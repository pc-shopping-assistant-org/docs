# Deployment

## Production baseline

Production Compose is defined at
`infra/compose/prod/compose-file/compose.yaml` and currently runs:

- `ai-service`, the FastAPI/PydanticAI image pulled from GHCR;
- PostgreSQL for ecommerce data and persistent carts/orders;
- Qdrant as the private vector store for retrieval.

PostgreSQL and Qdrant are attached only to the private data network and are
not published to the host. The AI service binds to `127.0.0.1:8000` by
default; a host reverse proxy should terminate TLS and expose the public API.

Create the deployment environment from
`infra/compose/prod/env/prod.env.example`, replace the placeholder password
and external backend API root (`AI_BACKEND_API_URL`), then validate and start
the stack:

```sh
cd infra/compose/prod
cp env/prod.env.example env/prod.env
docker compose --env-file env/prod.env -f compose-file/compose.yaml config
docker compose --env-file env/prod.env -f compose-file/compose.yaml pull ai-service
docker compose --env-file env/prod.env -f compose-file/compose.yaml up -d
```

The backend contains the canonical Flyway baseline at
`backend-api/server/src/main/resources/db/migration/V1__init.sql` plus
incremental migrations such as `V2__add_shipping_method_fee.sql` and
`V3__add_google_subject_to_accounts.sql`. They create the schema and
PostgreSQL constraints represented by `db.dbml`. Run the backend once against a
fresh local database to let Flyway apply all pending migrations before serving
application traffic. Existing development databases created from the old V1
must be recreated because that was a replacement baseline; databases already
on the canonical V2 baseline only need the normal V3 migration.

## Local staging

Local staging is data-only and is defined at
`infra/compose/staging/compose-file/compose.yaml`. It runs PostgreSQL only with
a localhost port binding; frontend and backend processes run locally on the
host and use the values in
`infra/compose/staging/env/staging.env.example`.
