# Plan — Conversational ReAct theo state

Ngày: **2026-10-23** · Trạng thái: **IMPLEMENTED — live eval hoãn theo owner**.
Phạm vi: `UC-AI-001/003/004/005` · Theo dõi: `ISSUE-149`.

**Mục tiêu:** agent trò chuyện tự nhiên, dùng được state trước đó và gọi tool khi
cần; application vẫn kiểm soát thay đổi requirements và tính đúng của kết quả.

Plan này mô tả thiết kế đích; tiến độ và evidence nằm ở §9. Owner đã yêu cầu
triển khai và push khi hoàn tất; chưa cho phép deploy. Owner xác nhận “hoãn live
eval, push”: nghiệm thu code bằng regression, không tuyên bố chất lượng model thật.

## 1. Vấn đề cần giải quyết

| Vấn đề | Hướng sửa |
| --- | --- |
| Hội thoại bị ép vào task/evidence contract | Tách response của turn khỏi completion của task |
| Model phải xuất full `FlexibleDecision` cho non-tool | Text thường hoặc native control call nhỏ |
| Câu hỏi chen ngang có thể làm mất task/proposal | Dùng context để trả lời, giữ pending có binding |
| Model tự khai outcome dễ vượt nghiệp vụ | Model chọn evidence; application xác định outcome |

Baseline phân tích: AI `b9a2e85`. ISSUE-148 đã tách task extraction và requirement
extraction; giữ phân tách này. Probe baseline ghi nhận 23.315 ký tự system + tool
schemas. Đây không phải token count và chưa chứng minh schema là nguyên nhân duy
nhất gây gọi tool thừa; chất lượng phải đo bằng scenario thực tế.

## 2. Flow đích

```text
Message / explicit command + exact accepted head
                         ↓
Load bounded conversation context
                         ↓
Register/continue business tasks nếu có
                         ↓
                       Agent ←───────────────────────────┐
  ├─ Text response                                      │
  ├─ Propose requirements → extract → resolve → admit/merge
  ├─ Ask clarification → application bind pending        │
  └─ Native tool → policy → service → canonical result ──┘
                         ↓
Validate turn response + business completion riêng
                         ↓
Prepare snapshot → stop proof / lineage / CAS → publish
```

Một LangGraph runtime, managed executor và canonical ledger như hiện tại.
Không thêm agent runtime, keyword router hoặc LLM gọi riêng để chọn schema.

| Component | Trách nhiệm | Không được làm |
| --- | --- | --- |
| Task extractor | Nhận diện kết quả nghiệp vụ user yêu cầu, hiểu follow-up | Extract ngân sách/linh kiện; quyết định tool sequence |
| Requirement extractor/resolver | Tạo typed draft, đối chiếu source, resolve tên/đơn vị | Tạo UUID giả; tự cấp consent |
| Agent | Hiểu context, chọn trả lời/hỏi/tool/đề xuất | Tự sửa trusted state hoặc tuyên bố task đã xong |
| Application services | Admission, merge, policy, optimizer, evidence validation | Tin model output chỉ vì đúng Pydantic schema |
| Publication/coordinator | Revalidate snapshot, ownership, lineage, stop proof, CAS | Publish working state chưa hợp lệ |

Requirement extraction nằm trong nhánh thay đổi requirements, không phải bước
bắt buộc trước mọi câu hỏi. Mỗi lần extraction có một trách nhiệm; không gọi
requirement extractor thêm lần nữa chỉ để lấy task.

## 3. Context phải được sử dụng, không chỉ được giữ lại

Projection gửi model lấy từ accepted head và working state đã được application
chấp nhận trong run. Không gửi nguyên persistence DTO hoặc toàn bộ lịch sử.

| Context | Dùng vào việc gì |
| --- | --- |
| Accepted requirements/workload | Hiểu nhu cầu, giải thích đánh đổi |
| Saved build + refs | Resolve “con đó”, “cấu hình này”; đọc snapshot không optimize lại |
| Pending task/proposal/clarification | Biết user đang hỏi về, sửa hay xác nhận điều gì |
| Bounded published history | Resolve referent chưa đủ trong structured state |
| Current-run requirements/results | Quan sát thay đổi/tool vừa chạy, chưa coi là đã publish |

