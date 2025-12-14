-----

## 📅 SQL-Daily-Digest

### 🎯 Day 2: Removing Duplicate Rows

#### 1️⃣ Setup: Re-Create Table with Duplicates

We'll start with the same table and duplicate data set from Day 1 to ensure the deletion queries work correctly.

```sql
-- Re-create the customer table with duplicates (from Day 1)
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    rn SERIAL,
    fname VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO customer (fname, city, email) VALUES
( 'Alice', 'New York', 'alice.ny@example.com'),
( 'Bob', 'London', 'bob.london@example.com'),
( 'Charlie', 'Paris', 'charlie.paris@example.com'),
( 'Alice', 'New York', 'alice.ny@example.com'), -- Duplicate 1 (will be deleted)
( 'Bob', 'London', 'bob.london2@example.com'), -- Duplicate 2 (will be deleted)
( 'David', 'New York', 'david.ny@example.com');

-- Check initial data (6 rows)
SELECT * FROM customer;
```

#### 2️⃣ Problem Documentation

### Problem

Remove all duplicate rows from the `customer` table, retaining only the row with the lowest `rn` (the original entry) for each unique combination of `fname` and `city`.

### Query 1: Identify Rows to Keep and Delete

The most robust way to selectively delete duplicates is by using the `ROW_NUMBER()` window function. This function assigns a sequential integer to rows within a partition (a group), allowing us to easily designate one row as the "keeper."

**Query (SELECT to verify deletion target)**

```sql
WITH DuplicateFinder AS (
    SELECT
        rn,
        fname,
        city,
        ROW_NUMBER() OVER (
            PARTITION BY fname, city
            ORDER BY rn ASC -- Keep the row with the lowest 'rn' (the earliest entry)
        ) AS row_num
    FROM
        customer
)
-- Select the rows we intend to delete (where row_num > 1)
SELECT
    *
FROM
    DuplicateFinder
WHERE
    row_num > 1;
```

**Result** (These are the rows marked for deletion)

| rn | fname | city | row\_num |
| :---: | :---: | :---: | :---: |
| 4 | Alice | New York | 2 |
| 5 | Bob | London | 2 |

**Explanation**

1.  **`ROW_NUMBER() OVER (PARTITION BY fname, city ORDER BY rn ASC)`**:
      * **`PARTITION BY fname, city`**: Groups the rows based on the columns that define the duplicate (Alice/New York, Bob/London, etc.).
      * **`ORDER BY rn ASC`**: Within each group (partition), it assigns the number 1 to the row with the smallest `rn` and increments from there.
2.  **`WHERE row_num > 1`**: Filters the result to show only the rows that were assigned a number greater than 1, meaning they are the duplicates that should be removed.

-----

### Query 2: Delete the Duplicate Rows

We use the exact same CTE logic from Query 1, but this time, we use a `DELETE` statement in conjunction with the CTE to permanently remove the rows where the `row_num` is greater than 1.

**Query (DELETE to clean the table)**

```sql
DELETE FROM customer
USING (
    SELECT
        rn,
        ROW_NUMBER() OVER (
            PARTITION BY fname, city
            ORDER BY rn ASC
        ) AS row_num
    FROM
        customer
) AS DuplicateFinder
WHERE
    customer.rn = DuplicateFinder.rn
    AND DuplicateFinder.row_num > 1;

-- Verify the final result (should be 4 rows)
SELECT * FROM customer;
```

**Result**

| rn (Original) | fname | city | email |
| :---: | :---: | :---: | :---: |
| 1 | Alice | New York | alice.ny@example.com |
| 2 | Bob | London | bob.london@example.com |
| 3 | Charlie | Paris | charlie.paris@example.com |
| 6 | David | New York | david.ny@example.com |

**Explanation**

1.  **`DELETE FROM customer USING (...)`**: PostgreSQL allows you to specify a source table/subquery (the CTE/subquery) from which to pull data to help identify which rows to delete from the target table (`customer`).
2.  **`WHERE customer.rn = DuplicateFinder.rn`**: This join condition links the rows in the main table to the calculated `row_num` in the CTE.
3.  **`AND DuplicateFinder.row_num > 1`**: This is the final filter that ensures only the designated duplicate rows are removed.

-----
