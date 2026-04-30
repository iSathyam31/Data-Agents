-- =============================================================================
-- 03_seed_large.sql  —  Extensive seed data for HOSPITAL_DB
-- Run as ACCOUNTADMIN (or the role that owns the healthcare schema tables)
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE HOSPITAL_DB;
USE SCHEMA healthcare;

-- =============================================================================
-- 0. TRUNCATE (reverse FK order)
-- =============================================================================
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


-- =============================================================================
-- 1. DEPARTMENTS  (10 rows)
-- =============================================================================
INSERT INTO departments (Department_ID, Name, Location_Floor) VALUES
( 1, 'Cardiology',          2),
( 2, 'Orthopedics',         3),
( 3, 'Emergency',           1),
( 4, 'Pediatrics',          4),
( 5, 'Neurology',           5),
( 6, 'Oncology',            6),
( 7, 'Radiology',           1),
( 8, 'General Surgery',     2),
( 9, 'Obstetrics & Gynecology', 4),
(10, 'Dermatology',         3);


-- =============================================================================
-- 2. DOCTORS  (30 rows)
-- =============================================================================
INSERT INTO doctors (Doctor_ID, Department_ID, First_Name, Last_Name, Specialty, License_Number, Phone, Email, Hire_Date) VALUES
-- Cardiology (Dept 1)
( 1,  1, 'Sarah',    'Chen',        'Cardiologist',              'MD100234', '555-1001', 'schen@hospital.com',       '2018-05-15'),
( 2,  1, 'Robert',   'Patel',       'Interventional Cardiologist','MD100235', '555-1002', 'rpatel@hospital.com',      '2017-03-10'),
( 3,  1, 'Olivia',   'Nguyen',      'Electrophysiologist',       'MD100236', '555-1003', 'onguyen@hospital.com',     '2020-07-22'),
-- Orthopedics (Dept 2)
( 4,  2, 'Marcus',   'Johnson',     'Orthopedic Surgeon',        'MD100237', '555-1004', 'mjohnson@hospital.com',    '2020-08-01'),
( 5,  2, 'Priya',    'Sharma',      'Sports Medicine Specialist','MD100238', '555-1005', 'psharma@hospital.com',     '2019-06-15'),
-- Emergency (Dept 3)
( 6,  3, 'Emily',    'Rodriguez',   'ER Physician',              'MD100239', '555-1006', 'erodriguez@hospital.com',  '2021-11-10'),
( 7,  3, 'James',    'O\'Brien',    'Trauma Surgeon',            'MD100240', '555-1007', 'jobrien@hospital.com',     '2016-09-05'),
-- Pediatrics (Dept 4)
( 8,  4, 'David',    'Kim',         'Pediatrician',              'MD100241', '555-1008', 'dkim@hospital.com',        '2019-02-20'),
( 9,  4, 'Linda',    'Foster',      'Pediatric Cardiologist',    'MD100242', '555-1009', 'lfoster@hospital.com',     '2022-01-15'),
-- Neurology (Dept 5)
(10,  5, 'Alan',     'Wright',      'Neurologist',               'MD100243', '555-1010', 'awright@hospital.com',     '2015-04-18'),
(11,  5, 'Mei',      'Zhang',       'Neuro-oncologist',          'MD100244', '555-1011', 'mzhang@hospital.com',      '2018-09-30'),
-- Oncology (Dept 6)
(12,  6, 'Patricia', 'Walsh',       'Medical Oncologist',        'MD100245', '555-1012', 'pwalsh@hospital.com',      '2014-11-12'),
(13,  6, 'Carlos',   'Mendez',      'Surgical Oncologist',       'MD100246', '555-1013', 'cmendez@hospital.com',     '2017-05-28'),
(14,  6, 'Hana',     'Yoshida',     'Radiation Oncologist',      'MD100247', '555-1014', 'hyoshida@hospital.com',    '2019-10-07'),
-- Radiology (Dept 7)
(15,  7, 'Thomas',   'Baker',       'Radiologist',               'MD100248', '555-1015', 'tbaker@hospital.com',      '2016-06-20'),
(16,  7, 'Susan',    'Lee',         'Interventional Radiologist','MD100249', '555-1016', 'slee@hospital.com',        '2021-03-14'),
-- General Surgery (Dept 8)
(17,  8, 'George',   'Murphy',      'General Surgeon',           'MD100250', '555-1017', 'gmurphy@hospital.com',     '2013-08-25'),
(18,  8, 'Anita',    'Rao',         'Laparoscopic Surgeon',      'MD100251', '555-1018', 'arao@hospital.com',        '2020-02-11'),
-- OB/GYN (Dept 9)
(19,  9, 'Rebecca',  'Stone',       'Obstetrician',              'MD100252', '555-1019', 'rstone@hospital.com',      '2018-12-01'),
(20,  9, 'Fatima',   'Hassan',      'Gynecologist',              'MD100253', '555-1020', 'fhassan@hospital.com',     '2022-06-18'),
-- Dermatology (Dept 10)
(21, 10, 'Nathan',   'Brooks',      'Dermatologist',             'MD100254', '555-1021', 'nbrooks@hospital.com',     '2017-07-09'),
(22, 10, 'Claire',   'Dubois',      'Cosmetic Dermatologist',    'MD100255', '555-1022', 'cdubois@hospital.com',     '2023-01-30'),
-- Extra doctors for busy departments
(23,  1, 'Raj',      'Kapoor',      'Cardiologist',              'MD100256', '555-1023', 'rkapoor@hospital.com',     '2021-04-15'),
(24,  3, 'Serena',   'Williams',    'ER Physician',              'MD100257', '555-1024', 'swilliams@hospital.com',   '2022-09-01'),
(25,  5, 'Henry',    'Clarke',      'Neurologist',               'MD100258', '555-1025', 'hclarke@hospital.com',     '2020-03-22'),
(26,  8, 'Diana',    'Prince',      'General Surgeon',           'MD100259', '555-1026', 'dprince@hospital.com',     '2019-11-05'),
(27,  2, 'Kenji',    'Tanaka',      'Joint Replacement Specialist','MD100260','555-1027', 'ktanaka@hospital.com',     '2021-07-14'),
(28,  4, 'Sofia',    'Perez',       'Neonatologist',             'MD100261', '555-1028', 'sperez@hospital.com',      '2018-08-30'),
(29,  6, 'Victor',   'Okonkwo',     'Hematologist',              'MD100262', '555-1029', 'vokonkwo@hospital.com',    '2016-02-19'),
(30,  9, 'Grace',    'Liu',         'Maternal-Fetal Specialist', 'MD100263', '555-1030', 'gliu@hospital.com',        '2020-10-12');


-- =============================================================================
-- 2b. UPDATE DEPARTMENT HEADS
-- =============================================================================
UPDATE departments SET Head_Doctor_ID =  1 WHERE Department_ID =  1;
UPDATE departments SET Head_Doctor_ID =  4 WHERE Department_ID =  2;
UPDATE departments SET Head_Doctor_ID =  6 WHERE Department_ID =  3;
UPDATE departments SET Head_Doctor_ID =  8 WHERE Department_ID =  4;
UPDATE departments SET Head_Doctor_ID = 10 WHERE Department_ID =  5;
UPDATE departments SET Head_Doctor_ID = 12 WHERE Department_ID =  6;
UPDATE departments SET Head_Doctor_ID = 15 WHERE Department_ID =  7;
UPDATE departments SET Head_Doctor_ID = 17 WHERE Department_ID =  8;
UPDATE departments SET Head_Doctor_ID = 19 WHERE Department_ID =  9;
UPDATE departments SET Head_Doctor_ID = 21 WHERE Department_ID = 10;


