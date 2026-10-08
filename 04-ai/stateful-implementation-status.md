# Stateful AI — implementation status để review

- Cập nhật: 2026-10-09.
- Trạng thái làm việc: **tạm dừng theo yêu cầu owner để review**. Không tiếp tục
  triển khai trước khi owner yêu cầu resume.
- Không đổi kiến trúc: LangGraph + Pydantic + PostgreSQL/checkpointer; một
  conversation = một thread; accepted head khác latest framework checkpoint.
- Đây là hiện trạng source và evidence, không phải tuyên bố toàn plan hoàn tất.

## 1. Tiến độ phase

| Phase | Status | Đã có | Còn thiếu để đóng phase |
| --- | --- | --- | --- |
| P0 | COMPLETED | Contract baseline, login-only, budget/retention, public DTO và provenance | Runtime của các contract thuộc P2–P5; root revision-zero chưa thay |
| P1 | COMPLETED | Pure multi-turn merge, owned/pinned, unknown state, hash/marker invalidation | Nối vào chat thực tế thuộc phase sau |
| P2 | IN PROGRESS | Alembic 0002, saver bootstrap, lifecycle, JWT verifier, owner-scoped create/get, exact accepted reads; native foundation gates owner báo pass | Hoàn thiện integration với run runtime; kiểm chứng môi trường auth thực tế |
| P3 | IN PROGRESS | Canonical requirements → resolver → atomic merge → compiler → optimizer → verifier; typed 4 tools và internal ReAct graph source | Verify graph; native model/product adapters, clarification/saved-build completion, soft preferences, FULL_SETUP và state migration |
| P4 | IN PROGRESS | Pure retry/stop guards, managed executor, durable attempt reservations; root experiment owner báo pass | Root initializer/CAS/readiness, durable admission/idempotency, lineage validator, fenced atomic finalize, runtime wiring |
| P5 | IN PROGRESS | Public DTO/SSE contract và grounded current-build presenter; create/get foundation routes | Runs/history/list/cancel/delete/events, persisted SSE reconnect và frontend |
| P6 | TODO | Acceptance criteria đã định nghĩa | Final core audit trên complete runtime, gồm DB races/recovery/publication |

Tổng 7 phase: 2 COMPLETED, 4 IN PROGRESS, 1 TODO. Không suy phần trăm hoàn thành
toàn chức năng từ số phase vì các phase có khối lượng khác nhau.

## 2. Evidence mới nhất

| Hạng mục | Evidence | Giới hạn |
| --- | --- | --- |
| Baseline trước ReAct source mới | Agent chạy 279 core tests; Ruff, mypy 119 files và offline lock check pass | Chưa phải full verification của source ReAct vừa thêm |
| Dotenv | 2 tests pass; shell override thắng `.env`; local `.env` ignored | Không thay quyền truy cập API hoặc tự bật stateful mode |
| Foundation PostgreSQL | Owner báo `alembic upgrade head` → `bootstrap_stateful` → toàn integration_tests pass | Không phải agent tự chạy; không chứng minh live JWKS/LLM hoặc coordinator |
| Initial-root native experiment | Owner báo `uv run pytest -q integration_tests/test_initial_root_postgres.py` pass; agent chạy 2 memory cases pass | Native mechanics được chứng minh; chưa có production initializer/CAS/concurrency readiness |
| Typed tools/completion | Agent chạy `uv run pytest -q tests/test_react_tools.py`: 4 passed | Internal services với canonical typed test catalog, không phải live backend/LLM |
| ReAct graph mới | Đã thêm `tests/test_react_graph.py`; lượt chạy chưa trả kết quả và bị dừng khi owner yêu cầu pause | Không claim graph tests pass; cần diagnose/verify trước khi nối runtime (ISSUE-100) |

## 3. Source mới để đọc

Paths dưới đây tương đối từ root `ai-service/`:

