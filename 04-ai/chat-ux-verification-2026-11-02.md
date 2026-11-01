# Chat UX — kiểm chứng 2026-11-02

## Thay đổi

- Chỉ transcript cuộn; composer cố định trong viewport, màu trung tính và viền nhẹ.
- Nút `+` bên trái mở menu → popup chọn sản phẩm. Đính kèm là dải thumbnail ngang
  phía trên input; tin đã gửi và history giữ nguyên lựa chọn.
- Thẻ sản phẩm canonical nằm sau đoạn nhắc tên; có xem nhanh và thao tác mua.
- Provider stream public text thành draft DELTA; kết quả đã validate thay draft.
  Không stream reasoning, JSON tool hay requirements.
- Mất kết nối: lấy kết quả của cùng run, không reload/resubmit. Nút kiểm tra kết quả
  đọc lại run. Lỗi model timeout/bận và xử lý có thông báo riêng; retry là thao tác
  chủ động với nội dung và đính kèm cũ.

## Browser và model thật

FE local `:3100`, AI local `:8011`, PostgreSQL local; catalog qua gateway thật,
Gemini được cấu hình từ runtime hiện có. Đăng nhập seed admin qua UI.

- Mobile 390×844: document 390×844, không tràn ngang/dọc; popup rộng358px.
  Nút `+`, chọn Logitech G431, thumbnail composer và xem chi tiết sản phẩm hoạt động.
- Desktop1440×1000: document1440×1000, composer trong viewport; footer storefront
  không xuất hiện trong assistant. Các trang khác giữ layout cũ.
- Câu hỏi giải thích Logitech G431: run `7d053e0e-8385-484d-bf0a-bd34485a2785`
  hoàn tất trong4,70s. Journal có5 draft DELTA; draft đầu lúc17:02:17.964 UTC,
  final DELTA/COMPLETED lúc17:02:18.955 UTC. Có canonical card giữa câu trả lời.
- F5 trên URL `?conversationId=...` giữ attachment và card, mở quick-view đúng sản phẩm.

Failure/retry và incremental replacement được kiểm tra bằng regression tests.
Không giả nhận đã tái tạo `NET_CHANGED` cấp hệ điều hành trong browser. Console có
403 cart của tài khoản ADMIN từ luồng storefront hiện có; không có lỗi render React.

## Ranh giới

Gate cuối: `pytest -q tests integration_tests` **1115 pass**, Ruff sạch,
mypy **215 source files**, `uv lock --check` pass. FE **248 test pass**;
typecheck, lint, OpenAPI generation check và production build pass.

Draft là nội dung tạm, không phải snapshot đã publish. Giá/identity/card dùng canonical
results; claim định tính vẫn thuộc factuality eval (ISSUE-117). Catalog physical/power
metadata và readiness semantic index tiếp tục theo ISSUE-168/175.

Không thay schema DB, không bump version và không chạy infra/deploy trong task này.
