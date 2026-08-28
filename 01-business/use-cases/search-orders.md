# UC-ORD-005 — Tìm kiếm đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-005` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng có quyền xem đơn của mình.

## Điều kiện sau

Đơn phù hợp điều kiện tìm kiếm được trả về.

## Luồng chính

1. Nhập số hóa đơn/mã đơn theo mô tả report.
2. Hệ thống tìm trong phạm vi đơn của khách.
3. Hiển thị kết quả.

## Luồng thay thế / ngoại lệ

- Không tìm thấy đơn.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
