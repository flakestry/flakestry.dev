from typing import List, Union
from fastapi import APIRouter, Depends, status
from fastapi.exceptions import HTTPException
from pydantic import BaseModel
from datetime import datetime
from sqlmodel import Session, select, col
from opensearchpy import OpenSearch
from packaging.version import parse

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

class OwnerResponse(BaseModel):
    repos: List[FlakeReleaseCompact]

class RepoResponse(BaseModel):
    latest: FlakeRelease | None
    releases: List[FlakeRelease]

router = APIRouter()

@router.get("/flake",
    response_model=FlakesResponse,
    responses={
        422: {"model": ValidationError},
    })
def get_flakes( session: Session = Depends(get_session)
              , opensearch: OpenSearch = Depends(get_opensearch)
              , q: Union[str, None] = None):
    if q:
        response = opensearch.search(
            body = {
                'size': 10,
                'query': {
                    'multi_match': {
                        'query': q,
                        'fields': ['description^2', 'readme', 'outputs']
                    }
                }
            },
            index = opensearch_index
        )
        ids = [int(hit['_id']) for hit in response['hits']['hits']]
        releases = session.exec(select(Release).where(col(Release.id).in_(ids))).all()
    else:
        statement = select(Release).order_by(col(Release.created_at)).limit(10)
        releases = session.exec(statement).all()

    releases = list(map(toFlakeReleaseCompact, releases))

    return {"releases": releases}

@router.get("/flake/github/{owner}",
    response_model=OwnerResponse,
    responses={
        422: {"model": ValidationError},
    })
def read_owner(owner: str, session: Session = Depends(get_session)):
    q = select(Release).join(GitHubRepo).join(GitHubOwner)\
            .where(GitHubOwner.name == owner)
    repos = session.exec(q).all()
    repo_response = map(toFlakeReleaseCompact, repos)
    return {"repos": list(repo_response)}

@router.get("/flake/github/{owner}/{repo}",
    response_model=RepoResponse,
    responses={
        422: {"model": ValidationError},
    })
def read_repo( owner: str
             , repo: str
             , session: Session = Depends(get_session)):
    statement = select(GitHubRepo).join(GitHubOwner)\
        .where(GitHubOwner.name == owner).where(GitHubRepo.name == repo)
    github_repo = session.exec(statement).first()

    if not github_repo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    # get all releases for repo
    statement = select(Release).where(col(Release.repo_id) == github_repo.id)
    releases = session.exec(statement).all()
    releases = sorted(releases, key=lambda r: parse(r.version))
    if releases:
        latest = toFlakeRelease(releases[-1])
    else:
        latest = None
    return { "releases": list(map(toFlakeRelease, releases)),
             "latest": latest
           }

def toFlakeReleaseCompact(release: Release) -> FlakeReleaseCompact:
    return FlakeReleaseCompact(
        owner=release.repo.owner.name,
        repo=release.repo.name,
        version=release.version,
        description=release.repo.description or "",
        created_at=release.created_at,
    )

def toFlakeRelease(release: Release) -> FlakeRelease:
    return FlakeRelease(
        owner=release.repo.owner.name,
        repo=release.repo.name,
        description=release.repo.description or "",
        version=release.version,
        commit=release.commit,
        created_at=release.created_at,
        readme=release.readme or ""
    )
