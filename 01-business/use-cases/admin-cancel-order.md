# UC-ADM-ORD-004 — Hủy đơn hàng khi có sự cố

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-ORD-004` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41; Hình 22 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Hủy đơn hàng khi có sự cố theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Có sự cố trong quá trình vận đơn theo mô tả report.

## Điều kiện sau

Đơn bị hủy và khách hàng được thông báo.

## Luồng chính

1. Chọn đơn hàng.
2. Chọn hủy đơn.
3. Hệ thống kiểm tra điều kiện.
4. Cập nhật trạng thái hủy.
5. Gửi/thể hiện thông báo đến khách hàng.

## Luồng thay thế / ngoại lệ

- Không thể hủy ở trạng thái hiện tại.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
