CREATE TABLE employees(
employee_id NUMBER,
first_name VARCHAR2(255),
last_name VARCHAR2(255),
email VARCHAR2(255),
phone VARCHAR2(20),
hire_date DATE,
manager_id NUMBER,
job_title VARCHAR2(255)
);

CREATE TABLE orders(
order_id number,
customer_id number,
status varchar2(20),
salesman_id number,
order_date date);

create table order_items(
order_id number,
item_id number(12),
product_id number,
quantity number(8,2),
unit_price number(8,2));

create table customers(
customer_id number,
name varchar2(255),
address varchar2(255),
website varchar2(255),
credit_limit number(8,2));

create table products(
product_id number,
product_name varchar2(255),
description varchar2(2000),
standard_cost number(9,2),
list_price number(9,2),
category_id number);

create table contacts(
contact_id number,
first_name varchar2(255),
last_name varchar2(255),
email varchar2(255),
phone varchar2(20),
customer_id number);

create table product_categories(
category_id number,
category_name varchar2(255));

create table inventories(
product_id number,
warehouse_id number,
quantity number(8));

create table warehouses(
warehouse_id number,
warehouse_name varchar2(255),
location_id number);

create table locations(
location_id number,
address varchar2(255),
postal_code varchar2(20),
city varchar2(50),
state varchar2(50),
country_id char(2));

create table countries(
country_id char(2),
country_name varchar2(40),
region_id number);

create table regions(
region_id number,
region_name varchar2(50));
