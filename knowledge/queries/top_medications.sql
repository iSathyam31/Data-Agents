-- <query top_medications>
-- <description>Identifies the most frequently prescribed medications</description>
-- <query>
SELECT m.Name, COUNT(p.Prescription_ID) AS Times_Prescribed
FROM healthcare.prescriptions p
JOIN healthcare.medications m ON p.Medication_ID = m.Medication_ID
GROUP BY m.Name
ORDER BY Times_Prescribed DESC
LIMIT 10;
-- </query>