from typing import List, Optional
from fastapi import APIRouter, Depends, status
from fastapi.exceptions import HTTPException
from fastapi.responses import Response
from pydantic import BaseModel
from datetime import datetime
from sqlmodel import Session, select, col
from opensearchpy import OpenSearch
from packaging.version import parse
import anybadge

from flakestry.sql import GitHubOwner, GitHubRepo, Release, get_session
from flakestry.error import ValidationError
from flakestry.search import get_opensearch, opensearch_index


# A compact subset of a FlakeRelease for use in search results
class FlakeReleaseCompact(BaseModel):
    owner: str
    repo: str
    version: str
    description: str
    created_at: datetime


class FlakeRelease(FlakeReleaseCompact):
    commit: str
    readme: str


class FlakesResponse(BaseModel):
    releases: List[FlakeReleaseCompact]
    count: int
    query: Optional[str] = None


class OwnerResponse(BaseModel):
    repos: List[FlakeReleaseCompact]


class RepoResponse(BaseModel):
    releases: List[FlakeRelease]


router = APIRouter()


@router.get(
    "/flake",
    response_model=FlakesResponse,
    responses={
        422: {"model": ValidationError},
    },
)
def get_flakes(
    session: Session = Depends(get_session),
    opensearch: OpenSearch = Depends(get_opensearch),
    q: Optional[str] = None,
):
    if q:
        response = opensearch.search(
            body={
                "size": 10,
                "query": {
                    "multi_match": {
                        "query": q,
                        "fuzziness": "AUTO",
                        "fields": [
                            "description^2",
                            "readme",
                            "outputs",
                            "repo^2",
                            "owner^2",
                        ],
                    }
                },
            },
            index=opensearch_index,
        )

        # A map of release ids to search scores
        hits = dict(
            [(int(hit["_id"]), hit["_score"]) for hit in response["hits"]["hits"]]
        )

        releases = session.exec(
            select(Release).where(col(Release.id).in_(hits.keys()))
        ).all()
        # Sort the releases by their search score
        releases.sort(key=lambda r: hits[r.id], reverse=True)

    else:
        statement = select(Release).order_by(Release.created_at.desc()).limit(10)
        releases = session.exec(statement).all()

    releases = list(map(toFlakeReleaseCompact, releases))
    return {"releases": releases, "count": len(releases), "query": q}


@router.get(
    "/flake/github/{owner}",
    response_model=OwnerResponse,
    responses={
        422: {"model": ValidationError},
    },
)
def read_owner(owner: str, session: Session = Depends(get_session)):
    # get all repos
    q = (
        select(GitHubRepo)
        .join(GitHubOwner)
        .where(GitHubOwner.name == owner)
        .order_by(GitHubRepo.created_at.desc())
    )
    repos = session.exec(q).all()

    # get latest versions for repos
    releases = []
    for repo in repos:
        sorted_releases = sort_releases(repo.releases)
        if sorted_releases:
            releases.append(sorted_releases[-1])

    releases_response = map(toFlakeReleaseCompact, releases)
    return {"repos": list(releases_response)}


@router.get(
    "/flake/github/{owner}/{repo}",
    response_model=RepoResponse,
    responses={
        422: {"model": ValidationError},
    },
)
def read_repo(owner: str, repo: str, session: Session = Depends(get_session)):
    statement = (
        select(GitHubRepo)
        .join(GitHubOwner)
        .where(GitHubOwner.name == owner)
        .where(GitHubRepo.name == repo)
    )
    github_repo = session.exec(statement).first()

    if not github_repo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    # get all releases for repo
    statement = select(Release).where(col(Release.repo_id) == github_repo.id)
    releases = session.exec(statement).all()
    releases = sort_releases(releases)
    return {"releases": list(map(toFlakeRelease, releases))}


def sort_releases(releases):
    return sorted(releases, key=lambda r: parse(r.version), reverse=True)


def toFlakeReleaseCompact(release: Release) -> FlakeReleaseCompact:
    return FlakeReleaseCompact(
        owner=release.repo.owner.name,
        repo=release.repo.name,
        version=release.version,
        description=release.description or "",
        created_at=release.created_at,
    )


def toFlakeRelease(release: Release) -> FlakeRelease:
    return FlakeRelease(
        owner=release.repo.owner.name,
        repo=release.repo.name,
        description=release.description or "",
        version=release.version,
        commit=release.commit,
        created_at=release.created_at,
        readme=release.readme or "",
    )


@router.get(
    "/badge/flake/github/{owner}/{repo}",
    responses={
        422: {"model": ValidationError},
        200: {"content": {"image/svg+xml": {}}},
    },
    response_class=Response,
)
def badge(owner: str, repo: str, session: Session = Depends(get_session)):
    releases = read_repo(owner, repo, session)
    latest = releases["releases"][0]
    badge = anybadge.Badge(
        label="flakestry.dev",
        value=latest.version,
        default_color="darkblue",
        num_padding_chars=1,
    )
    return Response(content=badge.badge_svg_text, media_type="image/svg+xml")


@router.get(
    "/flake/github/{owner}/{repo}/{version}",
    response_model=Release,
    responses={
        422: {"model": ValidationError},
    },
)
def read_version(
    owner: str, repo: str, version: str, session: Session = Depends(get_session)
):
    statement = (
        select(Release)
        .join(GitHubRepo)
        .join(GitHubOwner)
        .where(GitHubOwner.name == owner)
        .where(GitHubRepo.name == repo)
        .where(Release.version == version)
    )
    return session.exec(statement).first()
