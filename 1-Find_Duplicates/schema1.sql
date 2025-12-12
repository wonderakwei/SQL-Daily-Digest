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