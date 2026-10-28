# UC-ADM-STAT-001 — Xem thống kê

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-STAT-001` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **IMPLEMENTATION** |
| Nguồn | Chương 5.2.7, tr. 89 |

> **Mức nguồn:** Có bằng chứng giao diện/triển khai ở Chương 5 nhưng Chương 3 không đặc tả đầy đủ.

## Mục tiêu

Xem thống kê theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`).

## Điều kiện sau

Thông tin thống kê được hiển thị.

## Luồng chính

1. Mở trang thống kê và chọn khoảng ngày (theo múi giờ cửa hàng, gồm cả ngày cuối).
2. Hệ thống tổng hợp từ Order Service và hiển thị:
   - Doanh thu theo ngày hoặc tháng (biểu đồ): tổng tiền các đơn `COMPLETED` nhóm theo ngày giao, kèm số đơn; kỳ không có đơn là 0. Tối đa 366 ngày, hoặc 60 tháng khi xem theo tháng.
   - Top sản phẩm bán chạy: nhóm các dòng hàng của đơn `COMPLETED` theo variant, xếp theo tổng số lượng (tối đa 50 dòng), kèm doanh thu; tên, SKU, nhãn lấy từ snapshot của dòng hàng. Tính theo variant, không gộp theo sản phẩm.
   - Số đơn theo trạng thái, lọc theo ngày tạo; luôn có đủ 6 trạng thái.

## Luồng thay thế / ngoại lệ

- Khoảng ngày đảo ngược hoặc quá dài, giới hạn top ngoài 1–50, thiếu ngày bắt đầu/kết thúc ở biểu đồ doanh thu → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
