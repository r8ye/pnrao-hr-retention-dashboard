CREATE DATABASE pnhrao_employees;

SELECT *
FROM employee_master;

-- create a staging table
CREATE TABLE emp_staging
LIKE employee_master;

INSERT INTO emp_staging
SELECT *
FROM employee_master;

SELECT *
FROM emp_staging;

-- trim each column
UPDATE emp_staging
SET
	EmployeeID = TRIM(EmployeeID),
    FullName = TRIM(FullName),
    Department = TRIM(Department),
    JobTitle = TRIM(JobTitle),
    Email = TRIM(Email),
    Gender = TRIM(Gender),
    HireDate = TRIM(HireDate),
    TerminationDate = TRIM(TerminationDate),
    Salary = TRIM(Salary),
    ManagerID = TRIM(ManagerID),
    PerformanceRating = TRIM(PerformanceRating),
    `Status` = TRIM(`Status`);
    
   -- imputing the missing EmployeeID
SELECT 
	EmployeeID, 
    Email,
    SUBSTRING(Email, 10, 4),
    CONCAT('PNR-', SUBSTRING(Email, 10, 4))
FROM emp_staging;

UPDATE emp_staging
SET EmployeeID = CONCAT('PNR-', SUBSTRING(Email, 10, 4))
WHERE EmployeeID = ''
OR EmployeeID = '#N/A';

-- count all rows before removing duplicates(total rows: 868)
SELECT 
	COUNT(EmployeeID) AS total_rows
FROM emp_staging;

-- finding duplicates
WITH duplicate_cte AS (
	SELECT 
		*,
        ROW_NUMBER() OVER(
			PARTITION BY 
				EmployeeID,
                FullName
        ) AS row_num
	FROM emp_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- creating another table to delete duplicates
CREATE TABLE `emp_staging2` (
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO emp_staging2
SELECT 
	*,
	ROW_NUMBER() OVER(
		PARTITION BY 
			EmployeeID,
			FullName
	) AS row_num
FROM emp_staging;

SELECT *
FROM emp_staging2;

DELETE
FROM emp_staging2
WHERE row_num > 1;

-- making a new staging tbl to delete more duplicates
CREATE TABLE `emp_staging3` (
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
  `row_num` int DEFAULT NULL,
  `id_row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO emp_staging3
SELECT 
	*,
    ROW_NUMBER() OVER(
		PARTITION BY EmployeeID
        ORDER BY FullName DESC
    ) AS id_row_num
FROM emp_staging2;

-- row count after deleting duplicate rows (rows: 761)
SELECT COUNT(EmployeeID)
FROM emp_staging3;

-- moving the rows with incomplete employeeid to another tbl emp_incomplete_id
CREATE TABLE emp_incomplete_id AS
SELECT *
FROM emp_staging3
WHERE EmployeeID = 'PNR-';

DELETE 
FROM emp_staging3
WHERE EmployeeID = 'PNR-';

SELECT *
FROM emp_staging3;

-- standardizing fullname
UPDATE emp_staging3
SET FullName = NULL
WHERE FullName = ''
OR FullName = '#N/A';

-- standardizing department
UPDATE emp_staging3
SET Department = NULL
WHERE Department = ''
OR Department = '#N/A';

SELECT *
FROM emp_staging3
ORDER BY 3;

SELECT 
	Department,
    Jobtitle
FROM emp_staging3
WHERE JobTitle LIKE 'Financial';

UPDATE emp_staging3
SET Department = 'Finance'
WHERE JobTitle LIKE 'Financial%'
AND Department IS NULL;

-- join 
SELECT 
	e3.EmployeeID,
    e3.Department,
    e3.JobTitle,
    e2.EmployeeID,
    e2.Department,
    e2.JobTitle
FROM emp_staging3 AS e3
LEFT JOIN emp_staging2 AS e2
	ON e3.EmployeeID = e2.EmployeeID;
    
UPDATE emp_staging3 e3
LEFT JOIN emp_staging2 AS e2
	ON e3.EmployeeID = e2.EmployeeID
SET e3.Department = e2.Department;

-- standardizing email
SELECT
	EmployeeID,
    Email,
    SUBSTRING(EmployeeID, 5, 4),
    CONCAT('employee.', SUBSTRING(EmployeeID, 5, 4), '@pnrao.com')
FROM emp_staging3
ORDER BY 2;

UPDATE emp_staging3
SET Email = NULL
WHERE Email = ''
OR Email = '#N/A';

UPDATE emp_staging3
SET Email = CONCAT('employee.', SUBSTRING(EmployeeID, 5, 4), '@pnrao.com')
WHERE Email IS NULL;

-- standardizing gender
SELECT *
FROM emp_staging3
ORDER BY gender;

UPDATE emp_staging3
SET gender = NULL
WHERE gender = ''
OR gender = '#N/A';

-- standardizing hiredate & terminationdate
SELECT 
	hiredate,
    terminationdate,
    `status`
FROM emp_staging3;

SELECT 
	hiredate,
    terminationdate,
    `status`
FROM emp_staging3
WHERE `status` = 'Active';

UPDATE emp_staging3
SET TerminationDate = ''
WHERE `status` = 'Active';

SELECT 
	hiredate,
    terminationdate,
    `status`
FROM emp_staging3
WHERE terminationdate IS NOT NULL 
AND terminationdate != ''
AND terminationdate != '#N/A';

UPDATE emp_staging3
SET `status` = 'Terminated'
WHERE terminationdate IS NOT NULL 
AND terminationdate != ''
AND terminationdate != '#N/A';
    
UPDATE emp_staging3
SET `status` = ''
WHERE `status` = '#N/A';

UPDATE emp_staging3
SET `status` = NULL
WHERE `status` = ''
OR `status` = '#N/A';

ALTER TABLE emp_staging3
MODIFY COLUMN hiredate DATE;
    
ALTER TABLE emp_staging3
MODIFY COLUMN terminationdate DATE;

-- deleting unnecessary columns
ALTER TABLE emp_staging3
DROP COLUMN id_row_num;

-- row count: 751
SELECT COUNT(*)
FROM emp_staging3;

SELECT *
FROM emp_staging3;
    
