# Plan — Stateful AI Chat & Guided PC Build

- Ngày lập: 2026-10-06.
- Revision thiết kế: 12 — hoàn thiện P0 contracts; giữ nguyên kiến trúc revision 8.
- Trạng thái: IN PROGRESS — P0 contracts và P1 deterministic core hoàn tất; P2/B1 native persistence gate bị chặn bởi ISSUE-077.
- Phạm vi: AI service, contract catalog/identity, gateway và frontend chat.
- Liên quan: UC-AI-001, UC-AI-003; PC-builder extension ngoài 68 UC chính thức.
- Tracker: [`USECASE_IMPLEMENTATION.md`](../../USECASE_IMPLEMENTATION.md),
  ISSUE-073, ISSUE-074 và ISSUE-076.

## 1. Mục tiêu và hiện trạng

Khách có thể tiếp tục một cuộc tư vấn sau nhiều lượt chat, reload trang hoặc
restart AI service mà không mất ngân sách, yêu cầu, linh kiện đã chọn và build
trước đó. Hệ thống có thể xác định bước đã hoàn tất khi một lượt xử lý bị lỗi.

Hiện trạng được kiểm tra khi lập plan:

- Root `ai-service/` giữ history trong RAM, tối đa 20 message; chưa có durable
  conversation state hay principal/ownership tại AI boundary.
- Graph hiện tại chuẩn hóa query; graph runner tạo state mới mỗi request.
- Optimizer/application pipeline đã tồn tại nhưng chưa nối vào runtime chat.
- FE giữ conversation ID trong component state; chưa khôi phục hội thoại từ DB.
- Gateway có route assistant và JWT authentication; compose vẫn build bản
  `backend/ai-service/`, khác source AI độc lập đang được phát triển.
- Source được migrate sang direct model adapters + LangGraph ngày 2026-10-07.
  Installed graph/model stack và resolver-generated lock đã pass local regression:
  210 tests, Ruff, mypy (85 files), lock check (133 packages).
  Durable persistence chưa triển khai; Postgres saver/driver/ORM và test DB vẫn
  thiếu (ISSUE-077). Không coi regression framework là native persistence gate pass.

Đây là plan triển khai, không phải bằng chứng các khả năng trên đã hoàn thành.
Các quyết định đề xuất phải được đưa vào spec trước khi thay đổi behavior.

## 2. Quyết định nền và ranh giới

- Chọn root `ai-service/` làm source AI chính. Điều chỉnh wiring/docs để không
  phát triển hoặc chạy nhầm hai bản AI; không tự xóa source bản còn lại.
- AI sở hữu PostgreSQL `ai_db` và migration riêng. Có thể dùng chung instance
  PostgreSQL ở dev nhưng khác database/user; không ghi trực tiếp DB identity,
  catalog, order hay payment.
- Application metadata dùng SQLAlchemy async và Alembic; graph checkpoint dùng
  `langgraph-checkpoint-postgres` / `AsyncPostgresSaver`. PostgreSQL driver/pool
  tương thích được chốt ở B1; không truyền ORM session vào checkpointer.
- Kiến trúc đích dùng Pydantic cho schemas và LangGraph StateGraph cho orchestration;
  bỏ PydanticAI/Pydantic Graph sau migration callers. LLM extraction/explanation
  dùng LangChain chat-model adapters qua application ports, giữ optimizer/services
  deterministic hiện có. Không thêm create_agent/tool loop làm runtime thứ hai.
- Một graph tuần tự trước; chưa cần supervisor, multi-agent hoặc scheduler
  graph song song.
- LLM hiểu yêu cầu và diễn giải. Application validate/merge state. Optimizer
  quyết định cấu hình dựa trên catalog thật và constraints đã validate.
- Giữ API envelope `{data, message, errors}`; `message` là static enum/key.
- V1 login-only đã được owner chốt ngày 2026-10-07; guest làm sau.
  Conversation UUID không phải credential. Runtime auth vẫn thuộc B1.
- Budget scope V1, owner chốt ngày 2026-10-07: BUILD_PC mặc định chỉ case PC;
  FULL_SETUP gồm case PC, màn hình, chuột, bàn phím và tai nghe. Mỗi loại phụ kiện
  tối đa một cái. Không tự phân bổ 80/20 hoặc tỷ lệ khác; cần phụ kiện nhưng chưa
  rõ ngân sách thì hỏi user. Owned spending=0; pinned vẫn tính tiền.
- Retention V1: chat/run/checkpoint 90 ngày; orphan/debug checkpoint 7 ngày.
  User xóa conversation thì xóa toàn bộ dữ liệu liên quan. Debug/replay chỉ
  internal; replay không được publish vào accepted head hay kết quả thật.
- Chat history, current business state và graph execution checkpoints có
  trách nhiệm khác nhau; không dùng một loại thay thế toàn bộ các loại còn lại.

### 2.1. Vai trò Pydantic và LangGraph

| Thành phần | Trách nhiệm | Không chịu trách nhiệm |
| --- | --- | --- |
| Pydantic | Domain/request/output models; validate constraints, patches, restored state | Không tự lưu DB hoặc điều phối execution |
| Model/provider adapter | Typed extraction và async text generation/streaming; model configuration và usage metadata | Không sở hữu business state, message history, tool loop hoặc orchestration |
| LangGraph | Nodes, conditional edges, reducers, state history, resume/replay | Không tự enforce ownership, monetary rules hoặc commerce idempotency |
| AsyncPostgresSaver | Persist graph checkpoints qua framework API | Không thay transaction của application metadata |
| SQLAlchemy/Alembic | Conversations, messages, run metadata và migrations application | Không tự quản lý hoặc ghi trực tiếp bảng checkpoint framework |

Node async gọi application LLM port; adapter infrastructure dùng direct chat-model
structured output cho extraction và ainvoke/astream cho explanation. Canonical
contract là TurnPatchV1; chỉ truyền trực tiếp schema này vào with_structured_output
khi pinned provider/model hỗ trợ đầy đủ. Nếu cần provider wire schema, adapter
map explicit về TurnPatchV1, không đổi null thành absent/CLEAR. Pydantic validate
canonical output trước khi node trả state update. LangChain model objects,
AIMessage và callbacks nằm trong infrastructure, không trở thành domain/public DTOs.

Ưu tiên provider-native schema enforcement nếu model hỗ trợ; function-calling
structured output chỉ là cách lấy typed response, không tạo agent/tool execution
loop. ProviderStrategy/ToolStrategy của create_agent không phải API được dùng
trong flow này. Chọn method/strict options theo pinned provider integration.

LangGraph/node policy sở hữu retry budget; model SDK retries phải disable hoặc
bounded và được tính chung vào attempt/cost budget. Không có hai tầng semantic
retry hoặc hai message histories. Extraction không stream partial patch vào
state; validate toàn bộ response, merge một lần rồi checkpoint. Explanation text
deltas là provisional tới khi result được validate và application finalize.

Graph dùng `TypedDict` với payload JSON-serializable; domain schemas và patches
vẫn là Pydantic models. Validation explicit tại input, output node, restore và
public response; không giả định framework tự validate mọi partial update.
Không persist model client, connection, HTTP request hoặc Python runtime object.

### 2.2. Migration và provider gate

- B1 pin LangGraph/checkpointer, langchain-core và provider integration packages
  cần dùng (OpenAI/Gemini), driver/pool. Không cài full agent framework chỉ để có
  model.with_structured_output. Ghi versions/method vào execution provenance.
- B2 test TurnPatchV1 thực, gồm sparse fields, SET/CLEAR discriminated unions,
  extra-field rejection, null/absent, refusal/truncation, malformed/multiple tool
  calls và schema validation errors trên pinned adapters. Provider schema subset
  không được silently làm yếu DSL; nếu cần wire-schema adapter thì mapping về
  canonical TurnPatchV1 phải explicit và có contract tests, không đổi null thành
  absent tùy ý hoặc parse prose như một patch hợp lệ.
- Thay answer-generator/provider implementations, composition và shopping/
  comparison graph adapters; giữ contracts search/compare và canonical retriever.
  Chuyển các tests đang dùng PydanticAI TestModel sang model-port fixtures và
  adapter tests. Không rewrite business rules chỉ để đổi framework.
- Gỡ pydantic-ai/pydantic-graph khỏi manifest/lock chỉ khi không còn imports/
  callers ở source/tests/scripts và các capability regression/SSE tests pass.
  Nếu còn legacy caller, tracker phải ghi migration chưa hoàn tất; không tuyên bố
  service đã bỏ framework từ một thay đổi plan. ARCHITECTURE/README/specs được
  đồng bộ khi source migration diễn ra, tránh mô tả kế hoạch như runtime đã có.

### 2.3. Nguồn state chính

Graph checkpoints là nguồn business state chính. `conversations` chỉ giữ
revision và reference tới checkpoint đã được application chấp nhận. Public
state cho FE được load/validate/sanitize từ reference đó.

