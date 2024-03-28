use interview;
------ SEGMENT 1: Database - Tables, Columns, Relationships
----- Q1. Identify the tables in the database and their respective columns.
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'interview';
/* Ans:
TABLE_NAME	COLUMN_NAME
agents	AGENT_CODE
agents	AGENT_NAME
agents	WORKING_AREA
agents	COMMISSION
agents	PHONE_NO
agents	COUNTRY
customer	CUST_CODE
customer	CUST_NAME
customer	CUST_CITY
customer	WORKING_AREA
customer	CUST_COUNTRY
customer	GRADE
customer	OPENING_AMT
customer	RECEIVE_AMT
customer	PAYMENT_AMT
customer	OUTSTANDING_AMT
customer	PHONE_NO
customer	AGENT_CODE
orders	ORD_NUM
orders	ORD_AMOUNT
orders	ADVANCE_AMOUNT
orders	ORD_DATE
orders	CUST_CODE
orders	AGENT_CODE
orders	ORD_DESCRIPTION
*/
----- Q2. Determine the number of records in each table within the schema.
SELECT 'agents' AS table_name, COUNT(*) AS record_count FROM agents
UNION ALL
SELECT 'customer' AS table_name, COUNT(*) AS record_count FROM customer
UNION ALL
SELECT 'orders' AS table_name, COUNT(*) AS record_count FROM orders;
/* Ans:
table_name	record_count
agents		12
customer	25
orders		36
*/
----- Q3. Identify and handle any missing or inconsistent values in the dataset.
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'agents'
    AND is_nullable = 'YES';
    
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customer'
    AND is_nullable = 'YES';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'orders'
    AND is_nullable = 'YES';

----- Q4. Analyse the data types of the columns in each table to ensure they are appropriate for the stored data.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'agents';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customer';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders';

----- Q5. Identify any duplicate records within the tables and develop a strategy for handling them.
SELECT AGENT_CODE, COUNT(*) as count
FROM agents
GROUP BY AGENT_CODE
HAVING count > 1;

SELECT CUST_CODE, COUNT(*) as count
FROM customer
GROUP BY CUST_CODE
HAVING count > 1;

SELECT ORD_NUM, COUNT(*) as count
FROM orders
GROUP BY ORD_NUM
HAVING count > 1;
----------------------------------------------------------------------------------------------------------------------------------------------------
------- SEGMENT 2: Basic Sales Analysis
----- Q1. Write SQL queries to retrieve the total number of orders, total revenue, and average order value.
SELECT COUNT(*) AS total_orders
FROM orders;
--- Ans: 36
SELECT SUM(ORD_AMOUNT) AS total_revenue
FROM orders;
--- Ans: 78600.00
SELECT AVG(ORD_AMOUNT) AS average_order_value
FROM orders;
--- Ans: 2183.333333

/* Q2.The operations team needs to track the agent who has handled the maximum number of high-grade customers. 
Write a SQL query to find the agent_name who has the highest count of customers with a grade of 5. Display the agent_name and the count of high-grade customers.
*/
SELECT a.AGENT_NAME, COUNT(*) AS high_grade_customer_count
FROM agents a
INNER JOIN customer c ON a.AGENT_CODE = c.AGENT_CODE
WHERE c.GRADE = 5
GROUP BY a.AGENT_NAME
ORDER BY high_grade_customer_count DESC
LIMIT 1;
--- Ans: No agent have grade = 5. Check with the below query

SELECT a.AGENT_NAME, c.GRADE, COUNT(*) AS customer_count
FROM agents a
INNER JOIN customer c ON a.AGENT_CODE = c.AGENT_CODE
GROUP BY a.AGENT_NAME, c.GRADE;

/* Q3. The company wants to identify the most active customer cities in terms of the total order amount. 
Write a SQL query to find the top 3 customer cities with the highest total order amount. Include cust_city and total_order_amount in the output.
*/
SELECT c.CUST_CITY, SUM(o.ORD_AMOUNT) AS total_order_amount
FROM customer c
INNER JOIN orders o ON c.CUST_CODE = o.CUST_CODE
GROUP BY c.CUST_CITY
ORDER BY total_order_amount DESC
LIMIT 3;

/* Ans:
CUST_CITY					total_order_amount
Chennai                            	17000
Mumbai                             	12700
London                             	12500
*/

