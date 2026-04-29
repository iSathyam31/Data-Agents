-- 03_seed_data.sql
-- IMPORTANT: Run this script as the SYSADMIN role (or any role with WRITE access to 'healthcare' schema)

USE DATABASE HOSPITAL_DB;
USE SCHEMA healthcare;

-- ============================================================================
-- SNOWFLAKE NATIVE DATA GENERATION
-- This script uses Snowflake's incredibly fast TABLE(GENERATOR()) function 
-- to natively generate roughly ~250,000 rows of relational data in seconds.
-- ============================================================================

-- 1. Departments (10 records)
INSERT INTO Departments (Name, Location_Floor)
SELECT 
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 'Cardiology' WHEN 1 THEN 'Neurology' WHEN 2 THEN 'Orthopedics'
        WHEN 3 THEN 'Pediatrics' WHEN 4 THEN 'Oncology' WHEN 5 THEN 'Emergency'
        WHEN 6 THEN 'Internal Medicine' WHEN 7 THEN 'Surgery' WHEN 8 THEN 'Radiology'
        ELSE 'Psychiatry'
    END,
    UNIFORM(1, 10, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 10));

-- 2. Doctors (100 records)
INSERT INTO Doctors (Department_ID, First_Name, Last_Name, Specialty, License_Number, Hire_Date)
SELECT 
    UNIFORM(1, 10, RANDOM()), -- Random Department_ID (1-10)
    'DoctorFirst_' || SEQ4(),
    'DoctorLast_' || SEQ4(),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'General' WHEN 1 THEN 'Surgeon' WHEN 2 THEN 'Consultant' WHEN 3 THEN 'Specialist' ELSE 'Resident' END,
    'LIC-' || UUID_STRING(),
    DATEADD(day, -UNIFORM(100, 3000, RANDOM()), CURRENT_DATE())
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- 3. Patients (10,000 records)
INSERT INTO Patients (First_Name, Last_Name, Date_Of_Birth, Gender, Blood_Group, Phone)
SELECT 
    'PatientFirst_' || SEQ4(),
    'PatientLast_' || SEQ4(),
    DATEADD(day, -UNIFORM(1000, 30000, RANDOM()), CURRENT_DATE()),
    CASE MOD(SEQ4(), 2) WHEN 0 THEN 'Male' ELSE 'Female' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'A+' WHEN 1 THEN 'B+' WHEN 2 THEN 'O+' ELSE 'AB+' END,
    '555-' || LPAD(UNIFORM(1000, 9999, RANDOM())::VARCHAR, 4, '0')
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- 4. Insurance_Providers (10 records)
INSERT INTO Insurance_Providers (Company_Name)
SELECT 
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Aetna' WHEN 1 THEN 'Cigna' WHEN 2 THEN 'Blue Cross'
        WHEN 3 THEN 'UnitedHealth' ELSE 'Humana'
    END || ' ' || SEQ4()
FROM TABLE(GENERATOR(ROWCOUNT => 10));

-- 5. Patient_Insurance (8,000 records)
INSERT INTO Patient_Insurance (Patient_ID, Provider_ID, Policy_Number, Coverage_Start, Coverage_End, Copay_Amount)
SELECT 
    UNIFORM(1, 10000, RANDOM()), -- Random Patient
    UNIFORM(1, 10, RANDOM()),    -- Random Provider
    'POL-' || UUID_STRING(),
    DATEADD(day, -UNIFORM(100, 1000, RANDOM()), CURRENT_DATE()),
    DATEADD(day, UNIFORM(100, 1000, RANDOM()), CURRENT_DATE()),
    UNIFORM(10, 50, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 8000));

-- 6. Wards (30 records)
INSERT INTO Wards (Department_ID, Ward_Name, Ward_Type)
SELECT 
    UNIFORM(1, 10, RANDOM()),
    'Ward_' || SEQ4(),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'ICU' WHEN 1 THEN 'General' ELSE 'Maternity' END
FROM TABLE(GENERATOR(ROWCOUNT => 30));

-- 7. Rooms (300 records)
INSERT INTO Rooms (Ward_ID, Room_Number, Bed_Count, Daily_Rate)
SELECT 
    UNIFORM(1, 30, RANDOM()),
    'RM-' || SEQ4(),
    UNIFORM(1, 4, RANDOM()),
    UNIFORM(100, 1000, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 300));

