# Historical implementation journal

Archived from the status page on2026-10-14. Dates, commands and results below are
historical evidence, not the current TODO list or live capability specification.
For current behavior read [documentation](README.md); latest gates are in [status](stateful-implementation-status.md).

As of 2026-10-15 the server is V2-only. Enable flags/V1 mode selections mentioned
below describe earlier gates, not current setup instructions. Preserve them as history.

### Historical slice evidence — not the current TODO list

P5 list slice RED→GREEN: service lacked list(), GET collection returned405. Added
owner-authorized cursor lookup, existing SQL keyset ordering/lookahead and bounded
public projection. PostgreSQL gates cover tie-break/paging/foreign cursors; HTTP
gates cover auth/envelope/limits/OpenAPI and saved V2 flexible answer serialization.
No schema migration or default-version switch; other P5 routes remain unfinished.
Event journal foundation now verified:0004/0005 migration, typed public envelopes,
serialized per-run sequences/dedup, concurrent same-key replay, changed payload
rejection, rollback/reopen and owner/cursor checks. ISSUE-115 CHECK NULL regression
fixed with a forward constraint migration; no data reset. Local DB at0005 head.
Lifecycle emission now verified via managed SQL/native tests: admission START,
validated DELTA/COMPLETED atomically with publish; V2 result retains flexible state,
build and revision. Pending/running cancel ERROR only at safe release; retry cleanup
emits terminal ERROR, transient retry emits none. Failed terminal-event insert rolls
back assistant/head and both final events; conflicting publish leaves only START.
HTTP SSE now subscribes/tails committed events, owner-authorized and independent
of execution. No Last-Event-ID/reconnect/automatic retry. DELTA is final validated
text, not provider tokens. No migration beyond0005 for this slice.
P5 cancel slice RED→GREEN: missing local signal method/HTTP404, now owner-scoped
POST202. Durable cancel commits before signalling; pending/no-claim cancels directly;
running child drain retains busy slot until ACK. PostgreSQL covers local signal and
missed-signal heartbeat fallback; real optimizer/native publication race covers
cancel after validation/before CAS (no assistant/head publish). HTTP V1/V2 covers
auth, uniform404, static envelope and repeat. No user-supplied stop evidence.

Added confirmation → explicit requirement edit regression: accepted H0 is immutable,
working H1 (RAM16) then H2 (RAM32) have distinct content hashes, and preparation
replays both authorities in order. Missing edit receipt rejects. Managed PostgreSQL
fresh/recovery cases now confirm a 30m proposal, explicitly edit to 25m, run the real
optimizer and publish via native lineage/stop/CAS. Accepted head stays unchanged
while execution is held; final run advances conversation revision once, and duplicate
submission adds no messages. ISSUE-113 fixed two dynamic-registration continuation
guards: bootstrap from accepted tasks and compare task identity independently of
the requirements revision. A registered continuation regression also rejects a
forged product/task binding while allowing the legitimate requirement revision.
Managed cancellation after both edits drains the executor, publishes no new head
or assistant message, retains the accepted pending snapshot and releases only after
stop ACK. Model/catalog remain fixtures; this is internal executor cancellation,
not the deferred public cancel API. Publication-race fixture commits a competing
revision after native validation/before locked CAS: finalize returns
PUBLICATION_CONFLICT, preserves accepted head/assistant history and competing
revision, and keeps the slot busy when ACK persistence fails. Combined root gate
now passes: actual first V2 run errors after tool commit, persists stop ACK/releases,
then closes/reopens saver. New coordinator/executor publishes R2 from accepted root
without orphan evidence. Duplicate submission adds no messages. Migration current
was `0003_initial_root` at that gate; current head is `0006_user_memory`.
P6-01 closes for selected fixture-backed core;
live provider/catalog/identity, feature/operational extensions remain unfinished.
Core audit found/fixed ISSUE-112: a read before requirement merge wrongly blocked
publication even after fresh evidence. Graph and publisher now share current-run/
context projection; raw old ledger remains unchanged. RED→GREEN checks 8m historical
price, 9m current output and stale-ref rejection. Managed fresh/recovery PostgreSQL
gates verify read→merge→real optimizer→CAS, preserving the old-context record.
ISSUE-098 storage slice observed RED→GREEN: with 6KB catalog descriptions, old
working ledger growth failed at turn 74 (previous state 507215 bytes). V2 new-turn
windowing now keeps current-run ledger in working state; old canonical records
remain in immutable native ancestors, not deleted/relabelled. Same-run context
changes/resume and pending/domain state are preserved. 100 PostgreSQL turns pass:
state highwater 23159 bytes; logical native payload 9311305 bytes across checkpoint,
blob and write payloads. First/last evidence remains readable after reopen.
This is a fixture storage gate, not physical disk/WAL/RSS measurement or GC proof.
Retention/delete/GC remain feature backlog; ISSUE-098 is not fully resolved.
ISSUE-092 root slice observed two RED→GREEN cases: application rollback after native
commit previously created another root; a native-only legacy thread was silently
given a fresh head. Initializer now reconciles one exact server-marked empty root,
ignores newer debug checkpoints and rejects populated unmarked native history.
Real SQL concurrency invokes one initializer and attaches one root. Reopen/retry
preserves its ref/revision zero; ambiguous/nonempty/nonroot-lineage markers reject
without extra writes. Automatic reconciliation scheduling and legacy migration
are not implemented; this verifies the synchronous/internal-retry contract.

