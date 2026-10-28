# UC-ADM-CUS-005 — Khóa/chặn tài khoản khách hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CUS-005` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 19 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Khóa/chặn tài khoản khách hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Khách hàng có tài khoản.

## Điều kiện sau

Tài khoản bị khóa nhưng dữ liệu khách hàng được giữ.

## Luồng chính

1. Chọn khách hàng.
2. Chọn khóa/chặn.
3. Xác nhận.
4. Hệ thống đặt trạng thái tài khoản thành `LOCKED` và ghi mốc thu hồi token trong một transaction. Khách bị chặn đăng nhập và mọi token cấp trước thời điểm khóa mất hiệu lực (không khóa được nếu hệ thống thu hồi token không khả dụng).
5. Dữ liệu khách hàng (hồ sơ, địa chỉ, đơn hàng, đánh giá) được giữ nguyên. Các đơn đang xử lý (chưa `COMPLETED` hoặc `CANCELLED`) tiếp tục được xử lý bình thường, khóa tài khoản không hủy hay đổi đơn. Hệ thống không có chức năng mở khóa.

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Tài khoản đã bị khóa → từ chối.
- Không phải tài khoản khách hàng → xử lý như không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
