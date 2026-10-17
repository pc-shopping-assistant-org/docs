# Production reference data

Catalog seed chỉ tạo taxonomy: CPU, MAINBOARD, RAM, GPU, PSU, CASE, COOLER,
STORAGE, MONITOR, MOUSE, KEYBOARD, HEADSET. Không seed sản phẩm, giá hay tồn kho mẫu.

Từ `infra/`, chạy `./scripts/seed-prod.sh`; `./scripts/deploy.sh` tự gọi bước này.
Image catalog nhận `--seed-prod`, chạy Flyway rồi UPSERT reference data và thoát.
Seed chạy lại giữ UUID, trạng thái, tên, mô tả và hierarchy hiện có; category đã
soft-delete không được tự khôi phục. Tên hiện có được đối chiếu trước khi insert
để giữ slug/ID cũ. `hardware_type` là metadata chuẩn, được cập nhật từ seed.

AI đọc `hardwareType` trực tiếp từ snapshot API; không cấu hình category UUID trong env.
