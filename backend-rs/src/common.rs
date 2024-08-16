use axum::{http::StatusCode, response::IntoResponse, Json};
use opensearch::OpenSearch;
use sqlx::postgres::PgPool;

pub struct AppState {
    pub opensearch: OpenSearch,
    pub pool: PgPool,
}

pub enum AppError {
    OpenSearchError(opensearch::Error),
    SqlxError(sqlx::Error),
}

impl From<opensearch::Error> for AppError {
    fn from(value: opensearch::Error) -> Self {
        AppError::OpenSearchError(value)
    }
}

impl From<sqlx::Error> for AppError {
    fn from(value: sqlx::Error) -> Self {
        AppError::SqlxError(value)
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let body = match self {
            AppError::OpenSearchError(error) => error.to_string(),
            AppError::SqlxError(error) => error.to_string(),
        };
        (StatusCode::INTERNAL_SERVER_ERROR, Json(body)).into_response()
    }
}