Explicit-user pure policy passes nine cases: whole independently extracted draft
match, canonical resolution, private run/message/base-bound receipt and atomic
copy merge/replay. CLEAR preserves unmentioned budget/goals. Agent-authored text,
mismatch, omitted items and unresolved units cannot auto-merge; wrong receipt scope
rejects. Extraction remains model-based semantic assessment, not intent proof.
V2 runtime now wires the existing budgeted extractor, private receipt checkpointing
and publication replay from accepted/confirmed requirements. Four graph cases
verify match, mismatch, agent text and merge→missing-budget question; dropping a
receipt rejects publication. Managed SQL/executor/native gates verify a fresh real
optimizer build without confirmation, and stopped recovery after working merge
without re-extraction/optimization repeats. During recovery the published head,
requirements and history remain unchanged; final CAS publishes once/idempotently.
Model/catalog are fixtures; this is not live semantic accuracy/provider evidence.
Proposal resolution moved to an application helper; graph owns orchestration.

Verified SQL/native flows: catalog turns; unit/SKU choice → immutable confirmation
→ real optimizer; comparison choice retains original task; saved-build explanation.
Agent-proposed changes do not publish without confirmation; complete explicit-user
matches use the receipt/CAS path above.
V2 free-text unit/SKU choices now produce run/source/request-bound receipts.
Application rederives typed continuation at publish, checks canonical candidates/
unit evidence, and keeps pending consent. Unclear choices retain the original
pending source and unchanged requirements. Managed SQL/optimizer gates pass;
selected factory uses the same budgeted structured extractor.
No-op resolution regression fixed (ISSUE-108): typed/free choices with unchanged
ACCEPT continue the original task through tools/grounding without extra consent.
Publication rederives the exact command; changing SKU still cannot bypass consent.
Evidence is native graph/preparation regression, not a distinct SQL no-op fixture.
Free-text comparison choices now pass managed SQL publication without task
re-extraction or requirements/build mutation. Run/source/request-bound receipts
are rederived at publication; accepted subject bindings cannot be dropped. Empty
choices keep waiting; unavailable selected products remain bound, not replaced.
Pending requirement edits/removals now pass managed SQL → confirmation → real
optimizer. Untouched budget/workload and original task/source remain; changed item
uses the new message evidence. Canonical state does not change before consent.
Publication rederives amendment; forged source/target or modified proposal rejects.
Comparison subject correction now passes managed SQL publication. Only the edited
binding is cleared/re-resolved; other subjects, original task and canonical
requirements/build remain. Ambiguous corrections retain source-bound overrides;
wrong target/run/quote or dropped unaffected binding rejects.
Explicit REPLACE now binds the current draft/task source or immutable proposal
ID/hash/revision/base. It starts a new task from the new request, not a mutation
of old pending content; canonical requirements/build stay. Managed SQL task
replacement passes; proposal owner/hash gates pass pure binding tests. DISCARD
publishes a server acknowledgement with business status DISCARDED, no model/tool
or completed-task claim, and preserves requirements/build. Managed SQL verifies
slot release after stop/lineage/CAS and a fresh task on the next turn.
ISSUE-109 fixed with RED→GREEN: REPLACE/DISCARD reject an unpublished requirement
artifact target. Existing snapshot validation rejects wrong base content; accepted
requirements/build/pending state are not mutated by rejected commands.
ISSUE-110 fixed with four RED→GREEN cases: selected UNKNOWN/CONFLICT facts support
only unresolved insufficient-evidence responses. Server renders typed model/status/
source, not agent numbers. Native PostgreSQL reopen/resume reuses committed facts;
pure publication rejects changed terminal text. This is not a separate managed SQL
CAS/live-provider gate. Curated facts currently cover dimensions, not FPS/benchmark.
Mixed-task final validation now uses exact task-index coverage and existing
single-task validators. Real optimizer tests preserve a successful build alongside
unknown facts; scoped INFEASIBLE/SEARCH_INCOMPLETE cannot erase a grounded catalog
answer. Partial build preparation stores the verified public build. Public task
metadata keeps outcome/reason. Native PostgreSQL mixed read/missing-fact recovery
does not refetch committed tools; changed terminal text rejects at preparation.
Managed multi-task confirmation/build now passes the real SQL/native executor,
attempt ledger and stop/lineage/CAS gate. Partial answer preserves the verified
build; duplicate submit leaves head/messages unchanged, and the next saved-build
explanation does not optimize again. Model/catalog/web remain fixtures.
ISSUE-111 fixed with RED→GREEN: failed task indices reach bounded repair; one
successful optimizer/read is retained while the final candidate is corrected.
OpenAI/Gemini response parsing uses fixtures; live provider and cross-phase audit
remain open. No whole-phase completion claim.

