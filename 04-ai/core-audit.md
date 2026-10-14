# Stateful AI — core audit

Status: **COMPLETED — P6-01 core architecture**, 2026-10-13. Scope: plan §3.6,
selected V2/stop-ACK/two-attempt policy. Feature backlog remains unfinished;
this is not whole-project or production completion.

| Required gate | Current evidence | Audit state |
| --- | --- | --- |
| Owner-scoped submit/poll/history + envelope | Stateful API/auth tests; PostgreSQL lifecycle fixture | Verified with fixture identity/model; live identity integration separate |
| Idempotency, one active run, stop/drain/CAS | Coordinator, lifecycle and managed publication PostgreSQL tests | Verified selected executor-ACK policy; no heartbeat takeover |
| Exact accepted head vs orphan, native resume | Accepted-head/reopen, version policy and native resume tests | Verified selected pinned stack |
| Root recovery | Actual application concurrent initialize, native-commit/app-rollback retry + debug-latest, native-only legacy rejection; corrupt/ambiguous root unit cases | Verified selected synchronous/internal-retry policy. Automatic scheduling/asynchronous create and legacy migration remain deferred |
| Durable external attempt budget | Call-attempt PostgreSQL + provider/lifecycle tests | Verified reservations/retry limits; no hard monetary cap claim |
| Requirements + immutable consent | Resolver/merge/proposal tests; confirmation → explicit edit unit and managed PostgreSQL fresh/recovery gates | Verified ordered replay and CAS: accepted H0 stays unchanged while working H1/H2 differ; missing edit receipt rejects; final run increments conversation revision once. Fixture extraction, not semantic accuracy proof |
| Read → merge → fresh grounded result | ISSUE-112 RED→GREEN; managed fresh/recovery gates with real optimizer | Verified: canonical old ledger retained, current-context evidence publishes; stale reference rejects |
| Cancel after multiple edits | Managed PostgreSQL confirmation/edit gate pauses after both merges, then drains/cancels executor | Verified: accepted pending snapshot/head/revision preserved, no second assistant result, active slot cleared only after stop ACK |
| Publication race after multiple edits | Fixture competing revision committed after native validation, before locked finalize | Verified PUBLICATION_CONFLICT: no assistant result/head overwrite; competing revision preserved and slot stays busy when ACK persistence fails. Injected own-row conflict, not cross-service writer proof |
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

Final root gate: [managed V2 regression](../../ai-service/integration_tests/test_failed_first_turn_postgres.py)
proves tool commit → terminal first-run failure → persisted stop ACK/release → saver
close/reopen → second run from accepted root. Newer failed checkpoint is ignored;
R2 publishes once, without orphan evidence. Selected version policy rejects legacy
bases after PostgreSQL reopen; migration/heartbeat takeover remain unsupported.

At core closure: 721 core / 94 PostgreSQL tests; Ruff/mypy168, offline lock/diff pass.
At that gate DB was `0003_initial_root`; current migrations/evidence are in status.
All listed selected-policy gates
are verified; feature/live/operational expansions above remain open under their own
criteria, not silently marked complete.
