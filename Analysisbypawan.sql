CREATE DATABASE ELEVATELABTASK3;
CREATE TABLE sales(
Order_Date DATE,
Time TIME,
Aging FLOAT,
Customer_Id FLOAT,
Gender VARCHAR(100),
Device_Type VARCHAR(100),
Customer_Login_Type VARCHAR(100),
Product_Category VARCHAR(100),
Product VARCHAR(100),
Sales FLOAT,
Quantity FLOAT,
Discount FLOAT,
Profit FLOAT,
Shipping_Cost FLOAT,
Order_priority VARCHAR(100),
Payment_method VARCHAR(100)
);
COPY sales FROM 'C:\Elevate lab internship\E-commerce Dataset.csv\E-commerce Dataset.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM sales;

/* high profit electronics orders8*/

SELECT AVG(Profit) FROM sales WHERE Product_Category='Electronic';
SELECT DISTINCT(Product), Profit 
FROM sales
WHERE Product_Category = 'Electronic' 
  AND Profit > 60
ORDER BY Profit DESC;

--  web users with critical order priority
SELECT Order_Date,Customer_Id, Gender, Order_priority
FROM sales
WHERE Device_Type = 'Web' 
  AND Order_priority = 'Critical'
ORDER BY Order_Date;


/*aggregation functions*/
--SALES PERFORMANCE BY PRODUCT_CATEGORY
SELECT Product_Category,SUM(Sales) as Total_sales,
AVG(Profit) as avg_profit,
COUNT(*) as order_count FROM sales GROUP BY Product_Category
ORDER BY total_sales DESC;

--payment method analysis
SELECT Payment_method,
COUNT(Payment_method) as totaltransactions,
AVG(Discount) as avg_discount
FROM sales
GROUP BY Payment_method;

--joins
CREATE TABLE Customers (
    Customer_Id FLOAT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Join_Date DATE
);
-- Now join with sales
SELECT 
    s.Order_Date,
    c.Customer_Name,
    SUM(s.Sales) AS total_spent
FROM sales s
INNER JOIN customers c 
  ON s.Customer_Id = c.Customer_Id
GROUP BY s.Order_Date, c.Customer_Name;


--SUBQUERIES
SELECT Customer_Id, SUM(Sales) AS total_spent
FROM sales
GROUP BY Customer_Id
HAVING SUM(Sales) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(Sales) AS total_spent
        FROM sales
        GROUP BY Customer_Id
    ) AS subquery
);
SELECT customer_id,SUM(sales) as Total_spent FROM sales GROUP BY customer_id;

-- Product performance vs category average
SELECT 
    Product,
    AVG(Sales) AS product_avg,
    (SELECT AVG(Sales) 
     FROM sales s2 
     WHERE s2.Product_Category = s1.Product_Category) 
     AS category_avg
FROM sales s1
GROUP BY Product, Product_Category;

--views for common analysis
--Create customer lifetime value view
CREATE VIEW customer_lifetime_value AS
SELECT 
    Customer_Id,
    COUNT(DISTINCT Order_Date) AS visit_count,
    SUM(Sales) AS total_spent,
    SUM(Profit) AS total_profit
FROM sales
GROUP BY Customer_Id;
SELECT * FROM customer_lifetime_value;

--  Daily sales performance view
CREATE VIEW daily_sales AS
SELECT 
    Order_Date,
    SUM(Sales) AS daily_sales,
    SUM(Quantity) AS total_items_sold,
    AVG(Discount) AS avg_discount
FROM sales
GROUP BY Order_Date;
SELECT * FROM daily_sales;

--query Optimization
-- Create indexes on frequently used columns
CREATE INDEX idx_order_date ON sales(Order_Date);
CREATE INDEX idx_product_category ON sales(Product_Category);
CREATE INDEX idx_customer_id ON sales(Customer_Id);
SELECT * FROM sales
WHERE Order_Date='02-01-2018';

--ADVANCE ANALYSIS
-- Time-based sales trend
SELECT
    EXTRACT(YEAR FROM Order_Date) AS year,
    EXTRACT(MONTH FROM Order_Date) AS month,
    Product_Category,
    SUM(Sales) AS monthly_sales,
    LAG(SUM(Sales), 1) OVER (PARTITION BY Product_Category ORDER BY EXTRACT(YEAR FROM Order_Date), EXTRACT(MONTH FROM Order_Date)) AS prev_month_sales
FROM sales
GROUP BY year, month, Product_Category;

-- Discount effectiveness analysis
SELECT
    CASE
        WHEN Discount < 0.1 THEN '0-10%'
        WHEN Discount < 0.2 THEN '10-20%'
        ELSE '20%+'
    END AS discount_range,
    AVG(Quantity) AS avg_quantity,
    AVG(Sales) AS avg_sales,
    COUNT(*) AS orders_count
FROM sales
GROUP BY discount_range;