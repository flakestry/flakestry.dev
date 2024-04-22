use std::{collections::HashMap, sync::Arc};

use axum::{
    extract::{Query, State},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use opensearch::{OpenSearch, SearchParts};
use serde_json::{json, Value};
use sqlx::{postgres::PgPoolOptions, PgPool};

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
        todo!()
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
    let pool = PgPoolOptions::new()
        .connect("postgres://localhost:5432")
        .await
        .unwrap();
    let state = Arc::new(AppState {
        opensearch: OpenSearch::default(),
        pool,
    });
    let api = Router::new()
        .route("/flake", get(get_flake))
        .route("/publish", post(post_publish))
        .with_state(state);
    let app = Router::new().nest("/api", api);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn get_flake(
    State(state): State<Arc<AppState>>,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Json<GetFlakeResponse>, AppError> {
    let query = params.get("q");
    let releases = if let Some(q) = query {
        let response = &state
            .opensearch
            .search(SearchParts::Index(&["opensearch_index"]))
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
        let mut hits: HashMap<i64, i64> = HashMap::new();
        for hit in response["hits"]["hits"].as_array().unwrap() {
            // TODO: properly handle errors
            hits.insert(
                hit["_id"].as_i64().unwrap(),
                hit["_score"].as_i64().unwrap(),
            );
        }
        // TODO: This query is actually a join between different tables
        let mut releases = sqlx::query_as::<_, FlakeRelease>(
            "SELECT release.id AS id, \
                githubowner.name AS owner, \
                githubrepo.name AS repo, \
                release.version AS version, \
                release.description AS description, \
                release.created_at AS created_at \
                FROM release \
                INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
                INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
                WHERE release.id IN (?)",
        )
        .bind(hits.keys().cloned().collect::<Vec<i64>>())
        .fetch_all(&state.pool)
        .await?;
        releases.sort_by(|a, b| hits[&b.id].cmp(&hits[&a.id]));
        releases
    } else {
        // TODO: Update this query
        sqlx::query_as::<_, FlakeRelease>("SELECT * FROM release ORDER BY created_at LIMIT 100")
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
