# UC-ADM-PROD-005 — Xóa sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-005` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 50; rule ở Chương 3.1.2 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Xóa sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Sản phẩm chưa có tồn kho và chưa từng được đặt hàng (report: chưa được nhập về kho).

## Điều kiện sau

Sản phẩm được xóa theo nghiệp vụ report.

## Luồng chính

1. Chọn xóa sản phẩm.
2. Hệ thống yêu cầu xác nhận.
3. Nhân viên xác nhận.
4. Hệ thống kiểm tra từng variant chưa xóa của sản phẩm: tồn kho phải bằng 0 và variant chưa từng nằm trong đơn hàng nào (hỏi Order Service).
5. Nếu đạt, hệ thống xóa mềm sản phẩm cùng toàn bộ variant (trạng thái `DELETED`, ghi người thực hiện), nên tên SEO, SKU và barcode dùng lại được; sản phẩm biến mất khỏi mọi danh sách và chỉ mục tìm kiếm.

## Luồng thay thế / ngoại lệ

- Người dùng hủy xóa → không đổi gì.
- Có variant còn tồn kho hoặc đã từng được đặt → từ chối, không xóa gì; nhân viên ẩn sản phẩm thay thế (UC-ADM-PROD-006).
- Sản phẩm không tồn tại hoặc đã xóa → từ chối.
- Order Service không trả lời khi kiểm tra lịch sử đơn → báo lỗi, không xóa.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
