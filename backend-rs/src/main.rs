use axum::{
    routing::{get, post},
    Router,
};

#[tokio::main]
async fn main() {
    // build our application with a single route
    let api = Router::new()
        .route("/flake", get(get_flake))
        .route("/publish", post(post_publish));
    let app = Router::new().nest("/api", api);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn get_flake() -> &'static str {
    "Flake"
}

async fn post_publish() -> &'static str {
    "Publish"
}
