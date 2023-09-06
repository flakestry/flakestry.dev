from typing import Optional, List
import os
from datetime import datetime
from sqlmodel import Field, Relationship, SQLModel, create_engine
from sqlalchemy import Column
from sqlalchemy.dialects.postgresql import JSONB


class GitHubOwner(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    repos: List["GitHubRepo"] = Relationship(back_populates="owner")

class GitHubRepo(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    owner_id: int = Field(default=None, foreign_key="githubowner.id")
    owner: GitHubOwner = Relationship(back_populates="repos")
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    releases: List["Release"] = Relationship(back_populates="repo")
    # TODO: unique owner_id, name


class Release(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    repo_id: int = Field(default=None, foreign_key="githubrepo.id")
    repo: GitHubRepo = Relationship(back_populates="releases")
    
    readme: Optional[str]
    version: str = Field(sa_column_kwargs={"unique": True})
    commit: str
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    meta_data: Optional[dict] = Field(default_factory=dict, sa_column=Column(JSONB))
    meta_data_errors: Optional[str]
    outputs: Optional[dict] = Field(default_factory=dict, sa_column=Column(JSONB))
    outputs_errors: Optional[str]
    

host = os.environ.get('PGHOST', None)

if host:
    engine_url = f"postgresql://flakestry?host={host}"
else:
    engine_url = os.environ['DATABASE_URL']

engine = create_engine(engine_url)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
