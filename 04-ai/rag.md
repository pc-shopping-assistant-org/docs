# RAG boundary

Report định hướng embedding và vector retrieval (Qdrant). Repository hiện có
HTTP Qdrant/embedding adapters và một catalog indexer; local baseline vẫn dùng
backend catalog search làm fallback khi vector configuration chưa đầy đủ.

Khi triển khai RAG thật, pipeline cần tách:

1. đồng bộ product/specification document từ backend;
2. tạo embedding và lưu kèm product/variant ID;
3. truy vấn vector với filter trạng thái sản phẩm;
4. đưa các record đã truy xuất vào prompt model;
5. giữ product IDs và canonical prices trong response.

Provider embedding, chunking, freshness, score threshold và Qdrant lifecycle
phải được chốt trước khi đóng ISSUE-019.

## Retrieval seam in the service

`AssistantService` nhận một `CatalogRetriever` protocol. Baseline inject
`BackendCatalogRetriever`, adapter này gọi `GET /products` của backend để giữ
catalog backend làm source of truth. Khi bật Qdrant, `QdrantCatalogIndexer`
đồng bộ product payload + embedding vào collection và
`QdrantCatalogRetriever` trả payload đã index (hoặc hydrate product detail theo
ID). Search, chat và consult đều đi qua seam; `shopping_graph` chạy trước seam
để normalize query và giữ intent planning deterministic.

Index local/ops bằng command idempotent `uv run ai-index-catalog`. Command đọc
toàn bộ catalog qua cursor pages (mỗi request tối đa 100 record), tạo embedding
và upsert vào collection. Cursor lặp có guard chống cursor lỗi/lặp; freshness,
xoá record không còn ACTIVE và lịch chạy đồng bộ vẫn cần policy vận hành riêng.

Trong fallback adapter, hệ thống thử cả cụm truy vấn trước; nếu không có hit,
nó tách một số từ khóa có nghĩa, gọi lại catalog endpoint và loại bản ghi trùng.
Đây chỉ là lexical expansion có giới hạn để local flow hữu ích hơn, không phải
embedding retrieval.

Đây là boundary có thể cấu hình bằng dependency injection. Khi chưa có
index/provider, backend keyword retrieval vẫn là fallback grounded và
ISSUE-019 vẫn mở.
