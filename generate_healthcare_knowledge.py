import os
import json

TABLES = [
    {
        "table_name": "departments",
        "table_description": "Hospital departments with location and head doctor reference",
        "use_cases": ["Revenue by department", "Bed capacity per department"],
        "data_quality_notes": ["Head_Doctor_ID can be NULL if temporarily vacant."],
        "table_columns": [
            {"name": "Department_ID", "type": "INT", "description": "Primary key"},
            {"name": "Name", "type": "VARCHAR(100)", "description": "Department name (e.g., Cardiology)"},
            {"name": "Location_Floor", "type": "INT", "description": "Floor where department is located"},
            {"name": "Head_Doctor_ID", "type": "INT", "description": "Doctor ID leading the department"}
        ]
    },
    {
        "table_name": "doctors",
        "table_description": "Medical staff and their specialties",
        "use_cases": ["Doctor performance tracking", "Departmental staffing"],
        "data_quality_notes": ["Hire_Date is always set. Phone and Email can be NULL."],
        "table_columns": [
            {"name": "Doctor_ID", "type": "INT", "description": "Primary key"},
            {"name": "Department_ID", "type": "INT", "description": "Foreign key to departments"},
            {"name": "First_Name", "type": "VARCHAR(50)", "description": "Doctor's first name"},
            {"name": "Last_Name", "type": "VARCHAR(50)", "description": "Doctor's last name"},
            {"name": "Specialty", "type": "VARCHAR(100)", "description": "Medical specialty"},
            {"name": "License_Number", "type": "VARCHAR(50)", "description": "Unique medical license"},
            {"name": "Hire_Date", "type": "DATE", "description": "When doctor joined hospital"}
        ]
    },
    {
        "table_name": "patients",
        "table_description": "Patient demographics and emergency contacts",
        "use_cases": ["Patient cohort analysis", "Patient demographics overview"],
        "data_quality_notes": ["Date_Of_Birth is required. Blood_Group might be NULL."],
        "table_columns": [
            {"name": "Patient_ID", "type": "INT", "description": "Primary key"},
            {"name": "First_Name", "type": "VARCHAR(50)", "description": "Patient's first name"},
            {"name": "Last_Name", "type": "VARCHAR(50)", "description": "Patient's last name"},
            {"name": "Date_Of_Birth", "type": "DATE", "description": "Patient date of birth"},
            {"name": "Gender", "type": "VARCHAR(10)", "description": "Patient gender"},
            {"name": "Blood_Group", "type": "VARCHAR(5)", "description": "ABO blood group"},
            {"name": "Phone", "type": "VARCHAR(20)", "description": "Contact phone"}
        ]
    },
    {
        "table_name": "insurance_providers",
        "table_description": "Insurance companies that provide coverage to patients",
        "use_cases": ["Insurance network analysis"],
        "data_quality_notes": [],
        "table_columns": [
            {"name": "Provider_ID", "type": "INT", "description": "Primary key"},
            {"name": "Company_Name", "type": "VARCHAR(100)", "description": "Insurance company name"},
            {"name": "Support_Phone", "type": "VARCHAR(20)", "description": "Provider contact phone"},
            {"name": "Support_Email", "type": "VARCHAR(100)", "description": "Provider contact email"}
        ]
    },
    {
        "table_name": "patient_insurance",
        "table_description": "Mapping of patients to their insurance policies",
        "use_cases": ["Patient coverage verification", "Billing insurance estimation"],
        "data_quality_notes": ["Patients without insurance will not be in this table."],
        "table_columns": [
            {"name": "Insurance_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Provider_ID", "type": "INT", "description": "Foreign key to insurance_providers"},
            {"name": "Policy_Number", "type": "VARCHAR(100)", "description": "Unique policy identifier"},
            {"name": "Coverage_Start", "type": "DATE", "description": "Policy start date"},
            {"name": "Coverage_End", "type": "DATE", "description": "Policy expiration date"},
            {"name": "Copay_Amount", "type": "NUMBER(10,2)", "description": "Standard copay amount"}
        ]
    },
    {
        "table_name": "wards",
        "table_description": "Hospital wards or wings belonging to departments",
        "use_cases": ["Ward capacity tracking", "Departmental physical footprint"],
        "data_quality_notes": [],
        "table_columns": [
            {"name": "Ward_ID", "type": "INT", "description": "Primary key"},
            {"name": "Department_ID", "type": "INT", "description": "Foreign key to departments"},
            {"name": "Ward_Name", "type": "VARCHAR(50)", "description": "Name of the ward"},
            {"name": "Ward_Type", "type": "VARCHAR(50)", "description": "ICU, General, Maternity, etc."}
        ]
    },
    {
        "table_name": "rooms",
        "table_description": "Individual patient rooms within a ward",
        "use_cases": ["Bed availability", "Room rate analysis"],
        "data_quality_notes": ["Daily_Rate is the base price before procedures/medications."],
        "table_columns": [
            {"name": "Room_ID", "type": "INT", "description": "Primary key"},
            {"name": "Ward_ID", "type": "INT", "description": "Foreign key to wards"},
            {"name": "Room_Number", "type": "VARCHAR(20)", "description": "Physical room identifier"},
            {"name": "Bed_Count", "type": "INT", "description": "Number of beds in room"},
            {"name": "Is_Available", "type": "BOOLEAN", "description": "If room is active for admissions"},
            {"name": "Daily_Rate", "type": "NUMBER(10,2)", "description": "Cost per day"}
        ]
    },
    {
        "table_name": "admissions",
        "table_description": "Hospital stays for admitted patients",
        "use_cases": ["Bed occupancy rate", "Length of stay calculation"],
        "data_quality_notes": [
            "Discharge_Date is NULL if the patient is currently admitted.",
            "Status will be 'Admitted' if they are currently in the hospital."
        ],
        "table_columns": [
            {"name": "Admission_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Room_ID", "type": "INT", "description": "Foreign key to rooms"},
            {"name": "Attending_Doctor_ID", "type": "INT", "description": "Foreign key to doctors"},
            {"name": "Admission_Date", "type": "TIMESTAMP_NTZ", "description": "When patient was admitted"},
            {"name": "Discharge_Date", "type": "TIMESTAMP_NTZ", "description": "When patient left (NULL if still admitted)"},
            {"name": "Admission_Reason", "type": "TEXT", "description": "Why patient was admitted"},
            {"name": "Status", "type": "VARCHAR(20)", "description": "'Admitted', 'Discharged', or 'Transferred'"}
        ]
    },
    {
        "table_name": "appointments",
        "table_description": "Scheduled visits between patients and doctors",
        "use_cases": ["Doctor schedule utilization", "No-show rate tracking"],
        "data_quality_notes": ["Status can be 'Scheduled', 'Completed', 'Cancelled', 'No Show'."],
        "table_columns": [
            {"name": "Appointment_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Doctor_ID", "type": "INT", "description": "Foreign key to doctors"},
            {"name": "Appointment_Date", "type": "TIMESTAMP_NTZ", "description": "Scheduled time"},
            {"name": "Status", "type": "VARCHAR(20)", "description": "Appointment status"},
            {"name": "Reason_For_Visit", "type": "TEXT", "description": "Visit purpose"}
        ]
    },
    {
        "table_name": "medical_records",
        "table_description": "Clinical diagnosis and treatment notes",
        "use_cases": ["Diagnosis frequency", "Treatment efficacy"],
        "data_quality_notes": ["Appointment_ID can be NULL if the record was generated during an admission."],
        "table_columns": [
            {"name": "Record_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Doctor_ID", "type": "INT", "description": "Foreign key to doctors"},
            {"name": "Appointment_ID", "type": "INT", "description": "Foreign key to appointments"},
            {"name": "Date_Recorded", "type": "TIMESTAMP_NTZ", "description": "When the record was made"},
            {"name": "Diagnosis", "type": "TEXT", "description": "Clinical diagnosis"},
            {"name": "Symptoms", "type": "TEXT", "description": "Patient reported symptoms"},
            {"name": "Treatment_Plan", "type": "TEXT", "description": "Plan of action"}
        ]
    },
    {
        "table_name": "medications",
        "table_description": "Hospital pharmacy drug catalog",
        "use_cases": ["Inventory management", "Medication cost analysis"],
        "data_quality_notes": ["Unit_Cost is what the hospital paid. Stock_Quantity is current inventory."],
        "table_columns": [
            {"name": "Medication_ID", "type": "INT", "description": "Primary key"},
            {"name": "Name", "type": "VARCHAR(100)", "description": "Drug name"},
            {"name": "Unit_Cost", "type": "NUMBER(10,2)", "description": "Cost per unit"},
            {"name": "Stock_Quantity", "type": "INT", "description": "Current pharmacy stock"}
        ]
    },
    {
        "table_name": "prescriptions",
        "table_description": "Medications prescribed to patients",
        "use_cases": ["Most prescribed drugs", "Pharmacy demand prediction"],
        "data_quality_notes": ["Linked to Medical_Records, not directly to Patients."],
        "table_columns": [
            {"name": "Prescription_ID", "type": "INT", "description": "Primary key"},
            {"name": "Medical_Record_ID", "type": "INT", "description": "Foreign key to medical_records"},
            {"name": "Medication_ID", "type": "INT", "description": "Foreign key to medications"},
            {"name": "Dosage", "type": "VARCHAR(50)", "description": "Dosage instructions"},
            {"name": "Frequency", "type": "VARCHAR(50)", "description": "How often to take"},
            {"name": "Duration_Days", "type": "INT", "description": "How many days to take"}
        ]
    },
    {
        "table_name": "lab_tests",
        "table_description": "Catalog of available laboratory tests",
        "use_cases": ["Lab revenue", "Most frequent tests"],
        "data_quality_notes": [],
        "table_columns": [
            {"name": "Test_ID", "type": "INT", "description": "Primary key"},
            {"name": "Test_Name", "type": "VARCHAR(100)", "description": "Name of the test (e.g., Complete Blood Count)"},
            {"name": "Cost", "type": "NUMBER(10,2)", "description": "Base cost of test"},
            {"name": "Normal_Range", "type": "VARCHAR(100)", "description": "Expected normal outcome range"}
        ]
    },
    {
        "table_name": "test_results",
        "table_description": "Outcomes of lab tests performed on patients",
        "use_cases": ["Abnormality rates", "Test volume tracking"],
        "data_quality_notes": ["Is_Abnormal is a BOOLEAN flag for quick filtering."],
        "table_columns": [
            {"name": "Result_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Test_ID", "type": "INT", "description": "Foreign key to lab_tests"},
            {"name": "Result_Value", "type": "VARCHAR(100)", "description": "Recorded result"},
            {"name": "Is_Abnormal", "type": "BOOLEAN", "description": "True if result is out of normal range"}
        ]
    },
    {
        "table_name": "billing",
        "table_description": "Invoices and financial tracking for patients",
        "use_cases": ["Revenue tracking", "Unpaid balance tracking"],
        "data_quality_notes": ["Total_Amount = Insurance_Covered + Patient_Owed. Status 'Unpaid' means revenue is not yet realized."],
        "table_columns": [
            {"name": "Bill_ID", "type": "INT", "description": "Primary key"},
            {"name": "Patient_ID", "type": "INT", "description": "Foreign key to patients"},
            {"name": "Admission_ID", "type": "INT", "description": "Linked admission (NULL if outpatient)"},
            {"name": "Appointment_ID", "type": "INT", "description": "Linked appointment (NULL if admission billing)"},
            {"name": "Total_Amount", "type": "NUMBER(10,2)", "description": "Total cost of service"},
            {"name": "Insurance_Covered", "type": "NUMBER(10,2)", "description": "Amount covered by insurance"},
            {"name": "Patient_Owed", "type": "NUMBER(10,2)", "description": "Amount owed by patient out-of-pocket"},
            {"name": "Status", "type": "VARCHAR(20)", "description": "'Unpaid', 'Partial', 'Paid'"}
        ]
    }
]

