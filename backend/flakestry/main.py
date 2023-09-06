from fastapi import FastAPI, Request, Response, status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

from flakestry.sql import create_db_and_tables
import flakestry.api.publish
import flakestry.api.flake

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

