# Stateful HTTP V2 reference

Frontend và server dùng V2-only, không có runtime enable/version flags.
Shared endpoints/auth/pagination/SSE ở [HTTP reference](stateful-chat-v1.md).
Configure the required DB/auth/provider/catalog dependencies; startup fails if absent.
V2 request, public view, graph and publication are always selected; no automatic migration
of conversations with accepted V1 execution checkpoints.

Frontend assistant chat uses V2 exclusively, including product attachments and
proposal confirmation. It requires configured V2; there is no legacy fallback.

Examples/tutorial: [First steps](../04-ai/getting-started.md).
Verification nằm trong [status](../04-ai/stateful-implementation-status.md), không phải API contract.

## Request

| Field | Rule |
| --- | --- |
| `schema_version` | Explicit integer `2`; no automatic V1 upgrade |
| `conversation_id` | Owned conversation; must match route |
| `request_id` | Idempotency key; changed body with same ID conflicts |
| `expected_revision` | Published conversation revision for CAS/admission |
| `message` | Nonempty, at most 4,000 characters |
| `selected_product_ids` | Optional, at most 5 distinct canonical product IDs; 1 means ANSWER, 2–5 means COMPARE |
| Optional command | At most one of the commands below |

| Command | Required binding |
| --- | --- |
| `confirmation` | `proposal_id`, `proposal_hash`, `target_revision`, `base_requirements_hash` |
| `reference_reply` | Original pending source and offered variant selections; same inner shape as V1 `clarification_reply` |
| `unit_reply` | Original pending source/revision and source-bound unit selections |
| `task_reply` | Original pending source/revision and offered product selections |
| `pending_action` | `action: REPLACE` or `DISCARD`, explicit `target` and binding below |

Pending-action binding:

| Target | Required fields |
| --- | --- |
| `REQUIREMENTS`, `TASKS` | `pending_message_id`, `constraints_revision` from the current clarification |
| `CLARIFICATION` | `pending_message_id = flexible.task_message_id`, `constraints_revision = flexible.constraints_revision` |
| `PROPOSAL` | `proposal_id`, `proposal_hash`, `target_revision`, `base_requirements_hash` from the current proposal |

Replacement clears only the unmerged artifact in working state, preserves accepted
requirements/build and registers the new message under its own request ID. Owner,
current conversation revision and source binding are checked; old history remains.
Requirement/proposal targets must already be published; requirement artifacts must
match the current canonical content hash.
For `REPLACE`, message is a complete new task request. `DISCARD` clears the pending
artifact and publishes a server acknowledgement with `flexible.status: DISCARDED`.
The operational run is `COMPLETED`, but the abandoned task is not marked completed.
Discard invokes no model/tool and preserves canonical requirements and saved build;
stop proof, lineage validation and CAS publication still apply. Neither action can
be combined with confirmation/another reply or inferred implicitly from prose.

Example: confirming an immutable proposal.

```json
{
  "schema_version": 2,
  "conversation_id": "<conversation UUID>",
  "request_id": "<new request UUID>",
  "expected_revision": 4,
  "message": "OK",
  "confirmation": {
    "proposal_id": "<offered proposal UUID>",
    "proposal_hash": "<offered SHA-256>",
    "target_revision": 4,
    "base_requirements_hash": "<offered requirements hash>"
  }
}
```

## Boundaries

- Body contains no owner, checkpoint/thread selector, worker identity or trusted tasks.
- Application takes original task source from the exact accepted waiting state;
  `OK` or a product choice does not replace it.
- Private explicit-user admission receipts are not accepted request commands.
  V2 independently extracts user-sourced proposals and can admit a completely
  resolved matching draft in working state. Publication replays private receipts
  from the accepted/confirmed base; accepted head still changes only after CAS.
  Agent-authored, mismatched or ambiguous changes remain clarification/consent-bound.
  This is model-based semantic assessment, not deterministic proof of intent.
- The selected V2 HTTP route requires explicit `schema_version: 2`; missing or
  invalid versions reject with 422. The internal persisted parser treats absence
  as V1 for existing records. Legacy field names are not V2 aliases.
- Stored canonical JSON omits absent optional commands. V1 payload/hash shape stays
  unchanged; V2 retains its version and complete command binding.
- The only server factory configures V2-only coordinator admission.
  Unsupported coordinator request versions use `AI_REQUEST_VERSION_UNSUPPORTED`.
