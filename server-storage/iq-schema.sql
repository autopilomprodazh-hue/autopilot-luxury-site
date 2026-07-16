PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS iq_accounts (
  id TEXT PRIMARY KEY,
  external_user_id TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS iq_events (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES iq_accounts(id),
  event_key TEXT NOT NULL,
  points INTEGER NOT NULL CHECK (points <> 0),
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (account_id, event_key)
);

CREATE TABLE IF NOT EXISTS iq_redemptions (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES iq_accounts(id),
  reward_code TEXT NOT NULL,
  points_spent INTEGER NOT NULL CHECK (points_spent > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'fulfilled')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW IF NOT EXISTS iq_balances AS
SELECT a.id AS account_id,
       COALESCE(SUM(e.points), 0) - COALESCE((
         SELECT SUM(r.points_spent)
         FROM iq_redemptions r
         WHERE r.account_id = a.id AND r.status IN ('approved', 'fulfilled')
       ), 0) AS balance
FROM iq_accounts a
LEFT JOIN iq_events e ON e.account_id = a.id
GROUP BY a.id;
