# Media storage

`POST /media-service/files` nhận multipart field `file`, yêu cầu đăng nhập với role
ADMIN, EMPLOYEE hoặc CUSTOMER. Response vẫn là `{data, message, errors}`; `data` gồm
`id`, `originalName`, `mimeType`, `sizeBytes`, `url`, `createdAt`.
`GET /media-service/files/{id}` và `GET /media-service/files?ids=...` đọc public metadata ACTIVE.

```text
multipart image → MediaFileService → MediaStorage adapter → object storage
                                      ↓
                             media_db.files → response
```

`MEDIA_STORAGE_PROVIDER=S3` chọn adapter mới. `CLOUDINARY` chọn adapter cũ với
`CLOUDINARY_*` hiện có. Upload hoàn tất trước khi mở transaction lưu metadata;
lưu/commit DB lỗi thì xóa object vừa tạo. Cleanup lỗi được ghi log và giữ nguyên
nguyên nhân DB. Service không thực hiện distributed transaction với object store.

S3 client đọc `S3_ENDPOINT`, `S3_REGION`, `S3_BUCKET`, `S3_PUBLIC_BASE_URL`,
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` từ runtime env. Docker endpoint là
`http://seaweedfs:8333`; public base là origin browser truy cập, không kèm bucket.
Bucket/key được tạo trước qua Admin UI; service không tự tạo bucket/key/policy.

Ảnh mới lưu provider `S3`, key `images/<UUID>`, URL `<public-base>/<bucket>/<key>`.
Schema `media_db.files` không đổi. Bản ghi Cloudinary/EXTERNAL cũ trả nguyên URL
đã lưu, không gọi adapter hoặc upload lại. Việc chọn S3 chỉ đổi luồng upload mới.
`INVALID_FILE` giữ nguyên; S3 dùng error key `STORAGE_UPLOAD_FAILED`, adapter
Cloudinary giữ `CLOUDINARY_UPLOAD_FAILED`. Message envelope vẫn là static key.

[Infra config/Caddy](../../infra/README.md) · [Production seed](../03-data/sample-data.md)
