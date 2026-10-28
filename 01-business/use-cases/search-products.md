# UC-CAT-003 — Tìm kiếm sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CAT-003` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng truy cập chức năng tìm kiếm (không cần đăng nhập).

## Điều kiện sau

Danh sách sản phẩm phù hợp truy vấn được hiển thị.

## Luồng chính

1. Nhập nội dung tìm kiếm.
2. Nội dung là tên sản phẩm, thương hiệu hoặc danh mục (từ khóa dạng chữ). Mô tả nhu cầu tự do (ví dụ "laptop cho thiết kế đồ họa") là tìm kiếm ngữ nghĩa của UC-AI-002, không thuộc use case này.
3. Hệ thống truy vấn chỉ mục tìm kiếm (Elasticsearch, do search-service đọc): khớp tên sản phẩm (trọng số cao nhất), thương hiệu, danh mục và mô tả; không phân biệt hoa thường và dấu tiếng Việt (`card do hoa` tìm được `Card đồ họa`), chịu được gõ sai nhẹ và từ gõ dở (`rtx 40` tìm được `RTX 4070`). Có thể kết hợp với bộ lọc danh mục, thương hiệu, khoảng giá (xem UC-CAT-004); bộ lọc là điều kiện bắt buộc và không ảnh hưởng thứ tự độ khớp.
4. Trả về danh sách phù hợp theo trang số (kèm tổng số kết quả), sắp theo độ khớp giảm dần, mỗi trang tối đa 50 kết quả. Mỗi kết quả gồm tên, thương hiệu, danh mục, khoảng giá, ảnh chính và cờ còn hàng.

Chỉ mục tìm kiếm do sync-service cập nhật từ thay đổi ở Catalog (Debezium đọc thay đổi của các bảng sản phẩm, variant, ảnh, thương hiệu, danh mục rồi dựng lại bản ghi tìm kiếm). Sản phẩm không còn hiển thị (không `ACTIVE`, đã xóa) bị gỡ khỏi chỉ mục. Chỉ mục nhất quán sau cùng: thay đổi ở Catalog hiện ra trong tìm kiếm sau vài giây; khi cần, quản trị đồng bộ lại toàn bộ chỉ mục từ trang quản trị.

## Luồng thay thế / ngoại lệ

- Không có kết quả phù hợp → danh sách rỗng.
- Từ khóa rỗng hoặc dài quá 200 ký tự, số trang âm, kích thước trang ngoài 1–50, khoảng giá sai → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
