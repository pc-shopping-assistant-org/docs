# UC-CART-002 — Cập nhật số lượng trong giỏ

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CART-002` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật số lượng trong giỏ theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Giỏ hàng có ít nhất một mặt hàng.

## Điều kiện sau

Số lượng mặt hàng trong giỏ được cập nhật.

## Luồng chính

1. Mở giỏ hàng.
2. Thay đổi số lượng.
3. Hệ thống xác minh cart thuộc customer/session hiện tại.
4. Hệ thống kiểm tra quantity dương, không vượt tồn kho và cập nhật dòng hiện tại.

## Luồng thay thế / ngoại lệ

- Số lượng không dương hoặc vượt tồn kho.
- Cart không thuộc customer/session hiện tại hoặc không còn `ACTIVE`.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
