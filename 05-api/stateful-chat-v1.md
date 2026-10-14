# Stateful HTTP and V1 compatibility

Reference for shared endpoints, authorization, pagination and SSE.
New frontend callers use [V2 request/public views](stateful-chat-v2.md);
V1 request fields below are compatibility, not V2 aliases.

## Authorization and response

Stateful routes require configured RS256 identity access JWT and owner-scoped lookup.
Invalid/missing token:401 AI_UNAUTHENTICATED. Missing/foreign conversation or run:
404 AI_CONVERSATION_NOT_FOUND. UUID alone is not permission.

Server verifies issuer/audience/time claims, access type, ACTIVE status and accountId.
Owner, checkpoint selector and execution/stop evidence are not client fields.

Every JSON response and SSE data frame has:

```json
{"data": {}, "message": "STATIC_MESSAGE_KEY", "errors": []}
```

Success errors=[]; error data=null, static key and field/details in errors.
Operational health exceptions are documented separately; no success boolean.

Stateful routes require explicit enabled configuration and application/native DB
readiness. No HTTP migrations, silent RAM fallback or downgrade to stateless chat.

## Route contracts for P2/P5

All paths have prefix `/api/v1`. V2 selection changes conversation/run-result projection,
not shared paths.

| Method/path | Data / HTTP | Message |
| --- | --- | --- |
| POST /conversations | ConversationView /201 | AI_CONVERSATION_CREATED |
| GET /conversations | Page of owned ConversationViews /200 | AI_CONVERSATIONS_LISTED |
| GET /conversations/{id} | Exact accepted ConversationView /200 | AI_CONVERSATION_RETRIEVED |
| GET /conversations/{id}/messages | Page of messages /200 | AI_MESSAGES_LISTED |
| POST /conversations/{id}/runs | Versioned request → RunViewV1 /202 | AI_RUN_ACCEPTED |
| GET /conversations/{id}/runs/{run_id} | RunViewV1 /200 | AI_RUN_RETRIEVED |
| POST /conversations/{id}/runs/{run_id}/cancel | Current RunViewV1 /202 | AI_RUN_CANCEL_REQUESTED |
| GET /conversations/{id}/runs/{run_id}/events | text/event-stream | AI_CHAT_STREAM_* per frame |

DELETE conversation and asynchronous create are planned contracts, not active routes.

Create body has optional title, no owner. Synchronous create returns READY revision0
after native root/CAS. Public GET reads exact accepted state, never latest checkpoint.

## Pagination

Conversation list: limit1–100/default20, updated_at DESC then id DESC.
Message history: limit1–100/default20, sequence ascending.
Cursors are persisted owner/conversation-scoped UUIDs, not checkpoint selectors.

Invalid/missing/foreign cursor:400 VALIDATION_ERROR with errors.field=cursor.
Page has items and next_cursor; empty/last page next_cursor=null.
Conversation listing is live, not a frozen snapshot across pagination.

Failed-run submitted user messages remain history; assistant rows only after publish.
Model history window is a separate filtered projection.

## Submission and idempotency

Path/body conversation IDs must match. Runtime executor missing →503 before admission.
Same (conversation_id,request_id) + canonical body returns same run/result;
changed body409 AI_REQUEST_CONFLICT. Check same-body reuse before stale revision rejection.

Stale expected_revision:409 AI_REVISION_CONFLICT; occupied slot:409 AI_CONVERSATION_BUSY.
202 means admitted, not completed. Poll/SSE reads run independently.

## Cancellation

Cancel is durable request before local executor signal, not a stop receipt.
Unclaimed PENDING run can cancel under claim lock without ACK. Claimed execution
stays busy until owning stop/drain ACK; terminal/repeated cancel is idempotent.

Locked finalize observes cancel and suppresses assistant/head publish.
Missed local signal is picked up by owning worker; cancellation/TTL does not authorize takeover.

## SSE contract

SSE emits lowercase event name and JSON envelope data. No id, Last-Event-ID,
public offset or automatic reconnect/retry. Disconnect does not cancel run.

| Event | Payload/meaning | Message |
| --- | --- | --- |
| START | Durable admission/run identity | AI_CHAT_STREAM_STARTED |
| DELTA | Final validated answer text, whitespace preserved | AI_CHAT_STREAM_DELTA |
| COMPLETED | Published TurnResult and revision; V2 contains public flexible state | AI_CHAT_STREAM_COMPLETED |
| ERROR | Static error code/details; no grounded completion | AI_CHAT_STREAM_FAILED |

Each event binds conversation_id/run_id/positive sequence.
WAITING_INPUT result can complete delivery but not the original build task.
Cancel ERROR uses code AI_RUN_CANCELLED.

START shares admission transaction; final DELTA/COMPLETED share CAS publication.
Event-write failure rolls back publication. Retryable intermediate failure emits no
terminal event; duplicate submit does not re-emit START. Stream does not execute graph.

DELTA is not provider-token streaming. On disconnect poll saved result rather than
admitting a new run to fetch an answer.

## V1 request compatibility

TurnRequestV1 has conversation_id/request_id/expected_revision/message.
No schema_version=2; V1 continuation names are not V2 aliases.
Consultation/patch baseline: [legacy contracts](../04-ai/stateful-chat-contracts.md).

### SKU clarification continuation

V1 `clarification_reply` has pending_message_id and offered item_index/variant_id selections.
Accepted clarification provides constraints revision/options. Typed/free-text choice
binds original source and canonical identity; no partial draft merge.

### Product/task clarification continuation

V1 `task_clarification_reply` binds pending_message_id/constraints_revision and
task_index/subject_index/product_id selections. Product is not variant/SKU.
Original task and other subjects survive selection/amendment.

### Quantity/unit clarification

V1 `unit_clarification_reply` binds original quantity source and selected canonical
unit/evidence. Missing unit remains pending, not a guessed amount.
Current V2 uses reference_reply/task_reply/unit_reply in [its contract](stateful-chat-v2.md).

## Planned revision — initial accepted root/readiness

Initial root and synchronous READY201 already implemented.
Automatic asynchronous INITIALIZING202 and DELETING/public-delete workflow remain
backlog. Initializing does not admit new runs; no latest checkpoint treated as empty state.
Details: [initial root](../04-ai/context-management.md#initial-accepted-root).

## State, patch and setup

Public DTO is allowlisted; no owner/internal ledger/lease/proof/checkpoint selectors.
Owned spending0; pinned paid; synthetic integrated choices labelled with no commerce ID.
Requirements/Full setup semantics: [requirements](../04-ai/requirements.md), not
an unrestricted client mutation API.

## Replay, retention and acceptance

Retention/delete/replay are [roadmap](../04-ai/stateful-chat-implementation-plan.md)
requirements, not active jobs/routes. Internal replay cannot customer-publish.
Persistence and exact-head/stop/CAS acceptance: [core audit](../04-ai/core-audit.md).

**Related:** [First steps](../04-ai/getting-started.md) · [V2](stateful-chat-v2.md).
