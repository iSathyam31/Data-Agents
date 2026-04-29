-- <query upcoming_appointments>
-- <description>Lists appointments scheduled for the next 7 days</description>
-- <query>
SELECT p.First_Name AS Patient, d.Last_Name AS Doctor, a.Appointment_Date, a.Reason_For_Visit
FROM healthcare.appointments a
JOIN healthcare.patients p ON a.Patient_ID = p.Patient_ID
JOIN healthcare.doctors d ON a.Doctor_ID = d.Doctor_ID
WHERE a.Status = 'Scheduled' 
AND a.Appointment_Date BETWEEN CURRENT_DATE() AND DATEADD(day, 7, CURRENT_DATE())
ORDER BY a.Appointment_Date ASC;
-- </query>