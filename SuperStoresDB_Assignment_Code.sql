/*
Task 1: Understanding the data in hand

A. Describe the data in hand in your own words. (Word Limit is 500)

	1. cust_dimen: Details of all the customers
		
        Customer_Name (TEXT): Name of the customer
        Province (TEXT): Province of the customer
        Region (TEXT): Region of the customer
        Customer_Segment (TEXT): Segment of the customer
        Cust_id (TEXT): Unique Customer ID
	
    2. market_fact: Details of every order item sold
		
        Ord_id (TEXT): Order ID
        Prod_id (TEXT): Prod ID
        Ship_id (TEXT): Shipment ID
        Cust_id (TEXT): Customer ID
        Sales (DOUBLE): Sales from the Item sold
        Discount (DOUBLE): Discount on the Item sold
        Order_Quantity (INT): Order Quantity of the Item sold
        Profit (DOUBLE): Profit from the Item sold
        Shipping_Cost (DOUBLE): Shipping Cost of the Item sold
        Product_Base_Margin (DOUBLE): Product Base Margin on the Item sold
        
    3. orders_dimen: Details of every order placed
		
        Order_ID (INT): Order ID
        Order_Date (TEXT): Order Date
        Order_Priority (TEXT): Priority of the Order
        Ord_id (TEXT): Unique Order ID
	
    4. prod_dimen: Details of product category and sub category
		
        Product_Category (TEXT): Product Category
        Product_Sub_Category (TEXT): Product Sub Category
        Prod_id (TEXT): Unique Product ID
	
    5. shipping_dimen: Details of shipping of orders
		
        Order_ID (INT): Order ID
        Ship_Mode (TEXT): Shipping Mode
        Ship_Date (TEXT): Shipping Date
        Ship_id (TEXT): Unique Shipment ID

B. Identify and list the Primary Keys and Foreign Keys for this dataset
	(Hint: If a table don’t have Primary Key or Foreign Key, then specifically mention it in your answer.)

	1. cust_dimen
		Primary Key: Cust_id
        Foreign Key: NA
	
    2. market_fact
		Primary Key: NA
        Foreign Key: Ord_id, Prod_id, Ship_id, Cust_id
	
    3. orders_dimen
		Primary Key: Ord_id
        Foreign Key: NA
	
    4. prod_dimen
		Primary Key: Prod_id, Product_Sub_Category
        Foreign Key: NA
	
    5. shipping_dimen
		Primary Key: Ship_id
        Foreign Key: NA
 */
 
/*
Task 2: Basic Analysis

Write the SQL queries for the following:

A. Find the total and the average sales (display total_sales and avg_sales)
*/
	
    SELECT 
    SUM(sales) AS total_sales, AVG(sales) AS avg_sales
	FROM
    market_fact
    
/*
B. Display the number of customers in each region in decreasing order of no_of_customers. 
	The result should contain columns Region, no_of_customers
*/
	
    SELECT 
    region, COUNT(*) AS no_of_customers
	FROM
    cust_dimen
	GROUP BY region
    ORDER BY no_of_customers DESC

/*
C. Find the region having maximum customers (display the region name and max(no_of_customers)
*/
	
    SELECT 
    region, COUNT(*) AS no_of_customers
	FROM
    cust_dimen
	GROUP BY region
	HAVING 
    no_of_customers >= ALL (	SELECT 
												COUNT(*) AS no_of_customers
												FROM
												cust_dimen
												GROUP BY region )

/*
D. Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold)
*/
	
    SELECT 
    prod_id AS product_id, COUNT(*) AS no_of_products_sold
	FROM
    market_fact
	GROUP BY prod_id
	ORDER BY no_of_products_sold DESC

/*
E. Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased 
	(display the customer name, no_of_tables purchased)
 */
 
	SELECT 
    c.customer_name, COUNT(*) AS no_of_tables_purchased
	FROM
    market_fact m
	INNER JOIN
    cust_dimen c ON m.cust_id = c.cust_id
	WHERE
    c.region = 'atlantic'
	AND m.prod_id = ( SELECT 
									prod_id
									FROM
									prod_dimen
									WHERE
									product_sub_category = 'tables'	)
	GROUP BY m.cust_id, c.customer_name
 
/*
Task 3: Advanced Analysis

Write sql queries for the following:

A. Display the product categories in descending order of profits 
	(display the product category wise profits i.e. product_category, profits)?
*/

	SELECT 
    p.product_category, SUM(m.profit) AS profits
	FROM
    market_fact m
	INNER JOIN
    prod_dimen p ON m.prod_id = p.prod_id
	GROUP BY p.product_category
	ORDER BY profits DESC

/*
B. Display the product category, product sub-category and the profit within each sub-category in three columns.
*/

	SELECT 
    p.product_category, p.product_sub_category, SUM(m.profit) AS profits
	FROM
    market_fact m
	INNER JOIN
    prod_dimen p ON m.prod_id = p.prod_id
	GROUP BY p.product_category, p.product_sub_category

/*
C. Where is the least profitable product subcategory shipped the most? For the least
profitable product sub-category, display the region-wise no_of_shipments and the profit made 
in each region in decreasing order of profits (i.e. region, no_of_shipments, profit_in_each_region)
Note: You can hardcode the name of the least profitable product sub- category
*/
	
    SELECT 
    c.region, COUNT(distinct s.ship_id) AS no_of_shipments, SUM(m.profit) AS profit_in_each_region
	FROM
    market_fact m
	INNER JOIN
    cust_dimen c ON m.cust_id = c.cust_id
	INNER JOIN
    shipping_dimen s ON m.ship_id = s.ship_id
	INNER JOIN
    prod_dimen p ON m.prod_id = p.prod_id
	WHERE
    p.product_sub_category IN 
    (	SELECT 							-- Query for identifying the least profitable sub-category
		p.product_sub_category
        FROM
		market_fact m
		INNER JOIN
		prod_dimen p ON m.prod_id = p.prod_id
        GROUP BY p.product_sub_category
        HAVING SUM(m.profit) <= ALL
										(	SELECT 
											SUM(m.profit) AS profits
											FROM
											market_fact m
											INNER JOIN
											prod_dimen p ON m.prod_id = p.prod_id
											GROUP BY p.product_sub_category
										)
	)
	GROUP BY c.region
	ORDER BY profit_in_each_region DESC