# AI service architecture

Thiết kế V1 · 2026-10-12. Flexible action flow đã chốt, migration chưa implemented.
Runtime/evidence: [status](../04-ai/stateful-implementation-status.md).
Quyết định: [ADR-005](decisions/ADR-005-stateful-react.md).

## 1. Stack và scope

| Thành phần | Vai trò |
| --- | --- |
| FastAPI | HTTP/SSE |
| Pydantic | Typed contracts/validation |
| LangGraph | Một bounded ReAct graph; native execution/checkpoints |
| LangChain OpenAI/Gemini adapters | Model calls, không agent runtime thứ hai |
| SQLAlchemy/Alembic | Application metadata/migrations |
| AsyncPostgresSaver | Native checkpoint persistence trong PostgreSQL |

V1 login-only, một conversation = một stable thread với nhiều runs.
Không PydanticAI, cross-conversation memory/Mem0, multi-agent hoặc commerce mutation tools.
Legacy request-scoped chat không phải durable ReAct; stateful foundation đang opt-in.

## 2. Flow

```text
POST turn → auth/ownership → durable submit → managed executor
  → load accepted context + register requested tasks
  → bounded agent/action loop:
      read tool → observe → agent
      requirement proposal → resolve/validate/confirm → atomic working merge → agent
      clarification → persist pending → finalize WAITING_INPUT
  → grounding + task completion → terminal checkpoint
  → stop proof + native lineage + fenced CAS
  → accepted head / message / result

GET SSE → authorized persisted-event subscription
```

HTTP/SSE disconnect không cancel graph. Application head khác latest checkpoint.
Native saver giữ execution state; application quyết định checkpoint nào được publish.
Chi tiết: [agent](../04-ai/agent-tools.md), [execution](../04-ai/context-management.md).

## 3. Clean architecture

| Layer | Trách nhiệm | Dependency cấm |
| --- | --- | --- |
| api | Auth dependency, DTO/SSE mapping | Tạo provider/DB clients, chạy optimizer |
| application/use_cases | Ownership, submit/read/cancel, admission/finalization | Model/client authority |
| application/ports | Catalog/model/store/execution contracts | SDK/HTTP implementation |
| capabilities/assistant/requirements | Pure merge/compiler/verifier rules | Network, DB, model confidence làm authority |
| capabilities/assistant/react | Tool policy/dispatch, completion/grounding | Publish hoặc sửa trusted requirements |
| capabilities/pc_builder | Deterministic optimizer | Graph/model/network/DB runtime |
| infrastructure | Graph/provider/catalog/store/executor adapters | Định nghĩa lại business rules |

Composition: infrastructure/composition.py; resources/lifespan: infrastructure/stateful.py
và main. Routes không tạo coordinator/resource ownership riêng.

## 4. Build và tools

Target: read exploration không đòi full requirement resolution trước agent.
Requirements chỉ thay qua validated proposal branch; accepted state chỉ đổi ở CAS.
Current runtime vẫn có pre-agent draft/resolve/merge; P3-F01–F04 migrate cùng contracts.
build_pc compile canonical state → existing optimizer → independent satisfaction verifier.
Capability, preference, exact pin và available resource có semantics riêng;
unsupported/conflict không bị bỏ ngầm.

Sáu tools hiện có: search_catalog, get_product_details, compare_products, build_pc,
search_web, read_web_page. Action contracts và ownership: [agent](../04-ai/agent-tools.md#5-agent-protocol-và-execution-graph).
State-aware exposure; dispatcher recheck. Native protocol tối đa một call/response.
tool_results là canonical outcome; model messages là projection.

Backend catalog quyết định variant/SKU/price/stock/specs/visibility.
Vector/keyword results phải revalidate ACTIVE. Description là data, không instruction.
Facts public render từ typed evidence, không lấy LLM prose làm truth.

Contracts: [tools](../05-api/tool-contracts.md), [models](../04-ai/model-strategy.md),
[optimizer](../04-ai/pc-build-optimizer.md).

## 5. Persistence và publication

- Public/new turn dùng exact accepted ref; resume dùng eligible run working ref.
- Native next/tasks/pending writes/lineage được giữ, không reconstruct bằng copy values.
- Run status/lease expiry không release thread; stop evidence phải verify/drain.
- Mỗi outbound attempt reserve durable budget; UNKNOWN consumed. Không hard billing guarantee.
- Publish kiểm tra run lineage, terminal output, ownership và CAS revision/head.
- Debug/replay internal-only, không publish.

Contracts: [state/recovery](../04-ai/context-management.md),
[DB/provenance](../03-data/ai-stateful-schema.md), [API](../05-api/stateful-chat-v1.md).
