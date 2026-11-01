# Plan — Agent-first cho pending replies

Ngày: **2026-10-23** · Trạng thái: **CHỜ REVIEW — chưa implement**.
Liên quan: `UC-AI-001/003/004/005`, `ISSUE-150`.
Tiếp nối [conversational refactor](conversational-agent-refactor-plan.md), không viết lại kiến trúc.

## 1. Vấn đề đã tái hiện

Baseline AI `781d2d2`. Conversation đang chờ đơn vị của “SSD 1”, user hỏi:
**“SSD khác RAM như thế nào?”**

```text
interpret_reply → model chọn đơn vị, không có lựa chọn
amend_pending   → model kiểm tra sửa requirements, không có sửa đổi
agent           → model trả lời câu hỏi
```

Probe trên graph thật với scripted models: **3 model calls, 0 tool calls**, pending
được giữ nguyên. Đây là overhead orchestration đã chứng minh; chưa đo latency/token
hoặc kết luận nó là nguyên nhân duy nhất khiến model trả lời kém.

Luồng pending so sánh cũng có prefix `interpret_task_reply → amend_task` tương tự.
Không phải mọi conversation hiện tại đều mất ba calls; pending proposal đã có thể
đến agent trực tiếp.

## 2. Mục tiêu và flow

**Message thường đến agent trước. Chỉ xử lý pending khi agent chọn hành động đó.**

```text
Load exact accepted head + requirements/build/pending/history
                          ↓
                  Có explicit command?
                 ┌────────┴─────────┐
                Có                Không
                 ↓                  ↓
      Existing validated        Agent chọn action
          fast path             ├─ Text → trả lời, giữ pending
                 │              ├─ Read tool → evidence → agent
                 │              └─ Pending control + typed args
                 │                         ↓
                 └──────── Application validate/apply
                                           ↓
                          Chờ confirmation hoặc tiếp tục task
                                           ↓
                          Revalidation → stop/lineage/CAS publish
```

Không thêm intent-classifier call, keyword router, framework hoặc workflow engine.
Task registration của **yêu cầu mới không có pending** giữ nguyên trong slice này;
không hứa mọi greeting mới chỉ còn một model call.

## 3. Contract model: chọn và cung cấp dữ liệu trong cùng một call

Không để agent chỉ nói “hãy sửa pending” rồi gọi extractor lần nữa. Native control
phải mang typed args cần thiết để application xử lý ngay.

| Native control đề xuất | Reuse args | Chỉ expose khi |
| --- | --- | --- |
| `select_pending_unit` | `UnitChoiceDraft` | Pending có quantity thiếu đơn vị |
| `select_pending_variant` | `ChoiceDraft` | Pending requirements có SKU cần chọn |
| `select_pending_product` | `TaskChoiceDraft` | Pending task có product cần chọn |
| `amend_pending_requirements` | `PendingAmendment` | Có unmerged requirement draft |
| `amend_pending_tasks` | `TaskAmendment` | Có unresolved task draft |

Đây là **control actions**, không phải năm business tools mới. Bind subset theo
pending thực tế; không expose tất cả hoặc gộp vào một full decision union. Pending
vừa thiếu đơn vị vừa mơ hồ SKU có thể expose hai selection controls liên quan;
không ép user trả lời theo thứ tự cứng. Mỗi response vẫn tối đa một native call.

- Text, `submit_result` và business tools hiện có vẫn dùng cho câu hỏi chen ngang.
- Không thêm control cho plain “OK”; proposal vẫn cần explicit confirmation binding.
- `propose_requirements` không được dùng để âm thầm thay draft đang pending.
- Nếu chưa chọn được hoặc user hỏi lại, agent trả lời/hỏi thêm; không thử tuần tự
  tất cả selection/amendment heads.

## 4. Application giữ authority

Model chỉ cung cấp lựa chọn/sửa đổi và source spans. Application lấy owner, run,
original pending ID, revision và request hash từ trusted context; reuse các
`Free*ReplyV2` / `Free*AmendmentV2` receipts và validators hiện có.

1. Kiểm tra control còn phù hợp với pending và quyền truy cập.
2. Validate source spans, offered candidates, units và target indices.
3. Recheck canonical product/variant khi lựa chọn identity; không tin UUID từ model.
4. Apply bằng existing continuation/amendment services. Changed requirements vẫn
   đi qua consent hiện có; không biến việc chọn SKU/đơn vị thành đồng ý mua/build.
5. Checkpoint transition + control acknowledgement; nếu gọi model tiếp, project
   matching AIMessage/ToolMessage từ transition đã commit.

Không quay lại `begin_turn` để xử lý control: việc đó có thể reset ledger, counters
hoặc receipts của cùng run. Model/tool budgets và bounded repair giữ nguyên.

### Giữ hai đường reply

| Input | Cách xử lý |
| --- | --- |
| Typed `reference_reply`, `unit_reply`, `task_reply`, confirmation, REPLACE/DISCARD | Existing deterministic fast path; không gọi model chỉ để hiểu command |
| Message thường có pending | Hydrate original tasks/draft/options → agent; không eager interpret/amend/re-extract |
| Message không có pending | Existing task registration → agent |

Đặc biệt pending task phải dùng frozen source/task identity từ accepted state;
không chạy lại task extraction hoặc catalog resolution chỉ để trả lời câu hỏi phụ.
Lựa chọn thật mới cần canonical revalidation. Không coi task chưa resolve là
`tasks=[]` rồi vô tình cho completion đi qua.

### State/publication không thay semantics

