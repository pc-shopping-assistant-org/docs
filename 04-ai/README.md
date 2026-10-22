# AI service documentation

AI service giúp khách tìm, hiểu, so sánh sản phẩm và build PC qua hội thoại nhiều lượt.
Tài liệu này hướng dẫn **hiểu hệ thống, chạy local và phát triển một capability**.

Server và frontend chỉ chạy Stateful ReAct V2. Các contract snapshot/lịch sử giữ
version gốc, không là fallback runtime. Khả năng đã có và backlog: [implementation status](stateful-implementation-status.md).

## Overview

- [Introduction](ai-problem-definition.md) — service giải quyết bài toán gì?
- [Architecture](../02-architecture/ai-architecture.md) — ai làm gì, dữ liệu đi đâu?
- [First steps](getting-started.md) — từ local dependencies đến lượt chat đầu tiên.
- [Configuration](configuration.md) — chọn runtime, model, catalog và database.

## Fundamentals

Đọc theo thứ tự này khi mới vào dự án:

1. [Agent and tools](agent-tools.md): agent chọn hành động, application kiểm soát kết quả.
2. [Requirements](requirements.md): lời nói của user trở thành ràng buộc như thế nào?
3. [State and recovery](context-management.md): conversation, run, checkpoint và publish.
4. [Catalog retrieval](rag.md): nguồn sản phẩm chuẩn và ranh giới vector search.
5. [Web research](web-research.md): search, đọc trang, facts và citations.
6. [Model providers](model-strategy.md): OpenAI/Gemini/Qwen và native tool protocol.
7. [PC optimizer](pc-build-optimizer.md): thuật toán, compatibility và scoring.

## Guides

| Muốn làm | Đọc |
| --- | --- |
| Theo dõi một yêu cầu build qua nhiều lượt | [Build consultation](guided-selection.md) |
| So sánh sản phẩm và dùng attachments | [Product comparison](comparison.md) |
| Tra cứu thông số/benchmark trên web | [Research a question](search-qa.md) |
| Thêm một tool | [Add a tool](guides/add-tool.md) |
| Hỗ trợ một requirement mới | [Extend requirements](guides/extend-requirements.md) |
| Viết và chạy tests | [Testing](testing.md) |
| Xử lý lỗi startup/run | [Troubleshooting](troubleshooting.md) |
| Tra log và thời gian từng step bằng trace ID | [Logs and traces](observability.md) |
| Chuẩn bị dataset, baseline và fine-tuning | [Training plan](training-plan.md) |
| Chạy Qwen baseline → QLoRA → evaluate → serving | [Training runbook](training.md) |

## Reference

- [HTTP/SSE V2](../05-api/stateful-chat-v2.md); [shared HTTP and archived V1](../05-api/stateful-chat-v1.md).
- [Tool schemas](../05-api/tool-contracts.md); [catalog snapshot](../05-api/catalog-snapshot.md).
- [Application/native database](../03-data/ai-stateful-schema.md).
- [Hardware rules and policies](hardware-knowledge.md).
- [Legacy state contracts](stateful-chat-contracts.md).
- [Architecture decision](../02-architecture/decisions/ADR-005-stateful-react.md).

## Project delivery

Không dùng các trang này để học kiến trúc:

- [Roadmap](stateful-chat-implementation-plan.md): việc còn lại và gates.
- [Task/requirement separation](task-requirement-separation-plan.md): contract boundary, compatibility và verification record.
- [Current status](stateful-implementation-status.md): khả năng thực tế và verification.
- [Core audit](core-audit.md): phạm vi core đã được kiểm chứng.
- [Historical journal](stateful-implementation-history.md): bằng chứng các slice trước.
- [Session checkpoint](SESSION_CHECKPOINT.md): handoff cho phiên làm việc tiếp.

**Quy ước:** concept giải thích cơ chế; guide hướng dẫn một việc; reference giữ
contract chính xác. Test counts và lịch sử sửa lỗi không nằm trong concept pages.
