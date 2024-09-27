--SQL interview questions

/*
1. Write a SQL query to find employees whose salary is greater than the average salary of employees in their respective location.

Table Name: Employee 
Column Names: EmpID (Employee ID), Emp_name (Employee Name), Manager_id (Manager ID), Salary (Employee Salary), Location (Employee Location)
*/

WITH SUB AS(
	SELECT 
		EmpID, Emp_name, Salary, Location, AVG(Salary) OVER(PARTITION BY Location) as avg_salary

	FROM Employee 
	)

SELECT 
	EmpID, Emp_name

FROM SUB 

WHERE Salary > avg_salary

------------------------------------------------------------------------

/*
2. Write a SQL query to identify riders who have taken at least one trip every day for the last 10 days.

Table Name: Trip 
Column Names: trip_id (Trip ID), driver_id (Driver ID), rider_id (Rider ID), trip_start_timestamp (Trip Start Timestamp)
*/

WITH SUB AS(
	SELECT 
		rider_id, trip_start_timestamp, RANK() OVER(PARTITION BY rider_id ORDER BY trip_start_timestamp) as rnk

	FROM Trip 
	)

SELECT 
	rider_id 

FROM SUB 

GROUP BY rider_id 

HAVING DATEADD(day, -rnk, trip_start_timestamp) >= 10

------------------------------------------------------------------------

/*
3. Write a SQL query to calculate the percentage of successful payments for each driver. A payment is considered successful if its status is 'Completed'.

Table Name: Rides 
Column Names: ride_id (Ride ID), driver_id (Driver ID), fare_amount (Fare Amount), driver_rating (Driver Rating), start_time (Start Time) 

Table Name: Payments 
Column Names: payment_id (Payment ID), ride_id (Ride ID), payment_status (Payment Status)
*/

SELECT
	r.driver_id, COUNT(CASE WHEN p.payment_status = 'Completed' THEN 1 ELSE NULL END) / COUNT(p.payment_status) * 100.0 AS pct

FROM Rides r
JOIN Payments p 
ON r.ride_id = p.ride_id

------------------------------------------------------------------------

/*
4. Write a SQL query to calculate the percentage of menu items sold for each restaurant.

Table Name: Items 
Column Names: item_id (Item ID), rest_id (Restaurant ID)

Table Name: Orders 
Column Names: order_id (Order ID), item_id (Item ID), quantity (Quantity), is_offer (Is Offer), client_id (Client ID), Date_Timestamp (Date Timestamp)
*/

WITH SUB AS(
	SELECT 
		i.item_id AS stock, i.rest_id, o.item_id AS ordered

	FROM Items i
	LEFT JOIN Orders o
	ON i.item_id = o.item_id 
	)

SELECT 
	rest_id, COUNT(ordered) / COUNT(stock) * 100.0 AS pct

FROM SUB 

------------------------------------------------------------------------

/*
5. Write a SQL query to compare the time taken for clients who placed their first order with an offer versus those without an offer to make their next order.

Table Name: Orders 
Column Names: order_id (Order ID), user_id (User ID), is_offer (Is Offer), Date_Timestamp (Date Timestamp)
*/

WITH SUB AS(
	SELECT
		user_id, is_offer, date_timestamp, LEAD(date_timestamp) OVER(PARTITION BY user_id ORDER BY date_timestamp) as nxt_order

	FROM Orders 

	WHERE (user_id, date_timestamp) IN (
        SELECT user_id, MIN(date_timestamp) 
        FROM Orders 
        GROUP BY user_id
		)
	)

SELECT 
	is_offer, AVG(DATEDIFF(day, date_timestamp, nxt_order))

FROM SUB 

GROUP BY is_offer 

------------------------------------------------------------------------

/*
6. Write a SQL query to find all numbers that appear at least three times consecutively in the log.

Table Name: Logs 
Column Names: Id (ID), Num (Number)
*/

WITH Consecutive AS (
    SELECT
        num,
        ROW_NUMBER() OVER (ORDER BY Id) - 
        ROW_NUMBER() OVER (PARTITION BY num ORDER BY Id) AS grp
    FROM Logs
)

SELECT 
    DISTINCT num as ConsecutiveNums 
FROM Consecutive
GROUP BY num, grp
HAVING COUNT(*) >= 3;

------------------------------------------------------------------------

/*
7. Write a SQL query to find the length of the longest sequence of consecutive numbers in the table.

Table Name: Consecutive 
Column Names: number (Number)
*/

WITH SUB AS(
	SELECT 
		number, ROW_NUMBER() OVER(ORDER BY number) AS rnk

	FROM Consecutive
	),

SUB_2 AS(
	SELECT 
		number - rnk as num

	FROM SUB 
	)

SELECT 
	TOP 1
	COUNT(num) as length

FROM SUB_2 

GROUP BY num 

ORDER BY length DESC

------------------------------------------------------------------------

/*
8. Write a SQL query to calculate the percentage of promo trips, comparing members versus non-members.

Table Name: Pass_Subscriptions 
Column Names: user_id (User ID), pass_id (Pass ID), start_date (Start Date), end_date (End Date), status (Status)

Table Name: Orders 
Column Names: order_id (Order ID), user_id (User ID), is_offer (Is Offer), Date_Timestamp (Date Timestamp)
*/

SELECT
	COUNT(CASE WHEN o.is_offer = 'Yes' AND o.user_id IS NOT NULL THEN 1 ELSE NULL END) / COUNT(CASE WHEN o.user_id IS NOT NULL THEN 1 ELSE NULL END) * 100.0 AS members_pct,
	COUNT(CASE WHEN o.is_offer = 'Yes' AND o.user_id IS NULL THEN 1 ELSE NULL END) / COUNT(CASE WHEN o.user_id IS NULL THEN 1 ELSE NULL END) * 100.0 AS non_members_pct

FROM Orders o
LEFT JOIN Pass_Subscription p 
ON o.user_id = p.user_id

------------------------------------------------------------------------