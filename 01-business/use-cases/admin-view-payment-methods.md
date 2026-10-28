# UC-ADM-PAY-001 — Xem phương thức thanh toán

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PAY-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem phương thức thanh toán theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Các hình thức thanh toán được hỗ trợ được hiển thị.

## Luồng chính

1. Mở quản lý thanh toán.
2. Hệ thống hiển thị mọi phương thức đã cấu hình, đang dùng hay không, sắp theo tên: mã, tên, trạng thái (`ACTIVE`/`INACTIVE`). Hiện có `COD` và `VNPAY` đang dùng; thẻ online cũ đã `INACTIVE` từ khi chuyển sang VNPAY.
3. Khách hàng khi đặt hàng chỉ thấy các phương thức `ACTIVE`.

## Luồng thay thế / ngoại lệ

- Hệ thống chỉ cho xem; chưa có chức năng thêm, sửa hoặc bật/tắt phương thức thanh toán (thay đổi qua cập nhật dữ liệu hệ thống).

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
