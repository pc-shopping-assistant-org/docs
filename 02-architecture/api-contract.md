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

The canonical payment-method catalog is `COD`, `STRIPE_CARD` and
`BANK_TRANSFER`. Order and Stripe intent requests accept only these catalog
codes; unsupported or legacy provider names are rejected during request
validation.

For Stripe webhooks, a configured webhook secret makes `Stripe-Signature`
mandatory. Unsigned JSON is accepted only for the local mock flow when no
secret is configured.

The backend publishes the OpenAPI document at `/v3/api-docs` and the interactive
Swagger UI at `/swagger-ui.html`. Both documentation routes are public; actual
API authorization remains enforced by the backend security configuration.

`POST /api/v1/auth/logout` is the exception to the otherwise public auth route
group: it requires the current Bearer access token. The optional body
`{"refreshToken":"..."}` lets the backend blacklist the complete token pair;
clients should send it when available. Tokens are retained in Redis only for
their remaining lifetime. The backend fails closed for logout, refresh and
access-token authentication when Redis cannot read/write revocation state; durable
revocation across Redis data loss and the optional refresh-token compatibility
path remain tracked in `ISSUE-038`.
