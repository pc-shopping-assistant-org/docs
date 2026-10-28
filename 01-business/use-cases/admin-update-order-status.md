# UC-ADM-ORD-003 — Cập nhật trạng thái đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-ORD-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 56 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Cập nhật trạng thái đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Đơn chưa hoàn thành.

## Điều kiện sau

Trạng thái đơn được cập nhật.

## Luồng chính

1. Xem đơn chưa hoàn thành.
2. Chọn trạng thái mới.
3. Hệ thống khóa đơn rồi kiểm tra điều kiện chuyển trạng thái: nhân viên chỉ được chuyển đúng bước kế tiếp `PENDING_CONFIRMATION` → `CONFIRMED` → `SHIPPING` → `COMPLETED`. Bước `PENDING_PAYMENT` → `PENDING_CONFIRMATION` do hệ thống thực hiện khi thanh toán thành công; hủy đơn dùng thao tác riêng (UC-ADM-ORD-004).
4. Hệ thống cập nhật trạng thái, ghi một dòng lịch sử (trạng thái cũ, mới, người đổi, lý do) trong cùng transaction rồi thông báo thành công.
5. Khi chuyển sang `COMPLETED`, hệ thống đặt ngày giao (đồng thời là ngày hóa đơn). `COMPLETED` và `CANCELLED` là trạng thái cuối, không đổi tiếp. Hoàn tất đơn không kiểm tra payment nên đơn COD có thể `COMPLETED` trước khi nhân viên ghi nhận thu tiền (UC-ADM-PAY-002).

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Chuyển trạng thái không hợp lệ (nhảy cóc, đi lùi, đơn đã `COMPLETED`/`CANCELLED`, hoặc muốn sang `CANCELLED`/`PENDING_CONFIRMATION` bằng thao tác này) → từ chối.
- Đơn không tồn tại → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
