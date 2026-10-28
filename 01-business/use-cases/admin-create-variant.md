# UC-ADM-PROD-007 — Thêm biến thể sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-007` |
| Tác nhân | Nhân viên |
| Mức nguồn | **IMPLEMENTATION** |
| Nguồn | Chương 5.2.4, tr. 87 |

> **Mức nguồn:** Có bằng chứng giao diện/triển khai ở Chương 5 nhưng Chương 3 không đặc tả đầy đủ.

## Mục tiêu

Thêm biến thể sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Sản phẩm đã tồn tại.

## Điều kiện sau

Biến thể mới được tạo.

## Luồng chính

1. Mở giao diện thêm biến thể.
2. Nhập SKU, giá, tồn kho, số tháng bảo hành, barcode, model, mô tả, ngày phát hành và các tùy chọn của variant (mỗi option là một cặp tên + giá trị, ví dụ "Màu sắc" = "Xanh"; option đã có, không phân biệt hoa thường, thì dùng lại). Sản phẩm đang ẩn vẫn thêm variant được.
3. Có thể tải một ảnh riêng cho variant lên Media Service. Variant không có ảnh riêng thì hiển thị ảnh chính của product.
4. Hệ thống kiểm tra mỗi variant không có nhiều option cùng tên.
5. Xác nhận.
6. Hệ thống lưu variant và các liên kết option trong một transaction, ghi nhân viên thực hiện. Variant mới có trạng thái `ACTIVE`. Mỗi variant được thêm độc lập với việc tạo sản phẩm.
7. Sau khi tạo, nhân viên còn có các thao tác trên variant: sửa toàn bộ (kể cả tồn kho), ẩn/hiện, xóa mềm. Xóa bị từ chối khi variant còn tồn kho hoặc đã từng được đặt; khi đó nên ẩn. Tồn kho còn bị trừ/hoàn khi đặt/hủy đơn.

## Luồng thay thế / ngoại lệ

- Sản phẩm không tồn tại hoặc đã xóa → từ chối.
- SKU hoặc barcode trùng với một variant chưa bị xóa → từ chối (variant đã xóa mềm không tính, được dùng lại SKU/barcode). Barcode để trống thì không kiểm tra.
- Giá hoặc tồn kho âm; số tháng bảo hành không dương → từ chối.
- File ảnh không hợp lệ hoặc upload thất bại → từ chối.
- Variant có nhiều option cùng tên (so sánh không phân biệt hoa thường và khoảng trắng đầu/cuối) → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
