from fastapi import FastAPI, Request, Response, status
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
import sentry_sdk
import os

from flakestry.sql import create_db_and_tables
import flakestry.api.publish
import flakestry.api.flake

if os.environ.get("SENTRY_DSN", None):
    sentry_sdk.init(
        dsn=os.environ["SENTRY_DSN"],
        traces_sample_rate=1.0,
    )

base_path = os.environ.get("BASE_PATH", "localhost:8000")

app = FastAPI(
    title="Flakestry.dev",
    version="0.0.1",
    # The subpath for our API.
    # Allows the API docs to find the correct path to the OpenAPI spec.
    root_path="/api",
    servers=[
        {"url": base_path},
    ],
)

# Override the default OpenAPI version.
# openapi-generator does not currently support 3.1.0.
app.openapi_version = "3.0.0"

origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://localhost:3000",
    "http://localhost:1234",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    create_db_and_tables()


# TODO: make the routes more visible from a glance
app.include_router(flakestry.api.publish.router)
app.include_router(flakestry.api.flake.router)

FastAPIInstrumentor.instrument_app(app)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
) -> Response:
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=jsonable_encoder({"detail": exc.errors(), "body": exc.body}),
    )
