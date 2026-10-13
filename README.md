# Documentation

## Đọc AI service

| Cần biết | Tài liệu |
| --- | --- |
| Bài toán/phạm vi | [AI problem](04-ai/ai-problem-definition.md) |
| Components và boundaries | [Architecture](02-architecture/ai-architecture.md) |
| Quyết định kiến trúc | [ADR-005](02-architecture/decisions/ADR-005-stateful-react.md) |
| Requirements, ReAct, grounding | [Agent/tools](04-ai/agent-tools.md) |
| State, execution, recovery | [Context](04-ai/context-management.md) |
| API và tool schemas | [HTTP/SSE V1](05-api/stateful-chat-v1.md), [V2 internal request](05-api/stateful-chat-v2.md), [tools](05-api/tool-contracts.md) |
| Persistence/provenance | [AI database](03-data/ai-stateful-schema.md) |
| Thuật toán và policy | [Optimizer](04-ai/pc-build-optimizer.md), [hardware](04-ai/hardware-knowledge.md) |
| Delivery và evidence | [Plan](04-ai/stateful-chat-implementation-plan.md), [status](04-ai/stateful-implementation-status.md) |
| Setup/run/test | [ai-service README](../ai-service/README.md) |

## Nguồn chuẩn

| Folder | Nội dung |
| --- | --- |
| 01-overview / 01-business | Scope, glossary, business rules/use cases |
| 02-architecture | Boundaries và ADR |
| 03-data / 05-api | Schema/invariants và transport contracts |
| 04-ai | Agent, state, retrieval, optimizer/policies |
| 06-evaluation / 07-research / 08-thesis | Evidence, references và luận văn |

## Quy tắc viết

- Spec chỉ giữ quyết định hiệu lực, contract, invariant, flow và ví dụ cần thiết.
- Một rule ở một chỗ; nơi khác dẫn link, không copy.
- ADR giữ rationale/lịch sử; plan giữ dependency/gates; status/tracker giữ progress/evidence.
- Chốt decision thì sửa spec và affected API/data contracts, không append review log.
- Code/spec lệch thì ghi issue; design không phải bằng chứng runtime đã chạy.
- Source README chỉ setup/module navigation. Clone docs cạnh ai-service để relative links resolve.
