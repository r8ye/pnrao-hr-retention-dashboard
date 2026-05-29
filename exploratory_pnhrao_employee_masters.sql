SELECT *
FROM emp_staging3;

-- employees by department
SELECT 
	department,
    COUNT(employeeid) AS employees
FROM emp_staging3
GROUP BY Department
ORDER BY 2 DESC;

-- avg salary by jobtitle
SELECT 
	department,
	jobtitle,
    AVG(salary) AS avg_salary
FROM emp_staging3
GROUP BY Department, JobTitle
ORDER BY 3 DESC;

-- salary by gender
SELECT 
	gender,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary
FROM emp_staging3
WHERE gender IS NOT NULL
GROUP BY gender
ORDER BY avg_salary DESC;

-- month with the most terminated employees
SELECT 
	SUBSTRING(terminationdate, 6, 2) AS `month`,
    COUNT(SUBSTRING(terminationdate, 6, 2)) AS terminated_emp_count
FROM emp_staging3
WHERE `status` = 'terminated'
GROUP BY 1
ORDER BY 2 DESC;

-- hiring season (month)
SELECT
	SUBSTRING(hiredate, 6, 2) AS `month`,
    COUNT(SUBSTRING(hiredate, 6, 2)) AS emp_count
FROM emp_staging3
GROUP BY 1
ORDER BY 2 DESC;

-- avg performance rating by job title
SELECT 
	jobtitle,
    AVG(performancerating) AS avg_rating
FROM emp_staging3
GROUP BY JobTitle
ORDER BY 2 DESC;

-- high performing employees
SELECT 
	JobTitle,
    fullname,
    performancerating,
    DENSE_RANK() OVER(
		PARTITION BY JobTitle
        ORDER BY PerformanceRating DESC
    ) AS ranking
FROM emp_staging3
WHERE JobTitle IS NOT NULL
GROUP BY JobTitle, fullname, PerformanceRating;

WITH performance_rating_rank AS (
	SELECT 
		JobTitle,
		fullname,
		performancerating,
		DENSE_RANK() OVER(
			PARTITION BY JobTitle
			ORDER BY PerformanceRating DESC
		) AS ranking
		FROM emp_staging3
		WHERE JobTitle IS NOT NULL
		GROUP BY JobTitle, fullname, PerformanceRating
)
SELECT *
FROM performance_rating_rank
WHERE ranking = 1
AND fullname IS NOT NULL;

-- employees by status
SELECT 
	`status`,
    COUNT(employeeid) AS emp_count
FROM emp_staging3
GROUP BY `status`
ORDER BY 2 DESC;

