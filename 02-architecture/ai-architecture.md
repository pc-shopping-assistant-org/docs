# AI Service Architecture

## Boundary

`ai-service` là một FastAPI service tách khỏi backend nghiệp vụ. Nó cung cấp
`/api/v1/chat`, `/api/v1/chat/stream` (SSE), `/api/v1/search`,
`/api/v1/consult`, `/api/v1/compare` và `/api/v1/evaluate`. Tất cả route dùng
envelope `{data, message, errors}`; giá trị `message` là key tĩnh để frontend
mapping.

Backend API vẫn là source of truth cho product, variant, list price, stock và
trạng thái hiển thị. AI service chỉ gọi các catalog endpoint qua
`BackendClient`, không tự sao chép dữ liệu giao dịch.

## Runtime flow

```text
HTTP request
    -> Pydantic request validation
    -> AssistantService
       -> BackendClient (catalog context)
          -> CatalogRetriever boundary
       -> AnswerGenerator / StreamingAnswerGenerator port
          -> OpenAI or Gemini PydanticAI adapter (lazy)
          -> deterministic fallback when model is absent/unavailable
    -> canonical ApiResponse or SSE envelopes
```

## Clean-architecture foundation

The AI service is organized for capability vertical slices. The HTTP adapter
(`api/`) depends on the assistant inbound port, application use cases depend
on small outbound ports, and infrastructure binds concrete HTTP/model/vector
adapters in one composition root:

```text
api -> application/use_cases -> application/ports
                                      ^
                                      |
                         infrastructure adapters
capabilities/<feature>/ owns feature schemas, graphs and tools
```

`infrastructure/composition.py` is the only default wiring location. It builds
the catalog client/retriever, context store, PydanticAI answer generator and
request-scoped `PydanticGraphRunner` adapters. FastAPI gets the application
port through `api/dependencies.py`, which keeps routes free of provider and
graph construction. A generic `UseCase` port and a capability scaffold are
available for future search, guided-selection and workflow slices. Runtime
provider/retrieval choices and assistant branches are typed enums; their values
remain compatible with the environment/API strings.

The current `services/assistant_service.py` and `graphs/*_graph.py` paths are
thin compatibility seams for existing callers; new code should use
`application/use_cases` and `capabilities/<feature>/graphs`.

`CatalogRetriever` là protocol cấp use-case; baseline dùng
`BackendCatalogRetriever` để gọi catalog backend. Khi cấu hình
`AI_RETRIEVAL_BACKEND=hybrid` hoặc `qdrant`, service dùng
`HttpEmbeddingProvider` + Qdrant vector store và vẫn giữ backend fallback (trừ
chế độ strict `qdrant`) mà không đổi API contract.

`chat`, `search` và `consult` chạy `shopping_graph` trước retrieval để chuẩn hóa
query và xác định nhánh `SEARCH`/`CONSULT`. Graph chỉ chịu trách nhiệm planning;
retrieval và answer generation vẫn là các port thay thế được.

`compare` dùng `pydantic-graph` để validate/deduplicate input trong graph trước
khi lấy product detail. Chat giữ context giới hạn trong process bằng
`ConversationManager`; đây là MVP context, chưa phải durable conversation store.

## Model boundary and fallback

`AI_PROVIDER=fallback` và `AI_MODEL_NAME` là tùy chọn. Khi unset, các route vẫn
trả kết quả grounded từ backend bằng deterministic fallback. Khi chọn
`AI_PROVIDER=openai` hoặc `AI_PROVIDER=gemini`, infrastructure adapter tạo
agent lazy với output schema `ShoppingAnswer`; stream dùng agent text-only để
phát delta. Provider/network/configuration failure không làm route thành 500
và không thay đổi response key; adapter quay về fallback và ghi warning. Legacy
định dạng `provider:model` của PydanticAI vẫn được chấp nhận khi provider để
`fallback`.

Qdrant retrieval và catalog indexer đã có boundary executable; embedding
provider, collection provisioning, freshness và lựa chọn model/provider
production vẫn cần được cấu hình/verify trước khi đóng `ISSUE-019`.
