from typing import Union

from fastapi import FastAPI

app = FastAPI()

from fastapi_oidc import IDToken
from fastapi_oidc import get_auth

OIDC_config = {
    "client_id": "",
    # Audience can be omitted in which case the aud value defaults to client_id
    "audience": "https://yourapi.url.com/api",
    "base_authorization_server_uri": "https://dev-126594.okta.com",
    "issuer": "https://token.actions.githubusercontent.com",
    "signature_cache_ttl": 3600,
}

@app.post("/flakes")
def post_flakes():
    return {"flakes": [

    ]}

@app.get("/search")
def read_search():
    return {"flakes": [

    ]}

@app.get("/flake/{org}")
def read_org(org: str):
    return {"item_id": item_id, "q": q}

@app.get("/flake/{org}/{repo}")
def read_org(org: str, repo: str):
    return {"item_id": item_id, "q": q}

@app.get("/flake/{org}/{repo}")
def read_org(org: str, repo: str):
    return {"item_id": item_id, "q": q}

@app.get("/publish")
def read_item(version: str, q: Union[str, None] = None):
    # verify JWT
    # TODO: upload source to an S3 bucket
    return {"item_id": item_id, "q": q}