V2 lifecycle recovery verified through actual API/executor: SDK timeout after a
committed read → stored drained stop ACK → new generation → exact native resume
→ lineage/CAS publish. Catalog/context and call ledger are reused; old tool work
is not repeated. Stopped retry cleanup releases expired/exhausted/cancelled slots
only with matching stored ACK; live/missing/stale-proof cases remain busy. Accepted
head/history stay unchanged and a fresh request can proceed after valid cleanup.
V2 allows two execution attempts; V1 one. SDK 429/5xx/timeout are
allowlisted; unknown/application errors stay terminal. No heartbeat-only takeover.
PostgreSQL reopen additionally verifies recovery ignores newer orphan checkpoints.
Stopped-source reconciliation scans at most 256 checkpoints using exact run/
execution/generation/base/input/version metadata, validates ancestry, and requires
one unique lineage tip. Missing/stale DB cursors recover without repeating the
committed read; other-run orphan is excluded. Same-execution forks reject without
advancing generation/head. This requires an already stored owning executor ACK.

Proof boundary: PostgreSQL/saver/executor/optimizer are real; model/catalog/auth
are fixtures. No live-provider claim. Open: semantic quality and cross-phase audit,
process-death reconciliation and multi-retry
source advancement beyond the selected two-attempt policy.
The evidence below records earlier slices; their “not selected” wording is historical.

