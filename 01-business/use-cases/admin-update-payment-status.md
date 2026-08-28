# UC-ADM-PAY-002 — Cập nhật trạng thái thanh toán

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PAY-002` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật trạng thái thanh toán theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Đơn/giao dịch thanh toán tồn tại.

## Điều kiện sau

Trạng thái thanh toán được cập nhật.

## Luồng chính

1. Chọn giao dịch/đơn.
2. Chọn trạng thái thanh toán.
3. Hệ thống cập nhật.

## Luồng thay thế / ngoại lệ

- Cần đối chiếu với tích hợp Stripe để tránh cập nhật thủ công sai nguồn sự thật; report không đặc tả chi tiết.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
