USE ROLE ACCOUNTADMIN; -- Or whichever role owns the HOSPITAL_DB tables
USE DATABASE HOSPITAL_DB;
USE SCHEMA healthcare;

-- 1. Truncate existing data
TRUNCATE TABLE billing;
TRUNCATE TABLE test_results;
TRUNCATE TABLE lab_tests;
TRUNCATE TABLE prescriptions;
TRUNCATE TABLE medications;
TRUNCATE TABLE medical_records;
TRUNCATE TABLE appointments;
TRUNCATE TABLE admissions;
TRUNCATE TABLE rooms;
TRUNCATE TABLE wards;
TRUNCATE TABLE patient_insurance;
TRUNCATE TABLE insurance_providers;
TRUNCATE TABLE patients;
TRUNCATE TABLE doctors;
TRUNCATE TABLE departments;

-- 2. Insert Departments
INSERT INTO departments (Department_ID, Name, Location_Floor) VALUES 
(1, 'Cardiology', 2),
(2, 'Orthopedics', 3),
(3, 'Emergency', 1),
(4, 'Pediatrics', 4);

-- 3. Insert Doctors
INSERT INTO doctors (Doctor_ID, Department_ID, First_Name, Last_Name, Specialty, License_Number, Hire_Date) VALUES 
(1, 1, 'Sarah', 'Chen', 'Cardiologist', 'MD100234', '2018-05-15'),
(2, 2, 'Marcus', 'Johnson', 'Orthopedic Surgeon', 'MD100235', '2020-08-01'),
(3, 3, 'Emily', 'Rodriguez', 'ER Physician', 'MD100236', '2021-11-10'),
(4, 4, 'David', 'Kim', 'Pediatrician', 'MD100237', '2019-02-20');

-- Update Department Head Doctors
UPDATE departments SET Head_Doctor_ID = 1 WHERE Department_ID = 1;
UPDATE departments SET Head_Doctor_ID = 2 WHERE Department_ID = 2;
UPDATE departments SET Head_Doctor_ID = 3 WHERE Department_ID = 3;
UPDATE departments SET Head_Doctor_ID = 4 WHERE Department_ID = 4;

-- 4. Insert Patients
INSERT INTO patients (Patient_ID, First_Name, Last_Name, Date_Of_Birth, Gender, Blood_Group, Phone) VALUES 
(1, 'Michael', 'Scott', '1965-03-15', 'Male', 'O+', '555-0101'),
(2, 'Pam', 'Beesly', '1979-03-25', 'Female', 'A-', '555-0102'),
(3, 'Jim', 'Halpert', '1978-10-01', 'Male', 'B+', '555-0103'),
(4, 'Dwight', 'Schrute', '1970-01-20', 'Male', 'AB+', '555-0104'),
(5, 'Angela', 'Martin', '1971-06-25', 'Female', 'O-', '555-0105');

-- 5. Insert Insurance Providers
INSERT INTO insurance_providers (Provider_ID, Company_Name, Support_Phone, Support_Email) VALUES 
(1, 'Blue Cross Health', '1-800-555-0001', 'support@bluecross.com'),
(2, 'Aetna Secure', '1-800-555-0002', 'claims@aetna.com'),
(3, 'Medicare', '1-800-555-0003', 'support@medicare.gov');

-- 6. Insert Patient Insurance
INSERT INTO patient_insurance (Insurance_ID, Patient_ID, Provider_ID, Policy_Number, Coverage_Start, Coverage_End, Copay_Amount) VALUES 
(1, 1, 1, 'BC-99238', '2024-01-01', '2024-12-31', 40.00),
(2, 2, 2, 'AE-44211', '2024-01-01', '2024-12-31', 25.00),
(3, 4, 1, 'BC-99239', '2024-01-01', '2024-12-31', 40.00);

-- 7. Insert Wards
INSERT INTO wards (Ward_ID, Department_ID, Ward_Name, Ward_Type) VALUES 
(1, 1, 'Cardio ICU', 'ICU'),
(2, 2, 'Ortho Recovery', 'General'),
(3, 3, 'ER Trauma', 'Emergency'),
(4, 4, 'Peds General', 'General');

-- 8. Insert Rooms
INSERT INTO rooms (Room_ID, Ward_ID, Room_Number, Bed_Count, Is_Available, Daily_Rate) VALUES 
(1, 1, '101A', 1, TRUE, 1200.00),
(2, 1, '101B', 1, TRUE, 1200.00),
(3, 2, '201', 2, TRUE, 600.00),
(4, 2, '202', 2, TRUE, 600.00),
(5, 3, 'T1', 1, TRUE, 2000.00),
(6, 4, '401', 4, TRUE, 400.00);

