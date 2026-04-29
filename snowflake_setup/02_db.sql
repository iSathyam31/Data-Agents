-- 02_db.sql
-- IMPORTANT: Run this script as the SYSADMIN role

-- 1. Create Database and Warehouse
CREATE DATABASE IF NOT EXISTS HOSPITAL_DB;
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH WITH WAREHOUSE_SIZE='X-SMALL';

USE DATABASE HOSPITAL_DB;

-- 2. Create Schemas
-- 'healthcare' will hold the raw source data
CREATE SCHEMA IF NOT EXISTS healthcare;
-- 'dash' will hold the views/tables created autonomously by the Engineer agent
CREATE SCHEMA IF NOT EXISTS dash;

-- 3. Grant privileges to the roles
-- Engineer can do anything in 'dash' and read from 'healthcare'
GRANT USAGE ON DATABASE HOSPITAL_DB TO ROLE dash_engineer_role;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE dash_engineer_role;
GRANT USAGE ON SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_engineer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_engineer_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_engineer_role;

GRANT ALL PRIVILEGES ON SCHEMA HOSPITAL_DB.dash TO ROLE dash_engineer_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA HOSPITAL_DB.dash TO ROLE dash_engineer_role;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA HOSPITAL_DB.dash TO ROLE dash_engineer_role;

-- Analyst can only read from 'healthcare' and 'dash'
GRANT USAGE ON DATABASE HOSPITAL_DB TO ROLE dash_analyst_role;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE dash_analyst_role;

GRANT USAGE ON SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_analyst_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOSPITAL_DB.healthcare TO ROLE dash_analyst_role;

GRANT USAGE ON SCHEMA HOSPITAL_DB.dash TO ROLE dash_analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA HOSPITAL_DB.dash TO ROLE dash_analyst_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOSPITAL_DB.dash TO ROLE dash_analyst_role;

-- 4. Create Tables in the 'healthcare' schema (Comprehensive 15-Table Schema)
USE SCHEMA healthcare;

-- 1. Departments
CREATE OR REPLACE TABLE Departments (
    Department_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Location_Floor INT,
    Head_Doctor_ID INT -- Will be updated after Doctors table is populated
);

-- 2. Doctors
CREATE OR REPLACE TABLE Doctors (
    Doctor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Department_ID INT NOT NULL FOREIGN KEY REFERENCES Departments(Department_ID),
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Specialty VARCHAR(100) NOT NULL,
    License_Number VARCHAR(50) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Hire_Date DATE NOT NULL
);

-- 3. Patients
CREATE OR REPLACE TABLE Patients (
    Patient_ID INT IDENTITY(1,1) PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    Gender VARCHAR(10),
    Blood_Group VARCHAR(5),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(255),
    Emergency_Contact_Name VARCHAR(100),
    Emergency_Contact_Phone VARCHAR(20)
);

-- 4. Insurance_Providers
CREATE OR REPLACE TABLE Insurance_Providers (
    Provider_ID INT IDENTITY(1,1) PRIMARY KEY,
    Company_Name VARCHAR(100) NOT NULL,
    Support_Phone VARCHAR(20),
    Support_Email VARCHAR(100),
    Billing_Address VARCHAR(255)
);

-- 5. Patient_Insurance
CREATE OR REPLACE TABLE Patient_Insurance (
    Insurance_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Provider_ID INT NOT NULL FOREIGN KEY REFERENCES Insurance_Providers(Provider_ID),
    Policy_Number VARCHAR(100) NOT NULL UNIQUE,
    Coverage_Start DATE NOT NULL,
    Coverage_End DATE NOT NULL,
    Copay_Amount NUMBER(10,2) DEFAULT 0.00
);

-- 6. Wards
CREATE OR REPLACE TABLE Wards (
    Ward_ID INT IDENTITY(1,1) PRIMARY KEY,
    Department_ID INT NOT NULL FOREIGN KEY REFERENCES Departments(Department_ID),
    Ward_Name VARCHAR(50) NOT NULL,
    Ward_Type VARCHAR(50) -- e.g., 'ICU', 'General', 'Maternity'
);

