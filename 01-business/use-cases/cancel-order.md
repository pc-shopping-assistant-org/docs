# UC-ORD-003 — Hủy đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-003` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Hủy đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Đơn hàng thuộc trạng thái đang chờ duyệt/chờ xác nhận theo report.

## Điều kiện sau

Đơn hàng được chuyển sang trạng thái hủy.

## Luồng chính

1. Khách hàng chọn đơn đang chờ.
2. Chọn hủy đơn.
3. Hệ thống kiểm tra trạng thái.
4. Nếu hợp lệ, cập nhật đơn thành đã hủy.

## Luồng thay thế / ngoại lệ

- Đơn không còn ở trạng thái cho phép hủy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
