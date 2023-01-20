1.
INSERT INTO regions VALUES ('5','Oceania');

2.
UPDATE countries SET region_id='5' WHERE country_name='Australia';

3.
INSERT INTO countries VALUES ('NO','Norway','1'), ('ES','Spain','1'),
('SE','Sweden','1'), ('PT','Portugal','1'), ('NZ','New Zealand','5');

4.
CREATE TABLE asia_countries (
country_id CHAR(2),
country_name VARCHAR2(40));

5.
INSERT INTO asia_countries 
SELECT country_id,country_name
FROM countries,regions 
WHERE regions.region_id=countries.region_id AND region_name='Asia';

6.
CREATE VIEW order_total(order_id,total_price) AS
SELECT order_id,SUM(quantity*unit_price) AS total_price
FROM order_items
GROUP BY order_id;

7.
SELECT * FROM order_total WHERE order_id='97';

8.
UPDATE order_items SET unit_price=unit_price+4 WHERE product_id='99';

9.
SELECT * FROM order_total WHERE order_id='97';

10.
DELETE FROM asia_countries WHERE country_id='IN';

11.
truncate asia_countries;

12.
DROP TABLE asia_countries;
DROP VIEW order_total;

13.
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager 
FOREIGN KEY(manager_id) REFERENCES employees(employee_id) on delete cascade;
\d employees;

14.
SELECT * FROM employees WHERE employee_id='1';

15.
ALTER TABLE employees DROP CONSTRAINT fk_employees_manager;
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager 
FOREIGN KEY(manager_id) REFERENCES employees(employee_id);

16.
DELETE FROM employees WHERE employee_id='1';

17.
ALTER TABLE employees DROP CONSTRAINT fk_employees_manager;
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager 
FOREIGN KEY(manager_id) REFERENCES employees(employee_id) on delete cascade;

18.
DELETE FROM employees WHERE employee_id='1';

--思考
CREATE TABLE test(
    id CHAR(4) PRIMARY KEY,
    father_id CHAR(4),
    CONSTRAINT test_fk FOREIGN KEY(father_id) 
    REFERENCES test(id)
);
INSERT INTO test VALUES('1',NULL),('2','1'),('3','1');
UPDATE test SET id='4' WHERE id='1';
ALTER TABLE test DROP CONSTRAINT test_fk;
ALTER TABLE test ADD CONSTRAINT test_fk FOREIGN KEY(father_id) 
REFERENCES test(id) ON UPDATE CASCADE;