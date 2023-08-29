from fastapi import FastAPI
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from distutils.version import StrictVersion

app = FastAPI()


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

OIDC_config = {
    "client_id": "",
    # Audience can be omitted in which case the aud value defaults to client_id
    "audience": "https://yourapi.url.com/api",
    "base_authorization_server_uri": "https://dev-126594.okta.com",
    "issuer": "https://token.actions.githubusercontent.com",
    "signature_cache_ttl": 3600,
}

@app.get("/flakes")
def get_flakes():
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
    
    versions = ["1.1.2", "1.0.0", "1.3.3", "1.0.12", "1.0.2"]
    versions.sort(key=StrictVersion)
    
    return { versions: versions }

@app.get("/publish")
def read_item(version: str):
    # verify OIDC
    return {}

FastAPIInstrumentor.instrument_app(app)