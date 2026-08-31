-- Partial unique index: one default address per customer.
-- Non-default addresses remain unlimited.
CREATE UNIQUE INDEX ux_customer_default_address
ON customer_addresses (customer_id)
WHERE is_default = true;

-- One active main image per product variant.
CREATE UNIQUE INDEX ux_variant_main_image
ON product_images (product_variant_id)
WHERE is_main = true AND status = 'ACTIVE';

-- A customer or guest session can own at most one active cart.
CREATE UNIQUE INDEX ux_carts_active_customer
ON carts (customer_id)
WHERE status = 'ACTIVE' AND customer_id IS NOT NULL;

CREATE UNIQUE INDEX ux_carts_active_session
ON carts (session_token)
WHERE status = 'ACTIVE' AND session_token IS NOT NULL;

-- Failed attempts are retained, but an order can have only one paid attempt.
CREATE UNIQUE INDEX ux_payments_one_paid_per_order
ON payments (order_id)
WHERE status = 'PAID';

-- A variant can have at most one non-deleted option of each type.
-- This must also run when an option's type/status changes.
CREATE OR REPLACE FUNCTION enforce_variant_option_type_unique()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM variant_options vo
    JOIN options o ON o.id = vo.option_id
    WHERE vo.status <> 'DELETED'
      AND o.status <> 'DELETED'
    GROUP BY vo.product_variant_id, upper(trim(o.type))
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION
      'A product variant cannot have multiple options of the same type';
  END IF;

  RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER ct_variant_option_type_unique
AFTER INSERT OR UPDATE OR DELETE ON variant_options
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_variant_option_type_unique();

CREATE CONSTRAINT TRIGGER ct_option_type_unique_after_option_change
AFTER UPDATE ON options
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_variant_option_type_unique();

-- Scope-target is a cross-table invariant. Deferred constraint triggers allow
-- the discount and its targets to be written atomically in one transaction.
CREATE OR REPLACE FUNCTION enforce_discount_scope_targets()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  invalid_discount_id uuid;
BEGIN
  SELECT d.id
  INTO invalid_discount_id
  FROM discounts d
  WHERE
    (
      d.application_scope IN ('ORDER', 'ALL_ITEMS')
      AND (
        EXISTS (SELECT 1 FROM discount_categories dc WHERE dc.discount_id = d.id)
        OR EXISTS (SELECT 1 FROM discount_variants dv WHERE dv.discount_id = d.id)
      )
    )
    OR (
      d.application_scope = 'CATEGORY'
      AND (
        NOT EXISTS (SELECT 1 FROM discount_categories dc WHERE dc.discount_id = d.id)
        OR EXISTS (SELECT 1 FROM discount_variants dv WHERE dv.discount_id = d.id)
      )
    )
    OR (
      d.application_scope = 'VARIANT'
      AND (
        EXISTS (SELECT 1 FROM discount_categories dc WHERE dc.discount_id = d.id)
        OR NOT EXISTS (SELECT 1 FROM discount_variants dv WHERE dv.discount_id = d.id)
      )
    )
  LIMIT 1;

  IF invalid_discount_id IS NOT NULL THEN
    RAISE EXCEPTION
      'Discount % has targets inconsistent with application_scope',
      invalid_discount_id;
  END IF;

  RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER ct_discount_scope_targets
AFTER INSERT OR UPDATE ON discounts
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_discount_scope_targets();

CREATE CONSTRAINT TRIGGER ct_discount_category_targets
AFTER INSERT OR UPDATE OR DELETE ON discount_categories
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_discount_scope_targets();

CREATE CONSTRAINT TRIGGER ct_discount_variant_targets
AFTER INSERT OR UPDATE OR DELETE ON discount_variants
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_discount_scope_targets();
