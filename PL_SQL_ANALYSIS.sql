/*
1. Create a program block to accept the employee_id input 
and calculate the new_salary value. 
New_salary is obtained from the condition, 
if salary < 10000, new salary is salary plus 10%. 
If salary < 15000, new_salary is salary plus 5%, 
otherwise no additional salary.
Display the employee's last_name and new salary.
*/

DECLARE
v_empid employees.employee_id%TYPE;
v_lname employees.last_name%TYPE;
v_sal employees.salary%TYPE;
v_newsal employees.salary%TYPE;
BEGIN
v_empid := &ID;
SELECT last_name, salary INTO v_lname, v_sal
FROM employees
WHERE employee_id = v_empid;
IF v_sal < 10000
 THEN v_newsal := v_sal + v_sal *0.2;
 ELSIF v_Sal < 15000
  THEN v_newsal := v_sal + v_sal *0.1;
  ELSE
    v_newsal := v_sal;
END IF; 
DBMS_OUTPUT.PUT_LINE ('Last Name is ' || v_lname || ' with salary '|| v_sal || ' and new salary is ' || v_newsal);
END;


/*
2. Create a cursor to retrieve the department_id and the number of employees working in each department. 
From the cursor created, display the departments that have more than 10 employees, along with the number 
of employees in each department. Create with CURSOR with steps (DECLARE, OPEN, FETCH, CLOSE)
*/
DECLARE
CURSOR num_cur IS 
SELECT e.department_id, d.department_name, COUNT(e.employee_id) AS sum_emp 
FROM employees e, departments d
WHERE e.department_id = d.department_id
GROUP BY e.department_id, d.department_name ;
BEGIN
DBMS_OUTPUT.PUT_LINE ('Department dengan jumlah karyawan > 10 ' ) ;
FOR emp_rec IN num_cur 
LOOP
IF emp_rec.sum_emp > 10 AND emp_rec.department_id is not null THEN 
DBMS_OUTPUT.PUT_LINE ('Department ' || emp_rec.department_name  ||' , jumlah karyawan : ' || emp_rec.sum_emp) ;
END IF;
END LOOP ;
END ;


/*
3. Create a program that has 2 parameters, one to receive temperature data, 
and one to receive character data. The program will calculate the temperature 
conversion from degrees Fahrenheit to Celsius if the second parameter is 
the character 'C'/'c' or calculate the temperature conversion from degrees 
Celsius to Fahrenheit if the second parameter is the character 'F'/'f'. 
If the input character is another letter, display the message 'WRONG CODE'.  Work with CASE statement.
Formula:
C = (9/5 * c) + 32; F = 5/9 * (F - 32)
*/
Declare
konv NUMBER ;
suhu NUMBER := UPPER(&suhu);
kode VARCHAR2(2) := UPPER('&kode');
BEGIN
IF kode = 'F' THEN 
  DBMS_OUTPUT.PUT_LINE ('Konversi dari Celcius ke Fahrenheit' );
  konv := (9/5 * suhu) + 32 ;
  DBMS_OUTPUT.PUT_LINE (suhu || ' C = ' || ROUND(konv,1) || ' F') ;
ELSIF kode = 'C' THEN
  DBMS_OUTPUT.PUT_LINE ('Konversi dari Fahrenheit ke Celcius ' );
    konv := 5/9 * (suhu - 32) ;
  DBMS_OUTPUT.PUT_LINE (suhu || ' F = ' || ROUND(konv,1) || ' C') ;
ELSE 
   DBMS_OUTPUT.PUT_LINE ('KODE SALAH' ) ;
END IF ;
END; 



/*
4. Create a Cursor that accepts the input JOB_ID, then displays information about the job_id, 
namely JOB_TITLE, LOWEST SALARY, HIGHEST SALARY, and AVERAGE SALARY. Job_id is inputted by the 
user when the program is run. Create it using FOR LOOP CURSOR.
*/
DECLARE
CURSOR num_cur (jobid jobs.job_id%TYPE) IS 
SELECT e.job_id, j.job_title, COUNT(e.employee_id) AS sum_emp, MAX(e.salary) AS max_sal,
MIN(e.salary) AS min_sal, ROUND((AVG(e.salary)),1) AS avg_sal
FROM employees e, jobs j
WHERE e.job_id = j.job_id AND e.job_id = jobid
GROUP BY e.job_id, j.job_title ;
j_id jobs.job_id%TYPE := '&jid'; 
BEGIN
DBMS_OUTPUT.PUT_LINE ('----Informasi Jobs----- ' ) ;
FOR emp_rec  IN num_cur (j_id)
LOOP
--IF emp_rec.sum_emp > 10 AND emp_rec.department_id is not null THEN 
DBMS_OUTPUT.PUT_LINE ('Job Title: ' || emp_rec.job_title );
DBMS_OUTPUT.PUT_LINE ('         Gaji Tertinggi  : ' || emp_rec.max_sal) ;
DBMS_OUTPUT.PUT_LINE ('         Gaji Terendah   : ' || emp_rec.min_sal) ;
DBMS_OUTPUT.PUT_LINE ('         Gaji Rerata     : ' || emp_rec.avg_sal) ;
--END IF;
END LOOP ;
END ;

