# UC-REV-001 — Đánh giá sản phẩm sau khi mua

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-REV-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.1, tr. 39 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đánh giá sản phẩm sau khi mua theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng đã đăng nhập; order item thuộc customer đó tồn tại và order tương ứng có trạng thái `COMPLETED`.

## Điều kiện sau

Đánh giá sản phẩm được ghi nhận và gắn duy nhất với order item.

## Luồng chính

1. Khách hàng mở sản phẩm/đơn đã mua.
2. Chọn chức năng đánh giá.
3. Nhập mức đánh giá và nội dung nhận xét.
4. Hệ thống lưu đánh giá.

## Luồng thay thế / ngoại lệ

- Mỗi order item chỉ được tạo tối đa một review.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
