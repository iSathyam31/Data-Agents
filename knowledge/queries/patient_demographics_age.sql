-- <query patient_demographics_age>
-- <description>Groups all patients into age brackets to see demographic spread</description>
-- <query>
SELECT 
    CASE 
        WHEN DATEDIFF(year, Date_Of_Birth, CURRENT_DATE()) < 18 THEN '0-17'
        WHEN DATEDIFF(year, Date_Of_Birth, CURRENT_DATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN DATEDIFF(year, Date_Of_Birth, CURRENT_DATE()) BETWEEN 36 AND 55 THEN '36-55'
        WHEN DATEDIFF(year, Date_Of_Birth, CURRENT_DATE()) BETWEEN 56 AND 75 THEN '56-75'
        ELSE '75+'
    END AS Age_Bracket,
    COUNT(Patient_ID) AS Patient_Count
FROM healthcare.patients
GROUP BY Age_Bracket
ORDER BY Age_Bracket;
-- </query>