----------------------------------------------------------------------------------------------------------------------------------------------------
------- SEGMENT 3: Customer Analysis
----- Q1: Calculate the total number of customers.
SELECT COUNT(*) AS total_customers
FROM customer;
--- Ans: Total_customer: 25

----- Q2: Identify the top-spending customers based on their total order value.
SELECT c.CUST_NAME, SUM(o.ORD_AMOUNT) AS total_order_value
FROM customer c
INNER JOIN orders o ON c.CUST_CODE = o.CUST_CODE
GROUP BY c.CUST_NAME
ORDER BY total_order_value DESC;
/* Ans:
CUST_NAME	total_order_value
Ramanathan	10500
Holmes		6000
Karolina	5500
Ramesh		5200
Avinash		5000
Ravindran	5000
Winston		4200
Stuart		3500
Bolt		3500
Sundariya	3500
Yearannaidu	3000
Micheal		3000
Steven		2900
Martin		2500
Sasikant	2500
Cook		2500
Venkatpati	2000
Fleming		2000
Jacks		1500
Shilton		1500
Albert		1000
Rangarappa	800
Karl		500
Charles		500
Srinivas	500
*/

----- Q3. Analyse customer retention by calculating the percentage of repeat customers.
SELECT (COUNT(DISTINCT CUST_CODE) / COUNT(*)) * 100 AS customer_retention_percentage
FROM orders;
--- Ans: Customer_rentention_percentage:- 69.4444

----- Q4: Find the name of the customer who has the maximum outstanding amount from every country. 
SELECT c.CUST_COUNTRY, MAX(c.CUST_NAME) AS customer_name, c.OUTSTANDING_AMT
FROM customer c
WHERE (c.CUST_COUNTRY, c.OUTSTANDING_AMT) IN (
    SELECT CUST_COUNTRY, MAX(OUTSTANDING_AMT)
    FROM customer
    GROUP BY CUST_COUNTRY
)
GROUP BY c.CUST_COUNTRY, c.OUTSTANDING_AMT;
/* Ans:
CUST_COUNTRY	customer_name	OUTSTANDING_AMT
USA				Micheal			6000
UK				Stuart			11000
Australia		Jacks			7000
Canada			Shilton			11000
India			Venkatpati		12000
*/
----- Q5: Write a SQL query to calculate the percentage of customers in each grade category (1 to 5). 
SELECT GRADE, COUNT(*) AS customer_count, (COUNT(*) / (SELECT COUNT(*) FROM customer)) * 100 AS percentage
FROM customer
GROUP BY GRADE;
/* Ans:
GRADE	customer_count	percentage
2		10				40
3		5				20
1		9				36
0		1				4
*/
----------------------------------------------------------------------------------------------------------------------------------------------------
------- SEGMENT 4: Agent Performance Analysis
----- Q1: Company wants to provide a performance bonus to their best agents based on the maximum order amount. Find the top 5 agents eligible for it. 
SELECT a.AGENT_NAME, MAX(o.ORD_AMOUNT) AS max_order_amount
FROM agents a
INNER JOIN orders o ON a.AGENT_CODE = o.AGENT_CODE
GROUP BY a.AGENT_NAME
ORDER BY max_order_amount DESC
LIMIT 5;
/* Ans:
AGENT_NAME							max_order_amount
Santakumar                              	4500
Anderson                                	4200
Mukesh                                  	4000
Ivan                                    	4000
Alford                                  	3500
*/
/* Q2: The company wants to analyse the performance of agents based on the number of orders they have handled. 
Write a SQL query to rank agents based on the total number of orders they have processed. Display agent_name, total_orders, and their respective ranking.
*/
SELECT agent_name, total_orders, RANK() OVER (ORDER BY total_orders DESC) AS agent_rank
FROM (
    SELECT a.AGENT_NAME AS agent_name, COUNT(*) AS total_orders
    FROM agents a
    INNER JOIN orders o ON a.AGENT_CODE = o.AGENT_CODE
    GROUP BY a.AGENT_NAME
) AS agent_orders;
/* Ans:
agent_name							total_orders	agent_rank
Mukesh                                  	7			1
Santakumar                              	5			2
Ivan                                    	4			3
Alford                                  	3			4
Anderson                                	3			4
Alex                                    	2			6
Ramasundar                              	2			6
Lucida                                  	2			6
McDen                                   	2			6
Ravi Kumar                              	2			6
Subbarao                                	1			11
Benjamin                                	1			11
*/
/* Q3: Company wants to change the commission for the agents, basis advance payment they collected. Write a sql query which creates a new column updated_commision on the basis below rules.
If the average advance amount collected is less than 750, there is no change in commission.
If the average advance amount collected is between 750 and 1000 (inclusive), the new commission will be 1.5 times the old commission.
If the average advance amount collected is more than 1000, the new commission will be 2 times the old commission.
*/
SET SQL_SAFE_UPDATES = 0;
UPDATE agents
SET updated_commission = CASE
    WHEN (
        SELECT AVG(ADVANCE_AMOUNT)
        FROM orders
        WHERE orders.AGENT_CODE = agents.AGENT_CODE
    ) < 750 THEN commission
    WHEN (
        SELECT AVG(ADVANCE_AMOUNT)
        FROM orders
        WHERE orders.AGENT_CODE = agents.AGENT_CODE
    ) BETWEEN 750 AND 1000 THEN commission * 1.5
    ELSE commission * 2
