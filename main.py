from typing import Callable
from fastapi import FastAPI, Depends, Request, Response, status
from fastapi.openapi.utils import get_openapi
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi_oidc import IDToken
from fastapi_oidc import get_auth
from pydantic import BaseModel
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from distutils.version import StrictVersion

app = FastAPI(
    # The subpath for our API.
    # Allows the API docs to find the correct path to the OpenAPI spec.
    root_path="/api",
)

# Override the schema to use OpenAPI 3.0.0.
# OpenAPI 3.1 is not supported by openapi-generator.
# https://fastapi.tiangolo.com/how-to/extending-openapi/
def flakestry_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="Flakestry.dev",
        version="0.0.1",
        openapi_version="3.0.0",
        routes=app.routes,
        servers=app.servers,
    )

    # Cache the schema
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = flakestry_openapi
FastAPIInstrumentor.instrument_app(app)

OIDCConfig = {
    "client_id": "6779ef20e75817b79602",
    # Audience can be omitted in which case the aud value defaults to client_id
    #"audience": "https://yourapi.url.com/api",
    "base_authorization_server_uri": "https://token.actions.githubusercontent.com",
    "issuer": "token.actions.githubusercontent.com",
    "signature_cache_ttl": 3600,
}

authenticate_user: Callable = get_auth(**OIDCConfig)

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

@app.get(
    "/flake",
     responses={
         422: {"model": ValidationError},
     },
)
def get_flakes():
    return {"flakes": [

    ]}

@app.get(
    "/flake/{org}",
      responses={
         422: {"model": ValidationError},
     },
)
def read_org(org: str):
    return {
        "flakes": []
    }

@app.get(
    "/flake/{org}/{repo}",
    responses={
        422: {"model": ValidationError},
    },
)
def read_repo(org: str, repo: str):
    versions = ["1.1.2", "1.0.0", "1.3.3", "1.0.12", "1.0.2"]
    versions.sort(key=StrictVersion)
    latest = versions[-1]

    return { "versions": versions, "latest": latest}

@app.post(
    "/publish",
    responses={
        422: {"model": ValidationError},
    },
)
def read_item(id_token: IDToken = Depends(authenticate_user)):
    print(id_token)
    return {}
