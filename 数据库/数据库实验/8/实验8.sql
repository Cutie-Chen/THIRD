1.创建部门表dept(deptno, deptname)
CREATE TABLE dept(
    deptno char(2) PRIMARY KEY,
    deptname varchar(20) NOT NULL
);

2.创建 Teacher 表：Teacher(ID, job, Sal, deptno)
CREATE TABLE TEACHER(
    id char(5) PRIMARY KEY,
    job varchar(20) NOT NULL,
    sal numeric(7,2),
    deptno char(2),
    FOREIGN KEY (deptno) REFERENCES dept(deptno)
);

3.为dept表增加实验数据：(‘01’,’CS’), (‘02’,’SW’), (‘03’,’MA’)；为Teacher表增加实验数据：(‘10001’,
‘教授’,3800,’01’), (‘10002’,‘教授’,4100,’02’), (‘10003’,‘副教授’,3500,’01’), (‘10004’,‘助理教授’,3000,’03’)
INSERT INTO dept
VALUES('01','CS'),('02','SW'),('03','MA');
INSERT INTO TEACHER
VALUES('10001','教授',3800,'01'), ('10002','教授',4100,'02'), ('10003','副教授',3500,'01'), ('10004','助理教授',3000,'03');

4.在 Teacher 表上创建一个 BEFORE 行级触发器（名称：INSERT_OR_UPDATE_SAL）以实现如下完整
性规则：教授的工资不得低于 4000 元，如果低于 4000 元，自动改为 4000 元。
CREATE TRIGGER INSERT_OR_UPDATE_SAL
BEFORE INSERT OR UPDATE ON TEACHER
FOR EACH ROW
BEGIN
    IF(new.job='教授')AND(new.sal<4000)
    THEN new.sal:=4000;
    END IF;
END;

//opengauss中创建触发器
//添加函数
CREATE OR REPLACE FUNCTION UPDATE_SAL()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF(NEW.SAL<4000)AND(NEW.JOB = '教授')
    THEN NEW.SAL := 4000;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL;
//添加触发器
CREATE TRIGGER INSERT_OR_UPDATE_SAL
BEFORE INSERT OR UPDATE ON Teacher
FOR EACH ROW
EXECUTE PROCEDURE UPDATE_SAL();

5.验证触发器是否正常工作：分别执行以下 A，B 两种操作，验证 INSERT_OR_UPDATE_SAL 触发器
是否被触发？工作是否正确？如果正确，请观察 Teacher 表中数据的变化是否与预期一致。
 A. 插入两条新数据(‘10005’,‘教授’,3999,’02’), (‘10006’,‘教授’,4000,’03’);
 B. 更新数据:将 id 为 10002 的教授工资改为 3900。
INSERT INTO TEACHER
VALUES('10005','教授',3999,'02'), ('10006','教授',4000,'03');
UPDATE TEACHER
SET sal=3900
WHERE id='10002';
SELECT * 
FROM TEACHER;

6.查看触发器（名称和代码）；
//记住查看语句
SELECT *
FROM PG_TRIGGER;

7.设计触发器自动维持表间的外码约束：删除 dept 表中 deptno 为 03 的数据后，teacher 表上引
用该数据的记录也被自动删除。
CREATE TRIGGER DELETE
_AFTER
AFTER DELETE ON TABLE dept
FOR EACH ROW
BEGIN
    IF(old.deptno='03')
    THEN DELETE FROM TEACHER
    WHERE TEACHER.deptno='03';
    ENDIF;
END;

//opengauss写法
CREATE OR REPLACE FUNCTION DELETE_AFTER()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF(old.deptno='03')
    THEN DELETE FROM TEACHER
    WHERE TEACHER.deptno='03';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL;
//添加触发器
CREATE TRIGGER DELETE_AFTER_tr
BEFORE DELETE ON dept
FOR EACH ROW
EXECUTE PROCEDURE DELETE_AFTER();

8.设计触发器实现审计日志记录（教材例 5.21）：当对表 SC 的 Grade 属性进行修改时，若分数增
加了 10%及其以上，则将此次操作记录到下面表中：SC_U(Sno, Cno, Oldgrade, Newgrade)，其中，
Oldgrade 是修改前的分数，Newgrade 是修改后的分数。
① 创建 SC_U 表：SC_U(Sno, Cno, Oldgrade, Newgrade)，其中，
 Sno 的数据类型：定长为 9 的字符型，外码，引用 Student 表中 Sno 的值
 Cno 的数据类型：定长为 4 的字符型，外码，引用 Course 表中 Cno 的值
 Oldgrade 的数据类型：长度为 3 的整型
 Newgrade 的数据类型：长度为 3 的整型
② 创建 SC 表上的 AFTER 行级触发器，触发器名为 tri_update_sc
③ 验证 tri_update_sc 触发器是否正常工作（测试数据同教材）。
CREATE TABLE SC_U(
    Sno char(9),
    Cno char(4),
    Oldgrade int,
    Newgrade int,
    FOREIGN KEY (Sno) REFERENCES Student(Sno),
    FOREIGN KEY (Cno) REFERENCES Course(Cno)
);

CREATE TRIGGER tri_update_sc
AFTER UPDATE OF GRADE ON SC
FOR EACH ROW
BEGIN
    IF(new.GRADE>=old.GRADE*1.1)
    THEN INSERT INTO SC_U(Sno, Cno, Oldgrade, Newgrade)
    VALUES(olf.Sno,old.Cno,old.GRADE,new.GRADE);
    ENDIF;
END;
//书上的写法
CREATE TRIGGER tri_update_sc
AFTER UPDATE OF GRADE ON SC
REFERENCING
    OLD row AS OldTuple,
    NEW row AS NewTuple
FOR EACH ROW
    WHERE(NewTuple.GRADE>=1.1*OldTuple.GRADE)
    INSERT INTO SC_U(Sno, Cno, Oldgrade, Newgrade)
    VALUES(olf.Sno,old.Cno,old.GRADE,new.GRADE);

//opengauss写法
CREATE OR REPLACE FUNCTION tri_update_sc()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF(new.GRADE>=old.GRADE*1.1)
    THEN INSERT INTO SC_U(Sno, Cno, Oldgrade, Newgrade)
    VALUES(olf.Sno,old.Cno,old.GRADE,new.GRADE);
    END IF;
    RETURN NEW;
END
$$ LANGUAGE PLPGSQL;
//添加触发器
CREATE TRIGGER SC_AFTER_UPDATE
AFTER UPDATE OF GRADE ON SC
FOR EACH ROW
EXECUTE PROCEDURE tri_update_sc();

UPDATE SC   
SET GRADE=100  
WHERE Sno='201215122' AND Cno='2';
UPDATE SC 
SET GRADE=90  
WHERE Sno='201215121' AND Cno='2'; 
//

9.将触发器 tri_update_sc 改名为 update_sc_tri;
ALTER TRIGGER tri_update_sc RENAME TO update_sc_tri;

10.验证触发器禁用后效果
DELETE from SC_U WHERE Newgrade=100;
UPDATE SC 
SET GRADE=90
WHERE Sno='201215122';
UPDATE SC
SET GRADE=85
WHERE Sno='201215121';
ALTER TRIGGER update_sc_tri DISABLE;
UPDATE SC 
SET GRADE=100  
WHERE Sno='201215122' AND Cno='2';
UPDATE SC 
SET GRADE=90  
WHERE Sno='201215121' AND Cno='2'; 
//

SELECT *
FROM PG_TRIGGER;

DROP TRIGGER update_sc_tri;
.......
