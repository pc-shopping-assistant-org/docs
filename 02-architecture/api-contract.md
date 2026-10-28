# API Response Contract

All backend and AI HTTP endpoints use the same top-level envelope:

```json
{
  "data": {},
  "message": "SUCCESS",
  "errors": []
}
```

## Fields

- `data`: the endpoint payload; `null` when an operation fails.
- `message`: a static machine-readable key. The frontend maps this key to a
  localized message or a UI action. It must never contain request-specific
  text.
- `errors`: always an array. Validation and business details belong here; each
  item may include `field` and a human-readable `message`.

HTTP status remains the transport-level status. The JSON envelope does not add
`success` or `code` fields.

## Example: validation error

```json
{
  "data": null,
  "message": "VALIDATION_ERROR",
  "errors": [
    {
      "field": "email",
      "message": "Email is invalid"
    }
  ]
}
```

Backend callers should build responses through `ApiResponse.success(...)` or
`ApiResponse.error(...)`. The backend envelope stores the serialized
`StatusCode.name()` as a `String`, so arbitrary/dynamic text is never placed in
the top-level field. AI callers should use the equivalent Pydantic `ApiResponse`
model, whose `message` is the `ResponseMessage` enum. Do not return a raw string
or put dynamic exception text in the top-level `message` field.

The AI service type-checks this field against its `ResponseMessage` enum (for
example `AI_SEARCH_COMPLETED`, `AI_BACKEND_UNAVAILABLE` and
`VALIDATION_ERROR`), so an arbitrary sentence cannot cross the HTTP boundary as
`message`.

Order detail responses expose `payments` as the complete payment-attempt
history (creation order). There is no singular `payment` compatibility field;
clients must read the attempt history from `payments`.

The payment-method catalog is `COD` and `VNPAY`. The legacy `ONLINE_CARD`
method still exists in the table but is `INACTIVE`, so order requests naming it
or any other unknown code are rejected during validation.

VNPAY results arrive through the public callbacks `GET /payments/vnpay/ipn`
and `GET /payments/vnpay/return`. Both verify the HMAC signature and the paid
amount before touching a payment, and share one handler so receiving both is
harmless. An unsigned or mismatched callback never changes a payment.

Routes are exposed through the gateway either by service prefix (for example
`/identity-service/auth/login`, which the gateway strips before forwarding) or,
for the storefront's public routes, directly (`/auth/**`, `/cart/**`,
`/orders/**`, `/payments/**`, `/product-variants/**`). Actual authorization
(public, `ROLE_CUSTOMER`, `ROLE_EMPLOYEE`, `ROLE_ADMIN`) is enforced by each
service's security configuration; there is no role hierarchy.

`POST /auth/google` accepts `{ "idToken": "..." }` from Google Identity
Services. The backend verifies the token, then links the stable Google `sub` to
the local account with the same verified email or, when there is none, creates a
`ROLE_CUSTOMER` account without password or phone, before issuing the normal JWT
pair. The Google picture is copied to the Media Service in the background. The
user summary carries `hasPassword`; `POST /auth/change-password` accepts no
current password for an account that has no password yet.

`POST /auth/logout` is the exception to the otherwise public auth route group:
it requires the current Bearer access token and takes no body. Logout writes an
account-level `revoked-before:account:<id>` marker to Redis for the configured
refresh-token lifetime. The API gateway rejects every token issued before that
cutoff second for the account, so all other services reject it too. Locking,
deactivating or deleting an account writes the same marker. Redis is deployed
with AOF persistence in the local and server compose stacks. The backend fails
closed for logout, refresh and access-token authentication when Redis cannot
read or write revocation state.

Access tokens are RS256 JWTs signed by the identity service; other services
verify them against its JWKS (`/.well-known/jwks.json`). If production Redis
data is lost and cannot be restored, rotate `JWT_PRIVATE_KEY`, `JWT_PUBLIC_KEY`
and `JWT_KEY_ID` and restart the backend before restoring traffic, which
invalidates every outstanding JWT.
