-- Patch seguro para cadastro + tema padrão da loja
ALTER TABLE stores
  ADD COLUMN IF NOT EXISTS default_template_code VARCHAR(100) NOT NULL DEFAULT 'orange_default',
  ADD COLUMN IF NOT EXISTS personalization_initialized TINYINT(1) NOT NULL DEFAULT 0;

-- Opcional: garantir índice único de subdomínio, se ainda não existir
ALTER TABLE stores
  ADD UNIQUE KEY uk_stores_subdomain (subdomain);
