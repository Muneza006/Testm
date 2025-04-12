---insert table
BEGIN
   -- Create the engineering_projects table
CREATE TABLE engineering_projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    category VARCHAR(50), -- e.g., Civil, Mechanical, Electrical
    budget DECIMAL(10, 2),
    start_date DATE,
    completion_date DATE
);

-- Insert sample data
INSERT INTO engineering_projects VALUES
(1, 'Bridge Construction', 'Civil', 2500000, '2023-01-01', '2023-12-31'),
(2, 'Engine Design', 'Mechanical', 1500000, '2023-02-01', '2023-10-31'),
(3, 'Power Grid Upgrade', 'Electrical', 1800000, '2023-03-01', '2024-06-30'),
(4, 'Highway Expansion', 'Civil', 2500000, '2023-04-01', '2024-04-30'),
(5, 'HVAC Installation', 'Mechanical', 1200000, '2023-05-01', '2023-11-30'),
(6, 'Solar Farm', 'Electrical', 2000000, '2023-06-01', '2024-05-31'),
(7, 'Dam Rehabilitation', 'Civil', 2200000, '2023-07-01', '2024-03-31');
END;
/
commit;

-- 1. Compare Values with Previous/Next Records
SELECT 
    project_id,
    project_name,
    budget,
    start_date,
    LAG(budget) OVER (ORDER BY start_date) AS prev_budget,
    LEAD(budget) OVER (ORDER BY start_date) AS next_budget,
    CASE 
        WHEN budget > LAG(budget) OVER (ORDER BY start_date) THEN 'HIGHER'
        WHEN budget < LAG(budget) OVER (ORDER BY start_date) THEN 'LOWER'
        ELSE COALESCE(NULLIF('EQUAL', ''), 'N/A') 
    END AS budget_comparison
FROM engineering_projects
ORDER BY start_date;

-- 2. Ranking Data within a Category
SELECT 
    project_id,
    project_name,
    category,
    budget,
    RANK() OVER (PARTITION BY category ORDER BY budget DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY budget DESC) AS dense_rank
FROM engineering_projects;

-- 3. Identifying Top Records
WITH ranked_projects AS (
    SELECT 
        project_id,
        project_name,
        category,
        budget,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY budget DESC) AS rank
    FROM engineering_projects
)
SELECT *
FROM ranked_projects
WHERE rank <= 3;

-- 4. Finding the Earliest Records
WITH earliest_projects AS (
    SELECT 
        project_id,
        project_name,
        category,
        start_date,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY start_date) AS start_order
    FROM engineering_projects
)
SELECT *
FROM earliest_projects
WHERE start_order <= 2;

-- 5. Aggregation with Window Functions
SELECT 
    project_id,
    project_name,
    category,
    budget,
    MAX(budget) OVER (PARTITION BY category) AS category_max_budget,
    MAX(budget) OVER () AS overall_max_budget
FROM engineering_projects;
/
    End loop
    End
commit;
