# Model strategy

## Current baseline

Provider/model chưa được chốt cho production. `AI_PROVIDER=fallback` và
`AI_MODEL_NAME` để trống ở local mặc định, nên service chạy deterministic
fallback và không yêu cầu credential. Built-in PydanticAI `test` model được
dùng trong test để verify output adapter mà không gọi mạng.

Application code chỉ phụ thuộc vào port `AnswerGenerator`/
`StreamingAnswerGenerator`. Infrastructure có hai adapter lazy:

- `AI_PROVIDER=openai` dùng `OpenAIChatModel` + `OpenAIProvider`;
- `AI_PROVIDER=gemini` dùng `GoogleModel` + `GoogleProvider`.

SDK import, API-key validation và client construction chỉ xảy ra khi có request
cần model. `AI_MODEL_NAME` là override; nếu bỏ trống, adapter dùng
`gpt-4o-mini` hoặc `gemini-2.5-flash`. Khi chưa bật provider hoặc provider lỗi,
stream chat phát deterministic fallback thành một delta và vẫn giữ envelope
ổn định. Legacy `provider:model` của PydanticAI vẫn được chấp nhận khi
`AI_PROVIDER=fallback` để không phá local config cũ.

## Before production

Owner cần quyết định provider/model và bổ sung:

- secret injection và rotation;
- timeout, retry, rate limit và cost budget;
- logging/redaction cho prompt và response;
- model-backed acceptance set cho chat, tư vấn, compare và evaluate;
- fallback/error policy khi backend hoặc provider unavailable.

Không dùng model tự do để trả dữ liệu giao dịch; product context phải lấy từ
backend ở request time.
