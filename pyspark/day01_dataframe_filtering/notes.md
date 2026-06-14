# Day 1 — PySpark: DataFrame Filtering (filter, where, isin, between, isNull)

> **Roadmap Day:** 1 · **Date:** Monday, June 15, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Same problems as SQL Day 1 — same dataset, PySpark API**

---

## 1. PySpark vs SQL Mental Model

Every SQL filter clause has a direct PySpark equivalent:

| SQL | PySpark |
|-----|---------|
| `WHERE col = 'x'` | `filter(col('c') == 'x')` or `where("c = 'x'")` |
| `BETWEEN a AND b` | `filter(col('c').between(a, b))` |
| `IN (a, b, c)` | `filter(col('c').isin(a, b, c))` |
| `LIKE 'A%'` | `filter(col('c').startswith('A'))` or `like('A%')` |
| `IS NULL` | `filter(col('c').isNull())` |
| `IS NOT NULL` | `filter(col('c').isNotNull())` |
| `HAVING AVG(...) > x` | `groupBy().agg(avg()).filter()` |

---

## 2. Setup — Creating the DataFrame

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, round as spark_round
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, FloatType, DateType

spark = SparkSession.builder \
    .appName("Day01_Filtering") \
    .master("local[*]") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

data = [
    (1,  "Alice",  "Engineering",  95000.0, "2021-03-15"),
    (2,  "Bob",    "Engineering",  58000.0, "2022-07-01"),
    (3,  "Carol",  "Marketing",    72000.0, "2020-11-20"),
    (4,  "David",  "Engineering", 105000.0, "2019-06-10"),
    (5,  "Eve",    "HR",           48000.0, "2022-01-05"),
    (6,  "Frank",  "Marketing",    67000.0, "2023-04-18"),
    (7,  "Grace",  "Engineering",  88000.0, "2022-09-22"),
    (8,  "Hank",   "HR",           51000.0, "2021-12-01"),
    (9,  "Irene",  "Finance",      93000.0, "2020-03-30"),
    (10, "Arthur", "Engineering",  76000.0, "2022-05-14"),
]

schema = StructType([
    StructField("emp_id",    IntegerType(), True),
    StructField("name",      StringType(),  True),
    StructField("dept",      StringType(),  True),
    StructField("salary",    FloatType(),   True),
    StructField("hire_date", StringType(),  True),
])

df = spark.createDataFrame(data, schema=schema)
df.printSchema()
df.show()
```

---

## 3. filter() and where() — Two Names, Same Thing

`filter()` and `where()` are **aliases** — identical behavior. Use whichever reads more naturally.

### Column expression syntax (recommended)

```python
# Using col()
df.filter(col("dept") == "Engineering").show()

# Using df["column"] — also valid
df.filter(df["dept"] == "Engineering").show()
```

### SQL string syntax — quick and readable

```python
df.filter("dept = 'Engineering'").show()
df.where("salary > 80000").show()
```

> Use column expressions for production code (IDE autocomplete, refactor-safe). Use SQL strings for quick exploration.

---

## 4. between() — Inclusive Range

```python
# Equivalent to SQL: WHERE salary BETWEEN 60000 AND 100000
df.filter(col("salary").between(60000, 100000)).show()
```

For dates, first cast the string column:

```python
from pyspark.sql.functions import to_date

df = df.withColumn("hire_date", to_date(col("hire_date"), "yyyy-MM-dd"))

# Hired in 2022
df.filter(col("hire_date").between("2022-01-01", "2022-12-31")).show()
```

---

## 5. isin() — Match Any Value in a List

```python
# Equivalent to SQL: WHERE dept IN ('Engineering', 'Finance')
df.filter(col("dept").isin("Engineering", "Finance")).show()

# Using a Python list
depts = ["Engineering", "Finance"]
df.filter(col("dept").isin(depts)).show()

# NOT IN — negate with ~
df.filter(~col("dept").isin("HR", "Marketing")).show()
```

---

## 6. String Pattern Matching

```python
# LIKE 'A%' → startswith
df.filter(col("name").startswith("A")).show()

# LIKE '%e' → endswith
df.filter(col("name").endswith("e")).show()

# LIKE '%ar%' → contains
df.filter(col("name").contains("ar")).show()

# Full regex — like() supports SQL % wildcards
df.filter(col("name").like("A%")).show()

# Case-insensitive — use lower()
from pyspark.sql.functions import lower
df.filter(lower(col("name")).startswith("a")).show()
```

---

## 7. isNull() and isNotNull()

```python
# Rows where salary is null
df.filter(col("salary").isNull()).show()

