---insert table
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

---Ranking Data within a Category

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
commit;
---Identifying Top Records

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
commit;
---Finding the Earliest Records

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
commit;
---Aggregation with Window Functions
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
commit;





