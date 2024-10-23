use backend_rs::openapi::ApiDoc;
use std::fs;
use utoipa::OpenApi;

fn main() {
    let base_path = std::env::var("BASE_PATH").unwrap_or_else(|_| "/".to_string());
    let servers = utoipa::openapi::server::Server::builder()
        .url(format!("http://{}", base_path))
        .build();
    let server_spec = utoipa::openapi::OpenApi::builder()
        .servers(Some(vec![servers]))
        .build();
    let spec = ApiDoc::openapi()
        .merge_from(server_spec)
        .to_json()
        .expect("failed to generate OpenApi spec");

    fs::write("openapi.json", spec).expect("failed to write OpenApi spec to file");
}
