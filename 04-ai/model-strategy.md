# Model strategy

## Current baseline

Provider/model chưa được chốt. `AI_MODEL_NAME` để trống ở local mặc định, nên
service chạy deterministic fallback và không yêu cầu credential. Built-in
PydanticAI `test` model được dùng trong test để verify output adapter mà không
gọi mạng.

## Before production

Owner cần quyết định provider/model và bổ sung:

- secret injection và rotation;
- timeout, retry, rate limit và cost budget;
- logging/redaction cho prompt và response;
- model-backed acceptance set cho chat, tư vấn, compare và evaluate;
- fallback/error policy khi backend hoặc provider unavailable.

Không dùng model tự do để trả dữ liệu giao dịch; product context phải lấy từ
backend ở request time.
