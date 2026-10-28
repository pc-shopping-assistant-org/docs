# UC-ADM-DIS-001 — Xem danh sách khuyến mãi

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-DIS-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 21 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh sách khuyến mãi theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách khuyến mãi được hiển thị.

## Luồng chính

1. Mở quản lý khuyến mãi.
2. Hệ thống hiển thị các chương trình chưa xóa, mới tạo trước, phân trang (mỗi trang 1–100, mặc định 20), có thể lọc theo trạng thái hiển thị.
3. Mỗi chương trình có tiêu đề, mã (nếu có), loại và giá trị giảm, phạm vi áp dụng, giá trị đơn tối thiểu, thời gian hiệu lực, danh mục áp dụng và trạng thái tính ra tại thời điểm xem: `SCHEDULED` (chưa đến giờ bắt đầu), `RUNNING` (đang chạy), `EXPIRED` (đã hết hạn), `LOCKED` (nhân viên đã khóa). Hết hạn không phải trạng thái lưu mà tính từ thời điểm kết thúc.
4. Chọn một chương trình để xem chi tiết.

## Luồng thay thế / ngoại lệ

- Số trang âm hoặc kích thước trang ngoài 1–100 → từ chối.
- Chương trình không tồn tại hoặc đã xóa ở trang chi tiết → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
