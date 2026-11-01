# Live chat check — 2026-10-31

**Chưa pass toàn bộ luồng build.** AI `51df007`, FE `44f1e47`; không deploy trong lần test.

| Bước | Kết quả | Bằng chứng |
| --- | --- | --- |
| Catalog public | PASS | Browser hiển thị 2.391 sản phẩm |
| Tạo conversation | PASS | URL tự thêm `conversationId=d07b2035-0da6-47ed-aecd-abe3fced3f49` |
| Câu đầu | Backend PASS, delivery FAIL | Run `d55660ce` COMPLETED; browser báo tạm không khả dụng |
| F5 khôi phục | PASS | Giữ URL, tải lại câu hỏi và Markdown câu trả lời |
| Bổ sung yêu cầu | FAIL | Run `f9fbef97`: upstream error, recovery rồi REACT_VALIDATION_EXHAUSTED |
| Build sau bổ sung tồn kho | FAIL | Run `d7b4f236`: Gemini UPSTREAM_SERVER_ERROR; chưa tới optimizer |
| Khóa conversation | Không kẹt | revision1, active_run_id=null sau các runs kết thúc |

Network capture: Chrome báo `net::ERR_NETWORK_CHANGED` cho cả `/events` và
request đọc `/result` sau đó. Đây là bằng chứng lỗi kết nối trong phiên test,
không chứng minh nguyên nhân mạng thay đổi hoặc giải thích mọi lỗi run trước đó.

## Dữ liệu demo

SQL canonical `backend/catalog-service/src/main/resources/db/seed/demo/stock.sql`
đã chạy trên server trong một transaction: UPDATE 2.390 variants; 1 SKU đã có 10.
Kiểm tra sau commit: **2.391 variants ACTIVE, quantity=10**. Giá/ảnh/ID không đổi.
Không chạy lại deploy infra. CLI Java `--seed-demo-stock` và wrapper
`infra/scripts/seed-demo-stock.sh` là code mới, cần image catalog mới để gọi lại CLI.

Verification: **11 common-lib +172 catalog tests pass**, bao gồm PostgreSQL
idempotency/rollback/deleted records và full production-seed fixtures; **40 infra
tests pass**. Test DB local dùng temporary tables/private databases, không phải DB server.

## Blocker còn lại

- ISSUE-166: `/products/snapshot?limit=100` trả503. Catalog gộp IDs ảnh thành một
  GET media quá dài; media log `Request header is too large`, trả400. Cần batch media
  resolution hoặc endpoint bulk qua body; không tăng header size để che lỗi thiết kế.
- ISSUE-167: runtime catalog loader mặc định chỉ100 candidates/20 pages. Đây là
  giới hạn từ source, chưa kiểm chứng được sau bước snapshot vì endpoint đã lỗi503.
  Cần chốt giới hạn phù hợp catalog thật và test pagination/budget trước rollout.
- ISSUE-160/162: provider/validation failure và gián đoạn delivery vẫn còn. Không
  coi tồn kho10 là bằng chứng optimizer hoặc ReAct đã hoạt động end-to-end.

## Core fixes after the baseline

Code mới chưa commit/push/deploy; các lỗi runtime ở bảng đầu là baseline cũ.

| Boundary | Đã sửa và kiểm tra |
| --- | --- |
| Catalog → media | Chia tối đa100 ID/request; test1.700 ảnh, cả resolve và validate |
| Catalog → AI | Capacity3.000 variants/30 pages; SSD/HDD → STORAGE; giữ số đo mm lẻ |
| Ledger → model | Giữ replay inputs trong ledger; model chỉ đọc kết quả build, không toàn bộ candidates |
| Gemini → requirements | Predicate tách subject; quantity dạng chuỗi số có unit được normalize, không gọi extractor lần hai |
| Result completion | Bỏ objective không được hỗ trợ; chọn build_ref lấy đúng canonical refs; không dùng plain response để né kiểm chứng build |
| FE delivery | GET-result retry hữu hạn khi network đổi/502–504; không POST/SSE lần nữa, không retry401/403/404/410 |

Gemini thật đã chạy tới `READY_TO_PUBLISH/BUILT` với catalog fixture đủ thông số:
24.350.000 VND, RAM32GB. Đây là model thật + optimizer thật + graph preparation;
không phải kiểm chứng browser/DB publication của source chưa deploy.

Đọc catalog server bằng SQL chỉ đọc, dựng DTO tương ứng rồi chạy mapper local:
**2.391 products →1.800 core/accessory candidates**, không lỗi mapping. 591 prebuilt
PCs không phải linh kiện optimizer. Đã sửa lỗi55 GPU có chiều dài mm lẻ.
Chẩn đoán này bypass endpoint snapshot cũ đang lỗi503; không thay cho test HTTP
catalog→media sau release.

Gemini thật +1800 candidates từ bản đọc DB đã tới
`READY_TO_PUBLISH/SEARCH_INCOMPLETE`: trả rõ thiếu thông số catalog, không suy ra
ngân sách không đủ. Một lần gọi khác gặp upstream503; không cam kết provider luôn sẵn sàng.

**Data gate — ISSUE-168:** cả126 CPU và358 GPU chưa có performance_score; toàn bộ
GPU thiếu tdp_watts; PSU chưa có psu_tier. Chưa thể xếp hạng build thật theo policy
hiện tại. Cần metadata có nguồn và calibration rõ; không tự gán benchmark hoặc
lấy recommended_psu_w làm GPU TDP. Khi đủ dữ liệu, deploy source mới và chạy lại
browser journey. Production build chưa được tuyên bố hoàn tất.

Follow-up probe: Gemini có lần gửi đúng budget ID nhưng nhầm target collection.
Wire adapter hiện bind GOAL/REQUIREMENT theo ID tồn tại trong trusted state;
ID lạ vẫn bị từ chối. Regression cập nhật ngân sách giữ nguyên identity đã pass.
Probe live follow-up chưa pass trọn vẹn: có upstream503 và lần model bỏ target_id;
không claim chất lượng mọi lượt sửa yêu cầu đã được xác minh.

Validation local: common/catalog184 tests (PostgreSQL), FE230 tests +typecheck,
lint, OpenAPI and production build pass. AI1046 core/native tests, Ruff,
mypy212 source files and lock167 packages pass. Source vẫn chưa deploy.

Publication update2026-11-01: backend rebased onto current main; shared image
resolver moved to `helper/MediaFileResolver` and the regression follows it.
Re-run after integration: **14 common +188 catalog tests pass**, zero skipped;
infra40 tests pass. AI `a0e089b` and FE `ee58c5b` are included in their existing
release branches by upstream PR merges. Backend `13d25bb` pushed to main and
release/v1.0.1; infra `cc6ac2b` pushed to main only. No infra CD/deployment invoked.
Earlier "uncommitted/local" descriptions above record the original test environment.
