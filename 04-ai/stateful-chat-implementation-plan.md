# Stateful AI roadmap

Revision36 · 2026-10-17. V2-only server plus local setup/preferences/memory extension.
Broader phase/live gates remain open. [Architecture](../02-architecture/ai-architecture.md)
explains runtime; [status](stateful-implementation-status.md) records evidence.

## Goal

Multi-turn catalog-grounded chat and PC consultation with durable execution.
Agent explores/asks/proposes; application controls state/completion/publication;
deterministic optimizer/verifier computes builds.

Login-only, conversation-local history plus explicit owner-managed account memory. BUILD_PC defaults to core; FULL_SETUP adds
one monitor/mouse/keyboard/headset. Owned spending0, pinned paid; no implicit80/20.
Retention policy90 days, unprotected orphan/debug7 days. Internal replay cannot publish.

## Phases

| Phase | Deliverable | Current state |
| --- | --- | --- |
| P0 | Frozen contracts/policies | Completed baseline |
| P1 | Pure multi-turn merge and completion markers | Completed baseline |
| P2 | DB/auth/native saver/root and owner reads | Core implemented; live/migration expansions open |
| P3 | Requirements, bounded ReAct, tools, verified answer/build | Core implemented; semantic/domain/source expansion open |
| P4 | Durable admission/executor/attempts/recovery/publication | Selected policy verified; advanced recovery open |
| P5 | API/events/SSE/frontend and data lifecycle | Basic API/SSE/V2 caller implemented; UX/retention open |
| P6 | Cross-phase audit and internal replay | P6-01 completed; P6-02 backlog |

P2–P6 overall remain IN PROGRESS. Core completion is not a percentage of full feature delivery.

## Delivered core

Server/frontend use V2 only. No runtime enable/version flags, V1/guided selection
or stateless chat endpoints. Startup requires DB/JWKS/model/catalog configuration.
Published AI `e3e1bd2` includes parser `8f9fb89`; backend `43cd3e7` pins that AI.
Historical DTOs/DDL/fixture graphs remain versioned, not a supported V1 server mode.

These IDs retain traceability to the original implementation plan:

| IDs | Capability |
| --- | --- |
| P2-01/02/03 | Exact initial root/readiness, exclusive synchronous initialization, owner reads |
| P4-A01/02/03 | Durable submit/idempotency, managed lifecycle/stop ACK, external attempt reservations |
| P3-A01/02/03 | Source-bound drafts, canonical reference/unit resolution, atomic merge/continuation |
| P3-F01/F02/F03/F04 | V2 actions/hash/immutable confirmation, flexible loop, outcomes and publication |
| P3-B01/B02/B03/B04 | Native adapters, tool loop, scoped optimizer report, provenance/context/reuse |
| P3-W01 | Search/discovery and page-read/excerpt evidence |
| P3-W03 (local) | Hardware/compatibility/workload/build research: manufacturer-first source policy, bounded read, provenance, canonical build binding, grounded review |
| P3-W04/05 (local) | Topic-specific benchmark source expansion, shared helper presets, publisher/Steam requirements and official-only driver tool; Cloudflare transport deferred |
| P4-O01 (local) | Stable run trace, timed structured steps and shared Grafana LGTM log/trace store |
| P4-B01/B02/B03 | Selected stopped recovery, native lineage and fenced CAS |
| P5-01/02/03 | Create/list/get/history/submit/poll/cancel, basic journal/SSE and FE V2 caller |
| P6-01 | Selected code-core acceptance audit |
| P3-A04 (local extension) | FULL_SETUP canonical accessories/history, bounded soft utility; explicit account memory API/context |

