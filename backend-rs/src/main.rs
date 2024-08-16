mod api;
mod common;

use axum::{
    extract::{ConnectInfo, Request},
    middleware::{self, Next},
    response::IntoResponse,
    routing::{get, post},
    Router,
};
use opensearch::{
    http::StatusCode,
    indices::{IndicesCreateParts, IndicesGetParts},
    OpenSearch,
};
use sqlx::postgres::PgPoolOptions;
use std::{env, net::SocketAddr, sync::Arc};
use tower_http::trace::TraceLayer;
use tracing::{field, info_span, Span};
use tracing_subscriber::{fmt, EnvFilter};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::api::{get_flake, post_publish};
use crate::common::AppState;

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
    let _ = create_flake_index(&state.opensearch).await;
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

async fn create_flake_index(opensearch: &OpenSearch) -> Result<(), opensearch::Error> {
    let status = opensearch
        .indices()
        .get(IndicesGetParts::Index(&["flakes"]))
        .send()
        .await?
        .status_code();

    if status == StatusCode::NOT_FOUND {
        let _ = opensearch
            .indices()
            .create(IndicesCreateParts::Index("flakes"))
            .send()
            .await?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    use axum::http::StatusCode;
    use std::env;
    use tokio::net::TcpListener;
    use tokio::task::JoinHandle;
    use url::Url;

    pub struct TestApp {
        pub base_url: Url,
        pub client: reqwest::Client,
        server: JoinHandle<()>,
    }

    impl TestApp {
        pub async fn new() -> TestApp {
            let database_url = env::var("DATABASE_URL").unwrap();
            let pool = PgPoolOptions::new().connect(&database_url).await.unwrap();
            let state = Arc::new(AppState {
                opensearch: OpenSearch::default(),
                pool,
            });
            let app = app(state);

            let listener = TcpListener::bind("127.0.0.1:0")
                .await
                .expect("Could not bind ephemeral socket");
            let addr = listener.local_addr().unwrap();
            let server = tokio::spawn(async move {
                axum::serve(
                    listener,
                    app.into_make_service_with_connect_info::<SocketAddr>(),
                )
                .await
                .unwrap();
            });

            TestApp {
                base_url: Url::parse(&format!("http://{addr}")).unwrap(),
                client: reqwest::Client::new(),
                server,
            }
        }

        pub fn get(&self, path: &str) -> reqwest::RequestBuilder {
            let base_url = Some(&self.base_url);
            let base = Url::options().base_url(base_url);
            let url = base.parse(path).unwrap();
            self.client.get(url)
        }
    }

    impl Drop for TestApp {
        fn drop(&mut self) {
            self.server.abort()
        }
    }

    #[tokio::test]
    async fn test_get_flake_with_params() {
        let app = TestApp::new().await;
        let expected_response = "{\"releases\":[{\"owner\":\"nix-community\",\"repo\":\"home-manager\",\"version\":\"23.05\",\"description\":\"\",\"created_at\":\"2024-07-12T23:08:41.029566\"}],\"count\":1,\"query\":\"search\"}";

        let response = app.get("/api/flake?q=search").send().await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let body = response.text().await.unwrap();
        assert_eq!(body, expected_response);
    }

    #[tokio::test]
    async fn test_get_flake_with_params_no_result() {
        let app = TestApp::new().await;
        let expected_response = "{\"releases\":[],\"count\":0,\"query\":\"nothing\"}";

        let response = app.get("/api/flake?q=nothing").send().await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let body = response.text().await.unwrap();
        assert_eq!(body, expected_response);
    }

    #[tokio::test]
    async fn test_get_flake_without_params() {
        let app = TestApp::new().await;
        let expected_response = "{\"releases\":[{\"owner\":\"nix-community\",\"repo\":\"home-manager\",\"version\":\"23.05\",\"description\":\"\",\"created_at\":\"2024-07-12T23:08:41.029566\"},{\"owner\":\"nixos\",\"repo\":\"nixpkgs\",\"version\":\"22.05\",\"description\":\"nixpkgs is official package collection\",\"created_at\":\"2024-07-12T23:08:41.005518\"},{\"owner\":\"nixos\",\"repo\":\"nixpkgs\",\"version\":\"23.05\",\"description\":\"nixpkgs is official package collection\",\"created_at\":\"2024-07-12T23:08:41.005518\"}],\"count\":3,\"query\":null}";

        let response = app.get("/api/flake").send().await.unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let body = response.text().await.unwrap();
        assert_eq!(body, expected_response);
    }
}
