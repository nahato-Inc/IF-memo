-- ============================================================
-- ANSEMプロジェクト データベース設計書 v5.4.0
-- ファイル: 005_create_partitions.sql
-- 説明: パーティション作成文（年次・月次パーティション）
-- 生成日: 2026-02-10
--
-- 実行順序: 001 → 002 → 003 → 004 → 005
-- ============================================================

BEGIN;

-- ============================================================
-- t_audit_logs 月次パーティション（直近3年分 = 36パーティション）
-- ============================================================
CREATE TABLE t_audit_logs_2024_01 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE t_audit_logs_2024_02 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
CREATE TABLE t_audit_logs_2024_03 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
CREATE TABLE t_audit_logs_2024_04 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
CREATE TABLE t_audit_logs_2024_05 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE t_audit_logs_2024_06 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
CREATE TABLE t_audit_logs_2024_07 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
CREATE TABLE t_audit_logs_2024_08 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
CREATE TABLE t_audit_logs_2024_09 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
CREATE TABLE t_audit_logs_2024_10 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
CREATE TABLE t_audit_logs_2024_11 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
CREATE TABLE t_audit_logs_2024_12 PARTITION OF t_audit_logs FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

CREATE TABLE t_audit_logs_2025_01 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE t_audit_logs_2025_02 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE t_audit_logs_2025_03 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE t_audit_logs_2025_04 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE t_audit_logs_2025_05 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE t_audit_logs_2025_06 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE t_audit_logs_2025_07 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE t_audit_logs_2025_08 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE t_audit_logs_2025_09 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE t_audit_logs_2025_10 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE t_audit_logs_2025_11 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE t_audit_logs_2025_12 PARTITION OF t_audit_logs FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

CREATE TABLE t_audit_logs_2026_01 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE t_audit_logs_2026_02 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE t_audit_logs_2026_03 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE t_audit_logs_2026_04 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE t_audit_logs_2026_05 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE t_audit_logs_2026_06 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE t_audit_logs_2026_07 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');
CREATE TABLE t_audit_logs_2026_08 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');
CREATE TABLE t_audit_logs_2026_09 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
CREATE TABLE t_audit_logs_2026_10 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE t_audit_logs_2026_11 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE t_audit_logs_2026_12 PARTITION OF t_audit_logs FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

-- ------------------------------------------------------------
-- t_daily_performance_details パーティション（直近3年分）
-- ------------------------------------------------------------
CREATE TABLE t_daily_perf_2024 PARTITION OF t_daily_performance_details
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE t_daily_perf_2025 PARTITION OF t_daily_performance_details
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE t_daily_perf_2026 PARTITION OF t_daily_performance_details
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- ------------------------------------------------------------
-- t_daily_click_details パーティション（直近3年分）
-- ------------------------------------------------------------
CREATE TABLE t_daily_click_2024 PARTITION OF t_daily_click_details
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE t_daily_click_2025 PARTITION OF t_daily_click_details
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE t_daily_click_2026 PARTITION OF t_daily_click_details
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

COMMIT;