Plan revision 27: F01–F04 IN PROGRESS. V2 opt-in nối flexible loop, API/composition
và managed publication; V1 default giữ prefix cũ. Compiler/executor guards reuse.
The following paragraphs preserve historical per-slice evidence; current gates are above.
F01 pure slice: four discriminated V2 actions; versioned requirements content hash
excludes legacy counter; immutable proposal/confirmation binds ID/hash/target/base,
owner and conversation. Confirm returns patch only. Search DTO separates declared
complete exhaustion from incomplete search; heuristic-found build stays FEASIBLE.
17 focused tests; collection RED and found-result consistency RED→GREEN observed.
NativeFlexibleModel đã parse 4 actions, bind state-aware tools và structured repair;
multiple/mixed actions hoặc JSON tool-call bị reject toàn bộ. 13 V2 protocol tests
pass; shared transcript giữ Gemini signature qua serialize. Không live-provider proof.
No selected-runtime/API V2 switch. Actual optimizer trace/report now exists;
internal search terminal mapping now exists; managed publication remains open.
No added persisted counters. Runtime migration/semantic merge policy remain F02–F04.
F02 pure admission: agent patch tạo pending, exact confirmation mới atomic merge;
occupied pending slot bị reject, no-op giữ hash/binding. Six focused cases pass.
Fixed identical SET deleting a resolved binding (observed behavioral RED→GREEN).
Internal V2 graph: read-before-budget, proposal/wait/exact confirmation, immutable
ledger filtering, real optimizer build và structured repair. Eight core tests pass;
two PostgreSQL reopen tests verify committed read reuse and pending confirmation
survival. Model/catalog/attempt boundary are fixtures, not live provider or managed
CAS/publication proof. Explicit-user admission, free-text pending continuation,
graph version/accepted-head/publish integration remain open.
F03 empty/unavailable slice: final names canonical tool-call refs; server validates
actual failed/empty/unreadable outcomes. V2 answer/task DTO marks negatives UNRESOLVED,
not completed BUILD/COMPARE; positive mapping follows grounding validation. Eight
pure cases + two graph cases pass, including observed graph behavioral RED→GREEN.
Missing-measurement facts, general partial mixed-task completion
and fully targeted repair remain open; no V1 HTTP/response envelope change.
Reference continuation: owner/content/publication-bound V2 pending wrapper; typed
choice validates original source/offered SKU/current canonical rows and creates
pending confirmation, not an implicit merge. Nine core cases + PostgreSQL reopen
pass; graph no-model continuation observed RED→GREEN. Free-text/amend/discard
remain open. New internal graph version requires explicit migration/transport gates.
Typed unit continuation: original amount, alias and exact span validated; full reply
message retained as source, never a quote-only replacement. Partial unit→SKU roundtrip
keeps draft and both sources. Six core cases + native unit reopen pass; no model call
or automatic merge. Internal version now native-flexible-react-v2-quantity; V1 selected
runtime still unchanged.
F04 version/accepted-head gate: guarded DurableConversationGraph reuses exact native
base, requires initialized root and declared execution/base version; legacy/empty
versions reject before dispatch. Four core cases + PostgreSQL reopen verify newer
orphan is ignored and rejection writes no checkpoint. Existing V1 policy stays
unchanged by default; V2 selected factory/publication integration remains open.
Publication preparation shares final validation with graph. Eighteen core cases
cover read/build projection, tampered terminal rejection and exact confirmation-bound
change. New state is re-derived from accepted proposal/command, history preserves
money and becomes stale, partial bindings need no fake optimizer receipt. Native
reopen verifies unchanged answer lane and new waiting artifacts. Waiting preparation
re-resolves proposals/questions and typed continuation from accepted artifacts/stored
commands; 11 core cases and two PostgreSQL reopen cases pass. Confirmed-change waiting
uses the same transition binding as answers: five core cases + native confirm→clarify
reopen pass, new requirements retained/tasks unresolved/history stale. Native head
revisions are fixtures; coordinator CAS remains open. ISSUE-107 stale cross-run price regression fixed: current-run origin required
for projected facts, historical ledger retained, repeated IDs scoped per run.
V2 accepted snapshot now retains original task message/ID and either one pending
artifact or a validated final answer. Pending content/task bindings are checked;
V1 serialization stays unchanged. Six core cases and one PostgreSQL reopen gate
verify encoding and exact-head reads despite a newer orphan. Graph `prepare_publish`
now binds stored request/task/commands and revalidates before terminal checkpoint.
Four core cases cover read/waiting/confirmation/request mismatch; two PostgreSQL
cases resume failed preparation without repeating model/tool. Selected factory/
transport and managed stop/lineage/CAS integration remain open.
Task-only adapter now returns source-bound `TaskDraftBatch` through one reserved
model call, without requirement extraction/merge. Nine core cases pass, including
canonical comparison resolution and ambiguous result remaining unresolved. V2 graph
now checkpoints `register_request` then `resolve_registered_tasks`. Unresolved
subjects allow reads but block final answer; source-bound pending task resolution
can be prepared/persisted without fabricated completion targets. Three core cases
and two PostgreSQL reopen gates pass with no repeated extraction/lookup/read.
Typed V2 task selection now reuses source/revision/offered-candidate validation
before the agent, then rechecks active catalog identities. Six core + two PostgreSQL
gates retain original task/previous bindings without re-extraction. Selected product
unavailable stays unresolved, never switches to another match. Free-text/amendment
continuation and selected factory/transport/CAS remain open.
Explicit `TurnRequestV2`/parser now round-trips stored command bindings, maps original
task source into preparation input and preserves V1 idempotency payload shape.
Ten core cases + one PostgreSQL admission/JSON/idempotency gate pass. Coordinator
defaults to V1 and rejects V2 unless explicitly selected; V2 cannot use V1 publish.
Internal coordinator V2 publication now revalidates app-written execution context,
exact accepted base, stored request/tasks and terminal snapshot before shared
run/execution/generation/version lineage and drained-stop/CAS gates. Seven core
cases + three PostgreSQL managed gates pass: answer/waiting atomically advance
head/revision/message once; wrong-generation checkpoint publishes nothing and
retains busy slot. Managed confirm→real optimizer→publish→saved-build explanation
also passes: immutable confirmation, original task retained, historical money/
requirements unchanged on explanation, one optimizer call and idempotent retry.
The gate commits three SQL revisions/six messages; provider/catalog are fixtures.
Public route/factory, managed SKU/unit/task-selection/recovery and free-text/
amendment gates remain open.
Search evidence slice: actual enumeration/pool/removal/metadata/scoring observations
are retained in receipt, with execution policy hash. Report revalidates normalized
input/catalog/policy and independent found-build satisfaction; dispatcher attaches
typed evidence. Six real-optimizer cases pass. No removals/unknown/scoring loss and
complete enumeration can certify absence only inside supplied normalized scope;
otherwise no-result is SEARCH_INCOMPLETE. No full-catalog or pruning-proof claim.
Legacy receipts without trace stay uncertified. Internal search final validation
re-derives current report; scoped INFEASIBLE completes BUILD only, SEARCH_INCOMPLETE
does not complete tasks. Four pure + two real-optimizer graph cases pass. Native
PostgreSQL reopen after optimizer checkpoint reuses report without optimizing again
(explicit empty supplied scope fixture; not backend coverage or managed-publish proof).
Whole-pending DISCARD/REPLACE mới pass 3 core + 2 PostgreSQL focused tests ngày
2026-10-12; còn full/static/docs implementation audit trước đóng slice.

