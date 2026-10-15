# Implementation status

Updated: **2026-10-15**. Current delivery evidence, not an architecture tutorial.
Start at [AI documentation](README.md).

## Delivered

Server and frontend use **Stateful ReAct V2 only**. No runtime enable/version flags,
guided/V1 native adapter selection or old `/chat` / `/chat/stream` routes.
Startup requires PostgreSQL, JWKS, catalog mapping and an OpenAI/Gemini provider/key.
Settings construction and OpenAPI inspection are offline; they do not prove readiness.

Managed graph, typed tools, canonical requirements/compiler/verifier, deterministic
optimizer, accepted-head publication, bounded dialogue and basic SSE are implemented.
The [selected core milestone](core-audit.md) is complete, not full-project or
production completion. Shared versioned DTOs/DDL and historical graph/storage
fixtures remain; the server does not select them as legacy execution modes.

## Published code

| Repository | Commit | Delivery |
| --- | --- | --- |
| AI service | `8f9fb89` | Curated GPU dimensions: explicit model-column binding, source locators and conflict handling |
| AI service | `e3e1bd2` | V2-only startup/API/runtime; includes earlier catalog-admission and capability-port fixes |
| Backend | `43cd3e7` | Pins AI `e3e1bd2`; Compose supplies DB/JWKS/claims/provider/mapping |
| AI documentation | `d1cbb9b` | README describes the V2-only setup; code baseline remains `e3e1bd2` |
| Backend documentation | `c8ffb30` | Updated integration README; gitlink advances to published AI `d1cbb9b` |

Parser/native attachment changes from the previous local worktree are included.
No AI/backend source or README changes remain uncommitted; the manual is delivered
from the separate docs repository. Documentation-only pins do not change runtime behavior.
Workspace-root `USECASE_IMPLEMENTATION.md` is outside a Git repository and stays local.

## Verified code gates

Recorded on the published code on 2026-10-15:

| Scope | Result |
| --- | --- |
| AI core | **753 passed** |
| Native PostgreSQL | **102 passed** |
| Ruff / mypy | Pass; 176 source files checked by mypy |
| Offline lock / wheel / sdist | Pass |
| Backend Compose config | Pass; no container startup claimed |

These use real optimizer/application logic and native SQL/checkpoints, with external
model/auth/catalog fixtures. No live identity/catalog/model journey was run.
Retired V1 mode parameter cases and migrated protocol/lifecycle tests explain the
count change; historical totals are not current completion percentages.

From `ai-service/`:

```bash
uv run --no-sync pytest -q --tb=short
uv run --no-sync pytest -q integration_tests --tb=short
uv run --no-sync ruff check src tests integration_tests migrations
uv run --no-sync mypy src
uv lock --check --offline
uv build --offline
```

Prior FE gate:135 tests/typecheck/lint/OpenAPI and Webpack build66 pages; browser used
mocked API. Prior backend gate:148 catalog/common-lib tests with a local JDK override.
Neither was rerun for this documentation refresh; ISSUE-122/124 remain open.
Historical slice evidence: [journal](stateful-implementation-history.md).

## Documentation verification

2026-10-15:34 manual/reference/README pages checked;199 local links/anchors,
3 JSON blocks and16 shell blocks pass. Eight documented operations and three
concrete request examples match current OpenAPI/Pydantic; legacy chat routes and
V1 request schema are absent. No lifespan/network/DB execution or runtime-suite rerun.

## Remaining delivery

| Phase | Status | Deferred work |
| --- | --- | --- |
| P0–P1 | COMPLETED | Contract/pure-state baseline |
| P2 | IN PROGRESS | Live identity, automatic/asynchronous initialization, legacy migration |
| P3 | IN PROGRESS | Live model/catalog and semantic quality; FULL_SETUP/soft scoring, older-build selectors, more sources |
| P4 | IN PROGRESS | Hard process-death authority, expanded retry/version migration |
| P5 | IN PROGRESS | FE list/history/reload; conversation delete and retention jobs |
| P6 | IN PROGRESS | P6-01 core audit complete; internal replay/full-feature audit deferred |

Implementation order and acceptance: [roadmap](stateful-chat-implementation-plan.md).
Retention90/7-day policy is specified, not an enabled job. Replay remains an internal-only
design, not a delivered replay runner. No automatic SSE reconnect/token streaming added.
