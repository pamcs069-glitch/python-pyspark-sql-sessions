# Day 1 — Python: For Loop, Break, Continue, Enumerate, Zip

> **Roadmap Day:** 1 · **Date:** Monday, June 15, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Interview Level:** Easy → Medium

---

## 1. For Loop — The Foundation

A `for` loop iterates over any **iterable** (list, tuple, string, range, dict, generator).

```python
products = ["laptop", "mouse", "keyboard"]

for product in products:
    print(product)
```

**Key mental model:** Python `for` is always a "for-each" — you don't manage an index counter yourself. If you need the index, use `enumerate`.

---

## 2. Break — Exit the Loop Early

`break` immediately exits the **innermost** loop when a condition is met.

```python
sales = [2000, 3500, 4100, 1800, 5200]
total = 0

for i, sale in enumerate(sales, start=1):
    total += sale
    if total > 10000:
        print(f"Crossed 10000 on day {i}, total = {total}")
        break
```

**DE context:** Stop reading file chunks once you've collected enough rows. Stop polling an API once you find the record you need.

---

## 3. Continue — Skip This Iteration

`continue` skips the rest of the current iteration body and moves to the next iteration.

```python
records = [100, None, 250, None, 300]

for val in records:
    if val is None:
        continue          # skip nulls — don't process bad rows
    print(f"Processing: {val}")
```

**DE context:** Skip null/bad rows in a transformation loop without breaking the whole pipeline.

---

## 4. Enumerate — Loop With Index

`enumerate(iterable, start=0)` wraps any iterable and yields `(index, value)` pairs.

```python
products = ["laptop", "mouse", "keyboard", "monitor"]

for idx, product in enumerate(products, start=1):
    print(f"{idx}. {product}")
# 1. laptop
# 2. mouse
# 3. keyboard
# 4. monitor
```

### Why not `range(len(...))`?

```python
# Avoid — fragile and verbose
for i in range(len(products)):
    print(i, products[i])

# Prefer — idiomatic Python
for i, product in enumerate(products):
    print(i, product)
```

`enumerate` is cleaner, works on any iterable (not just lists), and is the standard in code reviews.

---

## 5. Zip — Pair Two (or More) Iterables

`zip(a, b)` pairs elements by position. **Stops at the shortest iterable.**

```python
names    = ["Alice", "Bob", "Carol"]
salaries = [80000,   95000,  72000]

for name, salary in zip(names, salaries):
    print(f"{name}: ${salary:,}")
# Alice: $80,000
# Bob: $95,000
# Carol: $72,000
```

### zip truncates at the shortest

```python
a = [1, 2, 3, 4, 5]
b = ["x", "y"]

list(zip(a, b))   # [(1, 'x'), (2, 'y')] — 3, 4, 5 are silently dropped
```

Use `itertools.zip_longest(a, b, fillvalue=None)` when you need all elements.

### zip to build a dict (very common in DE)

```python
headers = ["emp_id", "name", "salary"]
values  = [101, "Alice", 80000]

record = dict(zip(headers, values))
# {"emp_id": 101, "name": "Alice", "salary": 80000}
```

**DE context:** Pair column headers (row 0 of a CSV) with data rows to build dicts when reading files without pandas.

### Unzipping — reverse of zip

```python
pairs = [("Alice", 80000), ("Bob", 95000)]
names, salaries = zip(*pairs)
# names = ("Alice", "Bob")
# salaries = (80000, 95000)
```

---

## 6. The `else` Clause on a Loop

Rarely taught, but useful in interviews:

```python
target = 9999

for sale in [2000, 3000, 4000]:
    if sale > target:
        print("Found it")
        break
else:
    print("Never crossed target")   # runs only if no break hit
```

**DE use:** Signal "record not found" cleanly without a flag variable.

---

## 7. Combining All — Real DE Patterns

### Pattern: Read rows, skip nulls, stop after N valid records

```python
raw_records = [
    {"id": 1, "amount": 500},
    {"id": 2, "amount": None},
    {"id": 3, "amount": 1200},
    {"id": 4, "amount": 800},
    {"id": 5, "amount": 300},
]

MAX = 3
good = []

for record in raw_records:
    if record["amount"] is None:
        continue
    good.append(record)
    if len(good) >= MAX:
        break

print(good)
```

### Pattern: Build structured rows from two lists

```python
headers  = ["product", "price", "stock"]
data_row = ["laptop", 999, 50]

row_dict = dict(zip(headers, data_row))
# {"product": "laptop", "price": 999, "stock": 50}
```

### Pattern: Enumerate + zip for indexed pairs

```python
for i, (name, salary) in enumerate(zip(names, salaries), start=1):
    print(f"{i}. {name} earns ${salary:,}")
```

---

## 8. Day 1 Problems — Solutions

### Problem 1 (Easy)
Using `enumerate`, loop over products and print index + name in a formatted way.

```python
products = ["laptop", "mouse", "keyboard", "monitor", "webcam"]

for idx, product in enumerate(products, start=1):
    print(f"[{idx:02d}] {product.title()}")
```

Output:
```
[01] Laptop
[02] Mouse
[03] Keyboard
[04] Monitor
[05] Webcam
```

### Problem 2 (Easy)
Using `zip`, pair employee names with their salaries and print a report.

```python
employees = ["Alice", "Bob", "Carol", "David"]
salaries  = [80000, 95000, 72000, 110000]

print(f"{'Employee':<12} {'Salary':>10}")
print("-" * 24)
for name, salary in zip(employees, salaries):
    print(f"{name:<12} ${salary:>9,}")
```

### Problem 3 (Medium)
Accumulate running total of daily sales; `break` when it exceeds 10000 — report which day crossed.

```python
daily_sales = [1200, 3400, 2100, 800, 4500, 1900, 2200]
running_total = 0

for day, sales in enumerate(daily_sales, start=1):
    running_total += sales
    print(f"Day {day}: +{sales} → total = {running_total}")
    if running_total > 10000:
        print(f"\n>> Crossed 10,000 on Day {day} (total = {running_total:,})")
        break
else:
    print("10,000 was never crossed in this dataset.")
```

---

## 9. Interview Checklist

| Question | Expected Answer |
|----------|-----------------|
| What does `enumerate` return? | An `enumerate` object yielding `(index, value)` tuples |
| What happens when zip iterables are unequal length? | Stops at the shortest; use `zip_longest` to keep all |
| `break` vs `continue`? | `break` exits the loop; `continue` skips to next iteration |
| When does a `for/else` block run? | Only when the loop finishes without hitting a `break` |
| How do you unzip a list of pairs? | `zip(*pairs)` — the `*` unpacks the list as arguments |
| Can `enumerate` start at 1? | Yes: `enumerate(lst, start=1)` |

---

## 10. Quick Reference

```python
for item in iterable: ...                      # basic
for item in iterable:
    if bad: continue                           # skip
    if done: break                             # exit

for i, val in enumerate(lst, start=1): ...     # with index
for a, b in zip(list_a, list_b): ...           # paired
for i, (a, b) in enumerate(zip(la, lb)): ...   # both

d = dict(zip(keys, values))                    # → dict
keys, vals = zip(*pairs)                       # unzip
```
