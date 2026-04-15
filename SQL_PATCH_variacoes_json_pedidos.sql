ALTER TABLE products
  ADD COLUMN IF NOT EXISTS variation_attributes_json LONGTEXT NULL AFTER description;

ALTER TABLE order_items
  ADD COLUMN IF NOT EXISTS variation_snapshot_json LONGTEXT NULL AFTER variation_label;
