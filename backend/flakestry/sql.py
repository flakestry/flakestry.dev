from typing import Optional, List, Any
import os
from datetime import datetime
import logging
from sqlmodel import (
    Session,
    Field,
    Relationship,
    SQLModel,
    UniqueConstraint,
    create_engine,
)
from sqlalchemy import Column
from sqlalchemy.dialects.postgresql import JSONB

logger = logging.getLogger("uvicorn")


class GitHubOwner(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    repos: List["GitHubRepo"] = Relationship(back_populates="owner")


class GitHubRepo(SQLModel, table=True):
    __table_args__ = (UniqueConstraint("owner_id", "name", name="unique_owner_name"),)

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str]
    owner_id: int = Field(default=None, foreign_key="githubowner.id")
    owner: GitHubOwner = Relationship(
        back_populates="repos", sa_relationship_kwargs={"lazy": "joined"}
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    releases: List["Release"] = Relationship(back_populates="repo")


class Release(SQLModel, table=True):
    __table_args__ = (
        UniqueConstraint("repo_id", "version", name="unique_repo_version"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    repo_id: int = Field(default=None, foreign_key="githubrepo.id")
    repo: GitHubRepo = Relationship(
        back_populates="releases", sa_relationship_kwargs={"lazy": "joined"}
    )

    readme_filename: Optional[str]
    readme: Optional[str]
    version: str
    commit: str
    description: str | None
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    meta_data: Optional[dict[str, Any]] = Field(
        default_factory=dict, sa_column=Column(JSONB)
    )
    meta_data_errors: Optional[str]
    outputs: Optional[dict[str, Any]] = Field(
        default_factory=dict, sa_column=Column(JSONB)
    )
    outputs_errors: Optional[str]


scheme, rest = os.environ["DATABASE_URL"].split("://")
engine_url = f"postgresql+pg8000://{rest}"
# needed for pg8000
engine_url = engine_url.replace("?sslmode=disable", "")

# https://community.fly.io/t/postgresql-connection-issues-have-returned/6424/6
engine = create_engine(engine_url, pool_pre_ping=True)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session