| File | Trách nhiệm |
| --- | --- |
| `src/ai_service/capabilities/assistant/react/contracts.py` | Four tool names, strict args/results, server-owned ToolContext, completion and answer DTOs |
| `src/ai_service/capabilities/assistant/react/tools.py` | State-aware exposure/dispatch; real optimizer + independent verifier; completion checks; facts render từ typed evidence |
| `src/ai_service/infrastructure/graph/react.py` | Internal bounded agent → validate → tool → observe loop; checkpoints giữ call/result ledger; model attempt boundary |
| `tests/test_react_tools.py` | Tool preconditions/args, build completion, comparison coverage và evidence-only output |
| `tests/test_react_graph.py` | Planned verification: whole-response multi-call rejection, no task downgrade, resume without repeating committed build |
| `integration_tests/test_initial_root_postgres.py` | Experimental native terminal root, failed R1/orphan → R2 from exact root, metadata recovery after crash-before-CAS |

`react.py` chưa đăng ký trên HTTP/SSE và chưa có OpenAI/Gemini ReAct adapter.
`ToolContext` và completion requirements phải do application xác thực/cấp, không
nhận trực tiếp từ model hoặc body của client. Provider transcript sẽ là projection
của validated ledger; chưa có provider-native message assembly ở slice hiện tại.

## 4. Những điểm cần review trước khi làm tiếp

1. **Root:** native root experiment pass không tự sửa `revision=0 → accepted=null`.
   Production vẫn giữ invariant cũ. Cần chốt initialization transaction/ownership,
   crash/concurrency/CAS, readiness và legacy conversation policy trước migration.
   ISSUE-092 vẫn mở.
2. **Completion:** slice mới hỗ trợ BUILD/COMPARE/ANSWER. Targeted clarification
   và explain đúng historical accepted build chưa có; không claim WAITING_INPUT
   hoặc saved-build flow hoàn tất. Generic advice không thay verified build.
3. **Grounding:** public factual text render từ canonical DTO/build result. LLM
   prose không được publish thành fact. Không claim đã có detector chứng minh mọi
   câu natural language đúng. Empty/unknown evidence không thành success.
4. **Build objective:** `BuildPCArgs.objective` đã có schema nhưng hint khác null
   hiện bị reject; không âm thầm bỏ qua hay đổi policy. Cần mapping/policy version
   rõ trước khi hỗ trợ hint. Soft scorer/FULL_SETUP cũng còn thiếu.
5. **Execution/budgets:** graph model calls nhận AttemptBoundary; chưa có complete
   SQL coordinator/provider/backend wiring. Tool backend requests phải reserve
   từng outbound attempt; counters trong checkpoint không phải durable cap.
   Optimizer synchronous hiện chỉ dùng internal tests, chưa là production worker
   CPU isolation. `READY_TO_PUBLISH` không phải quyền publish hoặc nhường thread.
6. **Bounds:** source defaults 12 model calls, 8 tools, 2 repairs, 512000 bytes
   state và 128000 bytes/tool result. Đây là implementation defaults chưa qua
   complete runtime/cost/context validation. Deadline/retention/GC còn P4/P5/P6.

## 5. Thứ tự khi owner yêu cầu resume

1. Diagnose/verify ReAct graph gate (ISSUE-100); chạy focused rồi full/static checks.
2. Hoàn thiện root initialization contract + DTO/DB/schema/readiness, native
   concurrent/crash/CAS acceptance; sau đó mới đóng ISSUE-092.
3. Durable coordinator submit/claim/heartbeat/stop/lineage/finalize và budgeted
   model/backend adapters; không để HTTP/SSE sở hữu execution.
4. Complete requirement/ReAct behavior: clarification, saved build, unsupported/
   soft/FULL_SETUP coverage, trusted completion extraction và state migration.
5. Delivery endpoints/event journal/FE rồi P6 audit requirement-by-requirement.

Plan: [Stateful chat](stateful-chat-implementation-plan.md).
Design: [ReAct/tools](stateful-react-tools-design.md).
API: [Stateful V1](../05-api/stateful-chat-v1.md).
