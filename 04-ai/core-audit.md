# Stateful AI — core audit

Audit started 2026-10-13. Scope: core architecture from the approved plan; feature
backlog remains unfinished, not silently removed. No production-completion claim.

| Required gate | Current evidence | Audit state |
| --- | --- | --- |
| Owner-scoped submit/poll/history + envelope | Stateful API/auth tests; PostgreSQL lifecycle fixture | Verified with fixture identity/model; live identity integration separate |
| Idempotency, one active run, stop/drain/CAS | Coordinator, lifecycle and managed publication PostgreSQL tests | Verified selected executor-ACK policy; no heartbeat takeover |
| Exact accepted head vs orphan, native resume | Accepted-head/reopen, version policy and native resume tests | Verified selected pinned stack |
| Root recovery | Actual application concurrent initialize, native-commit/app-rollback retry + debug-latest, native-only legacy rejection; corrupt/ambiguous root unit cases | Verified selected synchronous/internal-retry policy. Automatic scheduling/asynchronous create and legacy migration remain deferred |
| Durable external attempt budget | Call-attempt PostgreSQL + provider/lifecycle tests | Verified reservations/retry limits; no hard monetary cap claim |
| Requirements + immutable consent | Resolver/merge/proposal tests; explicit-user managed PostgreSQL | Verified fixture extraction; semantic accuracy remains quality evaluation |
| Read → merge → fresh grounded result | ISSUE-112 RED→GREEN; managed fresh/recovery gates with real optimizer | Verified: canonical old ledger retained, current-context evidence publishes; stale reference rejects |
| Optimizer completion and scoped failure | Real optimizer/search-report tests; managed build/multi-task tests | Verified supplied-candidate scope, not global catalog infeasibility |
| Mixed outcomes and bounded repair | Managed multi-task, missing-fact native and targeted-repair tests | Verified fixture tools/model; no generated benchmark proof |
| 100-turn state/native storage bounds | PostgreSQL 100-turn/6KB-payload regression + reopen; same-run/pending/recovery suite | Verified fixture: state highwater 23159 bytes, native payload 9311305 bytes; ancestors preserved. Retention/GC remains P5 backlog |
| Version compatibility/recovery expansion | Unsupported-base guards and selected two-attempt recovery | Selected policy verified; legacy migration/process-death authority open |

Live provider/catalog/identity smoke is separate from fixture-backed core evidence.
P5 APIs/SSE/frontend/retention/delete, FULL_SETUP/soft scoring, source expansion and
internal replay keep their own acceptance criteria in the feature backlog.

Commands/results live in [implementation status](stateful-implementation-status.md).
This audit stays open until each required gate is verified or an explicit permitted
deferral is recorded; unresolved required gates do not count as completion.
