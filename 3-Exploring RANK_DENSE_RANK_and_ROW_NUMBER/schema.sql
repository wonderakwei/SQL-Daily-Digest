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