`accepted_checkpoint_ref` là application head đã được publish. Latest checkpoint
của LangGraph không mặc nhiên là accepted state: checkpoint đang xử lý, orphan,
debug hoặc stale có thể tồn tại trong cùng thread. Public state và base của lượt
chat mới luôn được resolve từ accepted head; không chọn checkpoint bằng thời gian
tạo mới nhất hoặc suy ra published history từ toàn bộ framework history.

Không tạo `conversation_states` như một nguồn ghi state song song, không tự
implement `agent_checkpoints` hoặc custom checkpoint engine. Nếu sau này cần
read projection, projection phải rebuild được, có checkpoint reference và không
nhận independent writes.

Ngoài scope:

- Cart/checkout mutations qua chat, thanh toán và replay side effect.
- Long-term user memory dùng xuyên conversation, vector memory và event sourcing.
- Dashboard replay riêng, orchestration platform và production deployment.
- Chứng nhận toàn bộ tương thích phần cứng ngoài các constraint đã model/test.

## 3. Batch triển khai và acceptance

### 3.1. Phases thực thi — không thay kiến trúc

| Phase | Mapping | Phạm vi / gate | Status |
| --- | --- | --- | --- |
| P0 — Contract baseline | B0 | Login-only, BUILD_PC/FULL_SETUP, patch/ref schemas, retention, public DTO/API/provenance và AI DB schema contract | COMPLETED — contract-only; runtime thuộc P2–P5 |
| P1 — Deterministic conversation core | B2 core | Typed unknown state; atomic absent/SET/CLEAR merge; provenance/locks; owned/pinned conflicts; completion/hash invalidation và total-budget arithmetic | COMPLETED — pure core slice, chưa wiring chat |
| P2 — Durable foundation | B1 | AI DB metadata, async ownership/JWT, native accepted-head gate trên exact pinned stack/PostgreSQL | BLOCKED — ISSUE-077 |
| P3 — Grounded build flow | B2 extraction + B3 | Canonical catalog/parts, accessory budget contract, optimizer/provenance và explanation nodes | TODO |
| P4 — Run recovery/publication | B4 | Execution-stop admission, idempotency, fencing, native lineage validation và CAS finalize | TODO |
| P5 — Customer delivery | B5 | HTTP/SSE mapping, reload/history/state và FE | TODO |
| P6 — Core acceptance audit | B6 | Multi-turn, optimizer, no-loss recovery, race/publication/ownership scenarios | TODO |

P1 core thuần có thể triển khai độc lập khi P2 bị chặn; không wiring stateful
runtime hoặc tuyên bố durable execution trước khi P2 pass. Không gộp completion
của một slice vào completion toàn batch/phase.

P1 evidence (2026-10-07, root `ai-service/`):

- `uv run pytest -q tests/test_conversation_core.py`: 9 core scenarios pass,
  gồm real optimizer BUILT/INFEASIBLE, atomic merge và preservation của build cũ.
- `UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q`: 210 passed in 5.45s.
- `uv run mypy src`: 85 source files pass; `uv run ruff check src tests integration_tests`
  và `uv lock --check` (133 packages) pass; diff checks pass.
- Core module chưa wiring vào chat. Accessory allocation/provenance snapshot,
  native checkpoint recovery, execution-stop admission và publish còn P2–P5.
- P2 recheck: dry-run cài saver/psycopg/SQLAlchemy/Alembic lỗi PyPI DNS;
  `pg_isready` không có response. Native PostgreSQL gate chưa pass (ISSUE-077).

### 3.2. Test strategy — owner-approved core-first

- Tập trung tests vào outcome nghiệp vụ: multi-turn giữ yêu cầu, CLEAR về unknown,
  atomic rejection, source/lock, owned/pinned và spending, completion/hash/reuse,
  optimizer invariants, stale execution/accepted head và publication races.
- Tests deterministic core dùng models/services thật; không cần live LLM/provider.
  Không thêm nhiều permutations SDK constructor, icon/UI hoặc wrapper chỉ để tăng
  số tests. Giữ regression tests hiện có, không xóa tests đúng để làm suite xanh.
- Adapter chỉ smoke/contract checks cần thiết. PostgreSQL accepted-head/restart,
  auth/ownership và transaction/race là core correctness gates, không được bỏ
  vì chúng đi qua infrastructure. Không thay chúng bằng mock/SQLite evidence.
- Mỗi phase có acceptance riêng và focused command; full suite/static/lock chạy
  trước handoff. Report phase/slice thực sự verified, không dùng test count làm
  bằng chứng toàn feature đã xong.

### 3.3. Batch acceptance gốc

| Batch | Status | Feature | Điều kiện nghiệm thu |
| --- | --- | --- | --- |
| B0 | COMPLETED | Spec, API/state contracts, ownership | Typed contracts/rejection tests và API/DDL spec; không claim auth/persistence/runtime |
| B1 | BLOCKED (ISSUE-077) | DB metadata + LangGraph checkpointer + auth | Restart không mất state; ownership đúng; pinned-version test chứng minh lượt mới bắt đầu từ accepted head dù thread có orphan/stale checkpoints |
| B2 | IN PROGRESS | Extraction và state patch/merge | P1 merge core verified; extraction/runtime integration còn TODO |
| B3 | TODO | Catalog mapping + graph build-PC | Build dùng SKU thật, đúng budget và constraints được hỗ trợ |
| B4 | TODO | Runs + native checkpoint recovery/reconciliation | Retry không trùng message; resume từ checkpoint; không publish stale run |
| B5 | TODO | HTTP/SSE và frontend conversation | Reload mở lại chat; progress/build/lỗi nhất quán |
| B6 | TODO | Audit end-to-end | Multi-turn, restart, race, failure và quyền truy cập được kiểm thử |

Trước mỗi batch: đọc spec, cập nhật tracker thành IN PROGRESS, viết rejection
tests và acceptance tương ứng. Chỉ COMPLETED khi feature được implement và
verify; không tự thay đổi số lượng hoặc trạng thái các UC chính thức.

## 4. B0 — Chốt specification và contracts

Baseline và acceptance IDs: [Stateful chat contracts](stateful-chat-contracts.md).
P0 baseline đã hoàn tất: strict patch/turn/head/stop-evidence, scope/accessory,
public/SSE và provenance schemas với core tests; policy và route/DDL contract
đã ghi trong [API V1](../05-api/stateful-chat-v1.md) và
[AI DB schema](../03-data/ai-stateful-schema.md). Native B1 gate được viết trong root `ai-service/integration_tests/`,
chưa chạy được vì thiếu dependencies/PostgreSQL access (ISSUE-077).

- Định nghĩa các intent: tiếp tục tư vấn, build mới, chỉnh build, giải thích
  build hiện tại; giữ các flow search/compare/evaluate đang có.
- Chốt câu hỏi tối thiểu, phạm vi ngân sách core/accessories, hard constraints,
  soft preferences, owned parts và pinned parts.
- Chốt request/response/state schemas, static keys và error semantics.
- Chốt principal, ownership, guest policy, retention/deletion và quyền debug.
- Làm rõ source gap của PC-builder extension và đồng bộ guided-selection,
  context-management, agent-tools, API docs với hành vi sẽ triển khai.
- Ghi mọi ambiguity/missing requirement vào tracker; không dùng example trong
  plan như một business rule đã được phê duyệt.

## 5. B1 — Database, auth và persistence

### 5.1. Schema toàn bộ feature

| Bảng | Trách nhiệm | Trường chính dự kiến |
| --- | --- | --- |
| `conversations` | Owner và published head; thread ổn định bằng conversation ID | `id`, `account_id`, title, status, revision, `accepted_checkpoint_ref`, timestamps |
| `conversation_messages` | Lịch sử có thứ tự | `id`, `conversation_id`, `run_id`, sequence, role, content/payload, timestamp |
| `agent_runs` | Một lượt xử lý trên thread của conversation | `id`, `conversation_id`, kind CHAT/DEBUG, request key/hash, status, base/last/final checkpoint refs, base_revision, attempt/worker/execution identity, authorized recovery-source refs, lease generation, cancel_requested, executor_stop_evidence, retry policy/count/deadline, versions/error/trace, timestamps |
| Framework-owned checkpoint tables | State snapshots và pending writes của LangGraph | Do phiên bản Postgres checkpointer quản lý; không tự định nghĩa ORM/schema |

B1 triển khai ba bảng application và bootstrap checkpointer, với graph smoke
test và integration gate ở 5.3. B4 hoàn thiện lifecycle/idempotency/recovery của
runs. DDL cuối cùng được chốt ở B0, không coi bảng trên là migration SQL.

### 5.2. Persistence và lifecycle

- Chuyển `ConversationStore` từ sync sang async, thêm owner vào thao tác.
- Thêm adapter LangGraph/checkpointer sau application port; framework imports
  nằm trong infrastructure, không lan vào optimizer/domain hoặc HTTP DTOs.
- Connection pool được mở/đóng theo application lifecycle; transaction/session
  không dùng chung giữa các request đồng thời.
- Lưu history đầy đủ theo retention policy; giới hạn context đưa vào prompt
  độc lập với lượng history được lưu.
