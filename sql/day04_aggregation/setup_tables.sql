-- Day 4 SQL — Aggregation
-- Run this script once to create all required tables.

-- ============================================================
-- 1. Exploration table: sales
-- ============================================================
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    sale_id    VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10),
    region     VARCHAR(20),
    sale_date  DATE,
    quantity   INT,
    unit_price NUMERIC(10,2)
);

INSERT INTO sales VALUES
  ('S001','P001','North','2024-01-05', 10, 29.99),
  ('S002','P002','South','2024-01-07',  5, 49.99),
  ('S003','P001','East', '2024-01-10', 20, 29.99),
  ('S004','P003','West', '2024-01-12', 15, 99.99),
  ('S005','P002','North','2024-01-15',  8, 49.99),
  ('S006','P001','South','2024-02-01', 30, 29.99),
  ('S007','P003','East', '2024-02-03',  2, 99.99),
  ('S008','P004','West', '2024-02-08', 25, 14.99),
  ('S009','P004','North','2024-02-11', 40, 14.99),
  ('S010','P002','East', '2024-02-14', 12, 49.99),
  ('S011','P001','West', '2024-03-01', 18, 29.99),
  ('S012','P003','South','2024-03-05',  7, 99.99),
  ('S013','P004','East', '2024-03-09', 22, 14.99),
  ('S014','P002','West', '2024-03-12',  3, 49.99),
  ('S015','P001','North','2024-03-20', 14, 29.99);

-- ============================================================
-- 2. Practice Question table (pq_ prefix)
-- ============================================================
DROP TABLE IF EXISTS pq_sales;
CREATE TABLE pq_sales AS SELECT * FROM sales;

-- ============================================================
-- Verify
-- ============================================================
SELECT 'sales'    AS tbl, COUNT(*) AS rows FROM sales
UNION ALL
SELECT 'pq_sales' AS tbl, COUNT(*) AS rows FROM pq_sales;
