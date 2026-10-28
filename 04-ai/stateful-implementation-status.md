# Implementation status

Updated: **2026-10-28**. Current delivery evidence, not an architecture tutorial.
Start at [AI documentation](README.md).

## Agent task admission — ISSUE-159

Implemented locally: new turns reach ReAct directly. Native `register_tasks`
shares the first business action response; application retains source/identity
validation and completion authority. Greetings use one call, catalog lookup plus
answer uses two instead of three. Pending task bindings remain intact.
Verified: **917 unit + 96 PostgreSQL integration tests**; native HTTP tests cover
actual model-dispatch counts, retry, publication and multi-turn history using
scripted providers. AI `4683417` published to main and release/v1.0.4 on owner
request; image build/deployment are in progress. No live model quality/latency claim.
Serving/training protocol: `agent-task-admission-v3`; old artifacts need regeneration
and relevant labels reviewed. Pending interpreter redesign remains ISSUE-150.

Provider follow-up (ISSUE-160): AI `cedb944` adds typed LangChain Gemini wrapper
classification; infra forwards the global request timeout. **922 unit + 96
PostgreSQL tests** and **39 infra tests** pass. Production 1.0.3 logged a 400
GoogleInvalidRequestError; replay of its saved request returned 503 high demand.
The original 400 detail is unavailable, so that cause is not claimed resolved.
AI 1.0.5 rollout is in progress; no provider/model change has been made.

## Current refactor — ISSUE-149

[Conversational agent plan](conversational-agent-refactor-plan.md): P0–P3 implemented;
P3 code/parity/docs verified at **897 unit + 96 PostgreSQL integration tests**;
Ruff/mypy206/lock167 pass. Optional-task dialogue and side responses preserve
accepted requirements/build/pending; original confirmation survives a later revision
and native saver reopen. Requirements-only admission needs no fabricated BUILD.
Native text/control protocol replaces full decision JSON; application derives outcomes.
Training uses the same serving projection/parser; export rejects three old DRAFT
clarification labels pending review (ISSUE-138). No pilot labels/approval changed.
Live paired model-quality gate is **UNVERIFIED, DEFERRED BY OWNER** (“hoãn live eval,
push”): local provider=fallback, no keys or Qwen endpoint. AI `781d2d2` published to
`origin/release/v1.0.0`; docs use `main`. This delivers code, not empirical model
quality. CI/image publication does not deploy the server; no backend repin or rollout.

## Delivered

Server and frontend use **Stateful ReAct V2 only**. No runtime enable/version flags,
guided/V1 native adapter selection or old `/chat` / `/chat/stream` routes.
Startup requires PostgreSQL, JWKS and an OpenAI/Gemini provider/key
or an explicitly configured self-hosted Qwen endpoint.
Settings construction and OpenAPI inspection are offline; they do not prove readiness.

Managed graph, typed tools, canonical requirements/compiler/verifier, deterministic
optimizer, accepted-head publication, bounded dialogue and basic SSE are implemented.
Task registration and requirement extraction use separate `TaskDraftBatch` and
`RequirementDraft` contracts; combined V1 `Draft` is restricted to persisted-data
compatibility reads. T5 focused gate: 75 unit + 48 PostgreSQL tests. Final audit:
867 unit + 93 PostgreSQL integration tests; Ruff, mypy and lock checks pass. No
live provider/GPU run is implied.
The [selected core milestone](core-audit.md) is complete, not full-project or
production completion. Shared versioned DTOs/DDL and historical graph/storage
fixtures remain; the server does not select them as legacy execution modes.

## Catalog taxonomy update — source published

AI reads typed `hardwareType` directly from catalog snapshots, without category
UUID env. Custom field mapping is optional; empty env uses defaults. Catalog owns
the production UPSERT seed and database constraint. Infra setup runs the seed job.
Verified886 core + 6 affected PostgreSQL integration tests, Ruff/mypy203/lock167;
Java150/infra25 and two packaged seed CLI runs on an isolated schema pass.
Published to main: AI `5a84584`, backend `68884c5` (submodule aligned), infra `000edc7`.
Deploy updated catalog before updated AI. No server/image rollout verified.

## Published code

Versioned follow-up: release/vX.Y.Z selects image :X.Y.Z in app and
infra workflows. Registry preflight and post-health local image cleanup added.
Verified33 offline infra tests, 12 app branch/version cases, four actionlint checks
and shellcheck/Bash syntax. Environment release must allow release/* branches.
Published app release/v1.0.0: AI dd62484, frontend 0f71f47, backend 2c29530
(submodule aligned). Actions builds started; image publication not yet verified.
All app changes are also synchronized to main; infra ea5692e published to main
only. Its release branch remains unpushed, so no server deployment triggered.
GHCR tag locking remains ISSUE-143.

CI update published to main: AI baa8e4d, backend d5659ac (submodule aligned),
frontend 5a8deb1 and infra c68d0e6. App release builds images only; infra release
owns SSH deployment, seed and stop-AI/migrate/start ordering. Verified 24 offline
infra tests, four workflow actionlint checks and shellcheck/Bash syntax. No release
branch/image publication or server rollout triggered by this delivery.

### Setup/preferences/memory extension — code published

AI source published to origin/main in three focused commits: `8a9fb01` (optimizer
utility), `93b1240` (FULL_SETUP/compiler/history) and `aac8286` (account memory).
This delivery's one-time publication was explicitly authorized; remote Actions
results have not been observed.

Compiler requirements-v2 wires FULL_SETUP into the existing V2 build tool. Canonical
peripherals stay separate from eight core slots; owned0/pinned paid, explicit accessory
cap for recommendations, no ratio. Public snapshots preserve complete setup spending
and ownership for later explanation. Native managed-run test confirms history retains
the original mouse price after catalog mutation. Monitor quality/resolution attributes
and joint global setup optimization are not claimed.

Bounded equal-preference utility influences optimizer ranking without removing hard
constraints; match-aware pruning, absent preferences, hard pins, score breakdowns and
unmet-preference disclosure are tested. [Exact policy](requirements.md#compiler).

Explicit account memory has owner-scoped GET/PUT/DELETE, PostgreSQL migration0006,
90-day validity and bounded run-context snapshots. No automatic raw-chat capture,
new framework or implicit requirement merge. SQL restart/isolation/expiry/quota and
HTTP/prompt boundaries are tested. [Memory semantics](context-management.md#account-memory).

Local migration0006 was applied to ai_db; no catalog seed, active-provider change,
real LLM or frontend memory UI verification. Verified884 core +104 PostgreSQL tests;
Ruff/mypy203/lock167/diff pass. Migration0006 is local head. Policy review/live
quality remain separate gates; backend submodule was not repinned.

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
| P3 | IN PROGRESS | Live model/catalog and semantic quality; richer accessory requirements/policy, older-build selectors, more sources |
| P4 | IN PROGRESS | Hard process-death authority, expanded retry/version migration |
| P5 | IN PROGRESS | FE list/history/reload; conversation delete and retention jobs |
| P6 | IN PROGRESS | P6-01 core audit complete; internal replay/full-feature audit deferred |

Implementation order and acceptance: [roadmap](stateful-chat-implementation-plan.md).
Retention90/7-day policy is specified, not an enabled job. Replay remains an internal-only
design, not a delivered replay runner. No automatic SSE reconnect/token streaming added.
