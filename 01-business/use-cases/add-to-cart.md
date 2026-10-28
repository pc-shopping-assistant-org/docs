# UC-CART-001 — Thêm sản phẩm vào giỏ hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CART-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Thêm sản phẩm vào giỏ hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Variant tồn tại và đang có thể bán (guest không có giỏ hàng).

## Điều kiện sau

Sản phẩm được thêm vào giỏ.

## Luồng chính

1. Khách hàng chọn sản phẩm/biến thể.
2. Chọn thêm vào giỏ.
3. Hệ thống kiểm tra variant có đang bán được không: variant và sản phẩm của nó đều phải `ACTIVE`.
4. Hệ thống tìm cart duy nhất của customer, tạo nếu chưa có, và khóa cart để các lần thêm đồng thời vào cùng giỏ xếp hàng chờ nhau.
5. Nếu variant đã có trong cart, hệ thống **cộng** quantity mới vào quantity hiện có; nếu chưa có thì tạo `cart_item`.
6. Hệ thống kiểm tra quantity cộng dồn không vượt tồn kho hiện tại của variant và không quá 9999 mỗi dòng.
7. Giỏ hàng được lưu và hiển thị, kèm giá, tên, ảnh hiện tại của từng dòng (cart chỉ lưu variant và quantity), tổng số lượng và tạm tính.

Mỗi customer chỉ có một cart; cart không có trạng thái. Khi đặt hàng xong hệ thống xóa hết cart item, dòng cart vẫn giữ lại để dùng cho lần sau. Thêm vào giỏ không giữ chỗ tồn kho; tồn kho chỉ được giữ khi đặt hàng. Dòng nào về sau hết bán thì giỏ vẫn hiển thị nhưng đánh dấu không khả dụng và không tính vào tổng.

## Luồng thay thế / ngoại lệ

- Variant không tồn tại hoặc không bán được (variant hay sản phẩm không `ACTIVE`) → từ chối.
- Quantity cộng dồn lớn hơn tồn kho, hoặc vượt 9999, hoặc quantity ngoài 1–9999 → từ chối.
- Người dùng chưa đăng nhập: hệ thống từ chối và yêu cầu đăng nhập. Không có tính năng guest: chỉ khách đã đăng nhập mới thêm hàng vào giỏ và đặt hàng.
- Tạo đồng thời hai cart cho cùng một customer: ràng buộc unique từ chối cart thứ hai, hệ thống dùng lại cart đã có và không tạo thêm cart.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
