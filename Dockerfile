FROM python:3.11.9-bullseye

ENV POETRY_VERSION=1.8.2 \
    POETRY_HOME=/usr/local \
    POETRY_VIRTUALENVS_CREATE=false \
    DBT_PROFILES_DIR=. \
    PROJECT_DIR=/workspaces/dbt-activity-schema/

# Add BUILDARCH from Global Docker Build Args
ARG BUILDARCH
ARG DUCKDB_VERSION="v0.10.1"

# Install DuckDB from Binary
RUN export ARCH=$( \
    if [ "$BUILDARCH" = "amd64" ]; then \
        echo "amd64"; \
    elif [ "$BUILDARCH" = "arm64" ]; then \
        echo "aarch64"; \
    else \
        echo "Got BUILDARCH=${BUILDARCH}. Must be one of amd64, arm64" && exit 1; \
    fi \
    ) &&  wget "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-${ARCH}.zip" && \
    unzip duckdb_cli-linux-${ARCH}.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm duckdb_cli-linux-${ARCH}.zip

RUN apt-get update \
    && apt-get install -y vim nano \
    && curl -sSL https://install.python-poetry.org | python - \
    && apt-get clean

WORKDIR $PROJECT_DIR

COPY ["*poetry.lock", "pyproject.toml", "$PROJECT_DIR"]
RUN poetry install --no-interaction

ENTRYPOINT ["./scripts/ci.sh"]
