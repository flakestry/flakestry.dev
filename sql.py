from typing import Optional
import os
from datetime import datetime
from sqlmodel import Field, SQLModel, create_engine


class GitHubOwner(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )

class GitHubRepo(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    owner_id: Optional[int] = Field(default=None, foreign_key="githubowner.id")
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )

class Release(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    readme: str
    version: str = Field(sa_column_kwargs={"unique": True})
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
    )
    repo_id: Optional[int] = Field(default=None, foreign_key="githubrepo.id")

host = os.environ.get('PGHOST', None)

if host:
    engine_url = f"postgresql://flakestry?host={host}"
else:
    engine_url = os.environ['DATABASE_URL']

engine = create_engine(engine_url)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
