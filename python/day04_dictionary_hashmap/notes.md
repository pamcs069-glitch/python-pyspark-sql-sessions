# Day 4 — Python: Dictionary & HashMap

> **Roadmap Day:** 4 · **Date:** Thursday, June 18, 2026  
> **Study Window:** 9 PM – 11 PM  
> **Interview Level:** Easy → Medium

---

## 1. What Is a Dictionary?

A Python `dict` is a **mutable**, **ordered** (Python 3.7+) key-value store backed by a hash table. Lookup, insert, and delete are all **O(1)** average.

```python
d = {}                     # empty dict
d = {'a': 1, 'b': 2}      # literal
d = dict(a=1, b=2)        # keyword args
d = dict([('a', 1)])      # from list of pairs
```

---

## 2. Core Operations

```python
d = {'name': 'Alice', 'dept': 'Engineering', 'salary': 95000}

# Read
print(d['name'])           # 'Alice'  — KeyError if missing
print(d.get('age', 0))    # 0        — safe, returns default

# Write
d['salary'] = 100000       # update existing
d['city'] = 'New York'     # add new key

# Delete
del d['city']              # removes key, KeyError if missing
d.pop('dept')              # removes + returns value, optional default
d.pop('missing', None)     # safe pop — returns None if not found

# Check membership
'name' in d                # True   — O(1)
'age'  in d                # False

# Size
len(d)                     # number of key-value pairs
```

---

## 3. Iterating

```python
d = {'a': 1, 'b': 2, 'c': 3}

for key in d:                      # iterate keys (default)
    print(key)

for key, val in d.items():         # key-value pairs (most common)
    print(key, '->', val)

for val in d.values():             # values only
    print(val)

for key in d.keys():               # keys only (same as default)
    print(key)
```

---

## 4. Building a Frequency Map (Counter Pattern)

The most common dict interview pattern:

```python
sentence = "the cat sat on the mat the"

freq = {}
for word in sentence.split():
    freq[word] = freq.get(word, 0) + 1
# {'the': 3, 'cat': 1, 'sat': 1, 'on': 1, 'mat': 1}

# Equivalent using collections.Counter
from collections import Counter
freq = Counter(sentence.split())

# Most common word
print(max(freq, key=freq.get))     # 'the'
print(freq.most_common(1))         # [('the', 3)]
```

**`d.get(key, 0)`** returns 0 instead of raising `KeyError` — use this every time you build a counter.

---

## 5. HashMap Pattern — Two Sum

The canonical HashMap interview problem: use a dict to avoid the O(n²) brute-force nested loop.

```python
def two_sum(nums, target):
    seen = {}                        # {value: index}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            return [seen[complement], i]
        seen[num] = i
    return []

print(two_sum([2, 7, 11, 15], 9))   # [0, 1]
```

**Why this works:** for each number, the number you need is `target - num`. Check if that value is already in the dict. If yes, you have a pair.

| Approach | Time | Space |
|----------|------|-------|
| Brute force (nested loop) | O(n²) | O(1) |
| HashMap | O(n) | O(n) |

---

## 6. GroupBy Pattern — Grouping with a Dict

```python
employees = [
    {'name': 'Alice', 'dept': 'Engineering', 'salary': 95000},
    {'name': 'Bob',   'dept': 'Marketing',   'salary': 72000},
    {'name': 'Carol', 'dept': 'Engineering', 'salary': 88000},
]

# Group names by department
by_dept = {}
for emp in employees:
    dept = emp['dept']
    by_dept.setdefault(dept, []).append(emp['name'])
# {'Engineering': ['Alice', 'Carol'], 'Marketing': ['Bob']}

# Group and accumulate totals
dept_stats = {}
for emp in employees:
    dept = emp['dept']
    dept_stats.setdefault(dept, {'count': 0, 'total': 0.0})
    dept_stats[dept]['count'] += 1
    dept_stats[dept]['total'] += emp['salary']

for dept, s in dept_stats.items():
    print(f"{dept}: count={s['count']}  avg={s['total']/s['count']:.0f}")
```