- Domain state được serialize qua validated JSON payload và có `schema_version`.
  Không ép internal checkpointer storage phải có dạng JSONB hoặc chỉnh serializer
  bằng cách ghi SQL trực tiếp. Không bật pickle fallback cho dữ liệu không tin cậy.
- State updates đi qua graph nodes/reducers hoặc framework API được authorize.
  Application publish accepted checkpoint dùng expected revision; stale bị từ chối.
- Không âm thầm fallback sang RAM khi DB lỗi. Memory store chỉ cho test hoặc
  chế độ development được cấu hình rõ ràng.
- Application tables: đồng bộ AI DBML, constraints, Alembic và integration tests.
  Checkpointer tables: bootstrap/upgrade bằng cơ chế của pinned package trong
  migration workflow riêng; không reimplement bằng Alembic hoặc setup mỗi request.
- Bootstrap `ai_db` cho volume dev hiện có bằng quy trình được kiểm tra;
  không xóa/recreate volume để init lại.

### 5.3. Conversation/thread mapping

- `conversation_id` là logical customer conversation, không phải quyền truy cập.
- Một conversation ánh xạ ổn định tới một LangGraph `thread_id`:
  `thread_id = str(conversation_id)`. Nhiều runs tạo checkpoints nối tiếp hoặc
  nhánh native trong thread đó. Không tạo thread mới cho từng run/attempt.
- Server resolve thread/checkpoint sau ownership check; client không được chọn
  arbitrary thread, namespace hoặc checkpoint. Run thuộc conversation owner.
- Lượt mới đọc revision và accepted checkpoint trong transaction claim run,
  lưu thành `base_revision`/`base_checkpoint_ref`. Graph nhận input của lượt mới
  dựa trên native checkpoint đã accepted; prompt history đọc từ message store
  với giới hạn riêng. Không mặc nhiên invoke chỉ với `thread_id` để lấy latest.
- Recovery/resume dùng native checkpoint của run đang khôi phục trên cùng thread,
  không quay về accepted head để làm lại lượt từ đầu. Reference phải thuộc đúng
  run/attempt/lineage hợp lệ và compatible versions; không lấy latest chung của
  thread. Không reconstruct execution bằng cách copy `StateSnapshot.values`.
- Mỗi conversation chỉ có một graph execution hoạt động, kể cả recovery và
  debug replay. Lease hết hạn không chứng minh execution cũ đã dừng. Chỉ takeover
  sau khi xác nhận execution cũ đã kết thúc và không còn checkpoint writes đang
  chạy; khi chưa xác nhận được thì giữ run chưa terminal và trả busy, không chạy
  song song hoặc suy ra quyền takeover chỉ từ lease hết hạn.
- Application fencing bảo vệ accepted head/messages/finalization; không tự fencing
  được writes bên trong `AsyncPostgresSaver`. Không dùng lease timeout hoặc DB
  run status đơn thuần như bằng chứng stale worker không còn ghi vào thread.
- Run status không tự nhường quyền sử dụng shared thread. Chỉ execution-stop
  evidence hợp lệ của execution đang sở hữu thread mới chứng minh có thể nhường
  thread cho execution tiếp theo; quy tắc này áp dụng cả new turn, resume và debug.
- Reference tới checkpoint framework là opaque metadata, không tạo FK tới
  internal tables; giữ đủ native identity, gồm thread/checkpoint và namespace
  khi có. Cleanup bảo toàn accepted/base/working refs và ancestor/pending writes
  cần recovery; không xóa checkpoint chỉ vì nó chưa được publish.

Mapping:

```text
Conversation C1 → thread_id C1 (stable)
  Run R1 → cp1 → cp2 (accepted)
  Run R2 → cp3 → cp4 (accepted)
  Run R3 → cp5 → ...
```

B1 phải pin LangGraph/checkpointer versions và test PostgreSQL thật để chốt cách
bắt đầu một lượt mới từ accepted head. Đối chiếu hai đường native: invoke new
input với accepted checkpoint config, hoặc `update_state`/new-input fork rồi
continue với config mới trả về. Không mặc định invoke từ checkpoint cũ có cùng
semantics với một lượt chat mới; replay có thể chạy lại các node phía sau.
`update_state` tạo checkpoint mới, có reducers và routing/`as_node` semantics;
không dùng nó như thao tác copy values hoặc ghi SQL vào bảng framework.

Gate phải bao gồm conversation đầu tiên, nhiều lượt tuần tự, failure/restart,
accepted head khác latest vì orphan/stale/debug checkpoints, đúng parent lineage,
không lặp lượt/marker/message và không chạy lại bước đã durable ngoài ý định.
Đường implementation được chọn sau khi gate pass và ghi API/config cụ thể theo
version vào tài liệu; không ghép hai cơ chế điều phối. Gate fail là blocker cho
stateful runtime, không tự fallback sang latest hoặc seed state sang thread khác.

#### 5.3.1. Native accepted-head gate

Root `ai-service/pyproject.toml` và resolver-generated lock đã có LangGraph/model
integrations và pass local regression, nhưng chưa có Postgres checkpointer/driver.
Chưa có version/API invocation cho durable accepted-head đã được kiểm chứng.
B1 phải pin exact versions của toàn bộ persistence stack trong
manifest và lock, ghi Python/driver versions cùng lệnh chạy vào test evidence.
Không chọn version chỉ bằng ví dụ docs hoặc coi lock check là integration test.

Test dùng StateGraph nhỏ, AsyncPostgresSaver, reducers thực và node call counters,
không cần live LLM. Chạy cùng một thread:

1. R1 ghi terminal checkpoint A với sentinel `accepted-A`; finalize A/revision 1.
   Lưu native config đầy đủ của A.
2. R2 ghi checkpoint B mới hơn với sentinel `orphan-B`, không finalize. Assert
   lookup mặc định trả B, lookup explicit A trả `accepted-A`. Dừng R2 trước R3.
3. Claim R3 tại revision 1/base A; bắt đầu input mới bằng đường native ứng viên.
   Assert R3 kế thừa A, áp dụng input R3 đúng một lần, không chứa sentinel B.
   Lineage đi từ A qua checkpoints input/update hợp lệ, không từ B.
4. Assert extraction/merge R3 chạy đúng một lần, publication marker R1 được reset;
   không tiếp tục pending tasks R2 hoặc replay explanation R1. CAS finalize R3
   với base revision 1; head/public state thành terminal checkpoint R3.
5. Lặp lại sau restart process/pool, với B có pending work/debug branch, crash
   trước finalize và conversation chưa có head ở lượt đầu. Resume R2 là test
   riêng: chọn working ref R2, không biến recovery thành một new turn.

Chỉ sau gate pass mới ghi input/config chính xác của ainvoke/astream, hoặc
aupdate_state/routing nếu phải fork native, vào adapter design. Không mặc định
as_node/checkpoint config cho đúng new-turn semantics trước khi test.

### 5.4. Ownership

- AI validate JWT RS256/JWKS theo contract identity hiện có: issuer, audience,
  expiration, access-token type, account identity và các claim bắt buộc.
- Không tin `account_id` hoặc header owner client tự gửi; không lưu JWT/API key.
- `account_id` là remote identity reference, không FK xuyên database.
- Mọi read/write/list/cancel/resume đều authorize theo conversation owner.
- Guest, nếu được phê duyệt, cần session credential an toàn và ownership riêng;
  không tự mở guest access bằng UUID hay tự chuyển chat guest sang account.

## 6. B2 — State giữa các lượt chat

State tối thiểu:

```text
phase
current_run_id
constraints + source + locked
missing_fields / pending_question
owned_parts
pinned_parts
last_successful_build + constraints_revision
optimization_status / optimization_input_hash / optimization_result
explanation_status / explanation_input_hash / explanation_result
publication_result + publication_input_hash
schema_version
```

- `owned_parts`: khách đã sở hữu; V1 không tính vào chi phí mua.
- `pinned_parts`: khách muốn giữ trong phương án mua; vẫn tính giá.
- Build snapshot lưu SKU, giá lúc tư vấn, evidence và versions đã dùng.
- State còn thiếu thông tin phải biểu diễn unknown rõ ràng; không khởi tạo
  default optimizer như thể khách đã xác nhận budget/use case.

Luồng:

```text
Kiểm tra owner → Load accepted checkpoint → Validate restored state
→ LLM port trích xuất typed patch → Application validate/merge
→ LangGraph ghi checkpoint → Publish reference với expected revision
```

Merge rules:

- Field không được đề cập giữ nguyên; phân biệt absent với explicit clear.
- Không tự điền default 20 triệu/gaming khi khách chưa cung cấp.
- Thay đổi constraint đã khóa phải có chỉ dẫn rõ ràng từ khách hoặc hỏi lại.
- Inference không được tự biến thành hard requirement.
- Mâu thuẫn phải hỏi lại; không tự bỏ yêu cầu để tạo build.
- Build cũ được giữ khi lỗi; đánh dấu stale nếu constraints thay đổi.
- Conversation mới không tự kế thừa ngân sách/build của conversation khác.

