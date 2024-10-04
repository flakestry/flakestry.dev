use axum::{http::StatusCode, response::IntoResponse, Json};
use opensearch::OpenSearch;
use sqlx::postgres::PgPool;

pub struct AppState {
    pub opensearch: OpenSearch,
    pub pool: PgPool,
}

pub struct AppError(anyhow::Error);

impl From<anyhow::Error> for AppError {
    fn from(value: anyhow::Error) -> Self {
        AppError(value)
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
       let body = self.0.to_string();
        (StatusCode::INTERNAL_SERVER_ERROR, Json(body)).into_response()
    }
}
