#[utoipa::path(
        post,
        path = "/api/publish",
        responses(
            (status = 200, description = "", body = str)
        )
    )]
pub async fn post_publish() -> &'static str {
    "Publish"
}
