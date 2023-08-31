from fastapi import FastAPI, Response
from fastapi.openapi.utils import get_openapi
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from pydantic import BaseModel
from fastapi.exceptions import RequestValidationError
from fastapi.responses import PlainTextResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

app = FastAPI(
    # servers=[
    #     { "url": "http://192.168.64.2:8888/api" },
    # ],
    root_path="/api",
    # The elm codegen only generates cross origin queries, so it needs to know
    # the base path. Since it can't tell the host, it uses localhost by
    # default. You either hardcode the url via "servers" above, or override
    # each query with withBasePath.
    # root_path_in_servers=False
)


# GitHub Org
#- slug

# GitHub Repo
#- name
#- description

# Release
#- version
#- created_on
#- revision
#- readme

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request, exc):
    return PlainTextResponse(str(exc.detail), status_code=exc.status_code)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc) -> Response:
    return PlainTextResponse(str(exc), status_code=422)

OIDC_config = {
    "client_id": "",
    # Audience can be omitted in which case the aud value defaults to client_id
    "audience": "https://yourapi.url.com/api",
    "base_authorization_server_uri": "https://dev-126594.okta.com",
    "issuer": "https://token.actions.githubusercontent.com",
    "signature_cache_ttl": 3600,
}

class MyValidationModel(BaseModel):
    detail: str

# @app.get("/flakes", responses={422: {"model": MyValidationModel}})
# async def get_flakes():
#     return {"flakes": [
#
#     ]}
#
# @app.get("/search", responses={422: {"model": MyValidationModel}})
# async def search():
#     return {"flakes": [
#
#     ]}

class Flake(BaseModel):
    name: str
    description: str
    versions: list[str]

class Flakes(BaseModel):
    flakes: list[Flake]

@app.get(
    "/flake/{org}",
     responses={
         422: {"model": MyValidationModel},
     },
)
async def get_org(org: str) -> Flakes:
    return {"flakes": [

    ]}

# @app.get("/flake/{org}/{repo}", responses={422: {"model": MyValidationModel}})
# async def get_repo(org: str, repo: str):
#     versions = ["1.1.2", "1.0.0", "1.3.3", "1.0.12", "1.0.2"]
#     versions.sort(key=StrictVersion)
#
#     return {
#         "org": org,
#         "repo": repo,
#         "description": "A flake",
#         "versions": versions
#     }
#
# @app.post("/publish", responses={422: {"model": MyValidationModel}})
# async def publish(version: str) -> None:
#     # verify OIDC
#     return

# https://fastapi.tiangolo.com/how-to/extending-openapi/
def flakestry_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="Custom title",
        version="2.5.0",
        description="Here's a longer description of the custom **OpenAPI** schema",
        openapi_version = "3.0.0",
        routes=app.routes,
        servers=app.servers,
    )

    # Cache the schema
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = flakestry_openapi
FastAPIInstrumentor.instrument_app(app)
