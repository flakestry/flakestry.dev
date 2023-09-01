from typing import Callable
from fastapi import FastAPI, Depends
from fastapi_oidc import IDToken
from fastapi_oidc import get_auth
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from distutils.version import StrictVersion

app = FastAPI()
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

@app.get("/flake")
def get_flakes():
    return {"flakes": [

    ]}


@app.get("/flake/{org}")
def read_org(org: str):
    return {
        "flakes": []
    }

@app.get("/flake/{org}/{repo}")
def read_repo(org: str, repo: str):
    
    versions = ["1.1.2", "1.0.0", "1.3.3", "1.0.12", "1.0.2"]
    versions.sort(key=StrictVersion)
    latest = versions[-1]
    
    return { versions: versions, latest: latest}

@app.post("/publish")
def read_item(id_token: IDToken = Depends(authenticate_user)):
    print(id_token)
    return {}
