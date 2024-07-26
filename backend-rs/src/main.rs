use std::{collections::HashMap, env, net::SocketAddr, sync::Arc};

use axum::{
    extract::{ConnectInfo, Query, Request, State},
    http::StatusCode,
    middleware::{self, Next},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use opensearch::{indices::IndicesCreateParts, OpenSearch, SearchParts};
use serde_json::{json, Value};
use sqlx::postgres::{PgPool, PgPoolOptions};
use tower_http::trace::TraceLayer;
use tracing::{field, info_span, Span};
use tracing_subscriber::{fmt, EnvFilter};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

struct AppState {
    opensearch: OpenSearch,
    pool: PgPool,
}

enum AppError {
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

#[derive(serde::Serialize)]
struct GetFlakeResponse {
    releases: Vec<FlakeRelease>,
    count: usize,
    query: Option<String>,
}

#[derive(serde::Serialize, sqlx::FromRow)]
struct FlakeRelease {
    #[serde(skip_serializing)]
    id: i64,
    owner: String,
    repo: String,
    version: String,
    description: String,
    // TODO: Change to DateTime?
    created_at: String,
}

#[tokio::main]
async fn main() {
    // TODO: read PG and OS host names from env variables
    // build our application with a single route
    dotenv::dotenv().ok();
    tracing_subscriber::registry()
        .with(fmt::layer().with_target(false))
        .with(EnvFilter::from_default_env())
        .init();
    let database_url = env::var("DATABASE_URL").unwrap();
    let pool = PgPoolOptions::new().connect(&database_url).await.unwrap();
    let state = Arc::new(AppState {
        opensearch: OpenSearch::default(),
        pool,
    });
    // TODO: check if index exist before creating one
    let _ = state
        .opensearch
        .indices()
        .create(IndicesCreateParts::Index("flakes"))
        .send()
        .await;
    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::info!("Listening on 0.0.0.0:3000");
    axum::serve(
        listener,
        app(state).into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await
    .unwrap();
}

async fn add_ip_trace(
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    req: Request,
    next: Next,
) -> impl IntoResponse {
    Span::current().record("ip", format!("{}", addr));

    next.run(req).await
}

fn app(state: Arc<AppState>) -> Router {
    let api = Router::new()
        .route("/flake", get(get_flake))
        .route("/publish", post(post_publish));
    Router::new()
        .nest("/api", api)
        .layer(middleware::from_fn(add_ip_trace))
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(
                    |request: &Request| {
                        info_span!("request", ip = field::Empty, method = %request.method(), uri = %request.uri(), version = ?request.version())
                    }
                )
        )
        .with_state(state)
}

async fn get_flake(
    State(state): State<Arc<AppState>>,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Json<GetFlakeResponse>, AppError> {
    let query = params.get("q");
    let releases = if let Some(q) = query {
        let response = &state
            .opensearch
            .search(SearchParts::Index(&["flakes"]))
            .size(10)
            .body(json!({
                "query": {
                    "multi_match": {
                        "query": q,
                        "fuzziness": "AUTO",
                        "fields": [
                            "description^2",
                            "readme",
                            "outputs",
                            "repo^2",
                            "owner^2",
                        ],
                    }
                }
            }))
            .send()
            .await?
            .json::<Value>()
            .await?;
        // TODO: Remove this unwrap, use fold or map to create the HashMap
        let mut hits: HashMap<i64, f64> = HashMap::new();
        for hit in response["hits"]["hits"].as_array().unwrap() {
            // TODO: properly handle errors
            hits.insert(
                hit["_id"].as_str().unwrap().parse().unwrap(),
                hit["_score"].as_f64().unwrap(),
            );
        }
        // TODO: This query is actually a join between different tables
        let mut releases = sqlx::query_as::<_, FlakeRelease>(
            "SELECT release.id AS id, \
                githubowner.name AS owner, \
                githubrepo.name AS repo, \
                release.version AS version, \
                release.description AS description, \
                CAST(release.created_at AS VARCHAR) AS created_at \
                FROM release \
                INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
                INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
                WHERE release.id IN (1)",
        )
        // .bind(hits.keys().cloned().collect::<Vec<i64>>())
        .fetch_all(&state.pool)
        .await?;
        releases.sort_by(|a, b| hits[&b.id].partial_cmp(&hits[&a.id]).unwrap());
        releases
    } else {
        sqlx::query_as::<_, FlakeRelease>(
            "SELECT release.id AS id, \
                githubowner.name AS owner, \
                githubrepo.name AS repo, \
                release.version AS version, \
                release.description AS description, \
                CAST(release.created_at AS VARCHAR) AS created_at \
                FROM release \
                INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
                INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
                ORDER BY release.created_at DESC LIMIT 100",
        )
        .fetch_all(&state.pool)
        .await?
    };
    let count = releases.len();
    return Ok(Json(GetFlakeResponse {
        releases,
        count,
        // TODO: Try to avoid using cloned()
        query: query.cloned(),
    }));
}

async fn post_publish() -> &'static str {
    "Publish"
}

#[cfg(test)]
mod tests {
    use std::env;

    use super::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use http_body_util::BodyExt;
    use sqlx::postgres::PgConnectOptions;
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_get_flake_with_params() {
        let host = env::var("PGHOST").unwrap().to_string();
        let opts = PgConnectOptions::new().host(&host);
        let pool = PgPoolOptions::new().connect_with(opts).await.unwrap();
        let state = Arc::new(AppState {
            opensearch: OpenSearch::default(),
            pool,
        });
        let app = app(state);
        let response = app
            .oneshot(
                Request::builder()
                    .uri("/api/flake?q=search")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();
        println!("#{body}");
        // assert_eq!(response.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_get_flake_without_params() {
        let host = env::var("PGHOST").unwrap().to_string();
        let opts = PgConnectOptions::new().host(&host);
        let pool = PgPoolOptions::new().connect_with(opts).await.unwrap();
        let state = Arc::new(AppState {
            opensearch: OpenSearch::default(),
            pool,
        });
        let app = app(state);
        let response = app
            .oneshot(
                Request::builder()
                    .uri("/api/flake")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
    }
}
