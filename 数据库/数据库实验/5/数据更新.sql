（1）	为地区表regions新增一条记录：(‘5’,’Oceania’)。 
INSERT INTO regions
VALUES('5','Oceania');

UPDATE countries
SET region_id=5
WHERE country_name='Australia';

INSERT INTO countries
VALUES('NO','Norway','1'), ('ES','Spain','1'), 
('SE','Sweden','1'), ('PT','Portugal','1'), ('NZ','New Zealand','5');

CREATE TABLE Asia_countries
(
    country_id CHAR(2),
    country_name VARCHAR2(40),
    region_id NUMBER
);

INSERT INTO Asia_countries
SELECT *
FROM countries
WHERE region_id IN SELECT *
                    FROM regions
                    WHERE region_name='Asia';

CREATE VIEW order_total(order_id,total_price)
As
SELECT order_id,sum(quantity*unit_price)
FROM order_items
group by order_id;

SELECT *
FROM order_total
WHERE order_id=97;

UPDATE order_items
SET unit_price=unit_price+4
WHERE product_id=99;

SELECT *
FROM order_total
WHERE order_id=97;

DELETE FROM Asia_countries
WHERE country_id='IN';

truncate Asia_countries;

DROP TABLE Asia_countries
DROP VIEW order_total
//查看
\d employees

SELECT *
FROM employees
WHERE manager_id='1';

//注意约束的修改和增加删除。
ALTER TABLE employees
DROP CONSTRAINT fk_employees_manager
ALTER TABLE employees
ADD CONSTRAINT fk_employees_manager
FOREIGN KEY manager_id REFERENCES employees(manager_id);

DELETE FROM employees
WHERE employ_id='1';

ALTER TABLE employees
DROP CONSTRAINT fk_employees_manager
ALTER TABLE employees
ADD CONSTRAINT fk_employees_manager
FOREIGN KEY manager_id REFERENCES employees(manager_id) on delete cascade;

DELETE FROM employees
WHERE employ_id='1';
