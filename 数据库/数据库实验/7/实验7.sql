（1）创建两张表：雇员表 Emp 和工作表 Work，它们的表结构如下：
CREATE TABLE Emp(
    Eid varchar(5) NOT NULL,
    Ename varchar(10),
    WorkID char(3),
    Salary numeric(8,2),
    Phone char(11)
);
CREATE TABLE Work(
    WorkID char(3),
    LowerSalary numeric(8,2),
    UpperSalary numeric(8,2)
);
（2）分别为两张表插入如下数据，查看插入操作是否成功。
INSERT INTO Emp
VALUES('10001', 'Smith', '001', 2000, '13800010001'),('10001', 'Jonny', '001', 3000,'13600010002'),('10002', 'Mary', '002', 2500,  '13800020002');
INSERT INTO Work
VALUES('001', 1000, 5000),('002', 2000, 8000);
（3）修改雇员表的结构，设置 Eid 为主码，主码名称为 eid_pk，查看该操作是否成功。若不成功，请说明原因并思考如何处理才能使得添加约束成功。要求：所有约束都要显式给出约束名，不可由
系统默认，因为删除约束时需要用到约束名。
ALTER TABLE Emp
ADD CONSTRAINT eid_pk PRIMARY KEY(Eid);
//添加失败，因为数据中有两个重复的eid
//解决方法将其中一个eid修改成‘10000’
UPDATE Emp
SET Eid='10000'
WHERE Ename='Smith';
//再次添加
ALTER TABLE Emp
ADD CONSTRAINT eid_pk PRIMARY KEY(Eid);
（4）将 eid 为主码的约束名 eid_pk 改为 pk_eid。
ALTER TABLE Emp
RENAME CONSTRAINT eid_pk to ok_eid;
（5）设置雇员表中的 phone 字段取唯一值，查看该操作是否成功。若不成功说明原因
ALTER TABLE Emp
ADD CONSTRAINT emp_u UNIQUE(Phone);
（6）给雇员表添加一条新记录(‘10003’,’Amy’,’002’, 3000,’13800020003’)，查看执行结果。
INSERT INTO Emp
VALUES('10003','Amy','002',3000,'13800020003');
（7）设置工作表的 WorkID 为主码。
ALTER TABLE Work
ADD PRIMARY KEY(WorkID);
（8）修改雇员表，设置雇员表的 WorkID 字段为外码，它引用工作表中的 WorkID 字段，查看操作
是否成功。若不成功说明原因。
ALTER TABLE Emp
ADD CONSTRAINT emp_fk FOREIGN KEY (WorkID) REFERENCES Work(WorkID);
（9）给雇员表添加一条新记录(‘10003’,’Amy’, ‘003’, 3000, ‘13800020003’)，查看操作是否成功。若不
成功说明原因。
INSERT INTO Emp
VALUES('10003','Amy','003',3000,'13800020003');
//不成功，因为eid为主码且已经存在‘10003’，所以插入不成功
（10）在雇员表中，设置雇员工资必须大于或等于 1000。查看操作是否成功。若不成功说明原因
ALTER TABLE Emp
ADD CONSTRAINT emp_salary_ck CHECK(Salary>=1000);
（11）给雇员表添加一条新记录(‘10003’,’Robert’,‘002’,500,‘13800020003’)，查看执行操作是否成功。
若不成功说明原因。
INSERT INTO Emp
VALUES('10003','Robert','002',500,'13800020003');
//因为工资低于1000，不满足完整性约束，所以插入失败
（12）在工作表中，设置其最低工资不超过最高工资。
ALTER TABLE Work
ADD CONSTRAINT work_salary_ck CHECK (LowerSalary<=UpperSalary);
（13）给工作表添加一条新记录(‘002’,4000,3000)，查看操作是否成功。若不成功说明原因
INSERT INTO Work
VALUES('002',4000,3000);
//操作失败，因为最低工资不能超过最高工资
（14）通过查看 openGauss 的系统表 pg_constraints 了解表上的约束。
\d pg_constraint;
（15）通过 gsql 命令\d+ table_name 查看改表上的约束定义。
\d Emp;
\d Work;
（16）删除雇员表的所有约束，包括主码约束、外码约束和其他约束。
ALTER TABLE Emp
DROP CONSTRAINT ok_eid;
ALTER TABLE Emp
DROP CONSTRAINT emp_u;
ALTER TABLE Emp
DROP CONSTRAINT emp_fk;
ALTER TABLE Emp
DROP CONSTRAINT emp_salary_ck;
（17）删除工作表所有约束，包括主码约束。
ALTER TABLE Work
DROP CONSTRAINT work_pkey;
ALTER TABLE Work
DROP CONSTRAINT work_salary_ck;