FROM python:3.10-bullseye AS base

ENV POETRY_VERSION=1.3.2 \
    POETRY_HOME=/usr/local \
    POETRY_VIRTUALENVS_CREATE=false \
    DBT_PROFILES_DIR=. \
    PROJECT_DIR=/workspaces/dbt-activity-schema/

RUN apt-get update \
    && apt-get install -y vim nano \
    && curl -sSL https://install.python-poetry.org | python - \
    && apt-get clean

WORKDIR $PROJECT_DIR

COPY ["*poetry.lock", "pyproject.toml", "$PROJECT_DIR"]
RUN poetry install --no-interaction

ENTRYPOINT ["./scripts/ci.sh"]
