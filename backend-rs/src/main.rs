use axum::{
    routing::{get, post},
    Router,
};

#[tokio::main]
async fn main() {
    // build our application with a single route
    let api = Router::new()
        .route("/flake", get(|| async { "Hello, World!" }))
        .route("/publish", post(|| async { "Hello, World!" }));
    let app = Router::new().nest("/api", api);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
