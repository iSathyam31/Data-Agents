"""Database connection factories using SQLAlchemy."""

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

from dash_strands import config


def _build_url(sslmode: str = "require") -> str:
    from urllib.parse import quote_plus
    password = quote_plus(config.DB_PASS)
    return (
        f"postgresql+psycopg2://{config.DB_USER}:{password}"
        f"@{config.DB_HOST}:{config.DB_PORT}/{config.DB_DATABASE}"
        f"?sslmode={sslmode}"
    )


_readonly_engine: Engine | None = None
_write_engine: Engine | None = None


def get_readonly_engine() -> Engine:
    """Engine for the Analyst — enforces read-only at connection level."""
    global _readonly_engine
    if _readonly_engine is None:
        _readonly_engine = create_engine(
            _build_url(),
            pool_size=3,
            max_overflow=2,
            pool_pre_ping=True,
            connect_args={"options": "-c default_transaction_read_only=on"},
        )
    return _readonly_engine


def get_write_engine() -> Engine:
    """Engine for the Engineer — can write to the dash schema."""
    global _write_engine
    if _write_engine is None:
        _write_engine = create_engine(
            _build_url(),
            pool_size=3,
            max_overflow=2,
            pool_pre_ping=True,
        )
    return _write_engine
