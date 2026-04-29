-- <query bed_occupancy_rate>
-- <description>Calculates the current bed occupancy rate across the entire hospital</description>
-- <query>
WITH total_beds AS (
    SELECT SUM(Bed_Count) AS max_capacity FROM healthcare.rooms WHERE Is_Available = TRUE
),
occupied_beds AS (
    SELECT COUNT(Admission_ID) AS current_patients FROM healthcare.admissions WHERE Status = 'Admitted'
)
SELECT 
    t.max_capacity,
    o.current_patients,
    (o.current_patients * 100.0 / t.max_capacity) AS Occupancy_Rate
FROM total_beds t
CROSS JOIN occupied_beds o;
-- </query>