Catalog snapshot slice: Java catalog/common-lib 139 tests pass, including snapshot
cursor service, batched assembler and standalone HTTP route/envelope. AI's 16-product
scan now dispatches one call; summary-shaped data fails rather than yielding a false
empty catalog. No default Java build claim: this environment lacks ct.sym and used
source/target 25 CLI overrides. No deployed-backend or SQL query-count proof.

Earlier intermediate gate (superseded by section2): 620 core and 50 PostgreSQL integration tests pass;
Ruff, mypy 159 source files and offline lock check pass. Native suite includes V2
read/proposal/search/reference/unit/version-head/preparation and internal managed
read/waiting/build/confirmation/saved-explanation CAS gates. Selected application
factory/HTTP remained V1 at that gate; current V2 is opt-in.
No live LLM/catalog claim.

Curated dimensions: one ASUS GPU techspec template, reduced real DOM fixture and
live reader returned READABLE/STRUCTURED. Source/model/quote/document hash/parser
version bind typed fact refs; server renders dimensions without axis/fit inference.
Eleven core cases cover fallback, missing/conflicting values and source identity,
including exact GPU suffix matching (5070 is not 5070 Ti).
Native PostgreSQL gate reopens saver after explanation failure and resumes without
refetching committed facts. Model/catalog/budget in this gate are fixtures, not
durable-attempt or live-agent proof. Benchmark parsers/conditions and query relevance
remain open; P3-W02/P3 are not complete.

Web review fixes (ISSUE-105): two regressions RED→GREEN. Empty search snippets
remain valid previews with no evidence refs. Mixed catalog/web answers preserve
exact quotes labelled as unverified reference content, alongside canonical prices;
invented model prose remains excluded. Curated facts are still TODO.

Comparison mention amendment: source-bound overrides keep original task and other
product bindings. Edited subject is re-resolved; unknown/ambiguous results remain
pending with updated options. Core gate covers exact source rejection, forbidden
model IDs, ambiguity→choice roundtrip and resume without another amendment call.
Native PostgreSQL gate reopens a NOT_FOUND comparison, corrects the mention, then
publishes both products while retaining 25m budget. Model/catalog fixtures, not live
intent-quality proof. Whole-task/draft replacement remains open.

Pending requirement amendment: amount/SKU replacements and individual removal
preserve unrelated requirements and original completion task. Per-item source
messages are revalidated before atomic merge; changed items lose prior choices.
Native model attempts are budgeted; checkpoint resume after catalog failure does
not repeat a committed amendment. PostgreSQL reopened saver/managed publish gates
cover amount change and removal while retaining 25m budget. Model/catalog fixtures;
comparison subject edits are verified separately; whole-draft replacement remains open.