Extraction và explanation có thể là hai lời gọi LLM structured/text khác nhau;
chưa cần autonomous agents riêng.

### 6.1. Patch DSL V1

Patch là sparse object có schema_version=1 và các nhóm constraints, owned_parts,
pinned_parts. Pydantic models dùng extra="forbid", discriminated union theo op,
typed values theo field. Không nhận arbitrary JSON paths hoặc cho patch sửa run
identity, phase, markers, provenance, source/lock hay checkpoint reference.
schema_version là Literal[1]; op là Literal[SET]/Literal[CLEAR], numeric/bool
inputs phải đúng type (không coercion "25000000"/true thành budget). Map keys là
enum allowlist; duplicate object keys bị reject tại JSON parsing boundary.

| Biểu diễn | Semantics |
| --- | --- |
| Field/group/slot absent | Giữ nguyên giá trị đã accepted |
| `{"op": "SET", "value": T}` | Thay bằng typed value đã validate/resolve |
| `{"op": "CLEAR"}` | Xóa constraint về unknown hoặc gỡ binding của slot |
| null, SET thiếu value/SET null, CLEAR có value | Reject; không coi như CLEAR |

Keys của constraints V1: target_budget_vnd, use_case, target_resolution,
target_fps, preferred_gpu_brand, preferred_cpu_brand, form_factor_preference.
Types/enums dùng canonical domain schemas; SET thỏa validators của field. CLEAR
budget/use case đưa state về unknown và clarification, không instantiate defaults
của PCBuildConstraints. Budget scope/objective bổ sung cần field contract/policy
riêng ở B0; không đưa thêm field qua generic metadata.

Ví dụ extraction patch:

```json
{
  "schema_version": 1,
  "constraints": {
    "target_budget_vnd": {"op": "SET", "value": 25000000},
    "preferred_gpu_brand": {"op": "CLEAR"}
  },
  "pinned_parts": {
    "GPU": {"op": "SET", "value": {"variant_id": "00000000-0000-4000-8000-000000000001"}}
  }
}
```

UUID trong ví dụ chỉ minh họa; runtime phải resolve catalog identity thật.

- owned_parts/pinned_parts là sparse maps theo ComponentCategory. Absent slot
  giữ nguyên, CLEAR gỡ binding, SET thay toàn bộ binding của slot. Không merge
  âm thầm từng property; empty object không có nghĩa clear-all.
- Validate cả patch và trạng thái cuối trước khi apply một state update. Không
  apply nửa patch rồi lỗi ở slot khác. Expected revision/request id/payload hash
  vẫn bắt buộc; không tự merge stale request.
- Application tạo source/confidence/lock/evidence sau khi kiểm tra message/user
  action và extraction evidence. Client/LLM không được gán SYSTEM, unlock SYSTEM
  constraint hoặc patch wrapper metadata. SET/CLEAR USER-locked field cần explicit
  user instruction/confirmation; không đủ bằng chứng thì clarify/reject.
- Lưu extraction patch/evidence để giữ ý định CLEAR; accepted field cleared là
  unknown. Chỉ map sang optimizer sau readiness validation với budget/use case
  explicit, không dùng missing field để kích hoạt default.

### 6.2. Owned/pinned contract V1

Core slots dùng enum hiện có: CPU, MAINBOARD, RAM, GPU, PSU, CASE, COOLER, STORAGE.
V1 core có tối đa một binding/slot. Nhiều kit/thiết bị/phụ kiện cần extension
slot/quantity contract riêng; không tự ép vào model một-slot hiện tại.

| DTO dự kiến | Fields và invariant |
| --- | --- |
| PinnedPartRefV1 | variant_id: UUID bắt buộc; category là map key và phải khớp canonical variant |
| OwnedPartRefV1 | variant_id: UUID; V1 luôn exclude_from_budget=true, spending_price_vnd=0; không cho client/LLM đổi owned thành khoản mua |
| ResolvedPartBindingV1 | category, kind OWNED/PINNED, variant_id, sku, validated ComponentSpec snapshot, catalog_price_vnd, spending_price_vnd, exclude_from_budget, evidence/source refs |

HTTP structured patch nếu expose và model extraction dùng cùng canonical ref DTOs.
Không nhận client-provided price/stock/specs. Resolver lấy canonical backend data,
validate visibility/identity/category và snapshot. Tên tự do hoặc owned ngoài
catalog chưa resolve được là unknown cần clarification; không tạo ComponentSpec
từ phỏng đoán LLM. Support hardware ref ngoài catalog cần requirement/port riêng.

- Owned/pinned không cùng chiếm một slot. Chuyển loại cần CLEAR binding cũ và SET
  binding mới cùng patch; trạng thái cuối vẫn xung đột thì reject.
- Owned V1 luôn có spending 0; không hỗ trợ owned exclude=false.
  Pinned luôn exclude=false và spending=catalog price; pin inactive/out-of-stock
  không bị thay SKU khác im lặng. Không tự chuyển pinned thành owned.
- Giữ ComponentSpec.price làm giá tham chiếu; spending là field riêng. Identity
  dùng variant ID, không dùng product ID/tên. Purchased rows không có ID bị reject.
- OptimizerInputV1 gồm explicit validated PCBuildConstraints, canonical normalized
  catalog và requested objective. Owned map sang OwnedComponent hiện có; bổ sung
  typed pinned_parts vào constraints và validate hard pins trước pruning. Không
  giả lập pinned bằng OwnedComponent vì output owned_categories sẽ sai semantics.
- Current source có OwnedComponent nhưng chưa có pinned_parts trong
  PCBuildConstraints. B2/B3 cập nhật schema, optimizer/recommendation mapping,
  guided-selection spec và tests cùng nhau trước khi coi contract implemented.
  BUILD_PC mặc định chỉ case PC; FULL_SETUP thêm bốn loại phụ kiện nêu ở mục 2,
  mỗi loại tối đa một cái. Không áp tỷ lệ chia budget hay minimum tiền tự đặt;
  budget phụ kiện chưa rõ thì clarify trước khi optimize. Clear/unknown ở chat
  boundary không được biến thành budget 20 triệu/gaming mặc định.
  P0 schema/merge đã siết owned exclude=false và scope/accessory refs, với core
  rejection tests. Library optimizer pinned/accessory wiring vẫn thuộc P3;
  không coi policy DTO là runtime đã có.

### 6.3. Completion markers và invalidation

Domain schemas dùng enum cho phase và stage status. Với nhánh build thành công:

```text
EXTRACTED → MERGED → CATALOG_READY → OPTIMIZED → EXPLAINED → READY_TO_PUBLISH
```

Đây là trạng thái nghiệp vụ đã đạt được, không thay execution cursor của
LangGraph. Nhánh hỏi làm rõ hoặc giải thích build đã có đi theo routing riêng;
không phải giả lập các bước catalog/optimize để đi qua toàn bộ chuỗi trên.

- `optimization_status` và `explanation_status` có các giá trị `NOT_STARTED`,
  `COMPLETED`, `FAILED`. Trạng thái execution đang chạy thuộc `agent_runs`.
  Không suy ra completion chỉ từ `result != None` hoặc thứ tự node.
- Node thành công trả status `COMPLETED`, input hash, validated result và
  versions/provenance trong cùng một state update. Chỉ coi bước đã durable khi
  checkpoint chứa toàn bộ update được commit; không đánh dấu hoàn tất trước
  khi kết quả được validate. Lỗi được ghi nhận không mang status `COMPLETED`.
- `optimization_input_hash` tính từ canonical normalized optimizer input:
  constraints, budget scope/units, owned/pinned parts, catalog snapshot và
  engine/policy/schema versions. Không hash riêng raw chat hoặc riêng budget.
- Optimizer đã xử lý nhưng không có nghiệm là completed computation với outcome
  `INFEASIBLE`; không được coi như có build hợp lệ để publish. Kết quả cần chứa
  outcome rõ ràng thay vì dùng null để phân biệt lỗi với không có nghiệm.
- `explanation_input_hash` bao gồm optimization/build result đã dùng, câu hỏi/
  intent, locale, evidence và prompt/model configuration versions. Kết quả giải
  thích cũ không tự được dùng cho một câu hỏi khác về cùng build.
- Reuse chỉ khi status là `COMPLETED`, input hash khớp input hiện tại, versions
  tương thích và result qua validation. Thiếu result/hash hoặc marker mâu thuẫn
  là state lỗi cần xử lý rõ ràng, không silently bỏ qua node.
- Khi input optimize thay đổi, reset completion markers và kết quả làm việc của
  optimize/explain/publication; giữ `last_successful_build` như snapshot lịch sử
  và đánh dấu stale theo merge rules. Khi chỉ input explain thay đổi, giữ kết quả
  optimize hợp lệ và invalidate explain/publication. Run mới reset phase và
  publication marker/payload của lượt trước; kết quả optimize/explain đã lưu
  chỉ là ứng viên reuse cho tới khi input của lượt mới được validate và hash
  được kiểm tra theo các điều kiện trên.
