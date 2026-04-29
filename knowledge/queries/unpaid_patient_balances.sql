-- <query unpaid_patient_balances>
-- <description>Finds patients with the highest unpaid out-of-pocket balances</description>
-- <query>
SELECT p.First_Name, p.Last_Name, SUM(b.Patient_Owed) AS Total_Owed
FROM healthcare.billing b
JOIN healthcare.patients p ON b.Patient_ID = p.Patient_ID
WHERE b.Status != 'Paid'
GROUP BY p.First_Name, p.Last_Name
ORDER BY Total_Owed DESC
LIMIT 10;
-- </query>