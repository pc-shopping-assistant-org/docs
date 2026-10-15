# Resume checkpoint — 2026-10-15

## Read first

Root `AGENTS.md` → [status](stateful-implementation-status.md) →
[architecture](../02-architecture/ai-architecture.md) → relevant [roadmap](stateful-chat-implementation-plan.md) slice.

## Current code

- Code baseline: AI `e3e1bd2`, including parser `8f9fb89`, is published.
  README commit `d1cbb9b` changes no runtime code; backend `c8ffb30` pins it.
- Server/frontend use V2 only; no enable/version flags or stateless chat routes.
  Missing DB/JWKS/model/mapping fails startup, not a fallback execution.
- Core audit is complete within its selected scope. Current counts and exact proof
  boundaries are in status; do not copy old totals from the historical journal.
- Shared versioned DTOs/DDL and historical fixture graphs remain. Do not rename them
  as if changing a Python suffix migrated stored state.
- One conversation/thread, exact accepted head, managed stop ACK, native lineage and
  CAS still govern publication. SSE observes events; disconnect does not cancel.
- Hardware catalog loads only for canonical resolution or compile-ready builds.
  Numerical facts are server-rendered; prose and test fixtures do not prove live quality.

## Deferred, not blockers to the closed core

Live login/catalog/model smoke; FE list/history/reload; delete/retention90/7-day jobs;
FULL_SETUP/soft scoring and source expansion; hard-death recovery/migration/internal replay.
Keep phase/issue statuses from the tracker; no whole-plan100% or production claim.
SSE reconnect and another agent/DSL framework are not implicit next work.

## Working agreement

The user authorized this documentation push after the code delivery. Do not reuse
that one-time permission for subsequent work; inspect Git status/log before continuing.
Root AGENTS/tracker are outside Git. Inspect every repository's status before editing.
No credentials in docs/logs; do not overwrite ignored `.env` or reset DB volumes.
