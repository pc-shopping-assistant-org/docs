# UC-CART-003 — Xóa sản phẩm khỏi giỏ

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CART-003` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xóa sản phẩm khỏi giỏ theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Giỏ hàng có mặt hàng cần xóa.

## Điều kiện sau

Mặt hàng được xóa khỏi giỏ.

## Luồng chính

1. Mở giỏ hàng.
2. Chọn xóa mặt hàng, hoặc xóa toàn bộ giỏ.
3. Hệ thống tìm dòng trong cart của customer hiện tại, xóa dòng (hoặc mọi dòng khi xóa toàn bộ giỏ), rồi hiển thị giỏ hàng đã cập nhật. Không phụ thuộc trạng thái bán của variant nên dòng đã hết bán vẫn xóa được.

## Luồng thay thế / ngoại lệ

- Customer chưa có cart hoặc variant không nằm trong giỏ → từ chối.
- Xóa toàn bộ giỏ khi chưa có cart hoặc giỏ đã rỗng → giỏ rỗng, không lỗi.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
