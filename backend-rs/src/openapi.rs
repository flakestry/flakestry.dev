use crate::api;
use axum::Json;
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Flakestry API",
        version = "0.1.0",
        license(
            name = "Apache-2.0",
            url = "https://github.com/flakestry/flakestry.dev/blob/main/LICENSE.md"
        ),
    ),
    paths(
        api::get_flake,
        api::get_owner,
        api::get_repo,
        api::get_version,
        api::post_publish
    )
)]
pub struct ApiDoc;

#[utoipa::path(
    get,
    path = "/openapi.json",
    responses(
        (status = 200, description = "JSON file", body = ())
    )
)]
pub async fn openapi() -> Json<utoipa::openapi::OpenApi> {
    Json(ApiDoc::openapi())
}