END;
SET SQL_SAFE_UPDATES = 1;
select * from agents;
/* Ans:
AGENT_CODE	AGENT_NAME									WORKING_AREA					COMMISSION	PHONE_NO			COUNTRY	updated_commission
A001  		Subbarao                                	Bangalore                          	0.14	077-12346674   	 	0.14
A002  		Mukesh                                  	Mumbai                             	0.11	029-12358964   	 	0.11
A003  		Alex                                    	London                             	0.13	075-12458969   	 	0.13
A004  		Ivan                                    	Torento                            	0.15	008-22544166   	 	0.15
A005  		Anderson                                	Brisban                            	0.13	045-21447739   	 	0.26
A006  		McDen                                   	London                             	0.15	078-22255588   	 	0.15
A007  		Ramasundar                              	Bangalore                          	0.15	077-25814763   	 	0.15
A008  		Alford                                  	New York                           	0.12	044-25874365   	 	0.24
A009  		Benjamin                                	Hampshair                          	0.11	008-22536178   	 	0.11
A010  		Santakumar                              	Chennai                            	0.14	007-22388644   	 	0.14
A011  		Ravi Kumar                              	Bangalore                          	0.15	077-45625874   	 	0.15
A012  		Lucida                                  	San Jose                           	0.12	044-52981425   	 	0.12
*/
----------------------------------------------------------------------------------------------------------------------------------------------------
------- SEGMENT 5: SQL Tasks
/* Q1: Add a new column named avg_rcv_amt in the table customers which contains the average receive amount for every country.
 Display all columns from the customer table along with the avg_rcv_amt column in the last.
*/
alter table customer
drop column avg_rcv_amt;
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM customer;
ALTER TABLE customer
ADD avg_rcv_amt decimal(12,2);