-- 7. Rooms
CREATE OR REPLACE TABLE Rooms (
    Room_ID INT IDENTITY(1,1) PRIMARY KEY,
    Ward_ID INT NOT NULL FOREIGN KEY REFERENCES Wards(Ward_ID),
    Room_Number VARCHAR(20) NOT NULL,
    Bed_Count INT NOT NULL DEFAULT 1,
    Is_Available BOOLEAN DEFAULT TRUE,
    Daily_Rate NUMBER(10,2) NOT NULL
);

-- 8. Admissions
CREATE OR REPLACE TABLE Admissions (
    Admission_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Room_ID INT NOT NULL FOREIGN KEY REFERENCES Rooms(Room_ID),
    Attending_Doctor_ID INT NOT NULL FOREIGN KEY REFERENCES Doctors(Doctor_ID),
    Admission_Date TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    Discharge_Date TIMESTAMP_NTZ,
    Admission_Reason TEXT NOT NULL,
    Status VARCHAR(20) DEFAULT 'Admitted' -- 'Admitted', 'Discharged', 'Transferred'
);

-- 9. Appointments
CREATE OR REPLACE TABLE Appointments (
    Appointment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Doctor_ID INT NOT NULL FOREIGN KEY REFERENCES Doctors(Doctor_ID),
    Appointment_Date TIMESTAMP_NTZ NOT NULL,
    Status VARCHAR(20) DEFAULT 'Scheduled', -- 'Scheduled', 'Completed', 'Cancelled', 'No Show'
    Reason_For_Visit TEXT,
    Notes TEXT
);

-- 10. Medical_Records
CREATE OR REPLACE TABLE Medical_Records (
    Record_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Doctor_ID INT NOT NULL FOREIGN KEY REFERENCES Doctors(Doctor_ID),
    Appointment_ID INT FOREIGN KEY REFERENCES Appointments(Appointment_ID),
    Date_Recorded TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    Diagnosis TEXT NOT NULL,
    Symptoms TEXT,
    Treatment_Plan TEXT
);

-- 11. Medications
CREATE OR REPLACE TABLE Medications (
    Medication_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Brand VARCHAR(100),
    Description TEXT,
    Unit_Cost NUMBER(10,2) NOT NULL,
    Stock_Quantity INT NOT NULL DEFAULT 0
);

-- 12. Prescriptions
CREATE OR REPLACE TABLE Prescriptions (
    Prescription_ID INT IDENTITY(1,1) PRIMARY KEY,
    Medical_Record_ID INT NOT NULL FOREIGN KEY REFERENCES Medical_Records(Record_ID),
    Medication_ID INT NOT NULL FOREIGN KEY REFERENCES Medications(Medication_ID),
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    Duration_Days INT NOT NULL,
    Prescription_Date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 13. Lab_Tests
CREATE OR REPLACE TABLE Lab_Tests (
    Test_ID INT IDENTITY(1,1) PRIMARY KEY,
    Test_Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Cost NUMBER(10,2) NOT NULL,
    Normal_Range VARCHAR(100)
);

-- 14. Test_Results
CREATE OR REPLACE TABLE Test_Results (
    Result_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Doctor_ID INT NOT NULL FOREIGN KEY REFERENCES Doctors(Doctor_ID),
    Test_ID INT NOT NULL FOREIGN KEY REFERENCES Lab_Tests(Test_ID),
    Test_Date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    Result_Value VARCHAR(100) NOT NULL,
    Is_Abnormal BOOLEAN DEFAULT FALSE,
    Notes TEXT
);

-- 15. Billing
CREATE OR REPLACE TABLE Billing (
    Bill_ID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_ID INT NOT NULL FOREIGN KEY REFERENCES Patients(Patient_ID),
    Admission_ID INT FOREIGN KEY REFERENCES Admissions(Admission_ID),
    Appointment_ID INT FOREIGN KEY REFERENCES Appointments(Appointment_ID),
    Total_Amount NUMBER(10,2) NOT NULL,
    Insurance_Covered NUMBER(10,2) DEFAULT 0.00,
    Patient_Owed NUMBER(10,2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Unpaid', -- 'Unpaid', 'Partial', 'Paid'
    Billing_Date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    Due_Date TIMESTAMP_NTZ
);
