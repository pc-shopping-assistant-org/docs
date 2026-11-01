# Kiểm tra luồng AI — 2026-11-01

Source hiện tại đã qua browser với đăng nhập thật và Gemini thật. Đây là kiểm tra
local có đọc catalog trên server; không phải xác nhận production đã chạy bản sửa.

## Môi trường

- FE local: Next.js, BFF và cookie đăng nhập thật.
- AI local: source hiện tại, PostgreSQL/checkpointer/executor thật, Gemini 3.1 Flash Lite.
- Catalog/identity/media: HTTP trên server; chỉ đọc dữ liệu, không sửa catalog.
- Search-service: build JAR từ source mới, chạy local với Elasticsearch9.4.5 và Redis8.6.
  Index test chứa30 sản phẩm public được đọc từ catalog thật.
- Chưa cấu hình endpoint bge-m3 thật. kNN được kiểm tra với Elasticsearch thật và
  vector fixture1024 chiều; không dùng kết quả đó để đánh giá chất lượng embedding.

## Kết quả

| Hành trình | Kết quả |
| --- | --- |
| Tìm tai nghe Logitech dưới2 triệu | Hoàn tất; gửi và nhận SSE qua BFF |
| Hỏi tiếp so sánh G431/G333 | Hoàn tất, giữ đúng conversation |
| Đính kèm G431/G Pro X để so sánh | Hoàn tất, có bảng thông số và product cards |
| Mở quick-view | Đọc detail/ảnh/giá từ catalog thật; link sang trang sản phẩm |
| Hỏi thêm từ product card | Hoàn tất, thông số render Markdown thay vì Python dict |
| F5 URL chứa conversationId | Khôi phục đủ5 lượt chat; không tạo conversation mới |
| Tìm Logitech dưới1,5 triệu, còn hàng | Chạy qua AI → search-service source mới → ES/Redis → canonical catalog |
| Build PC gaming25 triệu từ catalog thật | Optimizer chạy; trả SEARCH_INCOMPLETE do thiếu physical/power metadata |
| So sánh ngay sau build chưa hoàn tất | Hoàn tất trên cùng conversation, không bị BUSY |

Build thành công cũng đã được chạy với model thật và fixture8 linh kiện có đủ
physical metadata, bỏ performance_score CPU/GPU: UNRANKED, tổng21.650.000 VND;
sau đó giải thích saved build và so sánh đều hoàn tất. Đây là fixture optimizer,
không chứng minh catalog thật đã đủ dữ liệu.

NET_CHANGED/admission mất response/SSE ngắt được kiểm tra bằng regression tests
của frontend và native persistence; không giả nhận đã tái tạo lỗi mạng OS trong browser.

## Lỗi đã sửa

- Search giá/tồn kho phải khớp cùng ACTIVE SKU; sửa cả ES và catalog fallback.
- Semantic-only kNN không OR với một query chỉ lọc rồi trả sản phẩm không liên quan.
- Lọc hãng/giá/tồn kho không cần bịa keyword; search-service nhận filter-only.
- Canonical detail phải xác nhận lại brand/category, trạng thái và giá.
- Mỗi HTTP call có durable IO reservation; semantic fallback giữ nguyên keyword.
- Một canonical result duy nhất có thể được chọn khi model bỏ refs/calls;
  nhiều result vẫn cần lựa chọn rõ ràng.
- Gemini có cap generation2048 và reasoning levellow nếu SDK profile hỗ trợ.
  Probe trước đây trả503; probe và các hành trình lần này đã nhận response thành công.
- FE bỏ badge còn hàng không có bằng chứng, không đổi giánull thành0; sửa
  translation quick-view, bảng so sánh V2 và canonical spec Markdown.
- Embedding HTTP clients có connect/read timeout3s/10s để search/sync có thể fallback.

## Kiểm chứng

- AI:1105 tests gồm PostgreSQL integration, Ruff/mypy212/lock167 pass.
- FE:241 tests, typecheck/lint, OpenAPI snapshots và production build pass.
- Backend:65 tests Maven common/search/sync pass; native ES/Redis kiểm tra mapping,
  lexical/kNN/filter-only, same-SKU filters và cache. HTTP search từ JAR pass.
- Infra:40 tests pass. Không start/deploy stack trên server.

Lệnh native search (chỉ dùng ES test tại127.0.0.1:19201, Redis tại19202):

```bash
mvn -B -ntp -pl search-service,sync-service -am -Dpcshop.search.native=true test
```

## Giới hạn còn lại

1. ISSUE-168: catalog thật còn thiếu physical/power metadata; không tự điền để
   ép optimizer ra build. Thiếu benchmark không làm mất build đã chứng minh tương thích.
2. Chưa đánh giá relevance của endpoint bge-m3 thật; cần provision endpoint và
   reindex trước khi gọi semantic search là đã nghiệm thu.
3. Plain text/qualitative explanation vẫn cần factuality eval. Ref hợp lệ không
   chứng minh mọi nhận định trong văn bản đúng; ISSUE-117 đã ghi ranh giới này.

Không claim “hết mọi bug” hoặc100% use-case. Owner đã yêu cầu push để tự test:
AI `13fc491`, FE `a9b9af2`, backend `357e583`; nhánh release giữ nguyên các version
AI1.0.5, web1.0.2, backend1.0.1. Infra main có wiring mới (`b04d6bd`).
Chưa chạy infra/deploy hoặc xác nhận các image mới đã được publish thành công.

## Recheck đồng bộ chỉ mục — 14:52 UTC

POST qua web/BFF, đăng nhập admin thật: HTTP200 sau76,93s;
`indexed=2391, removed=0, failed=0`. Gateway trước đó trả503 vì chưa tìm thấy
sync-service vừa restart trong Eureka. Lượt kiểm tra này không tái hiện lỗi đó.

Embedding vẫn404: server chạy AI1.0.5 (`5fc143b`), endpoint mới nằm trong
AI1.0.6 (`94b799a`). Keyword index dựng lại thành công; chưa có bằng chứng semantic
index đã sẵn sàng. ISSUE-175 ghi riêng readiness/version mismatch. Không đổi code,
env hay chạy thêm deploy trong lần chẩn đoán này.
