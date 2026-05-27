CREATE DATABASE hr_analytics_emp;

SELECT *
FROM pnrao_hr_analytics_employee_master;

CREATE TABLE employees_staging
LIKE pnrao_hr_analytics_employee_master;

INSERT INTO employees_staging
SELECT *
FROM pnrao_hr_analytics_employee_master;

SELECT *
FROM employees_staging;

-- finding duplicates
WITH duplicate_cte AS (
	SELECT 
		*,
        ROW_NUMBER() OVER(
			PARTITION BY 
				EmployeeID,
                FullName,
                Email
        ) AS row_num
	FROM employees_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- creating a copy of employees_staging
CREATE TABLE `employees_staging2` (
  `EmployeeID` text,
  `FullName` text,
  `Department` text,
  `JobTitle` text,
  `Email` text,
  `Gender` text,
  `HireDate` text,
  `TerminationDate` text,
  `Salary` int DEFAULT NULL,
  `ManagerID` text,
  `PerformanceRating` int DEFAULT NULL,
  `Status` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO employees_staging2
SELECT
	*,
    ROW_NUMBER() OVER(
		PARTITION BY
			EmployeeID,
            FullName,
            Email
	) AS row_num
FROM employees_staging;

SELECT DISTINCT EmployeeID
FROM employees_staging2
WHERE EmployeeID NOT LIKE 'PNR%';

-- trim columns first
SELECT
	EmployeeID,
    TRIM(EmployeeID)
FROM employees_staging2;

UPDATE employees_staging2
SET EmployeeID = TRIM(EmployeeID);

SELECT 
	FullName,
    TRIM(FullName)
FROM employees_staging2;

UPDATE employees_staging2
SET FullName = TRIM(FullName);

UPDATE employees_staging2
SET
	Department = TRIM(Department),
    JobTitle = TRIM(JobTitle),
    Email = TRIM(Email),
    Gender = TRIM(Gender),
    HireDate = TRIM(HireDate),
    TerminationDate = TRIM(TerminationDate),
    Salary = TRIM(Salary),
    ManagerID = TRIM(ManagerID),
    `Status` = TRIM(`Status`);
    
-- completing the EmployeeID
SELECT 
	EmployeeID,
	CONCAT('PNR-', SUBSTRING(Email, 10, 4)),
    Email,
    SUBSTRING(Email, 10, 4)
FROM employees_staging2
WHERE EmployeeID = ''
OR EmployeeID = '#N/A';

UPDATE employees_staging2
SET EmployeeID = CONCAT('PNR-', SUBSTRING(Email, 10, 4))
WHERE EmployeeID = ''
OR EmployeeID = '#N/A';


WITH find_len AS (
	SELECT 
		EmployeeID,
		LENGTH(EmployeeID),
		Email,
		SUBSTRING(Email, 10, 4),
		LENGTH(SUBSTRING(Email, 10, 4))
	FROM employees_staging2
)
SELECT *
FROM find_len
WHERE LENGTH(SUBSTRING(Email, 10, 4)) != 4;

SELECT *
FROM employees_staging2
ORDER BY 1;

--
SELECT
	EmployeeID,
    FullName,
    Department,
    JobTitle,
    Email,
    ROW_NUMBER() OVER(
		PARTITION BY 
			EmployeeID,
            FullName,
            Email
    ) AS dup_name
FROM employees_staging2
ORDER BY 1;

SELECT *
FROM employees_staging2;

UPDATE employees_staging2
SET FullName = NULL
WHERE FullName = ''
OR FullName = '#N/A';

UPDATE employees_staging2
SET Department = NULL
WHERE Department = ''
OR Department = '#N/A';

UPDATE employees_staging2
SET JobTitle = NULL
WHERE JobTitle = ''
OR JobTitle = '#N/A';

SELECT *
FROM employees_staging2
ORDER BY JobTitle, Department;

SELECT 
	Department,
    Jobtitle
FROM employees_staging2
WHERE JobTitle = 'Warehouse Associate';

UPDATE employees_staging2
SET Department = 'Logistics'
WHERE JobTitle = 'Warehouse Associate';


















