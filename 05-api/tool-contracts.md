# Tool and action reference

Internal models: `ai-service/src/ai_service/capabilities/assistant/react/contracts.py`.
11 tools được nối vào managed V2 runtime; không còn cờ enable/version.
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
| research_hardware | model <=300 chars; focus enum; optional question <=500; max_sources 1..2 | ResearchResult: một section với search metadata và pages đã đọc |
| research_compatibility | part_a/part_b <=300; optional concern <=500; max_sources 1..2 | ResearchResult: nguồn về cặp linh kiện; không phải deterministic compatibility certificate |
| research_workload | workload <=300; mode BENCHMARK/REQUIREMENTS; benchmark_kind GAMING/PRODUCTIVITY; <=3 hardware names; optional resolution/preset/upscaling; max_sources 1..2 | ResearchResult + missing_conditions; không tự điền điều kiện đo |
| research_pc_build | optional current-run build_ref UUID; optional distinct slots <=8; question <=500 | ResearchResult: từng core part, canonical build_source_ref và per-subject source status |
| research_driver | component_name <=300; software_type VGA_DRIVER/BIOS_UPDATE/CHIPSET_DRIVER/RGB_CONTROL; optional operating_system/version <=100; max_sources 1..2 | ResearchResult: official-only support pages; no install/download |

Current objective non-null bị reject tới khi versioned policy support.
Budget/revision/requirements, candidates/prices/stock và prior build lấy trusted context,
không model args. Read/compare dùng product ID; optimizer dùng variant/SKU.

ProductEvidence: product_id/name/ACTIVE status, nullable known price_vnd, bounded
specs, evidence_ref/retrieved_at. Missing facts ghi unknown; revalidate visibility.
build_pc cần known budget/use-case, supported/resolved requirements và canonical metadata.

## Trusted context

Không có `register_tasks` trong native runtime. Agent gửi `tool_calls[]` trực tiếp;
application bind/validate task completion từ các calls và canonical outcomes.
Independent business reads được chạy theo batch có giới hạn; state-changing control
chạy riêng. Mỗi native call luôn có matching result; không drop một phần response.

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
  result                        # catalog/detail/comparison/build/search/page/research payload | null
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

## Research results

Args/focus/status enums và limits nằm trong
`capabilities/web_search/research_contracts.py`; result/ledger contracts ở `react/contracts.py`.
`ResearchSourceStatus`: READABLE / NO_RESULTS / UNREADABLE / UNAVAILABLE / SOURCE_UNRESOLVED.
Mỗi section giữ subjects/focus/query, official_source_status và search_steps
(tier/query/target_domains/status/result_urls). Tối đa2 pages/tier; build research
tra mọi core part, tối đa1 page/tier/part; `slots` thu hẹp phạm vi.
Result giữ source_policy_version/hash. Official trước, independent review sau;
specs/requirements dừng sau readable official. UNKNOWN là chưa resolve hãng/publisher,
không tự đoán domain. General-web fallback chỉ khi cấu hình cho phép và scoped
sources chưa đọc được. Driver không mở review/general fallback. Requirements dùng
publisher→STORE_LISTING, không review/general dù fallback config bật. Publisher hoặc
hãng resolve từ application registry, không model args. Registry không phải factuality guarantee.
Mỗi page trả <=2000 ký tự kèm next_offset; đọc tiếp bằng `read_web_page`.

Evidence refs phải đúng các page/fact thực sự trả về, được deduplicate. Không đọc
được nguồn nào thì không có citation evidence. Partial failures giữ từng section;
empty/unavailable research hỗ trợ unresolved outcome, không chứng minh vô nghiệm.
Generic model names chỉ là research subjects. Build subjects lấy từ exact accepted
snapshot hoặc current-run/context-matching, verified optimizer result. Foreign/stale
build refs và slot không tồn tại bị reject; research không sửa requirements/build.

Hardware focus: GENERAL, PERFORMANCE, PRODUCTIVITY, THERMAL_NOISE, MOTHERBOARD,
MEMORY, STORAGE, PSU_QUALITY, PSU_TIER, CASE_AIRFLOW, KNOWN_ISSUES, OFFICIAL_SPECS.

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
CALL_TOOL / PROPOSE_REQUIREMENTS / ASK_CLARIFICATION / FINAL_ANSWER / RESPOND. Requirement
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

`NativeFlexibleModel` accepts plain text or bounded native calls; no JSON action envelope.
Native controls are `propose_requirements`, `ask_clarification`, `submit_result`.
The last selects evidence/build refs by task index; it cannot supply outcome/status.
One selection with `task_index=null` is a grounded response without completing the
pending task. Application derives internal final outcomes and revalidates them.
Control schemas and availability live in `react/control_actions.py`; selection
contract is `react/submissions.py`. RepairFeedback restricts corrective actions;
invalid protocol returns no decision, not a fake answer. Control acknowledgements
are checkpointed separately from business ToolResults, with matched provider pairs.

Model-facing protocol `compact-native-tools-v5` uses `react/model_contracts.py`.
Proposal: `items[{subject,predicate,value,unit?,quote,...}]`, optional source_text only
for agent suggestions requiring consent. Example budget: subject SETUP, predicate
budget, target GOAL, value 25000000, unit VND, operator LTE, exact user quote.
Application binds offsets and resolves/validates once before working merge; no second
LLM requirement extraction. Submit: `results[{text,refs,build_ref?,calls,...}]`;
`quotes`/`review` are available only with readable web evidence. Defaults may be
omitted. Internal domain/evidence/receipt contracts keep their full validation.

FinalAnswerAction also accepts `supporting_tool_call_ids` for failed/empty outcomes
with no fact refs. Internal `FlexibleAnswer(schema_version=2)` has outcome/reason,
response status, original task_outcomes, evidence refs and optional build_ref.
`ConversationResponse` separately contains text/evidence_refs. A response may
coexist with WAITING_INPUT and unchanged pending artifacts; no-business-task turns
have empty task outcomes, not a fabricated ANSWER/BUILD result.
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
