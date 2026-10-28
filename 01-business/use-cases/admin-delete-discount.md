# UC-ADM-DIS-004 — Xóa giảm giá

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-004` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 55 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Xóa giảm giá theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Discount không đang chạy (đang chạy thì phải khóa trước).

## Điều kiện sau

Khuyến mãi được xóa.

## Luồng chính

1. Chọn giảm giá.
2. Chọn xóa.
3. Hệ thống yêu cầu xác nhận.
4. Xác nhận.
5. Hệ thống khóa dòng discount, kiểm tra không đang `RUNNING`, rồi xóa mềm (trạng thái `DELETED`, ghi người thực hiện) và cập nhật danh sách. Discount chưa bắt đầu (`SCHEDULED`), đã hết hạn (`EXPIRED`) hoặc đã khóa (`LOCKED`) xóa được. Đơn hàng đã đặt giữ nguyên số tiền giảm đã tính; mã của discount đã xóa được dùng lại cho discount khác.

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Discount đang chạy → từ chối; nhân viên khóa nó (UC-ADM-DIS-005) rồi xóa.
- Discount không tồn tại hoặc đã xóa → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
