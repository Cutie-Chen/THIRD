(1)查询顾客表中的顾客号（customer_id）、顾客名（name）和信用卡额度（credit_limit）
SELECT customer_id,name,credit_limit 
FROM customers;

(2)查询顾客的所有信息
SELECT * FROM customers;

(3)查询订单表中的订单号，顾客号，状态，订单日期，并按订单日期降序显示结果
SELECT order_id,customer_id,status,order_date 
FROM orders 
ORDER BY order_date DESC;

（4）查询联系表中的名和姓，并按名升序，姓降序显示
SELECT first_name,last_name 
FROM contacts
ORDER BY first_name ASC,last_name DESC;

(5)执行以下语句并观察 state 列 NULL 值的显示位置，得出结论 
SELECT country_id, city,state FROM locations ORDER BY city,state;  
SELECT country_id, city,state FROM locations ORDER BY state ASC NULLS LAST; 
SELECT country_id, city,state FROM locations ORDER BY state ASC NULLS FIRST ;  

（6）查询订单细节表中的产品号和数量，查询结果应无重复元组
SELECT DISTINCT item_id,quantity
FROM order_items;

（7）查询产品表中的产品名为‘Kingston’的产品名，产品描述和价格
SELECT product_name,description,list_price 
FROM products 
WHERE product_name = 'Kingston';

（8）查询产品表中所有价格大于 500 且 category_id 为 4 的产品名和价格
SELECT product_name,list_price 
FROM products 
WHERE category_id = 4 AND list_price > 500;

（9）查询产品表中所有价格在 650 和 680 之间的产品名和价格并按价格升序显示结果
SELECT product_name,list_price 
FROM products 
WHERE list_price BETWEEN 650 AND 680 
ORDER BY list_price ASC;

（10）查询雇员表中的名和姓，名和姓的字段分别显示为"First Name"和"Family Name"
SELECT first_name AS "First Name",last_name AS "Family Name "
FROM employees;


（11）查询产品表中的产品名及毛利，并按毛利结果降序显示，毛利名为 gross_profit，毛利= 
list_price - standard_cost 
SELECT product_name,list_price-standard_cost gross_profit 
FROM products 
ORDER BY gross_profit DESC;

（12）查询雇员表中每个雇员对应的经理名，要求第一列字段名为 employee，第二列字段名为
manager，无其他字段 
SELECT e1.first_name||' '||e1.last_name AS employee,
e2.first_name||' '||e2.last_name AS manager
FROM employees e1,employees e2
WHERE e1.manager_id=e2.employee_id;

（13）查询产品表中所有以 Asus 开头的产品名和价格，并以价格降序显示 
SELECT product_name,list_price
FROM products
WHERE product_name LIKE 'Asus%'
ORDER BY list_price DESC;

（14）查询联系表中电话号码不是以‘+1’开头的名、姓和电话号码，并以名升序显示 
SELECT first_name,last_name,phone
FROM contacts
WHERE phone NOT LIKE '+1%'
ORDER BY first_name ASC;

（15）查询联系表中的电话号码和电子邮件，要求名中包含‘Je_i’且以名升序显示 
SELECT phone,email
FROM contacts
WHERE first_name LIKE '%Je_i%'
ORDER BY first_name ASC;

（16）查询联系表中所有以开头'Je'的名，且至少包含 3 个字符的名，姓，电子邮件和电话 
SELECT first_name
FROM contacts
WHERE first_name LIKE 'Je%' AND length(first_name)>=3 AND length(last_name)>=3
AND length(email)>=3 AND length(phone)>=3;

（17）查询订单表中所有没有销售员负责的订单
SELECT * FROM orders
WHERE salesman_id IS NULL;


（18）统计每个顾客的订单总数（查询订单表） 
SELECT customer_id,count(customer_id) AS "order numbers"
FROM orders 
GROUP BY customer_id;

（19）统计每个订单的总价格大于 1000000 的订单号和总价格，并按总价格降序显示结果 
SELECT order_id,unit_price*quantity AS sum_price
FROM order_items
WHERE sum_price>1000000
ORDER BY sum_price DESC;

（20）创建一个折扣表 discounts,查询折扣表中折扣信息出现“25%”的产品号和折扣信息。
SELECT product_id,discount_message
FROM discounts
WHERE discount_message LIKE '%50\%%';

CREATE TABLE palette_a(
    id INT PRIMARY KEY,
    color VARCHAR2(100) NOT NULL);

