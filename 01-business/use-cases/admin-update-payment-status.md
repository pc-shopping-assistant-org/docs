# UC-ADM-PAY-002 — Cập nhật trạng thái thanh toán

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PAY-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật trạng thái thanh toán theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Đơn/giao dịch thanh toán tồn tại.

## Điều kiện sau

Trạng thái thanh toán được cập nhật.

## Luồng chính

1. Chọn giao dịch/đơn.
2. Chọn trạng thái thanh toán.
3. Hệ thống khóa payment, kiểm tra việc chuyển có thuộc hai thao tác thủ công cho phép rồi cập nhật, ghi người thực hiện:
   - Payment COD `PENDING` → `PAID`: nhân viên đánh dấu khi giao hàng và thu tiền (ghi thời điểm thanh toán).
   - Payment `PAID` → `REFUNDED` (mọi phương thức): nhân viên đánh dấu sau khi liên hệ khách và hoàn tiền thủ công ngoài hệ thống.
4. Các chuyển còn lại do hệ thống làm, không sửa tay: payment VNPAY `PENDING` sang `PAID`/`FAILED` theo callback có chữ ký của VNPAY, payment `PENDING` sang `CANCELLED` khi đơn bị hủy. `FAILED`, `CANCELLED`, `REFUNDED` là trạng thái cuối.
5. Khi hệ thống đóng payment online (`PAID`/`FAILED`) nó phát sự kiện để Order Service đưa đơn sang `PENDING_CONFIRMATION` hoặc hủy đơn. Đánh dấu COD `PAID` hay `REFUNDED` bằng tay không đổi trạng thái đơn.
6. Trường hợp riêng: khi cần đối soát với cổng, nhân viên có thể báo tay kết quả của payment online đang `PENDING` (thành công hoặc thất bại, kèm mã giao dịch không trùng); thao tác này tương đương callback VNPAY và cùng phát sự kiện. Không áp dụng cho COD.

## Luồng thay thế / ngoại lệ

- Chuyển trạng thái ngoài các thao tác cho phép (kể cả sửa tay payment online sang `PAID`/`FAILED`) → từ chối, để không lệch với cổng VNPAY.
- Đơn đã có một payment `PAID` khác thì không đánh dấu thêm payment thứ hai `PAID` → từ chối.
- Payment không tồn tại → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.
