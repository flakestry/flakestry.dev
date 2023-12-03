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
    ref: str | None
    version: str | None
    metadata: dict[str, Any] | None
    metadata_errors: str | None
    readme: str | None
    outputs: dict[str, Any] | None
    outputs_errors: str | None


router = APIRouter()


@router.post(
    "/publish",
    status_code=status.HTTP_201_CREATED,
    response_model=None,
    responses={
        422: {"model": ValidationError},
    },
)
def publish(
    publish: Publish,
    token: IDToken = Depends(authenticate_user),
    github_token: str = Header(),
    opensearch: OpenSearch = Depends(get_opensearch),
    session: Session = Depends(get_session),
):
    # if id_token.repository_visibility == "private":
    # return JSONResponse(status_code=400,
    # content={"message": "Private repositories are not supported, \
    # see https://github.com/flakestry/flakestry.dev/issues"})

    github_headers = {
        "Authorization": f"Bearer {github_token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "Accept": "application/vnd.github+json",
    }

    owner_name, repository_name = token.repository.split("/")
    if publish.ref:
        ref = publish.ref
    elif publish.version:
        ref = f"refs/tags/{publish.version}"
    else:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"message": 'Neither "ref" nor "version" were provided'},
        )

    # Get info on the commit to be published
    commit_response = requests.get(
        f"https://api.github.com/repos/{owner_name}/{repository_name}/commits/{ref}",
        headers=github_headers,
    )
    commit_response.raise_for_status()
    commit_json = commit_response.json()
    commit_sha = commit_json["sha"]
    commit_date = commit_json["commit"]["committer"]["date"]

    # Validate & parse version
    datetime = re.sub(r"[^0-9]", "", commit_date)
    if publish.version:
        given_version = publish.version.format(
            datetime=datetime,
            date=datetime[:8],
            time=datetime[8:],
        )
    elif publish.ref and publish.ref.startswith("refs/tags/"):
        given_version = publish.ref.removeprefix("refs/tags/")
    else:
        given_version = f"v0.1.{datetime}"

    version_regex = r"^v?([0-9]+\.[0-9]+\.?[0-9]*$)"
    version = re.search(version_regex, given_version)
    if not version:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"message": f"{given_version} doesn't match regex {version_regex}"},
        )
    else:
        version = version.groups()[0]

    # Create owner if it doesn't exist
    owner = session.exec(
        select(GitHubOwner).where(GitHubOwner.name == owner_name)
    ).first()
    if not owner:
        owner = GitHubOwner(name=owner_name)
        session.add(owner)
        session.commit()
        session.refresh(owner)

    # Create repository if it doesn't exist
    repo = session.exec(
        select(GitHubRepo)
        .where(GitHubRepo.name == repository_name)
        .where(GitHubRepo.owner_id == owner.id)
    ).first()
    if not repo:
        repo = GitHubRepo(name=repository_name, owner_id=owner.id)
        session.add(repo)
        session.commit()
        session.refresh(repo)

    # 409 if version already exists
    if session.exec(
        select(Release)
        .where(Release.version == version)
        .where(Release.repo_id == repo.id)
    ).first():
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={"message": f"Version {version} already exists"},
        )

    # index README
    try:
        description = publish.metadata["description"]
    except Exception:
        description = None

    path = f"{owner_name}/{repository_name}/{commit_sha}/{publish.readme}"
    if publish.readme:
        readme_response = requests.get(
            f"https://raw.githubusercontent.com/{path}", headers=github_headers
        )
        readme_response.raise_for_status()
        readme = readme_response.text
    else:
        readme = None

    # Do release
    release = Release(
        repo_id=repo.id,
        version=version,
        readme_filename=publish.readme,
        readme=readme,
        commit=commit_sha,
        description=description,
        meta_data=publish.metadata,
        meta_data_errors=publish.metadata_errors,
        outputs=publish.outputs,
        outputs_errors=publish.outputs_errors,
    )
    session.add(release)
    session.commit()
    session.refresh(release)

    # Index release
    document = {
        "description": description,
        "readme": readme,
        "outputs": str(publish.outputs),
        "repo": repository_name,
        "owner": owner_name,
    }
    opensearch.index(index=opensearch_index, body=document, id=release.id, refresh=True)

    return {}
