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
-- MALI JOIN MO ULIT

    



    
    
    
    
    
    
    
    
    