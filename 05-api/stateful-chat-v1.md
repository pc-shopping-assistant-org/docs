# Stateful chat V1 — P0 contract

Status: contract implemented/verified. P2 opt-in POST conversation and GET-by-ID
are implemented with auth/owner checks and lifecycle wiring; owner reported native
foundation gates PASS on 2026-10-09 (ISSUE-091 resolved). Submit/get run handlers
use a managed runtime. AI_STATEFUL_BUILD_ENABLED selects guided build;
AI_STATEFUL_REACT_ENABLED selects the native ReAct graph; they are mutually exclusive.
default resources have no run executor and return 503 before admission.
Message history and owner-scoped conversation listing are implemented against the
application DB. Owner-scoped cancel is implemented; events/delete remain planned.
Scope: UC-AI-001/003 and guided PC build. Existing `/chat`, `/chat/stream`, search,
compare and evaluate remain unchanged until P5 migration. No PydanticAI runtime.

## Authorization and response

All routes below require the verified identity RS256 access JWT and owner-scoped
lookups. Missing/invalid token: 401 `AI_UNAUTHENTICATED`. Nonexistent or another
owner's conversation/run: 404 `AI_CONVERSATION_NOT_FOUND` (do not reveal ownership).
Owner, checkpoint selector and execution evidence are never request fields.

P2 enablement: AI_STATEFUL_ENABLED=true with database/JWKS config. Disabled by
default, stateful routes are absent from OpenAPI. Enabled startup
requires applied Alembic 0003_initial_root and separately bootstrapped saver tables;
missing migration/config fails startup, never silently falls back to RAM.
Published GET uses exact accepted checkpoint channels consultation/public_build,
not graph latest; corrupt or missing accepted state is an error, not an empty state.
Conversation list uses persisted conversation UUID cursors, resolved only for the
authenticated owner. Invalid/missing/foreign cursor: 400 VALIDATION_ERROR,
errors.field=cursor. Limit1–100/default20; updated_at DESC then id DESC; last page
has next_cursor=null. It is a live listing, not a snapshot: updates between requests
can move conversations in the order. V2 selection returns PageV1[ConversationViewV2],
including the accepted flexible projection; never internal checkpoint/owner fields.
POST cancel returns202 AI_RUN_CANCEL_REQUESTED with the current RunViewV1; it is
not a stop receipt. Transaction locks conversation/run, validates owner and commits
cancel_requested before signalling the owning local executor. Claimed executions
remain busy until child/checkpoint writes drain and stop ACK persists. A missed
local signal is picked up by the owning worker heartbeat; no lease-only takeover.
If finalize races with durable cancel, cancellation suppresses assistant/head publish.
Pending runs whose execution_id is null under the same claim lock may cancel/release
immediately: no execution has been claimed. Terminal/repeated cancel is idempotent
and does not alter accepted state. Events/delete remain later P5 slices.
Message history reads persisted application rows, not checkpoint channels.
Cursor is an opaque persisted message UUID; the server resolves its sequence only
inside the owned conversation. Invalid/foreign cursor: 400 VALIDATION_ERROR with
errors.field=cursor. Limit is 1..100, default 20; results sort by sequence ascending.
Empty history returns items=[], next_cursor=null. Failed-run user messages remain
in history; assistant messages exist only after atomic publish.
Submit/get run use StatefulRunService → coordinator; successful admission wakes
the managed executor only after DB commit. Path/body mismatch returns 422.
Without configured run resources both endpoints return 503, never leave PENDING work.

### SKU clarification continuation

GET conversation adds nullable `clarification` from the **accepted** checkpoint:
`pending_message_id`, `constraints_revision`, and `items[{item_index, reason,
options[{variant_id, sku, name}]}]`. Internal draft/source/checkpoint data is not exposed.
The pending requirements remain wholly unmerged until all ambiguities resolve.

POST run accepts optional `clarification_reply`:

```json
{
  "pending_message_id": "<original request_id>",
  "selections": [{"item_index": 2, "variant_id": "<offered variant UUID>"}]
}
```

