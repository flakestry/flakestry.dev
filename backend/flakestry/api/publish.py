from typing import Any
from fastapi import APIRouter, Depends, Header, status
from fastapi_oidc import IDToken
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from opensearchpy import OpenSearch
import re
import requests
from sqlmodel import Session, select

from flakestry.error import ValidationError
from flakestry.oidc import authenticate_user
from flakestry.search import get_opensearch, opensearch_index
from flakestry.sql import GitHubOwner, GitHubRepo, Release, get_session

class Publish(BaseModel):
    version: str
    metadata: dict[str,Any] | None
    metadata_errors: str | None
    readme: str | None
    outputs: dict[str,Any] | None
    outputs_errors: str | None

router = APIRouter()

@router.post("/publish",
    status_code=status.HTTP_201_CREATED,
    response_model=None,
    responses={
        422: {"model": ValidationError},
    }
)
def publish(publish: Publish,
            token: IDToken = Depends(authenticate_user),
            github_token: str = Header(),
            opensearch: OpenSearch = Depends(get_opensearch),
            session: Session = Depends(get_session)):

    #if id_token.repository_visibility == "private":
        #return JSONResponse(status_code=400, 
        # content={"message": "Private repositories are not supported, \
        # see https://github.com/flakestry/flakestry.dev/issues"})

    version_regex = r'^v?([0-9]+\.[0-9]+\.?[0-9]*$)'
    version = re.search(version_regex, publish.version)
    if not version:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "message": f"{publish.version} doesn't match regex {version_regex}"
            })
    else:
        version = version.groups()[0]
    owner_name, repository_name = token.repository.split("/")

    # Create owner if it doesn't exist
    owner = session.exec(select(GitHubOwner)\
        .where(GitHubOwner.name == owner_name)).first()
    if not owner:
        owner = GitHubOwner(name=owner_name)
        session.add(owner)
        session.commit()
        session.refresh(owner)

    # Create repository if it doesn't exist
    repo = session.exec(select(GitHubRepo)\
                        .where(GitHubRepo.name == repository_name)\
                        .where(GitHubRepo.owner_id == owner.id)).first()
    if not repo:
        repo = GitHubRepo(name=repository_name, owner_id=owner.id)
        session.add(repo)
        session.commit()
        session.refresh(repo)

    # 400 if version already exists
    if session.exec(select(Release).where(Release.version == version)\
                    .where(Release.repo_id == repo.id)).first():
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "message": f"Version {publish.version} already exists"
            })

    github_headers = {
        "Authorization": f"Bearer {github_token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "Accept": "application/vnd.github+json"
    }
    ref_response = requests.get(
        f"https://api.github.com/repos/{owner_name}/{repository_name}/git/ref/tags/{publish.version}",
        headers=github_headers)
    ref_response.raise_for_status()
    commit = ref_response.json()['object']['sha']
 
    release = Release(
        repo_id=repo.id,
        version=version,
        readme=publish.readme,
        commit=commit,
        meta_data=publish.metadata,
        meta_data_errors=publish.metadata_errors,
        outputs=publish.outputs,
        outputs_errors=publish.outputs_errors,
    )
    session.add(release)
    session.commit()
    session.refresh(release)

    # index README
    try:
        description = publish.metadata['description']
    except Exception:
        description = ''

    path = f"{owner_name}/{repository_name}/{commit}/{publish.readme}"
    readme_response = requests.get(
        f"https://raw.githubusercontent.com/{path}",
        headers=github_headers
    )
    readme_response.raise_for_status()

    document = {
        'description': description,
        'readme': readme_response.text,
        'outputs': str(publish.outputs),
        'repo': repository_name,
        'owner': owner_name,
    }
    opensearch.index(
        index = opensearch_index,
        body = document,
        id = release.id,
        refresh = True
    )

    return {}
