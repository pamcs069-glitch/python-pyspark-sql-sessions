# Day 4 — PySpark: DataFrame Aggregations

> **Roadmap Day:** 4 · **Date:** Thursday, June 18, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Interview Level:** Easy → Medium

---

## 1. PySpark vs SQL Aggregation — Quick Mapping

| SQL | PySpark | Notes |
|-----|---------|-------|
| `SUM(col)` | `F.sum('col')` | |
| `COUNT(*)` | `F.count('*')` | |
| `AVG(col)` | `F.avg('col')` | |
| `MIN(col)` | `F.min('col')` | |
| `MAX(col)` | `F.max('col')` | |
| `ROUND(expr, 2)` | `F.round(expr, 2)` | |
| `GROUP BY col` | `.groupBy('col')` | |
| `HAVING agg > N` | `.groupBy().agg().filter(...)` | filter AFTER agg |
| Expression in SUM | `F.sum(F.col('qty') * F.col('price'))` | |

---

## 2. Imports

```python
from pyspark.sql import functions as F

# Or import individually
from pyspark.sql.functions import (
    col,
    sum as spark_sum,     # alias to avoid shadowing Python's built-in sum()
    count,
    avg,
    min as spark_min,     # alias to avoid shadowing Python's built-in min()
    max as spark_max,     # alias to avoid shadowing Python's built-in max()
    round as spark_round, # alias to avoid shadowing Python's built-in round()
)
```

**Best practice:** use `from pyspark.sql import functions as F` and call `F.sum()`, `F.min()` etc. — avoids shadowing Python built-ins.

---

## 3. Basic groupBy + agg

```python
from pyspark.sql import functions as F

df_revenue = (
    df_sales
    .groupBy('region')
    .agg(
        F.sum('quantity').alias('total_qty'),
        F.count('*').alias('num_transactions'),
    )
    .orderBy('total_qty', ascending=False)
)

df_revenue.show()
```

**Pattern:** `.groupBy(col).agg(func1, func2, ...).orderBy(...)`

---

## 4. Computed Column Inside Aggregation

```python
# Option A: create the column first, then aggregate
df_revenue = (
    df_sales
    .withColumn('revenue', F.col('quantity') * F.col('unit_price'))
    .groupBy('region')
    .agg(F.round(F.sum('revenue'), 2).alias('total_revenue'))
)

# Option B: inline expression inside agg (same result)
df_revenue = (
    df_sales
    .groupBy('region')
    .agg(
        F.round(F.sum(F.col('quantity') * F.col('unit_price')), 2).alias('total_revenue')
    )
)
```

Option A is easier to read — create the computed column first.

---

## 5. HAVING Equivalent — filter After agg

PySpark has no `HAVING` keyword. Instead: **group → aggregate → filter**.

```python
# SQL:   HAVING SUM(quantity) > 50
# PySpark:
df_top = (
    df_sales
    .groupBy('product_id')
    .agg(F.sum('quantity').alias('total_qty'))
    .filter(F.col('total_qty') > 50)          # ← this IS the HAVING
    .orderBy('total_qty', ascending=False)
)
```

**Rule:** `.filter()` applied to the result of `.agg()` is exactly SQL's `HAVING`.

---

## 6. Multiple Aggregates in One agg() Call

```python
df_summary = (
    df_sales
    .groupBy('region')
    .agg(
        F.min('unit_price').alias('min_price'),
        F.max('unit_price').alias('max_price'),
        F.round(F.avg('unit_price'), 2).alias('avg_price'),
        F.sum('quantity').alias('total_qty'),
        F.count('*').alias('num_transactions'),
    )
    .orderBy('region')
)

df_summary.show()
```

All aggregates run in a **single shuffle pass** — the same efficiency as a SQL query with multiple aggregate functions.

---

## 7. Day 4 PySpark Problems

### Problem 1 (Easy) — Total revenue per region
```python
df_revenue = (
    df_sales
    .withColumn('revenue', F.col('quantity') * F.col('unit_price'))
    .groupBy('region')
    .agg(F.round(F.sum('revenue'), 2).alias('total_revenue'))
    .orderBy('total_revenue', ascending=False)
)
df_revenue.show()
```

### Problem 2 (Easy) — Products with >50 units sold
```python
df_top = (
    df_sales
    .groupBy('product_id')
    .agg(F.sum('quantity').alias('total_units_sold'))
    .filter(F.col('total_units_sold') > 50)
    .orderBy('total_units_sold', ascending=False)
)
df_top.show()
```

### Problem 3 (Medium) — Regional price & quantity summary
```python
df_summary = (
    df_sales
    .groupBy('region')
    .agg(
        F.min('unit_price').alias('min_price'),
        F.max('unit_price').alias('max_price'),
        F.round(F.avg('unit_price'), 2).alias('avg_price'),
        F.sum('quantity').alias('total_qty'),
    )
    .orderBy('region')
)
df_summary.show()
```

---

## 8. Common Gotchas

| Gotcha | Detail |
|--------|--------|
| Name collision with Python built-ins | `F.sum()`, `F.min()`, `F.max()`, `F.round()` — use the `F.` prefix |
| `HAVING` in PySpark | No `HAVING` keyword — use `.filter()` after `.agg()` |
| `F.count('*')` vs `F.count('col')` | `F.count('*')` counts all rows; `F.count('col')` skips NULLs |
| Inline expression in agg | `F.sum(F.col('qty') * F.col('price'))` works but less readable than `withColumn` first |
| Sort direction | `.orderBy('col', ascending=False)` for descending |

---

## 9. Interview Checklist

| Question | Answer |
|----------|--------|
| PySpark equivalent of SQL HAVING? | `.groupBy().agg(...).filter(F.col('agg_col') > N)` |
| How to aggregate a computed column? | `withColumn('revenue', F.col('qty')*F.col('price'))` then `F.sum('revenue')` |
| Difference between F.count('*') and F.count('col')? | `F.count('*')` counts all rows; `F.count('col')` skips NULLs |
| Why use `F.` prefix for aggregates? | Avoids shadowing Python's built-in `sum()`, `min()`, `max()`, `round()` |
| Are multiple agg() functions in one pass? | Yes — one shuffle, all aggregates computed simultaneously |

---

## 10. Quick Reference

```python
from pyspark.sql import functions as F

# Basic
df.groupBy('col').agg(F.sum('val').alias('total'))

# Multiple aggregates in one call
df.groupBy('col').agg(
    F.count('*').alias('n'),
    F.sum('val').alias('total'),
    F.avg('val').alias('avg'),
    F.min('val').alias('min'),
    F.max('val').alias('max'),
)

# Computed column first, then aggregate
df.withColumn('rev', F.col('qty') * F.col('price')) \
  .groupBy('region').agg(F.sum('rev').alias('total_rev'))

# Inline expression
F.sum(F.col('qty') * F.col('price'))

# Filter after agg (≡ SQL HAVING)
.groupBy(...).agg(...).filter(F.col('total') > N)

# Sort
.orderBy('col', ascending=False)

# Round
F.round(F.avg('price'), 2)
```
