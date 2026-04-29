-- <query active_admissions>
-- <description>Gets all currently admitted patients and their assigned room</description>
-- <query>
SELECT p.First_Name, p.Last_Name, a.Admission_Date, r.Room_Number, w.Ward_Name
FROM healthcare.admissions a
JOIN healthcare.patients p ON a.Patient_ID = p.Patient_ID
JOIN healthcare.rooms r ON a.Room_ID = r.Room_ID
JOIN healthcare.wards w ON r.Ward_ID = w.Ward_ID
WHERE a.Status = 'Admitted' AND a.Discharge_Date IS NULL;
-- </query>