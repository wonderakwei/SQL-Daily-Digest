
---

## SQL-Daily-Digest

### Day 1: Find Duplicate Rows in a Table

#### 1️⃣ Setup: Table Creation and Data Insertion (PostgreSQL)

First, let's create the sample `customer` table and insert data, ensuring we include duplicates.

```sql
-- 1. Create the table
CREATE TABLE customer (
    rn SERIAL PRIMARY KEY, -- Using SERIAL for a unique ID column
    fname VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE
);

-- Note: We intentionally violate the email UNIQUE constraint in the duplicate rows,
-- but for simplicity in this exercise, we will focus on duplicates across (fname, city) or the entire row.
-- Let's redefine the table without the email UNIQUE constraint for easier duplicate insertion.

DROP TABLE customer; -- Drop the previous table if it exists
CREATE TABLE customer (
    rn SERIAL,
    fname VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100)
);

-- 2. Insert Sample Data (with Duplicates)
INSERT INTO customer (fname, city, email) VALUES
('Alice', 'New York', 'alice.ny@example.com'),
('Bob', 'London', 'bob.london@example.com'),
('Charlie', 'Paris', 'charlie.paris@example.com'),
('Alice', 'New York', 'alice.ny@example.com'), -- **Full Duplicate of Row 1**
('Bob', 'London', 'bob.london2@example.com'), -- **Partial Duplicate (fname, city) of Row 2**
('David', 'New York', 'david.ny@example.com');

-- Check the initial data
SELECT * FROM customer;
```

#### 2️⃣ Problem Documentation

### Problem

Identify and retrieve all rows in the `customer` table that are considered duplicates, based on the combination of the `fname` and `city` columns.

### Query 1: Identify Which Names/Cities are Duplicated

This query uses the `GROUP BY` and `HAVING` clauses, which is the standard, most efficient way to **count** and **identify** the combination of values that appear more than once.

**Query**

```sql
SELECT
    fname,
    city,
    COUNT(*) AS occurrence_count
FROM
    customer
GROUP BY
    fname,
    city
HAVING
    COUNT(*) > 1;
```

**Result** (Conceptual)

| fname |   city   | occurrence_count |
| :---: | :------: | :--------------: |
| Alice | New York |        2         |
|  Bob  |  London  |        2         |

**Explanation**

- **`GROUP BY fname, city`**: This aggregates the rows into groups based on unique combinations of first name and city.
- **`COUNT(*)`**: Counts the number of rows in each group.
- **`HAVING COUNT(*) > 1`**: Filters the groups, keeping only those where the count is greater than 1, meaning that specific `(fname, city)` combination is a duplicate.

---

### Query 2: Retrieve All Duplicate Rows (Including Originals)

Often, you need to see all the individual rows that form the duplicate group, including their `rn` (row number) and other columns. This is done using a Window Function inside a Common Table Expression (CTE) to avoid the `window functions are not allowed in WHERE` error.

**Query**

```sql
WITH RankedCustomers AS (
    SELECT
        rn,
        fname,
        city,
        email,
        COUNT(1) OVER (PARTITION BY fname, city) AS duplicate_group_count
    FROM
        customer
)
-- Filter the results based on the calculated duplicate_group_count column
SELECT
    rn,
    fname,
    city,
    email,
    duplicate_group_count
FROM
    RankedCustomers
WHERE
    duplicate_group_count > 1
ORDER BY
    fname, city, rn;
```

**Result** (Conceptual)

| rn  | fname |   city   |          email          | duplicate_group_count |
| :-: | :---: | :------: | :---------------------: | :-------------------: |
|  1  | Alice | New York |  alice.ny@example.com   |           2           |
|  4  | Alice | New York |  alice.ny@example.com   |           2           |
|  2  |  Bob  |  London  | bob.london@example.com  |           2           |
|  5  |  Bob  |  London  | bob.london2@example.com |           2           |

**Explanation**

1.  **`WITH RankedCustomers AS (...)`**: Defines a temporary, named result set (the CTE).
2.  **Inside the CTE**:
    - **Window Function `COUNT(1) OVER (PARTITION BY fname, city)`**: Calculates the count for each unique `(fname, city)` combination and applies that count back to every individual row in the group.
3.  **Outside the CTE**:
    - The main `SELECT` query treats `RankedCustomers` like a regular table.
    - The `WHERE duplicate_group_count > 1` clause filters the rows, keeping only those belonging to a group that appeared more than once.

---
