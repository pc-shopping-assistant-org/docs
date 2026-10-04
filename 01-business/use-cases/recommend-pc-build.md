# Source Gap — Recommend PC Build

Report gốc **không có use case build cấu hình PC hoàn chỉnh** và không định nghĩa:

- compatibility CPU ↔ mainboard/socket;
- RAM ↔ mainboard;
- PSU sizing;
- budget allocation giữa linh kiện;
- constraint solver/CP-SAT;
- top-K cấu hình hoặc ranking build.

Vì vậy file này được giữ như một **placeholder ngoài phạm vi nguồn**, không được coi là nghiệp vụ đã được report phê duyệt.

Use case gần nhất có nguồn là:

- `consult-products.md`
- `semantic-product-search.md`
- `compare-products.md`

## User-approved frontend prototype (2026-10-04)

This extension is explicitly requested by the project owner, not part of the
original report or the 68 official use cases. `/vi/build-pc` and `/en/build-pc`
use isolated synthetic SKU data in the frontend, never live cart mutations.

| Feature | Scope | Verification |
| --- | --- | --- |
| Component selection | PC component group plus optional display/mouse/keyboard/headset; replace/remove, search, brand, price sort | Interaction tests |
| Add-on discovery | Optional peripheral suggestion cards, browse alternatives, separate subtotals | Service/interaction tests |
| Quote | Server prices from fixture SKU; no client price trust | Service/API tests |
| Compatibility | Socket, DDR, board form factor, GPU length, cooler socket | Positive/negative/unknown checks |
| Templates and budget | Demo starting selections, reference-budget comparison | No automatic recommendation/ranking |
| Save/share | Local browser save and validated URL selection | No login or server persistence |
| Responsive layout | Core/accessories tabs, wide catalog + compact selected-item summary; mobile bottom summary shortcut | Interaction tests; browser acceptance pending |

All compatibility badges describe checked specifications only. Missing data,
PSU capacity/connectors, SSD slots and cooler clearance remain `UNKNOWN`.
BIOS, RAM QVL, lane sharing and other hardware requirements are not certified.
Fixtures follow product → variant/SKU with `listPrice`, quantity and product
specifications; these demo keys are not a canonical DB attribute migration.
Live catalog mapping, compatibility rules, saved builds and real-cart flow
need an approved specification before production integration (`ISSUE-073`).
