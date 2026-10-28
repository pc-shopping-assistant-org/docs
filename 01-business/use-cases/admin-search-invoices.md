# UC-ADM-INV-002 — Tìm kiếm/lọc hóa đơn

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-INV-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41–42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm/lọc hóa đơn theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Có dữ liệu hóa đơn/đơn hoàn tất.

## Điều kiện sau

Kết quả phù hợp được hiển thị.

## Luồng chính

1. Tìm theo số hóa đơn hoặc tên khách hàng (tên người nhận trên đơn), chỉ trong các đơn `COMPLETED`.
2. Có thể lọc theo ngày hóa đơn (ngày giao hàng): từ ngày (gồm) đến ngày (không gồm), từ ngày phải trước đến ngày.
3. Hệ thống hiển thị kết quả. Từ khóa khớp một phần số hóa đơn hoặc tên người nhận, không phân biệt hoa thường; bỏ trống thì không lọc theo từ khóa. Sắp theo ngày hóa đơn mới nhất trước, phân trang (mỗi trang 1–100).

## Luồng thay thế / ngoại lệ

- Số trang âm, kích thước trang ngoài 1–100, hoặc khoảng ngày sai → từ chối.
- Không có hóa đơn khớp → danh sách rỗng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
