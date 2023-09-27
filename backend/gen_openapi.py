from fastapi.openapi.utils import get_openapi
from flakestry.main import app
import json

with open("frontend/openapi.json", "w") as f:
    json.dump(
        get_openapi(
            title=app.title,
            description=app.description,
            version=app.version,
            openapi_version=app.openapi_version,
            routes=app.routes,
            servers=app.servers,
        ),
        f,
    )
