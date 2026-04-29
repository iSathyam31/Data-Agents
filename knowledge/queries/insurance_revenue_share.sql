-- <query insurance_revenue_share>
-- <description>Analyzes paid revenue split between Insurance and Patient Out-Of-Pocket</description>
-- <query>
SELECT 
    SUM(b.Insurance_Covered) AS Total_Insurance_Paid,
    SUM(b.Patient_Owed) AS Total_Patient_Paid,
    (SUM(b.Insurance_Covered) / SUM(b.Total_Amount)) * 100 AS Insurance_Percentage
FROM healthcare.billing b
WHERE b.Status = 'Paid';
-- </query>