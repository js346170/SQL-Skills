-- [FILE: tutorial2.sql]
-- [This file demonstrates various SQL techniques across multiple databases]

-- =============================================
-- SECTION 1: EXPLORING sql_invoicing DATABASE
-- =============================================

-- View all clients
select * from sql_invoicing.clients as cli;

-- View all invoices
select * from sql_invoicing.invoices as inv;

-- View payment methods
select * from sql_invoicing.payment_methods as meth;

-- View payment records
select * from sql_invoicing.payments as pay;

-- =============================================
-- SECTION 2: WORKING WITH sql_store DATABASE
-- =============================================

-- Switch to sql_store database
USE sql_store;

-- BASIC QUERIES -------------------------------
-- Get all customers sorted by first name
SELECT * FROM sql_store.customers ORDER BY first_name;

-- Select specific columns with calculations
SELECT 
    last_name, 
    first_name, 
    points, 
    points + 10,  -- Simple arithmetic
    points * 10 + 100 AS special_points_program  -- Aliased calculated column
FROM sql_store.customers;

-- Get all customers (no ordering)
SELECT * FROM sql_store.customers;

-- Get unique states
SELECT DISTINCT state FROM sql_store.customers;

-- PRODUCT ANALYSIS ----------------------------
-- View all products
SELECT * FROM sql_store.products;

-- Calculate 10% price markup
SELECT 
    name, 
    unit_price, 
    (unit_price * 1.1) AS markup_price  -- Price increase calculation
FROM sql_store.products;

-- =============================================
-- SECTION 3: FILTERING TECHNIQUES
-- =============================================

-- WHERE CLAUSE EXAMPLES -----------------------
-- Customers NOT in Virginia
SELECT * FROM sql_store.customers WHERE state <> 'VA';

-- Order filtering (note: date typo in condition)
SELECT * FROM sql_store.orders WHERE order_date >= '2019=01-01';

-- Compound conditions (OR operator)
SELECT * FROM sql_store.customers 
WHERE birth_date > '1990-01-01' OR points > 1000;

-- Order items with calculated condition
SELECT * FROM sql_store.order_items 
WHERE order_id = 6 AND unit_price * quantity > 30;  -- Using calculation in condition

-- IN OPERATOR ---------------------------------
-- Products with specific quantities in stock
SELECT * FROM sql_store.products 
WHERE quantity_in_stock IN ('49', '38', '72');

-- BETWEEN OPERATOR ----------------------------
-- Customers with points in range
SELECT * FROM sql_store.customers WHERE points BETWEEN 1000 AND 3000;

-- Customers born in the 1990s
SELECT * FROM sql_store.customers 
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01';

-- PATTERN MATCHING ----------------------------
-- Customers with last name starting with 'b'
SELECT * FROM sql_store.customers where last_name like 'b%';

-- Last name exactly 6 characters ending with 'y'
SELECT * FROM sql_store.customers WHERE last_name LIKE '_____y'; 

-- Address contains 'trail' or 'avenue'
SELECT * FROM sql_store.customers 
WHERE address LIKE '%trail%' OR address LIKE '%avenue%';

-- Phone numbers ending with '9' (11 characters total)
SELECT * FROM sql_store.customers WHERE phone LIKE '___________9';

-- REGULAR EXPRESSIONS -------------------------
-- Last name ends with 'field'
SELECT * FROM sql_store.customers WHERE last_name REGEXP 'field$';

-- First name matches 'ambur' or 'ELKA'
SELECT * FROM sql_store.customers WHERE first_name REGEXP 'ambur|ELKA';

-- Last name ends with 'EY' or 'ON'
SELECT * FROM sql_store.customers WHERE last_name REGEXP 'EY$|ON$';

-- Last name starts with 'MY' or contains 'SE'
SELECT * FROM sql_store.customers WHERE last_name REGEXP '^MY|SE';

-- Last name contains 'BR' or 'BU'
SELECT * FROM sql_store.customers WHERE last_name REGEXP 'BR|BU';

-- NULL HANDLING -------------------------------
-- Customers without phone numbers
SELECT * FROM sql_store.customers WHERE phone IS NULL;

