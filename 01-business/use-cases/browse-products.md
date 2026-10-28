# UC-CAT-002 — Xem danh sách sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CAT-002` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh sách sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng truy cập website (không cần đăng nhập).

## Điều kiện sau

Danh sách sản phẩm phù hợp trạng thái hiển thị được trả về.

## Luồng chính

1. Mở trang danh sách/danh mục.
2. Hệ thống tải các sản phẩm. Chỉ sản phẩm `ACTIVE` có ít nhất một variant `ACTIVE` mới được liệt kê, sắp theo sản phẩm mới nhất trước.
3. Hiển thị thông tin cơ bản để người dùng lựa chọn: tên, thương hiệu, danh mục, ảnh chính, khoảng giá thấp nhất–cao nhất, số variant và tổng tồn kho. Sản phẩm hết hàng vẫn được liệt kê.
4. Danh sách được phân trang theo số trang (kèm tổng số sản phẩm và tổng số trang), mặc định 20 sản phẩm mỗi trang, tối đa 100. Nếu người dùng yêu cầu trang vượt quá số trang hiện có, giao diện hiển thị trang cuối.
5. Menu danh mục lấy từ cây danh mục công khai, mỗi danh mục kèm số sản phẩm hiển thị được (gồm cả danh mục con) và tên loại phần cứng lấy từ master data `hardware_types` để dịch tên danh mục theo ngôn ngữ.

## Luồng thay thế / ngoại lệ

- Không có sản phẩm nào hiển thị được → danh sách rỗng.
- Số trang âm → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
