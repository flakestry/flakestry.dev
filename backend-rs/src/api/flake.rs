use anyhow::Context;
use axum::{
    extract::{Path, Query, State},
    Json,
};
use chrono::NaiveDateTime;
use opensearch::{OpenSearch, SearchParts};
use serde_json::{json, Value};
use sqlx::{postgres::PgRow, FromRow, Pool, Postgres, Row};
use std::{cmp::Ordering, collections::HashMap, sync::Arc};

use crate::common::{AppError, AppState};

#[derive(serde::Serialize, Eq, utoipa::ToSchema)]
struct FlakeRelease {
    #[serde(skip_serializing)]
    id: i32,
    owner: String,
    repo: String,
    version: String,
    description: String,
    created_at: NaiveDateTime,
    #[schema(value_type = String)]
    #[serde(skip_serializing_if = "Option::is_none")]
    commit: Option<String>,
    #[schema(value_type = String)]
    #[serde(skip_serializing_if = "Option::is_none")]
    readme: Option<String>,
}

impl Ord for FlakeRelease {
    fn cmp(&self, other: &Self) -> Ordering {
        self.id.cmp(&other.id)
    }
}

impl PartialOrd for FlakeRelease {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialEq for FlakeRelease {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl FromRow<'_, PgRow> for FlakeRelease {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            id: row.try_get("id")?,
            owner: row.try_get("owner")?,
            repo: row.try_get("repo")?,
            version: row.try_get("version")?,
            description: row.try_get("description").unwrap_or_default(),
            created_at: row.try_get("created_at")?,
            commit: row.try_get("commit").ok(),
            readme: row.try_get("readme").ok(),
        })
    }
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct Release {
    #[serde(skip_serializing)]
    id: i32,
    repo_id: i32,
    readme_filename: Option<String>,
    readme: Option<String>,
    version: String,
    commit: String,
    description: Option<String>,
    created_at: NaiveDateTime,
    #[schema(value_type = Option<Object>)]
    meta_data: Option<Value>,
    meta_data_errors: Option<Vec<String>>,
    #[schema(value_type = Option<Object>)]
    outputs: Option<Value>,
    outputs_errors: Option<Vec<String>>,
}

impl FromRow<'_, PgRow> for Release {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            id: row.try_get("id")?,
            repo_id: row.try_get("repo_id")?,
            readme_filename: row.try_get("readme_filename").ok(),
            readme: row.try_get("readme").ok(),
            version: row.try_get("version")?,
            commit: row.try_get("commit")?,
            description: row.try_get("description").unwrap_or_default(),
            created_at: row.try_get("created_at")?,
            meta_data: row.try_get("meta_data").ok(),
            meta_data_errors: row.try_get("meta_data_errors").ok(),
            outputs: row.try_get("outputs").ok(),
            outputs_errors: row.try_get("outputs_errors").ok(),
        })
    }
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct GetFlakeResponse {
    releases: Vec<FlakeRelease>,
    count: usize,
    query: Option<String>,
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct GetOwnerResponse {
    repos: Vec<FlakeRelease>,
}

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct GetRepoResponse {
    releases: Vec<FlakeRelease>,
}

#[utoipa::path(
        get,
        path = "/api/flake",
        responses(
            (status = 200, description = "", body = GetFlakeResponse)
        ),
        params(
                ("q" = Option<String>, Query, description = ""),
            )

    )]
pub async fn get_flake(
    State(state): State<Arc<AppState>>,
    Query(mut params): Query<HashMap<String, String>>,
) -> Result<Json<GetFlakeResponse>, AppError> {
    let query = params.remove("q");
    let releases = if let Some(ref q) = query {
        let hits = search_flakes(&state.opensearch, q).await?;

        let mut releases = get_flakes_by_ids(hits.keys().collect(), &state.pool).await?;

        if !releases.is_empty() {
            // Should this be done by the DB?
            releases.sort();
        }

        releases
    } else {
        get_flakes(&state.pool).await?
    };

    let count = releases.len();

    Ok(Json(GetFlakeResponse {
        releases,
        count,
        query,
    }))
}

#[utoipa::path(
        get,
        path = "/api/flake/github/{owner}",
        responses(
            (status = 200, description = "", body = GetOwnerResponse)
        ),
        params(
                ("owner" = String, Path, description = ""),
            )
    )]
pub async fn get_owner(
    State(state): State<Arc<AppState>>,
    Path(owner): Path<String>,
) -> Result<Json<GetOwnerResponse>, AppError> {
    let repos = get_flakes_by_owner(&state.pool, &owner).await?;

    Ok(Json(GetOwnerResponse { repos }))
}

#[utoipa::path(
        get,
        path = "/api/flake/github/{owner}/{repo}",
        responses(
            (status = 200, description = "", body = GetRepoResponse)
        ),
        params(
                ("owner" = String, Path, description = ""),
                ("repo" = String, Path, description = ""),
            )
    )]
pub async fn get_repo(
    State(state): State<Arc<AppState>>,
    Path((owner, repo)): Path<(String, String)>,
) -> Result<Json<GetRepoResponse>, AppError> {
    let releases = get_flakes_by_owner_and_repo(&state.pool, &owner, &repo).await?;

    Ok(Json(GetRepoResponse { releases }))
}

