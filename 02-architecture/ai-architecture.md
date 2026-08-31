# AI Service Architecture

## Boundary

`ai-service` là một FastAPI service tách khỏi backend nghiệp vụ. Nó cung cấp
`/api/v1/chat`, `/api/v1/search`, `/api/v1/consult`, `/api/v1/compare` và
`/api/v1/evaluate`. Tất cả route dùng envelope `{data, message, errors}`; giá
trị `message` là key tĩnh để frontend mapping.

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
       -> PydanticAIAnswerGenerator (optional model)
       -> deterministic fallback when model is absent/unavailable
    -> canonical ApiResponse
```

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

`AI_MODEL_NAME` là tùy chọn. Khi unset, các route vẫn trả kết quả grounded từ
backend bằng deterministic fallback. Khi set theo định dạng PydanticAI (ví dụ
`openai:gpt-4o-mini`), adapter tạo agent lazy với output schema
`ShoppingAnswer`. Provider/network/configuration failure không làm route thành
500 và không thay đổi response key; adapter quay về fallback và ghi warning.

Qdrant retrieval và catalog indexer đã có boundary executable; embedding
provider, collection provisioning, freshness và lựa chọn model/provider
production vẫn cần được cấu hình/verify trước khi đóng `ISSUE-019`.
