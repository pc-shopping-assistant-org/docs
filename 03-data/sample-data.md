# Production seed

Một seed Java qua bootstrap `--seed-prod` của catalog, không khởi động web/listeners.
CLI/Compose gộp `backend/scripts/seed/catalog_seed.json`, `pc_catalog_seed.json` và
`gear_catalog_seed.json`: 2.389 sản phẩm/biến thể, 99 thương hiệu và 19 hardware types.
PC có 10 definitions/50 category links; gear có 25 definitions/51 category links.
Thông số gear dùng key chuẩn; nhãn chưa chuẩn hóa được giữ trong LIST
`additional_specs`, không bị bỏ đi hoặc tự đoán giá trị số/đơn vị.

```sh
# Từ backend/ với runtime env đã export:
mvn -pl catalog-service -am -Pseed-prod -DskipTests package

# Từ infra/ với image backend đã publish:
./scripts/seed-prod.sh
```

Seed chạy Flyway từ từng service sở hữu DB rồi chỉ INSERT các hàng còn thiếu.
Hàng đã tồn tại được bỏ qua, gồm ID, metadata, tồn kho, giá và trạng thái.
Natural key được ánh xạ về ID có sẵn để các FK/liên kết đúng. Không khôi phục hàng
đã soft-delete. Biến thể mới lấy đúng quantity/status trong JSON (hiện `0`/`ACTIVE`).

Ảnh có file row còn thiếu được tải từ URL nguồn lên bucket `pcshop-media` đã tạo
thủ công trong Admin UI. Key deterministic `seed/catalog/<file-id>/<original-name>`;
object đã có được tái sử dụng qua HEAD, không ghi đè. `media_db.files` lưu provider
`S3`, key, MIME/dung lượng thật và URL `<public-origin>/<bucket>/<key>`.
File row EXTERNAL/Cloudinary đã có được giữ nguyên, không tự migrate ảnh lịch sử.
URL nguồn trả HTML/404 hoặc không đọc được sẽ được báo và bỏ qua ảnh/liên kết đó;
sản phẩm vẫn được seed. Lần chạy sau thử lại ảnh còn thiếu. Lỗi S3/DB vẫn dừng seed.

Catalog được validate bằng cùng validator của API trước upload/commit seed.
Ba DB có transaction riêng; validation/S3 lỗi rollback hàng chưa commit,
lỗi commit báo các DB đã commit. Chạy lại tiếp tục từ hàng/object đã có. Flyway
migrations commit độc lập. Không có tuyên bố atomic transaction xuyên ba DB/S3.

Bucket/key/public-read policy phải có trước lần seed đầu; khoảng 14.600 file nguồn có thể lâu hơn
timeout CD nên chạy seed đầu thủ công. Runtime env và xử lý lỗi search:
[backend seed runbook](../../backend/scripts/README.md).
AI đọc `hardwareType` từ catalog, không cần category UUID trong env.

## Master data và thứ tự danh mục

- `hardware_types` lưu `id`, `code`, `name_vi`, `name_en`, trạng thái và thứ tự.
  Migration V13 chuyển code cũ sang FK bắt buộc; `Khác` tham chiếu record `OTHER`.
- Brands, categories, attribute definitions, payment/shipping methods và roles
  đã là bảng dữ liệu. Status, attribute data type và các phép toán nghiệp vụ
  vẫn là enum vì code phải thực thi semantics của chúng.
- V12 thêm `categories.display_order`. Admin kéo thả trong cùng cấp hoặc sửa số;
  thứ tự được lưu bằng một transaction và áp dụng cho cả storefront.
- Seed chỉ thêm hàng thiếu. Chạy lại không ghi đè vị trí, metadata hoặc trạng thái
  admin đã chỉnh. Việc công bố các SKU cũ dùng script riêng trong seed runbook.

Kiểm chứng 2026-10-27: 178 common/catalog Java tests trên Docker JDK25, gồm seed
vào PostgreSQL tạm; 196 frontend tests (kéo thả cùng cấp, từ chối khác cấp,
chọn master type); 913 AI tests và 38 infra tests pass. Typecheck/lint/OpenAPI,
Ruff/mypy/lock pass. Chưa verify UI bằng browser hoặc deploy bộ seed mới lên server.
AI candidate limit còn được theo dõi tại ISSUE-156; đây không phải tuyên bố build
consultation đã chạy được với toàn bộ catalog production.