-- =============================================================================
-- 3. PATIENTS  (60 rows)
-- =============================================================================
INSERT INTO patients (Patient_ID, First_Name, Last_Name, Date_Of_Birth, Gender, Blood_Group, Phone, Email, Address, Emergency_Contact_Name, Emergency_Contact_Phone) VALUES
( 1, 'Michael',   'Scott',       '1965-03-15', 'Male',   'O+',  '555-0101', 'mscott@email.com',    '123 Maple St, Scranton PA',        'Dwight Schrute',    '555-0104'),
( 2, 'Pam',       'Beesly',      '1979-03-25', 'Female', 'A-',  '555-0102', 'pbeesly@email.com',   '456 Oak Ave, Scranton PA',         'Jim Halpert',       '555-0103'),
( 3, 'Jim',       'Halpert',     '1978-10-01', 'Male',   'B+',  '555-0103', 'jhalpert@email.com',  '456 Oak Ave, Scranton PA',         'Pam Beesly',        '555-0102'),
( 4, 'Dwight',    'Schrute',     '1970-01-20', 'Male',   'AB+', '555-0104', 'dschrute@email.com',  '1782 Schrute Farms Rd, Honesdale', 'Mose Schrute',      '555-0180'),
( 5, 'Angela',    'Martin',      '1971-06-25', 'Female', 'O-',  '555-0105', 'amartin@email.com',   '789 Pine Rd, Scranton PA',         'Oscar Martinez',    '555-0106'),
( 6, 'Oscar',     'Martinez',    '1975-11-10', 'Male',   'A+',  '555-0106', 'omartinez@email.com', '321 Elm St, Scranton PA',          'Angela Martin',     '555-0105'),
( 7, 'Kevin',     'Malone',      '1973-06-01', 'Male',   'B-',  '555-0107', 'kmalone@email.com',   '654 Birch Ln, Scranton PA',        'Stanley Hudson',    '555-0108'),
( 8, 'Stanley',   'Hudson',      '1958-02-19', 'Male',   'AB-', '555-0108', 'shudson@email.com',   '987 Cedar Blvd, Scranton PA',      'Phyllis Vance',     '555-0109'),
( 9, 'Phyllis',   'Vance',       '1956-07-04', 'Female', 'O+',  '555-0109', 'pvance@email.com',    '159 Walnut Dr, Scranton PA',       'Bob Vance',         '555-0181'),
(10, 'Meredith',  'Palmer',      '1967-04-12', 'Female', 'A+',  '555-0110', 'mpalmer@email.com',   '753 Spruce Ct, Scranton PA',       'Jake Palmer',       '555-0182'),
(11, 'Creed',     'Bratton',     '1940-01-01', 'Male',   'B+',  '555-0111', 'cbratton@email.com',  '852 Unknown St, Scranton PA',      'Unknown',           '555-0183'),
(12, 'Toby',      'Flenderson',  '1975-08-22', 'Male',   'O-',  '555-0112', 'tflenderson@email.com','246 Magnolia Ave, Scranton PA',   'HR Dept',           '555-0184'),
(13, 'Ryan',      'Howard',      '1983-05-17', 'Male',   'A-',  '555-0113', 'rhoward@email.com',   '369 Cypress Rd, Scranton PA',      'Kelly Kapoor',      '555-0114'),
(14, 'Kelly',     'Kapoor',      '1985-02-05', 'Female', 'B+',  '555-0114', 'kkapoor@email.com',   '741 Willow St, Scranton PA',       'Ryan Howard',       '555-0113'),
(15, 'Andy',      'Bernard',     '1973-12-22', 'Male',   'A+',  '555-0115', 'abernard@email.com',  '258 Sycamore Ave, Scranton PA',    'Erin Hannon',       '555-0116'),
(16, 'Erin',      'Hannon',      '1986-05-01', 'Female', 'O+',  '555-0116', 'ehannon@email.com',   '147 Poplar Blvd, Scranton PA',     'Andy Bernard',      '555-0115'),
(17, 'Gabe',      'Lewis',       '1980-09-30', 'Male',   'AB+', '555-0117', 'glewis@email.com',    '963 Chestnut Dr, Scranton PA',     'Jo Bennett',        '555-0185'),
(18, 'Jan',       'Levinson',    '1966-01-08', 'Female', 'B-',  '555-0118', 'jlevinson@email.com', '654 Hickory Ln, Scranton PA',      'Michael Scott',     '555-0101'),
(19, 'Roy',       'Anderson',    '1975-12-10', 'Male',   'O+',  '555-0119', 'randerson@email.com', '321 Aspen St, Scranton PA',        'Darryl Philbin',    '555-0120'),
(20, 'Darryl',    'Philbin',     '1971-04-14', 'Male',   'A+',  '555-0120', 'dphilbin@email.com',  '456 Redwood Ave, Scranton PA',     'Madge Madsen',      '555-0186'),
(21, 'Karen',     'Filippelli',  '1980-07-25', 'Female', 'A-',  '555-0121', 'kfilippelli@email.com','789 Juniper Ct, Utica NY',        'Jim Halpert',       '555-0103'),
(22, 'Charles',   'Miner',       '1970-03-18', 'Male',   'B+',  '555-0122', 'cminer@email.com',    '123 Bamboo St, NYC NY',            'David Wallace',     '555-0187'),
(23, 'David',     'Wallace',     '1963-11-05', 'Male',   'O-',  '555-0123', 'dwallace@email.com',  '456 Terrace Dr, Scranton PA',      'Susan Wallace',     '555-0188'),
(24, 'Holly',     'Flax',        '1975-06-14', 'Female', 'AB+', '555-0124', 'hflax@email.com',     '789 Valley Rd, Nashua NH',         'Michael Scott',     '555-0101'),
(25, 'Nellie',    'Bertram',     '1971-09-09', 'Female', 'O+',  '555-0125', 'nbertram@email.com',  '321 Hilltop Dr, Scranton PA',      'Robert California', '555-0189'),
(26, 'Robert',    'California',  '1965-04-01', 'Male',   'A+',  '555-0126', 'rcalifornia@email.com','654 Lakeview Blvd, Tallahassee FL','Gabe Lewis',        '555-0117'),
(27, 'Todd',      'Packer',      '1970-07-07', 'Male',   'B-',  '555-0127', 'tpacker@email.com',   '987 Riverside Ln, Scranton PA',    'Michael Scott',     '555-0101'),
(28, 'Jim',       'Carrey',      '1982-01-17', 'Male',   'A-',  '555-0128', 'jcarrey@email.com',   '159 Sunset Blvd, LA CA',           'Jenny Carrey',      '555-0190'),
(29, 'Lena',      'Kim',         '1990-08-23', 'Female', 'B+',  '555-0129', 'lkim@email.com',      '753 Aurora Dr, Chicago IL',        'Mark Kim',          '555-0191'),
(30, 'Hassan',    'Al-Farsi',    '1987-12-11', 'Male',   'O+',  '555-0130', 'halfarsi@email.com',  '258 Crescent St, Detroit MI',      'Sara Al-Farsi',     '555-0192'),
(31, 'Elena',     'Vasquez',     '1993-03-05', 'Female', 'A+',  '555-0131', 'evasquez@email.com',  '741 Palm Ave, Miami FL',           'Miguel Vasquez',    '555-0193'),
(32, 'Noah',      'Williams',    '1988-06-29', 'Male',   'AB-', '555-0132', 'nwilliams@email.com', '369 Oak Blvd, Atlanta GA',         'Chloe Williams',    '555-0194'),
(33, 'Sophia',    'Turner',      '1995-01-18', 'Female', 'B-',  '555-0133', 'sturner@email.com',   '963 Harbor Ln, Boston MA',         'Jack Turner',       '555-0195'),
(34, 'Ethan',     'Brown',       '1974-09-03', 'Male',   'O-',  '555-0134', 'ebrown@email.com',    '147 Grove St, Denver CO',          'Maria Brown',       '555-0196'),
(35, 'Isabella',  'Davis',       '2000-04-22', 'Female', 'A-',  '555-0135', 'idavis@email.com',    '852 Forest Rd, Seattle WA',        'Tom Davis',         '555-0197'),
(36, 'Liam',      'Wilson',      '1969-11-30', 'Male',   'B+',  '555-0136', 'lwilson@email.com',   '246 Summit Dr, Phoenix AZ',        'Karen Wilson',      '555-0198'),
(37, 'Mia',       'Anderson',    '1991-07-15', 'Female', 'O+',  '555-0137', 'manderson@email.com', '159 Canyon Rd, Salt Lake City UT', 'Leo Anderson',      '555-0199'),
(38, 'Oliver',    'Taylor',      '1983-02-28', 'Male',   'AB+', '555-0138', 'otaylor@email.com',   '753 Meadow St, Nashville TN',      'Emma Taylor',       '555-0200'),
(39, 'Amelia',    'Thomas',      '1998-10-10', 'Female', 'A+',  '555-0139', 'athomas@email.com',   '258 Creek Dr, Portland OR',        'Ben Thomas',        '555-0201'),
(40, 'William',   'Jackson',     '1960-05-20', 'Male',   'B-',  '555-0140', 'wjackson@email.com',  '963 River Blvd, Houston TX',       'Grace Jackson',     '555-0202'),
(41, 'Harper',    'White',       '1996-12-07', 'Female', 'O-',  '555-0141', 'hwhite@email.com',    '369 Bridge Ave, Minneapolis MN',   'Tyler White',       '555-0203'),
(42, 'Benjamin',  'Harris',      '1978-08-14', 'Male',   'A-',  '555-0142', 'bharris@email.com',   '741 Arch St, Philadelphia PA',     'Susan Harris',      '555-0204'),
(43, 'Evelyn',    'Martin',      '1955-03-25', 'Female', 'AB+', '555-0143', 'emartin@email.com',   '147 Bell St, San Francisco CA',    'Rick Martin',       '555-0205'),
(44, 'Lucas',     'Garcia',      '1987-06-18', 'Male',   'O+',  '555-0144', 'lgarcia@email.com',   '852 Mission Dr, San Diego CA',     'Ana Garcia',        '555-0206'),
(45, 'Abigail',   'Martinez',    '2002-09-01', 'Female', 'B+',  '555-0145', 'amartinez@email.com', '258 Bay Rd, Tampa FL',             'Carlos Martinez',   '555-0207'),
(46, 'Mason',     'Robinson',    '1964-01-09', 'Male',   'AB-', '555-0146', 'mrobinson@email.com', '963 Lakeview Dr, Indianapolis IN', 'Donna Robinson',    '555-0208'),
(47, 'Chloe',     'Clark',       '1992-04-16', 'Female', 'A+',  '555-0147', 'cclark@email.com',    '369 Marina Blvd, San Jose CA',     'Paul Clark',        '555-0209'),
(48, 'Elijah',    'Rodriguez',   '1980-11-22', 'Male',   'O+',  '555-0148', 'erodriguez@email.com','147 Vineyard St, Sacramento CA',   'Nina Rodriguez',    '555-0210'),
(49, 'Avery',     'Lewis',       '2004-07-30', 'Female', 'B-',  '555-0149', 'alewis@email.com',    '753 Coral Ave, Fort Lauderdale FL','Pete Lewis',        '555-0211'),
(50, 'James',     'Lee',         '1972-02-08', 'Male',   'A-',  '555-0150', 'jlee@email.com',      '852 Orchid Dr, Las Vegas NV',      'Sun Lee',           '555-0212'),
(51, 'Scarlett',  'Walker',      '1989-05-11', 'Female', 'AB+', '555-0151', 'swalker@email.com',   '258 Sapphire St, Kansas City MO',  'Dan Walker',        '555-0213'),
(52, 'Henry',     'Hall',        '1976-08-03', 'Male',   'O-',  '555-0152', 'hhall@email.com',     '963 Granite Rd, Raleigh NC',       'Beth Hall',         '555-0214'),
(53, 'Lily',      'Allen',       '1994-12-19', 'Female', 'B+',  '555-0153', 'lallen@email.com',    '369 Iron St, Charlotte NC',        'Steve Allen',       '555-0215'),
(54, 'Jackson',   'Young',       '1968-04-27', 'Male',   'A+',  '555-0154', 'jyoung@email.com',    '741 Copper Ave, Memphis TN',       'Lisa Young',        '555-0216'),
(55, 'Zoe',       'Hernandez',   '2001-01-31', 'Female', 'O+',  '555-0155', 'zhernandez@email.com','147 Silver Blvd, El Paso TX',      'Marco Hernandez',   '555-0217'),
(56, 'Sebastian', 'King',        '1985-06-24', 'Male',   'AB+', '555-0156', 'sking@email.com',     '852 Gold St, Louisville KY',       'Irene King',        '555-0218'),
(57, 'Hannah',    'Wright',      '1977-03-09', 'Female', 'B-',  '555-0157', 'hwright@email.com',   '258 Pearl Rd, Baltimore MD',       'Frank Wright',      '555-0219'),
(58, 'Carter',    'Lopez',       '1963-09-16', 'Male',   'O-',  '555-0158', 'clopez@email.com',    '963 Ruby Ave, Milwaukee WI',       'Maria Lopez',       '555-0220'),
(59, 'Grace',     'Hill',        '1999-07-04', 'Female', 'A-',  '555-0159', 'ghill@email.com',     '369 Diamond Rd, Albuquerque NM',   'Ed Hill',           '555-0221'),
(60, 'Logan',     'Scott',       '1981-10-21', 'Male',   'B+',  '555-0160', 'lscott@email.com',    '741 Emerald St, Tucson AZ',        'Penny Scott',       '555-0222');


-- =============================================================================
-- 4. INSURANCE PROVIDERS  (8 rows)
-- =============================================================================
INSERT INTO insurance_providers (Provider_ID, Company_Name, Support_Phone, Support_Email, Billing_Address) VALUES
(1, 'Blue Cross Health',   '1-800-555-0001', 'support@bluecross.com',    '1 Health Plaza, Chicago IL 60601'),
(2, 'Aetna Secure',        '1-800-555-0002', 'claims@aetna.com',         '151 Farmington Ave, Hartford CT 06156'),
(3, 'Medicare',            '1-800-555-0003', 'support@medicare.gov',     '7500 Security Blvd, Baltimore MD 21244'),
(4, 'United Healthcare',   '1-800-555-0004', 'service@uhc.com',          '9900 Bren Rd E, Minnetonka MN 55343'),
(5, 'Cigna Health',        '1-800-555-0005', 'help@cigna.com',           '900 Cottage Grove Rd, Bloomfield CT 06002'),
(6, 'Humana Care',         '1-800-555-0006', 'care@humana.com',          '500 W Main St, Louisville KY 40202'),
(7, 'Kaiser Permanente',   '1-800-555-0007', 'support@kp.org',           '1 Kaiser Plaza, Oakland CA 94612'),
(8, 'Medicaid',            '1-800-555-0008', 'support@medicaid.gov',     '200 Independence Ave SW, Washington DC 20201');


-- =============================================================================
-- 5. PATIENT INSURANCE  (50 rows, one per patient where applicable)
-- =============================================================================
INSERT INTO patient_insurance (Insurance_ID, Patient_ID, Provider_ID, Policy_Number, Coverage_Start, Coverage_End, Copay_Amount) VALUES
( 1,  1, 1, 'BC-99238',  '2024-01-01', '2024-12-31', 40.00),
( 2,  2, 2, 'AE-44211',  '2024-01-01', '2024-12-31', 25.00),
( 3,  3, 4, 'UH-77301',  '2024-01-01', '2024-12-31', 30.00),
( 4,  4, 1, 'BC-99239',  '2024-01-01', '2024-12-31', 40.00),
( 5,  5, 5, 'CG-51100',  '2024-01-01', '2024-12-31', 35.00),
( 6,  6, 2, 'AE-44212',  '2024-01-01', '2024-12-31', 25.00),
( 7,  7, 3, 'MC-10001',  '2024-01-01', '2024-12-31', 20.00),
( 8,  8, 3, 'MC-10002',  '2024-01-01', '2024-12-31', 20.00),
( 9,  9, 6, 'HU-66001',  '2024-01-01', '2024-12-31', 30.00),
(10, 10, 1, 'BC-99240',  '2024-01-01', '2024-12-31', 40.00),
(11, 11, 8, 'MD-20001',  '2024-01-01', '2024-12-31', 10.00),
(12, 12, 4, 'UH-77302',  '2024-01-01', '2024-12-31', 30.00),
(13, 13, 2, 'AE-44213',  '2024-01-01', '2024-12-31', 25.00),
(14, 14, 5, 'CG-51101',  '2024-01-01', '2024-12-31', 35.00),
(15, 15, 7, 'KP-33001',  '2024-01-01', '2024-12-31', 20.00),
(16, 16, 1, 'BC-99241',  '2024-01-01', '2024-12-31', 40.00),
(17, 17, 6, 'HU-66002',  '2024-01-01', '2024-12-31', 30.00),
(18, 18, 4, 'UH-77303',  '2024-01-01', '2024-12-31', 30.00),
(19, 19, 2, 'AE-44214',  '2024-01-01', '2024-12-31', 25.00),
(20, 20, 3, 'MC-10003',  '2024-01-01', '2024-12-31', 20.00),
(21, 21, 5, 'CG-51102',  '2024-01-01', '2024-12-31', 35.00),
(22, 22, 1, 'BC-99242',  '2024-01-01', '2024-12-31', 40.00),
(23, 23, 4, 'UH-77304',  '2024-01-01', '2024-12-31', 30.00),
(24, 24, 7, 'KP-33002',  '2024-01-01', '2024-12-31', 20.00),
(25, 25, 2, 'AE-44215',  '2024-01-01', '2024-12-31', 25.00),
(26, 26, 6, 'HU-66003',  '2024-01-01', '2024-12-31', 30.00),
(27, 27, 8, 'MD-20002',  '2024-01-01', '2024-12-31', 10.00),
(28, 28, 1, 'BC-99243',  '2024-01-01', '2024-12-31', 40.00),
(29, 29, 5, 'CG-51103',  '2024-01-01', '2024-12-31', 35.00),
(30, 30, 3, 'MC-10004',  '2024-01-01', '2024-12-31', 20.00),
(31, 31, 4, 'UH-77305',  '2024-01-01', '2024-12-31', 30.00),
(32, 32, 7, 'KP-33003',  '2024-01-01', '2024-12-31', 20.00),
(33, 33, 2, 'AE-44216',  '2024-01-01', '2024-12-31', 25.00),
(34, 34, 6, 'HU-66004',  '2024-01-01', '2024-12-31', 30.00),
(35, 35, 1, 'BC-99244',  '2024-01-01', '2024-12-31', 40.00),
(36, 36, 3, 'MC-10005',  '2024-01-01', '2024-12-31', 20.00),
(37, 37, 5, 'CG-51104',  '2024-01-01', '2024-12-31', 35.00),
(38, 38, 8, 'MD-20003',  '2024-01-01', '2024-12-31', 10.00),
(39, 39, 4, 'UH-77306',  '2024-01-01', '2024-12-31', 30.00),
(40, 40, 3, 'MC-10006',  '2024-01-01', '2024-12-31', 20.00),
(41, 41, 7, 'KP-33004',  '2024-01-01', '2024-12-31', 20.00),
(42, 42, 2, 'AE-44217',  '2024-01-01', '2024-12-31', 25.00),
(43, 43, 6, 'HU-66005',  '2024-01-01', '2024-12-31', 30.00),
(44, 44, 1, 'BC-99245',  '2024-01-01', '2024-12-31', 40.00),
(45, 45, 8, 'MD-20004',  '2024-01-01', '2024-12-31', 10.00),
(46, 46, 4, 'UH-77307',  '2024-01-01', '2024-12-31', 30.00),
(47, 47, 5, 'CG-51105',  '2024-01-01', '2024-12-31', 35.00),
(48, 48, 3, 'MC-10007',  '2024-01-01', '2024-12-31', 20.00),
(49, 49, 7, 'KP-33005',  '2024-01-01', '2024-12-31', 20.00),
(50, 50, 1, 'BC-99246',  '2024-01-01', '2024-12-31', 40.00);


