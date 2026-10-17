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

Runbook canonical: [infra README](../../infra/README.md). Cấu hình monolith cũ
ở `infra/compose/` không phải entrypoint cho microservices hiện tại.

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

CI test trên push/PR/merge queue. Chỉ push/manual dispatch nhánh **release** mới
build/publish GHCR và deploy qua SSH. Backend publish 10 image riêng; AI/FE mỗi
repo một image. Release pin `sha-<full commit>`, không deploy mutable latest.

GitHub Environment `release` giữ `SSH_HOST`, `SSH_USER`, `SSH_PORT`, `DEPLOY_PATH`
variables và `SSH_PRIVATE_KEY`, `SSH_KNOWN_HOSTS` secrets. Chúng không đi vào image.
Server giữ credentials đọc GHCR và app env; không dùng token publish để chạy app.

Mỗi repo chỉ cập nhật nhóm của nó; infra release không restart applications.
Lock server ngăn các repo cùng sửa deployment state. AI dừng executor rồi migrate
trước khi restart; Java chạy Flyway. Health/migration lỗi làm CD fail, không tự
rollback schema. Bootstrap connector sau khi catalog migrations thành công.

## Limits and acceptance

Named volumes ổn định; backup/migrate dữ liệu có chủ đích, không `down -v`.
Đổi env không tự rotate password trong volume cũ. Single-node baseline chưa phải
HA, least-privilege production accounts hoặc disaster-recovery đầy đủ.

Offline config tests và workflow lint không chứng minh Actions/server runtime.
Cần owner cấu hình env, SSH, GitHub Environment, package access, domain và chạy
nghiệm thu thật. Retry/DLT của sync được theo dõi riêng ở ISSUE-141.