- `READY_TO_PUBLISH` chỉ được ghi cùng `publication_result` đã sanitize/validate,
  hash của input/results và `current_run_id` tương ứng. Đây là marker graph đã
  chuẩn bị xong output; `agent_runs` chỉ hoàn tất sau application transaction
  publish thành công. Marker không thay ownership, revision hoặc lease guard.

## 7. B3 — Catalog và graph tư vấn

### 7.1. Luồng chính

```text
Load context
→ Understand turn / Extract patch
→ Validate + Merge
→ Decide
   ├─ Thiếu thông tin → Clarify → Prepare publication → Persist → End
   ├─ Hỏi về build hiện tại → Explain → Prepare publication → Persist → End
   └─ Build / Điều chỉnh
       → Retrieve catalog
       → Normalize components
       → Optimize + Recommend
       → Explain bằng evidence
       → Prepare publication result / READY_TO_PUBLISH
       → Persist → End
```

Reuse `PCBuildApplicationService`, recommendation policy và explanation context;
không tạo pipeline recommendation thứ hai. LangGraph adapter compile graph với
checkpointer và dùng async invocation/streaming. Input là restored/validated state
của turn hiện tại; không dùng state factory rỗng làm memory giữa các lượt.

LLM được gọi trong các node extraction/explanation qua model/provider port.
Nodes không tự ghi ORM state. Reducers/application merge thực hiện domain rules;
framework chỉ điều phối và persist updates đã được validate.

Node optimize chỉ map validated input, gọi PCBuildApplicationService.build_pc
và trả result/marker/hash. Compatibility, pruning, scoring và recommendation
vẫn nằm trong deterministic services/core; không chuyển thuật toán vào graph node.

Mọi outcome có response để publish, kể cả hỏi làm rõ hoặc `INFEASIBLE`, đi qua
prepare-publication node và ghi marker `READY_TO_PUBLISH` cùng payload của run
hiện tại. Lỗi kỹ thuật được xử lý bằng lifecycle/error contract của run; không
tạo completion marker giả chỉ để đi qua finalization của một response thành công.

### 7.2. Catalog contract

- Map product → variant/SKU, active visibility, giá, stock và attributes thật
  vào `ComponentSpec`; nguồn dữ liệu canonical vẫn là backend.
- Chốt metadata keys/units/provenance và các fields phục vụ engine/policies.
- Pinned/owned identity phải được resolve; không biến tên linh kiện tự do thành
  thông số phần cứng do LLM tự đoán.
- Thiếu compatibility/benchmark data thì UNKNOWN hoặc reject candidate theo
  engine; không điền số mẫu hay dùng web snippet làm chứng nhận tương thích.
- Không cho inactive/deleted catalog vào context, kể cả stale retrieval payload.
- Snapshot dùng để giải thích lịch sử; thao tác build mới hoặc commerce phải
  revalidate giá, stock và visibility hiện tại.

Nếu backend chưa có metadata đủ cho optimizer, tạo issue và hoàn thiện
contract/data trước. Fixture chỉ cho tests/dev, không phải production catalog.

#### 7.2.1. Optimizer provenance snapshot V1

OptimizerExecutionSnapshotV1 được lưu immutable cùng completion checkpoint;
không chỉ lưu hash hoặc selected SKU. Payload bắt buộc:

Đây là application DTO versioned, extra="forbid"; identity dùng UUID và revision
integer non-negative, timestamps UTC, monetary fields integer VND non-negative.
Normalized input tái sử dụng typed ComponentSpec/PCBuildConstraints đã validate,
không dùng dict[str, Any] làm contract optimizer. Policy maps dùng typed enum
profile/objective và finite numeric values; serialized ordering/hash được chốt
bằng golden fixtures. P0 DTO đã cụ thể hóa trong `provenance.py`; P3 capture actual
payload/config và P2/P4 persistence/replay adapter vẫn chưa triển khai.

| Field | Nội dung |
| --- | --- |
| identity | schema_version=1, conversation_id, run_id, base_revision, constraints_revision |
| constraints_snapshot | Merged values + source/lock/evidence, resolved owned/pinned, explicit budget scope/units, requested objective |
| catalog_snapshot | Canonical rows/fields dùng resolve/normalize: variant/SKU, visibility/stock/price, attributes/benchmark evidence, retrieved_at, backend revision nếu backend cung cấp |
| normalized_input | Toàn bộ ordered normalized candidates/ComponentSpec và effective spending mapping thực sự đưa vào optimizer; không chỉ final parts |
| synthetic_sources | iGPU/stock-cooler identity/kind, parent variant/evidence; không tạo commerce SKU giả |
| versions | graph/state/DTO, normalization/compatibility/optimizer/pruning/scoring/recommendation versions, engine code commit/artifact digest, Python/dependency lock digest |
| policy_snapshot | Resolved weights/tables/thresholds, tie-break/order rules, search limits/config, config hash, seed nếu có randomness |
| hashes | catalog_snapshot_hash, normalized_input_hash, optimization_input_hash, optimization_result_hash, recommendation_result_hash |
| results | Typed optimization outcome/result, recommendation decision/score breakdown/evidence; INFEASIBLE tách khỏi successful build |

Snapshot đủ để chạy optimizer offline mà không lấy catalog/policy hiện tại.
Nếu dùng immutable blob ref thay inline JSON, ref kèm digest và được giữ cùng
retention/lineage; missing blob/hash mismatch làm replay fail rõ ràng. Trước mắt
ưu tiên inline validated payload có size limit, không thêm storage platform.

Hash format V1: SHA-256 của application-canonical UTF-8 JSON: sorted object keys,
compact separators, enum/UUID thành string, UTC timestamps, finite numbers;
reject NaN/Infinity. Giữ array order nếu ảnh hưởng optimizer; set-like collections
normalize/sort trước hash. Có hash-format version và golden serialization tests.
optimization_input_hash bao gồm actual normalized input và effective algorithm/
policy config; audit run ID/retrieval timestamp đứng riêng, không đổi semantic
input hash chỉ vì được ghi nhận ở lượt khác. Snapshot/result hashes kiểm tra
integrity; không thay thế payload và versions/config thực tế.

Explanation provenance lưu trong checkpoint: input hash, prompt template/version,
provider/model/config, evidence/result refs, validated output và output hash.
Không lưu secrets/chain-of-thought. Text cũ đọc từ output đã lưu; LLM replay có
thể khác câu chữ. Chỉ claim optimizer reproducibility sau replay test đúng code/
config/environment. New build vẫn revalidate live visibility/stock/price; snapshot
lịch sử không trở thành dữ liệu catalog hiện tại.

### 7.3. Nhánh ngoại lệ

- Backend unavailable khác với search không có kết quả.
- Thiếu specs khác với không có nghiệm đáp ứng constraints.
- Không tự tăng budget hoặc bỏ pin/brand lock.
- Hỏi làm rõ kết thúc run với outcome cần input; conversation chờ lượt mới,
  không giữ worker/HTTP request chờ khách.
- Giới hạn timeout, số lần gọi model/tool và retry; lỗi terminal có static key.
- Fallback không bịa build hoặc facts và không xóa phương án đã công bố.

## 8. B4 — Runs, checkpoints và recovery

### 8.1. Concurrency/idempotency

- Unique `(conversation_id, request_id)` với payload hash; cùng key khác payload
  phải bị từ chối. Hoàn tất run được retry bằng kết quả đã commit.
- V1 chỉ một run đang xử lý trên mỗi conversation; request khác nhận busy.
- Lease/timeout + fencing ngăn worker hết quyền finalize/publish; claim/renewal
  dùng transaction/compare-and-set. Takeover phải thỏa điều kiện execution cũ đã
  dừng ở 5.3; timeout phía client hoặc mất heartbeat không đủ để cho phép takeover.
- Không giữ DB row lock trong lúc chờ LLM/backend/optimizer.
- Working checkpoints nằm trong thread chung và được liên kết đúng run/attempt;
  accepted reference chỉ được publish với revision/lease guard. Lỗi không
  overwrite head hoặc build đã công bố. Read/public/new-turn không dùng latest.
- Idempotency của run không thay thế command idempotency của commerce mutations.

Run statuses là enum: `PENDING`, `RUNNING`, `RECOVERING`, `WAITING_INPUT`,
`COMPLETED`, `FAILED_RETRYABLE`, `FAILED_TERMINAL`, `CANCELLED`. Luồng chính:

```text
PENDING → RUNNING → WAITING_INPUT / COMPLETED / FAILED_RETRYABLE / FAILED_TERMINAL / CANCELLED
FAILED_RETRYABLE → RECOVERING → RUNNING → outcome
RUNNING (process đã chết, có stop evidence) → RECOVERING → RUNNING → outcome
```