Unit clarification: original numeric draft stays wholly unmerged until units resolve.
Typed/free-text choices bind original and confirming sources; server handles money/TB
normalization. A dedicated choice checkpoint prevents repeated MODEL calls after
catalog failure. Real PostgreSQL saver reopen/managed publish verifies retained budget
and both sources. Old hashes stay unchanged when supporting evidence is absent.
Amount amendment is not unit confirmation; it uses the separate pending-edit path.

Web reader/composition: two regressions RED→GREEN. HTML extraction/metadata use
awaited CPU work; dispatcher no longer creates global infrastructure dependencies.
Native runtime gate checks injected adapter settings for guided/ReAct modes.
Curated structured facts and live LLM are still separate unfinished gates.

Web search correction: four regressions RED→GREEN; current DuckDuckGo title anchors,
organic-only results and single redirect decode are covered. Challenge/layout failure
now reaches ReAct as WEB_SEARCH_UNAVAILABLE, not empty success. Live probe returned
three review sources with original titles/URLs; TechPowerUp read returned READABLE
(5099 characters). No live agent/LLM or structured benchmark-fact verification.
Curated extraction remains open.

Typed task continuation: pending product options and original comparison survive
native saver reopen. Source/revision/offered-candidate checks, sticky canonical
bindings and fresh lookup prevent silent substitution; already-merged budget is
preserved. Read/publish validates public options against the pending artifact.
Model context includes original task and resolved product IDs. Two core cases
observed RED→GREEN; one real PostgreSQL managed admission/publication gate retains
25m budget and publishes both selected products after reopen. Model/catalog are
fixtures. NOT_FOUND mention amendment and older-run selectors remain open; P3 is
not complete.

Free-text task choice: six added core cases cover budget denial, empty/forged/
non-offered choices and native resume after catalog failure. Dedicated choice
checkpoint prevents repeating a committed model call. The reopened PostgreSQL
gate now covers typed and free-text variants; the latter reserves exactly one
additional MODEL attempt. Production factory injects the budgeted chooser.
Model/catalog remain fixtures, not live intent-quality proof.

Accepted saved-build slice: typed checkpoint/snapshot evidence, exact task binding,
server-rendered historical prices/stale label, owner scope and publish revalidation.
Native SQL gate publishes a snapshot fixture via managed admission, creates an
orphan, reopens saver, then runs the production ReAct factory; explanation uses
the accepted snapshot without catalog HTTP. Model remains a fixture. Unit tests
cover invented price/FPS, foreign thread/ref and refusal to satisfy a new BUILD.
Stale projection bug RED→GREEN: hash binds the one public snapshot; consultation
revalidates with actual revision, and mismatched snapshot fails publication/read.
Arbitrary older-run selection remains open; no claim that all history UX is done.

Flat ReAct runtime: `AI_STATEFUL_REACT_ENABLED=true` selects extraction/merge,
canonical task resolution and bounded tool nodes on one graph/thread. Mutually
exclusive with guided execution; legacy chat unchanged. Native gate covers HTTP
submit/poll/history, build→catalog read, shared accepted state, durable attempts,
publication and provider close after drain. Model/auth/catalog are explicit fixtures.
Core cases guard BUILD completion, skip hardware scans for read tasks and preserve
non-stale saved builds on unchanged requirements. Source-bound task/graph tests
observed RED→GREEN; runtime gate is not live provider/web verification.

ReAct prerequisite: source-bound requested tasks now accompany requirement Draft
and are validated by provider/resolver. Six new extraction cases cover build vs
requirements, comparison mentions and malformed/forged subjects. Three observed
RED→GREEN. Canonical task resolution now binds build revision/comparison product
IDs, with atomic pending handling and no default BUILD. Five pure cases pass;
two HTTP adapter cases RED→GREEN prove exhaustive cursor lookup and bad-cursor
failure. Public task clarification and arbitrary historical selection
remain open. Canonical lookup is bounded literal keyword matching, not alias search.

Comparison completion: 2/5-product regressions RED→GREEN. Every requested product
must have selected evidence, not merely exist in the tool payload. Curated web facts
remain open; this fix does not close P3/P4.