-- =============================================================================
-- 6. WARDS  (20 rows)
-- =============================================================================
INSERT INTO wards (Ward_ID, Department_ID, Ward_Name, Ward_Type) VALUES
( 1,  1, 'Cardio ICU',       'ICU'),
( 2,  1, 'Cardio Step-Down', 'General'),
( 3,  2, 'Ortho Recovery',   'General'),
( 4,  2, 'Ortho Pre-Op',     'General'),
( 5,  3, 'ER Trauma',        'Emergency'),
( 6,  3, 'ER Observation',   'Emergency'),
( 7,  4, 'Peds General',     'General'),
( 8,  4, 'NICU',             'ICU'),
( 9,  5, 'Neuro ICU',        'ICU'),
(10,  5, 'Neuro General',    'General'),
(11,  6, 'Oncology Day',     'General'),
(12,  6, 'Oncology Inpatient','General'),
(13,  7, 'Imaging Suite',    'General'),
(14,  8, 'Surgical ICU',     'ICU'),
(15,  8, 'Surgical Recovery','General'),
(16,  9, 'Labor & Delivery', 'Maternity'),
(17,  9, 'Post-Partum',      'Maternity'),
(18, 10, 'Derm Clinic',      'General'),
(19,  1, 'Cardiac Rehab',    'General'),
(20,  3, 'ER Fast Track',    'Emergency');


-- =============================================================================
-- 7. ROOMS  (40 rows)
-- =============================================================================
INSERT INTO rooms (Room_ID, Ward_ID, Room_Number, Bed_Count, Is_Available, Daily_Rate) VALUES
-- Cardio ICU (Ward 1)
( 1,  1, '101A',  1, TRUE,  1200.00),
( 2,  1, '101B',  1, FALSE, 1200.00),
( 3,  1, '102A',  1, TRUE,  1200.00),
-- Cardio Step-Down (Ward 2)
( 4,  2, '110',   2, TRUE,   750.00),
( 5,  2, '111',   2, FALSE,  750.00),
-- Ortho Recovery (Ward 3)
( 6,  3, '201',   2, TRUE,   600.00),
( 7,  3, '202',   2, FALSE,  600.00),
( 8,  3, '203',   2, TRUE,   600.00),
-- Ortho Pre-Op (Ward 4)
( 9,  4, '210',   1, TRUE,   500.00),
(10,  4, '211',   1, TRUE,   500.00),
-- ER Trauma (Ward 5)
(11,  5, 'T1',    1, FALSE, 2000.00),
(12,  5, 'T2',    1, FALSE, 2000.00),
(13,  5, 'T3',    1, TRUE,  2000.00),
-- ER Observation (Ward 6)
(14,  6, 'OB1',   2, TRUE,   900.00),
(15,  6, 'OB2',   2, FALSE,  900.00),
-- Peds General (Ward 7)
(16,  7, '401',   4, TRUE,   400.00),
(17,  7, '402',   4, FALSE,  400.00),
-- NICU (Ward 8)
(18,  8, 'N101',  1, FALSE, 2500.00),
(19,  8, 'N102',  1, TRUE,  2500.00),
-- Neuro ICU (Ward 9)
(20,  9, '501A',  1, FALSE, 1800.00),
(21,  9, '501B',  1, TRUE,  1800.00),
-- Neuro General (Ward 10)
(22, 10, '510',   2, TRUE,   700.00),
(23, 10, '511',   2, FALSE,  700.00),
-- Oncology Day (Ward 11)
(24, 11, 'ONC-D1',1, TRUE,   800.00),
(25, 11, 'ONC-D2',1, TRUE,   800.00),
-- Oncology Inpatient (Ward 12)
(26, 12, 'ONC-101',1,FALSE,  950.00),
(27, 12, 'ONC-102',1,TRUE,   950.00),
-- Imaging Suite (Ward 13)
(28, 13, 'IMG-1', 1, TRUE,   300.00),
-- Surgical ICU (Ward 14)
(29, 14, 'SICU-1',1, FALSE, 2200.00),
(30, 14, 'SICU-2',1, TRUE,  2200.00),
-- Surgical Recovery (Ward 15)
(31, 15, 'SR-201',2, TRUE,   900.00),
(32, 15, 'SR-202',2, FALSE,  900.00),
-- Labor & Delivery (Ward 16)
(33, 16, 'LD-1',  1, FALSE, 1500.00),
(34, 16, 'LD-2',  1, TRUE,  1500.00),
-- Post-Partum (Ward 17)
(35, 17, 'PP-301',2, TRUE,   700.00),
(36, 17, 'PP-302',2, FALSE,  700.00),
-- Derm Clinic (Ward 18)
(37, 18, 'DC-1',  1, TRUE,   250.00),
-- Cardiac Rehab (Ward 19)
(38, 19, 'CR-1',  4, TRUE,   500.00),
-- ER Fast Track (Ward 20)
(39, 20, 'FT-1',  2, TRUE,   600.00),
(40, 20, 'FT-2',  2, FALSE,  600.00);


-- =============================================================================
-- 8. ADMISSIONS  (40 rows)
-- =============================================================================
INSERT INTO admissions (Admission_ID, Patient_ID, Room_ID, Attending_Doctor_ID, Admission_Date, Discharge_Date, Admission_Reason, Status) VALUES
-- Currently admitted
( 1,  1,  2,  1, DATEADD(day,-5, CURRENT_TIMESTAMP()),  NULL,                              'Heart palpitations',            'Admitted'),
( 2,  4,  7,  4, DATEADD(day,-2, CURRENT_TIMESTAMP()),  NULL,                              'Broken leg (tibia fracture)',    'Admitted'),
( 3,  8, 20, 10, DATEADD(day,-3, CURRENT_TIMESTAMP()),  NULL,                              'Acute ischemic stroke',          'Admitted'),
( 4, 12, 12,  7, DATEADD(day,-1, CURRENT_TIMESTAMP()),  NULL,                              'Severe abdominal pain',          'Admitted'),
( 5, 18, 26, 12, DATEADD(day,-7, CURRENT_TIMESTAMP()),  NULL,                              'Chemotherapy - Breast Cancer',  'Admitted'),
( 6, 22, 29, 17, DATEADD(day,-4, CURRENT_TIMESTAMP()),  NULL,                              'Post-appendectomy recovery',    'Admitted'),
( 7, 30, 18, 28, DATEADD(day,-6, CURRENT_TIMESTAMP()),  NULL,                              'Premature birth (32 weeks)',    'Admitted'),
( 8, 35, 17,  8, DATEADD(day,-2, CURRENT_TIMESTAMP()),  NULL,                              'Asthma exacerbation',           'Admitted'),
( 9, 40, 11,  7, DATEADD(day,-1, CURRENT_TIMESTAMP()),  NULL,                              'Cardiac arrest stabilised',     'Admitted'),
(10, 45, 33, 19, DATEADD(day,-3, CURRENT_TIMESTAMP()),  NULL,                              'Labor - first baby',            'Admitted'),
-- Discharged
(11,  5, 13,  6, DATEADD(day,-10,CURRENT_TIMESTAMP()), DATEADD(day,-9, CURRENT_TIMESTAMP()),'Minor concussion',             'Discharged'),
(12,  2,  4,  1, DATEADD(day,-30,CURRENT_TIMESTAMP()), DATEADD(day,-24,CURRENT_TIMESTAMP()),'Chest pain evaluation',        'Discharged'),
(13,  3,  6,  4, DATEADD(day,-45,CURRENT_TIMESTAMP()), DATEADD(day,-42,CURRENT_TIMESTAMP()),'Knee arthroscopy',             'Discharged'),
(14,  6,  8,  4, DATEADD(day,-20,CURRENT_TIMESTAMP()), DATEADD(day,-18,CURRENT_TIMESTAMP()),'Hip replacement',              'Discharged'),
(15,  7, 15, 14, DATEADD(day,-60,CURRENT_TIMESTAMP()), DATEADD(day,-55,CURRENT_TIMESTAMP()),'Colon surgery - polyp removal','Discharged'),
(16,  9, 35, 19, DATEADD(day,-90,CURRENT_TIMESTAMP()), DATEADD(day,-88,CURRENT_TIMESTAMP()),'Delivery - vaginal birth',     'Discharged'),
(17, 10, 11,  7, DATEADD(day,-15,CURRENT_TIMESTAMP()), DATEADD(day,-13,CURRENT_TIMESTAMP()),'Appendicitis (emergency)',     'Discharged'),
(18, 11, 22, 10, DATEADD(day,-50,CURRENT_TIMESTAMP()), DATEADD(day,-46,CURRENT_TIMESTAMP()),'Seizure evaluation',           'Discharged'),
(19, 13, 23, 11, DATEADD(day,-25,CURRENT_TIMESTAMP()), DATEADD(day,-22,CURRENT_TIMESTAMP()),'Brain tumor biopsy',           'Discharged'),
(20, 14, 39,  6, DATEADD(day,-8, CURRENT_TIMESTAMP()), DATEADD(day,-7, CURRENT_TIMESTAMP()),'Allergic reaction - severe',   'Discharged'),
(21, 15, 31, 17, DATEADD(day,-35,CURRENT_TIMESTAMP()), DATEADD(day,-31,CURRENT_TIMESTAMP()),'Hernia repair',                'Discharged'),
(22, 16, 36, 20, DATEADD(day,-75,CURRENT_TIMESTAMP()), DATEADD(day,-73,CURRENT_TIMESTAMP()),'Endometriosis surgery',        'Discharged'),
(23, 17,  5,  6, DATEADD(day,-12,CURRENT_TIMESTAMP()), DATEADD(day,-11,CURRENT_TIMESTAMP()),'Chest trauma from accident',   'Discharged'),
(24, 19,  1,  1, DATEADD(day,-40,CURRENT_TIMESTAMP()), DATEADD(day,-35,CURRENT_TIMESTAMP()),'STEMI heart attack',           'Discharged'),
(25, 20, 32, 18, DATEADD(day,-55,CURRENT_TIMESTAMP()), DATEADD(day,-51,CURRENT_TIMESTAMP()),'Bowel obstruction',            'Discharged'),
(26, 21,  4,  3, DATEADD(day,-18,CURRENT_TIMESTAMP()), DATEADD(day,-16,CURRENT_TIMESTAMP()),'Atrial fibrillation',          'Discharged'),
(27, 23, 14,  6, DATEADD(day,-5, CURRENT_TIMESTAMP()), DATEADD(day,-4, CURRENT_TIMESTAMP()),'Observation - chest pain',     'Discharged'),
(28, 24,  9,  4, DATEADD(day,-22,CURRENT_TIMESTAMP()), DATEADD(day,-19,CURRENT_TIMESTAMP()),'Shoulder dislocation surgery', 'Discharged'),
(29, 25, 16,  8, DATEADD(day,-14,CURRENT_TIMESTAMP()), DATEADD(day,-12,CURRENT_TIMESTAMP()),'Tonsillitis (pediatric visit)','Discharged'),
(30, 26, 27, 12, DATEADD(day,-80,CURRENT_TIMESTAMP()), DATEADD(day,-74,CURRENT_TIMESTAMP()),'Lung cancer - chemo cycle 1',  'Discharged'),
(31, 27, 11,  7, DATEADD(day,-9, CURRENT_TIMESTAMP()), DATEADD(day,-8, CURRENT_TIMESTAMP()),'Rib fractures from fall',      'Discharged'),
(32, 28,  3,  1, DATEADD(day,-28,CURRENT_TIMESTAMP()), DATEADD(day,-24,CURRENT_TIMESTAMP()),'Unstable angina',              'Discharged'),
(33, 29, 20, 10, DATEADD(day,-32,CURRENT_TIMESTAMP()), DATEADD(day,-29,CURRENT_TIMESTAMP()),'Migraine with complications',  'Discharged'),
(34, 31, 33, 30, DATEADD(day,-65,CURRENT_TIMESTAMP()), DATEADD(day,-62,CURRENT_TIMESTAMP()),'High-risk pregnancy monitoring','Discharged'),
(35, 32, 22, 11, DATEADD(day,-48,CURRENT_TIMESTAMP()), DATEADD(day,-44,CURRENT_TIMESTAMP()),'Epilepsy - status epilepticus','Discharged'),
(36, 33, 15, 17, DATEADD(day,-38,CURRENT_TIMESTAMP()), DATEADD(day,-35,CURRENT_TIMESTAMP()),'Laparoscopic cholecystectomy', 'Discharged'),
(37, 34,  5,  6, DATEADD(day,-17,CURRENT_TIMESTAMP()), DATEADD(day,-16,CURRENT_TIMESTAMP()),'Kidney stone ER visit',        'Discharged'),
(38, 36,  7,  4, DATEADD(day,-42,CURRENT_TIMESTAMP()), DATEADD(day,-38,CURRENT_TIMESTAMP()),'Total knee replacement',       'Discharged'),
(39, 50, 29, 17, DATEADD(day,-20,CURRENT_TIMESTAMP()), DATEADD(day,-16,CURRENT_TIMESTAMP()),'Gastric bypass surgery',       'Discharged'),
(40, 54,  1,  2, DATEADD(day,-58,CURRENT_TIMESTAMP()), DATEADD(day,-52,CURRENT_TIMESTAMP()),'Coronary artery bypass graft', 'Discharged');


