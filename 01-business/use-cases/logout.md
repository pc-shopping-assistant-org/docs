# UC-AUTH-004 — Đăng xuất

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-004` |
| Tác nhân | Khách hàng, Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 39–41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đăng xuất theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng đang đăng nhập.

## Điều kiện sau

Phiên đăng nhập kết thúc.

## Luồng chính

1. Người dùng chọn đăng xuất.
2. Hệ thống kết thúc phiên/xóa trạng thái xác thực.
3. Hệ thống đưa người dùng về trạng thái chưa đăng nhập.

## Luồng thay thế / ngoại lệ

- Không được report đặc tả thêm.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