Giữ rõ nhãn **accepted / proposed / historical / current-run**. Proposal không
phải lựa chọn đã chốt; giá snapshot không phải giá hiện tại. Nhiều referent hợp
lý thì hỏi lại. Không load full hardware catalog chỉ để đọc saved snapshot.

Ví dụ accepted build RAM 16GB, proposal nâng 32GB đang chờ:

| User nói | Phản hồi đúng | State sau turn |
| --- | --- | --- |
| “RAM đang chọn bao nhiêu?” | Đọc 16GB từ accepted build | Không đổi |
| “Nâng lên vậy có lợi gì?” | Giải thích 32GB theo proposal và workload | Giữ proposal, chưa nâng RAM |
| “Giá con RAM đó bây giờ?” | Resolve đúng model rồi đọc catalog mới | Giữ task/proposal cũ |
| “RAM dùng để làm gì?” | Giải thích kiến thức chung, có thể liên hệ build | Không ép tool |
| “OK” | Chỉ áp dụng khi có confirmation binding hợp lệ | Merge đúng proposal đã xác nhận |

**Câu hỏi phụ không có giá trị bằng 0:** nó có thể đọc state, gọi tool và tạo
response có evidence. Nó chỉ không tự hoàn tất hoặc sửa task gốc.

Text không tự thành confirmation, REPLACE hay DISCARD. Giữ command/binding hiện
có; chưa có authority thì hỏi/hướng dẫn xác nhận, không tự hiểu “OK” thành consent.

## 4. Contract của turn, task và state

### 4.1 Response khác task outcome

- Task extraction có thể trả `tasks=[]` cho hội thoại không có yêu cầu nghiệp vụ.
  Provider error/malformed output không được đổi thành danh sách rỗng.
- Response kết thúc lượt hiện tại; task cũ có thể vẫn chờ input.
- Câu hỏi phụ không ghi đè task pending thành task ANSWER mới.
- BUILD/COMPARE mới vẫn phải đáp ứng completion contract; advice không thành BUILT.
- Run COMPLETED là execution/publication xong, không tự chứng minh nghiệp vụ xong.
- Giữ batch multi-task hiện có; không thêm backlog nhiều workflow.

### 4.2 Working state và publication

Working state ở checkpoint; accepted state chỉ đổi sau validation + CAS.
Giữ `conversation_revision` cho publication, `requirements_hash` cho nội dung;
không thêm hai counter accepted/working.

Model đề xuất, application admission/merge. Explicit user instruction phải có
source-bound evidence; agent đề nghị nới constraint cần confirmation riêng.
Không giảm RAM để tăng GPU rồi gán đó là yêu cầu của user.

### 4.3 Pending và consent qua nhiều lượt

```text
revision 4: proposal P, hash H, target_revision=4
revision 5: trả lời câu hỏi về P; P/H/target_revision còn nguyên
confirm: expected_revision=5; binding vẫn P/H/target_revision=4
```

Tái sử dụng original stored proposal binding và current CAS revision.
Carry nguyên pending artifact/source qua side response; không rehash/rebind.
Nếu underlying requirements đã đổi thì không tái sử dụng consent cũ.
Không tự hủy proposal chỉ vì user vừa hỏi thêm một câu.

## 5. Model protocol và validation

### 5.1 Model chỉ cần text hoặc native call

| Output | Ý nghĩa |
| --- | --- |
| Plain assistant text | Candidate response hội thoại; không phải business completion |
| `propose_requirements` | Đề xuất thay đổi; đi qua extraction/resolution/admission/consent |
| `ask_clarification` | Hỏi thông tin thiếu, bind pending nếu có artifact thật |
| `submit_result` | Chọn task/evidence/build refs; application suy ra outcome |
| Native business tool | Giữ tools hiện có; expose subset theo trusted state |

`submit_result` không nhận outcome/status do model tự khai. Grounded response
chen ngang phải biểu diễn được việc chọn evidence **không hoàn tất task pending**
(trong bản đang triển khai: `task_index=null`).

