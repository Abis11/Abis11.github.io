SELECT *FROM departments
SELECT department_id,location_id,department_name FROM departments
SELECT *FROM COUNTRIES
SELECT country_name, region_id FROM COUNTRIES
SELECT *FROM job_history
SELECT end_date, start_date,department_id FROM job_history
SELECT job_id FROM job_history
SELECT *FROM jobs
SELECT job_title, max_salary FROM jobs
SELECT *FROM REGIONS
SELECT *FROM LOCATIONS
SELECT postal_code, city, state_province FROM LOCATIONS
SELECT * FROM employees
SELECT employee_id, first_name, last_name, salary, department_id FROM employees

SELECT * FROM employees
SELECT *FROM LOCATIONS
SELECT *FROM departments


--1.) Display the minimum salary. 
SELECT MIN(salary) AS MINIMUM_SALARY FROM employees

--2.) Display the highest salary.
SELECT MAX(salary) 'AS MAXIMUM SALARY' FROM employees

--3.) Display the total salary of all employees. 
SElECT SUM(salary) AS total_salary FROM employees

--4.) Display the average salary of all employees.
SELECT AVG(salary) AS average_salary FROM employees

--5.) Issue a query to count the number of rows in the employee table. The result should be just one row.
SELECT COUNT(*) AS TOTAL_COUNT FROM employees
SELECT COUNT(salary) As TOTAL_COUNT FROM employees

--6.) Issue a query to count the number of employees that make commission. The result should be just one row.
SELECT COUNT(commission_pct) As Count FROM employees

--7.) Issue a query to count the number of employees’ first name column. The result should be just one row.
SELECT COUNT(first_name) AS Employees_COUNT FROM employees

--8.) Display all employees that make less than Peter Hall.
SELECT * FROM employees WHERE salary < 9000
(SELECT salary FROM employees WHERE first_name = 'Peter' AND last_name ='Hall')

--9.) Display all the employees in the same department as Lisa Ozer.
SELECT * FROM employees WHERE department_id = 80
(SELECT department_id FROM employees WHERE first_name ='Lisa' AND last_name = 'Ozer')

--10.) Display all the employees in the same department as Martha Sullivan and that make more than TJ Olson.
SELECT * FROM employees WHERE department_id >50
(SELECT department_id FROM employees WHERE first_name ='Martha' AND last_name ='Sullivan') 
 (SELECT salary FROM employees WHERE first_name ='TJ' AND last_name = 'Olson')

--11.) Display all the departments that exist in the departments table that are not in the employees’ table. Do not use a where clause.
SELECT  department_id FROM departments
Except 
SELECT distinct department_id FROM employees

--12.) Display all the departments that exist in department tables that are also in the employees’ table. Do not use a where clause.
SELECT department_id FROM employees
INTERCEPT
SELECT distinct department_id from employees

--13.) Display all the departments name, street address, postal code, city, and state of each department. Use the departments and locations table for this query.
SELECT departments.department_name, locations.street_adddress, locations.postal_code, locations.city, locations.state_province, FROM employees

SELECT d.department_name, l.street_address, l.postal_code, l.city, l.state_province, FROM employees


--14.) Display the first name and salary of all the employees in the accounting departments.
SELECT employees.first_name, employees.salary, departments.department_name, FROM employees JOIN departments ON departments.department_id = employees.department_id WHERE department_name ='accounting'

SELECT e.first_name, e.salary, d.department_name FROM employees e
JOIN departments d ON d.department_id = e.department_id WHERE department_name = 'accounting'

 

--15.) Display all the last name of all the employees whose department location id are 1700 and 1800.
SELECT e.last_name, d.department_id, d.location_id FROM departments d
JOIN employees e ON d.department_id = e.department_id WHERE location_id IN (1700,1800)


--16.) Display the phone number of all the employees in the Marketing department.
SELECT e.first_name, e.last_name,e.phone_number, d.department_name FROM employees e
JOIN departments d ON e.department_id = d.department_id WHERE d.department_name ='Marketing'

--17.) Display all the employees in the Shipping and Marketing departments who make more than 3100. 
SELECT e.first_name, e.last_name, d.department_name, e.salary FROM employees e 
JOIN departments d ON d.department_id =d.department_id WHERE d.department_name ='shipping' OR department_name ='Marketing'
AND salary > 3100

SELECT first_name,s FROM employees
--18). Write an SQL query to print the first three characters of FIRST_NAME from employee’s table.
SELECT SUBSTRING(first_name,1,3) AS first_3_characters

--19.) Display all the employees who were hired before Tayler Fox.

--20.) Display names and salary of the employees in executive department
SELECT e.first_name, e.last_name, d.department_name
FROM employees AS e
JOIN departments As d
on e.department_id = d.department_id
WHERE department_name ='Executive'

--21.) Display the employees whose job ID is the same as that of employee 141.
SELECT*FROM employees WHERE job_id = 
(SELECT job_id FROM employees WHERE employee_id =141)

--22.) For each employee, display the employee number, last name, salary, and salary increased by 15% and expressed as a whole number. Label the column New Salary.
SELECT employee_id, last_name, salary, ROUND(salary*1.15,0) AS 'NEW SALARY' FROM employees

--23). Write an SQL query to print the FIRST_NAME and LAST_NAME from employees table into a single column COMPLETE_NAME. A space char should separate them.
SELECT CONCAT (first_name,' ', last_name) COMPLETE_NAME FROM employees

--24.) Display all the employees and their salaries that make more than Abel.
SELECT *FROM 
first_name, last_name, employee_id, salary, FROM employees WHERE first_name ='Abel' AND salary >

--25.) Create a query that displays the employees’ last names and commission amounts. If an employee does not earn commission, put “no commission”. Label the column COMM. 
--26.) Create a unique listing of all jobs that are in department 80. Include the location of department in the output.
--27.) Write a query to display the employee’s last name, department name, location ID, and city of all employees who earn a commission.
--28.) Create a query to display the name and hire date of any employee hired after employee Davies.
--29.) Write an SQL query to show one row twice in results from a table.
--30.) Display the highest, lowest, sum, and average salary of all employees. Label the columns Maximum, Minimum, Sum, and Average, respectively. Round your results to the nearest whole number.