SKU continuation (2026-10-11): three focused regression tests RED→GREEN.
Native PostgreSQL gate closes/reopens saver connections between ambiguous and
selection turns; real managed admission/finalization publishes WAITING_INPUT then
COMPLETED. Accepted public options survive reopen; the original 25m budget/pin
merge atomically; a GPU-only catalog correctly returns INFEASIBLE. Explicit model
and catalog fixtures, not live provider proof. Unit clarification and
task continuation remain open. Guided and ReAct execution are opt-in via
AI_STATEFUL_BUILD_ENABLED / AI_STATEFUL_REACT_ENABLED respectively.

Free-text SKU choice: seven focused cases (six initially RED), source/candidate
rejection, empty-choice retention, budget denial and checkpoint resume without a
second model call. Native PostgreSQL gate covers typed and free-text variants,
reopened saver, actual MODEL reservation and managed publish. Native schemas bind
with installed OpenAI/Gemini SDKs without network calls; not live intent-quality proof.

| Hạng mục                                         | Evidence                                                                                                                                                                                                  | Giới hạn                                                                                                                                                                                                                                          |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Persisted history HTTP (2026-10-11)              | Native missing-route RED→GREEN; full core 337 pass (8.24s), PostgreSQL 13 pass (1.29s), Ruff/mypy 136 files/offline lock pass                                                                             | Real SQL history after managed two-turn publish; ordered pages, cursor/owner scope, bad limits and static field errors. No SSE/reconnect/frontend proof                                                                                           |
| Awaited CPU work (2026-10-11)                    | Two focused cases RED→GREEN; full core 337 pass (8.42s), PostgreSQL 13 pass (1.30s), Ruff/mypy 136 files/offline lock pass                                                                                | Optimizer off event loop in build graph and ReAct tool; cancellation drains worker before stop ACK. asyncio thread pool, no process isolation/immediate kill; production composition still missing                                                |
| Hardware candidate adapter (2026-10-11)          | Missing adapter RED→GREEN; three focused cases include actual optimizer/verifier. Full core 335 pass (8.31s), PostgreSQL 13 pass (1.33s), Ruff/mypy 135 files/offline lock pass                           | Explicit category/option mapping, complete bounded cursor scan and variant prices/stock. HTTP fixtures only; local probe still configured catalog 401/direct 8082 ConnectError, provider fallback/no keys. Production mapping/factory remain open |
| Run HTTP transport (2026-10-11)                  | Full core 332 pass (8.25s), PostgreSQL 13 pass (1.26s), Ruff/mypy 134 files/offline lock pass                                                                                                             | Auth/ownership/conflict/path validation and no-executor 503; ASGI follow-up → actual SQL/optimizer/checkpoints → managed publish survives client close. Injected auth/extractor/catalog; production factory/lifespan still missing                |
| Exact web excerpts (2026-10-11)                  | Fabricated-FPS regression RED→GREEN; full core 331 pass (8.31s), PostgreSQL 13 pass (1.21s), Ruff/mypy 134 files/offline lock pass                                                                        | Web-only publication now quotes exact selected source segments, not arbitrary model prose. Source truth/query relevance/curated grounded synthesis still TODO; no live runtime proof                                                              |
| Bounded web reading (2026-10-11)                 | Oversized page regression RED→GREEN; full core 329 pass (8.45s), PostgreSQL 13 pass (1.23s), Ruff/mypy 134 files/offline lock pass                                                                        | Character pagination + exact segment refs prevent oversized article result; still refetches each segment. No curated facts, live model or API wiring proof                                                                                        |
| Native requirement/product adapters (2026-10-11) | Three extractor + three catalog cases observed RED→GREEN; full core 328 pass (8.13s), PostgreSQL 13 pass (1.17s); Ruff/mypy 134 files/offline lock pass. Both installed SDKs bind Draft structured schema | Budgeted extraction/catalog, exact product-vs-variant identity and unknown range price. HTTP fixtures, no live LLM. Configured local catalog request returned 401; runtime auth/URL and hardware candidate mapping still pending                  |
| Native ReAct protocol adapter (2026-10-11)       | 5 focused protocol cases pass; full core 322 pass (8.26s), PostgreSQL 13 pass (1.15s), Ruff/mypy 132 files pass. Installed OpenAI/Gemini SDKs bind six tool schemas                                       | Canonical pairs, allowed tools, malformed/multi-call handling and serialized Gemini signature; no live model credentials, no production lifespan/API wiring                                                                                       |
| Web review fixes (2026-10-11)                    | Four regressions observed RED, then GREEN; full core 317 pass (8.56s), PostgreSQL integration 13 pass (1.20s); Ruff, mypy 131 files, offline lock check pass                                              | Mixed web/catalog output stays canonical; server-owned links; ReAct web TOOL_IO reservations; source-aware evidence refs. Curated extraction/native LLM/HTTP wiring remain open                                                                   |
| Managed run → optimizer → publish (2026-10-09)   | Agent: full core 306 pass (8.90s), native integration 13 pass (1.46s), Ruff src/tests/integration/migrations và mypy 129 files pass                                                                       | PostgreSQL thật, optimizer thật; extractor/catalog fixtures. Hai lượt giữ requirements/history, lỗi model giữ accepted head. Chưa bật chat API hoặc gọi live LLM/catalog                                                                          |
| Main root/create path (2026-10-09)               | Agent applied Alembic 0003; native create/root/reopen pass; all integration_tests 12 pass (1.32s); full core 305 pass (8.28s); Ruff src/tests/integration/migrations, mypy 126 files pass                 | Core root → build → next-turn preserves requirements; extractor/catalog fixtures. No real LLM/catalog/chat endpoint yet; rare recovery deferred                                                                                                   |
| Power policy fix (2026-10-09)                    | Agent: power/recovery focused 14 pass; full `uv run --no-sync pytest -q --tb=short`: 303 passed (8.46s); Ruff src/tests, mypy 124 files pass                                                              | ISSUE-101 resolved; iGPU/discrete và ngưỡng 180/280W; core fixtures, không live catalog/LLM/DB                                                                                                                                                    |
| Pruning fix (2026-10-09)                         | Agent: full `uv run --no-sync pytest -q --tb=short`: 296 passed (8.40s), gồm 10 case regression; Ruff src/tests và mypy 124 files pass                                                                    | ISSUE-102 resolved: explicit support, UNKNOWN/metadata error, pruning ON/OFF tương đương; core fixtures, không live catalog/LLM/PostgreSQL                                                                                                        |
| P1 baseline (2026-10-07)                         | Agent: test_conversation_core.py 9 pass; full pytest 210 pass (5.45s), mypy 85 files, Ruff/lock check pass                                                                                                | Pure core; chưa wiring durable chat                                                                                                                                                                                                               |
| Baseline trước ReAct source mới                  | Agent chạy 279 core tests; Ruff, mypy 119 files và offline lock check pass                                                                                                                                | Chưa phải full verification của source ReAct vừa thêm                                                                                                                                                                                             |
| Dotenv                                           | 2 tests pass; shell override thắng `.env`; local `.env` ignored                                                                                                                                           | Không thay quyền truy cập API hoặc tự bật stateful mode                                                                                                                                                                                           |
| Foundation PostgreSQL                            | Owner báo `alembic upgrade head` → `bootstrap_stateful` → toàn integration_tests pass                                                                                                                     | Không phải agent tự chạy; không chứng minh live JWKS/LLM hoặc coordinator                                                                                                                                                                         |
| Initial-root native experiment                   | Owner báo `uv run pytest -q integration_tests/test_initial_root_postgres.py` pass; agent chạy 2 memory cases pass                                                                                         | Native mechanics được chứng minh; chưa có production initializer/CAS/concurrency readiness                                                                                                                                                        |
| Typed tools/completion                           | Agent chạy `uv run pytest -q tests/test_react_tools.py`: 4 passed                                                                                                                                         | Internal services với canonical typed test catalog, không phải live backend/LLM                                                                                                                                                                   |
| ReAct graph/tools recheck                        | Agent chạy `timeout 30s env UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run --no-sync pytest -q tests/test_react_graph.py tests/test_react_tools.py`: 7 passed in 0.68s                                     | Focused internal fixtures; không phải full suite hoặc live provider/runtime (ISSUE-100)                                                                                                                                                           |
| Type cleanup                                     | Mypy 123 source files pass sau sửa annotations/import formatting                                                                                                                                          | Chưa full pytest/Ruff rerun sau cleanup; không claim toàn slice đã verified                                                                                                                                                                       |

Historical counts chỉ có hiệu lực tại lần chạy tương ứng, không chứng minh source hiện tại.
Foundation integration owner-reported ngày 2026-10-09 gồm production adapter,
scoped constraints/lifecycle và call-reservation race/reopen; ISSUE-091 resolved.
Commands/environment cho native tests ở [README](../../ai-service/README.md).