Không gửi full `FlexibleDecision`/publication DTO vào prompt. Union nội bộ có thể
giữ để normalize hoặc đọc persisted payload; không fallback ngầm sang JSON protocol cũ.
Không chuyển nguyên union dài sang tool schema rồi coi là đã đơn giản hóa.

Control actions không là business ToolResult. Nếu gọi model tiếp, project matching
AIMessage/ToolMessage từ transition đã checkpoint; giữ call ID, thứ tự và opaque
provider signatures. V1 một call mỗi response; reject cả malformed/multiple calls,
repair hữu hạn, giữ durable attempt budget. Tool policy kiểm tra lại trước dispatch.

### 5.2 Hai validation độc lập

| Loại kết quả | Điều kiện trước publish |
| --- | --- |
| Hội thoại/kiến thức chung | Không bắt buộc external evidence; không giả facts nghiệp vụ |
| Giá/stock/SKU hiện tại | Canonical catalog, đúng entity/context |
| Giải thích build cũ | Exact authorized snapshot; phân biệt historical/current |
| Benchmark/performance | Evidence có điều kiện đo; thiếu thì nói thiếu |
| BUILT | Verified optimizer result cho requirements hiện tại |
| INFEASIBLE | Proof trong candidate scope xác định |
| SEARCH_INCOMPLETE | Chưa tìm được nghiệm; không được nói “không tồn tại” |
| COMPARE completed | Coverage đủ các sản phẩm được yêu cầu |

Grounding kiểm tra dựa vào nguồn nào; completion kiểm tra đã đáp ứng task chưa.
Refs hợp lệ/Pydantic pass không bảo đảm mọi prose đều đúng. Facts quan trọng render
từ typed evidence; model diễn giải. Semantic quality có eval riêng, không thêm
regex/LLM fact checker toàn năng.

## 6. Phạm vi và compatibility

**Giữ nguyên:** stable conversation/thread, PostgreSQL checkpointer, managed executor,
accepted head, native recovery, stop proof/lineage/fencing/CAS, idempotency, login-only,
basic SSE và envelope `{data,message,errors}`. Không đổi optimizer/compiler/verifier.

**Không làm:** framework mới, auto-memory, SSE reconnect, GPU training, FE/BE refactor,
deploy hoặc xử lý mọi edge case của hội thoại.

Trước đổi DTO phải inventory snapshot/checkpoint/request hash/receipts/pending.
Ưu tiên optional additive fields; chỉ thêm SQL migration nếu representation thực
sự cần. Không rewrite lịch sử/hash, reset DB, copy `values` sang thread mới hoặc
tăng version để né test. Test **new turn từ old accepted state** và **resume old
in-flight run** riêng. Nếu topology/protocol phá resume, phải chốt version policy
trước khi vượt gate.

## 7. Phases triển khai

Làm tuần tự; mỗi phase ghi behavior, files, commands/results và việc còn thiếu.

| Phase | Deliverables | Gate |
| --- | --- | --- |
| P0 — Baseline/contracts | Regression hội thoại/pending; inventory persisted contracts; chốt §3–5 | Tái hiện lỗi và có acceptance/compatibility policy rõ |
| P1 — Stateful dialogue | Optional task; response riêng; context projection; pending-preserving publication | HTTP/run → publish → PostgreSQL reopen; xác nhận proposal cũ ở revision mới |
| P2 — Native model protocol | Text/control calls gọn; graph dispatch; canonical outcomes; protocol projection | Không full union; validator không bị bypass; provider và native resume tests pass |
| P3 — Parity/eval/docs | Serving/training dùng chung projection/parser; full regression; live scenarios; docs/handoff | Runtime/persistence/parity pass; model quality báo riêng, không giả là đã đo |

Bản đồ source, tương đối với `ai-service/src/ai_service/`:

- **P0/P1:** `requirements/tasks.py`, `react/{task_resolution,contracts,published_state,snapshot_publication}.py`, `infrastructure/graph/flexible.py`, execution/context projections.
- **P2:** `infrastructure/providers/react_model.py`, `react/actions.py`, control/submission contracts và provider adapters.
- **P3:** `training/{dataset,export,evaluation}.py`, Qwen protocol, focused tests và docs.

Không bắt buộc sửa mọi file. Reuse validators/services hiện có; không xóa rejection
tests build/consent để cho text đi qua.