UPDATE customer c1
JOIN (
    SELECT CUST_COUNTRY, AVG(RECEIVE_AMT) AS avg_receive_amt
    FROM customer
    WHERE CUST_COUNTRY IS NOT NULL
    GROUP BY CUST_COUNTRY
) c2 ON c1.CUST_COUNTRY = c2.CUST_COUNTRY
SET c1.avg_rcv_amt = c2.avg_receive_amt;
SET SQL_SAFE_UPDATES = 1;
/* Ans:
CUST_CODE	CUST_NAME	CUST_CITY							WORKING_AREA		CUST_COUNTRY	GRADE	OPENING_AMT	RECEIVE_AMT	PAYMENT_AMT	OUTSTANDING_AMT	PHONE_NO		AGENT_CODE	avg_rcv_amt
C00013		Holmes		London                             	London				UK				2		6000		5000		7000		4000			BBBBBBB			A003  		6400
C00001		Micheal		New York                           	New York			USA				2		3000		5000		2000		6000			CCCCCCC			A008  		6500
C00020		Albert		New York                           	New York			USA				3		5000		7000		6000		6000			BBBBSBB			A008  		6500
C00025		Ravindran	Bangalore                          	Bangalore			India			2		5000		7000		4000		8000			AVAVAVA			A011  		9100
C00024		Cook		London                             	London				UK				2		4000		9000		7000		6000			FSDDSDF			A006  		6400
C00015		Stuart		London                             	London				UK				1		6000		8000		3000		11000			GFSGERS			A003  		6400
C00002		Bolt		New York                           	New York			USA				3		5000		7000		9000		3000			DDNRDRH			A008  		6500
C00018		Fleming		Brisban                            	Brisban				Australia		2		7000		7000		9000		5000			NHBGVFC			A005  		7333.33
C00021		Jacks		Brisban                            	Brisban				Australia		1		7000		7000		7000		7000			WERTGDF			A005  		7333.33
C00019		Yearannaidu	Chennai                            	Chennai				India			1		8000		7000		7000		8000			ZZZZBFV			A010  		9100
C00005		Sasikant	Mumbai                             	Mumbai				India			1		7000		11000		7000		11000			147-25896312	A002  		9100
C00007		Ramanathan	Chennai                            	Chennai				India			1		7000		11000		9000		9000			GHRDWSD			A010  		9100
C00022		Avinash		Mumbai                             	Mumbai				India			2		7000		11000		9000		9000			113-12345678	A002  		9100
C00004		Winston		Brisban                            	Brisban				Australia		1		5000		8000		7000		6000			AAAAAAA			A005  		7333.33
C00023		Karl		London                             	London				UK				0		4000		6000		7000		3000			AAAABAA			A006  		6400
C00006		Shilton		Torento                            	Torento				Canada			1		10000		7000		6000		11000			DDDDDDD			A004  		7000
C00010		Charles		Hampshair                          	Hampshair			UK				3		6000		4000		5000		5000			MMMMMMM			A009  		6400
C00017		Srinivas	Bangalore                          	Bangalore			India			2		8000		4000		3000		9000			AAAAAAB			A007  		9100
C00012		Steven		San Jose                           	San Jose			USA				1		5000		7000		9000		3000			KRFYGJK			A012  		6500
C00008		Karolina	Torento                            	Torento				Canada			1		7000		7000		9000		5000			HJKORED			A004  		7000
C00003		Martin		Torento                            	Torento				Canada			2		8000		7000		7000		8000			MJYURFD			A004  		7000
C00009		Ramesh		Mumbai                             	Mumbai				India			3		8000		7000		3000		12000			Phone No		A002  		9100
C00014		Rangarappa	Bangalore                          	Bangalore			India			2		8000		11000		7000		12000			AAAATGF			A001  		9100
C00016		Venkatpati	Bangalore                          	Bangalore			India			2		8000		11000		7000		12000			JRTVFDD			A007  		9100
C00011		Sundariya	Chennai                            	Chennai				India			3		7000		11000		7000		11000			PPHGRTS			A010  		9100
*/
/* Q2: Write a sql query to create and call a UDF named avg_amt to return the average outstanding amount of the customers which are managed by a given agent. 
Also, call the UDF with the agent name ‘Mukesh’.
*/
CREATE FUNCTION avg_amt(agent_name VARCHAR(40))
RETURNS DECIMAL(12,2)
BEGIN
    DECLARE avg_outstanding_amt DECIMAL(12,2)
    SELECT AVG(OUTSTANDING_AMT) INTO avg_outstanding_amt
    FROM customer
    WHERE AGENT_CODE = (SELECT AGENT_CODE FROM agents WHERE AGENT_NAME = agent_name)
    RETURN avg_outstanding_amt
END;

CREATE PROCEDURE cust_detail(IN grade_value DECIMAL(10,0))
BEGIN
    SELECT *
    FROM customer
    WHERE GRADE = grade_value;
END //

DELIMITER ;
USE interview;
DELIMITER //
CREATE FUNCTION avg_amt(agent_name VARCHAR(40))
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_outstanding DECIMAL(12,2);
    
    SELECT AVG(c.OUTSTANDING_AMT) INTO avg_outstanding
    FROM customer c
    INNER JOIN agents a ON c.AGENT_CODE = a.AGENT_CODE
    WHERE a.AGENT_NAME = agent_name
    GROUP BY a.AGENT_CODE;
    
    IF avg_outstanding IS NULL THEN
        SET avg_outstanding = 0.00;
    END IF;
    
    RETURN avg_outstanding;
END //
DELIMITER ;
SET @@global.log_bin_trust_function_creators = 1;
SELECT avg_amt('Mukesh');
DROP FUNCTION IF EXISTS avg_amt;
select * from customer
select * from agents;