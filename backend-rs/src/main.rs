use std::sync::Arc;

use axum::{
    extract::State,
    routing::{get, post},
    Router,
};
use opensearch::OpenSearch;

struct AppState {
    opensearch: OpenSearch,
}

#[tokio::main]
async fn main() {
    // build our application with a single route
    let state = Arc::new(AppState {
        opensearch: OpenSearch::default(),
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

async fn get_flake(State(state): State<Arc<AppState>>) -> &'static str {
    let opensearch = &state.opensearch;
    "Flake"
}

async fn post_publish() -> &'static str {
    "Publish"
}
