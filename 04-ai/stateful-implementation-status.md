# Implementation status

Updated: **2026-10-17**. Current delivery evidence, not an architecture tutorial.
Start at [AI documentation](README.md).

## Delivered

Server and frontend use **Stateful ReAct V2 only**. No runtime enable/version flags,
guided/V1 native adapter selection or old `/chat` / `/chat/stream` routes.
Startup requires PostgreSQL, JWKS, catalog mapping and an OpenAI/Gemini provider/key
or an explicitly configured self-hosted Qwen endpoint.
Settings construction and OpenAPI inspection are offline; they do not prove readiness.

Managed graph, typed tools, canonical requirements/compiler/verifier, deterministic
optimizer, accepted-head publication, bounded dialogue and basic SSE are implemented.
The [selected core milestone](core-audit.md) is complete, not full-project or
production completion. Shared versioned DTOs/DDL and historical graph/storage
fixtures remain; the server does not select them as legacy execution modes.

## Published code

### Qwen training workflow — code published, execution gates open

AI service `264097f` published to origin/main on2026-10-17 in seven focused commits.
This documentation accompanies that delivery; backend submodule pin was not changed.

Reader-first [training plan](training-plan.md), [evaluation rubric](../06-evaluation/evaluation-plan.md)
and an offline pilot:51 samples/50 scenario,10 task extraction/16 requirement
extraction/25 ReAct decisions,39 train/6 validation/6 test samples. Eight frozen
typed snapshots include synthetic catalog/web outcomes and a real optimizer receipt
on synthetic parts. Grouped splits, hashes, runtime schemas/policy, source spans/
quantities/current IDs and final grounding/completion are checked offline.

Approved-only canonical exporter and captured-response evaluator are implemented.
Prompt builders/native response admission are shared with runtime; input has no
gold labels/review metadata, tool history keeps matched pairs, test targets never
become SFT output. Evaluator keeps failures/missing cases and separates schema
from source/policy/grounding checks; semantic review remains REQUIRED.
[Commands and artifact format](../../ai-service/training/README.md).

Owner selected Qwen/Qwen3-8B + SFT/QLoRA. Implementation now includes pinned model/
tokenizer config, shared train/serve schema projection, final-completion loss mask,
vLLM baseline/adapter capture, NF4/all-linear QLoRA recipe, adapter file provenance,
paired comparison and explicit serving commands. Optional Qwen provider reuses native
ReAct/structured contracts and recovery policy; untrained auxiliary heads use base
weights. Training and serving dependencies are isolated. [A→Z runbook](training.md).

All51 labels remain DRAFT. Native tokenizer, real GPU train/inference/vLLM and
conversation quality remain verification gates (ISSUE-138). No weights download,
active-provider change or automatic approval/promotion. Commit/push was separately
authorized for this delivery only; no continuing publication authority.

Verified2026-10-17:869 core tests, including52 training/provider/recovery regressions
added since the817-core baseline; Ruff/mypy196/lock pass. Mock HTTP native ReAct,
capture/report comparison, fixture trainer/artifact round-trip and CLI review-gate/
serving dry-run pass. No real GPU/tokenizer/LLM, SQL or PostgreSQL rerun claimed.

### Local extensions — research and observability

Five research tools bring the registry to11: hardware, compatibility, workload,
canonical PC build and official-only driver/BIOS/chipset/RGB. Each searches/reads bounded sources; build research binds the
current verified result or accepted snapshot. Source coverage and exact excerpts
support a review; enums own source status/focus/mode. Manufacturer-first registry,
topic-specific independent sources and result/final-domain filtering replace global
top-N selection (ISSUE-134). Policy version/hash and per-tier queries/status persist.
Unknown brands/publishers stay explicit; all-web fallback is disabled by default.
Web attempts reserve per request;
new runs default to48 TOOL_IO, existing persisted budgets stay unchanged.

Requirements route publisher→Steam, not review sites; gaming/productivity sources
are distinct. Legacy helpers reuse presets/policy instead of adding duplicate tools.
Binary response bodies are not consumed. Live Wukong/Adobe/MSI discovery uses the
correct domain scopes; Steam connection failed, Adobe/MSI403 prevented page evidence.
Benchmark reader probes read8/10 samples; TechSpot/Phoronix Cloudflare403 remains
ISSUE-135, deferred by owner. No browser/fetch bypass or structured FPS parser.

Run observability adds stable public/persisted trace_id, timed graph/model/tool/web
steps and stop/finalize spans. Managed retries share a trace, concurrent runs isolate
context. JSON console + batched OTLP logs/traces reuse persistent backend LGTM.
Grafana dashboard **PC Shopping - AI Runs** is provisioned and accessible locally.
Real LGTM ingestion/lookup passed:20 logs/10 spans from a fixture-model managed graph;
not a live provider/auth/catalog conversation. See [Observability](observability.md).

Verified2026-10-16: **817 core +102 PostgreSQL** tests; Ruff/mypy181/lock/diff pass.
Native protocol fixtures cover OpenAI/Gemini and committed-tool resume. Live probes
read RM850x on Corsair first, then Hardware Busters; prior DeepCool AK620 probe read
TechPowerUp. These verify
search/read access, not live LLM/catalog/auth, relevance or structured FPS extraction.
Earlier commits authorized2026-10-16: AI research `872f841`, tracing `2d6d72f`;
backend `7b5747d` provisions the dashboard and pins AI `2d6d72f`. Documentation is
updated in this delivery. Research/tracing commits are ancestors of published AI
`264097f`; backend was not repinned for the training work.

### Published baseline

| Repository | Commit | Delivery |
| --- | --- | --- |
| AI service | `8f9fb89` | Curated GPU dimensions: explicit model-column binding, source locators and conflict handling |
| AI service | `e3e1bd2` | V2-only startup/API/runtime; includes earlier catalog-admission and capability-port fixes |
| Backend | `43cd3e7` | Pins AI `e3e1bd2`; Compose supplies DB/JWKS/claims/provider/mapping |
| AI documentation | `d1cbb9b` | README describes the V2-only setup; code baseline remains `e3e1bd2` |
| Backend documentation | `c8ffb30` | Updated integration README; gitlink advances to published AI `d1cbb9b` |

Parser/native attachment changes from the previous local worktree are included.
The manual is delivered from the separate docs repository. The Qwen code delivery
above supersedes the older baseline; documentation-only pins do not change runtime behavior.
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
