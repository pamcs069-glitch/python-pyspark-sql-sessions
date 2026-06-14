# Day 1 — SQL: Filters (WHERE, HAVING, BETWEEN, IN, LIKE)

> **Roadmap Day:** 1 · **Date:** Monday, June 15, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Dataset:** `employees(emp_id, name, dept, salary, hire_date)`

---

## 1. The Dataset

```sql
CREATE TABLE employees (
    emp_id    INT PRIMARY KEY,
    name      VARCHAR(100),
    dept      VARCHAR(50),
    salary    DECIMAL(10,2),
    hire_date DATE
);

INSERT INTO employees VALUES
(1,  'Alice',   'Engineering', 95000,  '2021-03-15'),
(2,  'Bob',     'Engineering', 58000,  '2022-07-01'),
(3,  'Carol',   'Marketing',   72000,  '2020-11-20'),
(4,  'David',   'Engineering', 105000, '2019-06-10'),
(5,  'Eve',     'HR',          48000,  '2022-01-05'),
(6,  'Frank',   'Marketing',   67000,  '2023-04-18'),
(7,  'Grace',   'Engineering', 88000,  '2022-09-22'),
(8,  'Hank',    'HR',          51000,  '2021-12-01'),
(9,  'Irene',   'Finance',     93000,  '2020-03-30'),
(10, 'Arthur',  'Engineering', 76000,  '2022-05-14');
```

---

## 2. WHERE — Row-Level Filtering

`WHERE` filters rows **before** any grouping. Think of it as a gate — only rows passing the condition enter further processing.

```sql
SELECT * FROM employees
WHERE dept = 'Engineering';
```

### Comparison Operators

| Operator | Meaning |
|----------|---------|
| `=`      | Equal |
| `<>` or `!=` | Not equal |
| `>`  `<`  `>=`  `<=` | Numeric / date comparisons |
| `IS NULL` / `IS NOT NULL` | Null checks |

---

## 3. BETWEEN — Inclusive Range Filter

`BETWEEN low AND high` is **inclusive** on both ends. Equivalent to `>= low AND <= high`.

```sql
-- Employees with salary between 60000 and 100000 (inclusive)
SELECT emp_id, name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 100000;
```

Works on dates too:

```sql
-- Hired in the year 2022
SELECT * FROM employees
WHERE hire_date BETWEEN '2022-01-01' AND '2022-12-31';
```

> **Gotcha:** `BETWEEN` on timestamps — `BETWEEN '2022-01-01' AND '2022-12-31'` may miss rows with time component `2022-12-31 23:59:59`. Prefer `>= '2022-01-01' AND < '2023-01-01'` for timestamps.

---

## 4. IN — Match Any Value in a List

`IN (v1, v2, v3)` is cleaner than chained `OR` conditions.

```sql
-- Same as dept = 'Engineering' OR dept = 'Finance'
SELECT * FROM employees
WHERE dept IN ('Engineering', 'Finance');
```

`NOT IN`:

```sql
SELECT * FROM employees
WHERE dept NOT IN ('HR', 'Marketing');
```

> **Gotcha:** `NOT IN` with NULLs — if the list contains a NULL, `NOT IN` returns no rows. Always filter nulls first or use `NOT EXISTS`.

---

## 5. LIKE — Pattern Matching

```sql
-- Names starting with 'A'
SELECT * FROM employees
WHERE name LIKE 'A%';

-- Names ending with 'e'
SELECT * FROM employees
WHERE name LIKE '%e';

-- Names containing 'ar' anywhere
SELECT * FROM employees
WHERE name LIKE '%ar%';
```

| Wildcard | Meaning |
|----------|---------|
| `%` | Zero or more characters |
| `_` | Exactly one character |

Case sensitivity depends on the DB collation. Use `ILIKE` in PostgreSQL for case-insensitive matching.

---

## 6. AND / OR — Combining Conditions

```sql
-- Engineering dept AND salary in range
SELECT * FROM employees
WHERE dept = 'Engineering'
  AND salary BETWEEN 60000 AND 100000;

-- Name starts with 'A' OR hired in 2022
SELECT * FROM employees
WHERE name LIKE 'A%'
   OR hire_date BETWEEN '2022-01-01' AND '2022-12-31';
```

> **Operator precedence:** `AND` binds tighter than `OR`. Always use parentheses when mixing them to avoid bugs.

