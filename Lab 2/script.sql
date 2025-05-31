-- Create Types

CREATE TYPE dept_t;
/

CREATE TYPE emp_t AS OBJECT (
  empno      CHAR(6),
  firstname  VARCHAR2(12),
  lastname   VARCHAR2(15),
  workdept   REF dept_t,
  sex        CHAR(1),
  birthdate  DATE,
  salary     NUMBER(8,2)
);
/

CREATE OR REPLACE TYPE dept_t AS OBJECT (
  deptno     CHAR(3),
  deptname   VARCHAR2(36),
  mgrno      REF emp_t,
  admrdept   REF dept_t
);
/

-- Create Tables

CREATE TABLE ORDEPT OF dept_t (
  PRIMARY KEY (deptno)
);
/

CREATE TABLE OREMP OF emp_t (
  PRIMARY KEY (empno),
  SCOPE FOR (workdept) IS ORDEPT
);
/


-- Insert Data into OREMP

INSERT INTO OREMP VALUES ('000010', 'CHRISTINE', 'HAAS', NULL, 'F', TO_DATE('14-AUG-1953', 'DD-MON-YYYY'), 72750);
/
INSERT INTO OREMP VALUES ('000020', 'MICHAEL', 'THOMPSON', NULL, 'M', TO_DATE('02-FEB-1968', 'DD-MON-YYYY'), 61250);
/
INSERT INTO OREMP VALUES ('000030', 'SALLY', 'KWAN', NULL, 'F', TO_DATE('11-MAY-1971', 'DD-MON-YYYY'), 58250);
/
INSERT INTO OREMP VALUES ('000060', 'IRVING', 'STERN', NULL, 'M', TO_DATE('07-JUL-1965', 'DD-MON-YYYY'), 55555);
/
INSERT INTO OREMP VALUES ('000070', 'EVA', 'PULASKI', NULL, 'F', TO_DATE('26-MAY-1973', 'DD-MON-YYYY'), 56170);
/
INSERT INTO OREMP VALUES ('000050', 'JOHN', 'GEYER', NULL, 'M', TO_DATE('15-SEP-1955', 'DD-MON-YYYY'), 60175);
/
INSERT INTO OREMP VALUES ('000090', 'EILEEN', 'HENDERSON', NULL, 'F', TO_DATE('15-MAY-1961', 'DD-MON-YYYY'), 49750);
/
INSERT INTO OREMP VALUES ('000100', 'THEODORE', 'SPENSER', NULL, 'M', TO_DATE('18-DEC-1976', 'DD-MON-YYYY'), 46150);
/


-- Insert Data into ORDEPT

INSERT INTO ORDEPT VALUES ('A00', 'SPIFFY COMPUTER SERVICE DIV.', NULL, NULL);
/
INSERT INTO ORDEPT VALUES ('B01', 'PLANNING', NULL, NULL);
/
INSERT INTO ORDEPT VALUES ('C01', 'INFORMATION CENTRE', NULL, NULL);
/
INSERT INTO ORDEPT VALUES ('D01', 'DEVELOPMENT CENTRE', NULL, NULL);
/


-- Update References

UPDATE OREMP E SET E.workdept = (SELECT REF(D) FROM ORDEPT D WHERE D.deptno = 'A00') WHERE empno = '000010';
/
UPDATE OREMP E SET E.workdept = (SELECT REF(D) FROM ORDEPT D WHERE D.deptno = 'B01') WHERE empno IN ('000020', '000090', '000100');
/
UPDATE OREMP E SET E.workdept = (SELECT REF(D) FROM ORDEPT D WHERE D.deptno = 'C01') WHERE empno IN ('000030', '000050');
/
UPDATE OREMP E SET E.workdept = (SELECT REF(D) FROM ORDEPT D WHERE D.deptno = 'D01') WHERE empno IN ('000060', '000070');
/
UPDATE ORDEPT D SET D.mgrno = (SELECT REF(E) FROM OREMP E WHERE E.empno = '000010') WHERE D.deptno = 'A00';
/
UPDATE ORDEPT D SET D.mgrno = (SELECT REF(E) FROM OREMP E WHERE E.empno = '000020') WHERE D.deptno = 'B01';
/
UPDATE ORDEPT D SET D.mgrno = (SELECT REF(E) FROM OREMP E WHERE E.empno = '000030') WHERE D.deptno = 'C01';
/
UPDATE ORDEPT D SET D.mgrno = (SELECT REF(E) FROM OREMP E WHERE E.empno = '000060') WHERE D.deptno = 'D01';
/
UPDATE ORDEPT D SET D.admrdept = (SELECT REF(DD) FROM ORDEPT DD WHERE DD.deptno = 'A00') WHERE D.deptno IN ('A00', 'B01', 'C01');
/
UPDATE ORDEPT D SET D.admrdept = (SELECT REF(DD) FROM ORDEPT DD WHERE DD.deptno = 'C01') WHERE D.deptno = 'D01';
/

--2

--(a) Get the department name and manager’s lastname for all departments. 

SELECT d.deptname, DEREF(d.mgrno).lastname AS manager_lastname
FROM ordept d
/

--(b) Get the employee number, lastname and the department name of every employee. 

SELECT e.empno, 
       e.lastname, 
       DEREF(e.workdept).deptname AS department_name
FROM oremp e
/

--c) For each department, display the department number, department name, and name of the administrative department. 

SELECT d.deptno, 
       d.deptname, 
       DEREF(d.admrdept).deptname AS administrative_department
FROM ordept d
/

--d) For each department, display the department number, department name, the name of the administrative department and the last name of the manager of the administrative department. 

SELECT d.deptno, 
       d.deptname, 
       DEREF(d.admrdept).deptname AS administrative_department,
       DEREF(DEREF(d.admrdept).mgrno).lastname AS admin_manager_lastname
FROM ordept d
/


--e) Display the employee number, firstname, lastname and salary of every employee, along with lastname and salary of the manager of the employee’s work department. 

SELECT e.empno, 
       e.firstname, 
       e.lastname, 
       e.salary,
       DEREF(DEREF(e.workdept).mgrno).lastname AS manager_lastname,
       DEREF(DEREF(e.workdept).mgrno).salary AS manager_salary
FROM oremp e
/

-- f) Show the average salary for men and the average salary for women for each department. Identify the department by both department number and name. 

SELECT DEREF(e.workdept).deptno AS dept_no,
       DEREF(e.workdept).deptname AS dept_name,
       e.sex,
       AVG(e.salary) AS average_salary
FROM oremp e
GROUP BY DEREF(e.workdept).deptno, DEREF(e.workdept).deptname, e.sex
ORDER BY dept_no, sex
/