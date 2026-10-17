# Resume checkpoint — 2026-10-18

## Read first

Root `AGENTS.md` → [status](stateful-implementation-status.md) →
[architecture](../02-architecture/ai-architecture.md) → relevant [roadmap](stateful-chat-implementation-plan.md) slice.

## Current code

- Latest slice: catalog V9 adds stable hardware_type; `--seed-prod` runs
  Flyway + production taxonomy UPSERT and exits. Infra deploy/BE release run seed.
  AI consumes snapshot hardwareType directly; no category UUID env required.
  Custom spec/option mapping optional; blank env uses defaults. Verified886 core,
  6 affected PostgreSQL integration, Java150/infra25, packaged CLI twice against
  isolated schema. Published to main: AI `5a84584`, backend `68884c5` (AI submodule
  updated), infra `000edc7`. One-time push authorization consumed; release branch
  untouched, Actions/server rollout unverified. Publish new BE/AI images first.
- Previous slice: FULL_SETUP accessories in V2, bounded equal-soft utility,
  explicit owner memory in PostgreSQL. Migration0006 applied locally. AI published
  through `aac8286` in three focused commits; backend submodule not repinned.
  Policies/contracts: [requirements](requirements.md), [memory](context-management.md#account-memory).
  Exact verification in [status](stateful-implementation-status.md); do not infer live
  model/catalog quality or frontend memory UI from fixture-backed tests.
- Previous delivery: Qwen/Qwen3-8B SFT/QLoRA end-to-end code, not a GPU job.
  [Runbook](training.md) owns commands; [plan](training-plan.md) owns phase gates.
  Done: typed data/review gates, native export, shared Qwen input projection and
  completion mask, baseline/adapter capture, QLoRA trainer/artifact hashes, paired
  comparison, serving launcher and opt-in Qwen Provider. No new agent runtime.
  Native ReAct/structured adapters reuse Qwen HTTP client; auxiliary untrained heads
  use base weights. Normal CI/server image do not install training/vLLM packages.
  Verified869 core, Ruff/mypy196/lock; fixture trainer/native HTTP/report round-trips,
  serving dry-run and DRAFT rejection. Source/API tests are not GPU/model proof.
  All51 pilot labels stay DRAFT. Next: review dataset, native tokenizer/CUDA/vLLM
  smoke, actual baseline/train and semantic/conversation evaluation (ISSUE-138).
  AI code published as264097f on origin/main, seven focused commits. Docs accompany
  the delivery. No weights download or active env/provider change. Backend submodule
  was not repinned. One-time commit/push authorization is consumed by this delivery.
- Owner reported pushing the previous research/observability delivery. Do not
  reuse that permission for the training work.

- Local research registry11: shared legacy presets/policy, publisher→Steam
  requirements, official-only research_driver; gaming/productivity sources separate.
  Never download installers. Cloudflare reader work stays deferred (ISSUE-135).
  Gates:817 core/102 PostgreSQL, Ruff/mypy181/lock. Live scope probes correct but
  Steam/Adobe/MSI reads failed; no live-provider/factuality claim. See [web research](web-research.md).
- AI observability: run UUID.hex = stable persisted/public trace_id; managed execution,
  graph/model/tool/web/finalize steps emit correlated duration/outcome logs/spans.
  Local backend LGTM is running at http://localhost:3300/d/pcshop-ai; real store
  lookup verified20 logs/10 spans with fixture graph. Local ignored AI env configured;
  restart an existing AI process to load it. [Guide](observability.md).
- Earlier commits authorized2026-10-16: AI research `872f841`, tracing `2d6d72f`;
  backend `7b5747d` provisions Grafana and pins AI `2d6d72f`. Docs updated with this
  delivery; research/tracing code is included in published AI264097f.
- Code baseline: AI `e3e1bd2`, including parser `8f9fb89`, is published.
  README commit `d1cbb9b` changes no runtime code; backend `c8ffb30` pins it.
- Server/frontend use V2 only; no enable/version flags or stateless chat routes.
  Missing DB/JWKS/model credentials fails startup. Category data is read lazily
  from catalog snapshots and is not a startup prerequisite.
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
Richer accessory policy/attributes and source expansion; hard-death recovery/migration/internal replay.
Keep phase/issue statuses from the tracker; no whole-plan100% or production claim.
SSE reconnect and another agent/DSL framework are not implicit next work.

## Working agreement

The user authorized commit/push for this setup/preferences/memory delivery only.
Do not reuse this authority for subsequent work; inspect Git status/log before continuing.
Root AGENTS/tracker are outside Git. Inspect every repository's status before editing.
No credentials in docs/logs; do not overwrite ignored `.env` or reset DB volumes.
