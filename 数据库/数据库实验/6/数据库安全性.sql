CREATE VIEW saleman
AS 
SELECT *
FROM employees
WHERE job_title='Sales Representative';

CREATE VIEW  salesman_contacts(first_name,last_name,email,phone)
AS
SELECT first_name,last_name,email,phone
FROM saleman;

SELECT *
FROM saleman;

SELECT * 
FROM salesman_contacts;

\c - omm
create user user1 password 'Bigdata123';
\c - user1

select * from salesman_contacts;
\c - chenxinlei
grant select on salesman_contacts to user1;

\c - user1
select * from salesman_contacts;

select * 
from pg_roles;

select *
from pg_authid;