/*
5. Create multiple cursors (2 cursors) to display each manager 
(ID and Full Name) and the employees (full name) under each manager.
*/
DECLARE
CURSOR man_cur IS 
SELECT distinct (a.manager_id ) , b.last_name FROM employees a, employees b 
WHERE a.manager_id = b. employee_id ORDER BY manager_id ;
CURSOR emp_cur (man_id NUMBER) IS
SELECT * FROM employees WHERE manager_id = man_id ;
BEGIN
FOR man_rec IN man_cur 
LOOP
DBMS_OUTPUT.PUT_LINE ('Karyawan yang dibawahi manager ID ' || man_rec.manager_id ||' - ' || man_rec.last_name) ;
   FOR emp_rec  IN emp_cur (man_rec.manager_id)
   LOOP
   DBMS_OUTPUT.PUT_LINE('    ' || emp_rec.first_name || ' ' || emp_rec.last_name) ;
   END LOOP ;
END LOOP ;
END ;

SELECT DISTINCT (job_id ) FROM employees;

/*
6. Create a program block to use a record to store data according to the departments table, 
and display the department_name, manager_id and location_id of the specific department entered by the user. 
Use an exception to display an error message if the data is not found.
*/
DECLARE
 v_dept_rec departments%ROWTYPE;
BEGIN
 SELECT * INTO v_dept_rec
 FROM departments
 WHERE department_id = :dept;
 DBMS_OUTPUT.PUT_LINE('Department ID : ' ||v_dept_rec.department_id);
 DBMS_OUTPUT.PUT_LINE('Department Name : '  || v_dept_rec.department_name );
 DBMS_OUTPUT.PUT_LINE('Manager ID : ' ||  v_dept_rec.manager_id) ;
 DBMS_OUTPUT.PUT_LINE('Location ID : ' || v_dept_rec.location_id);
EXCEPTION
 WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('This department does not exist');
END;

/*
7. Create a procedure dept_xxx (xxx is the student's 3-digit number) 
to accept department id input and display the full names (first name and last name)
that work in the department. Use exception to display an error message if the data is not found or 
the data is more than one line.
*/
CREATE OR REPLACE PROCEDURE dept_113(dept_id IN number) IS
    v_emp_id Employees.Employee_id%TYPE;
    l_name employees.last_name%TYPE;
    f_name employees.first_name%TYPE;
BEGIN
  select Employee_id, first_name, last_name into  v_emp_id, f_name, l_name 
  from Employees 
  where department_id = dept_id;
  DBMS_OUTPUT.PUT_LINE('Karyawan yang bekerja pada dept ' || dept_id || ' :  ');
  DBMS_OUTPUT.PUT_LINE( v_emp_id|| ' - ' ||f_name || ' '||l_name);
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Output lebih dari satu baris data');
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Tidak ada data yang dihasilkan');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Terjadi error'); 
END;

BEGIN
dept_113(10);
END; 

/*
8. Create a PL/SQL program to create a Table of Record to display the department_id 
and department_name that are in a specific location (location_id in user input). Use the locations and countries tables.
*/
DECLARE
TYPE t_dept IS TABLE OF departments%ROWTYPE
INDEX BY BINARY_INTEGER;
dep_tab t_dept;
loc NUMBER := :loc ;
BEGIN
FOR count_rec IN (select * from departments where location_id = loc )
LOOP
dep_tab(count_rec.department_id) := count_rec; 
END LOOP;
DBMS_OUTPUT.PUT_LINE('======Departments on Location ' || loc || ' =======') ;
FOR i IN  dep_tab.FIRST .. dep_tab.LAST
LOOP
IF dep_tab.EXISTS(i) THEN
DBMS_OUTPUT.PUT_LINE(dep_tab(i).department_id|| ' ' || dep_tab(i).department_name  ); 
END IF;
END LOOP;
END;




/*
8. Create an emp_pkg_xxx package which has 2 functions, namely tax and hire. 
Function tax is used to calculate the tax to be given which is 20% of the salary value for 
one year (salary * 12) which is inputted into the function, while the function hire is used to 
calculate the length of employment according to the date (hire_date) which is inputted into the function. 
(xxx in emp_pkg_xxx is the last 3 digits of each student's number)

Also create the main algorithm to receive an employee id and calculate the employee's 
tax and length of employment by calling the tax and hire functions in emp_pkg_xxx.
The data displayed are annual salary, tax, hire date and length of employment.
*/
--package specification
CREATE OR REPLACE PACKAGE emp_pkg_113 IS
  FUNCTION tax (p_value IN NUMBER) RETURN NUMBER;
  FUNCTION hire(d_value IN DATE) RETURN NUMBER ;
END emp_pkg_113;

/
--package body
CREATE OR REPLACE PACKAGE BODY emp_pkg_113 IS     --xxx adalah 3 digit akhir mahasiswa
  FUNCTION tax (p_value IN NUMBER) RETURN NUMBER IS
    v_tax NUMBER := 0.20;
  BEGIN
    RETURN ((p_value * 12 ) * v_tax);
  END tax;

  FUNCTION hire(d_value IN DATE) RETURN NUMBER IS
    BEGIN
    RETURN ROUND(((SYSDATE - d_value) / 365 ),0);
   END hire ;
END emp_pkg_113;
/

--cal the package
DECLARE
sal NUMBER;
h_date DATE;
emp_id NUMBER := :emp_id ; 
BEGIN
SELECT salary, hire_date INTO sal, h_date 
FROM employees
WHERE employee_id = emp_id;
DBMS_OUTPUT.PUT_LINE('Tax and work periode employee ' ||emp_id || '   :');
DBMS_OUTPUT.PUT_LINE ('Annual Salary : ' || sal * 12) ;
DBMS_OUTPUT.PUT_LINE('Tax $ :' ||emp_pkg_113.tax(sal));
DBMS_OUTPUT.PUT_LINE ('Hire date : ' || h_date) ;
DBMS_OUTPUT.PUT_LINE('Work periode : '|| emp_pkg_113.hire(h_date) || ' Years');
END;


