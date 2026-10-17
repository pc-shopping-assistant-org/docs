# Stateful AI — core audit

Status: **COMPLETED — selected core-code milestone**, verified through 2026-10-15.
Scope: [core definition of done](stateful-chat-implementation-plan.md#definition-of-done),
selected V2/stop-ACK/two-attempt policy. Feature backlog remains unfinished;
this is not whole-project or production completion.

| Required gate | Current evidence | Audit state |
| --- | --- | --- |
| V2-only server startup/API | Missing-dependency startup rejection; V2 OpenAPI/owner/envelope tests; actual managed V2 lifecycle | No enable/version flags or guided/V1 native adapter selection; old /chat routes removed. Shared versioned DTO/DDL and historical storage fixtures are not runtime fallbacks |
| Owner-scoped submit/poll/history + envelope | Stateful API/auth tests; PostgreSQL lifecycle fixture | Verified with fixture identity/model; live identity integration separate |
| Idempotency, one active run, stop/drain/CAS | Coordinator, lifecycle and managed publication PostgreSQL tests | Verified selected executor-ACK policy; no heartbeat takeover |
| Exact accepted head vs orphan, native resume | Accepted-head/reopen, version policy and native resume tests | Verified selected pinned stack |
| Root recovery | Actual application concurrent initialize, native-commit/app-rollback retry + debug-latest, native-only legacy rejection; corrupt/ambiguous root unit cases | Verified selected synchronous/internal-retry policy. Automatic scheduling/asynchronous create and legacy migration remain deferred |
| Durable external attempt budget | Call-attempt PostgreSQL + provider/lifecycle tests | Verified reservations/retry limits; no hard monetary cap claim |
| Requirements + immutable consent | Resolver/merge/proposal tests; confirmation → explicit edit unit and managed PostgreSQL fresh/recovery gates | Verified ordered replay and CAS: accepted H0 stays unchanged while working H1/H2 differ; missing edit receipt rejects; final run increments conversation revision once. Fixture extraction, not semantic accuracy proof |
| Requirement admission before hardware acquisition | Catalog-policy graph regressions; actual V2 lifespan/API/executor/SQL/saver three-turn fixture | Missing goals, scalar/unit consent do not require hardware I/O; candidate fetch follows admitted goals; native resume keeps the committed merge. Unloaded catalog cannot justify missing-metadata/variant claims; waiting finalizer rechecks the same policy |
| Dependency direction | AST boundary gate + retained helper regressions | Application/capability do not import infrastructure/runtime frameworks; helper ports are injected explicitly. This verifies dependency structure, not factual accuracy of legacy heuristics |
| Canonical alternatives helper | Missing/empty catalog, price cap, socket/RAM, cooler support and stable limit regressions | No embedded products/prices or over-budget fallback; exact catalog identity/price retained. Matching only requested standards, not full-build compatibility; stock remains unknown |
| Read → merge → fresh grounded result | ISSUE-112 RED→GREEN; managed fresh/recovery gates with real optimizer | Verified: canonical old ledger retained, current-context evidence publishes; stale reference rejects |
| Cancel after multiple edits | Managed PostgreSQL confirmation/edit gate pauses after both merges, then drains/cancels executor | Verified: accepted pending snapshot/head/revision preserved, no second assistant result, active slot cleared only after stop ACK |
| Publication race after multiple edits | Fixture competing revision committed after native validation, before locked finalize | Verified PUBLICATION_CONFLICT: no assistant result/head overwrite; competing revision preserved and slot stays busy when ACK persistence fails. Injected own-row conflict, not cross-service writer proof |
| Optimizer completion and scoped failure | Real optimizer/search-report tests; managed build/multi-task tests | Verified supplied-candidate scope, not global catalog infeasibility |
| Mixed outcomes and bounded repair | Managed multi-task, missing-fact native and targeted-repair tests | Verified fixture tools/model; no generated benchmark proof |
| Unified V2 attachments → ordinary follow-up | Actual lifespan/API/executor/SQL/saver regression | One conversation, revision2/four messages, prior published pair in context; identity/model/catalog are fixtures |
| Basic SSE + bounded dialogue | Run event subscription/API/native tests; extractor and provider context tests | SSE observes committed events only; no reconnect/cancel ownership. History4 pairs/12k chars, frozen on recovery; not current facts or consent |
| Curated source binding and conflicts | Tom's parser RED6 failures → GREEN; reader/tool/finalizer regression | Explicit header/column binding; same-model conflicts clear numbers, remain UNRESOLVED. Missing binding falls back to CONTENT_ONLY; no site truth or compatibility guarantee |
| 100-turn state/native storage bounds | PostgreSQL 100-turn/6KB-payload regression + reopen; same-run/pending/recovery suite | Verified fixture: state highwater 23159 bytes, native payload 9311305 bytes; ancestors preserved. Retention/GC remains P5 backlog |
| Version compatibility/recovery expansion | Unsupported-base guards and selected two-attempt recovery | Selected policy verified; legacy migration/process-death authority open |

Live provider/catalog/identity smoke is separate from fixture-backed core evidence.
Remaining P5 list/history/reload UI, retention/delete, richer accessory policy, source expansion and
internal replay keep their own acceptance criteria in the feature backlog.

Commands/results live in [implementation status](stateful-implementation-status.md).
Selected required gates are verified. Reopen this milestone only for a failed
required gate; approved feature/live/operational deferrals do not become completed.

Final root gate: [managed V2 regression](../../ai-service/integration_tests/test_failed_first_turn_postgres.py)
proves tool commit → terminal first-run failure → persisted stop ACK/release → saver
close/reopen → second run from accepted root. Newer failed checkpoint is ignored;
R2 publishes once, without orphan evidence. Selected version policy rejects legacy
bases after PostgreSQL reopen; migration/heartbeat takeover remain unsupported.

Current commands/counts are in implementation status; app migration is0006_user_memory.
The later FULL_SETUP/soft utility/explicit account-memory extension does not change
the original selected core audit boundary; see status for its separate gates.
All listed selected-policy gates
are verified; feature/live/operational expansions above remain open under their own
criteria, not silently marked complete.
