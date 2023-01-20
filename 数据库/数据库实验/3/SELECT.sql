SELECT customer_id,name,credit_limit
FROM CUSTOMERS;

SELECT *
FROM CUSTOMERS;

SELECT order_id,customer_id,status,order_date
FROM ORDERS
ORDER BY order_date DESC;

SELECT first_name,last_name
FROM CONTACTS
ORDER BY first_name ASC,last_name DESC;

SELECT country_id, city,state 
FROM locations 
ORDER BY city,state; 

SELECT country_id, city,state 
FROM locations 
ORDER BY state ASC NULLS FIRST ; 

SELECT country_id, city,state 
FROM locations
ORDER BY state ASC NULLS LAST;

SELECT DISTINCT product_id,quantity
FROM ORDER_ITEMS;

SELECT product_name,description,list_price
FROM PRODUCTS
WHERE product_name='Kingston';

SELECT product_name,list_price
FROM PRODUCTS
WHERE list_price>500 AND category_id=4;

SELECT product_name,list_price
FROM PRODUCTS
WHERE list_price BETWEEN 650 AND 680
ORDER BY list_price;

SELECT first_name AS "First Name",last_name AS "Family Name"
FROM EMPLOYEES;

SELECT product_name,list_price - standard_cost  gross_profit
FROM PRODUCTS
ORDER BY gross_profit

SELECT e1.first_name||','||e1.last_name AS employee_name,
e2.first_name||','||e2.last_name AS manager_name
FROM EMPLOYEES e1,EMPLOYEES e2
WHERE e1.manager_id=e2.employee_id;

SELECT product_name,list_price
FROM PRODUCTS
WHERE product_name LIKE 'Asus%'
ORDER BY list_price DESC;

SELECT first_name,last_name,phone
FROM CONTACTS
WHERE phone NOT LIKE '+1%'
ORDER BY first_name ASC;

SELECT email,phone
FROM CONTACTS
WHERE first_name LIKE 'Je_i'
ORDER BY first_name ASC;


SELECT first_name,last_name,email,phone
FROM CONTACTS
WHERE first_name LIKE 'Je_%';
//另外解法
SELECT first_name,last_name,email,phone
FROM CONTACTS
WHERE first_name LIKE 'Je%' AND length(first_name)>=3;

SELECT *
FROM ORDERS
WHERE salesman_id IS NULL;

SELECT COUNT(customer_id)
FROM ORDERS
GROUP BY customer_id;

SELECT order_id,unit_price*quantity AS sum_price
FROM ORDER_ITEMS
WHERE sum_price>1000000
ORDER BY sum_price DESC;

CREATE TABLE discounts
 ( product_id NUMBER, 
 discount_message VARCHAR2( 255 ) NOT NULL, 
 PRIMARY KEY( product_id ) );
INSERT INTO discounts(product_id, discount_message) VALUES(1, 'Buy 1 and Get 25% OFF on 2nd ');
INSERT INTO discounts(product_id, discount_message) VALUES(2, 'Buy 2 and Get 50% OFF on 3rd ');
INSERT INTO discounts(product_id, discount_message) VALUES(3, 'Buy 3 Get 1 free');

SELECT product_id,discount_message
FROM discounts
WHERE discount_message LIKE '%25\%%' ESCAPE'\';