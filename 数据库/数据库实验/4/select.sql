//总结
1.注意distince的用法
2.group by 可以在子查询中用
3.UNION排序问题——解决方法用union将两张表连成一张表，当做一个派生表去查询。(注意派生表需要有别名)
派生表里有聚集函数的时候还要记得补上属性列
4.不相关子查询：子查询只需要做一次
相关子查询：父查询每查找一次，子查询就需要更新一次——比如查询本类平均定价

CREATE TABLE palette_a
( id INT PRIMARY KEY,
color VARCHAR2 (100) NOT NULL);
CREATE TABLE palette_b
( id INT PRIMARY KEY,
color VARCHAR2 (100) NOT NULL);
//注意values插入多个值时的操作
为表 palette_a 添加样例数据：
INSERT INTO palette_a
VALUES(1, 'Red'), (2, 'Green'), (3, 'Blue'), (4, 'Purple');

为表 palette_b 添加样例数据：
INSERT INTO palette_b
VALUES(1, 'Green'), (2, 'Red'), (3, 'Cyan'), (4, 'Brown');

查询两张表中相同颜色的所有信息。
SELECT *
FROM palette_a,palette_b
WHERE palette_a.color=palette_b.color;

查询 palette_a 表中颜色不出现在 palette_b 表中的两张表的 id 和颜色（用左外连接）。
SELECT *
FROM palette_a
LEFT OUTER JOIN palette_b
ON palette_a.color=palette_b.color
WHERE palette_b.id IS NULL;

查询 palette_b 表中颜色不出现在 palette_a 表中的两张表的 id 和颜色（用右外连接）。
SELECT *
FROM palette_a
RIGHT OUTER JOIN palette_b
ON palette_a.color=palette_b.color
WHERE palette_a.id IS NULL;

查询（5）或（6）两种情况的信息（用（全）外连接）。
SELECT *
FROM palette_a
FULL OUTER JOIN palette_b
ON palette_a.color=palette_b.color
WHERE palette_b.id IS NULL OR palette_a.id IS NULL;

查询产品表 products 中的 product_id, product_name, list_price 信息，要求产品定价 list_price 大于
其平均定价 list_price。
SELECT product_id,product_name,list_price
FROM products
WHERE list_price >(
                    SELECT AVG(list_price)
                    FROM products
                  );

查询产品表 products 中最便宜产品的 product_id, product_name, list_price。
SELECT product_id,product_name,list_price
FROM products
WHERE list_price =(
                    SELECT MIN(list_price)
                    FROM products
                   );

查询没有一个订单的顾客姓名。
SELECT name
FROM customers
WHERE customer_id NOT IN (
                            SELECT customer_id
                            FROM orders
                         );


查询产品表 products 中产品的 product_id, product_name, list_price，要求产品定价 list_price 大于
其同类产品（可由 category_id 表达）的平均定价
SELECT product_id,product_name,list_price
FROM products x
WHERE list_price > (
                    SELECT AVG(list_price)
                    FROM products y
                    WHERE x.category_id=y.category_id
                    );


查询有订单 order 的所有顾客 customer 姓名（查询涉及 customers 表和 orders 表）。
SELECT name
FROM customers
WHERE EXISTS (
                SELECT *
                FROM orders
                WHERE customers.customer_id=orders.customer_id
             );
//另解(注意这里的distinct，y因为在orders表中有重复的customer_id)
SELECT DISTINCT name
FROM customers,orders
WHERE customers.customer_id=orders.customer_id;

执行以下两条语句，观察有何不同，能否得出某些初步结论？
SELECT * 
FROM customers 
WHERE customer_id IN (NULL);
SELECT * 
FROM customers 
WHERE EXISTS (SELECT NULL FROM customers);

找出所有没有订单的顾客姓名（查询涉及 customers 表和 orders 表）。
SELECT name
FROM customers
WHERE NOT EXISTS(
                    SELECT *
                    FROM orders
                    WHERE customers.customer_id=orders.customer_id
                );

查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价高于产品种类 1 中
的任何产品定价。
SELECT product_name,list_price
FROM products
WHERE list_price > ANY (
                        SELECT list_price
                        FROM products
                        WHERE category_id=1
                       );
                    
查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价高于产品种类 1 中
的所有定价
SELECT product_name,list_price
FROM products
WHERE list_price > ALL(
                        SELECT list_price
                        FROM products
                        WHERE category_id=1
                      );
                    
查询产品表 products 中的产品名 product_name 和定价 list_price，要求其定价低于产品种类的所
有平均定价。
//注意观察子查询中是否能用groupby——可以
SELECT product_name,list_price
FROM products
WHERE list_price < ALL(
                        SELECT AVG(list_price)
                        FROM products
                        GROUP BY category_id
                       );

查询 contacts 表和 employees 表中的所有 last_name，并以 last_name 升序显示。
//注意这里需要进行排序的话，要用到基于派生表的查询
SELECT last_name
FROM(
    SELECT last_name FROM contacts
    UNION
    SELECT last_name FROM employees
)AS lastnamet
ORDER BY last_name ASC;

查询 contacts 表和 employees 表中的所有 last_name，并以 last_name 升序显示。
SELECT last_name
FROM(
    SELECT last_name FROM contacts
    UNION ALL
    SELECT last_name FROM employees
) AS lastnamet
ORDER BY last_name ASC;         

查询同时出现在 contacts 表和 employees 表中的所有 last_name。
SELECT distinct last_name
FROM contacts
INTERSECT
SELECT last_name
FROM employees;

查询在产品表 products 中而不在库存表 inventories 中的产品号 product_id。
SELECT product_id
FROM products
EXCEPT
SELECT product_id
FROM inventories;