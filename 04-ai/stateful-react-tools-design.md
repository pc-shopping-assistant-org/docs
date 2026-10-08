# Thiết kế review — Stateful ReAct Agent + Tools

- Ngày: 2026-10-08.
- Revision: 7 — không đổi kiến trúc; bổ sung implementation/review evidence 2026-10-09.
- Phạm vi: UC-AI-001/003 và guided PC build.
- Trạng thái: **DESIGN FOR REVIEW**; có internal tool/graph source, chưa live ReAct runtime verified. Implementation tạm dừng để owner review.
- Stack đã chốt: LangGraph + Pydantic + PostgreSQL + AsyncPostgresSaver.
- Không dùng PydanticAI, Mem0, pgvector hoặc memory xuyên conversation ở V1.
- Plan chính: [Stateful chat implementation](stateful-chat-implementation-plan.md).
- Hiện trạng implementation: [Status và evidence](stateful-implementation-status.md).
- Contracts hiện có: [B0](stateful-chat-contracts.md), [API V1](../05-api/stateful-chat-v1.md),
  [AI application DB](../03-data/ai-stateful-schema.md).

## 1. Quyết định kiến trúc

Chọn **một bounded ReAct loop bên trong một LangGraph**, kết hợp các bước
deterministic. Agent quyết định cần tìm sản phẩm, xem chi tiết, so sánh, build hay
hỏi thêm; application/domain quyết định authorization, merge, compatibility,
budget, provenance và publish. Không tạo agent/runtime thứ hai trong graph node.

