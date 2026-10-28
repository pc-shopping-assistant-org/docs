# UC-ADM-ORD-001 — Xem danh sách đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-ORD-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 56 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Xem danh sách đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách đơn hàng được hiển thị.

## Luồng chính

1. Mở quản lý đơn hàng.
2. Hệ thống trả đơn của mọi khách hàng, mới nhất trước, phân trang theo số trang (mỗi trang 1–100, mặc định 50, kèm tổng số). Có thể lọc theo trạng thái, khách hàng, khoảng ngày tạo và từ khóa; từ khóa khớp một phần (không phân biệt hoa thường) mã đơn, số hóa đơn, tên người nhận hoặc số điện thoại người nhận.
3. Hiển thị danh sách đơn: số hóa đơn, khách hàng, người nhận và số điện thoại, trạng thái, tổng tiền, số dòng hàng, tên sản phẩm đầu tiên, ngày tạo.

## Luồng thay thế / ngoại lệ

- Số trang âm, kích thước trang ngoài 1–100, hoặc thời điểm bắt đầu không trước thời điểm kết thúc → từ chối.
- Tài khoản không có vai trò nhân viên (kể cả quản trị viên thuần) → từ chối truy cập.
- Không có đơn khớp → danh sách rỗng.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
