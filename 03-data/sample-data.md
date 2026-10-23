# Production seed

Một seed Java qua bootstrap `--seed-prod` của catalog, không khởi động web/listeners.
Dataset duy nhất là `backend/scripts/seed/catalog_seed.json`: 90 thương hiệu,
1.625 sản phẩm/biến thể, 8.502 ảnh, cùng taxonomy và template thông số.

```sh
# Từ backend/ với runtime env đã export:
mvn -pl catalog-service -am -Pseed-prod -DskipTests package

# Từ infra/ với image backend đã publish:
./scripts/seed-prod.sh
```

Seed chạy Flyway từ từng service sở hữu DB rồi chỉ INSERT các hàng còn thiếu.
Hàng đã tồn tại được bỏ qua, gồm ID, metadata, tồn kho, giá và trạng thái.
Natural key được ánh xạ về ID có sẵn để các FK/liên kết đúng. Không khôi phục hàng
đã soft-delete. Biến thể mới lấy đúng quantity/status trong JSON (hiện `0`/`INACTIVE`).

Ảnh có file row còn thiếu được tải từ URL nguồn lên bucket `pcshop-media` đã tạo
thủ công trong Admin UI. Key deterministic `seed/catalog/<file-id>/<original-name>`;
object đã có được tái sử dụng qua HEAD, không ghi đè. `media_db.files` lưu provider
`S3`, key, MIME/dung lượng thật và URL `<public-origin>/<bucket>/<key>`.
File row EXTERNAL/Cloudinary đã có được giữ nguyên, không tự migrate ảnh lịch sử.

Catalog được validate bằng cùng validator của API trước upload/commit seed.
Ba DB có transaction riêng; validation/upload lỗi rollback hàng chưa commit,
lỗi commit báo các DB đã commit. Chạy lại tiếp tục từ hàng/object đã có. Flyway
migrations commit độc lập. Không có tuyên bố atomic transaction xuyên ba DB/S3.

Bucket/key/public-read policy phải có trước lần seed đầu; 8.502 ảnh có thể lâu hơn
timeout CD nên chạy seed đầu thủ công. Runtime env và xử lý lỗi search:
[backend seed runbook](../../backend/scripts/README.md).
AI đọc `hardwareType` từ catalog, không cần category UUID trong env.