-- Orders not yet shipped
SELECT * FROM sql_store.orders where shipped_date IS NULL;

-- =============================================
-- SECTION 4: SORTING AND LIMITING
-- =============================================

-- Sort customers by first name (descending)
SELECT * FROM sql_store.customers ORDER BY first_name DESC;

-- Calculate total price and sort (order items)
SELECT *, quantity * unit_price AS total_price
FROM sql_store.order_items
WHERE order_id = 2
ORDER BY total_price DESC;  -- Sort by calculated column

-- Limit results to first 3 customers
SELECT * FROM sql_store.customers LIMIT 3;

-- Pagination example (skip 6, show next 3)
SELECT * FROM sql_store.customers LIMIT 6, 3;

-- Top 3 customers by points
SELECT * FROM sql_store.customers 
ORDER BY points DESC
LIMIT 3;

-- =============================================
-- SECTION 5: JOIN TECHNIQUES
-- =============================================

-- INNER JOINS ---------------------------------
-- Basic join: orders with customer info
SELECT 
    order_id, 
    first_name, 
    last_name, 
    o.customer_id
FROM sql_store.orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Join products with order items + calculations
SELECT 
    p.product_id, 
    name, 
    quantity, 
    oi.unit_price, 
    (quantity * oi.unit_price) AS total_price 
FROM sql_store.order_items oi
JOIN sql_store.products p ON oi.product_id = p.product_id;

-- LEFT JOINS ----------------------------------
-- All products (even unsold ones)
SELECT 
    p.product_id, 
    p.name, 
    oi.quantity
FROM sql_store.products p
LEFT JOIN sql_store.order_items oi
    ON p.product_id = oi.product_id
ORDER BY p.product_id;

-- Multi-table left join (customers + orders + shippers)
SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    sh.name AS shipper
FROM sql_store.customers c
LEFT JOIN sql_store.orders o ON c.customer_id = o.customer_id
LEFT JOIN sql_store.shippers sh ON o.shipper_id = sh.shipper_id
ORDER BY c.customer_id;

-- Complex multi-join with statuses
select 
    o.order_date, 
    o.order_id, 
    c.first_name,
    sh.name AS shipper, 
    os.name as status
FROM sql_store.orders o
JOIN sql_store.customers c ON c.customer_id = o.customer_id
LEFT JOIN sql_store.shippers sh ON o.shipper_id = sh.shipper_id
JOIN sql_store.order_statuses os ON o.status = os.order_status_id
ORDER BY o.order_id;

-- SELF JOIN -----------------------------------
-- Employee hierarchy (employees + managers)
USE sql_hr;  -- Switching databases
SELECT 
    e.employee_id,
    e.first_name,
    m.first_name as manager
FROM employees e
LEFT JOIN employees m ON e.reports_to = m.employee_id;

-- USING CLAUSE --------------------------------
-- Simplified join syntax (when column names match)
SELECT
    o.order_id,
    c.first_name,
    sh.name AS shipper
FROM sql_store.orders o
JOIN sql_store.customers c USING (customer_id)  -- Equivalent to ON o.customer_id = c.customer_id
LEFT JOIN sql_store.shippers sh USING (shipper_id);

-- Composite key join
SELECT *
FROM sql_store.order_items oi
JOIN sql_store.order_item_notes oin
    USING (order_id, product_id);  -- Matching two columns

-- CROSS JOIN ----------------------------------
-- All possible shipper-product combinations
SELECT
    sh.name AS shipper,
    p.name AS product
FROM sql_store.shippers sh
CROSS JOIN sql_store.products p  -- Cartesian product
ORDER BY sh.name;

-- MULTI-DATABASE JOIN -------------------------
-- Join across different databases (sql_invoicing)
SELECT
    p.date,
    c.name AS client,
    p.amount,
    pm.name AS payment_method
FROM sql_invoicing.payments p
JOIN sql_invoicing.clients c USING (client_id)
JOIN sql_invoicing.payment_methods pm
    ON p.payment_method = pm.payment_method_id;