CREATE TABLE palette_b(
    id INT PRIMARY KEY,
    color VARCHAR2(100) NOT NULL);

Insert into palette_a values (1,'Red'),(2,'Green'),(3,'Blue'),(4,'Purple');
Insert into palette_b values (1,'Green'),(2,'Red'),(3,'Cyan'),(4,'Brown');

（4）查询两张表中相同颜色的所有信息。
SELECT * FROM palette_a A,palette_b B
WHERE A.color=B.color;

（5）查询 palette_a 表中颜色不出现在 palette_b 表中的两张表的 id 和颜色（用左外连接）。
SELECT *
FROM palette_a A LEFT OUTER JOIN palette_b B
ON A.color = B.color
WHERE B.color IS NULL;

（6）查询 palette_b 表中颜色不出现在 palette_a 表中的两张表的 id 和颜色（用右外连接）。
SELECT * 
FROM palette_a A RIGHT OUTER JOIN palette_b B
ON A.color = B.color
WHERE A.color IS NULL;

（7）查询（5）或（6）两种情况的信息（用（全）外连接）。
SELECT *
FROM palette_a A FULL OUTER JOIN palette_b B
ON A.color = B.color
WHERE A.color IS NULL OR B.color IS NULL;

（8）查询产品表 products 中的 product_id, product_name, list_price 信息，要求产品定价 list_price 大于
其平均定价 list_price。
SELECT product_id,product_name,list_price
FROM products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM products
);

（9）查询产品表 products 中最便宜产品的 product_id, product_name, list_price。
SELECT product_id,product_name,list_price
FROM products
WHERE list_price = (
    SELECT MIN(list_price)
    FROM products
);

（10）查询没有一个订单的顾客姓名。
SELECT name
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id FROM orders
);

（11）查询产品表 products 中产品的 product_id, product_name, list_price，要求产品定价 list_price 大于
其同类产品（可由 category_id 表达）的平均定价。
SELECT product_id,product_name,list_price
FROM products A
WHERE list_price > (
    SELECT AVG(list_price)
    FROM products B
    WHERE A.category_id = B.category_id
);

（12）查询有订单 order 的所有顾客 customer 姓名（查询涉及 customers 表和 orders 表）。
SELECT name
FROM customers
WHERE EXISTS(
    SELECT customer_id
    FROM orders
    WHERE orders.customer_id = customers.customer_id
);

（13）执行以下两条语句，观察有何不同，能否得出某些初步结论？

（14）找出所有没有订单的顾客姓名（查询涉及 customers 表和 orders 表）。
SELECT name
FROM customers
WHERE NOT EXISTS(
    SELECT customer_id
    FROM orders
    WHERE orders.customer_id = customers.customer_id
);

（15）查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价高于产品种类 1 中
的任何产品定价。
SELECT product_name,list_price
FROM products
WHERE list_price > ANY(
    SELECT list_price
    FROM products
    WHERE category_id = 1
);

（16）查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价高于产品种类 1 中
的所有定价。
SELECT product_name,list_price
FROM products
WHERE list_price > ALL(
    SELECT list_price
    FROM products
    WHERE category_id = 1
);

（17）查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价低于产品种类的所
有平均定价。
SELECT product_name,list_price
FROM products
WHERE list_price < ALL(
    SELECT AVG(list_price)
    FROM products
    GROUP BY category_id
);

（18）查询 contacts 表和 employees 表中的所有 last_name，并以 last_name 升序显示。
SELECT last_name
FROM(
    SELECT last_name FROM contacts
    UNION
    SELECT last_name FROM employees
)
ORDER BY last_name ASC;

（19）查询 contacts 表和 employees 表中的所有 last_name，并以 last_name 升序显示。
实现要求：保留重复+UNION ALL（必须）+其它查询方法（如果找到）
SELECT last_name
FROM(
    SELECT last_name FROM contacts
    UNION ALL
    SELECT last_name FROM employees
)
ORDER BY last_name ASC;

（20）查询同时出现在 contacts 表和 employees 表中的所有 last_name。
实现要求：INTERSECT（必须）+其它查询方法（如果找到）
SELECT last_name FROM contacts
INTERSECT
SELECT last_name FROM employees;

（21）查询在产品表 products 中而不在库存表 inventories 中的产品号 product_id。
实现要求：MINUS/EXCEPT（必须）+其它查询方法（如果找到）
SELECT product_id FROM products
EXCEPT
SELECT product_id FROM inventories;