--- Engineering table
CREATE TABLE engineering_projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    category VARCHAR(50), -- e.g., Civil, Mechanical, Electrical
    budget DECIMAL(10, 2),
    start_date DATE,
    completion_date DATE
);

