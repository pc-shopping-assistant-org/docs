# ADR-003 — Dùng PydanticAI cho model boundary

## Context

AI service cần một lớp model có output được validate, có thể thay provider sau
này và không làm mất khả năng chạy local khi chưa có API key. Luồng compare cũng
cần graph deterministic để kiểm soát input trước khi gọi model.

## Decision

Sử dụng PydanticAI làm adapter model với output `ShoppingAnswer`. Agent được khởi
tạo lazy từ `AI_MODEL_NAME`; không cấu hình model thì dùng deterministic
backend-grounded fallback. Sử dụng `pydantic-graph` cho orchestration có state,
đã áp dụng cho shopping planning và comparison flow. Semantic retrieval có port
embedding/vector riêng, được cấu hình độc lập với model boundary.

## Consequences

- Frontend có contract ổn định trước khi chốt provider.
- Model output không đi thẳng ra HTTP nếu không qua schema validation.
- Local/test không cần secret hay network tới provider.
- Cần chốt provider, model, secret rotation, timeout, retry và acceptance test
  trước khi claim AI production (ISSUE-019).
- Adapter model không tự biến keyword search thành vector retrieval; Qdrant và
  embedding provider được quản lý bởi retrieval adapter riêng.