ReAct ở đây là vòng tool-calling: model yêu cầu action, tool trả observation,
model quyết định tiếp. Không yêu cầu, lưu hay gửi ra FE suy luận nội bộ của model.
LangGraph hỗ trợ workflow cố định và agent chọn tool động;
[tài liệu chính thức](https://docs.langchain.com/oss/python/langgraph/workflows-agents).

```text
FE / Gateway
    ↓ RS256 access JWT
FastAPI → StatefulChatApplicationService
              │ authorize / idempotency / exclusive execution claim
              ↓
       LangGraph — thread = conversation_id
       ├─ begin_turn → extract_requirements → resolve_product_mentions → validate_merge
       ├─ agent ── tool request ──→ validate_action → execute_tool
       │    ↑                                        │
       │    └────────── checkpointed observation ─────┘
       ├─ clarification / final-answer candidate
       └─ validate_result → validate_completion → prepare_publish → native terminal checkpoint
              ↓
       Application finalizer (lineage + fence + CAS)
              ↓
       accepted head / assistant message / published result
```

Tool adapter gọi catalog/application services. Graph chỉ orchestration; optimizer
không import LangGraph, LangChain, DB session hay HTTP DTO. Chưa triển khai
multi-agent supervisor, autonomous background planning hoặc tool marketplace;
managed execution supervisor ở section 7.1 không phải một agent runtime thứ hai.

## 2. Hiện trạng và ranh giới P2

| Thành phần | Hiện trạng source | Gate còn lại |
| --- | --- | --- |
| AI application DB | Alembic through 0002, scoped FK/checks; owner báo native pass 2026-10-09 | Run coordinator integration |
| Checkpointer | Pool/bootstrap riêng, explicit accepted-ref adapter; owner báo orphan/reopen pass | Initial-root recovery/lineage publish |
| Owner/auth | Async store, RS256 verifier, create/get endpoints opt-in | Native runtime/JWKS environment verification |
| Lifecycle | Resource readiness/reopen gate owner báo pass; không tự migrate/setup | Live HTTP/JWKS environment verification |
| ReAct | Strict contracts/dispatcher và internal LangGraph loop source; 4 tool tests pass | Graph verification, provider/tool protocol adapters và runtime wiring |
| Recovery/publish | Pure retry/stop guards | P4 coordinator, lineage validator và fenced transactions |

Owner báo migration, bootstrap và toàn bộ integration_tests pass ngày 2026-10-09;
ISSUE-091 RESOLVED. P2 vẫn IN PROGRESS cho phần integration còn lại; native gates
không chứng minh live JWKS/provider hoặc coordinator đã chạy. Root native experiment
riêng được owner báo pass; production initialization/recovery vẫn chưa có.
Existing legacy chat chưa dùng DB mới.

## 3. Memory V1: persistent nhưng không xuyên conversation

| Dữ liệu | Chủ sở hữu | Source of truth |
| --- | --- | --- |
| Owner, run, request hash, revision, execution slot | Application | AI application PostgreSQL tables |
| Published message history | Application | conversation_messages |
| Domain constraints, owned/pinned, previous build | Domain state | Exact accepted native checkpoint |
| Agent/tool messages, observations, pending execution | LangGraph | Working checkpoint + native tasks/pending writes |
| Public current build | Guarded presenter | public_build channel tại accepted checkpoint |

Một conversation = một stable root thread; nhiều runs trên thread đó.
Latest framework checkpoint **không phải** public conversation state. Public
GET đọc accepted ID sau owner lookup; recovery đọc exact working ref của run.
Không copy snapshot.values sang thread mới để giả lập recovery.

Prompt window khác persistent history: chỉ đưa phần gần đây + domain state +
evidence cần thiết vào model; không xóa history vì prompt đầy. Có thể thêm summary
theo phase sau, nhưng summary không thay constraints/evidence hay completion hashes.
Trong V1, summary nếu có chỉ thuộc conversation, không tạo user profile xuyên thread.
Phân biệt thread memory và cross-session memory theo
[LangGraph memory](https://docs.langchain.com/oss/python/langgraph/add-memory).

Giữ retention đã chốt: chat/run/checkpoint 90 ngày, true orphan/debug 7 ngày;
không purge accepted/recoverable ancestor dựa riêng vào tuổi checkpoint. Delete
conversation phải stop/drain rồi purge application + saver + event/snapshot data.
Mem0/pgvector chỉ xét sau khi có requirement memory xuyên conversation, consent,
ownership, sửa/xóa và retention rõ ràng.

## 4. State và trust boundary

### 4.1. Graph state đề xuất

TypedDict/reducers là adapter LangGraph. Payload ở mỗi boundary phải validate
bằng Pydantic; serialized ConsultationStateV1 giữ schema_version=1 hiện có.

| Channel | Shape / semantics |
| --- | --- |
| requirement_state | Proposed CanonicalRequirementStateV1, nguồn chuẩn nhu cầu sau atomic merge |
| consultation | Existing stage/result/history bookkeeping; legacy constraints become compiled projection, không update độc lập với requirement_state |
| messages | Model-facing representation, không phải execution truth; stable IDs và tool_call_id correlation |
| current_run_id | Server UUID, reset theo run mới; không từ model |
| turn_input | Validated TurnRequestV1, request/message identity do application cấp |
| phase | Enum: EXTRACTED, REFERENCES_RESOLVED, MERGED, AGENT_READY, TOOL_PENDING, TOOL_COMPLETED, READY_TO_PUBLISH |
| requirement_draft / resolution | Typed untrusted extraction + canonical resolution/clarification; chưa là hard constraints |
| completion_requirement | Validated application CompletionRequirementV1; không do final-answer model tự đổi |
| catalog_evidence | Normalized canonical catalog snapshots + retrieval times/hash/version |
| selected_action | Validated agent action; tối đa một pending tool call ở V1 |
| tool_results | Canonical execution ledger duy nhất của current run, key theo tool_call_id; typed ToolResultV1 |
| counters | Checkpoint projection của durable call-budget ledger + absolute deadline; không là budget authority |
| answer_candidate | AnswerCandidateV1, chưa được coi là validated/public cho tới validate_result |
| public_build | PublicBuildV1 hoặc explicit null; P2 reader yêu cầu channel hiện diện |
| publication_input_hash / payload_hash | App-computed digests; model không được cấp giá trị |

optimization/explanation completion markers nằm trong consultation, dùng lại
StageVersionsV1 + semantic input hash hiện có. READY_TO_PUBLISH chỉ do guard
node gán sau khi output/evidence hợp lệ. ReAct phase không thay RunStatus.

**Single source of truth:** tool_results chính là checkpointed execution ledger,
không có collection ledger khác được cập nhật độc lập. ToolMessage chỉ được tạo
bởi deterministic projection từ validated ToolResultV1 đã commit. Observe không
thực thi lại tool; stable message ID cho phép upsert/idempotent projection khi
resume. Kết quả/message lệch nhau → reject hoặc regenerate representation từ
ledger; không dùng message để sửa canonical result. P5 audit/event journal là
projection cho delivery, không cạnh tranh quyền sở hữu outcome/evidence.

### 4.2. Run mới và resume

- Run mới: authorize → claim base revision/ref → explicit accepted config + new
  input + server metadata; durability=sync. begin_turn reset pending action,
  current-run tool ledger/counters/answer/publish hashes, không xóa domain state.
- Message ID lấy từ application message identity để reducers không duplicate.
- Completion marker cũ chỉ reuse khi hash/versions còn khớp, không dựa result != null.
- Resume: input=None từ exact working config; **không chạy begin_turn/reset state**.
  Cancellation/heartbeat được kiểm tra trước model/tool và trước finalize.
- Checkpoint source=input có thể giữ values của run trước trước START; P4 kiểm
  tra server metadata + native input boundary, không suy run ownership từ values.run_id.
- P4 phải stamp và kiểm tra metadata do server tạo: app_execution_id,
  app_worker_instance_id, app_generation, app_base_revision, app_request_hash.
  Metadata run/base checkpoint/input hash/graph version của adapter P2 chưa đủ
  để chứng minh attempt ownership hoặc fencing.
- Revision zero và thread đã có orphan: adapter hiện fail closed. Chỉ recover run
  gốc khi đủ điều kiện; đường new-turn sau terminal first-run failure là điểm
  review ISSUE-092, chưa tự purge thread hoặc suy latest là empty root.

### 4.3. Quyền sửa requirements

LLM không trực tiếp gọi setters hoặc tự gán USER/SYSTEM/locked/confidence.
extract_requirements trả RequirementDraftV1; chỉ sau resolution mới tạo requirement patch:
absent giữ nguyên, SET thay giá trị, CLEAR xóa.
Trusted application kiểm chứng evidence/confirmation rồi gọi apply_turn_patch.
Giá, specs, quantity và slot binding phải resolve từ backend, không lấy từ prompt.
Ambiguous budget/owned/pinned selection → hỏi user. Không tự giải khóa field hay
thay linh kiện pinned để optimizer dễ tìm build.

Cần formalize ExtractionEvidenceV1 trong P3: field path, source message ID, evidence
span/value, resolved candidate IDs và confirmation. Schema extraction không tự
chứng minh source=USER. Until that gate passes, ambiguous bindings cannot become
hard constraints (ISSUE-093). UI structured confirmation là một contract extension phải được
review riêng; không âm thầm thêm mutation fields vào TurnRequestV1 hiện tại.

### 4.4. Natural-language part references trước merge (P3-A)

```text
RequirementDraftV1
  operations: typed sparse goal/requirement/resource operations (absent / SET / CLEAR)
  part_mentions: list[PartMentionV1]
  requested_outcome: provisional task requirement + source evidence

PartMentionV1
  mention_id: server-bound identity
  operation: SET | CLEAR
  binding_target: stable requirement/resource ID + field path
  slot: allowlisted component slot
  text: user mention (SET only)
  source_message_id + source_span: extraction evidence

PartResolutionV1
  mention_id
  status: RESOLVED | AMBIGUOUS | NOT_FOUND | METADATA_INSUFFICIENT
  candidates: bounded canonical variant refs + distinguishing typed fields
  resolved_variant_id: UUID | None (only RESOLVED)
  evidence_refs: canonical resolution evidence
```

Model không có field để invent UUID trong mention. Resolver là application service
dùng canonical search/detail port và normalized exact attributes (brand/model,
capacity/color/slot), không chấp nhận search rank/confidence là uniqueness proof.
Product-level match chưa đủ: phải resolve đúng variant/SKU. “RTX 5070 Ti ASUS TUF”
có nhiều variant phù hợp → AMBIGUOUS, hỏi user chọn với bounded canonical options;
không lấy top-1 hay cheapest. Không match/thiếu metadata → hỏi thêm, không fake UUID.
Refs trực tiếp từ UI vẫn phải verify canonical identity/slot/quyền, không bypass resolver.

Resolution dùng cùng visibility/evidence/call-reservation boundary như tools nhưng
là deterministic pre-agent node; không cần chờ model chọn search tool. Các CLEAR
không cần lookup tên; phải giữ invariant lock/provenance của merge hiện có.
Only verified resolution + source evidence → trusted requirement patch/atomic merge.
Legacy TurnPatchV1 mapping nằm trong compiler adapter, không là canonical state.
Một mention chưa resolve → chưa apply nửa patch: giữ draft và prior consultation,
terminal clarification nêu đúng missing/disambiguation field. Follow-up dùng accepted
pending draft + new user evidence; tái kiểm tra candidates, không giữ nhầm lựa chọn.
User sửa/hủy yêu cầu thì replace/clear pending draft theo explicit patch semantics.
Pending draft được publish như waiting context, không phải optimizer input/locked state.

### 4.5. Capability constraint không phải SKU pin (P3-A / P3-B)

Không ép mọi component phrase qua OWNED/PINNED resolution. Extraction giữ semantics
người dùng, source evidence và typed operation; model confidence/mention specificity
không tự nâng preference thành constraint hoặc pin. Không âm thầm bỏ requirement
khi hiện tại schema/optimizer chưa biểu diễn được.

| User requirement | Kind | Binding / optimizer effect |
| --- | --- | --- |
| RAM 32GB | HARD_CAPABILITY | Capacity predicate trên canonical RAM candidates; không khóa SKU |
| SSD 1TB | HARD_CAPABILITY | SSD media + nominal capacity predicate; không chỉ chọn bất kỳ storage 1TB |
| Ưu tiên RTX 5070 Ti | SOFT_PREFERENCE | Canonical GPU model/family preference để ranking; không bắt buộc mọi build dùng nó |
| Giữ đúng ASUS TUF RTX 5070 Ti OC | EXACT_PIN | Resolve đúng variant trước merge; ambiguous hỏi lại, không đoán |
| Tôi đã có linh kiện này | OWNED | Resolve owned ref, budget treatment theo owned rules; không suy owned từ từ “ưu tiên” |

Approved canonical model thay draft types theo từng ví dụ; không generic expression DSL:

```text
CanonicalRequirementStateV1
  schema_version + constraints_revision
  goals
  requirements: list[RequirementV1]
  available_resources
  resolved_bindings
  unresolved

RequirementV1
  id: stable server-bound ID
  subject: typed selector (setup / component / workload)
  predicate: allowlisted semantic key + operator
  value: typed quantity/unit | canonical reference | typed enum/text value
  strength: HARD | SOFT
  source_evidence: validated user-message evidence

RequirementPatchV1
  operations: typed SET | CLEAR by stable goal/requirement/resource identity
  # absent preserves; SET needs value; CLEAR has none; atomic application
```

Combinations subject/predicate/operator/value được semantic registry validate;
không Any, raw expression/regex hoặc arbitrary attribute access. Keys có thể thêm
qua versioned capability registry, không tạo một class cho mỗi câu ví dụ. Goals
là desired outcomes; resources là fact user đã có, không tự buộc chọn. Muốn dùng
resource phải có requirement/binding xác nhận; compiler mới tạo owned_parts cho
selected resource (spending=0). Hard identity requirement compile thành pinned_parts,
không dùng PINNED như một nhóm câu ngôn ngữ riêng. Goals resolution/FPS không tự
biến thành benchmark promise. Nếu chưa model được resource không có catalog identity,
giữ unresolved/unsupported, không fake ref.

Đây là versioned state/merge/compiler extension, chưa có trong
TurnPatchV1 hiện tại. Không gửi model draft trực tiếp vào optimizer. SET yêu cầu
typed value; CLEAR không có value; absent giữ nguyên. Capacity operator và unit
phải rõ: “ít nhất” → GTE, “đúng” → EQ; khi không rõ exact/minimum thì clarify,
không tự nới thành GTE. Dùng normalized nominal-capacity metadata có unit evidence,
không coi TB/TiB hoặc total RAM/one module là tương đương không cần kiểm chứng.
V1 RAM predicate áp dụng tổng dung lượng selected kit; nhiều kit/modules hay nhiều
ổ không được giả bằng một SKU nếu inventory/optimizer chưa model. SSD predicate
yêu cầu verified media type và dung lượng của selected drive.

Compiler thuần trả RequirementMappingV1 cho **mọi** requirement:
APPLIED / NEEDS_CLARIFICATION / UNSUPPORTED / CONFLICT, giữ HARD/SOFT riêng,
với requirement_id, canonical bindings, static reason và compiler/policy version.
Không có success result bỏ qua một requirement trong draft. Unsupported hoặc
ambiguous → targeted response/WAITING_INPUT; giữ pending draft, không báo INFEASIBLE
hay build thành công với requirement bị mất. User muốn bỏ/đổi requirement thì phải
có explicit confirmation/new patch; không dùng generic fallback để tự relax.

- Hard predicates filter canonical candidates **trước pruning**, kiểm tra cả pinned
  và owned selected parts, rồi validate lại final optimizer result. Empty feasible
  space chỉ là INFEASIBLE khi các requirements đã support/map đúng và metadata đủ.
- Soft preference chỉ ảnh hưởng deterministic scoring/ranking, không feasibility;
  policy weight do server versioned. Không đáp ứng preference vẫn có thể là valid
  build, nhưng phải disclose preference unmet + typed reason. Nếu scorer chưa
  support model preference → UNSUPPORTED, không nhận rồi lờ đi.
- EXACT_PIN bắt buộc variant identity, vẫn tính tiền; hard capability và pin mâu
  thuẫn → CONFLICT/clarify, không thay pin hoặc drop constraint để có nghiệm.
- Hash/provenance và completion gate bao gồm requirement kinds, predicates/units,
  normalized preference refs, mapping outcomes, scoring/compiler versions và unmet
  preferences. Thay RAM/SSD/preference phải invalidate đúng marker/replay inputs.

Current source evidence: ConstraintsPatchV1/ConsultationConstraintsV1 và
PCBuildConstraints chỉ có budget/use case/resolution/FPS/brand/form-factor cùng
owned/pinned refs. RAM capacity, SSD media/capacity và GPU-model preference chưa
có dedicated fields/mapping. Không tận dụng preferred_gpu_brand bằng cách nhét
“RTX 5070 Ti” vào brand string hoặc locked flag. Support registry tối thiểu là
static allowlist predicate → normalizer/compiler/scorer + version; không plugin
discovery/framework. ISSUE-099 theo dõi extension và core rejection coverage.

### 4.6. Approved build pipeline và satisfaction report

```text
User message → LLM Requirement Draft → Reference / Unit Resolver
→ Atomic Requirement Merge → Canonical Requirement State
→ Requirement Compiler (versioned) → Optimizer Input
→ Existing Deterministic Optimizer → Satisfaction Verifier → Grounded Explanation
```

Pre-agent xử lý draft/resolve/merge đúng một lần mỗi user turn. build_pc nhận
canonical state qua trusted context và chạy compiler/optimizer/verifier; agent vẫn
chọn read tools linh hoạt, không bypass pipeline hoặc mutate requirements trong tool.
CompiledRequirementInputV1 giữ canonical-state hash/revision, compiler/schema/policy
versions, optimizer input và exhaustive mapping report; input là projection có thể
rebuild, không một source-of-truth thứ hai. Unsupported/ambiguous/conflict đi nhánh
phản hồi rõ/clarification, không optimizer success giả. Existing optimizer giữ nguyên
core; adapter filters/scorers chỉ cho supported capabilities và evidence thực sự.

SatisfactionReportV1 giữ state/result hashes và mỗi requirement_id:
SATISFIED / UNSATISFIED / UNKNOWN / NOT_EVALUABLE, strength, evidence refs và static
reason; goals/resources có outcome/binding coverage tương ứng. Hard UNSATISFIED/
UNKNOWN/NOT_EVALUABLE không publish feasible build success. Supported soft unmet
không làm build infeasible nhưng phải disclose. INFEASIBLE của optimizer và missing
metadata/unsupported semantics là các outcome khác nhau, không trộn thành một.

Verifier đọc canonical requirements + normalized evidence/result, không chỉ đọc
compiled input hoặc compiler verdict; mapping thiếu requirement/hash mismatch cũng
reject. Không gọi compiler lại như oracle để “verify chính mình”; dùng invariant
checks và independent expected-outcome tests, gồm deliberately faulty compilation.
Grounded explanation chỉ dùng verified report/build; completion/publish gates giữ
nguyên. Checkpoint optimize success rồi verifier/explain lỗi không chạy optimize lại
khi input/version hashes khớp; state/requirements đổi thì invalidate đúng stages.

Scope đồ án: finite typed registry + pure compiler/verifier, không rule-engine,
plugin/DSL framework hay optimizer mới. Migrate legacy contracts/checkpoint state
bằng explicit schema version, không tự biến old constraints thành new semantics.

## 5. Agent protocol và execution graph

### 5.1. Model boundary

Provider adapter dùng model.bind_tools cho native tool calling của OpenAI/Gemini.
Pydantic cung cấp args schemas; normalized model result đi qua application guard.
Không dùng textual ReAct parser, exec/eval, automatic tool discovery hoặc tên tool
được import theo input. Không log bearer/API key, system secrets hay hidden reasoning.

Một model response là một trong:

1. Một allowlisted tool request, chưa có public final result.
2. Final answer candidate, không có tool call.
3. Clarification candidate + typed missing-field reasons, không có tool call.

Mixed final+tool request không được gửi final ra FE; normalize thành tool branch
hoặc reject theo adapter policy. Multiple tool calls bị reject/repair toàn response
trong V1, không âm thầm chỉ thực thi call đầu tiên. Schema/provider error có retry hữu hạn.
Nếu provider không support approved tool calling, fail capability rõ ràng;
không fallback sang agent giả chạy bằng text parsing. Legacy deterministic chat
fallback vẫn là đường riêng, không được đánh dấu ReAct success.

#### Provider message protocol V1

- Adapter/model hỗ trợ thì bind parallel_tool_calls=False; capability được kiểm
  tra trên pinned integration/model, không gửi option không hỗ trợ cho Gemini.
  Response vẫn phải validate sau khi hoàn tất stream và assemble tool-call chunks.
- Một valid call có name/args/ID hợp lệ mới được commit thành pending action.
  Rejected multi-call/malformed response không append vào canonical messages:
  giữ last valid transcript, retry/repair toàn response với instruction one-call.
  Không gửi AIMessage chứa hai calls kèm chỉ một ToolMessage ở request tiếp theo.
- Rejected response chỉ có sanitized audit/call-attempt record, không execution
  ToolResult thành công. Repair là model call mới, phải reserve budget mới.
- Accepted AIMessage có một call chỉ được follow-up bằng matched ToolMessage từ
  ledger, kể cả result REJECTED/FAILED. Crash trước observe → project lại từ ledger.
  Không cắt nửa AI/tool pair khi trim history; không gọi model với unresolved pair.
- Các provider-specific normalization phải có contract tests cho valid pair,
  multi-call reject/repair, malformed/duplicate ID và chunk assembly. Không ép
  protocol của provider này lên provider khác hoặc dùng text parser fallback.

Tham khảo: [LangChain model tool calling](https://docs.langchain.com/oss/python/langchain/models#parallel-tool-calls).

### 5.2. Nodes

| Node | Trách nhiệm | Không được làm |
| --- | --- | --- |
| begin_turn | Input identity/reset ephemeral run state | Suy latest là accepted |
| extract_requirements | Typed draft/scalar patch/mentions và source evidence | Tự gán trusted provenance hoặc đoán variant UUID |
| resolve_product_mentions | Canonical owned/pin variant hoặc model-family binding; normalize capability units | Ép capability/preference thành PINNED hoặc chọn top-1 ambiguous |
| validate_merge | Business validation, atomic merge, invalidate markers | Ghi conversation head |
| agent | Resolve allowed_tools theo state/context rồi bind; chọn tool hoặc final/clarification | Expose toàn bộ registry bất kể state; tự gọi HTTP/DB |
| validate_action | Registry/schema/capability/preconditions/counters | Tin owner/run IDs từ tool args |
| execute_tool | Một tool invocation, checkpoint result | Bundle nhiều tool calls/LLM calls trong cùng node |
| observe | Project committed ToolResultV1 thành matched ToolMessage rồi quay agent | Cập nhật outcome/evidence độc lập với ledger |
| validate_result | Grounding, outcome, public projection và answer validation | Coi prose của LLM là SKU facts |
| validate_completion | Match terminal outcome với yêu cầu application đã validate | Coi câu trả lời đúng facts nhưng không làm task là success |
| prepare_publish | Hash typed result, READY_TO_PUBLISH | Publish hoặc release execution slot |

Clarification là terminal graph output cho turn hiện tại, RunStatus.WAITING_INPUT
khi được finalize. Không giữ coroutine/lease chờ người dùng nhiều giờ. New message
tạo run mới từ accepted terminal checkpoint sau verified stop/drain.

## 6. Tool registry và contracts V1

Tất cả tool args/output extra=forbid; money là strict integer VND không âm,
UUIDs là references chứ không phải quyền truy cập. Các bounds dưới đây là
**đề xuất operational defaults để review**, không đổi business rules.

ToolContext do server inject: account_id, conversation_id, run_id, execution identity,
constraints_revision, validated consultation, cancellation/deadline và policy versions.
Không hiện các field đó trong schema model.bind_tools. Không truyền DB session
hoặc JWT vào model. Dispatcher xác thực context còn quyền trước mỗi external call.

### 6.1. Tool catalog

| Tool | Args model đề xuất | Result model / service | Preconditions |
| --- | --- | --- | --- |
| search_catalog | query: nonblank <=1000; limit: strict int 1..20 | CatalogSearchResultV1; canonical retriever | Valid owner/run, remaining budget |
| get_product_details | product_id: UUID | ProductDetailsResultV1; canonical backend client | ACTIVE/visible product; variant status rechecked |
| compare_products | product_ids: distinct UUID list 2..5; question?: <=1000 | ComparisonEvidenceV1; reuse comparison application service | Resolve từng product; missing fields remain unknown |
| build_pc | objective?: existing BuildObjective | BuildToolResultV1; grounded preparation + PCBuildApplicationService | Budget/use case known; canonical SKU/specs + owned/pinned resolved |

V1 giữ đúng 4 tool names; bỏ adjust_build trước implementation, không cần alias.
build_pc xử lý cả tạo mới và điều chỉnh theo requirements đã merge. Application
đọc prior build/constraints_revision từ trusted ToolContext và tự quyết định reuse
hoặc optimize lại bằng hash guards. Model không truyền expected_constraints_revision,
arbitrary patch/prices/candidates/slot overrides. objective chỉ là optimization
hint được validate theo policy, không được override objective/locks đã chốt với user.
Chưa có cart/checkout/payment/file/shell/browser tools hay tool ghi long-term memory.

#### State-aware tool exposure

Static registry định nghĩa capability, không đồng nghĩa mọi tool đều được expose.
Một hàm thuần tool_policy.resolve(phase, consultation, current_build, principal)
trả ordered subset của ToolName. Không yêu cầu hard intent classification.
Agent bind đúng subset ở **mỗi vòng**, không chỉ lần đầu. Resolve dùng trusted
state/context; model không được gửi principal hay allowed_tools.

- Budget/use_case chưa rõ → hide build_pc, ưu tiên clarification.
- Không có previous build vẫn được build_pc nếu business prerequisites đủ.
- Build state chưa đủ prerequisites cho normalization/owned/pinned → chỉ expose
  search/get phù hợp để lấy evidence hoặc hỏi thêm, chưa expose build tools.
- Các read tools vẫn được expose theo capability/quyền; model linh hoạt search,
  get hoặc compare. Tool args và canonical visibility được kiểm tra ở dispatch.
- Phase không cho execution, principal thiếu quyền, cancelled/deadline hết → không
  expose tools; chuyển terminal/error branch theo run policy.

Không có allowed tools vẫn có thể tạo grounded final/clarification. Exposure là
optimization, **không thay authorization**: validate_action và dispatcher resolve
lại policy + prerequisites ngay trước execution. Call không thuộc subset, kể cả
model giữ tool schema cũ → REJECTED, không invoke handler; repair có giới hạn.

### 6.2. Observation envelope (internal, khác HTTP envelope)

```json
{
  "schema_version": 1,
  "tool_call_id": "provider-call-opaque-id",
  "tool": "build_pc",
  "status": "COMPLETED",
  "input_hash": "<sha256>",
  "result": {"outcome": "INFEASIBLE", "build": null, "reasons": []},
  "error": null,
  "evidence_refs": []
}
```

Đây là shape minh họa; input_hash placeholder không phải digest hợp lệ. Contract
cuối là discriminated union theo tool, không result: Any. Status enum:
COMPLETED / REJECTED / FAILED. COMPLETED + outcome=INFEASIBLE là business result,
không phải exception retry. REJECTED mang typed validation/precondition reasons.
FAILED mang static error code + retry classification, không dump SDK exception.
Tool result JSON là observation untrusted cho model, không được nâng thành system role.
Provider tool-call ID phải khớp parent AI message và duy nhất trong run; executor
từ chối ToolMessage không có call tương ứng, không tự ghép bằng tool name.

Proposed error enum: BAD_ARGUMENTS, UNKNOWN_TOOL, PREREQUISITE_MISSING,
CATALOG_UNAVAILABLE, PRODUCT_NOT_FOUND, METADATA_INSUFFICIENT,
EXECUTION_CANCELLED, EXECUTION_BUDGET_EXHAUSTED, TOOL_EXECUTION_FAILED.
Các code này internal; HTTP/SSE giữ `{data,message,errors}` và keys đã document.

### 6.3. Canonical catalog và build

- Keyword/vector chỉ tìm candidates. Revalidate visibility/status từ canonical
  backend trước context/tool result, kể cả vector payload stale.
- Product khác variant: compare/get dùng product IDs; optimizer dùng variant UUID
  + SKU và normalized ComponentSpec. Không dùng product ID làm SKU ID.
- CatalogRowV1 chứa reference price, stock, timestamps, backend revision nếu có,
  evidence refs và canonical component identity. Missing socket/TDP/DDR/size/power
  phải báo metadata thiếu, không tạo số để đủ optimizer input.
- Owned có giá tham khảo nhưng spending=0; pinned spending vẫn tính vào cap.
  BUILD_PC default core only; FULL_SETUP thêm các accessory explicit, max một/type.
- Không chia 80/20; không tự chọn cheapest accessories khi ISSUE-085 chưa có policy.
- Synthetic iGPU/stock cooler chỉ khi có parent CPU evidence; không fake SKU ID.
- Tool build không được bypass prepare_build_input, completion hash guards hoặc
  to_public_build. Saved optimization/recommendation không bị LLM sửa nội dung.
- Structured giá/stock/SKU được render từ canonical DTO. Schema hợp lệ hoặc text
  không rỗng không chứng minh prose đúng sự thật: explanation cần evidence prompt,
  factuality eval/claim checks. Product descriptions là dữ liệu, không phải instructions;
  authorization/tool guards vẫn phải đứng ngoài model để chống prompt injection.
- Historical full-setup projection giữ ISSUE-087; không gắn accessories hiện tại
  vào historical core build để giả thành snapshot cũ.

### 6.4. Tool execution ledger và bounded loops

Mỗi call record giữ: tool/name/version, call ID, args hash, constraints revision,
policy/catalog hash, outcome/result/evidence, execution identity và timestamps.
Native checkpoint chứa tool_results ledger duy nhất; P5 event journal là projection cho delivery/audit,
không dùng conversation_messages thay tool journal. Cùng call ID nhưng khác args
bị reject. Semantic cache chỉ reuse khi inputs + versions + evidence còn khớp.

Đề xuất config: max_model_calls_per_run, max_tool_calls_per_run,
max_output_tokens_per_call, max_context_tokens, run_deadline, per_tool_timeout,
max_validation_repairs. Defaults hữu hạn phải được review trước implementation;
không chỉ dựa LangGraph recursion_limit để kiểm soát cost. Deadline lưu bền vững,
không reset khi resume; checkpoint counters không đủ làm hard call cap.

#### Crash-safe call-budget contract (P4-A, prerequisite P3-B)

Proposed application table agent_call_attempts, migration mới trước P3-B; không
phải ToolResult ledger. Fields: id UUID, run_id FK, execution_id, worker_instance_id,
generation, kind MODEL/TOOL_IO, operation_key, request_hash, attempt_number,
status RESERVED/SUCCEEDED/FAILED/UNKNOWN, reserved_at, finished_at, provider_request_id?,
usage? (typed nullable), result_ref?. UNIQUE(run_id, operation_key, attempt_number).
operation_key là logical node/call identity do app cấp, không provider tool-call ID.
Record không giữ credentials, raw prompts hoặc duplicate tool outcome/evidence.

1. Trước **mỗi outbound attempt**, transaction lock run, recheck execution ownership,
   cancellation/deadline và cap, insert RESERVED rồi commit. Không commit được →
   không gọi external service. MODEL bao gồm extract/agent/explain/repair và retries;
   TOOL_IO gồm từng backend request trong handler, không chỉ một tool invocation.
2. Chỉ claimant hiện tại được dispatch reservation vừa tạo một lần. Sau restart,
   RESERVED không được dispatch lại vì không biết provider đã nhận hay chưa:
   mark UNKNOWN, vẫn tính vào cap; muốn retry phải reserve attempt mới.
3. Success/failure ghi usage/ref nếu biết. UNKNOWN không phải zero tokens/cost,
   không refund reservation. Crash trước outbound cũng có thể mất một slot: V1
   chọn conservative accounting hơn tự cấp lại slot cho attempt không rõ kết quả.
4. Graph retry và SDK retry không nhân call ẩn: disable automatic outbound retries
   trong provider/backend client, hoặc instrument từng attempt bằng cùng reservation
   boundary. Không implement được adapter boundary → không claim hard attempt cap.
5. Durable budget ledger là authority qua resume/takeover; checkpoint counters là
   projection. Repair, provider error, failed attempt đều tính slot; run cap không
   reset theo generation, HTTP reconnect hoặc process restart.

Guarantee V1: hard cap **application-dispatched attempts** nếu mọi adapter đi qua
boundary này; bounded local deadline/output/context theo capability. Không hứa
exactly-once provider execution, hard billing cap hay hard total-token spending:
request timeout/cancel vẫn có thể đã bị provider tính tiền. Financial hard cap cần
provider-side quota/account enforcement; usage chưa biết giữ UNKNOWN. Reuse tool
result vẫn dựa canonical ToolResult checkpoint; call ledger không tự biến một
attempt SUCCEEDED thành graph-completed result nếu checkpoint chưa commit.

### 6.5. Grounded answer contract

Internal proposed Pydantic DTOs, extra=forbid; không đổi HTTP envelope:

```text
AnswerCandidateV1
  schema_version: Literal[1]
  text: nonblank string
  evidence_refs: list[EvidenceRef]
  build_ref: UUID | None
  claims: list[GroundedClaimV1]

GroundedClaimV1
  kind: SKU | PRICE | STOCK | COMPATIBILITY | TOTAL_PRICE | BENCHMARK
  evidence_ref: EvidenceRef
  subject_ref: canonical product/variant/build reference
  fact_key: allowlisted typed field or compatibility rule ID
  value: discriminated typed value by kind (not Any)
  text_span: exact start/end offsets in candidate text
```

EvidenceRef resolve tới validated catalog snapshot, deterministic build result,
compatibility report hoặc benchmark evidence của run/accepted context; không
chấp nhận model-provided URL như bằng chứng. build_ref là application-assigned
snapshot identity, không phải UUID do model tự tạo hay live mutable build.
Historical result phải được gắn nhãn historical/stale theo policy hiện có.

validate_result phải kiểm tra:

1. Mọi ref resolve được, đúng subject, visibility, constraints revision và
   evidence/version policy; không cross-owner hoặc trỏ orphan/debug result.
2. Claim value khớp typed field/result: integer VND, stock availability có thời
   điểm, SKU identity chính xác, compatibility theo rule result, total theo
   deterministic spending, benchmark có nguồn/workload/unit. Thiếu benchmark
   evidence → không nói FPS/điểm số hoặc suy từ marketing description.
3. Claim span khớp câu đang render. Có refs đúng nhưng text ghi số/subject khác
   vẫn reject. Không coi claim list do model tự khai là coverage proof: V1 các
   factual snippets quan trọng phải được server render từ validated claims/DTO,
   không cho prose tự do là nơi xuất bản số liệu hay compatibility verdict.
4. Prose chỉ là diễn giải/synthesis; không cho dùng như nguồn fact hoặc chứng nhận
   performance. “Mọi game 2K cực kỳ mượt” là performance claim dù không có số FPS.
   Known unsupported claims → reject/repair; điều đó không chứng minh detector
   bắt được mọi claim trong natural language. Strict factual output V1 dùng typed
   snippets/template; phần model diễn giải không kiểm chứng được thì omit khỏi
   factual answer, fallback evidence-only summary, không promote thành sự thật.

Không dùng một LLM thứ hai làm nguồn truth cho validator. Claim checks/template
rendering là deterministic. Factuality eval là quality test, không là deterministic
correctness guarantee cho prose; Pydantic/text_span/claim list cũng không đủ chứng minh
coverage của mọi assertion. Không hứa public free-form narration hoàn toàn factual.
DTO hợp lệ nhưng không vượt grounding gate không được set READY_TO_PUBLISH.

### 6.6. Result-completion validation (P3-A / prerequisite P3-B)

CompletionRequirementV1 là internal application contract từ explicit user request,
source evidence và pending task: kind BUILD / COMPARE / EXPLAIN_SAVED_BUILD /
ANSWER / CLARIFY, required canonical subjects/fields, constraints_revision và
historical build ref nếu có. Nhiều task → list requirements, mỗi task phải có typed
outcome. Ambiguous task/subjects → clarification; model final không tự hạ BUILD
thành ANSWER hoặc xóa requirement. Đây là completion validation, không intent routing
và không restrict lựa chọn read tools. CLARIFY là outcome thiếu prerequisites,
không phải cách đánh dấu task gốc đã hoàn thành.

| Yêu cầu | Terminal outcome hợp lệ |
| --- | --- |
| Build PC | FEASIBLE optimizer result đúng merged constraints/hash/revision hoặc typed INFEASIBLE với reasons; generic advice không đủ |
| Compare | Evidence/typed comparison bao phủ 2..5 canonical products được yêu cầu; missing specs ghi unknown, không làm giả giá trị |
| Explain saved build | Exact authorized accepted/published snapshot được chỉ định, có historical/stale labeling; không dùng current/latest thay snapshot |
| Mandatory input/reference thiếu | Clarification với field/mention IDs và reason thuộc prerequisite validator; không hỏi unrelated field hoặc tự nhận success |
| General answer | Grounded answer đúng câu hỏi; không được dùng nhánh này để bỏ pending build/compare task |

CompletionValidationV1 trả COMPLETED / WAITING_INPUT / REJECTED và typed per-task
reasons/result refs. Backend outage hay schema error không trở thành INFEASIBLE;
đi run failure policy. Không có hợp lệ outcome → bounded repair nếu đủ call budget,
nếu vẫn fail → fail run, không prepare_publish. Valid clarification có thể publish
WAITING_INPUT nhưng original task remains pending. Finalizer recheck outcome cùng
grounding/hashes, không tin model declaration “done”.

## 7. Recovery, stop evidence và publication

Một tool/node success chỉ reusable sau khi checkpoint durable. Node optimize và
node model/explain không gộp: optimize committed, explanation timeout → native
resume không optimize lại. Nếu routing vẫn vào optimize, existing marker + hash
guard vẫn ngăn recomputation. Read tool có thể gọi lại nếu crash trước commit;
không claim exactly-once execution. Native pending writes/lineage do saver quản lý;
[persistence reference](https://docs.langchain.com/oss/python/langgraph/persistence).

P4 coordinator phải:

1. Lock/scoped authorize conversation; idempotency reuse trước revision check.
2. Claim run + immutable base head; active slot không được suy từ status/TTL.
3. Execute một graph execution duy nhất. Run status terminal không tự release slot.
4. Executor stop ACK/process-termination proof phải match execution UUID,
   worker incarnation UUID, generation và drained checkpoint writes. Timeout/PID
   đơn lẻ không đủ; không chắc old worker đã chết thì giữ busy.
5. Walk candidate native ancestry đến đúng run boundary/base, metadata/START input
   hash/versions đúng; sibling/debug/orphan hoặc missing ancestor bị reject.
6. Native output terminal, no pending work; READY_TO_PUBLISH + current run + hashes
   + required completion/outcome markers hợp lệ. DEBUG/REPLAY không publish.
7. Fenced transaction recheck lease/generation/base revision/head/stop evidence;
   update accepted head, revision, assistant message và terminal run atomically.
8. Release slot chỉ sau verified stop/drain. Retry finalize cùng ref/hash trả saved
   result; khác candidate rejected. Lease fencing không ngăn saver.put của stale worker.

Full finalization protocol giữ plan mục 8; ReAct không thay invariant đó.
Future mutation tools bắt buộc external idempotency key và authorization/approval;
không thêm tool có side effect tài chính chỉ vì registry đã có generic dispatcher.

### 7.1. Managed executor contract V1 (P4-A)

```text
POST turn → durable PENDING run → managed executor claim → LangGraph
GET SSE   → authorize run → subscribe persisted progress (không execute graph)
```

V1 executor là lifecycle-owned supervisor, không thêm queue framework. Durable
PENDING rows là work source; bounded scan/claim phục hồi handoff mất sau commit.
HTTP submit không claim rồi giữ task riêng; executor claim run ngay trước execution,
giữ worker incarnation/execution UUID/generation. Internal wake signal chỉ giảm
latency, không phải delivery authority. POST disconnect sau commit không mất run;
retry request key trả cùng run. SSE subscriber close không cancel execution.

- Supervisor được composition root khởi động, quản lý bounded tasks/TaskGroup và
  task registry, bắt lỗi per execution, heartbeat, cancellation và drain. Không
  detached asyncio.create_task hoặc FastAPI BackgroundTasks làm durable runner.
- Worker chỉ có một owning execution mỗi conversation; mọi child task/provider
  stream/checkpointer write được join/drain trước EXECUTOR_STOP_ACK. HTTP không
  thể ghi ACK. Explicit cancel ghi cancel_requested và signal owning executor.
- Shutdown: stop admission, request cancel, await executions/streams/writes trong
  grace period, chỉ ghi ACK khi thật sự drained. Hết grace không được fake ACK;
  giữ busy đến trusted process termination + settled DB writes evidence.
- Crash: PENDING chưa claim có thể được scan lại; RUNNING cần đúng stop evidence
  trước takeover. Lease timeout/status hoặc process restart riêng nó không đủ.
- Resource ownership: supervisor giữ engine/saver/provider clients sống đến sau
  drain; không đóng resource vì SSE/request context kết thúc. Nếu dùng FastAPI
  lifespan host supervisor, graph tasks không thuộc request task group. Có thể
  tách worker process sau này, vẫn dùng cùng admission/stop/reservation contracts.

Source slice 2026-10-08 có internal TaskGroup supervisor, registered-child drain,
heartbeat/cancel và claim-commit/shutdown race tests. PostgreSQL attempt ledger +
migration 0002 cũng đã có; owner báo native reservation race/reopen test pass
ngày 2026-10-09. Agent không kết nối được DB để tự xác minh.
Durable admission/finalize coordinator, instrumented provider/backend adapters và
composition-root wiring vẫn chưa có. P2 lifespan vẫn chỉ quản lý resources; P3-B
không được nối graph execution trực tiếp vào HTTP stream trong lúc chờ P4-A.

### 7.2. Initial accepted root — experiment, chưa chốt (ISSUE-092)

Evidence 2026-10-09: owner báo toàn `test_initial_root_postgres.py` pass; agent
verify 2 memory variants. Native `aupdate_state(as_node="initialize_root")` tạo
terminal root không chạy tools, survived reopen, R1 terminal fail/orphan rồi R2
từ exact root; crash-before-CAS recovery chọn theo initialization metadata dù có
latest debug checkpoint mới hơn. Experiment chưa có concurrent production
initializer/fenced application CAS/readiness/legacy migration. Không đóng ISSUE-092
hoặc đổi P0/DB invariant từ native mechanics proof này.

Đề xuất test: create → internal INITIALIZING → exclusive initializer tạo native
terminal root checkpoint với unknown consultation/public_build=null → CAS accepted
root ref → READY. Root không chạy extraction/model/tool, không thêm assistant message
và không tăng conversational turn revision. R1 terminal failure leaves orphan;
lượt mới vẫn bắt đầu từ exact root sau stop/drain, không cần resume terminal run.

**Không coi đây là contract đang chạy:** P0 hiện yêu cầu revision=0 không có accepted
ref, P2 create trả initial conversation ngay và chưa initialize graph. Nếu native
experiment pass, phải revise head DTO/public create readiness/DB invariants và
initializer retry contract đồng bộ trước implementation. Không fake root bằng
copy values, tự ghi saver internals hoặc adopt latest. Initialization cũng là
exclusive execution, không miễn stop/drain; INITIALIZING không cho submit chat.

Native pinned PostgreSQL gates phải chứng minh:

- Root created bằng native graph/checkpointer API; terminal next/tasks không có
  pending model/tool work, exact ref survive pool/process restart.
- Crash sau checkpoint trước CAS → retry initializer identify đúng initialization
  lineage/server metadata và publish đúng ref, không tạo duplicate READY/head hoặc
  suy latest là root. Concurrent create/retry không chạy hai initializer trên thread.
- Root accepted, R1 terminal fail/orphan, worker stop verified → R2 bắt đầu từ root,
  không lấy orphan; user có đường tiếp tục chat và không revive terminal R1.
- Auth/revision/lineage/CAS rejection vẫn giữ nguyên; root không publish result của
  debug/replay. Legacy revision-zero/no-head conversation cần migration/initialization
  policy riêng, không âm thầm thay semantics.

ISSUE-092 chỉ close sau native gates và contract changes, không sau sửa markdown.

### 7.3. Persisted-state size và protected retention (P3/P4)

Tách published conversation_messages khỏi model-facing messages: published history
là application truth; prompt context là bounded projection, không nhét toàn bộ
history/catalog/benchmark documents vào graph channels mỗi lượt. Tool/evidence
snapshots chỉ giữ các typed fields thực sự dùng, candidate bounds và references.
Không dùng trim_messages để xóa nửa AI/tool pair hoặc pending clarification.

Chốt config trước implementation: max serialized graph-state bytes, per-result
bytes/candidate count, per-run ledger entries, model-context token cap và bounded
history window. Validate size trước node writes; oversized result → bounded typed
projection hoặc explicit error, không truncate làm mất nghĩa. Cần fuller evidence
thì dùng immutable snapshot store refs+hash/version với retention aligned; không
thêm blob store/framework trước khi đo thực tế. Persisted ref thiếu/corrupt → fail
closed, không fetch live facts thay immutable replay evidence.

Windowing chỉ ảnh hưởng model context/new checkpoints, không rewrite native
ancestors. GC không xóa accepted root/head, pending/resumable checkpoint ancestry,
pending writes hoặc evidence còn được active/historical result tham chiếu. Orphan
7-day policy chỉ áp dụng checkpoint thật sự unreachable/unprotected; giữ dependencies
cần recovery dù đã qua orphan/debug 7-day cutoff. Conversation retention 90 ngày
hoặc user deletion vẫn stop/drain rồi purge theo policy đã chốt; không kéo dài
conversation retention vô hạn chỉ vì root/head còn reference.

Acceptance: nhiều lượt theo bounds cấu hình (chốt fixture count trước code) đo
serialized state + native DB growth, context trim giữ valid AI/tool pairs và pending
draft, reload/recovery/replay vẫn resolve evidence. Oversize/missing protected ref
reject rõ; GC không phá native lineage hoặc historical build. Đây là planned gate,
không claim đã đo throughput/storage hoặc native recovery pass.

## 8. Delivery và observability

P5 dùng API V1 runs/history/SSE reconnect đã chốt. FE thấy public progress như
“Đang tìm sản phẩm”, “Đang kiểm tra cấu hình”, answer delta, final build/clarification;
không nhận raw tool trace, internal IDs/checkpoint refs hay hidden reasoning.

Không stream agent intermediate content như final answer. V1 ưu tiên stream câu
trả lời từ dedicated final/explain node sau grounding; deltas là provisional,
COMPLETED chỉ sau CAS publish. SSE disconnect không tự cancel run. Reconnect đọc
persisted run events, không rerun model hoặc chọn latest checkpoint.

Trace/log correlate conversation/run/execution/tool call. Không đưa account UUIDs
làm high-cardinality metric labels; không log JWT, keys, full prompts hay PII catalog
payload. Debug/replay internal-only và không publish kết quả thật.

## 9. Clean architecture placement đề xuất

```text
application/
  ports/                  # chat policy, canonical catalog, persistence/coordinator
  use_cases/              # submit/read/cancel/finalize; domain authorization
capabilities/assistant/
  conversation_core.py    # existing pure state/merge rules
  grounded_build.py       # existing canonical preparation
  build_stages.py         # existing optimize/explain marker reuse
  react_contracts.py      # proposed typed action/tool result/guard contracts
  tools/                  # feature tool handlers calling application services
infrastructure/
  execution/              # managed supervisor + durable attempt reservation adapters
  graph/                  # LangGraph nodes/reducers/routing + durable adapter
  providers/              # OpenAI/Gemini native messages/tool calling
  persistence/            # SQLAlchemy application store + native saver reader
api/                      # request/auth/response/SSE adapters, no optimizer logic
```

Không tạo một file/model factory cho từng enum hoặc generic framework mới. Registry
là static map ToolName → args validator + handler; business services dùng lại.
Public API DTO không alias internal LangChain messages hoặc generated tool schemas.

## 10. Implementation order và acceptance core

| Batch | Work | Gate |
| --- | --- | --- |
| P2 finish | Dependencies/lock, Alembic/bootstrap, lifespan/auth/readiness, exact accepted reads | Native application + adapter gate pass |
| P4-A | Durable submit + managed executor/exclusive claim/stop + call reservations | Disconnect không cancel; crash reservation vẫn tính cap; stale worker rejects |
| P3-A | Canonical requirement/draft/patch, resolver + atomic merge, versioned compiler/full mapping; tool policy/contracts | Equivalent paraphrases same semantics; ambiguous/unsupported/conflicts explicit; legacy state migration reviewed |
| P3-B | Existing optimizer + independent satisfaction verifier, ReAct build pipeline + grounded explanation | Faulty compiler/drop requirement rejected; hard/soft outcomes explicit; completion + bounded execution pass |
| P4-B | Native resume/root experiment/lineage + fenced atomic publish | First-failed-run can continue safely; native gates pass; orphan/stale publish rejected |
| P5 | Stateful endpoints, persisted SSE events, FE history/reload | Owner-bound reconnect/reload, no repeated execution/messages |
| P6 | Final core audit | DB races + terminal/retry semantics + published financial/domain consistency |

Tests tập trung core: typed patch provenance, ownership, accepted vs orphan,
compatible pins/owned spending, catalog evidence, marker reuse, run races,
stop/drain, finalization và bounded tool loop. Dùng scripted model cho graph tests
và optimizer thật; không cần benchmark UI, exhaustive SDK permutations hay live
LLM cho core acceptance. Scripted model không thay native PostgreSQL gate.

Core acceptance thêm sau review:

- Compiler bỏ/dịch sai requirement → verifier đọc canonical state và reject;
  independent expectations không chỉ round-trip compiler output. Paraphrases cho
  cùng nhu cầu có cùng normalized semantics; available resource không tự pin/use.
- RAM32GB + SSD1TB + ưu tiên RTX5070Ti → hai hard predicates và một soft model
  preference, không có pin. Exact ASUS TUF OC mới resolve variant pin. Unsupported
  mapping không biến thành success; hard/pin conflicts và unmet soft preference rõ.
- Hard capacity filter chạy trước pruning và verify final parts; preference không
  biến thành candidate exclusion. Unit/operator ambiguity, owned/pin mismatch và
  changed requirement hash invalidation có focused core tests trước P3-B.
- “25 triệu, giữ RTX 5070 Ti ASUS TUF” → resolve canonical variant trước merge;
  duplicate variants → đúng clarification, không guessed UUID hay partial mutation.
- Correct generic advice cho BUILD request vẫn fail completion; FEASIBLE/INFEASIBLE,
  comparison subject coverage và saved-build snapshot đúng mới pass corresponding task.
- Unsupported broad performance claims không được render như fact; typed facts
  deterministic, free-form narration/factuality eval không có guarantee toàn diện.
- Native root + first terminal failure + orphan + restart → new turn đúng root;
  GC/windowing multi-turn không phá pending pairs, state bounds hoặc protected evidence.
- Commit tool success → crash trước observe → resume tạo đúng một ToolMessage
  từ cùng ledger result, không gọi lại tool đã commit hoặc đổi outcome/evidence.
- Thiếu budget/use case → schemas không expose build_pc;
  state đổi sau bind → dispatcher reject stale action, handler không được gọi.
- Read tools không bị hard intent gate; principal không có quyền không thể vượt
  policy bằng tool args. build_pc tạo mới/điều chỉnh đều dùng trusted revision.
- SSE close hoặc POST disconnect sau commit không giết execution; explicit cancel
  và shutdown không release slot trước join/drain; PENDING handoff phục hồi từ DB.
- Provider success rồi crash trước checkpoint → slot vẫn consumed; retry reserve
  slot mới, không vượt cap. SDK retry không đi vòng reservation; UNKNOWN không refund.
- Multi-call response không invoke tool hoặc để lại unresolved AIMessage; repair
  giữ transcript hợp lệ, có attempt reservation riêng và đầy đủ correlation.
- Đúng evidence refs nhưng typed claim sai SKU/price/stock/total/compatibility/benchmark
  → grounding reject; undeclared prose claims không có blanket deterministic guarantee.
- Valid grounded build/clarification → typed public projection, không leak ledger
  hoặc native message objects. Các contracts trên là design gates, chưa có runtime tests.

Điểm review trước code ReAct:

- Đã chốt 4 tools, một build_pc; không intent gate cứng, ledger/projection và
  grounding giữ sections 4.1/6.5. Review chỉ còn operational limits và adapter specifics.
- Chốt operational call/token/deadline bounds và structured extraction evidence.
- Chốt safe root anchor/new-turn khi first run terminal fail (ISSUE-092).
- Catalog metadata completeness/normalization và accessory ranking vẫn cần gates
  hiện có; không đổi nghiệp vụ để “agent luôn ra được build”.

## 11. P2 runbook và evidence

Source hiện có: migration, DBML/constraint reference, owner-scoped async store,
RS256 verifier, accepted reader, native graph adapter và lifecycle/create/get.
Agent đã verify HTTP/auth boundary với fake storage và unit checkpoints. Owner
báo migration/bootstrap và toàn bộ native integration gates pass ngày 2026-10-09.
Không ghi P2 COMPLETED hoặc full recovery pass từ các foundation tests này.

Từ root ai-service, terminal có network/DB access:

```bash
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv lock
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv sync
# Configure AI_DATABASE_URL and AI_TEST_POSTGRES_DSN in ignored .env first.
uv run alembic upgrade head &&
uv run python -m ai_service.bootstrap_stateful &&
uv run pytest -q integration_tests
```

DSN là ví dụ local Compose, đổi nếu credentials khác. Không reset DB volume.
Bật foundation endpoints trong ignored env: AI_STATEFUL_ENABLED=true,
AI_JWT_JWKS_URL=<identity JWKS URL>, AI_JWT_ISSUER=http://identity-service,
AI_JWT_AUDIENCE=pc-shopping-api, rồi chạy uvicorn. Thiếu schema/config → fail
startup; application không tự migrate/setup request-time hoặc fallback RAM.
