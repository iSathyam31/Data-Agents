-- <query abnormal_test_rates>
-- <description>Calculates the percentage of abnormal test results grouped by Test Type</description>
-- <query>
SELECT 
    lt.Test_Name,
    COUNT(*) AS Total_Tests,
    SUM(CASE WHEN tr.Is_Abnormal = TRUE THEN 1 ELSE 0 END) AS Abnormal_Count,
    (SUM(CASE WHEN tr.Is_Abnormal = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Abnormal_Percentage
FROM healthcare.test_results tr
JOIN healthcare.lab_tests lt ON tr.Test_ID = lt.Test_ID
GROUP BY lt.Test_Name
ORDER BY Abnormal_Percentage DESC;
-- </query>