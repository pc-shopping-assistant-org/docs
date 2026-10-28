# UC-ADM-INV-001 — Xem hóa đơn

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-INV-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41–42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem hóa đơn theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Đơn hàng đã hoàn tất theo mô tả report.

## Điều kiện sau

Thông tin hóa đơn được hiển thị.

## Luồng chính

1. Mở chức năng hóa đơn.
2. Chọn hóa đơn/đơn hoàn tất.
3. Hệ thống hiển thị danh sách hóa đơn (số hóa đơn, người nhận, tổng tiền, ngày hóa đơn, mới nhất trước, phân trang như danh sách đơn) và chi tiết một hóa đơn (người nhận, số điện thoại, địa chỉ giao, các dòng hàng, tạm tính, tiền giảm, phí giao, tổng tiền).
4. Hóa đơn không có bảng riêng: đó là đơn hàng `COMPLETED`, nội dung lấy từ snapshot của đơn, ngày hóa đơn là ngày giao. Số hóa đơn được sinh lúc tạo đơn nên đơn chưa hoàn tất hoặc đã hủy cũng có số, nhưng màn hình hóa đơn chỉ hiển thị đơn `COMPLETED`.

## Luồng thay thế / ngoại lệ

- Đơn không tồn tại hoặc chưa `COMPLETED` (kể cả đã hủy) → không hiển thị như hóa đơn.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