Keep normal `conversation_id`, new `request_id`, current conversation
`expected_revision`, and `message` in the request. The application verifies source,
canonical constraints revision, offered options and fresh catalog identity before
atomic merge. The choice is included in request idempotency and checkpoint input hashes.
Absent/null reply does not clear the pending draft; duplicate selections are invalid.
Without a typed reply, guided runtime interprets `message` against the accepted
options using a budgeted structured ChoiceDraft. Ordinals refer to the displayed
option order, not item_index. Application validates source spans, offered IDs,
revision and fresh catalog through the same path as a typed reply. Empty choices
keep the question/options pending; an invalid choice does not merge requirements.
The choose node checkpoints before catalog resolution, so native resume after a
catalog failure does not repeat a completed model choice. Unit amendment and
abandon/replace-pending operations remain P3 work. Source matching checks data
binding, not a deterministic guarantee that the model understood user intent.

### Product/task clarification continuation

GET conversation adds nullable `task_clarification` from the accepted checkpoint:
`pending_message_id`, `constraints_revision` and
`items[{task_index, subject_index, mention, reason, options[{product_id, name}]}]`.
These are product IDs for comparison, not SKU/variant IDs.

POST run accepts a separate optional `task_clarification_reply`:

```json
{
  "pending_message_id": "<original request_id>",
  "constraints_revision": 1,
  "selections": [{"task_index": 0, "subject_index": 0, "product_id": "<offered product UUID>"}]
}
```

Use the normal new request_id/current conversation expected_revision. Only one
reply kind is allowed. Application checks source/revision, offered candidates and
fresh canonical matches. Original tasks and already-merged requirements survive
native checkpoint reopen; unique/selected product bindings never switch silently.
Removed selections ask again as SELECTED_PRODUCT_UNAVAILABLE. Absent reply retains
the pending task. Empty options are not selectable.
Public options are rechecked against the internal artifact at read/publication.
The model receives the original task plus resolved completion requirements; a
choice message cannot downgrade comparison into a generic answer.

Pending comparison mentions may also be corrected through the normal `message`.
With no typed/extracted product choice, a budgeted `TaskAmendment` binds exact
new-message evidence to an existing `(task_index, subject_index)`. Original task
kind/span and budget stay unchanged; only the edited subject loses its previous
product binding. Canonical lookup uses the corrected mention. A still-ambiguous
correction returns updated options and supports the same typed/free-text choice.
The amendment is checkpointed before lookup and survives saver reopen/resume.
No model-supplied product ID or synthetic concatenated source message is accepted.

Without a typed reply, the runtime reserves MODEL and extracts `TaskChoiceDraft`
against accepted options. Each proposed product choice needs exact source evidence.
Application checks its span and offered IDs through the typed path, then performs
fresh catalog lookup. An empty choice retains pending; changing unresolved
mentions is handled by the amendment path, not treated as a product selection. The
`choose_task` node checkpoints before lookup, so native resume after a catalog
failure does not repeat a committed choice call. Source matching is not a guarantee
of model intent accuracy; live provider/evals remain separate gates.

### Quantity unit clarification

An explicit integer without a unit is an extraction-only `UNRESOLVED_QUANTITY`.
GET `clarification.items` adds nullable `quantity_amount` and `unit_options`;
`QUANTITY_UNIT_REQUIRED` retains the whole original draft, including budget/pins.

POST run accepts optional `unit_clarification_reply`:

```json
{
  "pending_message_id": "<original request_id>",
  "constraints_revision": 0,
  "selections": [{"item_index": 2, "unit": "GB", "start": 0, "end": 2, "quote": "GB"}]
}
```

Offsets refer to the current `message`, not the frozen original message.
Source/revision/item and exact unit text are checked before atomic merge.
Server normalization handles `triệu` → VND and TB → 1000 GB; no default unit.
Canonical evidence retains the original quantity plus the confirming source.
Absent supporting evidence preserves existing snapshot hashes.
SKU and unit replies may coexist; neither can accompany a task/product reply.
Without a typed reply, `choose_unit` reserves MODEL and validates its typed choice
through the same path. Its checkpoint is reused after downstream failure.
Changing an amount is not a unit-only confirmation; it uses pending-item amendment.

