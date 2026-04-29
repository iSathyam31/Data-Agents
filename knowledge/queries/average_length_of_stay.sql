-- <query average_length_of_stay>
-- <description>Calculates the average length of stay (LOS) in days per department</description>
-- <query>
SELECT d.Name AS Department, AVG(DATEDIFF(day, a.Admission_Date, COALESCE(a.Discharge_Date, CURRENT_DATE()))) AS avg_stay_days
FROM healthcare.admissions a
JOIN healthcare.doctors doc ON a.Attending_Doctor_ID = doc.Doctor_ID
JOIN healthcare.departments d ON doc.Department_ID = d.Department_ID
GROUP BY d.Name
ORDER BY avg_stay_days DESC;
-- </query>