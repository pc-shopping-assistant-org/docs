# Stateful chat V1 — P0 contract

Status: contract implemented/verified; routes and persistence NOT implemented.
Scope: UC-AI-001/003 and guided PC build. Existing `/chat`, `/chat/stream`, search,
compare and evaluate remain unchanged until P5 migration. No PydanticAI runtime.

## Authorization and response

All routes below require the verified identity RS256 access JWT and owner-scoped
lookups. Missing/invalid token: 401 `AI_UNAUTHENTICATED`. Nonexistent or another
owner's conversation/run: 404 `AI_CONVERSATION_NOT_FOUND` (do not reveal ownership).
Owner, checkpoint selector and execution evidence are never request fields.

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
Persisting/deduplicating events and reconnect behavior belong to P4/P5.

## State, patch and setup

Canonical schemas live in `stateful_contracts.py`, `conversation_core.py` and
`public_contracts.py`. Model extraction returns TurnPatchV1; it is NOT an
unrestricted client mutation API. Trusted application assigns source/confirmation.

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
