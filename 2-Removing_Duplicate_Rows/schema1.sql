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