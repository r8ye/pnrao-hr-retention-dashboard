SELECT *
FROM employees;

SELECT *
FROM compensation_history;

SELECT *
FROM performance_reviews;

SELECT 
	e.EmployeeID,
    FullName,
    Department,
    JobTitle,
    Email,
    Gender,
    OldSalary,
    NewSalary,
    Reason,
    PerformanceRating,
    HireDate,
    TerminationDate,
    `Status`
FROM employees AS e
JOIN compensation_history AS c
	ON e.EmployeeID = c.EmployeeID;
    
CREATE TABLE employees_staging AS
SELECT 
	e.EmployeeID,
    FullName,
    Department,
    JobTitle,
    Email,
    Gender,
    OldSalary,
    NewSalary,
    Reason,
    PerformanceRating,
    HireDate,
    TerminationDate,
    `Status`
FROM employees AS e
JOIN compensation_history AS c
	ON e.EmployeeID = c.EmployeeID;


    

