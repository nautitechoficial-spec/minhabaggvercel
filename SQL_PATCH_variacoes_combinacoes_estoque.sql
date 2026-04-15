ALTER TABLE product_variations
  ADD COLUMN variation_key VARCHAR(255) NULL AFTER image_url;

CREATE INDEX idx_product_variations_product_variation_key
  ON product_variations (product_id, variation_key(191));