`WAITING_INPUT` kết thúc execution của lượt hỏi làm rõ; câu trả lời của khách tạo
run mới từ accepted head. Chuyển sang `RECOVERING` chỉ sau khi xác nhận execution
trước đã dừng, authorize và kiểm tra revision/version/checkpoint của run. Yêu cầu
cancel không đồng nghĩa worker đã dừng: chỉ ghi `CANCELLED` terminal khi executor
acknowledge/được xác nhận đã dừng và không còn writes đang chạy. Không resume run
đã bị thay thế bởi accepted revision mới hoặc tự hồi sinh run đã cancelled.

Failure semantics:

| Status/outcome | Có resume cùng run? | Điều kiện |
| --- | --- | --- |
| FAILED_RETRYABLE | Có, không tự động đồng nghĩa sẽ retry | Execution đã dừng; lỗi thuộc retry allowlist, còn attempt/time budget, checkpoint/input/version hợp lệ và accepted base chưa đổi |
| FAILED_TERMINAL | Không | Lỗi permanent, retry budget hết hoặc recovery không thể đúng; retry cùng request key trả saved failure |
| CANCELLED / COMPLETED / WAITING_INPUT | Không | Run đã kết thúc; WAITING_INPUT nhận câu trả lời bằng run mới |
| INFEASIBLE | Không phải technical failure | Optimization hoàn tất với domain outcome không có nghiệm; publish response rồi COMPLETED, không retry optimizer với input không đổi |

- Retry allowlist V1: transient upstream timeout/429/5xx và execution interruption
  có thể resume sau stop evidence. Authorization/input rejection không được biến
  thành retryable error; corrupted/missing required checkpoint, incompatible
  version không có migration hoặc lineage mismatch là terminal. Unexpected bug
  mặc định terminal và được ghi issue, không loop retry vô hạn.
- FAILED_RETRYABLE chỉ giữ khả năng recovery, không có worker đang chạy. Muốn
  bắt đầu lượt khác phải cancel/discard run này có kiểm soát hoặc resume xong;
  không bỏ unresolved working execution rồi lấy latest để tiếp tục conversation.
- Resume giữ run_id, request hash và base reference; tăng attempt/generation bằng
  CAS sau stop evidence. Retry request tự nó không tạo execution mới: trả status/
  saved result; command resume mới đi qua eligibility gate.
- retry_policy_version, max_attempts, attempt_count và retry_deadline được ghi khi
  claim run. B0 cấu hình giới hạn hữu hạn. Hết budget chuyển FAILED_TERMINAL;
  không reset budget theo mỗi request/restart. Không có checkpoint trước bước đầu
  thì chỉ retry từ stored initial input bằng đường native đã verify trong B1.
- Stage status FAILED của optimize/explain ở 6.3 chỉ mô tả bước; application error
  classifier quyết định run FAILED_RETRYABLE hay FAILED_TERMINAL. Hai enum không
  dùng thay nhau. Failed runs không publish accepted head hay assistant success.

#### 8.1.1. Execution-stop evidence V1

Mỗi executor có worker_instance_id mới cho mỗi process incarnation, execution_id
và lease generation gắn với run. agent_runs giữ identity, cancel_requested và
typed executor_stop_evidence. Không dùng PID đơn thuần vì PID có thể được reuse.

Invariant admission: đổi run status, kể cả sang COMPLETED, WAITING_INPUT,
FAILED_RETRYABLE, FAILED_TERMINAL hoặc CANCELLED, không tự giải phóng thread.
Admission phải verify stop evidence của execution sở hữu thread gần nhất, đúng
identity/generation và đã drain writes, rồi CAS claim generation mới. Không dùng
query chỉ lọc các run status đang chạy để suy ra thread rảnh. Evidence là điều
kiện chứng minh execution đã dừng; auth/revision/run eligibility vẫn phải pass.
Conversation chưa từng có execution dùng initial claim atomic, không cần stop
evidence giả cho một execution chưa tồn tại.

Chỉ hai loại evidence cho phép nhường shared thread:

| Evidence | Điều kiện kỹ thuật |
| --- | --- |
| EXECUTOR_STOP_ACK | Executor sở hữu đúng execution_id/generation đã kết thúc hoặc cancel-and-join graph task, đóng async stream/context, await mọi child task và pending checkpoint-write futures rồi ghi stop acknowledgement |
| PROCESS_TERMINATED | Trusted supervisor hoặc thao tác dev/operator được kiểm chứng xác nhận đúng process incarnation đã exit/terminate; checkpointer sessions/transactions liên quan đã đóng/settle, không còn write đang chạy |

Evidence lưu kind, execution_id, worker_instance_id, generation, stopped_at,
checkpoint_writes_drained=true và trusted proof reference. Chỉ internal executor/
recovery coordinator tạo/verify evidence; API client không được khai worker chết,
gửi stop_ack hoặc force đổi status để mở khóa thread.

1. Cancel chỉ ghi cancel_requested và gửi signal tới executor đang sở hữu run.
   Task cancellation request hoặc asyncio task đã nhận CancelledError chưa đủ;
   executor phải join/drain xong mới ghi EXECUTOR_STOP_ACK. Không để detached
   task giữ checkpointer hoặc ghi checkpoint sau acknowledgement.
2. Lease hết hạn/mất heartbeat nhưng không có evidence: giữ run chưa terminal,
   từ chối new execution bằng busy contract. V1 không tự takeover theo TTL.
   Remote instance không liên lạc được phải xác nhận process termination; không
   coi network timeout, Redis key mất, advisory lock mất hay DB status là evidence.
3. Recovery coordinator verify evidence khớp execution generation hiện tại rồi
   CAS claim generation mới và chuyển RECOVERING. Resume cùng thread từ working
   checkpoint đúng lineage. Evidence của attempt cũ không unlock attempt mới.
4. Sau normal completion cũng phải drain execution trước khi publish terminal
   outcome/nhường thread. Khi crash đã ghi READY_TO_PUBLISH nhưng chưa finalize,
   coordinator cần stop evidence rồi mới reconcile hoặc cho execution khác chạy.

B4 phải test runner bị chặn, cancellation chưa drain, heartbeat mất nhưng worker
còn sống, process termination thật, stale/wrong-generation evidence và hai
coordinator cùng claim. B0/B4 chốt adapter tạo termination proof theo môi trường
thực tế; trước khi có proof adapter thì recovery sau hard crash là fail-closed,
cần operator xác nhận, không quảng cáo automatic takeover.

### 8.2. Snapshot boundaries

LangGraph/Postgres saver chịu trách nhiệm snapshots và pending writes tại
super-step boundaries. Thiết kế sequential nodes để accepted constraints, catalog
normalization, optimization và explanation có boundary rõ ràng.

- Dùng synchronous durability mode cho các critical execution boundaries;
  verify API/semantics với phiên bản pinned. Không tự viết save/restore cursor.
- Đưa input/output/evidence cần tái hiện và graph/schema/engine/policy versions
  vào serializable state/metadata; checkpoint có sẵn không tự tạo provenance đủ.
- Không copy toàn bộ history vào mỗi checkpoint; snapshot/reference dữ liệu
  catalog phải đủ để tái hiện input optimizer và không bị sửa sau đó.
- Không lưu credentials, chain-of-thought hoặc mỗi token SSE.
- Có retention/deletion cho checkpoints và dữ liệu nhạy cảm.
- Checkpoint sau optimize chứa completion marker và optimizer result cùng hash;
  checkpoint sau explain chứa marker và explanation result tương ứng. Node
  chuẩn bị publication ghi `READY_TO_PUBLISH` cùng validated public payload.
  Không tạo bảng marker riêng hoặc ghi status/result vào hai nguồn state.

### 8.3. Finalization và reconciliation

Checkpointer và application ORM transaction không mặc nhiên atomic dù cùng
PostgreSQL. Thiết kế theo thứ tự:

1. Authorize; transaction application đọc accepted head/revision, claim run,
   persist user message một lần và ghi input/base reference cần restart.
2. Graph chạy ngoài transaction dài trên thread ổn định, bắt đầu từ base reference
   bằng đường native đã verify ở B1; checkpointer persist working state. Lưu/
   reconcile working refs theo run identity, không suy ra từ latest của thread.
3. Kiểm tra publish-lineage gate ở 8.3.1, marker READY_TO_PUBLISH và validated
   publication result; validate/sanitize lại tại public boundary.
4. Một application transaction publish accepted reference, assistant message và
   run outcome/final checkpoint reference với expected base revision và lease/
   fencing guard; tăng revision rồi mới phát SSE COMPLETED.

- Crash sau checkpoint `READY_TO_PUBLISH` nhưng trước finalize: retry đọc marker
  cùng publication result đã lưu rồi finalize idempotently, không chạy lại
  optimizer/LLM chỉ để tạo message. Chưa có marker này thì tiếp tục phần graph
  còn thiếu; không suy ra graph đã hoàn tất từ một field build/explanation.
- Crash sau finalize nhưng trước SSE: fetch/retry trả kết quả đã publish.
- Unique message/run identity ngăn duplicate inserts trong finalization.
- Không cập nhật conversation head bằng checkpoint chưa validate hoặc run đã
  mất lease. Checkpoint orphan/stale được cleanup theo policy.