```sql
-- Ambiguous — OR is evaluated last but visually looks grouped
WHERE a = 1 OR b = 2 AND c = 3

-- Clear intent
WHERE a = 1 OR (b = 2 AND c = 3)
```

---

## 7. HAVING — Filter After Grouping

`WHERE` cannot reference aggregate functions. `HAVING` runs **after** `GROUP BY` and can filter on aggregates.

```sql
-- Departments where average salary > 70000
SELECT dept, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept
HAVING AVG(salary) > 70000;
```

### WHERE vs HAVING — when to use which

| Clause | Runs | Can reference aggregates? | Use for |
|--------|------|--------------------------|---------|
| `WHERE` | Before GROUP BY | No | Filter individual rows |
| `HAVING` | After GROUP BY | Yes | Filter groups |

```sql
-- WHERE filters rows first, then HAVING filters groups
SELECT dept, COUNT(*) AS headcount, AVG(salary) AS avg_sal
FROM employees
WHERE hire_date >= '2020-01-01'   -- filter rows first
GROUP BY dept
HAVING COUNT(*) >= 2;             -- then filter groups
```

---

## 8. SQL Query Execution Order

Understanding this prevents common mistakes:

```
1. FROM / JOIN      — identify source tables
2. WHERE            — filter rows
3. GROUP BY         — form groups
4. HAVING           — filter groups
5. SELECT           — compute output columns
6. ORDER BY         — sort
7. LIMIT / OFFSET   — paginate
```

This is why you **cannot** use a SELECT alias in WHERE — the alias doesn't exist yet at step 2.

```sql
-- ERROR — 'annual_bonus' alias doesn't exist in WHERE
SELECT salary * 0.1 AS annual_bonus
FROM employees
WHERE annual_bonus > 5000;   -- column doesn't exist yet

-- CORRECT — repeat the expression or use a subquery/CTE
SELECT salary * 0.1 AS annual_bonus
FROM employees
WHERE salary * 0.1 > 5000;
```

---

## 9. Day 1 Problems — Solutions

### Problem 1 (Easy)
Find all employees in 'Engineering' with salary between 60000 and 100000.

```sql
SELECT emp_id, name, dept, salary
FROM employees
WHERE dept = 'Engineering'
  AND salary BETWEEN 60000 AND 100000;
```

Expected: Alice (95000), Grace (88000), Arthur (76000) — Bob (58000) is excluded, David (105000) is excluded.

### Problem 2 (Easy)
Find departments where average salary > 70000.

```sql
SELECT dept,
       ROUND(AVG(salary), 2) AS avg_salary,
       COUNT(*)               AS headcount
FROM employees
GROUP BY dept
HAVING AVG(salary) > 70000
ORDER BY avg_salary DESC;
```

### Problem 3 (Medium)
Find employees whose name starts with 'A' OR whose hire_date falls in 2022.

```sql
SELECT emp_id, name, dept, salary, hire_date
FROM employees
WHERE name LIKE 'A%'
   OR hire_date BETWEEN '2022-01-01' AND '2022-12-31'
ORDER BY hire_date;
```

Expected: Arthur (name starts with A), Bob/Eve/Grace/Arthur (hired 2022).  
Note Arthur matches both conditions — appears once (no duplicates in a single table scan).

---

## 10. Common Mistakes to Avoid

| Mistake | Problem | Fix |
|---------|---------|-----|
| `WHERE AVG(salary) > 70000` | AVG not available in WHERE | Use HAVING |
| `NOT IN (1, 2, NULL)` | Returns zero rows when list has NULL | Exclude NULLs from the list |
| `BETWEEN '2022-01-01' AND '2022-12-31'` on timestamps | Misses Dec 31st late records | Use `>= '2022-01-01' AND < '2023-01-01'` |
| Mixing AND/OR without parentheses | Operator precedence bugs | Always parenthesize OR groups |
| `WHERE col = NULL` | Never returns rows | Use `WHERE col IS NULL` |

---

## 11. Quick Reference

```sql
-- Equality and range
WHERE dept = 'Engineering'
WHERE salary BETWEEN 60000 AND 100000
WHERE dept IN ('Engineering', 'Finance')
WHERE name LIKE 'A%'
WHERE hire_date IS NOT NULL

-- Combining
WHERE dept = 'Engineering' AND salary > 80000
WHERE name LIKE 'A%' OR YEAR(hire_date) = 2022

-- Aggregation filter
GROUP BY dept
HAVING AVG(salary) > 70000
HAVING COUNT(*) >= 3
```