## 8. Nghiệm thu tập trung core

| Scenario | Phải chứng minh |
| --- | --- |
| Greeting/general knowledge | Không tạo task/tool giả |
| Câu hỏi về saved build | Đúng snapshot, không optimize/catalog I/O thừa |
| Câu hỏi về pending proposal | Hiểu proposal/workload, giữ accepted/pending/source |
| Giá hiện tại của “con đó” | Resolve đúng sản phẩm rồi đọc evidence mới |
| Side response → confirm | Original binding còn hợp lệ; áp dụng một lần qua current CAS |
| Build thiếu/đủ dữ liệu | Clarification hợp lý hoặc verified build; không hoàn tất bằng advice |
| Compare/multi-task | Đủ coverage, không mất task chưa xong |
| Model/tool lỗi | Không biến thành success hoặc drop pending |
| PostgreSQL reopen/resume | Đúng head, requirements/build/pending và committed outcomes |
| Training/inference | Cùng protocol/projection; không auto-approve/relabel dataset cũ |

Đo paired scenarios trên cùng model/config: đúng context, task fulfillment, tool
thừa, parse/repair, calls, latency và usage nếu có. Đo cả system + schemas + context;
không lấy schema nhỏ hơn làm bằng chứng UX tốt hơn. Không có provider thì ghi live
gate **UNVERIFIED**, không tự coi là đã pass. Owner đã đồng ý hoãn riêng live eval
để giao code; quality eval vẫn cần chạy trước khi đánh giá/promote model.

Gate cuối, từ `ai-service/`:

```sh
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run pytest -q integration_tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run ruff check src tests integration_tests
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv run mypy src
UV_CACHE_DIR=/tmp/pc-shopping-uv-cache uv lock --check
```

Integration dùng DB test được cấu hình, không reset dữ liệu dùng chung.
Export có protocol version; regenerate bằng tooling hiện có, không overwrite
adapter/artifacts đã train hoặc tự đổi approval/label của pilot dataset.

## 9. Tiến độ và handoff

Trạng thái dưới đây gồm gate mới và handoff từng phase. Historical test counts
ở handoff cũ không thay thế full gate P3.

| Phase | Trạng thái ghi nhận | Còn thiếu |
| --- | --- | --- |
| P0 | COMPLETED | — |
| P1 | COMPLETED | — |
| P2 | COMPLETED | — |
| P3 | COMPLETED | Live paired eval được owner hoãn; chưa có quality evidence |

Tài liệu nguồn cần đồng bộ khi implementation được xác minh:
[agent/tools](agent-tools.md), [context/recovery](context-management.md),
[requirements](requirements.md), [architecture](../02-architecture/ai-architecture.md),
[API V2](../05-api/stateful-chat-v2.md), [training](training.md),
[implementation status](stateful-implementation-status.md) và root tracker.
Plan không thay thế các trang kiến trúc/contract này.

Chi tiết handoff cũ được giữ bên dưới để không mất evidence; đọc §1–8 để review
thiết kế. Push sau khi hoàn tất gate, hoặc khi owner đồng ý hoãn riêng live eval.

### P0 handoff — 2026-10-23

- Owner yêu cầu implement toàn plan và push khi hoàn thành; không deploy.
- Baseline `uv run pytest -q tests`: **867 passed** trước khi thêm regressions.
- `tests/test_conversational_turns.py`: **3 failed** đúng lỗi cần sửa: empty tasks, no-task response và câu hỏi về proposal bị ép hoàn tất BUILD.
- Contract chốt: response riêng với task outcomes; thêm response representation có thể cùng tồn tại với original pending. Không nới business `validate_answer` hoặc tạo task giả.
- Persisted inventory: `FlexiblePublishedState`, `AcceptedConversationSnapshot`, `FlexibleExecutionContext`, request hash, pending proposal/resolution/source và graph checkpoint channels. Existing proposal validator đã hỗ trợ original revision.
- P1 ưu tiên optional snapshot field/new internal action, giữ node names/native cursor và old payloads; không cần SQL migration cho representation này. PostgreSQL reopen/resume là gate bắt buộc, không suy từ unit tests.
- Next: P1; P2/P3 chưa bắt đầu. Model-quality baseline và paired evaluation chưa chạy.

