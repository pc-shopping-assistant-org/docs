# Model strategy

## Architecture decision

LangGraph sở hữu orchestration/tool loop/checkpoints; Pydantic sở hữu schemas/
validation; direct LangChain OpenAI/Gemini adapters sở hữu model calls.
Không PydanticAI, create_agent runtime thứ hai hay textual ReAct parser.
[ADR-005](../02-architecture/decisions/ADR-005-stateful-react.md).

Application chỉ phụ thuộc model/answer ports. Provider objects, AIMessage/ToolMessage,
callbacks và SDK exceptions nằm trong infrastructure. Provider wire-schema mapping
về canonical draft phải explicit; validate toàn response trước merge, không stream
partial requirements vào trusted state. Structured output không chứng minh intent/facts.

## Existing stateless adapter

AI_PROVIDER=fallback không gọi model, kể cả có AI_MODEL_NAME.
AI_PROVIDER=openai hoặc gemini tạo adapter lazy; model/API-key config thuộc Settings.
Bare model ID override bằng AI_MODEL_NAME; legacy provider:model và built-in test
model đã bỏ. Default names nằm trong .env.example/Settings, không coi là production
recommendation. Tests dùng model-port fixtures, không gọi live LLM.

JSON answer dùng ShoppingAnswer structured validation. No-model/provider failure
trước output có thể dùng canonical backend-grounded fallback. Stream lỗi sau delta
phải ERROR, không fallback thành successful completion; cancellation được propagate.
SDK retries disabled; timeout dùng AI_REQUEST_TIMEOUT_SECONDS.

## Stateful ReAct target

Native bind_tools cho bốn approved tools, schemas strict và state-aware exposure.
parallel_tool_calls=False nếu model/integration hỗ trợ; vẫn validate multi-call/
malformed/chunk response. Unsupported tool-calling capability fail rõ, không parse
text để giả tool call. Provider-specific protocol tests không ép OpenAI semantics
sang Gemini. Native ReAct adapters chưa là complete live runtime.

Every extraction/agent/explain/repair/fallback outbound attempt phải durable reserve
budget trước dispatch, kể cả backend fan-out. SDK retries phải disabled hoặc
instrumented từng attempt; UNKNOWN không refund. Durable attempt cap không là
provider billing cap. Model context/output/deadline limits finite, snapshot vào run.

Stateful provider failure không được downgrade BUILD thành generic fallback success.
Grounding, task completion và publication gates vẫn bắt buộc.
[Tool protocol](agent-tools.md#5-agent-protocol-và-execution-graph).

## Before runtime enablement

Chốt model capabilities/strict schema method trên pinned integrations; verify
timeouts/cancellation/message pairs và outbound reservation boundary. Secrets ở
ignored env/runtime secret store. Log sanitized usage/errors, không JWT/API keys/
raw sensitive prompts hoặc hidden reasoning. Live provider smoke riêng; core dùng
scripted model với optimizer/PostgreSQL thật theo acceptance gate.
