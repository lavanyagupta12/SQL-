/* 1.	Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv 
into the employee database from the given resources.*/
create schema employee;
/*2.	Create an ER diagram for the given employee database.*/
/* 3.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, 
and make a list of employees and details of their department.*/
use employee;
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM
    emp_record_table;
/* 4.	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
●	less than two
●	greater than four 
●	between two and four*/
select * from emp_record_table;
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    DEPT,
    EMP_RATING,
    CASE
        WHEN EMP_RATING < 2 THEN 'less than two'
        WHEN EMP_RATING > 4 THEN 'greater than four'
        WHEN EMP_RATING BETWEEN 2 AND 4 THEN 'between two and four'
        ELSE 'no label'
    END AS 'tags'
FROM
    emp_record_table;
    /* 5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from
 the employee table and then give the resultant column alias as NAME.*/
 select * from emp_record_table;
 select concat(trim(FIRST_NAME),' ',trim(LAST_NAME)), DEPT from emp_record_table where DEPT= "FINANCE";
/* 6.	Write a query to list only those employees who have someone reporting to them. 
Also, show the number of reporters (including the President).*/
 select * from data_science_team;
  select * from proj_table;
  SELECT 
    m.EMP_ID AS Manager_ID,
    m.FIRST_NAME AS Manager_First_Name,
    m.LAST_NAME AS Manager_Last_Name, m.role,
    COUNT(e.EMP_ID) AS Number_of_Reporters
FROM 
    emp_record_table m
JOIN 
    emp_record_table e ON m.EMP_ID = e.MANAGER_ID
GROUP BY 
    m.EMP_ID, m.FIRST_NAME, m.LAST_NAME, m.role
ORDER BY 
    Number_of_Reporters DESC;
    /* 7.	Write a query to list down all the employees from the healthcare and finance departments 
    using union. Take data from the employee record table.*/
    SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM
    emp_record_table
WHERE
    DEPT = 'finance' 
UNION SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM
    emp_record_table
WHERE
    DEPT = 'healthcare';
    /* 8.	Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT,
    and EMP_RATING grouped by dept. Also include the respective 
    employee rating along with the max emp rating for the department.*/
    
    SELECT 
    e.EMP_ID,
    e.FIRST_NAME,
    e.LAST_NAME,
    e.ROLE,
    e.DEPT,
    e.EMP_RATING,
    max_dept.Max_Rating
FROM 
    emp_record_table e
JOIN 
    (SELECT 
        DEPT, 
        MAX(EMP_RATING) AS Max_Rating
     FROM 
        emp_record_table
     GROUP BY 
        DEPT) max_dept
ON 
    e.DEPT = max_dept.DEPT
ORDER BY 
    e.DEPT, e.EMP_RATING DESC;
/* 9.	Write a query to calculate the minimum and the maximum salary of the employees 
in each role. Take data from the employee record table.*/
SELECT 
    ROLE,
    MIN(SALARY) AS Min_Salary,
    MAX(SALARY) AS Max_Salary
FROM 
    emp_record_table
GROUP BY 
    ROLE;
    /* 10.	Write a query to assign ranks to each employee based on their experience. 
    Take data from the employee record table.*/
    select *, dense_RANK() OVER( order by EXP)  AS rank_exp 
from emp_record_table;
/* 11.	Write a query to create a view that displays employees in various countries whose salary is 
more than six thousand. Take data from the employee record table.*/
CREATE VIEW more_than_6000 AS
    SELECT 
        *
    FROM
        emp_record_table
    WHERE
        SALARY > 6000;
SELECT 
    *
FROM
    more_than_6000;
/* 12.	Write a nested query to find employees with experience of more than ten years. 
Take data from the employee record table.*/
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    ROLE,
    DEPT,
    EXP
FROM 
    emp_record_table e
WHERE 
    e.EXP in (
        SELECT 
            EXP
        FROM 
            emp_record_table
        WHERE 
            EXP> 10
    );
    /* 13.	Write a query to create a stored procedure to retrieve the details of the employees whose experience
    is more than three years. Take data from the employee record table.*/
DELIMITER //

CREATE PROCEDURE exp_more_than_3 (IN greater_than_3 INT)
BEGIN
    SELECT * 
    FROM emp_record_table
    WHERE EXP > greater_than_3;
END //

DELIMITER ;
CALL exp_more_than_3(3);
/* 14.	Write a query using stored functions in the project table to check whether the job profile 
assigned to each employee in the data science team matches the organization’s set standard.

The standard being:
For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
For an employee with the experience of 12 to 16 years assign 'MANAGER'.*/
DELIMITER //

CREATE FUNCTION GetJobProfile(exp INT) 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(50);
    
    IF exp <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp > 2 AND exp <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp > 5 AND exp <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF exp > 10 AND exp <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF exp > 12 AND exp <= 16 THEN
        SET job_profile = 'MANAGER';
    ELSEIF exp > 16 THEN
        SET job_profile = 'PRESIDENT';
    ELSE
        SET job_profile = 'NO MATCHING PROFILE';
    END IF;

    RETURN (job_profile);
END //

DELIMITER ;

DELIMITER ;
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    ROLE AS current_profile,
    GetJobProfile(EXP) AS expected_profile,
    CASE 
        WHEN ROLE = GetJobProfile(EXP) THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS profile_match_status
FROM 
emp_record_table;
/* 16.	Write a query to calculate the bonus for all the employees, based on their ratings and 
salaries (Use the formula: 5% of salary * employee rating).*/
SELECT 
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    SALARY,
    EMP_RATING,
    (0.05 * SALARY * EMP_RATING) AS BONUS
FROM 
    emp_record_table;
    /* 17.	Write a query to calculate the average salary distribution based 
    on the continent and country. Take data from the employee record table.*/
    SELECT 
    CONTINENT,
    COUNTRY,
    AVG(SALARY) AS AVERAGE_SALARY
FROM 
  emp_record_table
GROUP BY 
    CONTINENT, 
    COUNTRY
ORDER BY 
    CONTINENT, 
    COUNTRY;