- Câu hỏi phụ dùng được requirements/build/pending, nhưng không tự đổi chúng.
- Response tăng conversation revision; original proposal ID/hash/target revision giữ nguyên.
- Selection/amendment là application-validated transition, không model authority.
- Existing task completion, optimizer proof, grounding, lineage/stop/CAS giữ nguyên.
- Sửa nội dung proposal đã chờ consent không được tái sử dụng confirmation cũ.

## 5. Phases và gate

Làm tuần tự. Mỗi task ghi handoff ngắn: behavior, files, command/result, việc còn thiếu.

| Task | Deliverable | Gate | Status |
| --- | --- | --- | --- |
| T0 — Reproduce/contract | Regression case 3 calls; fixtures cho unit/SKU/task pending; kiểm tra checkpoint cursors cũ | Case mới fail đúng eager prefix; chốt control subset và compatibility trước sửa graph | TODO |
| T1 — Native controls | Strict schemas, state-aware exposure, parser/projection và receipt mapping | Đúng native call/ack; source/candidate sai bị reject; không thêm extraction call | TODO |
| T2 — Agent-first graph | Bỏ eager prefix ở new turns; giữ typed fast path; hydrate pending tasks trước agent | Các scenario §6 pass qua graph + PostgreSQL publication/reopen; counters/ledger không reset | TODO |
| T3 — Parity/docs | Serving/training export/evaluator đồng bộ, protocol metadata và docs/handoff | Full regression/static pass; không silently relabel pilot; live quality báo riêng | TODO |

### Phạm vi source

Đường dẫn tương đối với `ai-service/src/ai_service/`; kiểm tra trước khi sửa:

- `infrastructure/graph/flexible.py`: begin/registration/routing và pending transitions.
- `react/{actions,control_actions,contracts}.py`, `infrastructure/providers/react_model.py`: control schemas, availability, normalization, acknowledgement/projection.
- `react/{resolution_reply,snapshot_publication,waiting_publication}.py`: reuse receipt validation và publication replay, không bypass.
- `infrastructure/execution/build_runtime.py`: new-turn composition; không inject eager interpretation như một prefix bắt buộc.
- `training/{dataset,export,evaluation}.py`: shared serving protocol và label validation.

Không bắt buộc sửa mọi file; không thêm service/port nếu helper hiện tại đủ dùng.

### Compatibility

Old accepted snapshots/pending receipts phải tiếp tục dùng được, không SQL migration
hoặc reset DB chỉ để đổi orchestration. T0 phải kiểm chứng native resume tại các
node interpretation/amendment cũ, không chỉ new-turn replay.

Ưu tiên giữ node names/handlers cần cho in-flight cursor cũ trong giai đoạn chuyển
tiếp, nhưng new turns không đi qua eager prefix. Không tạo runtime fallback V1,
copy checkpoint values hoặc reset counters để né recovery. Nếu test chứng minh
resume không tương thích, dừng gate để chốt version policy trước triển khai tiếp.

## 6. Nghiệm thu theo hành trình phổ biến

| User turn / context | Expected behavior |
| --- | --- |
| “SSD khác RAM như thế nào?” khi chờ đơn vị SSD | Một agent call nếu trả lời text hợp lệ; 0 selection/amendment calls, 0 catalog/tool calls; pending nguyên vẹn |
| “GB với TB khác nhau thế nào?” | Giải thích, không tự chọn đơn vị chỉ vì câu hỏi chứa `GB`/`TB` |
| “GB” cho pending đơn vị | Agent dùng unit control + source span; không gọi thêm unit extractor; giữ amount gốc và consent semantics |
| “Chọn bản ASUS đó” khi có offered variants | Bind đúng offered variant; canonical recheck; không đoán SKU |
| “Đổi RAM thành 32GB” khi draft còn pending | Amendment đúng item; không làm mất budget/workload hoặc merge trước consent |
| Hỏi thêm khi đang chọn sản phẩm so sánh | Response có context, giữ original subjects/options; không eager product lookup/amendment |
| Chọn product cho comparison | Resolve đủ subjects mới hoàn tất COMPARE; không đổi thành ANSWER |
| Typed reply/confirmation từ FE | Không có interpretation model call; original binding vẫn đúng sau side response |
| Đủ ngân sách/workload sau clarification | Tiếp tục task gốc, gọi optimizer và publish verified build, không hỏi lại dữ liệu đã có |
| Reopen/resume sau control transition | Reuse committed result/ack; không áp dụng lựa chọn hai lần |

Đếm riêng actual agent/selection/amendment calls, business tools, repair và catalog
I/O. Không giảm số calls bằng bỏ source/canonical validation hoặc completion checks.
Tổng request phải tính cả schemas/context mới; không chỉ so độ dài system prompt.

Gate cuối: focused suites trước, rồi `pytest -q tests`, `pytest -q integration_tests`,
`ruff check src tests integration_tests migrations`, `mypy src`, `uv lock --check`
theo lệnh/cache trong root AGENTS. Chạy các DB suites tuần tự trên shared test DB.

Scripted tests chứng minh orchestration/state. Model thật mới chứng minh hiểu câu
hỏi, chọn control và giải thích hữu ích; live eval hiện chưa có provider local và
không là precondition để viết plan. Không tự mang deferral cũ thành quyền bỏ gate
mới hoặc tự push khi implement; báo rõ phần đã/chưa kiểm chứng.

## 7. Không làm trong slice này

Không xử lý SSRF/hard-crash recovery, đổi optimizer, thêm memory framework,
SSE reconnect, FE redesign hay intent taxonomy. Không cố nhận mọi cách nói hoặc
loại mọi repair call. Mục tiêu là bỏ prefix thừa trong các flow phổ biến, giữ state
đúng và agent đủ linh hoạt.

**Handoff:** chỉ mới lập plan; chưa có code/test mới, commit, push hoặc deploy.
