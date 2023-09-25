import os
from fastapi_oidc import get_auth
from typing import Callable

# TODO: use pydantic_settings: fails to compile pyyaml
oidc_audience = os.environ.get('FLAKESTRY_URL', 'http://localhost:8000')
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
