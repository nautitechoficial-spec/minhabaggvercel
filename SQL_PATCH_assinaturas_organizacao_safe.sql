-- Patch seguro de organização para lógica de assinaturas/renovação/upgrade
-- Compatível com MariaDB/MySQL (usa IF NOT EXISTS onde disponível)
-- Não remove nada existente. Apenas adiciona colunas/índices/tabelas opcionais.

START TRANSACTION;

-- 1) Metadados opcionais em orders para distinguir renovação x upgrade (não quebra dependências atuais)
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS subscription_id INT NULL AFTER tipo,
  ADD COLUMN IF NOT EXISTS subscription_kind VARCHAR(20) NULL AFTER subscription_id;

-- 2) Índices úteis (performance e consistência de consultas)
ALTER TABLE orders
  ADD INDEX IF NOT EXISTS idx_orders_store_tipo_status (store_id, tipo, status),
  ADD INDEX IF NOT EXISTS idx_orders_asaas_payment_id (asaas_payment_id),
  ADD INDEX IF NOT EXISTS idx_orders_payment_external_id (payment_external_id);

ALTER TABLE store_subscriptions
  ADD INDEX IF NOT EXISTS idx_store_subscriptions_store_status (store_id, status),
  ADD INDEX IF NOT EXISTS idx_store_subscriptions_ends_at (ends_at);

ALTER TABLE subscription_changes
  ADD INDEX IF NOT EXISTS idx_subscription_changes_store_status_effective (store_id, status, effective_at),
  ADD INDEX IF NOT EXISTS idx_subscription_changes_order_id (order_id);

-- 3) Tabela opcional de vínculo explícito entre assinatura e faturas (renovação/upgrade/downgrade)
CREATE TABLE IF NOT EXISTS subscription_invoices (
  id INT NOT NULL AUTO_INCREMENT,
  store_id INT NOT NULL,
  subscription_id INT NULL,
  order_id INT NOT NULL,
  invoice_type ENUM('renewal','upgrade','downgrade') NOT NULL DEFAULT 'renewal',
  cycle_start DATETIME NULL,
  cycle_end DATETIME NULL,
  due_at DATETIME NULL,
  status ENUM('pending','paid','canceled','expired') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_subscription_invoices_order (order_id),
  KEY idx_subscription_invoices_store_status (store_id, status),
  KEY idx_subscription_invoices_sub_status (subscription_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