QUERIES = [
    {
        "filename": "active_admissions.sql",
        "name": "active_admissions",
        "description": "Gets all currently admitted patients and their assigned room",
        "sql": """SELECT p.First_Name, p.Last_Name, a.Admission_Date, r.Room_Number, w.Ward_Name
FROM healthcare.admissions a
JOIN healthcare.patients p ON a.Patient_ID = p.Patient_ID
JOIN healthcare.rooms r ON a.Room_ID = r.Room_ID
JOIN healthcare.wards w ON r.Ward_ID = w.Ward_ID
WHERE a.Status = 'Admitted' AND a.Discharge_Date IS NULL;"""
    },
    {
        "filename": "average_length_of_stay.sql",
        "name": "average_length_of_stay",
        "description": "Calculates the average length of stay (LOS) in days per department",
        "sql": """SELECT d.Name AS Department, AVG(DATEDIFF(day, a.Admission_Date, COALESCE(a.Discharge_Date, CURRENT_DATE()))) AS avg_stay_days
FROM healthcare.admissions a
JOIN healthcare.doctors doc ON a.Attending_Doctor_ID = doc.Doctor_ID
JOIN healthcare.departments d ON doc.Department_ID = d.Department_ID
GROUP BY d.Name
ORDER BY avg_stay_days DESC;"""
    },
    {
        "filename": "revenue_by_department.sql",
        "name": "revenue_by_department",
        "description": "Calculates total collected revenue (Paid bills) grouped by department",
        "sql": """SELECT d.Name AS Department, SUM(b.Total_Amount) AS Total_Revenue
FROM healthcare.billing b
JOIN healthcare.admissions a ON b.Admission_ID = a.Admission_ID
JOIN healthcare.doctors doc ON a.Attending_Doctor_ID = doc.Doctor_ID
JOIN healthcare.departments d ON doc.Department_ID = d.Department_ID
WHERE b.Status = 'Paid'
GROUP BY d.Name
ORDER BY Total_Revenue DESC;"""
    },
    {
        "filename": "top_medications.sql",
        "name": "top_medications",
        "description": "Identifies the most frequently prescribed medications",
        "sql": """SELECT m.Name, COUNT(p.Prescription_ID) AS Times_Prescribed
FROM healthcare.prescriptions p
JOIN healthcare.medications m ON p.Medication_ID = m.Medication_ID
GROUP BY m.Name
ORDER BY Times_Prescribed DESC
LIMIT 10;"""
    },
    {
        "filename": "unpaid_patient_balances.sql",
        "name": "unpaid_patient_balances",
        "description": "Finds patients with the highest unpaid out-of-pocket balances",
        "sql": """SELECT p.First_Name, p.Last_Name, SUM(b.Patient_Owed) AS Total_Owed
FROM healthcare.billing b
JOIN healthcare.patients p ON b.Patient_ID = p.Patient_ID
WHERE b.Status != 'Paid'
GROUP BY p.First_Name, p.Last_Name
ORDER BY Total_Owed DESC
LIMIT 10;"""
    },
    {
        "filename": "upcoming_appointments.sql",
        "name": "upcoming_appointments",
        "description": "Lists appointments scheduled for the next 7 days",
        "sql": """SELECT p.First_Name AS Patient, d.Last_Name AS Doctor, a.Appointment_Date, a.Reason_For_Visit
FROM healthcare.appointments a
JOIN healthcare.patients p ON a.Patient_ID = p.Patient_ID
JOIN healthcare.doctors d ON a.Doctor_ID = d.Doctor_ID
WHERE a.Status = 'Scheduled' 
AND a.Appointment_Date BETWEEN CURRENT_DATE() AND DATEADD(day, 7, CURRENT_DATE())
ORDER BY a.Appointment_Date ASC;"""
    },
    {
        "filename": "insurance_revenue_share.sql",
        "name": "insurance_revenue_share",
        "description": "Analyzes paid revenue split between Insurance and Patient Out-Of-Pocket",
        "sql": """SELECT 
    SUM(b.Insurance_Covered) AS Total_Insurance_Paid,
    SUM(b.Patient_Owed) AS Total_Patient_Paid,
    (SUM(b.Insurance_Covered) / SUM(b.Total_Amount)) * 100 AS Insurance_Percentage
FROM healthcare.billing b
WHERE b.Status = 'Paid';"""
    },
    {
        "filename": "abnormal_test_rates.sql",
        "name": "abnormal_test_rates",
        "description": "Calculates the percentage of abnormal test results grouped by Test Type",
        "sql": """SELECT 
    lt.Test_Name,
    COUNT(*) AS Total_Tests,
    SUM(CASE WHEN tr.Is_Abnormal = TRUE THEN 1 ELSE 0 END) AS Abnormal_Count,
    (SUM(CASE WHEN tr.Is_Abnormal = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Abnormal_Percentage
FROM healthcare.test_results tr
JOIN healthcare.lab_tests lt ON tr.Test_ID = lt.Test_ID
GROUP BY lt.Test_Name
ORDER BY Abnormal_Percentage DESC;"""
    },
    {
        "filename": "bed_occupancy_rate.sql",
        "name": "bed_occupancy_rate",
        "description": "Calculates the current bed occupancy rate across the entire hospital",
        "sql": """WITH total_beds AS (
    SELECT SUM(Bed_Count) AS max_capacity FROM healthcare.rooms WHERE Is_Available = TRUE
),
occupied_beds AS (
    SELECT COUNT(Admission_ID) AS current_patients FROM healthcare.admissions WHERE Status = 'Admitted'
)
SELECT 
    t.max_capacity,
    o.current_patients,
    (o.current_patients * 100.0 / t.max_capacity) AS Occupancy_Rate
FROM total_beds t
CROSS JOIN occupied_beds o;"""
    },
    {
        "filename": "patient_demographics_age.sql",
        "name": "patient_demographics_age",
        "description": "Groups all patients into age brackets to see demographic spread",
        "sql": """SELECT 
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
ORDER BY Age_Bracket;"""
    }
]