-- 9. Insert Admissions (2 active, 1 discharged)
INSERT INTO admissions (Admission_ID, Patient_ID, Room_ID, Attending_Doctor_ID, Admission_Date, Discharge_Date, Admission_Reason, Status) VALUES 
(1, 1, 1, 1, DATEADD(day, -5, CURRENT_TIMESTAMP()), NULL, 'Heart palpitations', 'Admitted'),
(2, 4, 3, 2, DATEADD(day, -2, CURRENT_TIMESTAMP()), NULL, 'Broken leg', 'Admitted'),
(3, 5, 5, 3, DATEADD(day, -10, CURRENT_TIMESTAMP()), DATEADD(day, -9, CURRENT_TIMESTAMP()), 'Minor concussion', 'Discharged');

-- 10. Insert Appointments
INSERT INTO appointments (Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Status, Reason_For_Visit) VALUES 
(1, 2, 4, DATEADD(day, -15, CURRENT_TIMESTAMP()), 'Completed', 'Routine checkup'),
(2, 3, 2, DATEADD(day, -7, CURRENT_TIMESTAMP()), 'Completed', 'Knee pain evaluation'),
(3, 2, 4, DATEADD(day, 2, CURRENT_TIMESTAMP()), 'Scheduled', 'Follow-up'),
(4, 3, 2, DATEADD(day, 5, CURRENT_TIMESTAMP()), 'Scheduled', 'MRI review'),
(5, 5, 1, DATEADD(day, -1, CURRENT_TIMESTAMP()), 'No Show', 'Annual physical');

-- 11. Insert Medical Records
INSERT INTO medical_records (Record_ID, Patient_ID, Doctor_ID, Appointment_ID, Date_Recorded, Diagnosis, Symptoms, Treatment_Plan) VALUES 
(1, 1, 1, NULL, DATEADD(day, -5, CURRENT_TIMESTAMP()), 'Mild Arrhythmia', 'Shortness of breath', 'Observe in ICU'),
(2, 4, 2, NULL, DATEADD(day, -2, CURRENT_TIMESTAMP()), 'Tibia Fracture', 'Severe pain in leg', 'Surgery required'),
(3, 3, 2, 2, DATEADD(day, -7, CURRENT_TIMESTAMP()), 'Meniscus Tear', 'Knee swelling', 'Physical therapy');

-- 12. Insert Medications
INSERT INTO medications (Medication_ID, Name, Unit_Cost, Stock_Quantity) VALUES 
(1, 'Metoprolol (Beta Blocker)', 15.50, 500),
(2, 'Oxycodone (Pain Relief)', 25.00, 200),
(3, 'Ibuprofen (Anti-inflammatory)', 2.00, 5000),
(4, 'Amoxicillin (Antibiotic)', 8.50, 1000);

-- 13. Insert Prescriptions
INSERT INTO prescriptions (Prescription_ID, Medical_Record_ID, Medication_ID, Dosage, Frequency, Duration_Days) VALUES 
(1, 1, 1, '50mg', 'Twice daily', 30),
(2, 2, 2, '10mg', 'Every 6 hours', 7),
(3, 3, 3, '400mg', 'Every 8 hours', 14);

-- 14. Insert Lab Tests
INSERT INTO lab_tests (Test_ID, Test_Name, Cost, Normal_Range) VALUES 
(1, 'Complete Blood Count (CBC)', 55.00, 'Normal'),
(2, 'Basic Metabolic Panel (BMP)', 45.00, 'Normal'),
(3, 'Electrocardiogram (ECG)', 150.00, 'Normal Sinus Rhythm'),
(4, 'X-Ray (Leg)', 200.00, 'No fracture');

-- 15. Insert Test Results
INSERT INTO test_results (Result_ID, Patient_ID, Test_ID, Result_Value, Is_Abnormal) VALUES 
(1, 1, 3, 'Irregular rhythm detected', TRUE),
(2, 4, 4, 'Clear oblique fracture of tibia', TRUE),
(3, 3, 4, 'No fracture', FALSE),
(4, 5, 1, 'All normal limits', FALSE);

-- 16. Insert Billing
INSERT INTO billing (Bill_ID, Patient_ID, Admission_ID, Appointment_ID, Total_Amount, Insurance_Covered, Patient_Owed, Status) VALUES 
(1, 1, 1, NULL, 6000.00, 5500.00, 500.00, 'Unpaid'),
(2, 4, 2, NULL, 4500.00, 3600.00, 900.00, 'Partial'),
(3, 5, 3, NULL, 2000.00, 0.00, 2000.00, 'Paid'),
(4, 2, NULL, 1, 150.00, 125.00, 25.00, 'Paid'),
(5, 3, NULL, 2, 250.00, 0.00, 250.00, 'Unpaid');
