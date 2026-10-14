# Architecture

AI service nằm giữa frontend, catalog và model provider. Nó giữ hội thoại, điều phối
tools và trả kết quả đã kiểm tra — không thay backend ecommerce hoặc optimizer.

## System view

```text
Frontend
   │ HTTP / SSE
   ▼
AI service ────► Catalog service   sản phẩm, SKU, giá, tồn kho
   │       └──► OpenAI / Gemini    hiểu yêu cầu, chọn action, diễn giải
   │       └──► Web sources        tài liệu tham khảo
   ▼
PostgreSQL                         history, runs, attempts, checkpoints
```

Identity service cấp access JWT; AI service verify bằng configured JWKS và kiểm tra
owner trước đọc/chạy conversation. Qdrant là retrieval option, không database lưu state.

## Inside the service

```text
API → Application → LangGraph agent/action loop
          │                 │
          │                 ▼
          │          Tool policy → Dispatcher → Application services / ports
          │                                      │
          │                                      ├─ Catalog / Web / Model adapters
          │                                      └─ Deterministic PC optimizer
          ▼
      Validate + publish → Accepted state/result → HTTP / SSE
```

| Component | Responsibility |
| --- | --- |
| API | Auth dependency, DTO mapping và event subscription |
| Application | Ownership, admission/idempotency, execution authority, publication |
| LangGraph | Chạy nodes/actions và lưu execution checkpoints |
| Agent/model | Chọn bước tiếp theo; không cấp quyền merge/publish |
| Requirements services | Resolve tên/đơn vị, atomic merge, compile và verify |
| Tools | Đưa typed observations từ services/ports vào canonical ledger |
| Optimizer | Tính cấu hình trong ngân sách và modeled compatibility |
| Infrastructure | Bind model/HTTP/SQL/saver/executor implementations |

FastAPI, Pydantic, LangGraph, LangChain adapters và PostgreSQL là stack hiện tại.
Không PydanticAI hoặc agent runtime thứ hai.

## Request lifecycle

1. API xác thực và admit một run bền vững; HTTP không giữ graph task.
2. Managed executor load exact accepted state và bounded published history.
3. Application đăng ký task; agent có thể đọc dữ liệu, đề xuất requirements hoặc hỏi lại.
4. Tool results vào ledger; agent quan sát và chọn bước tiếp.
5. Final candidate qua grounding/task-completion validation.
6. Terminal checkpoint qua stop/drain, lineage và CAS để publish accepted result.

SSE đọc persisted events độc lập. Disconnect không cancel graph. DELTA hiện chứa
answer đã validate, không stream trực tiếp unvalidated model tokens.

## Example: two-turn build

| Turn | What happens |
| --- | --- |
| “Build 25 triệu, RAM ít nhất 32GB” | Draft → resolve → validated merge → compile → optimizer/verifier → result |
| “Đổi CPU sang Intel, giữ RAM” | Load accepted requirements → sửa phần được yêu cầu → tính lại build |

Agent có thể search trước khi đủ budget. Nhưng generic advice không hoàn thành BUILD.
Nếu agent tự đề xuất giảm RAM, application yêu cầu confirmation; không tự đổi user constraint.

## State ownership

Một conversation có một stable LangGraph thread, nhiều runs và nhiều checkpoints.

- **Accepted state:** dữ liệu đã công bố, được application head trỏ tới.
- **Working state:** tiến trình của run, nằm trong native checkpoints.
- **History:** published messages trong application DB; model chỉ nhận bounded window.
- **Ledger:** canonical tool outcomes; model transcript/public DTO là projections.

Latest checkpoint có thể orphan/debug, không phải accepted head. Working state chỉ
trở thành accepted khi publication hợp lệ. [State and recovery](../04-ai/context-management.md).

## Code organization

Root package: `ai-service/src/ai_service/`.

| Layer | Entry point |
| --- | --- |
| HTTP/SSE | [api/stateful_conversations.py](../../ai-service/src/ai_service/api/stateful_conversations.py), [api/sse.py](../../ai-service/src/ai_service/api/sse.py) |
| Use cases/ports | [application/](../../ai-service/src/ai_service/application/) |
| ReAct graph | [infrastructure/graph/flexible.py](../../ai-service/src/ai_service/infrastructure/graph/flexible.py) |
| Tool/completion rules | [capabilities/assistant/react/](../../ai-service/src/ai_service/capabilities/assistant/react/) |
| Requirements/compiler/verifier | [capabilities/assistant/requirements/](../../ai-service/src/ai_service/capabilities/assistant/requirements/) |
| Build service/optimizer | [capabilities/pc_builder/](../../ai-service/src/ai_service/capabilities/pc_builder/) |
| Wiring/lifecycle | [infrastructure/stateful.py](../../ai-service/src/ai_service/infrastructure/stateful.py), [execution/build_runtime.py](../../ai-service/src/ai_service/infrastructure/execution/build_runtime.py) |
| Executor/SQL publication | [execution/supervisor.py](../../ai-service/src/ai_service/infrastructure/execution/supervisor.py), [persistence/runs.py](../../ai-service/src/ai_service/infrastructure/persistence/runs.py) |

Business logic phụ thuộc ports, không SDK implementations. API không tạo model/DB
clients; graph không chứa optimizer rules; optimizer không gọi network/DB/model.

## Availability

Frontend dùng V2-only; server phải [cấu hình V2](../04-ai/configuration.md).
Source defaults vẫn stateful-off/V1 và giữ compatibility, không fallback của frontend.
Core đã có fixture/native gates; live services, Full setup/soft scoring, retention,
history UI và recovery/replay mở rộng được theo dõi riêng trong [status](../04-ai/stateful-implementation-status.md).

**Next:** [First steps](../04-ai/getting-started.md) · [Agent and tools](../04-ai/agent-tools.md).
Rationale: [ADR-005](decisions/ADR-005-stateful-react.md).