#### 8.3.1. Publish-lineage gate

Cùng thread hoặc cùng ancestor accepted checkpoint chưa chứng minh candidate
thuộc run đang finalize. Application chỉ nhận final reference từ runner đã drain
hoặc authorized recovery source đã được ghi nhận; không chọn latest checkpoint.
Checkpoint refs/payloads được xem là immutable sau stop/drain; kiểm tra native
snapshot/parent metadata ngoài transaction dài rồi recheck guards trong CAS.

Gate bắt buộc:

1. Authorize owner; run.kind=CHAT, đúng conversation/thread và root namespace.
   DEBUG run/checkpoint không được publish qua chat finalizer, dù cùng thread.
2. Candidate đúng terminal ref đã runner trả hoặc recovery coordinator đã chốt.
   Native checkpoint context phải khớp run_id, request/input hash, base reference
   và graph/schema versions. Context do server đóng dấu trong framework metadata
   hoặc private validated channel đã test ở B1; client/LLM không được sửa context.
3. Đi theo native parent references từ candidate tới run input/resume boundary
   và base_checkpoint_ref đã claim. Phần lineage sau base thuộc đúng run và các
   execution/attempt được application cấp quyền; không chấp nhận sibling branch,
   checkpoint run khác/debug/orphan hoặc lineage không thể chứng minh.
4. Candidate generation là execution hiện tại, hoặc exact recovery_source_ref của
   stopped execution cùng run đã được coordinator authorize trong CAS recovery.
   Trường hợp crash sau READY_TO_PUBLISH có thể finalize output generation cũ,
   nhưng chỉ từ source ref đã validate/drain; không accept mọi checkpoint mang
   run_id cũ hoặc lấy checkpoint mới xuất hiện sau khi source ref được chốt.
5. Native terminal snapshot không còn next/tasks/interrupt hoặc pending work cần
   chạy. Phase READY_TO_PUBLISH, current_run_id, publication_input_hash và payload
   hash khớp validated input/results của run; required completion markers/outcome
   hợp lệ cho nhánh tương ứng. Marker một mình không thay thế lineage proof.
6. Application transaction recheck run chưa terminal, valid current lease/generation,
   stop evidence và authorized source unchanged; conversation revision/head vẫn
   bằng base_revision/base_checkpoint_ref. CAS update head, final_checkpoint_ref,
   assistant message và terminal outcome một lần. Replay cùng finalized ref/hash
   trả saved result, không tăng revision lần nữa; candidate khác bị từ chối.

Conversation đầu tiên có base null dùng native initial-input boundary đã được
B1 kiểm chứng; không coi mọi checkpoint parent-null trong thread là hợp lệ.
Missing ancestor/invalid hash/lineage mismatch từ chối publish, giữ accepted head
và ghi terminal error/issue; không sửa provenance hoặc seed values để lách gate.
Snapshot retention phải giữ các refs/ancestors cần chứng minh lineage của run.

### 8.4. Recovery/replay

- Resume từ native working checkpoint đã commit của run, trên cùng thread và chỉ
  sau khi execution trước đã dừng. Bước chưa commit có thể chạy lại. Nếu crash
  trước khi ghi working ref vào application DB, reconcile qua native checkpoint
  metadata/lineage của run; không chọn latest chung hoặc copy values làm cursor.
- Optimize đã có marker `COMPLETED` hợp lệ và explain lỗi: native resume tiếp tục
  bước explain. Nếu routing/retry đi vào optimize một lần nữa, node dùng guard
  completion + matching input hash + compatible versions để reuse result.
  Explain cũng áp dụng guard tương ứng; không tự điều phối cursor bằng phase.
- Nếu optimizer/LLM đã trả kết quả nhưng crash trước checkpoint commit, lời gọi
  có thể chạy lại. Completion markers không tạo exactly-once execution.
- Chỉ resume sau khi authorize và kiểm tra compatibility của versions.
- FAILED_TERMINAL không chuyển RECOVERING. FAILED_RETRYABLE chỉ resume sau toàn
  bộ eligibility/stop-evidence gate; trạng thái RUNNING bị mất heartbeat không
  tự được coi là recoverable nếu chưa xác nhận execution cũ đã dừng.
- Version không tương thích phải migrate hoặc từ chối rõ ràng.
- Replay debug dùng native checkpoint branching có parent reference và tuân thủ
  serialization của cùng thread; không tự promote kết quả vào accepted head.
  Debug checkpoints không trở thành base cho lượt khách tiếp theo chỉ vì mới hơn.
- Tái lập optimizer yêu cầu input, code và policy tương ứng.
- Gọi lại LLM không đảm bảo cùng câu chữ; xem câu cũ bằng output đã lưu.
- Không tự replay side effects. Không claim exactly-once execution.

Không viết lại checkpoint runner hoặc thêm agent runtime điều phối bên trong node.
LangGraph runtime xử lý checkpoint/resume; application
vẫn sở hữu auth, concurrency, retention và business finalization. Checkpointing
không đồng nghĩa có background scheduler hoặc exactly-once LLM/tool execution.

## 9. B5 — HTTP/SSE và frontend

### 9.1. API đề xuất

- Tạo/list/get conversation và xóa theo policy.
- Đọc messages phân trang và sanitized public state.
- Gửi chat với `request_id`, `conversation_id`, expected revision.
- Xem trạng thái run, cancel/resume có kiểm soát.
- Debug checkpoint/replay không mặc nhiên là API công khai cho khách; chốt
  riêng quyền truy cập và redaction trước khi expose.

Tên route/request DTO/status/error enums được chốt ở B0. Giữ `/api/v1` tại AI;
external gateway route assistant và BFF phải thống nhất, không thêm prefix khác.

### 9.2. Streaming

- Giữ `START`, `DELTA`, `COMPLETED`, `ERROR`; bổ sung progress/state/build events
  có schema/enum và contract tests.
- Mỗi frame vẫn có `{data, message, errors}`.
- Public payload có conversation/run identity và revisions cần thiết; không
  expose internal snapshots, prompt hay credentials.
- Không forward raw LangGraph state/events hoặc model SDK messages/events ra FE.
  Dùng allowlisted public DTO mapper; private graph channels không phải security
  boundary. Model text deltas và LangGraph progress được map thành SSE chuẩn.
- `COMPLETED` chỉ phát sau transaction commit thành công.
- Chốt disconnect/cancel: bản đầu không auto gửi lại message hoặc giữ background
  run vô hạn; khi request dừng phải finalize/cancel hoặc đi qua recovery eligibility
  và stop-evidence gate, không recover chỉ vì lease timeout.
- Không hứa replay từng token. Reconnect fetch run status/kết quả đã commit.

### 9.3. Frontend

- Conversation ID trong URL; reload load history/state từ server sau authorize.
- Không coi localStorage là nguồn state chính; đổi account không reuse cache
  hoặc history của account trước.
- Một chat workspace: questions, progress, build cards và thay đổi giữa builds.
- Request/response schemas, enums, feature models/mappers riêng; generated
  OpenAPI là contract tham khảo, không alias trực tiếp domain model.
- Skeleton/loading, abort, busy, stale revision, timeout và reconnect rõ ràng.
- Mất stream: đọc trạng thái run thay vì gửi lại thành một lượt chat mới.
- Giữ Ask-AI prefill editable; không tự send hoặc attach demo IDs như SKU thật.

## 10. B6 — Kiểm thử và audit

