from typing import List, Union
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from datetime import datetime
from sqlmodel import Session, select
from opensearchpy import OpenSearch
from packaging.version import parse

from flakestry.sql import GitHubOwner, GitHubRepo, Release, get_session
from flakestry.error import ValidationError
from flakestry.search import get_opensearch, opensearch_index

class FlakeRelease(BaseModel):
    version: str
    commit: str
    created_at: datetime
    repo: GitHubRepo

class FlakesResponse(BaseModel):
    releases: List[FlakeRelease]

class OwnerResponse(BaseModel):
    repos: List[GitHubRepo]

class RepoResponse(BaseModel):
    releases: List[Release]
    latest: Release | None

router = APIRouter()

@router.get("/flake",
         responses={
            422: {"model": ValidationError},
         })
def get_flakes( session: Session = Depends(get_session)
              , opensearch: OpenSearch = Depends(get_opensearch)
              , q: Union[str, None] = None) -> FlakesResponse:
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
        releases = session.exec(select(Release).where(Release.id.in_(ids))).all()
    else:
        q = select(Release).order_by(Release.created_at.desc()).limit(10)
        releases = session.exec(q).all()
    return {"releases": releases}

@router.get("/flake/github/{owner}", 
         responses={
            422: {"model": ValidationError},
         })
def read_owner(owner: str, session: Session = Depends(get_session)) -> OwnerResponse:
    select(GitHubRepo).join(GitHubOwner).where(GitHubOwner.name == owner)
    repos = session.exec().all()
    return {
        "repos": repos
    }

@router.get("/flake/github/{owner}/{repo}",
         responses={
            422: {"model": ValidationError},
         })
def read_repo( owner: str
             , repo: str
             , session: Session = Depends(get_session)) -> RepoResponse:
    repo = session.exec(select(GitHubRepo).join(GitHubOwner)\
        .where(GitHubOwner.name == owner).where(GitHubRepo.name == repo)).one()

    # get all releases for repo
    releases = session.exec(select(Release).where(Release.repo_id == repo.id)).all()
    releases = sorted(releases, key=lambda r: parse(r.version))
    if releases:
        latest = releases[-1]
    else:
        latest = None
    return { "releases": releases
           , "latest": latest
           }
