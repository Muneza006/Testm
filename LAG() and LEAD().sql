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
commit;

