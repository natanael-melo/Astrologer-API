# Astrologer API — serviço interno (só o backend dos mapas astrais fala com
# ela, pela rede do Swarm; não é exposta ao público).
#
# O pacote se chama "app" (ver pyproject.toml: package-dir = {app = "."}) — o
# código só importa certo se a pasta do repo se chamar literalmente "app" e a
# gente rodar um nível acima dela. Por isso o COPY vai pra /srv/app, não /app.

FROM python:3.13-slim AS deps
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
WORKDIR /build
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

FROM python:3.13-slim AS runtime
COPY --from=deps /build/.venv /srv/.venv
ENV PATH="/srv/.venv/bin:$PATH" ASTROLOGER_ALLOW_NO_AUTH=true
WORKDIR /srv
COPY . /srv/app
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