“Delivered core” does not close broader live/feature gates under these IDs.
Local extensions pass817 core/102 PostgreSQL gates, Ruff/mypy181/lock.
Source strategy and acceptance are in
[web research](web-research.md#research-strategy--manufacturer-first): configurable
manufacturer-first, topic-specific reviews, domain filtering, typed provenance and
explicit gaps. Live RM850x reads Corsair then Hardware Busters. Code is local,
committed locally, not pushed. P3-W02 structured benchmarks, exact revision relevance and live
LLM quality remain open; source policy does not certify factual correctness or FPS.
P4-O01 includes fixture-managed graph→OTLP→Loki/Tempo lookup and Grafana dashboard,
not distributed backend tracing, durable audit delivery or production retention.
See [Observability](observability.md).

## Remaining delivery

Explicitly deferred after the 2026-10-15 core delivery. Prioritize a live smoke
when real dependencies are ready, then user-facing history/reload. Do not reopen
the selected core milestone merely to add these features.

| ID / priority | Work | Acceptance |
| --- | --- | --- |
| P5-03 / next UX | FE conversation list/history/reload | Same owned conversation/accepted result after reload; no duplicate admission or legacy fallback |
| P5-04 / data lifecycle | Conversation delete and retention jobs | Stop/drain first; purge app/native/events/snapshots; preserve protected ancestry;90/7-day policy |
| ISSUE-085/099 / domain extension | Rich accessory policy/requirements | Basic explicit-cap selection and soft utility are implemented; owner review/quality attributes, unsupported predicates and legacy migration remain open |
| P3-W02 | More curated sources/benchmark evidence | Typed model/value/unit/conditions/source; content fallback does not fabricate facts |
| P3 completion extensions | Arbitrary older-build selector | Exact authorized historical snapshot, no current accessory/price reconstruction |
| P2 / ISSUE-092 | Automatic/asynchronous root reconcile and legacy migration | Exclusive proof-bound initialize/migrate; no latest-head adoption/copy-values recovery |
| P4-B01 / ISSUE-094/095 | Hard-death authority and broader retries | Trusted process-stop proof, bounded attempts, native cursor/lineage; heartbeat never takeover proof |
| P6-02 | Internal deterministic replay | Snapshot/artifacts only, no live fallback, no customer publish |
| P2/P3 live / ISSUE-093/100 | Identity/catalog/model smoke and semantic quality | Real login→read→build→follow-up; fixture proof not counted as live |

Default FE/JDK build environment gates ISSUE-122/124 are recorded separately.
Cart/order/export mutation is another approved feature scope, not implicit permission.

## Dependencies

```text
Persistence/root → admission/executor/attempts
                 → requirements/adapters → ReAct/optimizer/verifier
                 → recovery/publication → minimum API/caller → core audit

Core closed → approved UX/data/domain expansions → replay/full-feature audit
```

Reuse existing services/ports/optimizer. Do not add another agent runtime, DSL or
framework just to finish backlog. SSE reconnect/token streaming stays outside selected scope.

## Migration gates

Schema/version change must migrate or reject incompatible saved state explicitly.
Keep exact accepted head, original pending task/source, immutable proposal binding,
private receipt replay, scoped proof and stop/lineage/CAS across every extension.
Old INFEASIBLE without proof is not silently upgraded.

FULL_SETUP changes require complete historical accessory snapshots.
Limits/context changes require durable budget/config snapshots and bounded-state gates.
Pinned artifacts are part of replay; matching hashes alone do not recreate missing code/data.

## Definition of done

Selected core requires managed stable-thread execution, owner-scoped admission/reads,
durable attempts, source/consent-bound merge, verified outcomes, native resume and CAS
publication. These selected gates passed; see [core audit](core-audit.md).

Full plan completion additionally needs each approved feature gate, review of open
correctness issues and final use-case audit. Blocked/deferred required functionality
cannot be counted as100%. Live smoke has separate evidence.

Each slice: tracker IN PROGRESS → implement/test focused core → relevant full/static/native
gates → docs/status update. Do not claim runtime proof from source-only changes.

**Next:** [Current status](stateful-implementation-status.md) · [Testing](testing.md).
