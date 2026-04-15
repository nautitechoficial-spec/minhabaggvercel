-- PATCH: marketplace_integrations missing columns used by API/UI
-- Execute this in your MySQL (phpMyAdmin) on the same database used by the panel.

ALTER TABLE marketplace_integrations
  ADD COLUMN last_synced_at DATETIME NULL AFTER updated_at,
  ADD COLUMN last_checked_at DATETIME NULL AFTER last_synced_at,
  ADD COLUMN sync_status VARCHAR(30) NULL AFTER last_checked_at;

-- Optional defaults for existing rows
UPDATE marketplace_integrations
SET sync_status = COALESCE(sync_status, 'idle');
