-- Partial unique index: one default address per customer.
-- Non-default addresses remain unlimited.
CREATE UNIQUE INDEX ux_customer_default_address
ON customer_addresses (customer_id)
WHERE is_default = true;

-- One active main image per product variant.
CREATE UNIQUE INDEX ux_variant_main_image
ON product_images (product_variant_id)
WHERE is_main = true AND status = 'ACTIVE';

-- Scope-target is cross-table and cannot be represented by a simple CHECK.
-- Enforce atomically in the discount service transaction, or add a PostgreSQL
-- constraint trigger covering discounts, discount_categories, and discount_variants:
-- ORDER/ALL_ITEMS: zero targets
-- CATEGORY: at least one category target and zero variant targets
-- VARIANT: at least one variant target and zero category targets