### Pending requirement amendment

With no typed SKU/unit reply and no extracted choice, a pending requirement turn
may amend/drop specific unmerged items through a budgeted structured model call.
No new HTTP mutation payload is required: the follow-up is the normal `message`.

- Replacements keep item identity/subject/predicate and use new-message evidence.
- Discards remove only explicitly selected unmerged items, not canonical state.
- Unmentioned items, original task and their source messages remain unchanged.
- Changed items invalidate old SKU choices/unit confirmations and resolve afresh.
- Merge remains atomic; a remaining ambiguity withholds the entire draft.
- The amendment node checkpoints before catalog IO; native resume reuses it.

This covers amount/SKU edits and item removal within a pending requirement draft.
Comparison-subject correction is described above; replacing/discarding the whole
draft remains open. Source binding does not prove model intent accuracy; live evals
remain a gate.

Every HTTP response and SSE data frame is `{data, message, errors}`. Success
errors is `[]`; error data is null, static message/code and field/details in
`errors`. Operational health exceptions remain unchanged. No `success` field.

## Route contracts for P2/P5

| Method / `/api/v1` route | Request | Response data / HTTP | Static message |
| --- | --- | --- | --- |
| POST `/conversations` | ConversationCreateV1: optional title, no owner | ConversationViewV1 / 201 | AI_CONVERSATION_CREATED |
| GET `/conversations` | opaque cursor, limit 1–100 (default 20) | PageV1[ConversationViewV1] / 200 | AI_CONVERSATIONS_LISTED |
| GET `/conversations/{id}` | owner lookup | ConversationViewV1 / 200 | AI_CONVERSATION_RETRIEVED |
| DELETE `/conversations/{id}` | owner lookup | null / 200, after stop/drain and complete purge | AI_CONVERSATION_DELETED |
| GET `/conversations/{id}/messages` | cursor, limit 1–100 (default 20) | PageV1[MessageViewV1] / 200 | AI_MESSAGES_LISTED |
| POST `/conversations/{id}/runs` | TurnRequestV1; body conversation_id must equal path id | RunViewV1 / 202 | AI_RUN_ACCEPTED |
| GET `/conversations/{id}/runs/{run_id}` | owner + conversation-scoped run lookup | RunViewV1 / 200 | AI_RUN_RETRIEVED |
| POST `/conversations/{id}/runs/{run_id}/cancel` | no execution proof/body | RunViewV1 / 202, cancellation request only | AI_RUN_CANCEL_REQUESTED |
| GET `/conversations/{id}/runs/{run_id}/events` | optional Last-Event-ID bound to this run | SSE, envelope per event | Existing AI_CHAT_STREAM_* keys |

Run submission is idempotent on `(conversation_id, request_id)` with a canonical
request payload hash. Same key/same body returns the existing run; same key/new
body: 409 `AI_REQUEST_CONFLICT`. Revision mismatch: 409 `AI_REVISION_CONFLICT`;
occupied execution slot: 409 `AI_CONVERSATION_BUSY`. Validate idempotent reuse
before rejecting its now-old expected_revision. Cancellation/status/TTL do not
release the slot: verified stop evidence is required. Do not hold DB locks during
model/catalog calls. Deletion must stop/drain writes before purging to prevent
data resurrection; no successful-delete response before purge completion.

Conversation list order is updated_at descending, id as deterministic tie-break;
message history is sequence ascending, with persisted opaque cursors. Cursors and
SSE offsets are scoped/validated, not SQL predicates or checkpoint selectors.
SSE disconnect does not implicitly cancel a run. Reconnect reads persisted events
after the acknowledged offset, with owner authorization on every connection;
unknown/expired event history fails explicitly, never resumes from graph latest.
The subscriber is independent of execution. Submit commits a durable PENDING
run; a lifecycle-owned managed executor claims it. No detached request task or
SSE-triggered graph execution. Explicit cancellation does not release the shared
thread until verified executor stop/drain. Internal P4-A supervisor/attempt ledger
source and SQL admission/publication coordinator are implemented and integration-tested.
Production executor lifespan/provider wiring exists; native runtime verification
uses model/auth/catalog fixtures, not live providers.
Persisting/deduplicating events and reconnect behavior belong to P4/P5.