# Rows where salary is NOT null
df.filter(col("salary").isNotNull()).show()
```

---

## 8. Combining Conditions — & | ~

```python
# AND — use & (not Python 'and')
df.filter(
    (col("dept") == "Engineering") &
    (col("salary").between(60000, 100000))
).show()

# OR — use | (not Python 'or')
df.filter(
    (col("name").startswith("A")) |
    (col("hire_date").between("2022-01-01", "2022-12-31"))
).show()

# NOT — use ~ (tilde)
df.filter(~col("dept").isin("HR")).show()
```

> **Critical:** Each condition must be **wrapped in parentheses** when combining with `&` or `|`. Without parens, Python operator precedence causes silent bugs.

```python
# BUG — missing parens — comparison binds lower than &
df.filter(col("dept") == "Engineering" & col("salary") > 80000)

# CORRECT
df.filter((col("dept") == "Engineering") & (col("salary") > 80000))
```

---

## 9. HAVING Equivalent — filter After groupBy

```python
from pyspark.sql.functions import avg, count

# SQL equivalent: GROUP BY dept HAVING AVG(salary) > 70000
df.groupBy("dept") \
  .agg(
      avg("salary").alias("avg_salary"),
      count("*").alias("headcount")
  ) \
  .filter(col("avg_salary") > 70000) \
  .orderBy(col("avg_salary").desc()) \
  .show()
```

---

## 10. Day 1 Problems — PySpark Solutions

### Problem 1 (Easy)
Engineering dept, salary between 60000 and 100000.

```python
df.filter(
    (col("dept") == "Engineering") &
    (col("salary").between(60000, 100000))
).select("emp_id", "name", "dept", "salary") \
 .show()
```

### Problem 2 (Easy)
Departments where average salary > 70000.

```python
df.groupBy("dept") \
  .agg(
      spark_round(avg("salary"), 2).alias("avg_salary"),
      count("*").alias("headcount")
  ) \
  .filter(col("avg_salary") > 70000) \
  .orderBy(col("avg_salary").desc()) \
  .show()
```

### Problem 3 (Medium)
Employees whose name starts with 'A' OR hired in 2022.

```python
from pyspark.sql.functions import year, to_date

df = df.withColumn("hire_date_dt", to_date(col("hire_date"), "yyyy-MM-dd"))

df.filter(
    col("name").startswith("A") |
    (year(col("hire_date_dt")) == 2022)
).select("emp_id", "name", "dept", "salary", "hire_date") \
 .orderBy("hire_date") \
 .show()
```

---

## 11. filter() vs SQL String — When to Use Each

| Approach | When to Use |
|----------|-------------|
| `filter(col("x") == "y")` | Production code — type-safe, refactor-friendly |
| `filter("x = 'y'")` | Quick exploration, prototyping |
| `spark.sql("SELECT ... WHERE ...")` | Complex queries, sharing SQL across teams |

---

## 12. Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `filter(col("a") == "x" & col("b") > 0)` | Operator precedence bug | Wrap each condition: `(col("a") == "x") & (col("b") > 0)` |
| `filter(col("a") == None)` | Never matches — Python `None` ≠ Spark null | Use `col("a").isNull()` |
| `filter(col("dept").isin(["a", "b"]))` | Passing a list directly — works but not obvious | Both `isin("a", "b")` and `isin(["a", "b"])` work |
| Using `and`/`or` instead of `&`/`\|` | Python `and`/`or` don't work on Column objects | Always use `&`, `\|`, `~` |

---

## 13. Quick Reference

```python
# Basic filter/where
df.filter(col("dept") == "Engineering")
df.where("salary > 80000")

# Range
df.filter(col("salary").between(60000, 100000))

# In/Not in
df.filter(col("dept").isin("Engineering", "Finance"))
df.filter(~col("dept").isin("HR"))

# String matching
df.filter(col("name").startswith("A"))
df.filter(col("name").contains("ar"))
df.filter(col("name").like("A%"))

# Null checks
df.filter(col("salary").isNull())
df.filter(col("salary").isNotNull())

# Combining (parentheses required!)
df.filter((col("dept") == "Engineering") & (col("salary") > 80000))
df.filter((col("name").startswith("A")) | (col("salary") > 90000))

# HAVING equivalent
df.groupBy("dept").agg(avg("salary").alias("avg_sal")) \
  .filter(col("avg_sal") > 70000)
```