- V2 cannot publish through the V1 adapter. The internal V2 path revalidates exact
  accepted base/request/context/snapshot, native lineage and drained stop proof
  before fenced head/revision/message CAS. Managed SKU/unit/task-selection pass;
  selected lifecycle recovery also passes SDK timeout after a catalog tool. These
  gates use model/catalog/auth fixtures, not live-provider proof. V2 retries at
  most once, only after stored executor stop ACK; duplicate HTTP requests never
  create recovery execution. Missing/stale cursors can be reconciled after stored
  owning ACK using exact execution metadata and unique validated lineage; ambiguous
  forks stay busy. Process-death recovery remains closed.

## Public view

Create/get returns `schema_version: 2` and nullable `flexible`. Once published,
`flexible` contains status, original task message/ID, canonical constraints revision,
answer, task outcomes and the
pending proposal/clarification options. Proposal confirmation bindings and readable
changes are included. Owner, native checkpoint references, private working state,
execution context and ledger are not exposed.
Completion also includes `products`: selected canonical catalog evidence projected
to public cards, never synthetic variant-to-product IDs. Attachment task bindings
are validated against the stored request before publication.

Responses retain `{data, message, errors}` with static message keys. See
[implementation status](../04-ai/stateful-implementation-status.md) for evidence
and remaining runtime gates.

## Persisted completion events

Lifecycle emission and basic HTTP SSE delivery are implemented. One admission and
one stream per turn; disconnect does not cancel execution. No reconnect offset,
automatic retry or legacy fallback. See [SSE contract](stateful-chat-v1.md#sse-contract).
START/DELTA/ERROR retain V1 event shapes. COMPLETED for a V2 run has
`result.schema_version: 2` and the same public `flexible` projection as GET; build,
answer and published revision come from the validated snapshot, not working state.
No checkpoint references, receipts or ledger. DELTA currently contains the validated
final answer, not unvalidated LLM tokens. Cancel uses ERROR with `AI_RUN_CANCELLED`;
top-level message remains static `AI_CHAT_STREAM_FAILED`.

## Missing structured facts

`INSUFFICIENT_EVIDENCE` may cite exact `fact:` refs with canonical status UNKNOWN
or CONFLICT, plus their `supporting_tool_call_ids`. Server renders model/status/source
from those results, not generated numbers. Internal reasons are `FACT_UNKNOWN` and
`FACT_CONFLICT`; published response/tasks stay UNRESOLVED and saved build is preserved.
A positive answer selecting those facts is rejected. Readable content-only prose
does not prove a fact is absent; this does not claim exhaustive web coverage.

## Multiple requested tasks

The internal final action can use `outcome: MULTI_TASK` and `task_answers` (2..8).
Each entry has `task_index`, `outcome`, `answer` and optional supporting tool IDs.
Indices must cover the registered task list exactly once; entries cannot provide
task kinds/statuses or redefine the request. Application validates each entry using
the existing single-task grounding, optimizer/search and missing-data validators.

Each public task outcome can include its validated `outcome` and `reason`. Overall
status is COMPLETED only when every task completes; otherwise UNRESOLVED. A verified
build is still saved when an unrelated task lacks evidence. Scoped no-solution
evidence does not complete unrelated tasks. Aggregate model prose/evidence is not
published; server combines validated per-task output. `MULTI_TASK` is not a new tool
or an HTTP request command. Historical V1 fixtures do not define a server runtime.
On per-task validation failure, bounded repair feedback includes the failed
`task_indices` and static `TASK_INCOMPLETE` code. The agent corrects its candidate
against the same canonical ledger; feedback cannot redefine tasks or authorize merge.

For an accepted unit/SKU clarification, a plain `message` can select an offered
option without a typed command. The budgeted extractor proposes a source-bound
choice; application validates it and returns pending confirmation for changed
requirements. A genuinely unchanged resolved target continues the original task
without new consent; its state/hash is preserved and final grounding still applies. Unclear replies
keep waiting. This does not interpret plain `OK` as proposal consent: confirmation
still requires the immutable bindings above. Plain messages can also select an
offered comparison product: the original task/other subject bindings are preserved
and products are canonically re-resolved. Unclear replies stay waiting; a selected
unavailable product is not replaced by the remaining match.

When a requirement draft is waiting for unit/SKU clarification, a plain message
may explicitly edit/remove its unmerged items (e.g. `64GB`, `Bỏ RAM`). Valid choice
takes precedence; otherwise the budgeted amender proposes edits. Application binds
new evidence, preserves untouched items, re-resolves and asks confirmation for
changed requirements. It never directly edits already accepted canonical state.
Comparison subject corrections are also supported while task identity is pending.
If no offered choice is selected, the budgeted task amender may propose a new
mention for an explicitly corrected subject. Application validates its evidence,
clears only that subject's binding and canonically re-resolves it; the original
task and other bindings remain. Explicit whole-pending replacement is supported
as above; it supersedes, never mutates, an immutable proposal. Replacing or discarding
a proposal does not accept its old patch.