### P1 handoff — 2026-10-23

- Added internal RESPOND/ConversationResponse; published response can coexist with original WAITING_INPUT task/artifact. Fresh empty-task conversation gets no fabricated task outcome.
- Context carries accepted proposal changes/source/question; response publication independently revalidates unchanged requirements, pending payloads, receipts and selected evidence. Business validate_answer remains strict.
- 95 focused unit tests pass. 12 API/PostgreSQL tests pass: 2 new native reopen cases, 7 existing managed publication/CAS cases, 3 existing HTTP cases. Ruff and mypy pass at this gate.
- Native chain root → proposal → side response → original confirmation at later revision applies once; tampering and duplicate confirmation reject. New tests use real PostgreSQL and fixture models, not live LLM.
- Storage adds an optional response field, no SQL migration or graph-node/version change. Old accepted/receipt payloads remain readable; full-suite compatibility will be rerun at P3.
- Next: P2 model protocol; current provider still uses the old JSON envelope during this intermediate phase. No commit/push/deploy yet.

### P2 handoff — 2026-10-23

- Live adapter now accepts plain text as RESPOND and native propose_requirements/ask_clarification/submit_result. No JSON decision envelope or schema union in the prompt; old stored decisions still decode at the persistence boundary.
- ResultSelection contains no outcome/status. Application derives outcomes from selected canonical records and existing verifiers; task_index=null produces a grounded response without completing pending work.
- Control acknowledgements are checkpointed separately from business ToolResult, projected into matching native pairs in model-step order, including opaque Gemini signatures. Native resume reuses a committed requirement transition.
- New tests were red before implementation: 8 protocol failures, one pre-existing multiple-call rejection green. New focused tests now 21 pass; broader native/graph/PostgreSQL resume gate 58 pass; mypy passes. Full P1 unit gate also passed at 872 tests.
- Empty-context request measured 1,819 system characters + 10,559 native-schema characters = 12,378 total versus 23,315 before (~47% fewer characters). Tool definitions are counted; no token/latency/quality claim inferred.
- Native provider fixtures moved to explicit native calls; raw fake Provider remains unchanged. Legacy JSON is rejected, not adapted as live fallback.
- Next: P3 training/export/evaluation parity and full verification. Local provider=fallback, no model credentials/endpoint; live paired gate needs owner configuration or explicit deferral. No commit/push/deploy yet.

### P3 handoff — 2026-10-23

- Serving/export/evaluation dùng chung text/native protocol. Export manifest ghi `text-native-controls-v1`; outcome do application suy ra, không model label tự cấp authority.
- 22/25 pilot ReAct labels roundtrip đúng action; 3 DRAFT clarification labels `react-13/14/15` bị export chặn vì không có registered task. Giữ nguyên 51 samples/snapshot hashes/approval; manual dataset review thuộc ISSUE-138.
- Full gate: **897 unit + 96 PostgreSQL integration tests**, Ruff (src/tests/integration/migrations), mypy206 và lock167 pass. Integration suites phải chạy tuần tự trên shared test DB vì managed executors claim global pending runs; concurrent suites không là evidence hợp lệ.
- Managed HTTP/native fixture verifies greeting → BUILD clarification → unit consent → question about proposal; publication preserves proposal/tasks without hardware I/O. Native saver reopen tests cover original confirmation at a later revision. These are fixture-model tests, not live LLM quality.
- Requirements-only dialogue supports source-admitted merge or separately confirmed proposal, without fabricated BUILD. Reused publication replay validates the change; stale side-response text is cleared for a later unresolved selection. SSE product cards use selected refs from either response or business answer.
- Architecture, agent/provider/state/API/training docs updated. No SQL migration, framework/dependency, runtime fallback, backend repin or deploy.
- **Deferred by owner:** live paired scenarios from §8. Explicit instruction: “hoãn live eval, push”. Keep live quality UNVERIFIED; configure local provider and run paired scenarios later under the existing evaluation workstream, without automatic model promotion.
- AI `781d2d2` pushed to `origin/release/v1.0.0`. This triggers CI/image publishing, not deployment. Docs publication uses its independent `main` branch; backend submodule was not repinned.