-- =============================================================================
-- 9. APPOINTMENTS  (80 rows)
-- =============================================================================
INSERT INTO appointments (Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Status, Reason_For_Visit, Notes) VALUES
-- Completed
( 1,  2,  8, DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Completed', 'Routine checkup',                  'All clear'),
( 2,  3,  4, DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'Completed', 'Knee pain evaluation',             'MRI ordered'),
( 3,  5,  1, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'No Show',   'Annual physical',                  NULL),
( 4,  6, 21, DATEADD(day,-20, CURRENT_TIMESTAMP()), 'Completed', 'Skin rash evaluation',             'Eczema diagnosed'),
( 5,  7,  3, DATEADD(day,-45, CURRENT_TIMESTAMP()), 'Completed', 'Chest pain workup',                'ECG normal'),
( 6,  8, 10, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Completed', 'Headache follow-up',               'CT scan ordered'),
( 7,  9, 19, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Completed', 'OB prenatal visit week 28',        'Normal progression'),
( 8, 10, 17, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Completed', 'Post-surgery check',               'Healing well'),
( 9, 11, 10, DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Completed', 'Seizure medication review',        'Dosage adjusted'),
(10, 12, 12, DATEADD(day,-25, CURRENT_TIMESTAMP()), 'Completed', 'Chemo pre-assessment',             'Labs reviewed'),
(11, 13, 11, DATEADD(day,-50, CURRENT_TIMESTAMP()), 'Completed', 'Neurology initial consult',        'Glioma suspected'),
(12, 14,  6, DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'Completed', 'Allergy follow-up',                'EpiPen prescribed'),
(13, 15, 17, DATEADD(day,-35, CURRENT_TIMESTAMP()), 'Completed', 'Pre-op hernia assessment',         'Surgery scheduled'),
(14, 16, 20, DATEADD(day,-75, CURRENT_TIMESTAMP()), 'Completed', 'Gynecology annual exam',           'Normal'),
(15, 17,  3, DATEADD(day,-12, CURRENT_TIMESTAMP()), 'Completed', 'ER follow-up chest trauma',        'X-ray clear'),
(16, 18, 12, DATEADD(day,-40, CURRENT_TIMESTAMP()), 'Completed', 'Oncology consult',                 'Treatment plan set'),
(17, 19,  1, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Completed', 'Cardiology post-MI follow-up',     'Echo scheduled'),
(18, 20, 18, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Completed', 'Pre-op bowel surgery assessment',  'Cleared for OR'),
(19, 21,  3, DATEADD(day,-18, CURRENT_TIMESTAMP()), 'Completed', 'A-fib rate control evaluation',    'Medication adjusted'),
(20, 22, 17, DATEADD(day,-35, CURRENT_TIMESTAMP()), 'Completed', 'Post-appendectomy follow-up',      'Full recovery'),
(21, 23,  1, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Completed', 'Chest pain second opinion',        'Stress test normal'),
(22, 24,  4, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Completed', 'Shoulder pain evaluation',         'MRI showed tear'),
(23, 25,  8, DATEADD(day,-14, CURRENT_TIMESTAMP()), 'Completed', 'Child wellness exam (age 3)',       'Up to date on vaccines'),
(24, 26, 12, DATEADD(day,-80, CURRENT_TIMESTAMP()), 'Completed', 'Lung cancer staging consult',      'Stage IIIA'),
(25, 27,  7, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Completed', 'Trauma surgery follow-up',         'Healing progressing'),
(26, 28,  1, DATEADD(day,-28, CURRENT_TIMESTAMP()), 'Completed', 'Angina initial consultation',      'Angiogram ordered'),
(27, 29, 25, DATEADD(day,-32, CURRENT_TIMESTAMP()), 'Completed', 'Chronic migraine management',      'Preventive meds started'),
(28, 30, 28, DATEADD(day,-90, CURRENT_TIMESTAMP()), 'Completed', 'OB first prenatal visit',          '8 weeks, heartbeat confirmed'),
(29, 31, 30, DATEADD(day,-65, CURRENT_TIMESTAMP()), 'Completed', 'High-risk OB assessment',          'Gestational diabetes noted'),
(30, 32, 11, DATEADD(day,-48, CURRENT_TIMESTAMP()), 'Completed', 'Epilepsy medication review',       'New regimen started'),
(31, 33, 17, DATEADD(day,-38, CURRENT_TIMESTAMP()), 'Completed', 'Gallbladder pain evaluation',      'Surgery recommended'),
(32, 34,  6, DATEADD(day,-17, CURRENT_TIMESTAMP()), 'Completed', 'Kidney stone evaluation',          'CT confirmed stone'),
(33, 35,  8, DATEADD(day,-20, CURRENT_TIMESTAMP()), 'Completed', 'Asthma management follow-up',      'Inhaler technique reviewed'),
(34, 36,  5, DATEADD(day,-42, CURRENT_TIMESTAMP()), 'Completed', 'Pre-op knee replacement',          'Cleared for surgery'),
(35, 37, 21, DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Completed', 'Acne treatment follow-up',         'New topical prescribed'),
(36, 38, 10, DATEADD(day,-25, CURRENT_TIMESTAMP()), 'Completed', 'Parkinson evaluation',             'Medication initiated'),
(37, 39, 20, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Completed', 'Menstrual irregularity',           'Ultrasound ordered'),
(38, 40,  2, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Completed', 'Heart failure management',         'Meds optimized'),
(39, 41, 21, DATEADD(day,-18, CURRENT_TIMESTAMP()), 'Completed', 'Psoriasis consultation',           'Biologics considered'),
(40, 42,  4, DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Completed', 'Back pain evaluation',             'Spinal MRI ordered'),
(41, 43,  3, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Completed', 'Palpitations evaluation',          'Holter monitor ordered'),
(42, 44, 17, DATEADD(day,-12, CURRENT_TIMESTAMP()), 'Completed', 'Hernia consultation',              'Watchful waiting'),
(43, 45,  9, DATEADD(day,-40, CURRENT_TIMESTAMP()), 'Completed', 'Pediatric cardiology consultation','Normal echo'),
(44, 46,  1, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Completed', 'Annual cardiac follow-up',         'Stable CAD'),
(45, 47, 22, DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'Completed', 'Skin tag removal',                 'Removed successfully'),
(46, 48,  6, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Completed', 'ER follow-up - laceration',        'Stitches removed'),
(47, 49,  8, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Completed', 'Pediatric wellness visit (6m)',     'Growth normal'),
(48, 50,  3, DATEADD(day,-70, CURRENT_TIMESTAMP()), 'Completed', 'Hypertension management',          'BP controlled'),
-- Scheduled (future)
(49,  2,  8, DATEADD(day, 2,  CURRENT_TIMESTAMP()), 'Scheduled', 'Follow-up wellness',               NULL),
(50,  3,  4, DATEADD(day, 5,  CURRENT_TIMESTAMP()), 'Scheduled', 'MRI review',                       NULL),
(51,  6, 21, DATEADD(day, 3,  CURRENT_TIMESTAMP()), 'Scheduled', 'Eczema follow-up',                 NULL),
(52,  9, 19, DATEADD(day, 7,  CURRENT_TIMESTAMP()), 'Scheduled', 'OB 36-week check',                 NULL),
(53, 11, 10, DATEADD(day,10,  CURRENT_TIMESTAMP()), 'Scheduled', 'EEG review',                       NULL),
(54, 13, 11, DATEADD(day, 4,  CURRENT_TIMESTAMP()), 'Scheduled', 'Post-chemo neuro follow-up',       NULL),
(55, 16, 20, DATEADD(day, 6,  CURRENT_TIMESTAMP()), 'Scheduled', 'Annual gynecology',                NULL),
(56, 18, 12, DATEADD(day, 8,  CURRENT_TIMESTAMP()), 'Scheduled', 'Chemo cycle 6 assessment',         NULL),
(57, 21,  3, DATEADD(day,12,  CURRENT_TIMESTAMP()), 'Scheduled', 'A-fib 3-month follow-up',          NULL),
(58, 24,  4, DATEADD(day, 9,  CURRENT_TIMESTAMP()), 'Scheduled', 'Post-op shoulder review',          NULL),
(59, 26, 12, DATEADD(day,14,  CURRENT_TIMESTAMP()), 'Scheduled', 'Chemo cycle 4',                    NULL),
(60, 29, 25, DATEADD(day, 5,  CURRENT_TIMESTAMP()), 'Scheduled', 'Migraine 6-week review',           NULL),
(61, 31, 30, DATEADD(day,15,  CURRENT_TIMESTAMP()), 'Scheduled', 'Gestational diabetes follow-up',   NULL),
(62, 33, 17, DATEADD(day,11,  CURRENT_TIMESTAMP()), 'Scheduled', 'Post-op cholecystectomy',          NULL),
(63, 35,  8, DATEADD(day, 3,  CURRENT_TIMESTAMP()), 'Scheduled', 'Asthma medication review',         NULL),
(64, 37, 21, DATEADD(day, 6,  CURRENT_TIMESTAMP()), 'Scheduled', 'Acne 8-week follow-up',            NULL),
(65, 38, 10, DATEADD(day,20,  CURRENT_TIMESTAMP()), 'Scheduled', 'Parkinson 3-month review',         NULL),
(66, 41, 21, DATEADD(day, 4,  CURRENT_TIMESTAMP()), 'Scheduled', 'Psoriasis biologic assessment',    NULL),
(67, 43,  9, DATEADD(day,10,  CURRENT_TIMESTAMP()), 'Scheduled', 'Pediatric cardio 6-month',         NULL),
(68, 46,  2, DATEADD(day,16,  CURRENT_TIMESTAMP()), 'Scheduled', 'Stress echo follow-up',            NULL),
-- Cancelled / No Show
(69,  4,  4, DATEADD(day,-14, CURRENT_TIMESTAMP()), 'Cancelled', 'Ortho follow-up',                  'Patient admitted before appt'),
(70,  5,  1, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'No Show',   'Cardiology follow-up',             NULL),
(71, 14,  6, DATEADD(day,-20, CURRENT_TIMESTAMP()), 'Cancelled', 'ER follow-up',                     'Patient rescheduled'),
(72, 17,  7, DATEADD(day,-40, CURRENT_TIMESTAMP()), 'No Show',   'Surgery consult',                  NULL),
(73, 20, 18, DATEADD(day,-25, CURRENT_TIMESTAMP()), 'Cancelled', 'Pre-op bowel',                     'Surgery date changed'),
(74, 27,  7, DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Cancelled', 'Trauma follow-up',                 NULL),
(75, 32, 11, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'No Show',   'Neurology consult',                NULL),
(76, 34,  6, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Cancelled', 'Urology referral',                 'Rescheduled'),
(77, 40,  2, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'No Show',   'Heart failure check',              NULL),
(78, 48,  6, DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Cancelled', 'ER wound check',                   NULL),
(79, 51,  1, DATEADD(day,-12, CURRENT_TIMESTAMP()), 'No Show',   'Cardiology new patient',           NULL),
(80, 55, 22, DATEADD(day,-6,  CURRENT_TIMESTAMP()), 'Cancelled', 'Derm appointment',                 'Rescheduled for next week');


-- =============================================================================
-- 10. MEDICAL RECORDS  (60 rows)
-- =============================================================================
INSERT INTO medical_records (Record_ID, Patient_ID, Doctor_ID, Appointment_ID, Date_Recorded, Diagnosis, Symptoms, Treatment_Plan) VALUES
-- Admission-linked records
( 1,  1,  1, NULL, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Mild Arrhythmia',                      'Palpitations, shortness of breath', 'Continuous ECG monitoring, beta blockers'),
( 2,  4,  4, NULL, DATEADD(day,-2,  CURRENT_TIMESTAMP()), 'Tibia Fracture',                        'Severe leg pain, swelling',         'Surgical fixation with intramedullary nail'),
( 3,  8, 10, NULL, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Acute Ischemic Stroke',                 'Sudden speech difficulty, arm weakness', 'IV thrombolysis, anticoagulation'),
( 4, 12,  7, NULL, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'Acute Appendicitis',                    'RLQ pain, fever, nausea',           'Emergency appendectomy'),
( 5, 18, 12, NULL, DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'Breast Cancer Stage II',                'Left breast mass',                  'Chemotherapy cycle 5, targeted therapy'),
( 6, 22, 17, NULL, DATEADD(day,-4,  CURRENT_TIMESTAMP()), 'Acute Appendicitis',                    'RLQ abdominal pain, elevated WBC',  'Laparoscopic appendectomy'),
( 7, 40,  7, NULL, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'Cardiac Arrest - VF',                   'Loss of consciousness, no pulse',   'CPR, defibrillation, ICU monitoring'),
-- Appointment-linked records
( 8,  2,  8,  1,   DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Healthy Adult',                         'None',                              'Routine annual care, screenings up to date'),
( 9,  3,  4,  2,   DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'Meniscus Tear',                         'Knee swelling and locking',         'Physical therapy, possible arthroscopy'),
(10,  6, 21,  4,   DATEADD(day,-20, CURRENT_TIMESTAMP()), 'Atopic Dermatitis (Eczema)',             'Itchy red patches on arms',         'Topical corticosteroids, moisturiser'),
(11,  7,  3,  5,   DATEADD(day,-45, CURRENT_TIMESTAMP()), 'Non-Cardiac Chest Pain',                'Chest tightness, normal ECG',       'Reassurance, antacids, follow-up in 4 weeks'),
(12,  8, 10,  6,   DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Tension Headache',                      'Bilateral head pressure, fatigue',  'Analgesics, stress management, CT scan pending'),
(13,  9, 19,  7,   DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Normal Pregnancy - Week 28',            'Mild back pain',                    'Iron supplements, weekly monitoring'),
(14, 10, 17,  8,   DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Post-Appendectomy',                     'Healing incision site',             'Wound care, activity restriction 2 weeks'),
(15, 11, 10,  9,   DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Temporal Lobe Epilepsy',                'Complex partial seizures x2/month', 'Levetiracetam 1000mg BD, EEG monitoring'),
(16, 12, 12, 10,   DATEADD(day,-25, CURRENT_TIMESTAMP()), 'Pancreatic Cancer Stage III',           'Jaundice, weight loss, back pain',  'Gemcitabine + nab-paclitaxel chemo regimen'),
(17, 13, 11, 11,   DATEADD(day,-50, CURRENT_TIMESTAMP()), 'Glioblastoma Multiforme (GBM)',         'Headaches, seizures, personality changes','Temozolomide, radiation, Dexamethasone'),
(18, 14,  6, 12,   DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'Anaphylaxis - Penicillin Allergy',      'Hives, throat swelling, hypotension','EpiPen, steroids, antihistamines, allergy bracelet'),
(19, 15, 17, 13,   DATEADD(day,-35, CURRENT_TIMESTAMP()), 'Inguinal Hernia',                       'Groin bulge, intermittent pain',    'Laparoscopic inguinal hernia repair scheduled'),
(20, 16, 20, 14,   DATEADD(day,-75, CURRENT_TIMESTAMP()), 'Endometriosis',                         'Dysmenorrhea, pelvic pain',         'Laparoscopic excision, hormonal therapy'),
(21, 17,  3, 15,   DATEADD(day,-12, CURRENT_TIMESTAMP()), 'Rib Contusion',                         'Chest wall pain on breathing',      'Analgesics, deep breathing exercises'),
(22, 18, 12, 16,   DATEADD(day,-40, CURRENT_TIMESTAMP()), 'Breast Cancer - Chemo Planning',        'Previous lumpectomy, clear margins','Adjuvant chemotherapy plan confirmed'),
(23, 19,  1, 17,   DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Post-STEMI Recovery',                   'Exertional dyspnoea',               'Aspirin, statin, ACE inhibitor, cardiac rehab'),
(24, 20, 18, 18,   DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Adhesive Bowel Obstruction',            'Vomiting, distension, colicky pain','Nasogastric tube decompression, surgery'),
(25, 21,  3, 19,   DATEADD(day,-18, CURRENT_TIMESTAMP()), 'Atrial Fibrillation',                   'Irregular heartbeat, fatigue',      'Rate control (metoprolol), anticoagulation (warfarin)'),
(26, 22, 17, 20,   DATEADD(day,-35, CURRENT_TIMESTAMP()), 'Post Laparoscopic Appendectomy',        'Mild incision soreness',            'No complications, return to work in 1 week'),
(27, 23,  1, 21,   DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Musculoskeletal Chest Pain',            'Left-sided chest pain on movement', 'Reassurance, NSAIDs, stress test ordered'),
(28, 24,  4, 22,   DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Rotator Cuff Tear',                     'Shoulder pain, reduced ROM',        'Arthroscopic rotator cuff repair'),
(29, 25,  8, 23,   DATEADD(day,-14, CURRENT_TIMESTAMP()), 'Healthy Toddler',                       'None',                              'All milestones met, continue routine follow-up'),
(30, 26, 12, 24,   DATEADD(day,-80, CURRENT_TIMESTAMP()), 'Non-Small Cell Lung Cancer Stage IIIA', 'Haemoptysis, weight loss',          'Concurrent chemoradiation - cisplatin/etoposide'),
(31, 27,  7, 25,   DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Rib Fractures (multiple)',              'Chest pain on breathing, ecchymosis','Pain management, chest physiotherapy'),
(32, 28,  1, 26,   DATEADD(day,-28, CURRENT_TIMESTAMP()), 'Unstable Angina',                       'Chest pain at rest',                'Angiogram, PCI/CABG depending on stenosis'),
(33, 29, 25, 27,   DATEADD(day,-32, CURRENT_TIMESTAMP()), 'Chronic Migraine',                      'Unilateral throbbing headache 3x/week','Topiramate (preventive), sumatriptan (acute)'),
(34, 31, 30, 29,   DATEADD(day,-65, CURRENT_TIMESTAMP()), 'Gestational Diabetes',                  'Elevated fasting glucose at 28 weeks','Diet modification, insulin therapy if needed'),
(35, 32, 11, 30,   DATEADD(day,-48, CURRENT_TIMESTAMP()), 'Generalised Tonic-Clonic Epilepsy',     'Status epilepticus episode',        'Valproate, EEG, driving ban'),
(36, 33, 17, 31,   DATEADD(day,-38, CURRENT_TIMESTAMP()), 'Cholelithiasis (Gallstones)',            'RUQ pain after fatty meals, nausea','Laparoscopic cholecystectomy'),
(37, 34,  6, 32,   DATEADD(day,-17, CURRENT_TIMESTAMP()), 'Renal Calculus (Kidney Stone)',         'Severe flank pain, haematuria',     'IV fluids, analgesics, urological referral'),
(38, 35,  8, 33,   DATEADD(day,-20, CURRENT_TIMESTAMP()), 'Moderate Persistent Asthma',            'Wheeze, nocturnal cough',           'ICS/LABA inhaler, salbutamol PRN, allergen avoidance'),
(39, 36,  5, 34,   DATEADD(day,-42, CURRENT_TIMESTAMP()), 'Severe Osteoarthritis - Left Knee',     'Pain, stiffness, crepitus',         'Total knee arthroplasty'),
(40, 37, 21, 35,   DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Acne Vulgaris - Moderate',              'Papules, pustules on face and back','Clindamycin topical + adapalene gel'),
(41, 38, 10, 36,   DATEADD(day,-25, CURRENT_TIMESTAMP()), 'Parkinson Disease - Early Stage',       'Tremor, bradykinesia, mild rigidity','Levodopa-carbidopa initiated'),
(42, 39, 20, 37,   DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Polycystic Ovary Syndrome (PCOS)',      'Irregular periods, hirsutism',      'Metformin, combined OCP, lifestyle modification'),
(43, 40,  2, 38,   DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Congestive Heart Failure (CHF) EF 30%','Ankle oedema, dyspnoea, orthopnoea','Furosemide, ACE inhibitor, spironolactone, salt restriction'),
(44, 41, 21, 39,   DATEADD(day,-18, CURRENT_TIMESTAMP()), 'Plaque Psoriasis - Moderate',          'Silvery plaques on elbows and knees','IL-17 inhibitor biologic therapy'),
(45, 42,  4, 40,   DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Lumbar Disc Herniation L4-L5',         'Low back pain radiating to leg',    'Physiotherapy, NSAIDs, epidural steroid injection'),
(46, 43,  3, 41,   DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Supraventricular Tachycardia (SVT)',   'Sudden rapid palpitations',         'Valsalva, IV adenosine if needed, Holter monitor'),
(47, 45,  9, 43,   DATEADD(day,-40, CURRENT_TIMESTAMP()), 'Innocent Heart Murmur',                'Asymptomatic murmur on auscultation','No treatment required, reassure parents, follow-up in 12m'),
(48, 46,  1, 44,   DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Stable Coronary Artery Disease',        'Exertional chest pain',             'Aspirin 75mg, atorvastatin, metoprolol, lifestyle change'),
(49, 47, 22, 45,   DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'Benign Skin Tags (Acrochordons)',       'Pedunculated lesions neck/axilla',  'Excision under local anaesthetic'),
(50, 48,  6, 46,   DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Laceration - Right Hand',              'Clean 3cm cut from accident',       'Wound closure with 4 non-absorbable sutures'),
(51, 49,  8, 47,   DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Normal Infant Development (6 months)', 'No concerns',                       'Continue breastfeeding, introduce solids at 6m'),
(52, 50,  3, 48,   DATEADD(day,-70, CURRENT_TIMESTAMP()), 'Essential Hypertension',               'BP 158/94 on 3 readings',           'Amlodipine 5mg, DASH diet, exercise 150min/week'),
(53, 51,  1, NULL, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Hypertrophic Cardiomyopathy (HCM)',    'Syncope, exertional dyspnoea',      'Beta blocker, ICD referral, sports restriction'),
(54, 52, 10, NULL, DATEADD(day,-33, CURRENT_TIMESTAMP()), 'Multiple Sclerosis - Relapsing Remitting','Visual disturbance, limb weakness','Interferon beta-1a, physiotherapy'),
(55, 53,  9, NULL, DATEADD(day,-28, CURRENT_TIMESTAMP()), 'Supraventricular Tachycardia (SVT)',   'Intermittent palpitations',         'Propranolol, Holter monitor'),
(56, 54,  2, NULL, DATEADD(day,-70, CURRENT_TIMESTAMP()), 'Triple-Vessel Coronary Artery Disease','Chest pain, ST changes on ETT',     'Coronary artery bypass graft surgery'),
(57, 55, 20, NULL, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Menorrhagia',                          'Heavy prolonged periods',           'Tranexamic acid, USS pelvis, referral to gynaecology'),
(58, 56,  5, NULL, DATEADD(day,-45, CURRENT_TIMESTAMP()), 'ACL Tear - Left Knee',                 'Sudden knee giving way during sport','ACL reconstruction, post-op rehab program'),
(59, 57,  3, NULL, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Paroxysmal A-Fib',                     'Episodic palpitations, dizziness',  'Flecainide, warfarin, cardioversion if needed'),
(60, 58,  1, NULL, DATEADD(day,-80, CURRENT_TIMESTAMP()), 'Heart Block - Second Degree',          'Bradycardia, presyncope',           'Permanent pacemaker implantation');


-- =============================================================================
-- 11. MEDICATIONS  (30 rows)
-- =============================================================================
INSERT INTO medications (Medication_ID, Name, Brand, Description, Unit_Cost, Stock_Quantity) VALUES
( 1, 'Metoprolol Succinate',         'Toprol-XL',     'Beta-blocker for hypertension/arrhythmia',     15.50,  500),
( 2, 'Oxycodone HCl',                'OxyContin',     'Opioid analgesic for moderate-severe pain',     25.00,  200),
( 3, 'Ibuprofen',                    'Advil',          'NSAID anti-inflammatory/analgesic',              2.00, 5000),
( 4, 'Amoxicillin',                  'Amoxil',         'Broad-spectrum penicillin antibiotic',           8.50, 1000),
( 5, 'Atorvastatin',                 'Lipitor',         'Statin for LDL cholesterol reduction',         12.00,  800),
( 6, 'Warfarin Sodium',              'Coumadin',        'Vitamin K antagonist anticoagulant',            9.00,  400),
( 7, 'Metformin HCl',                'Glucophage',      'Biguanide for Type 2 Diabetes',                 5.00,  900),
( 8, 'Amlodipine',                   'Norvasc',         'Calcium channel blocker for hypertension',     11.00,  600),
( 9, 'Lisinopril',                   'Zestril',         'ACE inhibitor for hypertension/heart failure',  8.00,  700),
(10, 'Furosemide',                   'Lasix',           'Loop diuretic for oedema/heart failure',        6.50,  500),
(11, 'Levetiracetam',                'Keppra',          'Antiepileptic for partial/tonic-clonic seizures',22.00, 300),
(12, 'Valproate Sodium',             'Depakote',        'Antiepileptic, mood stabiliser',               18.00,  250),
(13, 'Temozolomide',                 'Temodar',         'Alkylating agent for GBM/astrocytoma',        180.00,   80),
(14, 'Dexamethasone',                'Decadron',        'Corticosteroid for inflammation/cerebral oedema',7.00,  450),
(15, 'Sumatriptan',                  'Imitrex',         'Triptan for acute migraine relief',             30.00,  350),
(16, 'Topiramate',                   'Topamax',         'Antiepileptic / migraine prophylaxis',          20.00,  300),
(17, 'Salbutamol (Albuterol)',       'Ventolin',        'Short-acting beta-2 agonist bronchodilator',   10.00,  800),
(18, 'Fluticasone/Salmeterol',       'Advair Diskus',   'ICS/LABA combination inhaler for asthma/COPD', 95.00, 200),
(19, 'Levodopa/Carbidopa',           'Sinemet',         'Dopamine precursor for Parkinson disease',      35.00, 250),
(20, 'Gemcitabine',                  'Gemzar',          'Nucleoside analogue chemotherapy agent',       220.00,  60),
(21, 'Cisplatin',                    'Platinol',        'Platinum-based chemotherapy agent',            180.00,  70),
(22, 'Doxorubicin',                  'Adriamycin',      'Anthracycline chemotherapy for various cancers',200.00, 50),
(23, 'Clindamycin Phosphate',        'Cleocin-T',       'Topical antibiotic for acne vulgaris',           8.00,  600),
(24, 'Adapalene',                    'Differin',        'Retinoid for acne vulgaris',                    12.50, 400),
(25, 'Tranexamic Acid',              'Cyklokapron',     'Antifibrinolytic for heavy menstrual bleeding',  9.00,  350),
(26, 'Flecainide Acetate',           'Tambocor',        'Class IC antiarrhythmic for A-fib',             28.00, 200),
(27, 'Spironolactone',               'Aldactone',       'Aldosterone antagonist / potassium-sparing diuretic',7.50,450),
(28, 'Aspirin (Low Dose)',           'Bayer',           'Antiplatelet for cardiovascular prevention',     1.50, 3000),
(29, 'Epinephrine (EpiPen)',         'EpiPen',          'Auto-injector for anaphylaxis',                 65.00, 150),
(30, 'Ondansetron',                  'Zofran',          'Serotonin antagonist antiemetic',               14.00, 500);


-- =============================================================================
-- 12. PRESCRIPTIONS  (80 rows)
-- =============================================================================
INSERT INTO prescriptions (Prescription_ID, Medical_Record_ID, Medication_ID, Dosage, Frequency, Duration_Days) VALUES
-- Cardiology / Arrhythmia records
( 1,  1,  1, '50mg',    'Twice daily',        30),
( 2,  1, 28, '75mg',    'Once daily',         90),
( 3, 23, 28, '75mg',    'Once daily',        180),
( 4, 23,  5, '40mg',    'Once daily',        180),
( 5, 23,  9, '10mg',    'Once daily',        180),
( 6, 25, 26, '100mg',   'Twice daily',        60),
( 7, 25,  6, '5mg',     'Once daily',         90),
( 8, 32,  1, '25mg',    'Once daily',         30),
( 9, 43, 10, '40mg',    'Once daily',         90),
(10, 43,  9, '5mg',     'Once daily',         90),
(11, 43, 27, '25mg',    'Once daily',         90),
(12, 43, 28, '75mg',    'Once daily',        365),
(13, 46,  1, '25mg',    'Twice daily',        30),
(14, 48, 28, '75mg',    'Once daily',        180),
(15, 48,  5, '20mg',    'Once daily',        365),
(16, 48,  1, '50mg',    'Once daily',        365),
(17, 53,  1, '100mg',   'Once daily',        180),
(18, 56, 28, '75mg',    'Once daily',        365),
(19, 56,  5, '40mg',    'Once daily',        365),
(20, 57, 26, '100mg',   'Twice daily',        90),
(21, 57,  6, '5mg',     'Once daily',        180),
(22, 58,  8, '5mg',     'Once daily',        180),
(23, 60,  9, '5mg',     'Once daily',        365),
-- Neurology records
(24, 15, 11, '1000mg',  'Twice daily',       365),
(25, 17, 13, '150mg',   'Once daily',         42),
(26, 17, 14, '4mg',     'Three times daily',  14),
(27, 33, 15, '50mg',    'As needed (max 2x)', 30),
(28, 33, 16, '25mg',    'Once nightly',      180),
(29, 35, 12, '500mg',   'Twice daily',       365),
(30, 41, 19, '25/100mg','Three times daily',  90),
(31, 52, 11, '500mg',   'Twice daily',       180),
(32, 54, 14, '4mg',     'Twice daily',        14),
-- Oncology records
(33,  5, 22, '60mg/m²', 'IV every 3 weeks',   84),
(34, 16, 20, '1000mg/m²','IV weekly x 7',     56),
(35, 30, 21, '75mg/m²', 'IV day 1 each cycle',63),
(36, 30, 14, '4mg',     'Daily during chemo', 63),
-- Pain / Ortho records
(37,  2,  2, '10mg',    'Every 6 hours',       7),
(38,  2,  3, '400mg',   'Every 8 hours',      14),
(39,  9,  3, '400mg',   'Every 8 hours',      10),
(40, 31,  2, '5mg',     'Every 6 hours PRN',   5),
(41, 31,  3, '600mg',   'Every 8 hours',      10),
(42, 45,  3, '600mg',   'Twice daily',        21),
(43, 45, 14, '4mg',     'Once daily',          5),
-- Pulmonology / Asthma
(44, 38, 17, '2 puffs', 'Every 4 hours PRN',  30),
(45, 38, 18, '1 puff',  'Twice daily',        90),
-- OB/GYN records
(46, 13, 30, '4mg',     'Every 8 hours PRN',  30),
(47, 34,  7, '500mg',   'Twice daily',        90),
(48, 42,  7, '500mg',   'Twice daily',       180),
(49, 55, 25, '500mg',   'Twice daily (day 1-5 of cycle)', 90),
-- Dermatology records
(50, 40, 23, 'Apply thin layer', 'Twice daily', 60),
(51, 40, 24, 'Apply thin layer', 'Once nightly',60),
-- Infection / Post-op / ER records
(52,  4,  4, '500mg',   'Three times daily',  10),
(53,  6,  4, '625mg',   'Three times daily',   7),
(54, 14,  4, '500mg',   'Three times daily',   5),
(55, 21,  4, '500mg',   'Three times daily',   7),
(56, 36,  4, '500mg',   'Three times daily',   5),
-- CHF / Hypertension
(57, 52,  8, '5mg',     'Once daily',         90),
(58, 37,  3, '400mg',   'Every 8 hours',       5),
(59, 12, 28, '75mg',    'Once daily',         30),
(60, 12,  5, '20mg',    'Once daily',         30),
-- Antiemetics for chemo
(61,  5, 30, '8mg',     'Before chemo IV',     5),
(62, 16, 30, '8mg',     'Before chemo IV',     5),
(63, 30, 30, '8mg',     'Before chemo IV',     5),
-- Allergy
(64, 18, 29, '0.3mg',   'Self-administer IM if anaphylaxis', 365),
-- Additional prescriptions for variety
(65, 11,  3, '400mg',   'Three times daily',   7),
(66, 24,  2, '5mg',     'Every 8 hours PRN',   4),
(67, 24, 30, '4mg',     'Twice daily',          3),
(68, 29, 30, '4mg',     'As needed',            5),
(69, 39,  5, '20mg',    'Once daily',          30),
(70, 39,  9, '10mg',    'Once daily',          30),
(71, 50,  4, '500mg',   'Three times daily',   5),
(72, 44, 14, '4mg',     'Twice daily (loading)',7),
(73, 10,  3, '400mg',   'Twice daily',         10),
(74, 26,  4, '625mg',   'Three times daily',   5),
(75, 27,  3, '400mg',   'Twice daily',         7),
(76,  7,  2, '10mg',    'Every 6 hours',       3),
(77,  7, 30, '4mg',     'IV every 8 hours',    3),
(78, 19,  3, '400mg',   'Three times daily',  10),
(79, 19,  4, '625mg',   'Three times daily',   7),
(80, 51, 30, '4mg',     'As needed',           5);


-- =============================================================================
-- 13. LAB TESTS  (20 rows)
-- =============================================================================
INSERT INTO lab_tests (Test_ID, Test_Name, Description, Cost, Normal_Range) VALUES
( 1, 'Complete Blood Count (CBC)',                 'Full haematological panel',                         55.00, 'WBC 4-11 x10³, Hb 12-17 g/dL, Plt 150-400 x10³'),
( 2, 'Basic Metabolic Panel (BMP)',                'Electrolytes, glucose, BUN, creatinine',            45.00, 'Glucose 70-100 mg/dL, Na 136-145, K 3.5-5.0'),
( 3, 'Electrocardiogram (12-lead ECG)',            'Electrical activity of the heart',                 150.00, 'Normal sinus rhythm, rate 60-100 bpm'),
( 4, 'X-Ray - Lower Limb',                         'Plain radiograph of leg/knee/foot',               200.00, 'No fracture or dislocation'),
( 5, 'CT Scan - Head',                             'Computed tomography of brain',                    800.00, 'No acute intracranial abnormality'),
( 6, 'MRI - Brain',                                'Magnetic resonance imaging of brain/spine',      1200.00, 'No mass lesion or signal abnormality'),
( 7, 'MRI - Musculoskeletal',                      'MRI of joint/soft tissue',                        900.00, 'No ligament tear or erosion'),
( 8, 'Lipid Panel',                                'Total cholesterol, LDL, HDL, triglycerides',       40.00, 'Total <200, LDL <100, HDL >40 mg/dL'),
( 9, 'Liver Function Tests (LFT)',                 'ALT, AST, ALP, bilirubin, albumin',                50.00, 'ALT 7-56, AST 10-40 U/L, Bili <1.2 mg/dL'),
(10, 'Thyroid Function Tests (TFT)',               'TSH, free T3, free T4',                            60.00, 'TSH 0.4-4.0 mIU/L, FT4 0.8-1.8 ng/dL'),
(11, 'HbA1c',                                     'Glycated haemoglobin - 3-month glucose average',   35.00, '<5.7% (normal), 5.7-6.4% (prediabetes)'),
(12, 'Urine Culture & Sensitivity',               'Identifies urinary tract infection organism',       55.00, 'No growth (sterile)'),
(13, 'Chest X-Ray (PA)',                           'Posterior-anterior radiograph of chest',          180.00, 'Clear lung fields, no cardiomegaly'),
(14, 'Echocardiogram (TTE)',                       'Transthoracic ultrasound of heart',               500.00, 'EF >55%, no wall motion abnormality'),
(15, 'Abdominal Ultrasound',                       'Ultrasound of liver, gallbladder, pancreas, kidneys',250.00,'No cholelithiasis, normal organ size'),
(16, 'Tumour Markers Panel (CA-125, CEA, AFP)',    'Cancer antigen screen',                           120.00, 'CEA <2.5, CA-125 <35, AFP <8.1 ng/mL'),
(17, 'Coagulation Profile (PT/INR, aPTT)',         'Bleeding and clotting assessment',                 65.00, 'PT 11-13s, INR 0.8-1.2, aPTT 25-35s'),
(18, 'Arterial Blood Gas (ABG)',                   'Blood pH, pO2, pCO2, bicarbonate',                 80.00, 'pH 7.35-7.45, pO2 75-100, pCO2 35-45 mmHg'),
(19, 'EEG (Electroencephalogram)',                 'Brain electrical activity for seizure evaluation', 350.00, 'Normal background activity, no epileptiform discharges'),
(20, 'Bone Density Scan (DEXA)',                   'T-score bone mineral density measurement',        300.00, 'T-score > -1.0 (normal)');


-- =============================================================================
-- 14. TEST RESULTS  (80 rows)
-- =============================================================================
INSERT INTO test_results (Result_ID, Patient_ID, Doctor_ID, Test_ID, Test_Date, Result_Value, Is_Abnormal, Notes) VALUES
-- Cardiology patients
( 1,  1,  1,  3, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'Irregular rhythm - premature atrial contractions', TRUE,  'Rate 58 bpm, PACs noted'),
( 2,  1,  1, 14, DATEADD(day,-4,  CURRENT_TIMESTAMP()), 'EF 48% - mildly reduced',                          TRUE,  'Mild systolic dysfunction'),
( 3,  1,  1,  1, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'WBC 7.2, Hb 13.1, Plt 210',                       FALSE, 'Normal haematology'),
( 4,  4,  4,  4, DATEADD(day,-2,  CURRENT_TIMESTAMP()), 'Clear oblique fracture mid-shaft tibia',           TRUE,  'Displaced, surgical fixation required'),
( 5,  8, 10,  5, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Hypodense area L MCA territory - ischaemic stroke',TRUE,  'Lesion ~2.5cm, no haemorrhage'),
( 6,  8, 10,  6, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Large diffusion restriction L parieto-temporal',  TRUE,  'Correlates with clinical presentation'),
( 7, 12,  7,  1, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'WBC 18.4 (elevated), CRP 95',                     TRUE,  'Consistent with acute infection'),
( 8, 12,  7, 15, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'Dilated appendix 10mm, periappendiceal fat stranding',TRUE,'Confirms acute appendicitis'),
( 9, 18, 12,  1, DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'WBC 3.1 (low - post chemo nadir)',                TRUE,  'Neutropenia grade 2 - monitor'),
(10, 18, 12, 16, DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'CA-125 elevated at 89 U/mL',                      TRUE,  'Trending down from 210 before chemo'),
(11, 19,  1,  3, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'ST elevation in leads II, III, aVF - inferior STEMI',TRUE,'Emergency PCI performed'),
(12, 19,  1, 14, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'EF 38% - moderate dysfunction post-MI',           TRUE,  'Inferior wall hypokinesis'),
(13, 21,  3,  3, DATEADD(day,-18, CURRENT_TIMESTAMP()), 'Irregular rate 95 bpm - A-fib',                   TRUE,  'No P waves, irregularly irregular'),
(14, 23,  1,  3, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Normal sinus rhythm 72 bpm',                      FALSE, 'No ischaemic changes'),
(15, 26,  1, 13, DATEADD(day,-79, CURRENT_TIMESTAMP()), 'Left hilar mass 4.5cm, mediastinal widening',     TRUE,  'Biopsy confirmed NSCLC'),
(16, 28,  1,  3, DATEADD(day,-28, CURRENT_TIMESTAMP()), 'ST depression V4-V6 at rest',                     TRUE,  'Suggests subendocardial ischaemia'),
(17, 32,  2, 14, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'EF 30% - severely reduced',                       TRUE,  'Dilated cardiomyopathy'),
(18, 40,  7,  3, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'VF on presentation, reverted to sinus after shock',TRUE,  'Successfully resuscitated'),
(19, 43,  3,  3, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'SVT at 185 bpm, converted with Valsalva',         TRUE,  'Narrow complex tachycardia'),
(20, 46,  1,  3, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'Normal sinus rhythm, T-wave flattening in V5-V6', TRUE,  'Mild ischaemic changes'),
(21, 51,  1,  3, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Sinus tachycardia 110 bpm, LVH pattern',          TRUE,  'Compatible with HCM'),
(22, 51,  1, 14, DATEADD(day,-54, CURRENT_TIMESTAMP()), 'Septal hypertrophy 18mm, LVOTO gradient 45mmHg',  TRUE,  'Significant outflow obstruction'),
(23, 54,  2,  3, DATEADD(day,-70, CURRENT_TIMESTAMP()), 'ST depression leads I, II, aVL, V4-V6',           TRUE,  'Ischaemic pattern on ETT'),
(24, 57,  3,  3, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Paroxysmal A-fib detected, self-terminating',     TRUE,  'Episode 12 minutes on Holter'),
(25, 58,  1,  3, DATEADD(day,-80, CURRENT_TIMESTAMP()), 'Mobitz type II second degree heart block',        TRUE,  'Pacemaker indicated'),
(26, 60,  1,  3, DATEADD(day,-70, CURRENT_TIMESTAMP()), 'Normal sinus rhythm, no significant changes',     FALSE, 'Routine annual ECG'),
-- Neurology patients
(27,  8, 10, 19, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'Focal slowing L hemisphere, no seizure activity', TRUE,  'Consistent with acute stroke'),
(28, 11, 10, 19, DATEADD(day,-30, CURRENT_TIMESTAMP()), 'Interictal temporal spikes, L>R',                 TRUE,  'Temporal lobe epilepsy confirmed'),
(29, 13, 11,  6, DATEADD(day,-50, CURRENT_TIMESTAMP()), 'Ring-enhancing mass R frontal 4.2cm',             TRUE,  'GBM highly likely - biopsy performed'),
(30, 32, 11, 19, DATEADD(day,-48, CURRENT_TIMESTAMP()), 'Generalised spike-wave discharges 3Hz',           TRUE,  'Generalised epilepsy pattern'),
(31, 38, 10,  6, DATEADD(day,-25, CURRENT_TIMESTAMP()), 'T2 hyperintensities periventricular and juxtacortical',TRUE,'Consistent with MS plaques'),
(32, 52, 10,  5, DATEADD(day,-33, CURRENT_TIMESTAMP()), 'No acute haemorrhage, small chronic changes',     FALSE, 'Background MS lesions only'),
(33, 55,  9, 14, DATEADD(day,-28, CURRENT_TIMESTAMP()), 'Normal EF, no structural abnormality',            FALSE, 'Murmur - functional/innocent'),
(34, 29, 25,  5, DATEADD(day,-32, CURRENT_TIMESTAMP()), 'No acute intracranial pathology',                 FALSE, 'Clear for migraine diagnosis'),
-- Orthopaedic patients
(35,  3,  4,  7, DATEADD(day,-7,  CURRENT_TIMESTAMP()), 'Complete medial meniscus tear, grade 3',          TRUE,  'Arthroscopic repair recommended'),
(36, 24,  4,  7, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'Full thickness rotator cuff tear, supraspinatus', TRUE,  'Surgical repair indicated'),
(37, 36,  5,  7, DATEADD(day,-42, CURRENT_TIMESTAMP()), 'Severe joint space narrowing, osteophytes',       TRUE,  'Bone-on-bone OA - surgery necessary'),
(38, 42,  4,  7, DATEADD(day,-30, CURRENT_TIMESTAMP()), 'L4-L5 disc protrusion, nerve root compression',  TRUE,  'Right S1 radiculopathy'),
(39, 56,  5,  7, DATEADD(day,-45, CURRENT_TIMESTAMP()), 'Complete ACL disruption, bone bruising',          TRUE,  'Reconstruction with hamstring graft'),
-- Oncology patients
(40, 13, 11, 16, DATEADD(day,-50, CURRENT_TIMESTAMP()), 'CEA 0.9, CA-125 8.2, AFP 1.1 - all normal',      FALSE, 'No serum marker elevation'),
(41, 26, 12, 13, DATEADD(day,-80, CURRENT_TIMESTAMP()), 'Left hilar mass 4.5cm, atelectasis LLL',         TRUE,  'Highly suspicious for malignancy'),
(42, 26, 12, 16, DATEADD(day,-79, CURRENT_TIMESTAMP()), 'CEA 18.5 (elevated), CA-125 22',                 TRUE,  'CEA elevated - supports lung cancer'),
(43, 30, 12, 16, DATEADD(day,-74, CURRENT_TIMESTAMP()), 'CEA 32.1, CA-125 45 - both elevated',            TRUE,  'Tumour markers tracking on treatment'),
-- General lab results
(44,  2,  8,  1, DATEADD(day,-15, CURRENT_TIMESTAMP()), 'WBC 6.8, Hb 13.5, Plt 255 - all normal',        FALSE, 'Healthy haematology'),
(45,  2,  8,  8, DATEADD(day,-15, CURRENT_TIMESTAMP()), 'Total Chol 185, LDL 102, HDL 55 - optimal',      FALSE, 'Good lipid profile'),
(46,  6, 21,  1, DATEADD(day,-20, CURRENT_TIMESTAMP()), 'WBC 9.1, Hb 14.2, Plt 315 - normal',            FALSE, 'No infection markers'),
(47,  9, 19,  1, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'WBC 8.4, Hb 11.2 (slightly low - pregnancy)',    TRUE,  'Iron supplementation advised'),
(48, 31, 30, 11, DATEADD(day,-65, CURRENT_TIMESTAMP()), 'HbA1c 6.8% - above normal for pregnancy',       TRUE,  'Gestational diabetes confirmed'),
(49, 34,  6,  2, DATEADD(day,-17, CURRENT_TIMESTAMP()), 'Creatinine 1.1, Na 138, K 3.9 - normal',        FALSE, 'Normal renal function'),
(50, 34,  6, 12, DATEADD(day,-17, CURRENT_TIMESTAMP()), 'E. coli 10^5 CFU/mL - UTI',                     TRUE,  'Sensitive to trimethoprim-sulfa'),
(51, 35,  8, 18, DATEADD(day,-2,  CURRENT_TIMESTAMP()), 'pH 7.32, pO2 68, pCO2 48 - respiratory acidosis',TRUE,  'Indicates inadequate ventilation - asthma exacerbation'),
(52, 39, 20, 15, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'Bulky ovaries, multiple follicles, thickened endometrium',TRUE,'Compatible with PCOS'),
(53, 40,  2,  1, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'Hb 10.2 - anaemia, Plt 450 - elevated',         TRUE,  'Anaemia of chronic disease in CHF'),
(54, 41, 21,  1, DATEADD(day,-18, CURRENT_TIMESTAMP()), 'WBC 7.5, Hb 13.8, normal counts',               FALSE, 'Routine check for biologic therapy'),
(55, 44, 17,  1, DATEADD(day,-12, CURRENT_TIMESTAMP()), 'WBC 8.9, Hb 14.1, Plt 280 - normal',            FALSE, 'No contraindications for surgery'),
(56, 45,  9,  1, DATEADD(day,-40, CURRENT_TIMESTAMP()), 'WBC 7.2, Hb 12.5, Plt 230 - all normal',        FALSE, 'Healthy child, no abnormalities'),
(57, 47, 22,  1, DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'Normal CBC',                                     FALSE, 'Pre-procedure baseline'),
(58, 48,  6,  1, DATEADD(day,-3,  CURRENT_TIMESTAMP()), 'WBC 11.2 (mildly elevated)',                     TRUE,  'Inflammatory response to wound'),
(59, 50,  3,  2, DATEADD(day,-70, CURRENT_TIMESTAMP()), 'BP 162/98, Na 140, K 4.1 - electrolytes normal', TRUE,  'Hypertension confirmed, kidneys normal'),
(60, 53,  1,  8, DATEADD(day,-33, CURRENT_TIMESTAMP()), 'Total Chol 242, LDL 158 - elevated',             TRUE,  'Dyslipidaemia, statin therapy indicated'),
(61, 15, 17,  1, DATEADD(day,-35, CURRENT_TIMESTAMP()), 'WBC 9.4, Hb 14.0 - normal',                     FALSE, 'Pre-op workup - cleared'),
(62, 17,  7,  4, DATEADD(day,-12, CURRENT_TIMESTAMP()), 'No rib fracture on X-ray, soft tissue bruising', FALSE, 'Contusion confirmed, no bony injury'),
(63, 20, 18,  1, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'WBC 5.4, Hb 12.8 - normal',                     FALSE, 'Pre-op bloods for bowel surgery'),
(64, 22, 17,  1, DATEADD(day,-4,  CURRENT_TIMESTAMP()), 'WBC 7.1, Hb 13.9 - normal recovery',            FALSE, 'Post-op day 1, recovering well'),
(65, 25,  8,  1, DATEADD(day,-14, CURRENT_TIMESTAMP()), 'WBC 9.8, Hb 12.0 - within normal limits',       FALSE, 'Post-op tonsillectomy check'),
(66, 27,  7, 13, DATEADD(day,-9,  CURRENT_TIMESTAMP()), 'Multiple rib fractures bilateral, no pneumothorax',TRUE,'Consistent with high-energy trauma'),
(67, 33, 17, 15, DATEADD(day,-38, CURRENT_TIMESTAMP()), 'Gallbladder thickened, multiple calculi',        TRUE,  'Cholelithiasis confirmed, largest stone 12mm'),
(68, 37, 17,  9, DATEADD(day,-17, CURRENT_TIMESTAMP()), 'ALT 42, AST 38 - borderline',                   TRUE,  'Mildly elevated, consistent with pain/NSAID use'),
(69, 39, 20, 10, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'TSH 3.2 - normal',                              FALSE, 'Euthyroid, no thyroid contribution to PCOS'),
(70, 43,  2,  2, DATEADD(day,-55, CURRENT_TIMESTAMP()), 'BNP 820 pg/mL (very elevated)',                  TRUE,  'Confirms fluid overload in CHF'),
(71, 46,  1,  8, DATEADD(day,-60, CURRENT_TIMESTAMP()), 'LDL 118, HDL 38 - suboptimal profile',           TRUE,  'Statin therapy to be intensified'),
(72,  5,  6,  1, DATEADD(day,-10, CURRENT_TIMESTAMP()), 'All normal limits - WBC, Hb, Plt',               FALSE, 'Routine annual check'),
(73, 10, 17,  9, DATEADD(day,-5,  CURRENT_TIMESTAMP()), 'ALT 28, AST 22, Bili 0.7 - all normal',         FALSE, 'No hepatic complications post-op'),
(74, 14,  6,  1, DATEADD(day,-8,  CURRENT_TIMESTAMP()), 'WBC 13.2 (elevated - reaction)',                 TRUE,  'Leucocytosis consistent with anaphylaxis'),
(75, 16, 12,  9, DATEADD(day,-25, CURRENT_TIMESTAMP()), 'ALT 65, AST 58 - mildly elevated',              TRUE,  'Chemo-related hepatotoxicity grade 1'),
(76, 21,  3, 17, DATEADD(day,-18, CURRENT_TIMESTAMP()), 'INR 2.4 - therapeutic range for A-fib',         FALSE, 'Warfarin dose appropriate'),
(77,  7,  7,  1, DATEADD(day,-1,  CURRENT_TIMESTAMP()), 'WBC 12.1, Hb 12.8 - stress response',           TRUE,  'Leukocytosis post cardiac arrest'),
(78, 30, 12,  1, DATEADD(day,-74, CURRENT_TIMESTAMP()), 'WBC 3.8 (low - chemo effect)',                  TRUE,  'Chemo-induced neutropenia, G-CSF given'),
(79,  4,  4,  1, DATEADD(day,-2,  CURRENT_TIMESTAMP()), 'WBC 10.4, Hb 13.2, Plt 190 - normal',          FALSE, 'Pre-surgical bloods cleared'),
(80, 49,  8,  1, DATEADD(day,-22, CURRENT_TIMESTAMP()), 'WBC 8.1, Hb 11.8 - slightly low for infant age',TRUE,  'Iron-rich foods to be introduced');


-- =============================================================================
-- 15. BILLING  (60 rows)
-- =============================================================================
INSERT INTO billing (Bill_ID, Patient_ID, Admission_ID, Appointment_ID, Total_Amount, Insurance_Covered, Patient_Owed, Status, Billing_Date, Due_Date) VALUES
-- Admission bills
( 1,  1,  1, NULL, 6000.00,  5500.00,   500.00, 'Unpaid',  DATEADD(day,-5,  CURRENT_TIMESTAMP()), DATEADD(day,25, CURRENT_TIMESTAMP())),
( 2,  4,  2, NULL, 4500.00,  3600.00,   900.00, 'Partial', DATEADD(day,-2,  CURRENT_TIMESTAMP()), DATEADD(day,28, CURRENT_TIMESTAMP())),
( 3,  8,  3, NULL, 5400.00,  4000.00,  1400.00, 'Unpaid',  DATEADD(day,-3,  CURRENT_TIMESTAMP()), DATEADD(day,27, CURRENT_TIMESTAMP())),
( 4, 12,  4, NULL, 3200.00,  2800.00,   400.00, 'Unpaid',  DATEADD(day,-1,  CURRENT_TIMESTAMP()), DATEADD(day,29, CURRENT_TIMESTAMP())),
( 5, 18,  5, NULL,12500.00, 11000.00,  1500.00, 'Partial', DATEADD(day,-7,  CURRENT_TIMESTAMP()), DATEADD(day,23, CURRENT_TIMESTAMP())),
( 6, 22,  6, NULL, 2800.00,  2500.00,   300.00, 'Unpaid',  DATEADD(day,-4,  CURRENT_TIMESTAMP()), DATEADD(day,26, CURRENT_TIMESTAMP())),
( 7, 30,  7, NULL, 9000.00,  7500.00,  1500.00, 'Unpaid',  DATEADD(day,-6,  CURRENT_TIMESTAMP()), DATEADD(day,24, CURRENT_TIMESTAMP())),
( 8, 35,  8, NULL, 1600.00,  1200.00,   400.00, 'Unpaid',  DATEADD(day,-2,  CURRENT_TIMESTAMP()), DATEADD(day,28, CURRENT_TIMESTAMP())),
( 9, 40,  9, NULL,11000.00,  9500.00,  1500.00, 'Unpaid',  DATEADD(day,-1,  CURRENT_TIMESTAMP()), DATEADD(day,29, CURRENT_TIMESTAMP())),
(10, 45, 10, NULL, 4500.00,  2000.00,  2500.00, 'Unpaid',  DATEADD(day,-3,  CURRENT_TIMESTAMP()), DATEADD(day,27, CURRENT_TIMESTAMP())),
-- Discharged admission bills
(11,  5, 11, NULL, 2000.00,     0.00,  2000.00, 'Paid',    DATEADD(day,-10, CURRENT_TIMESTAMP()), DATEADD(day,-1, CURRENT_TIMESTAMP())),
(12,  2, 12, NULL, 7200.00,  6800.00,   400.00, 'Paid',    DATEADD(day,-24, CURRENT_TIMESTAMP()), DATEADD(day, 6, CURRENT_TIMESTAMP())),
(13,  3, 13, NULL, 1800.00,  1500.00,   300.00, 'Paid',    DATEADD(day,-42, CURRENT_TIMESTAMP()), DATEADD(day,-12,CURRENT_TIMESTAMP())),
(14,  6, 14, NULL, 5500.00,  4500.00,  1000.00, 'Paid',    DATEADD(day,-18, CURRENT_TIMESTAMP()), DATEADD(day, 2, CURRENT_TIMESTAMP())),
(15,  7, 15, NULL,10000.00,  8500.00,  1500.00, 'Paid',    DATEADD(day,-55, CURRENT_TIMESTAMP()), DATEADD(day,-25,CURRENT_TIMESTAMP())),
(16,  9, 16, NULL, 3000.00,  2400.00,   600.00, 'Paid',    DATEADD(day,-88, CURRENT_TIMESTAMP()), DATEADD(day,-58,CURRENT_TIMESTAMP())),
(17, 10, 17, NULL, 2600.00,  2200.00,   400.00, 'Paid',    DATEADD(day,-13, CURRENT_TIMESTAMP()), DATEADD(day, 17,CURRENT_TIMESTAMP())),
(18, 11, 18, NULL, 4600.00,  1000.00,  3600.00, 'Partial', DATEADD(day,-46, CURRENT_TIMESTAMP()), DATEADD(day,-16,CURRENT_TIMESTAMP())),
(19, 13, 19, NULL, 9500.00,  7000.00,  2500.00, 'Paid',    DATEADD(day,-22, CURRENT_TIMESTAMP()), DATEADD(day, 8, CURRENT_TIMESTAMP())),
(20, 14, 20, NULL,  900.00,   700.00,   200.00, 'Paid',    DATEADD(day,-7,  CURRENT_TIMESTAMP()), DATEADD(day,23, CURRENT_TIMESTAMP())),
(21, 15, 21, NULL, 3500.00,  2800.00,   700.00, 'Paid',    DATEADD(day,-31, CURRENT_TIMESTAMP()), DATEADD(day,-1, CURRENT_TIMESTAMP())),
(22, 16, 22, NULL, 4000.00,  3200.00,   800.00, 'Paid',    DATEADD(day,-73, CURRENT_TIMESTAMP()), DATEADD(day,-43,CURRENT_TIMESTAMP())),
(23, 17, 23, NULL, 2000.00,  1800.00,   200.00, 'Paid',    DATEADD(day,-11, CURRENT_TIMESTAMP()), DATEADD(day,19, CURRENT_TIMESTAMP())),
(24, 19, 24, NULL, 9000.00,  7500.00,  1500.00, 'Paid',    DATEADD(day,-35, CURRENT_TIMESTAMP()), DATEADD(day,-5, CURRENT_TIMESTAMP())),
(25, 20, 25, NULL, 5500.00,  4000.00,  1500.00, 'Paid',    DATEADD(day,-51, CURRENT_TIMESTAMP()), DATEADD(day,-21,CURRENT_TIMESTAMP())),
(26, 21, 26, NULL, 3200.00,  2800.00,   400.00, 'Paid',    DATEADD(day,-16, CURRENT_TIMESTAMP()), DATEADD(day,14, CURRENT_TIMESTAMP())),
(27, 23, 27, NULL,  900.00,   800.00,   100.00, 'Paid',    DATEADD(day,-4,  CURRENT_TIMESTAMP()), DATEADD(day,26, CURRENT_TIMESTAMP())),
(28, 24, 28, NULL, 3300.00,  2600.00,   700.00, 'Paid',    DATEADD(day,-19, CURRENT_TIMESTAMP()), DATEADD(day,11, CURRENT_TIMESTAMP())),
(29, 25, 29, NULL,  800.00,   600.00,   200.00, 'Paid',    DATEADD(day,-12, CURRENT_TIMESTAMP()), DATEADD(day,18, CURRENT_TIMESTAMP())),
(30, 26, 30, NULL,18000.00, 15000.00,  3000.00, 'Partial', DATEADD(day,-74, CURRENT_TIMESTAMP()), DATEADD(day,-44,CURRENT_TIMESTAMP())),
(31, 27, 31, NULL, 2000.00,  1800.00,   200.00, 'Paid',    DATEADD(day,-8,  CURRENT_TIMESTAMP()), DATEADD(day,22, CURRENT_TIMESTAMP())),
(32, 28, 32, NULL, 9600.00,  8500.00,  1100.00, 'Paid',    DATEADD(day,-24, CURRENT_TIMESTAMP()), DATEADD(day, 6, CURRENT_TIMESTAMP())),
(33, 29, 33, NULL, 2100.00,  1600.00,   500.00, 'Paid',    DATEADD(day,-29, CURRENT_TIMESTAMP()), DATEADD(day, 1, CURRENT_TIMESTAMP())),
(34, 31, 34, NULL, 7800.00,  5500.00,  2300.00, 'Paid',    DATEADD(day,-62, CURRENT_TIMESTAMP()), DATEADD(day,-32,CURRENT_TIMESTAMP())),
(35, 32, 35, NULL, 4400.00,  3500.00,   900.00, 'Paid',    DATEADD(day,-44, CURRENT_TIMESTAMP()), DATEADD(day,-14,CURRENT_TIMESTAMP())),
(36, 33, 36, NULL, 2700.00,  2200.00,   500.00, 'Paid',    DATEADD(day,-35, CURRENT_TIMESTAMP()), DATEADD(day,-5, CURRENT_TIMESTAMP())),
(37, 34, 37, NULL, 2000.00,  1600.00,   400.00, 'Paid',    DATEADD(day,-16, CURRENT_TIMESTAMP()), DATEADD(day,14, CURRENT_TIMESTAMP())),
(38, 36, 38, NULL, 8400.00,  6000.00,  2400.00, 'Partial', DATEADD(day,-38, CURRENT_TIMESTAMP()), DATEADD(day,-8, CURRENT_TIMESTAMP())),
(39, 50, 39, NULL, 9000.00,  7200.00,  1800.00, 'Paid',    DATEADD(day,-16, CURRENT_TIMESTAMP()), DATEADD(day,14, CURRENT_TIMESTAMP())),
(40, 54, 40, NULL,22000.00, 18000.00,  4000.00, 'Paid',    DATEADD(day,-52, CURRENT_TIMESTAMP()), DATEADD(day,-22,CURRENT_TIMESTAMP())),
-- Appointment bills
(41,  2, NULL,  1,  150.00,   120.00,    30.00, 'Paid',    DATEADD(day,-15, CURRENT_TIMESTAMP()), DATEADD(day,15, CURRENT_TIMESTAMP())),
(42,  3, NULL,  2,  250.00,   180.00,    70.00, 'Unpaid',  DATEADD(day,-7,  CURRENT_TIMESTAMP()), DATEADD(day,23, CURRENT_TIMESTAMP())),
(43,  6, NULL,  4,  200.00,   160.00,    40.00, 'Paid',    DATEADD(day,-20, CURRENT_TIMESTAMP()), DATEADD(day,10, CURRENT_TIMESTAMP())),
(44,  7, NULL,  5,  150.00,     0.00,   150.00, 'Paid',    DATEADD(day,-45, CURRENT_TIMESTAMP()), DATEADD(day,-15,CURRENT_TIMESTAMP())),
(45,  8, NULL,  6,  400.00,   350.00,    50.00, 'Paid',    DATEADD(day,-10, CURRENT_TIMESTAMP()), DATEADD(day,20, CURRENT_TIMESTAMP())),
(46,  9, NULL,  7,  180.00,   150.00,    30.00, 'Paid',    DATEADD(day,-60, CURRENT_TIMESTAMP()), DATEADD(day,-30,CURRENT_TIMESTAMP())),
(47, 11, NULL,  9,  300.00,     0.00,   300.00, 'Paid',    DATEADD(day,-30, CURRENT_TIMESTAMP()), CURRENT_TIMESTAMP()),
(48, 12, NULL, 10,  250.00,   200.00,    50.00, 'Paid',    DATEADD(day,-25, CURRENT_TIMESTAMP()), DATEADD(day, 5, CURRENT_TIMESTAMP())),
(49, 13, NULL, 11, 1200.00,   900.00,   300.00, 'Paid',    DATEADD(day,-50, CURRENT_TIMESTAMP()), DATEADD(day,-20,CURRENT_TIMESTAMP())),
(50, 14, NULL, 12,  350.00,   280.00,    70.00, 'Paid',    DATEADD(day,-8,  CURRENT_TIMESTAMP()), DATEADD(day,22, CURRENT_TIMESTAMP())),
(51, 15, NULL, 13,  200.00,   160.00,    40.00, 'Paid',    DATEADD(day,-35, CURRENT_TIMESTAMP()), DATEADD(day,-5, CURRENT_TIMESTAMP())),
(52, 16, NULL, 14,  175.00,   140.00,    35.00, 'Paid',    DATEADD(day,-75, CURRENT_TIMESTAMP()), DATEADD(day,-45,CURRENT_TIMESTAMP())),
(53, 18, NULL, 16,  350.00,   280.00,    70.00, 'Paid',    DATEADD(day,-40, CURRENT_TIMESTAMP()), DATEADD(day,-10,CURRENT_TIMESTAMP())),
(54, 21, NULL, 19,  250.00,   200.00,    50.00, 'Paid',    DATEADD(day,-18, CURRENT_TIMESTAMP()), DATEADD(day,12, CURRENT_TIMESTAMP())),
(55, 26, NULL, 24, 1500.00,  1200.00,   300.00, 'Paid',    DATEADD(day,-80, CURRENT_TIMESTAMP()), DATEADD(day,-50,CURRENT_TIMESTAMP())),
(56, 29, NULL, 27,  250.00,   200.00,    50.00, 'Paid',    DATEADD(day,-32, CURRENT_TIMESTAMP()), DATEADD(day,-2, CURRENT_TIMESTAMP())),
(57, 35, NULL, 33,  150.00,   120.00,    30.00, 'Paid',    DATEADD(day,-20, CURRENT_TIMESTAMP()), DATEADD(day,10, CURRENT_TIMESTAMP())),
(58, 37, NULL, 35,  200.00,   160.00,    40.00, 'Paid',    DATEADD(day,-15, CURRENT_TIMESTAMP()), DATEADD(day,15, CURRENT_TIMESTAMP())),
(59, 41, NULL, 39,  300.00,   240.00,    60.00, 'Unpaid',  DATEADD(day,-18, CURRENT_TIMESTAMP()), DATEADD(day,12, CURRENT_TIMESTAMP())),
(60, 47, NULL, 45,  175.00,   140.00,    35.00, 'Paid',    DATEADD(day,-8,  CURRENT_TIMESTAMP()), DATEADD(day,22, CURRENT_TIMESTAMP()));