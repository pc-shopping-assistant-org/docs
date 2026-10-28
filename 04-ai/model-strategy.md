# Model providers

OpenAI, Gemini và Qwen là model-call adapters, không orchestration runtimes.
LangGraph giữ loop/checkpoints; Pydantic giữ schemas; application giữ authority.

## Provider selection

Chọn `AI_PROVIDER=openai` hoặc `gemini`, key tương ứng và model ID trong
[Configuration](configuration.md). Model clients được lifecycle reuse/close sau drain.
Không giữ một model message history riêng ngoài canonical context.

`AI_PROVIDER=qwen` gọi vLLM ở `AI_QWEN_BASE_URL`, không gọi OpenAI/Gemini.
Alias adapter ở `AI_QWEN_MODEL_NAME`; chưa train thì dùng `Qwen/Qwen3-8B`.
Provider lazy/reused/closed, không SDK retry.429/5xx/timeouts đi qua recovery policy
hiện có. Không đọc weight/GPU trong process FastAPI.

Request-scoped fallback provider không chạy stateful ReAct. Stateful provider failure
không downgrade BUILD thành generic advice success.

## Structured output

Requirement/task extraction trả typed drafts, không trực tiếp trusted state.
Wire schema phải map explicit; null/refusal/truncation/malformed không trở thành empty patch.
Validation toàn response trước resolve/merge; không stream partial draft vào state.
Model trả quote nguyên văn; application tính source offsets trước khi tạo draft nội bộ.

Task declaration đi qua native `register_tasks` cùng action đầu tiên của agent;
runtime không gọi task-extraction model trước ReAct. Contract `TaskDraftBatch`
vẫn riêng với requirements; head extraction cũ chỉ còn cho offline training/tests.
Requirement extraction được dùng khi
proposal cần chứng minh explicit user source, không mandatory prefix mọi turn.

## Native tool calling

Adapter bind schemas của allowed subset và project complete ledger pairs thành
AIMessage/ToolMessage. Tối đa một action mỗi response, có thể kèm task declaration.

- Cho phép provider trả cặp registration + action khi registration đang mở;
  application admit tuần tự trước execution. Không mở parallel business tools.
- Reject malformed/multiple action response; repair không làm hỏng last valid transcript.
- Gemini signature giữ opaque theo call cho serialization/reopen.
- Không parse text/`exec` để fake tool-calling capability.
- Text thường thành candidate response. Native controls `propose_requirements`,
  `ask_clarification`, `submit_result` được normalize nội bộ; JSON action envelope
  cũ bị reject, không fallback. Model chọn refs, application xác định outcome.

Protocol `agent-task-admission-v3` được dùng chung bởi serving và training export.
Artifact cũ cần regenerate/retrain để học declaration cùng action; không tự sửa pilot labels.
Control acknowledgements là checkpointed transitions, không business ToolResults;
projection giữ matched pairs và thứ tự cùng business ledger.

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

Dataset/fine-tuning là workflow offline riêng: [Training plan](training-plan.md).
Đã có Qwen3-8B SFT/QLoRA trainer, inference capture, paired comparison và lệnh
serve base/adapter. [Runbook](training.md) là hướng dẫn chạy chuẩn.
Shared Qwen projection đưa structured schema vào model context giống lúc train;
native tools dùng template/parser của vLLM, không text parser tự chế trong agent.
Structured JSON hiện là schema guidance trong prompt + Pydantic validation, không
server-enforced grammar decoding. Cần đo raw validity/repair trên model thật trước
khi coi adapter đạt chất lượng; không bảo đảm output luôn hợp lệ.
Chỉ ReAct/QuotedRequirementDraft/QuotedTaskBatch dùng adapter; head phụ chưa train vẫn dùng base weights.
Pilot còn DRAFT; chưa có lượt train, model quality hoặc GPU serving được xác minh.

Core dùng scripted models; protocol tests phải tôn trọng khác biệt OpenAI/Gemini/Qwen.
Kiểm tra schema binding, signatures, matched pairs, cancellation và reserve boundaries.
Live semantic/factuality quality có gate riêng, không suy từ core/native pass.

Source: [provider adapters](../../ai-service/src/ai_service/infrastructure/providers/).
**Next:** [Agent protocol](agent-tools.md#actions-and-protocol) · [Testing](testing.md).
