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

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Giỏ hàng có ít nhất một mặt hàng.

## Điều kiện sau

Số lượng mặt hàng trong giỏ được cập nhật.

## Luồng chính

1. Mở giỏ hàng.
2. Thay đổi số lượng.
3. Hệ thống chỉ tìm dòng trong cart của customer hiện tại (cart được xác định từ tài khoản đăng nhập, không nhận cart id từ client) và khóa cart.
4. Hệ thống kiểm tra variant còn bán được, quantity từ 1 đến 9999 và không vượt tồn kho, rồi **thay** quantity của dòng bằng giá trị mới (không cộng dồn).
5. Hệ thống hiển thị giỏ hàng đã cập nhật.

## Luồng thay thế / ngoại lệ

- Số lượng ngoài 1–9999, vượt tồn kho hoặc vượt 9999 → từ chối.
- Variant không còn bán được → từ chối.
- Customer chưa có cart hoặc variant không nằm trong cart của họ → từ chối (không lộ giỏ của người khác).

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
