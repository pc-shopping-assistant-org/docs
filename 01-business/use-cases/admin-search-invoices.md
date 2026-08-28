# UC-ADM-INV-002 — Tìm kiếm/lọc hóa đơn

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-INV-002` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41–42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Tìm kiếm/lọc hóa đơn theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Có dữ liệu hóa đơn/đơn hoàn tất.

## Điều kiện sau

Kết quả phù hợp được hiển thị.

## Luồng chính

1. Tìm theo mã hóa đơn hoặc tên khách hàng.
2. Có thể lọc theo ngày/tháng/năm.
3. Hệ thống hiển thị kết quả.

## Luồng thay thế / ngoại lệ

- Report không xác định rõ invoice entity độc lập.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
