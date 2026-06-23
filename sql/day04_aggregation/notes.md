# Day 4 — SQL: Aggregation

> **Roadmap Day:** 4 · **Date:** Thursday, June 18, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Interview Level:** Easy → Medium

---

## 1. Why Aggregations Matter for Data Engineers

Every analytics query involves aggregation:
- Revenue dashboards: `SUM` by region or period
- Inventory alerts: `COUNT` or `SUM` with `HAVING`
- Price range reports: `MIN`, `MAX`, `AVG` per category
- KPI pipelines: group + aggregate + filter

Mastering `GROUP BY` + `HAVING` + all five aggregate functions is non-negotiable for DE interviews.

---

## 2. The Five Aggregate Functions

```sql
SELECT
    COUNT(*)                          AS row_count,       -- total rows in group
    COUNT(col)                        AS non_null_count,  -- rows where col IS NOT NULL
    SUM(col)                          AS total,
    AVG(col)                          AS average,
    MIN(col)                          AS minimum,
    MAX(col)                          AS maximum
FROM sales
GROUP BY region;
```

| Function | What it returns | Ignores NULLs? |
|----------|----------------|----------------|
| `COUNT(*)` | Total rows | No |
| `COUNT(col)` | Non-NULL values | Yes |
| `SUM(col)` | Sum of non-NULL values | Yes |
| `AVG(col)` | Mean of non-NULL values | Yes |
| `MIN(col)` | Smallest non-NULL value | Yes |
| `MAX(col)` | Largest non-NULL value | Yes |

---

## 3. GROUP BY

```sql
-- One row per group
SELECT  region,
        SUM(quantity * unit_price)   AS total_revenue
FROM    sales
GROUP   BY region
ORDER   BY total_revenue DESC;
```

**Rules:**
- Every column in `SELECT` must be either in `GROUP BY` or wrapped in an aggregate function
- `GROUP BY` can reference multiple columns: `GROUP BY region, product_id`

---

## 4. WHERE vs HAVING

| Clause | Runs | Can use aggregates? |
|--------|------|---------------------|
| `WHERE` | Before `GROUP BY` | No |
| `HAVING` | After `GROUP BY` | Yes |

```sql
-- WRONG: WHERE cannot reference aggregate
SELECT product_id, SUM(quantity) AS total
FROM   sales
WHERE  SUM(quantity) > 50   -- ERROR
GROUP  BY product_id;

-- CORRECT: HAVING filters after aggregation
SELECT product_id, SUM(quantity) AS total
FROM   sales
GROUP  BY product_id
HAVING SUM(quantity) > 50
ORDER  BY total DESC;
```

**Memory aid:** `WHERE` filters **rows** (individual records), `HAVING` filters **groups** (aggregated results).

---

## 5. Computed Column in Aggregation

```sql
-- Revenue = quantity × unit_price, summed per region
SELECT  region,
        ROUND(SUM(quantity * unit_price)::NUMERIC, 2)  AS total_revenue
FROM    sales
GROUP   BY region;
```

You can use **expressions** inside aggregate functions — the expression is evaluated per row before aggregation.

---

## 6. ROUND for Cleaner Output

```sql
-- PostgreSQL: cast to NUMERIC before ROUND for exact decimal arithmetic
ROUND(AVG(unit_price)::NUMERIC, 2)
ROUND(SUM(quantity * unit_price)::NUMERIC, 2)
```

`::NUMERIC` casts the result from `double precision` to `NUMERIC`, which `ROUND` works cleanly with.

---

## 7. Multiple Aggregates in One Query

```sql
SELECT  region,
        MIN(unit_price)                             AS min_price,
        MAX(unit_price)                             AS max_price,
        ROUND(AVG(unit_price)::NUMERIC, 2)          AS avg_price,
        SUM(quantity)                               AS total_qty,
        COUNT(*)                                    AS num_transactions
FROM    sales
GROUP   BY region
ORDER   BY region;
```

All five aggregates run in **one scan** of the table — the database computes all of them simultaneously per group.

---

## 8. Day 4 SQL Problems

### Problem 1 (Easy) — Total revenue per region
```sql
SELECT  region,
        ROUND(SUM(quantity * unit_price)::NUMERIC, 2)  AS total_revenue
FROM    sales
GROUP   BY region
ORDER   BY total_revenue DESC;
```

### Problem 2 (Easy) — Products with >50 units sold
```sql
SELECT  product_id,
        SUM(quantity)  AS total_units_sold
FROM    sales
GROUP   BY product_id
HAVING  SUM(quantity) > 50
ORDER   BY total_units_sold DESC;
```

### Problem 3 (Medium) — Regional price & quantity summary
```sql
SELECT  region,
        MIN(unit_price)                             AS min_price,
        MAX(unit_price)                             AS max_price,
        ROUND(AVG(unit_price)::NUMERIC, 2)          AS avg_price,
        SUM(quantity)                               AS total_qty
FROM    sales
GROUP   BY region
ORDER   BY region;
```

---

## 9. Common Gotchas

| Gotcha | Detail |
|--------|--------|
| `WHERE` with aggregate | `WHERE SUM(...) > N` is a syntax error — use `HAVING` |
| Non-aggregated column in SELECT | Every SELECT column must be in GROUP BY or aggregated |
| `ROUND` and `double precision` | In PostgreSQL, `ROUND(AVG(...), 2)` may error — cast: `ROUND(AVG(...)::NUMERIC, 2)` |
| `COUNT(col)` vs `COUNT(*)` | `COUNT(col)` skips NULLs; `COUNT(*)` counts all rows |
| ORDER BY alias | In most databases you can `ORDER BY total_revenue DESC` using the alias |

---

## 10. Interview Checklist

| Question | Answer |
|----------|--------|
| Difference between WHERE and HAVING? | WHERE filters rows before grouping; HAVING filters groups after aggregation |
| When must you use HAVING? | When the filter condition references an aggregate function |
| Can you put an expression in SUM? | Yes — `SUM(quantity * unit_price)` evaluates per row then sums |
| How to get revenue per group? | `SUM(quantity * unit_price)` with `GROUP BY group_col` |
| How to count non-NULL values? | `COUNT(col)` — skips NULLs. `COUNT(*)` counts everything |

---

## 11. Quick Reference

```sql
-- Basic aggregation
SELECT  group_col, SUM(val), COUNT(*), AVG(val), MIN(val), MAX(val)
FROM    table
GROUP   BY group_col
ORDER   BY SUM(val) DESC;

-- Computed column inside aggregate
SUM(quantity * unit_price)

-- Filter on aggregate (HAVING, not WHERE)
HAVING SUM(quantity) > 50

-- Round for display
ROUND(AVG(unit_price)::NUMERIC, 2)

-- Multiple aggregates in one pass
SELECT region,
       MIN(unit_price)  AS min_p,
       MAX(unit_price)  AS max_p,
       ROUND(AVG(unit_price)::NUMERIC, 2) AS avg_p,
       SUM(quantity)    AS total_qty
FROM   sales
GROUP  BY region;
```
