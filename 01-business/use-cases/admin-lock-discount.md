# UC-ADM-DIS-005 — Khóa/ẩn giảm giá

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-005` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 55 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Khóa/ẩn giảm giá theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Giảm giá tồn tại.

## Điều kiện sau

Giảm giá được chuyển sang trạng thái khóa/ngừng áp dụng.

## Luồng chính

1. Chọn giảm giá.
2. Chọn khóa.
3. Hệ thống yêu cầu xác nhận.
4. Xác nhận.
5. Hệ thống đặt trạng thái lưu `INACTIVE` (khóa) và ghi người thực hiện. Khóa có hiệu lực ngay: discount không còn được dùng khi tính giá đơn hàng, và hiển thị là `LOCKED`. Mở khóa (đặt lại `ACTIVE`) thì discount lại chạy nếu còn trong thời gian hiệu lực; mở khóa discount đã hết hạn thì nó hiển thị `EXPIRED`.

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Đặt trạng thái `DELETED` ở đây → từ chối, phải dùng thao tác xóa.
- Discount không tồn tại hoặc đã xóa → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