BUSINESS_RULES = {
    "metrics": [
        {
            "name": "Length of Stay (LOS)",
            "definition": "The number of days a patient was in the hospital.",
            "calculation": "DATEDIFF(day, Admission_Date, COALESCE(Discharge_Date, CURRENT_DATE()))"
        },
        {
            "name": "Recognized Revenue",
            "definition": "Only bills that have been marked as 'Paid' are considered realized revenue.",
            "calculation": "SUM(Total_Amount) WHERE Status = 'Paid'"
        },
        {
            "name": "Bed Occupancy Rate",
            "definition": "The ratio of currently admitted patients to the total number of available beds across all rooms.",
            "calculation": "COUNT(Admitted Patients) / SUM(Bed_Count)"
        },
        {
            "name": "Patient Age",
            "definition": "Calculated dynamically using the Date_Of_Birth relative to the current date.",
            "calculation": "DATEDIFF(year, Date_Of_Birth, CURRENT_DATE())"
        }
    ],
    "common_gotchas": [
        {
            "issue": "Active Admissions",
            "solution": "Always filter using Status = 'Admitted' AND Discharge_Date IS NULL to find current patients."
        },
        {
            "issue": "Billing Totals",
            "solution": "Total_Amount is the sum of Insurance_Covered and Patient_Owed. To find outstanding debt, look at Patient_Owed where Status != 'Paid'."
        },
        {
            "issue": "Test Results",
            "solution": "Use the Is_Abnormal BOOLEAN column to quickly find problematic lab results instead of parsing the Result_Value string."
        },
        {
            "issue": "Inpatient vs Outpatient",
            "solution": "Outpatients have an Admission_ID that is NULL in the Billing and Appointments tables. Inpatients have an Admission_ID that is NOT NULL."
        }
    ]
}

def main():
    os.makedirs('knowledge/tables', exist_ok=True)
    os.makedirs('knowledge/queries', exist_ok=True)
    os.makedirs('knowledge/business', exist_ok=True)
    
    # Tables
    for t in TABLES:
        with open(f"knowledge/tables/{t['table_name']}.json", "w") as f:
            json.dump(t, f, indent=4)
            
    # Queries
    for q in QUERIES:
        content = f"-- <query {q['name']}>\n-- <description>{q['description']}</description>\n-- <query>\n{q['sql']}\n-- </query>"
        with open(f"knowledge/queries/{q['filename']}", "w") as f:
            f.write(content)
            
    # Business Rules
    with open("knowledge/business/healthcare_rules.json", "w") as f:
        json.dump(BUSINESS_RULES, f, indent=4)
        
    print("Generated all 15 healthcare knowledge files with advanced queries and rules!")

if __name__ == '__main__':
    main()
