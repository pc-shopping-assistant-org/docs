# Deployment

## Boundary

`infra/` là checkout độc lập, không cần source application trên server.
Một compose, hai chế độ:

```text
Dev:    local applications ── SSH/private network ── server infra
Deploy: server application images ── Docker network ── server infra
```

Infra gồm PostgreSQL, Redis, RabbitMQ, Kafka/Debezium Connect, Elasticsearch và LGTM.
Mặc định chỉ chạy infra; profile `apps` thêm Eureka, Gateway, 8 business services,
AI/migration và Next.js. Sync là application worker, không phải infrastructure.

Runbook canonical: [infra README](../../infra/README.md).
Entrypoint duy nhất là `infra/compose.yaml`, chạy qua `infra/compose.sh`.

Bootstrap đầy đủ: `infra/scripts/deploy.sh`. Script pull image, gọi catalog job
`seed-prod` (Flyway + UPSERT taxonomy), rồi bật apps. Seed riêng bằng
`infra/scripts/seed-prod.sh`. AI đọc hardware type từ catalog, không ghi UUID vào env.

## Configuration

- Global runtime config: ignored `infra/.env.docker`, mẫu `.env.docker.example`.
- `compose.sh` nạp global env, rồi image-tag overrides trong `.release.env`.
- Không COPY env hoặc truyền deployment config/secrets qua Docker build args.
- FE nhận Google client ID từ allowlisted runtime endpoint `/api/config`, không
  dùng `NEXT_PUBLIC_*` baked values. Backend/AI endpoints chỉ nằm ở BFF server.
- Local app dùng env mẫu riêng trong `infra/env/`; không dùng Docker DNS từ host.
- Caddy global terminate TLS cho HTTP. Native dependencies mặc định loopback qua
  SSH, có auth; không public plaintext native ports hoặc management APIs.

## Release

CI test trên push/PR/merge queue. Nhánh **release/vX.Y.Z** ở backend/AI/FE chỉ
build/publish GHCR: backend 10 image riêng, AI/FE mỗi repo một image.
`release/v1.0.0` publish tag `1.0.0` + `sha-<full commit>`; cũng hỗ trợ `-rc.N`.
Chỉ **infra release/vX.Y.Z** SSH
deploy cả hệ thống, sau khi các app builds thành công. Không tự deploy từ app repo.

Chỉ repo infra cần GitHub Environment `release`: `SSH_HOST`, `SSH_USER`, `SSH_PORT`, `DEPLOY_PATH`
variables và `SSH_PRIVATE_KEY`, `SSH_KNOWN_HOSTS` secrets. Deployment branch rule
phải cho phép `release/*`. Chúng không đi vào image.
Server giữ app env và credential đọc GHCR nếu package private; public không cần
login. Không dùng token publish để chạy app.

Infra `release/v1.0.0` mặc định chọn chính xác `:1.0.0` cho BE/AI/FE, không lấy
override cũ, latest hoặc mutable release. Dispatch hỗ trợ chọn version/sha-* riêng
cho từng app. Đợi app builds thành công trước khi chạy infra release.
Version đã phát hành không sửa lại branch; GHCR chưa tự khóa ghi đè (ISSUE-143).
Lock server bảo vệ deploy config/apps; dependencies → seed → backend → stop AI →
migrate → AI/FE. Chỉ ghi `.release.env` khi health pass. Health/migration lỗi làm
CD fail, không tự rollback schema/container. Bootstrap connector sau khi catalog
migrations thành công. Không sửa env server, xóa volumes hoặc quản lý Caddy global.
Trước khi đổi service: kiểm tra đủ 12 app manifests và pull. Sau khi tất cả healthy:
xóa local image cũ của app vừa thay thế, không force/prune; không xóa image GHCR.
Cleanup lỗi chỉ cảnh báo. Rollback phải pull lại image cũ và xét tương thích schema.

## Limits and acceptance

Named volumes ổn định; backup/migrate dữ liệu có chủ đích, không `down -v`.
Đổi env không tự rotate password trong volume cũ. Single-node baseline chưa phải
HA, least-privilege production accounts hoặc disaster-recovery đầy đủ.

Offline config tests và workflow lint không chứng minh Actions/server runtime.
Cần owner cấu hình env, SSH, GitHub Environment, package access, domain và chạy
nghiệm thu thật. Retry/DLT của sync được theo dõi riêng ở ISSUE-141.
