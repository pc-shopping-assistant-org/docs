# Catalog snapshot page

`GET /products/snapshot` in catalog-service; gateway prefixes/routes are unchanged.
Public read, same visibility as product detail: ACTIVE products and ACTIVE variants.
Inactive/deleted rows never become AI evidence. Stock-zero ACTIVE variants remain
available for owned-part validation; the compiler decides purchase eligibility.

Uses ProductFilterRequest: `cursor`, `limit` (default 20, maximum 100), category,
brand, keyword and price filters. AI passes only cursor/limit to scan the complete
visible catalog; no top-k/keyword shortlist is treated as complete candidate proof.

Response: `{data, message: "SUCCESS", errors: []}`. Data is
`{items: ProductDetailResponse[], hasNext, nextCursor, size}`. Each item contains
product identity/category/status/specifications, a master-data `hardwareType`, and variants with identity,
productId/SKU/price/quantity/status/options. Empty arrays/maps are valid; missing
specifications/variants are not a hardware snapshot and AI rejects the response.

`hardwareType` comes from the product category's `hardware_types.code`,
batch-loaded through its FK. Core values: CPU, MAINBOARD, RAM,
GPU, PSU, CASE, COOLER, STORAGE; accessories: MONITOR, MOUSE, KEYBOARD, HEADSET.
Prebuilt product groups use separate master codes such as `PREBUILT_PC` and `PC_GAMING`;
they are valid catalog taxonomy but are not optimizer slots. The generic `OTHER` category
is used for products outside the component/accessory taxonomy. `GET /categories`
also exposes this metadata. AI consumes the snapshot field directly; category UUIDs and names are not configuration.
Category responses also expose non-negative `displayOrder`; public/admin lists and
the nested tree sort by `displayOrder ASC`, then category name. The generic `Khác`
category uses the `OTHER` hardware type and a high display order so it stays after
typed hardware categories.
Publish the updated catalog before the updated AI image.

`GET /hardware-types` returns active `{id, code, nameVi, nameEn, displayOrder}`
records sorted by display order/code. The admin dropdown uses this endpoint.
Category create/update accepts `hardwareTypeCode` and `displayOrder`; create defaults
to the `OTHER` master row, while update keeps the existing type/order when omitted.
Employee-only `PUT /categories/order` accepts `{items: [{id, displayOrder}]}`.
All IDs must be distinct live categories with the same parent; the update is atomic.

Products retain descending-ID cursor order; variants sort by product, price, ID.
One read-only REPEATABLE_READ transaction covers a page's product/association reads.
Across pages this is an observed catalog snapshot, not a frozen global catalog version.

Assembler batch-loads variants, images, options, brands and categories, and resolves
media once per page. Single-product detail reuses the same assembler. No DB query
or detail HTTP request per product. Existing product endpoints remain unchanged.

AI reserves one TOOL_IO per page. It rejects non-advancing/duplicate cursors,
malformed data, exhausted budget and candidate/page bounds rather than publishing
a truncated catalog as INFEASIBLE. Current bounds: 100 mapped variants, 20 pages;
the run's independent 16-call budget may reject earlier. No fallback to sample data
or the old N+1 scan. Update backend before enabling the new AI adapter.

Verified: Java service/assembler and standalone MockMvc tests; AI HTTP fixtures,
16-product budget regression, cursor/bound tests and optimizer/verifier flow.
Not proof of a deployed backend, live model or SQL query profiling.
