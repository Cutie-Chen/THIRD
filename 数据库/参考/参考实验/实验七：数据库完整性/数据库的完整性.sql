(1)
CREATE TABLE Emp(
    Eid CHAR(5) NOT NULL,
    Ename VARCHAR(10),
    WorkID CHAR(3),
    Salary NUMBER(8,2),
    Phone CHAR(11) NOT NULL
);

CREATE TABLE Work(
    WorkID CHAR(3) NOT NULL,
    LowerSalary NUMBER(8,2),
    UpperSalary NUMBER(8,2)
);

(2)
INSERT INTO Emp VALUES ('10001', 'Smith', '001', 2000, '13800010001'),
('10001', 'Jonny', '001', 3000, '13600010002'),
('10002', 'Mary', '002', 2500, '13800020002');

INSERT INTO Work VALUES ('001', 1000, 5000),
('002', 2000, 8000);

(3)
ALTER TABLE Emp ADD CONSTRAINT eid_pk PRIMARY KEY(Eid);
UPDATE Emp SET Eid = '10000' WHERE Ename = 'Smith';  

(4)
ALTER TABLE Emp RENAME CONSTRAINT eid_pk TO pk_eid;

(5)
ALTER TABLE Emp ADD CONSTRAINT uni_phone UNIQUE(Phone);

(6)
INSERT INTO Emp VALUES ('10003', 'Amy', '002', 3000, '13800020003');

(7)
ALTER TABLE Work ADD CONSTRAINT pk_workid PRIMARY KEY(WorkID);

(8)
ALTER TABLE Emp ADD CONSTRAINT fk_emp_work FOREIGN KEY(WorkID) 
REFERENCES Work(WorkID);

(9)
INSERT INTO Emp VALUES ('10003', 'Amy', '003', 3000, '13800020003');

(10)
ALTER TABLE Emp ADD CONSTRAINT ck_emp_salary CHECK(Salary >= 1000);

(11)
INSERT INTO Emp VALUES ('10003', 'Robert', '002', 500, '13800020003');

(12)
ALTER TABLE Work ADD CONSTRAINT ck_work_salary CHECK(UpperSalary >= LowerSalary);

(13)
INSERT INTO Work VALUES ('002', 4000, 3000);

(14)
SELECT oid,conname FROM pg_constraint;
SELECT pg_get_constraintdef(oid);

(15)
\d+ Emp
\d+ Work

(16)
ALTER TABLE Emp DROP CONSTRAINT pk_eid;
ALTER TABLE Emp DROP CONSTRAINT fk_emp_work;
ALTER TABLE Emp DROP CONSTRAINT ck_emp_salary;

(17)
ALTER TABLE Work DROP CONSTRAINT pk_workid;
ALTER TABLE Work DROP CONSTRAINT ck_work_salary;