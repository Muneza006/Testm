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
