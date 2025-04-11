## Creat table Engineering projects
```sql
CREATE TABLE engineering_projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    category VARCHAR(50), -- e.g., Civil, Mechanical, Electrical
    budget DECIMAL(10, 2),
    start_date DATE,
    completion_date DATE
);

```

![image](https://github.com/user-attachments/assets/efb88241-dd8a-466d-9103-412e26ffd019)

## INSERT INTO engineering_projects 
```sql
BEGIN
    INSERT INTO engineering_projects VALUES
        (1, 'Bridge Construction', 'Civil', 2500000, DATE '2023-01-01', DATE '2023-12-31');

    INSERT INTO engineering_projects VALUES
        (2, 'Engine Design', 'Mechanical', 1500000, DATE '2023-02-01', DATE '2023-10-31');

    INSERT INTO engineering_projects VALUES
        (3, 'Power Grid Upgrade', 'Electrical', 1800000, DATE '2023-03-01', DATE '2024-06-30');

    INSERT INTO engineering_projects VALUES
        (4, 'Highway Expansion', 'Civil', 2500000, DATE '2023-04-01', DATE '2024-04-30');

    INSERT INTO engineering_projects VALUES
        (5, 'HVAC Installation', 'Mechanical', 1200000, DATE '2023-05-01', DATE '2023-11-30');

    INSERT INTO engineering_projects VALUES
        (6, 'Solar Farm', 'Electrical', 2000000, DATE '2023-06-01', DATE '2024-05-31');

    INSERT INTO engineering_projects VALUES
        (7, 'Dam Rehabilitation', 'Civil', 2200000, DATE '2023-07-01', DATE '2024-03-31');
END;
/
commit;
```
![image](https://github.com/user-attachments/assets/e41c5715-4bc1-4de0-b953-0a3d26b4b3b3)

# 1. Compare Values with Previous/Next Records:

Compare project budgets with previous and next projects (ordered by start date):

```sql
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_projects IS
        SELECT 
            project_id,
            project_name,
            budget,
            start_date,
            LAG(budget) OVER (ORDER BY start_date) AS prev_budget,
            LEAD(budget) OVER (ORDER BY start_date) AS next_budget
        FROM engineering_projects
        ORDER BY start_date;

    v_comparison VARCHAR2(10);
BEGIN
    FOR rec IN c_projects LOOP
        IF rec.prev_budget IS NULL THEN
            v_comparison := 'N/A';
        ELSIF rec.budget > rec.prev_budget THEN
            v_comparison := 'HIGHER';
        ELSIF rec.budget < rec.prev_budget THEN
            v_comparison := 'LOWER';
        ELSE
            v_comparison := 'EQUAL';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Project ID: ' || rec.project_id ||
            ', Name: ' || rec.project_name ||
            ', Budget: ' || rec.budget ||
            ', Start Date: ' || rec.start_date ||
            ', Previous Budget: ' || NVL(TO_CHAR(rec.prev_budget), 'NULL') ||
            ', Next Budget: ' || NVL(TO_CHAR(rec.next_budget), 'NULL') ||
            ', Comparison: ' || v_comparison
        );
    END LOOP;
END;
/

```
![image](https://github.com/user-attachments/assets/d93754c7-1bd4-4acd-95c4-9218f40b5dd4)

# 2. Ranking Data within a Category

Rank projects by budget within each engineering category:
```sql
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_ranked_projects IS
        SELECT 
            project_id,
            project_name,
            category,
            budget,
            RANK() OVER (PARTITION BY category ORDER BY budget DESC) AS rnk,
            DENSE_RANK() OVER (PARTITION BY category ORDER BY budget DESC) AS dense_rnk
        FROM engineering_projects;

BEGIN
    FOR rec IN c_ranked_projects LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Project ID: ' || rec.project_id ||
            ', Name: ' || rec.project_name ||
            ', Category: ' || rec.category ||
            ', Budget: ' || rec.budget ||
            ', Rank: ' || rec.rnk ||
            ', Dense Rank: ' || rec.dense_rnk
        );
    END LOOP;
END;
/

```
![image](https://github.com/user-attachments/assets/e20b8692-1e5e-46e5-b332-e31075f0af98)
# 3. Identifying Top Records

Fetch the top 3 highest-budget projects in each category:

```sql
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_top_projects IS
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

BEGIN
    FOR rec IN c_top_projects LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Project ID: ' || rec.project_id ||
            ', Name: ' || rec.project_name ||
            ', Category: ' || rec.category ||
            ', Budget: ' || rec.budget ||
            ', Rank: ' || rec.rank
        );
    END LOOP;
END;
/

```
![image](https://github.com/user-attachments/assets/cc777311-14f1-4f78-94cb-afb93bba1fad)

# 4. Finding the Earliest Records

Retrieve the first 2 projects started in each category:

```sql
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_earliest_projects IS
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

BEGIN
    FOR rec IN c_earliest_projects LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Project ID: ' || rec.project_id ||
            ', Name: ' || rec.project_name ||
            ', Category: ' || rec.category ||
            ', Start Date: ' || TO_CHAR(rec.start_date, 'YYYY-MM-DD') ||
            ', Start Order: ' || rec.start_order
        );
    END LOOP;
END;
/

```
![image](https://github.com/user-attachments/assets/f81e09f3-4a57-4f8d-968a-07e9e73be336)

# 5. Aggregation with Window Functions

Calculate category-level and overall maximum budgets:
```sql
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_project_budgets IS
        SELECT 
            project_id,
            project_name,
            category,
            budget,
            MAX(budget) OVER (PARTITION BY category) AS category_max_budget,
            MAX(budget) OVER () AS overall_max_budget
        FROM engineering_projects;

BEGIN
    FOR rec IN c_project_budgets LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Project ID: ' || rec.project_id ||
            ', Name: ' || rec.project_name ||
            ', Category: ' || rec.category ||
            ', Budget: ' || rec.budget ||
            ', Category Max Budget: ' || rec.category_max_budget ||
            ', Overall Max Budget: ' || rec.overall_max_budget
        );
    END LOOP;
END;
/

```
![image](https://github.com/user-attachments/assets/7fc64668-f877-48f3-afec-f56ce103e289)




