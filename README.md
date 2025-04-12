## Create table Engineering projects
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
## Explanation:

The LAG() function retrieves the budget of the previous project when projects are ordered by start date
The LEAD() function retrieves the budget of the next project
The CASE statement classifies each budget as HIGHER, LOWER, or EQUAL compared to the previous project
For the first project (with no previous), we show 'N/A' using the COALESCE function

## Real-life Application:

This analysis helps project managers identify budget trends over time. It can reveal whether project budgets are consistently increasing,
which might indicate scope creep or inflation in material costs. It's particularly useful for financial planning and forecasting future project budgets.

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

## Explanation of Difference Between RANK() and DENSE_RANK():

RANK() assigns the same rank to tied values but leaves gaps in the ranking sequence
DENSE_RANK() assigns the same rank to tied values but does not leave gaps

## Real-life Application:

This ranking helps engineering firms identify their highest-budget projects in each category, which often correlate with the most complex or prestigious projects. 
The ranking can be used for resource allocation, portfolio showcasing, and identifying expertise areas within the firm.

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

## Explanation:

A Common Table Expression (CTE) first ranks all projects within their categories by budget
DENSE_RANK() is used to handle potential budget ties appropriately
The WHERE clause filters to include only the top 3 highest-budget projects in each category
If there are ties for the 3rd position, all tied projects would be included

## Real-life Application:

Engineering firms often highlight their top projects when bidding for new contracts. This query quickly identifies the most significant projects by budget in each engineering discipline,
which can be featured in proposals, marketing materials, or annual reports.


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

## Explanation:

ROW_NUMBER() assigns a unique sequence number to projects in each category based on start date
Unlike RANK() or DENSE_RANK(), ROW_NUMBER() will always assign unique numbers even when there are ties
This query identifies the first two projects started in each engineering category
If there happens to be a tie in start date, ROW_NUMBER() will arbitrarily assign sequence numbers

## Real-life Application:

This analysis helps identify the pioneering projects in each engineering category. For engineering firms, understanding which projects initiated work in -
specific disciplines can provide historical context for expertise development. It's also useful for tracking the evolution of project complexity and scope over time.


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

## Explanation:

MAX(budget) OVER (PARTITION BY category) calculates the maximum budget within each engineering category
MAX(budget) OVER () calculates the maximum budget across all projects
The key difference is in the PARTITION BY clause:

With PARTITION BY category, the calculation is done separately for each category
Without PARTITION BY (empty OVER ()), the calculation spans all projects



## Real-life Application:
This analysis provides context for individual project budgets by showing how they compare to the maximum budgets both within their category and across the entire project portfolio. 
Project managers can use this to understand budget scaling within different engineering disciplines and identify which categories typically require the largest investments.


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




