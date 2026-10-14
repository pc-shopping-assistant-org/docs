# Model providers

OpenAI và Gemini là model-call adapters, không orchestration runtimes.
LangGraph giữ loop/checkpoints; Pydantic giữ schemas; application giữ authority.

## Provider selection

Chọn `AI_PROVIDER=openai` hoặc `gemini`, key tương ứng và model ID trong
[Configuration](configuration.md). Model clients được lifecycle reuse/close sau drain.
Không giữ một model message history riêng ngoài canonical context.

Request-scoped fallback provider không chạy stateful ReAct. Stateful provider failure
không downgrade BUILD thành generic advice success.

## Structured output

Requirement/task extraction trả typed drafts, không trực tiếp trusted state.
Wire schema phải map explicit; null/refusal/truncation/malformed không trở thành empty patch.
Validation toàn response trước resolve/merge; không stream partial draft vào state.

Task extraction chỉ đăng ký requested tasks. Requirement extraction được dùng khi
proposal cần chứng minh explicit user source, không mandatory prefix mọi turn.

## Native tool calling

Adapter bind schemas của allowed subset và project complete ledger pairs thành
AIMessage/ToolMessage. Tối đa một accepted call mỗi response.

- Tắt parallel calls khi integration hỗ trợ; vẫn kiểm tra multi-call.
- Reject malformed/multiple/mixed action response; repair không làm hỏng last valid transcript.
- Gemini signature giữ opaque theo call cho serialization/reopen.
- Không parse text/`exec` để fake tool-calling capability.
- JSON non-tool actions dùng V2 contract; JSON CALL_TOOL bị reject vì native protocol.

Model không được quyết định principal, attempt budget, source provenance, publish
authority hoặc completion của requested task.

## Attempts and failures

Mỗi actual extraction/agent/explanation/repair call phải durable-reserve trước outbound.
SDK retries disabled hoặc instrument từng attempt. UNKNOWN vẫn consumed; không exactly-once
hoặc hard billing guarantee.

Refusal/schema failure dùng bounded repair hoặc explicit failure. Cancellation được
propagate/drain. Không publish unvalidated partial model text để che lỗi provider.

## Explanation

Facts server render từ typed catalog/build/web evidence. Model chỉ bổ sung qualitative
explanation có selected refs; ref matching không chứng minh mọi prose claim đúng.
Không tạo FPS/spec/stock/giá từ knowledge của model.

## Testing an adapter

Core dùng scripted models; protocol tests phải tôn trọng khác biệt OpenAI/Gemini.
Kiểm tra schema binding, signatures, matched pairs, cancellation và reserve boundaries.
Live semantic/factuality quality có gate riêng, không suy từ core/native pass.

Source: [provider adapters](../../ai-service/src/ai_service/infrastructure/providers/).
**Next:** [Agent protocol](agent-tools.md#actions-and-protocol) · [Testing](testing.md).
