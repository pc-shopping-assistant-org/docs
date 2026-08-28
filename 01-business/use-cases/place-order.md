# UC-ORD-001 — Đặt hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 57 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đặt hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng đã đăng nhập hoặc xác thực thành công; giỏ hàng có sản phẩm.

## Điều kiện sau

Đơn hàng được tạo thành công.

## Luồng chính

1. Mở giỏ hàng.
2. Chọn đặt hàng.
3. Hệ thống mở trang đặt hàng.
4. Khách hàng nhập thông tin cần thiết.
5. Chọn địa chỉ giao hàng.
6. Nhập mã giảm giá nếu có.
7. Chọn phương thức thanh toán.
8. Xác nhận đặt hàng.
9. Hệ thống lưu đơn và thông báo thành công.

## Discount calculation

Đơn hàng có thể áp dụng đồng thời một item promotion cho mỗi dòng và một order voucher cho toàn đơn. Không cho phép nhiều voucher trên cùng order.

```text
20.000.000 - 2.000.000 - 500.000 + 30.000 = 17.530.000
```

## Luồng thay thế / ngoại lệ

- Thông tin đơn hàng không hợp lệ → yêu cầu nhập lại.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
