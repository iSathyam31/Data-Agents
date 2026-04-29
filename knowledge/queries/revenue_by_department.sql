-- <query revenue_by_department>
-- <description>Calculates total collected revenue (Paid bills) grouped by department</description>
-- <query>
SELECT d.Name AS Department, SUM(b.Total_Amount) AS Total_Revenue
FROM healthcare.billing b
JOIN healthcare.admissions a ON b.Admission_ID = a.Admission_ID
JOIN healthcare.doctors doc ON a.Attending_Doctor_ID = doc.Doctor_ID
JOIN healthcare.departments d ON doc.Department_ID = d.Department_ID
WHERE b.Status = 'Paid'
GROUP BY d.Name
ORDER BY Total_Revenue DESC;
-- </query>