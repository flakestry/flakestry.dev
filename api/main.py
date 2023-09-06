from typing import Callable, Any, List, Union
import re
from datetime import datetime
import os
import requests
from functools import lru_cache
from fastapi import FastAPI, Depends, Header, Request, Response, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi_oidc import IDToken
from fastapi_oidc import get_auth
from pydantic import BaseModel
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from packaging.version import parse
from sqlmodel import Session, select
from opensearchpy import OpenSearch

from sql import create_db_and_tables, GitHubOwner, GitHubRepo, Release, engine

app = FastAPI(
    title="Flakestry.dev",
    version="0.0.1",
    openapi_version="3.0.0",
    # The subpath for our API.
    # Allows the API docs to find the correct path to the OpenAPI spec.
    root_path="/api",
)

# Override the default OpenAPI version.
# openapi-generator does not currently support 3.1.0.
app.openapi_version="3.0.0"

class ErrorDetail(BaseModel):
    loc: list[str]
    msg: str
    type: str

# Override the default ValidationError response to work with openapi-generator.
# In particular, we cannot have an anyOf type for the location field.
# TODO: Work on the error response
class ValidationError(BaseModel):
  detail: list[ErrorDetail]
  body: str

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
) -> Response:
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=jsonable_encoder({"detail": exc.errors(), "body": exc.body}),
    )

FastAPIInstrumentor.instrument_app(app)

opensearch_index = "flakes"

@lru_cache()
def get_opensearch():
    opensearch = OpenSearch(
        hosts = [{'host': 'localhost', 'port': 9200}],
    )

    if not opensearch.indices.exists(index=opensearch_index):
        opensearch.indices.create(opensearch_index, body={})
    return opensearch

# TODO: use pydantic_settings: fails to compile pyyaml
oidc_audience = os.environ['OIDC_AUDIENCE']
oidc_client_id = os.environ.get("OIDC_CLIENT_ID", "6779ef20e75817b79602")
oidc_issuer = os.environ.get("OIDC_ISSUER", "https://token.actions.githubusercontent.com")


OIDCConfig = {
    "client_id": oidc_client_id,
    "audience": oidc_audience,
    "base_authorization_server_uri": oidc_issuer,
    "issuer": oidc_issuer,
    "signature_cache_ttl": 3600,
}

authenticate_user: Callable = get_auth(**OIDCConfig)

def get_session():
    with Session(engine) as session:
        yield session



@app.on_event("startup")
def on_startup():
    create_db_and_tables()


class FlakeRelease(BaseModel):
    version: str
    commit: str
    created_at: datetime
    repo: GitHubRepo

class FlakesResponse(BaseModel):
    releases: List[FlakeRelease]

@app.get("/flake",
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

class OwnerResponse(BaseModel):
    repos: List[GitHubRepo]

@app.get("/flake/github/{owner}", 
         responses={
            422: {"model": ValidationError},
         })
def read_owner(owner: str, session: Session = Depends(get_session)) -> OwnerResponse:
    select(GitHubRepo).join(GitHubOwner).where(GitHubOwner.name == owner)
    repos = session.exec().all()
    return {
        "repos": repos
    }

class RepoResponse(BaseModel):
    releases: List[Release]
    latest: Release | None

@app.get("/flake/github/{owner}/{repo}",
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


class Publish(BaseModel):
    version: str
    metadata: Any | None
    metadata_errors: str | None
    readme: str | None
    outputs: Any | None
    outputs_errors: str | None


@app.post("/publish",
          responses={
            422: {"model": ValidationError},
         })
def publish(publish: Publish,
            token: IDToken = Depends(authenticate_user),
            github_token: str = Header(),
            opensearch: OpenSearch = Depends(get_opensearch),
            session: Session = Depends(get_session)) -> None:
    
    #if id_token.repository_visibility == "private":
        #return JSONResponse(status_code=400, 
        # content={"message": "Private repositories are not supported, \
        # see https://github.com/flakestry/flakestry.dev/issues"})
    
    version_regex = r'^v?([0-9]+\.[0-9]+\.?[0-9]*$)'
    version = re.search(version_regex, publish.version)
    if not version:
        return JSONResponse(
            status_code=400,
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
            status_code=400,
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
    }
    opensearch.index(
        index = opensearch_index,
        body = document,
        id = release.id,
        refresh = True
    )

    return {}
