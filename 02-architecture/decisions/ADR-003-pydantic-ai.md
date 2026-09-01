# ADR-003 — Dùng PydanticAI cho model boundary

## Context

AI service cần một lớp model có output được validate, có thể thay provider sau
này và không làm mất khả năng chạy local khi chưa có API key. Luồng compare cũng
cần graph deterministic để kiểm soát input trước khi gọi model.

## Decision

Sử dụng PydanticAI làm adapter model với output `ShoppingAnswer`. Application
chỉ phụ thuộc các port `AnswerGenerator` và `StreamingAnswerGenerator`; agent
provider được tạo lazy trong infrastructure. `AI_PROVIDER` hỗ trợ `fallback`,
`openai` và `gemini`; không cấu hình model thì dùng deterministic
backend-grounded fallback. Streaming chat dùng agent text-only để phát delta,
trong khi route JSON tiếp tục validate `ShoppingAnswer`. Sử dụng
`pydantic-graph` cho orchestration có state, đã áp dụng cho shopping planning
và comparison flow. Semantic retrieval có port embedding/vector riêng, được
cấu hình độc lập với model boundary.

Các capability được tổ chức theo vertical slice dưới
`capabilities/<feature>/`. Use case chỉ nhận outbound ports; adapter
`PydanticGraphRunner` cô lập API runtime của Pydantic Graph, còn
`infrastructure/composition.py` là composition root duy nhất. FastAPI resolve
inbound port qua dependency injection thay vì tự khởi tạo provider/graph.

## Consequences

- Frontend có contract ổn định trước khi chốt provider.
- Model output không đi thẳng ra HTTP nếu không qua schema validation.
- Local/test không cần secret hay network tới provider.
- Cần chốt provider, model, secret rotation, timeout, retry và acceptance test
  trước khi claim AI production (ISSUE-019).
- Adapter model không tự biến keyword search thành vector retrieval; Qdrant và
  embedding provider được quản lý bởi retrieval adapter riêng.
- Có thể thêm capability hoặc thay graph runner/model provider mà không đổi
  HTTP contract; compatibility re-exports chỉ tồn tại trong giai đoạn migrate.