**`d.setdefault(key, default)`** — inserts `default` if key is missing and returns the value. Avoids the `if key not in d` check.

---

## 7. defaultdict — Cleaner GroupBy

```python
from collections import defaultdict

by_dept = defaultdict(list)           # missing keys auto-init to []
for emp in employees:
    by_dept[emp['dept']].append(emp['name'])

dept_totals = defaultdict(lambda: {'count': 0, 'total': 0.0})
for emp in employees:
    dept_totals[emp['dept']]['count'] += 1
    dept_totals[emp['dept']]['total'] += emp['salary']
```

---

## 8. Dictionary Comprehensions

```python
names = ['alice', 'bob', 'carol']

# name → length
d = {name: len(name) for name in names}
# {'alice': 5, 'bob': 3, 'carol': 5}

# Filter: keep only names longer than 3
d = {name: len(name) for name in names if len(name) > 3}
# {'alice': 5, 'carol': 5}

# Invert a dict (swap keys and values)
original = {'a': 1, 'b': 2, 'c': 3}
inverted = {v: k for k, v in original.items()}
# {1: 'a', 2: 'b', 3: 'c'}
```

---

## 9. Day 4 Problems — Solutions

### Problem 1 (Easy) — Two Sum using HashMap
```python
def two_sum(nums, target):
    seen = {}
    for i, num in enumerate(nums):
        if target - num in seen:
            return [seen[target - num], i]
        seen[num] = i
    return []

print(two_sum([2, 7, 11, 15], 9))   # [0, 1]
```

### Problem 2 (Easy) — Highest Frequency Word
```python
def highest_frequency_word(sentence):
    freq = {}
    for word in sentence.lower().split():
        freq[word] = freq.get(word, 0) + 1
    return max(freq, key=freq.get)

print(highest_frequency_word("the cat sat on the mat the"))  # the
```

### Problem 3 (Medium) — Group Employees by Department
```python
def group_by_department(employees):
    dept_map = {}
    for emp in employees:
        dept = emp['dept']
        dept_map.setdefault(dept, {'headcount': 0, 'total_salary': 0.0})
        dept_map[dept]['headcount']    += 1
        dept_map[dept]['total_salary'] += emp['salary']
    return {
        dept: {
            'headcount':  data['headcount'],
            'avg_salary': round(data['total_salary'] / data['headcount'], 2),
        }
        for dept, data in dept_map.items()
    }
```

---

## 10. Interview Checklist

| Question | Answer |
|----------|--------|
| Dict lookup time complexity? | O(1) average — backed by a hash table |
| Safe read without KeyError? | `d.get(key, default)` |
| How to count frequencies? | `d[k] = d.get(k, 0) + 1` or `Counter(iterable)` |
| How to group items into lists? | `d.setdefault(key, []).append(item)` or `defaultdict(list)` |
| Max value in a dict? | `max(d, key=d.get)` returns the key with the largest value |
| Two Sum O(n) — key idea? | Store `{value: index}` as you iterate; check if `target - num` already seen |
| Dict vs defaultdict? | `defaultdict(type)` auto-creates missing keys; avoids `if k not in d` |

---

## 11. Quick Reference

```python
# Create
d = {}
d = {'key': value}
d = dict(key=value)

# Read / write
d[key]                         # read — KeyError if missing
d.get(key, default)            # safe read
d[key] = value                 # write / update
d.setdefault(key, default)     # write only if missing, return value

# Delete
del d[key]
d.pop(key, default)            # safe delete

# Check
key in d                       # O(1)
len(d)

# Iterate
for k, v in d.items():   ...
for k in d.keys():       ...
for v in d.values():     ...

# Counter pattern
freq = {}
for x in lst: freq[x] = freq.get(x, 0) + 1
max(freq, key=freq.get)        # key with max value

# GroupBy pattern
groups = {}
groups.setdefault(key, []).append(item)

# Comprehension
{k: f(v) for k, v in d.items() if cond}

# collections
from collections import Counter, defaultdict
Counter(lst)                   # freq map
defaultdict(list)              # auto-init missing keys to []
```