## Planned revision — initial accepted root/readiness

Implemented main path (0003): ConversationView có readiness INITIALIZING/READY.
POST create chờ root được persist + CAS rồi trả 201 AI_CONVERSATION_CREATED,
revision=0. GET dùng exact accepted ref; checkpoint refs không public.
202/DELETING/background reconciliation bên dưới vẫn là planned, chưa enable.

Initial-root contract trong [context spec](../04-ai/context-management.md#initial-accepted-root--target-extension)
đã được triển khai cho main create/get path; các recovery gates dưới đây còn deferred.

- Target ConversationView thêm readiness `INITIALIZING | READY | DELETING`.
  READY luôn có exact accepted checkpoint; revision-zero READY chỉ có validated
  initial root. Checkpoint refs/initialization identities vẫn private.
- Target POST create: 201 + `AI_CONVERSATION_CREATED` khi READY; 202 +
  `AI_CONVERSATION_INITIALIZING` khi initializer chưa xong. Cả hai giữ envelope
  chuẩn và versioned ConversationView; FE poll owner-scoped GET, không tạo lại
  conversation mỗi lần poll. Đây là static key đề xuất, chưa có trong runtime.
- New run khi INITIALIZING: planned 409 `AI_CONVERSATION_NOT_READY`; DELETING
  không nhận new run. Owner GET initializing trả readiness và chưa có accepted
  public build; không lấy latest checkpoint hoặc giả accepted empty state.
- Initializer cũng phải exclusive claim/stop/drain/fence. Root không gọi LLM/tool,
  không thêm message hoặc tăng turn revision. Crash-before-CAS reconcile exact
  initialization provenance/lineage; stale/debug/latest không thành root.
- FAILED_TERMINAL của R1 không xóa root: lượt mới chỉ sau verified execution stop,
  dùng exact accepted root. Legacy populated thread cần explicit migration/recovery,
  không implicit copy values, reset thread hoặc purge history.

Root create/readiness acceptance gồm owner authorization, concurrent initializer,
crash-before/after-CAS, restart và orphan R1 → R2. Chỉ sau các gates này mới đổi
route table/Swagger/generated reference/feature-local FE models sang revision mới.

## State, patch and setup

Baseline schemas live in `stateful_contracts.py`, `conversation_core.py` and
`public_contracts.py`. Baseline extraction contract TurnPatchV1 is NOT an
unrestricted client mutation API. Requirement-centric target adds versioned
draft/task/resolution/merge contracts from requirements/ ([canonical-state contract](../04-ai/context-management.md#canonical-state-migration-and-task-authority--target-extension)),
with legacy consultation only a compiled/public projection, not another writable
source of truth. Trusted application validates source/confirmation/completion.

- BUILD_PC is the approved default: only case PC/core spending. FULL_SETUP adds
  monitor/mouse/keyboard/headset, at most one per type. Core remains eight slots;
  this V1 does not support multiple RAM/storage slot entries or accessory quantity.
- target_budget_vnd is the cap for the selected scope; accessory_budget_vnd is an
  explicitly supplied accessory cap, unknown by default. No 80/20 allocation.
  FULL_SETUP lacking a clear accessory budget must clarify before optimization.
  A request to add accessories while scope is core-only needs scope/budget
  clarification; do not silently charge them outside the cap or drop them.
- AccessoryRequestV1 kind is OWNED/PINNED/RECOMMEND. OWNED/PINNED require canonical
  variant ID, RECOMMEND has no selected ID yet; absent type is unresolved, not a
  claim the customer owns it. FULL_SETUP resolves all four types before publishing
  a complete setup, with explicit user adjustments captured in state.
- OwnedPartRefV1 always excludes spending; false/1 are rejected. Pinned stays paid.
  Prices/specs/visibility come from the backend; canonical ref alone proves none
  of those. Budget/use-case unknown stays unknown, never optimizer 20m defaults.
- Sparse absent preserves, SET replaces, CLEAR returns unknown/removes binding;
  empty map is a no-op. Final state is validated atomically and cannot overspend
  the accessory cap relative to total. Changes invalidate completed stage markers.
- Intents: continue consultation, new build, adjust build, explain current build;
  search/compare/evaluate flows are preserved. Reset requires explicit patch
  operations grounded in user intent; an intent label alone does not authorize
  deleting unrelated requirements. Preserve old accepted messages/build as
  history; no implied reset on ordinary turns.

PublicConsultationV1 is an allowlist of values/bindings/stale status. It excludes
stage markers, raw snapshots, provenance evidence, lease/worker/stop proof and
checkpoint refs. PublicBuildV1 exposes objective, parts and validated spending
total; synthetic iGPU/stock cooler has no commerce ID or price and is labeled.
Owned/pinned overlap and duplicated slot/type are invalid.

## SSE contract

StatefulEventV1 is a discriminated START / DELTA / COMPLETED / ERROR union.
All carry conversation_id, run_id and positive persisted sequence. Nested run
identity must match the event. DELTA preserves whitespace. `id` is an opaque
run-scoped persisted event offset; event name is lowercased data.event.

- START: RunViewV1; `AI_CHAT_STREAM_STARTED`.
- DELTA: text fragment; `AI_CHAT_STREAM_DELTA`. Tentative text is not accepted state.
- COMPLETED: TurnResultV1 with published revision, public state and answer/build;
  `AI_CHAT_STREAM_COMPLETED`. A clarification may end with WAITING_INPUT and
  `AI_INPUT_REQUIRED`; this is not a completed build.
- ERROR: static StatefulErrorCode and envelope errors; `AI_CHAT_STREAM_FAILED`.
  Failure after a delta does not become a successful grounded completion.

Only post-CAS accepted output emits a successful completion. Debug/replay cannot
emit customer completion, assistant publication or accepted-head movement.
Public DTO shape validation does not itself enforce publication or ownership.

## Replay, retention and acceptance

Internal typed optimizer contracts are in `provenance.py`. Inline snapshot stores
canonical active catalog rows with stock/price/evidence/retrieval metadata,
ordered normalized candidates and explicit effective spending, constraints with
source/lock and revisions, synthetic CPU parent refs, all engine/policy/code/Python/
dependency versions, config tables/weights/limits/tie-break and typed result/decision.
SHA-256 canonical hashes protect catalog/input/result/recommendation payloads;
audit run IDs and retrieval times do not change optimization_input_hash.
Changed prices, candidates/order, algorithm/config/version do change it.

Restore validates hashes/refs; no live catalog/current-config fallback. Hashes do
not authenticate catalog facts or prove complete runtime capture. P3 must capture
actual engine configs and inputs, enforce bounded snapshot storage, implement
the missing pinned/accessory adapters, and test deterministic replay with matching
artifacts. P0 tests use real optimizer results but do not execute a replay adapter.

Chat/run/checkpoint: 90 days; orphan/debug checkpoints: 7 days. User deletion
purges all related data, including framework writes, events and inline snapshots.
Debug/replay is internal-only and cannot publish. Accepted/recoverable ancestors
are not orphan checkpoints. P2/P4 must implement lineage-safe cleanup, stop/drain,
authorization/redaction and storage transaction checks; these policies are not jobs
already running.

P0 acceptance: sparse/atomic merge, budget/owned/accessory rejection, public
allowlisting and correlated envelope, saved snapshot round-trip/hash corruption,
and canonical source evidence tests. P2 native PostgreSQL accepted-head gate and
P4 ownership/race/stop/finalization tests remain mandatory independent gates.
