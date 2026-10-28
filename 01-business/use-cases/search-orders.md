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

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Khách hàng có đơn hàng của mình.

## Điều kiện sau

Đơn phù hợp điều kiện tìm kiếm được trả về.

## Luồng chính

1. Nhập số hóa đơn/mã đơn theo mô tả report.
2. Hệ thống chấp nhận mã đơn (UUID đầy đủ hoặc không dấu gạch) hoặc số hóa đơn dạng `INV-` + 10 ký tự ngẫu nhiên, sinh lúc tạo đơn (ví dụ `INV-7K3M9QX2BD`).
3. Hệ thống tìm trong phạm vi đơn của khách và áp dụng thêm trạng thái nếu được chọn. Từ khóa khớp **chính xác** mã đơn hoặc số hóa đơn (không phân biệt hoa thường); không tìm theo một phần mã hay theo tên sản phẩm.
4. Hiển thị kết quả cùng định dạng, phân trang với lịch sử đơn hàng. Từ khóa rỗng thì trả toàn bộ đơn của khách.

## Luồng thay thế / ngoại lệ

- Không tìm thấy đơn, hoặc mã thuộc đơn của khách khác → danh sách rỗng (không lộ đơn người khác).

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
