# Implementation status

Updated2026-10-14. This is delivery evidence, not an architecture tutorial.
Start at [AI documentation](README.md).

## Current capability

Frontend chat/attachments/immutable confirmation uses Stateful ReAct V2.
Managed graph, typed tools, canonical requirements/compiler/verifier, optimizer,
accepted-head publication, bounded dialogue and basic SSE are implemented.

Core-code milestone is **COMPLETED** within [core audit](core-audit.md) scope.
This is not full-project, live-integration or production completion.
Server Settings remain stateful-off/V1 unless explicitly configured for V2.

## Phases

| Phase | Status | Remaining |
| --- | --- | --- |
| P0 | COMPLETED | Contract baseline |
| P1 | COMPLETED | Pure merge/marker baseline |
| P2 | IN PROGRESS | Live identity, automatic/asynchronous initialization, legacy migration |
| P3 | IN PROGRESS | Live model/catalog/semantic quality; soft/FULL_SETUP, older selectors/source expansion |
| P4 | IN PROGRESS | Hard process-death authority, expanded retry/version migration |
| P5 | IN PROGRESS | FE history/reload, delete/retention; basic APIs/SSE already delivered |
| P6 | IN PROGRESS | P6-01 core audit complete; internal replay/full-feature audit deferred |

## Latest code verification

Verified2026-10-15 on clean AI commit `33bca30`: **747 core +106 native PostgreSQL pass**;
Ruff, mypy176 files, offline lock, wheel/sdist build and diff checks pass.
Current workspace:756 core, including nine pre-existing uncommitted parser tests.
Model/auth/catalog are fixtures.

```bash
uv run --no-sync pytest -q --tb=short
uv run --no-sync pytest -q integration_tests --tb=short
uv run --no-sync ruff check src tests integration_tests migrations
uv run --no-sync mypy src
uv lock --check --offline
git diff --check
```

ISSUE-127 resolved: requirement-owned catalog policy separates user clarification
and scalar/unit admission from optimizer candidate acquisition. Eight graph tests
cover first-turn missing goals, merge-before-fetch recovery, canonical references
and waiting revalidation. A three-turn managed V2/API/SQL/saver test publishes
clarification → unit question → confirmation with an unavailable hardware backend
and zero hardware requests. Accepted state/consent/stop/lineage/CAS remain guarded.

ISSUE-128 resolved: web/commerce/build helpers require injected ports. An AST gate
first reproduced all three infrastructure imports, then passed after caller migration.
69 focused architecture/helper tests preserve existing outcomes; V2 wiring unchanged.

ISSUE-129 resolved: alternatives use explicitly supplied canonical components with
IDs; strict price/category/socket/RAM filters replace embedded names/prices. No match
returns empty; absent catalog fails closed. Output retains source values and stable
price/ID limit; stock is unknown. Eight new regression cases pass. This helper is
not exposed in V2 and does not certify full-build compatibility.

Tom’s parser RED6 failures/2 pass → focused9 pass; curated slice35/native runtime5.
Native attachment→ordinary follow-up retains one conversation and prior published context.
ISSUE-074/096/097/121 resolved. No live provider key/catalog used.

Frontend committed post-merge gate:135 tests/typecheck/lint/OpenAPI pass; Webpack build66
pages. Earlier browser mocked API:two turns/confirmation, no page error; not live model.
Default Turbopack worker-port gate remains ISSUE-122.

Backend recorded148 catalog/common-lib tests +Compose config pass using CLI
release unset/source25/target25; full/default reactor not verified, ISSUE-124.
These FE/backend gates were not rerun for documentation edits.

## Documentation verification

ISSUE-125 resolved by the manual rewrite; runtime/config/credentials are unchanged.
Read-only Node checks pass:149 Markdown pages/374 local links+anchors; all28 AI
pages reachable from the index;35 selected pages have valid fences/nonempty content,
3 JSON blocks parse and11 Bash blocks pass bash-n. Docs/AI diff checks pass.

Offline `uv run --no-sync python` validated the first-step create/turn examples with
actual Pydantic contracts and all8 documented HTTP operations against selected V2
OpenAPI. No lifespan/provider/HTTP/DB connections opened; no full runtime suite rerun.
Historical slice evidence is preserved in [journal](stateful-implementation-history.md).
ISSUE-126 resolved: scoring documentation follows the current optimizer as the
approved baseline; no optimizer behavior changed.

## Remaining work

Approved backlog/gates: [roadmap](stateful-chat-implementation-plan.md).
Live identity/catalog/model smoke is separate from native fixture proofs.
Delete/retention90/7-day policy exists but jobs are not enabled; replay internal-only.
No SSE reconnect/token streaming requirement added.
No additional tool was exposed for ISSUE-129. Legacy heuristic helpers remain separate
from the selected V2 dispatcher; their wider functionality is not a live integration claim.

## Delivery state

Historical published baseline: AI6a16569; backend e7ae822 pins that AI commit; FE45068a8.
Current delivery: `3e64c67` catalog admission; `33bca30` capability ports/canonical
alternatives. User authorized this push only. Existing Tom's parser/tests and native
attachment-fixture edits remain local; backend submodule is unchanged at `6a16569`.
Docs are in a separate repository. Workspace-root USECASE_IMPLEMENTATION.md is not
inside a Git repository; its updated tracker remains local.