-- 8. Appointments (50,000 records)
INSERT INTO Appointments (Patient_ID, Doctor_ID, Appointment_Date, Status, Reason_For_Visit)
SELECT 
    UNIFORM(1, 10000, RANDOM()),
    UNIFORM(1, 100, RANDOM()),
    DATEADD(hour, -UNIFORM(1, 10000, RANDOM()), CURRENT_TIMESTAMP()),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Scheduled' WHEN 1 THEN 'Completed' WHEN 2 THEN 'Cancelled' ELSE 'No Show' END,
    'Routine Checkup'
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- 9. Admissions (5,000 records)
INSERT INTO Admissions (Patient_ID, Room_ID, Attending_Doctor_ID, Admission_Date, Discharge_Date, Admission_Reason, Status)
SELECT 
    UNIFORM(1, 10000, RANDOM()),
    UNIFORM(1, 300, RANDOM()),
    UNIFORM(1, 100, RANDOM()),
    DATEADD(day, -UNIFORM(10, 1000, RANDOM()), CURRENT_TIMESTAMP()),
    DATEADD(day, -UNIFORM(1, 9, RANDOM()), CURRENT_TIMESTAMP()),
    'Observation',
    'Discharged'
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- 10. Medical_Records (40,000 records)
INSERT INTO Medical_Records (Patient_ID, Doctor_ID, Appointment_ID, Diagnosis, Symptoms, Treatment_Plan)
SELECT 
    UNIFORM(1, 10000, RANDOM()),
    UNIFORM(1, 100, RANDOM()),
    UNIFORM(1, 50000, RANDOM()),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Hypertension' WHEN 1 THEN 'Diabetes' WHEN 2 THEN 'Flu' WHEN 3 THEN 'Fracture' ELSE 'Migraine' END,
    'Various symptoms reported',
    'Rest and medication'
FROM TABLE(GENERATOR(ROWCOUNT => 40000));

-- 11. Medications (100 records)
INSERT INTO Medications (Name, Unit_Cost, Stock_Quantity)
SELECT 
    'Medication_' || SEQ4(),
    UNIFORM(5, 200, RANDOM()),
    UNIFORM(100, 5000, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- 12. Prescriptions (60,000 records)
INSERT INTO Prescriptions (Medical_Record_ID, Medication_ID, Dosage, Frequency, Duration_Days)
SELECT 
    UNIFORM(1, 40000, RANDOM()),
    UNIFORM(1, 100, RANDOM()),
    UNIFORM(1, 5, RANDOM()) || ' pills',
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Daily' WHEN 1 THEN 'Twice a day' ELSE 'Weekly' END,
    UNIFORM(5, 30, RANDOM())
FROM TABLE(GENERATOR(ROWCOUNT => 60000));

-- 13. Lab_Tests (50 records)
INSERT INTO Lab_Tests (Test_Name, Cost, Normal_Range)
SELECT 
    'LabTest_' || SEQ4(),
    UNIFORM(20, 500, RANDOM()),
    'Standard'
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- 14. Test_Results (30,000 records)
INSERT INTO Test_Results (Patient_ID, Doctor_ID, Test_ID, Result_Value, Is_Abnormal)
SELECT 
    UNIFORM(1, 10000, RANDOM()),
    UNIFORM(1, 100, RANDOM()),
    UNIFORM(1, 50, RANDOM()),
    UNIFORM(1, 100, RANDOM())::VARCHAR,
    CASE WHEN UNIFORM(1, 10, RANDOM()) > 8 THEN TRUE ELSE FALSE END
FROM TABLE(GENERATOR(ROWCOUNT => 30000));

-- 15. Billing (55,000 records)
INSERT INTO Billing (Patient_ID, Appointment_ID, Total_Amount, Patient_Owed, Status)
SELECT 
    UNIFORM(1, 10000, RANDOM()),
    UNIFORM(1, 50000, RANDOM()),
    UNIFORM(100, 5000, RANDOM()),
    UNIFORM(10, 500, RANDOM()),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Paid' WHEN 1 THEN 'Unpaid' ELSE 'Partial' END
FROM TABLE(GENERATOR(ROWCOUNT => 55000));