#[utoipa::path(
        get,
        path = "/api/flake/github/{owner}/{repo}/{version}",
        responses(
            (status = 200, description = "", body = Release)
        ),
        params(
                ("owner" = String, Path, description = ""),
                ("repo" = String, Path, description = ""),
                ("version" = String, Path, description = ""),
            )
    )]
pub async fn get_version(
    State(state): State<Arc<AppState>>,
    Path((owner, repo, version)): Path<(String, String, String)>,
) -> Result<Json<Release>, AppError> {
    let release = get_release_by_owner_repo_version(&state.pool, &owner, &repo, &version).await?;
    Ok(Json(release))
}

async fn get_flakes_by_ids(
    flake_ids: Vec<&i32>,
    pool: &Pool<Postgres>,
) -> Result<Vec<FlakeRelease>, AppError> {
    if flake_ids.is_empty() {
        return Ok(vec![]);
    }

    let param_string = flake_ids.iter().fold(String::new(), |acc, &id| {
        format!("{acc}{}{id}", if acc.is_empty() { "" } else { "," })
    });
    let query = format!(
        "SELECT release.id AS id, \
            githubowner.name AS owner, \
            githubrepo.name AS repo, \
            release.version AS version, \
            release.description AS description, \
            release.created_at AS created_at \
            FROM release \
            INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
            INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
            WHERE release.id IN ({param_string})",
    );

    let releases: Vec<FlakeRelease> = sqlx::query_as(&query)
        .fetch_all(pool)
        .await
        .context("Failed to fetch flakes by id from database")?;

    Ok(releases)
}

async fn get_flakes(pool: &Pool<Postgres>) -> Result<Vec<FlakeRelease>, AppError> {
    let releases: Vec<FlakeRelease> = sqlx::query_as(
        "SELECT release.id AS id, \
            githubowner.name AS owner, \
            githubrepo.name AS repo, \
            release.version AS version, \
            release.description AS description, \
            release.created_at AS created_at \
            FROM release \
            INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
            INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
            ORDER BY release.created_at DESC LIMIT 100",
    )
    .fetch_all(pool)
    .await
    .context("Failed to fetch flakes from database")?;

    Ok(releases)
}

async fn get_flakes_by_owner(
    pool: &Pool<Postgres>,
    owner: &str,
) -> Result<Vec<FlakeRelease>, AppError> {
    let releases: Vec<FlakeRelease> = sqlx::query_as(
        "SELECT release.id AS id, \
            githubowner.name AS owner, \
            githubrepo.name AS repo, \
            release.version AS version, \
            release.description AS description, \
            release.created_at AS created_at \
            FROM release \
            INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
            INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
            WHERE githubowner.name = $1 \
            ORDER BY release.created_at DESC LIMIT 100",
    )
    .bind(owner)
    .fetch_all(pool)
    .await
    .context("Failed to fetch owner from database")?;

    Ok(releases)
}

async fn get_flakes_by_owner_and_repo(
    pool: &Pool<Postgres>,
    owner: &str,
    repo: &str,
) -> Result<Vec<FlakeRelease>, AppError> {
    let releases: Vec<FlakeRelease> = sqlx::query_as(
        "SELECT release.id AS id, \
            githubowner.name AS owner, \
            githubrepo.name AS repo, \
            release.version AS version, \
            release.description AS description, \
            release.created_at AS created_at, \
            release.commit AS commit, \
            release.readme AS readme \
            FROM release \
            INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
            INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
            WHERE githubowner.name = $1 AND githubrepo.name = $2",
    )
    .bind(owner)
    .bind(repo)
    .fetch_all(pool)
    .await
    .context("Failed to fetch owner and repo from database")?;

    Ok(releases)
}

async fn get_release_by_owner_repo_version(
    pool: &Pool<Postgres>,
    owner: &str,
    repo: &str,
    version: &str,
) -> Result<Release, AppError> {
    let release: Option<Release> = sqlx::query_as(
        "SELECT * \
            FROM release \
            INNER JOIN githubrepo ON githubrepo.id = release.repo_id \
            INNER JOIN githubowner ON githubowner.id = githubrepo.owner_id \
            WHERE githubowner.name = $1 AND githubrepo.name = $2 AND release.version = $3",
    )
    .bind(owner)
    .bind(repo)
    .bind(version)
    .fetch_optional(pool)
    .await
    .context("Failed to fetch release by version from database")?;

    match release {
        Some(release) => Ok(release),
        None => Err(AppError::NotFound),
    }
}

async fn search_flakes(opensearch: &OpenSearch, q: &String) -> Result<HashMap<i32, f64>, AppError> {
    let res = opensearch
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
        .await
        .context("Failed to send opensearch request")?
        .json::<Value>()
        .await
        .context("Failed to decode opensearch response as json")?;

    // TODO: Remove this unwrap, use fold or map to create the HashMap
    let mut hits: HashMap<i32, f64> = HashMap::new();

    let hit_res = res["hits"]["hits"]
        .as_array()
        .context("failed to extract hits from open search response")?;

    for hit in hit_res {
        let id = hit["_id"]
            .as_str()
            .context("failed to read id as string from open search hit")?
            .parse()
            .context("failed to parse id from open search hit")?;
        let score = hit["_score"]
            .as_f64()
            .context("failed to parse score from open search hit")?;

        hits.insert(id, score);
    }

    Ok(hits)
}
