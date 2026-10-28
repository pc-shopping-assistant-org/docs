-- Reference only. The source of truth for every constraint is the Flyway
-- migrations of each service (src/main/resources/db/migration). This file lists
-- the constraints that are easy to miss because they are partial indexes or
-- triggers rather than column definitions.

-- identity-service: one default address per customer.
CREATE UNIQUE INDEX uk_customer_addresses_default
ON customer_addresses (customer_id)
WHERE is_default = true;

-- identity-service: a Google subject links to at most one account.
CREATE UNIQUE INDEX uk_accounts_google_subject
ON accounts (google_subject)
WHERE google_subject IS NOT NULL;

-- catalog-service: names, SEO names, SKUs and barcodes are unique only among
-- non-deleted rows, so a soft-deleted row never blocks reuse.
CREATE UNIQUE INDEX uk_brands_name        ON brands (name)            WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_brands_seo_name    ON brands (seo_name)        WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_categories_name    ON categories (name)        WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_categories_seo_name ON categories (seo_name)   WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_products_seo_name  ON products (seo_name)      WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_product_variants_sku     ON product_variants (sku)     WHERE status <> 'DELETED';
CREATE UNIQUE INDEX uk_product_variants_barcode ON product_variants (barcode) WHERE status <> 'DELETED';

-- catalog-service: hardware type is master data (hardware_types.code is unique).
-- Every category references one, the generic category using the explicit OTHER row.
-- Category navigation order is explicit: display_order >= 0, and the storefront
-- sorts by display_order ASC, then name ASC.
-- categories.hardware_type_id is NOT NULL; ck_categories_display_order CHECK (display_order >= 0)
CREATE INDEX idx_categories_parent_display_order ON categories (parent_id, display_order, name);

-- catalog-service: at most one main image per product.
CREATE UNIQUE INDEX uk_product_images_main
ON product_images (product_id)
WHERE is_main = true;

-- catalog-service: a variant has at most one option per normalized option name
-- (trim + uppercase). Enforced by deferred constraint triggers:
--   trg_variant_options_unique_type          AFTER INSERT OR UPDATE ON variant_options
--   trg_options_type_unique_after_change     AFTER UPDATE OF name ON options
-- (functions check_variant_option_type_uniqueness / check_option_rename_uniqueness,
--  see V6__product_schema_update.sql)

-- promotion-service: discount codes are unique case-insensitively among
-- non-deleted discounts.
CREATE UNIQUE INDEX discounts_normalized_code
ON discounts (upper(code))
WHERE code IS NOT NULL AND status <> 'DELETED';

-- promotion-service: scope-target is a cross-table invariant. Deferred
-- constraint triggers (enforce_discount_scope_targets, see V3) check, at commit,
-- that ORDER / ALL_ITEMS discounts have no category target and CATEGORY
-- discounts have at least one:
--   trg_discount_scope_targets     AFTER INSERT OR UPDATE ON discounts
--   trg_discount_category_targets  AFTER INSERT OR UPDATE OR DELETE ON discount_categories

-- order-service: invoice numbers and idempotency keys are unique.
CREATE UNIQUE INDEX ux_orders_invoice_number ON orders (invoice_number);
-- orders.idempotency_key is unique where not null (see V3__add_order_idempotency.sql)

-- payment-service: failed attempts are retained, but an order can have only one
-- paid attempt.
CREATE UNIQUE INDEX uk_payments_order_paid
ON payments (order_id)
WHERE status = 'PAID';
