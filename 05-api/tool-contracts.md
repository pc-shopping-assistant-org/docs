# Tool and action reference

Internal models: `ai-service/src/ai_service/capabilities/assistant/react/contracts.py`.
Sáu tools được nối vào managed V2 runtime; không còn cờ enable/version.
Policy/protocol: [agent](../04-ai/agent-tools.md).
ToolResult schema version1 vẫn được dùng trong V2 action/runtime, không có nghĩa HTTP V1.
Public transport: [HTTP V2](stateful-chat-v2.md), [shared SSE](stateful-chat-v1.md#sse-contract).

## Args và payloads

Tất cả DTO strict/extra=forbid. Money là nonnegative integer VND; UUID là reference,
không authorization.

| Tool | Args | COMPLETED payload |
| --- | --- | --- |
| search_catalog | query nonblank <=1000 chars; strict limit 1..20, default 10 | CatalogResult: <=20 ProductEvidence |
| get_product_details | product_id UUID | DetailsResult: ProductEvidence |
| compare_products | distinct product_ids 2..5; optional question <=1000 chars | ComparisonResult: đúng requested subjects |
| build_pc | objective optional BuildObjective | BuildResult: server build_ref, BuildReceipt, SatisfactionReport |
| search_web | query <=1000 chars; limit 1..10 | SearchWebResult: title/url/snippet, không citation evidence |
| read_web_page | url <=2000 chars; offset >=0; max_chars 1..16000 (default 12000) | ReadWebPageResult: bounded content, next_offset/total_chars, source hash và segment evidence ref |

Current objective non-null bị reject tới khi versioned policy support.
Budget/revision/requirements, candidates/prices/stock và prior build lấy trusted context,
không model args. Read/compare dùng product ID; optimizer dùng variant/SKU.

ProductEvidence: product_id/name/ACTIVE status, nullable known price_vnd, bounded
specs, evidence_ref/retrieved_at. Missing facts ghi unknown; revalidate visibility.
build_pc cần known budget/use-case, supported/resolved requirements và canonical metadata.

## Trusted context

Current ToolContext: account/conversation/run IDs, canonical requirements,
bounded catalog, read_catalog_allowed, execution_allowed.
Runtime extension: execution incarnation/generation, cancel/deadline, attempt boundary,
policy versions. Các authority fields/JWT/DB session không thuộc bind_tools/public DTO.

## Result and error contract

```text
ToolResult
  schema_version=1
  tool_call_id, tool, status
  input_hash                    # canonical args/context SHA-256
  constraints_revision
  result                        # CatalogResult | DetailsResult | ComparisonResult | BuildResult | SearchWebResult | ReadWebPageResult | null
  error                         # ToolError | null
  evidence_refs                 # bounded, distinct
```

| Status | Invariant |
| --- | --- |
| COMPLETED | Matching discriminated payload; error=null |
| REJECTED / FAILED | result=null, không success evidence; static error bắt buộc |

Build INFEASIBLE là completed computation, không tool execution failure.
Current ToolError: BAD_ARGUMENTS / UNKNOWN_TOOL / PREREQUISITE_MISSING /
PRODUCT_NOT_FOUND / CATALOG_UNAVAILABLE / WEB_SEARCH_UNAVAILABLE.
Search không có matches là COMPLETED với results=[]; nguồn bị chặn/lỗi/layout
không nhận diện là FAILED / WEB_SEARCH_UNAVAILABLE. Snippet không sinh evidence.
Runtime cancel/budget/provider errors cần explicit application mapping; không giả enum
variant hoặc leak SDK exception.

ToolResult là internal observation. HTTP/SSE vẫn dùng {data, message, errors}, message static.

## Answer extension

Current AnswerCandidate includes text/evidence_refs/build_ref/clarification_fields/
web_excerpts and evidence-linked qualitative explanation; exact fields are in source.
WebExcerpt: selected evidence_ref và exact quote 1..2000 chars; tối đa 8 excerpts.
Web-only không publish unrestricted text: server render matching quotes và nguồn,
đánh dấu chưa xác thực facts. Nội dung quote không tự thỏa mãn BUILD/COMPARE.
Target full GroundedClaim extension còn backlog. Targeted clarification và accepted
saved-build completion đã có; không nhầm schema extension với capability thiếu.
Semantics ở [grounding](../04-ai/agent-tools.md#grounding-and-completion).

Library helpers không tự thành ReAct tools. V2 không expose cart/checkout/payment
mutations chỉ vì đã có helper. Thiếu canonical adapter thì fail closed, không sample facts.

## Flexible V2 contracts — server runtime

`react/actions.py`: FlexibleDecision(schema_version=2, action), discriminated by
CALL_TOOL / PROPOSE_REQUIREMENTS / ASK_CLARIFICATION / FINAL_ANSWER. Requirement
proposal cannot replace tasks; no owner/hash/merge authority fields in model action.
RepairFeedback has static code, missing/evidence refs and allowed next actions.
It can include `task_indices` (0..7, at most 8) from application validation to target
multi-task repairs. No adapter exception prose or model-supplied completion authority.
`INSUFFICIENT_EVIDENCE` can select canonical UNKNOWN/CONFLICT fact refs and their
unique supporting tool call IDs. `FACT_UNKNOWN`/`FACT_CONFLICT` remain unresolved;
server renders only typed status/model/source. SUPPORTED facts, readable prose and
unrelated references do not support this missing-fact outcome.
`MULTI_TASK` uses exact registered task indices and per-task final payloads, with
the same single-task outcomes/evidence rules. No nested MULTI_TASK, omitted/duplicate
indices, aggregate evidence or model-supplied task kinds/statuses. Application
combines canonical outputs and publishes a verified build even if another task is
unresolved. Public per-task outcome/reason are projections, not a second ledger.

`requirements/proposals.py`: server-issued immutable pending payload binds owner,
conversation, patch/source evidence, target_revision and base_requirements_hash.
ProposalConfirmation repeats proposal_id/hash/target_revision/base_requirements_hash;
confirmation verifies current content/ownership and returns patch without publishing.
Owner/source_messages are internal, not a public response projection.

`react/search_evidence.py`: application-owned search metadata binds scope, requirements/
input/catalog hashes and algorithm/pruning/policy versions. Outcomes FEASIBLE /
INFEASIBLE / SEARCH_INCOMPLETE must match declared completion/coverage/pruning and
termination. Metadata validation alone is not proof of actual search correctness.

`NativeFlexibleModel` supports V2 native CALL_TOOL and JSON non-tool actions;
JSON CALL_TOOL is rejected to preserve provider protocol. RepairFeedback restricts
allowed corrective actions; invalid output returns no decision, not a fake answer.
The adapter does not authorize merges or certify final outcomes.

FinalAnswerAction also accepts `supporting_tool_call_ids` for failed/empty outcomes
with no fact refs. Internal `FlexibleAnswer(schema_version=2)` has outcome/reason,
response status, original task_outcomes, evidence refs and optional build_ref.
Empty search/unavailable source can end a turn while tasks remain UNRESOLVED;
typed result refs, not model prose, justify the server-rendered response.
Shared persisted contracts giữ version gốc; HTTP/publication của server chỉ dùng V2.
Internal search answers include validated search_evidence and SCOPED_EXHAUSTION /
INCOMPLETE_SEARCH reason. Proven scoped absence completes only requested BUILD;
incomplete search leaves tasks unresolved. Server re-derives report before rendering;
legacy no-result labels cannot supply proof. Managed V2 publication is implemented;
this metadata does not replace its grounding/lineage/stop/CAS validation.

Internal reference_reply reuses ClarificationReplyV1 (source message + offered item/
variant IDs), but pending artifact is owner/content/publication-bound PendingResolution
V2. Resolving it creates a separately confirmed proposal; it is not a merge command.
Không nhận public V1 request hoặc migrate ngầm unscoped pending drafts.
Internal unit_reply reuses UnitClarificationReplyV1; number comes from the frozen
draft and unit from an exact span in the current full user message. It resolves the
draft into a separately confirmed proposal, not a merge. Do not combine reference/
unit/confirmation commands; public mapping is in the V2 HTTP reference.
ToolRecord origin_run_id is application provenance, not a tool argument. Current
facts require current-run origin; history is not re-labelled. PreparedAnswerPublication
V2 contains validated snapshot/answer but is not a CAS instruction or public endpoint.
Confirmation-bound changes are prepared only using an accepted-store proposal and
stored command, never the producer's working state as authority. Historical amounts
remain unchanged and become stale. PreparedWaitingPublication validates one new or
continued pending artifact/question against stored commands; status WAITING_INPUT,
snapshot preserved, task outcomes UNRESOLVED. It is internal, not public API or CAS
authority. Exact accepted confirmation also binds changed waiting state; asking the
next question does not complete the original task. Coordinator CAS and selected V2
API are implemented; verification records stay in the status page.

Shared versioned contracts/envelope remain unchanged. The server uses V2 and requires
supported saved-state versions; do not reinterpret legacy INFEASIBLE as certified
or old revision as content hash.