| Scenario | Acceptance |
| --- | --- |
| “25 triệu” → “gaming 1440p” | Giữ budget và bổ sung use case đúng |
| Restart service rồi chat tiếp | History/state còn nguyên trong PostgreSQL |
| “Giữ GPU” | GPU pinned vẫn tính chi phí mua; không bị coi là owned |
| Owned part | Spending theo rule và explanation tổng khớp engine |
| Retry request | Không trùng message/build; payload mismatch bị từ chối |
| Hai request cùng lúc | Không lost update hoặc hai run xử lý trùng |
| Nhiều lượt của một conversation | Dùng một stable thread, giữ native checkpoint lineage; run metadata phân biệt từng lượt |
| Latest khác accepted vì orphan/stale/debug checkpoint | Public state và lượt mới dùng accepted reference; không lấy latest mặc định |
| New input từ accepted head trên pinned version | Native invoke/fork semantics đúng, không replay ngoài ý định; reducers và markers thuộc lượt mới |
| Run bị lỗi/restart giữa lượt | Resume đúng working checkpoint cùng thread, không khởi động lại từ accepted head |
| Mất heartbeat nhưng worker chưa được xác nhận dừng | Không takeover hoặc chạy recovery đồng thời; run chưa terminal, request khác nhận busy |
| Cancellation chưa acknowledge | Không coi execution đã dừng hoặc nhường shared thread cho worker khác |
| Run status terminal nhưng thiếu stop evidence hợp lệ | New turn/resume/debug vẫn bị chặn; đổi status không tự giải phóng shared thread |
| Stop evidence khác execution/generation hoặc chưa drain | Không claim RECOVERING hoặc mở shared thread; client không giả mạo evidence được |
| Worker đã terminate, native writes đã settle | Coordinator claim bằng CAS, resume đúng working ref; hai coordinator không cùng execution |
| FAILED_RETRYABLE / FAILED_TERMINAL | Chỉ retryable đi RECOVERING khi đủ guards; terminal trả saved failure, không chạy lại |
| Retry vượt attempt/deadline budget | FAILED_TERMINAL; request/restart không reset budget |
| Final checkpoint cùng thread nhưng khác run/input/base/branch | Reject publish; accepted head/messages/revision không đổi |
| DEBUG/orphan checkpoint có READY_TO_PUBLISH | Không bypass lineage gate bằng marker hoặc same-thread identity |
| Recovery output thuộc generation cũ | Chỉ exact authorized source ref được finalize dưới lease mới; stale ref khác bị reject |
| Lineage thiếu ancestor hoặc native snapshot còn pending work | Không publish dù payload đầy đủ; lỗi rõ ràng |
| Hai finalizer hoặc retry sau commit | CAS publish một lần; same ref/hash trả saved result, khác ref bị reject |
| Patch absent / SET / CLEAR / null | Absent giữ nguyên, typed SET thay thế, CLEAR thành unknown/gỡ binding, null/malformed/extra field reject |
| Patch có nhiều operations và một operation lỗi | Không partial apply; locked/source/revision rules vẫn được enforce |
| Owned/pinned trùng slot hoặc chuyển loại | Reject xung đột; chuyển bằng CLEAR+SET atomic, không tự đổi ownership |
| Owned exclude true/false và pinned | Spending lần lượt 0/reference price/reference price; price gốc giữ nguyên, pin được giữ qua pruning |
| Pin sai category/ID/inactive/out-of-stock | Không tự substitute, không dùng client specs hoặc biến tên tự do thành SKU |
| Replay optimizer sau catalog/policy hiện tại đã đổi | Dùng snapshot payload/config đã lưu, không gọi live catalog; input/results được verify bằng hash |
| Replay snapshot missing/blob hash mismatch/version không tương thích | Fail rõ ràng, không fallback sang current catalog/default policy |
| Worker mất lease | Không commit kết quả sau takeover |
| Optimize xong, explain lỗi | Marker/result/hash đã commit; resume không gọi lại optimize với cùng input |
| Node optimize bị routing/retry gọi lại | Marker hợp lệ và matching hash reuse result; không chỉ kiểm tra field khác null |
| Constraints/catalog/engine version thay đổi | Hash đổi; invalidate optimize và các kết quả phụ thuộc, không reuse build làm việc cũ |
| Câu hỏi/locale/prompt version thay đổi | Invalidate explanation/publication; giữ optimization hợp lệ khi input optimize không đổi |
| Marker COMPLETED thiếu result/hash hoặc result không hợp lệ | Validation từ chối state mâu thuẫn; không silently skip hoặc publish |
| Optimizer trả INFEASIBLE | Phân biệt computation hoàn tất với build thành công; không publish build giả |
| Optimizer/LLM trả kết quả nhưng checkpoint chưa commit thì crash | Cho phép chạy lại bước chưa durable; không claim exactly-once |
| Checkpoint READY_TO_PUBLISH, chưa finalize thì crash | Reconcile một lần từ validated publication result, không gọi lại LLM/optimizer |
| Stale/orphan checkpoint được ghi muộn | Không đổi accepted head; latest không được dùng làm public state hoặc new-turn base |
| Native state/reducer update | Pydantic boundary validation và domain merge rules được enforce |
| Stream private channel | Không lộ internal state/prompt qua public SSE |
| Model structured extraction | TurnPatchV1 được validate trước merge; refusal/truncation/null/extra fields không tạo partial state |
| Provider SDK retry và graph retry | Cùng budget hữu hạn, không nhân số model calls ngoài policy |
| Migration model/graph adapters | Shopping/comparison/SSE regressions pass; dependency removal chỉ khi không còn legacy imports/callers |
| Catalog lỗi/inactive/thiếu specs | Không bịa dữ liệu, không xóa build cũ |
| Constraints mới không có nghiệm | Không tự bỏ yêu cầu; build cũ đánh dấu stale |
| Owner khác hoặc JWT không hợp lệ | Không read/write/cancel/resume được |
| Reload hoặc đứt stream | FE khôi phục history và kết quả đã commit |
| Schema/graph version khác | Migration hoặc lỗi rõ ràng, không resume nhầm |

Regression tests theo TDD; DB constraints/race/restart tests dùng PostgreSQL thật,
không coi SQLite/mock là bằng chứng tương đương. LLM tests dùng validated fixtures;
live provider smoke tests opt-in và phải ghi rõ môi trường/kết quả.

Quality gates: pytest, Ruff, mypy, dependency lock, migration verification,
compose config, API/SSE contract tests, FE tests/typecheck/lint và browser acceptance.
Phân biệt source-level, in-process, DB integration và live end-to-end evidence.

## 11. Thứ tự commit và handoff

1. Spec + contracts + tracker.
2. Application DB migration + checkpointer bootstrap + auth/ownership + async store.
3. State extraction/merge.
4. Canonical catalog mapping.
5. LangGraph integration với model-port nodes; migrate legacy provider/graph callers.
6. Run/checkpoint recovery và finalization reconciliation.
7. API/SSE.
8. FE conversation persistence/build presentation.
9. Integration audit + docs/tracker.

Commit nhỏ theo từng slice đã verify; không gom thay đổi user sẵn có một cách
vô thức. Không push/commit khi chưa có yêu cầu tương ứng.

## 12. Quyết định còn phải chốt

- V1 đã chốt login-only; guest ngoài scope, cần contract riêng khi triển khai sau.
- Retention/deletion đã chốt: chat/run/checkpoint 90 ngày; orphan/debug checkpoint
  7 ngày; xóa conversation xóa mọi dữ liệu liên quan. Cleanup/deletion thực tế
  thuộc P2/P4/P5, phải dừng/drain execution trước purge để tránh ghi lại dữ liệu.
- Canonical hardware metadata, benchmark provenance và readiness của catalog.
- Budget đã chốt BUILD_PC/FULL_SETUP, phụ kiện tối đa một cái/type, không tự chia
  tỷ lệ; thiếu ngân sách phụ kiện thì hỏi user. ISSUE-080 đóng ở mức requirement.
- Xác nhận scope owned ngoài catalog và metadata readiness;
  V1 ref-only contract ở 6.2 không phải bằng chứng source hiện tại đã support đủ.
- Debug/replay chỉ internal, không được publish kết quả thật; ISSUE-081 đóng ở
  mức requirement. Policy versions và snapshot compatibility còn cần DTO.
- B1 chốt native API/config tạo lượt mới từ accepted checkpoint bằng pinned-version
  PostgreSQL integration gate; B4 chốt bằng chứng executor đã dừng trước takeover.
- Chốt/lock dependency versions và checkpointer bootstrap/retention workflow;
  contract tests cho model structured output/streaming, native checkpoint và public SSE.

Các điểm chưa chốt được ghi thành issue khi bắt đầu B0. Tiếp tục phần không bị
ảnh hưởng; chỉ BLOCKED feature cần quyết định đó để implement đúng.

Failure semantics và publish-lineage invariant đã được chốt trong plan revision 6.
Có thể bắt đầu B0/B1 cho contracts, DB metadata, ownership và native graph spike.
Exact LangGraph version/API là gate hoàn thành B1, metadata catalog là gate của
real-catalog B3; các mục còn mở không chặn mọi công việc nhưng phải đóng trước
feature phụ thuộc. Không đánh dấu batch COMPLETED chỉ từ thiết kế này.

## 13. Tài liệu tham khảo

- [LangGraph persistence](https://docs.langchain.com/oss/python/langgraph/persistence):
  thread-scoped checkpoints khác với cross-thread memory.
- [LangGraph checkpointers](https://docs.langchain.com/oss/python/langgraph/checkpointers):
  snapshot boundaries, recovery và replay semantics.
- [LangGraph time travel](https://docs.langchain.com/oss/python/langgraph/use-time-travel):
  replay từ checkpoint cũ, native fork/update state và routing semantics.
- [LangGraph Graph API](https://docs.langchain.com/oss/python/langgraph/graph-api):
  state schema/reducers, node functions và streaming boundaries.
- [Google ADK state](https://adk.dev/sessions/state/): history/events và state
  được quản lý riêng, cập nhật qua lifecycle có persistence.
- [LangChain models](https://docs.langchain.com/oss/python/langchain/models):
  direct model structured output bằng Pydantic schema, methods và streaming.
- [LangChain structured output](https://docs.langchain.com/oss/python/langchain/structured-output):
  ProviderStrategy/ToolStrategy thuộc create_agent; phân biệt với direct model API.
- [SQLAlchemy asyncio](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html).
- [Alembic cookbook](https://alembic.sqlalchemy.org/en/latest/cookbook.html).

Học pattern từ tài liệu công khai; không suy đoán schema nội bộ ChatGPT/Gemini.
