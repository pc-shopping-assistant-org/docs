# Catalog retrieval

Catalog service là nguồn chuẩn cho product/variant/price/stock/visibility.
Keyword/vector search chỉ tìm candidates; stale payload không được override backend facts.

## V2 canonical tools

`search_catalog`, `get_product_details` và `compare_products` dùng
BackendProductCatalog qua application port.

Product summary có price range; range không là exact variant price.
Missing detail/spec ghi unknown. Inactive/deleted products không vào model evidence.
Names cần canonical resolution, không top-k uniqueness proof.

## Hardware snapshots

Build/requirement resolution dùng BackendRequirementCatalog và versioned taxonomy mapping.
Adapter quét bounded cursor pages của [snapshot API](../05-api/catalog-snapshot.md),
không N+1 product-detail calls.

Overflow/budget/schema error phải fail rõ; không coi truncated candidates là exhaustive
catalog rồi báo global INFEASIBLE. ACTIVE stock0 có thể phục vụ owned validation;
compiler quyết định purchasable stock.

Read-only V2 turns không preload hardware snapshot. Native recovery giữ snapshot đã
checkpoint để không refetch committed optimizer inputs.

## Optional vector seam

Request-scoped AssistantService có CatalogRetriever seam: backend lexical,
hybrid/Qdrant adapters và catalog indexer. Đây là configurable retrieval capability,
không có nghĩa V2 tools tự dùng vector DB hoặc durable memory đã chuyển sang Qdrant.

Embedding provider/chunking/freshness/threshold/index lifecycle cần policy riêng.
Chưa có vector configuration thì lexical baseline là explicit mode, không semantic search proof.

## Index catalog

Chỉ sau khi collection và embedding configuration đã sẵn sàng:

```bash
uv run ai-index-catalog
```

Command đọc cursor pages và upsert embeddings/payloads. Index ACTIVE only và
backend-revalidate visibility khi retrieval; hash embeddings chỉ development.
Deletion/freshness/scheduling policy không được suy từ một lần index thành công.

Source: [indexer](../../ai-service/src/ai_service/index_catalog.py),
[retrievers](../../ai-service/src/ai_service/services/).

**Next:** [Configuration](configuration.md) · [Web research](web-research.md).
