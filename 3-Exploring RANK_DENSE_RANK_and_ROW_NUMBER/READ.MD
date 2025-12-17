## 📅 SQL-Daily-Digest

### 🎯 Day 3: Exploring RANK, DENSE_RANK, and ROW_NUMBER

#### 1️⃣ Setup: Table Creation and Data Insertion (PostgreSQL)

We'll create an `employee_scores` table designed to generate ties, which is essential for understanding the differences between the three ranking functions.

```sql
-- Re-create the table for Day 3 practice
DROP TABLE IF EXISTS employee_scores;

CREATE TABLE employee_scores (
    employee_id SERIAL PRIMARY KEY,
    department VARCHAR(50),
    score INT,
    hire_date DATE
);

-- Insert Sample Data (with intentional ties in scores)
INSERT INTO employee_scores (department, score, hire_date) VALUES
('Sales', 95, '2023-01-10'),  -- Highest score
('Sales', 95, '2023-02-15'),  -- Tie with first Sales
('Marketing', 88, '2023-03-01'),
('Marketing', 88, '2023-04-20'),  -- Tie with first Marketing
('HR', 75, '2023-05-05'),
('HR', 75, '2023-06-12'),   -- Tie with first HR
('Sales', 92, '2023-07-01'),  -- Next highest Sales score
('Marketing', 80, '2023-08-10'),
('HR', 65, '2023-09-01'),
('Sales', 50, '2023-10-15');  -- Lowest score

-- Check initial data
SELECT * FROM employee_scores ORDER BY department, score DESC;
```

#### 2️⃣ Problem Documentation

### Problem

Analyze employee scores within each department by applying the three primary ranking window functions: `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`. Understand how each function handles ties.

### Query: Comparing All Three Ranking Functions

This single query will demonstrate the crucial differences between the three functions side-by-side by partitioning the data by `department` and ordering by `score` (highest first).

**Query**

```sql
SELECT
    employee_id,
    department,
    score,
    -- 1. ROW_NUMBER: Assigns a unique, sequential integer (1, 2, 3...)
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY score DESC) AS rn,

    -- 2. RANK: Assigns the same rank to ties, then skips the next rank numbers.
    RANK() OVER (PARTITION BY department ORDER BY score DESC) AS rnk,

    -- 3. DENSE_RANK: Assigns the same rank to ties, but does NOT skip any rank numbers.
    DENSE_RANK() OVER (PARTITION BY department ORDER BY score DESC) AS dense_rnk
FROM
    employee_scores
ORDER BY
    department, score DESC, hire_date;
```

**Result** (Conceptual: Focus on the ranks for the tie-breakers)

| employee_id | department | score | rn  | rnk | dense_rnk |
| :---------: | :--------: | :---: | :-: | :-: | :-------: |
|      1      |     HR     |  75   |  1  |  1  |     1     |
|      2      |     HR     |  75   |  2  |  1  |     1     |
|      3      |     HR     |  65   |  3  |  3  |     2     |
|      4      | Marketing  |  88   |  1  |  1  |     1     |
|      5      | Marketing  |  88   |  2  |  1  |     1     |
|      6      | Marketing  |  80   |  3  |  3  |     2     |
|      7      |   Sales    |  95   |  1  |  1  |     1     |
|      8      |   Sales    |  95   |  2  |  1  |     1     |
|      9      |   Sales    |  92   |  3  |  3  |     2     |
|     10      |   Sales    |  50   |  4  |  4  |     3     |

### Analysis and Explanation

The key to these functions lies in how they handle rows with identical values (ties) within a partition.

|     Function     |                                              How it Handles Ties                                               |                                   Next Rank After Tie                                    |                                                 Use Case                                                 |
| :--------------: | :------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------: |
| **ROW_NUMBER()** | Does **NOT** acknowledge ties. Assigns a unique, sequential number to every row, even if values are identical. |                      Always continues sequentially (e.g., 1, 2, 3)                       |                     Used for **deduplication** (like in Day 2) or paging/pagination.                     |
|    **RANK()**    |                                   Assigns the **same rank** to tied values.                                    |     **Skips** the next rank(s). If two rows are rank 1, the next distinct rank is 3.     | Used when you need the "top N" items and skipping ranks after ties is acceptable (e.g., Olympic medals). |
| **DENSE_RANK()** |                                   Assigns the **same rank** to tied values.                                    | **Does NOT skip** any rank numbers. If two rows are rank 1, the next distinct rank is 2. |     Used when you need to find the rank of distinct values (e.g., finding all unique score levels).      |

#### Scenario Insights: When to Choose One Over the Other

1.  **To get the single oldest entry per department (Deduplication):**

    - **Choose:** `ROW_NUMBER()`.
    - **Reason:** You need a single number 1, even if scores are tied, to uniquely identify the row to keep.

2.  **To see the top three unique score levels in Sales:**

    - **Choose:** `DENSE_RANK()`.
    - **Reason:** If two employees tie for the top score, the next score should be rank 2, not rank 3. You care about the unique _level_ of performance.

3.  **To see the list of employees who finished in the top 3 (where finishing 1st and 2nd might mean rank 1 and 3):**

    - **Choose:** `RANK()`.
    - **Reason:** This is used in competitive scoring where sharing a rank "consumes" the slots. For example, if two employees tie for 1st place (`rnk=1`), the next best score is technically 3rd place (`rnk=3`).

---
