from fastapi import FastAPI

app = FastAPI()


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
    return {}

@app.get("/flake/{org}/{repo}")
def read_repo(org: str, repo: str):
    return {}

@app.get("/publish")
def read_item(version: str):
    # verify OIDC
    return {}