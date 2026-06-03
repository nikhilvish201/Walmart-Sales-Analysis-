select * from walmart_sales
--

select count(*) from walmart_sales

SELECT
      payment_method,
	  count(*)
from walmart_sales
group by payment_method

Select 
    count(distinct branch)
from walmart_sales

SELECT MIN(quantity) from walmart_sales

--Business problems
--1) find the different payments methods, the number of transaction and number of quantity sold.
SELECT 
      payment_method,
      COUNT(*) AS total_transaction,
      SUM(quantity) AS total_quantity_sold
FROM walmart_sales
GROUP BY payment_method
ORDER BY total_transaction DESC;

--2)Identify the highest-rated category in each branch, displaying the branch, category and avg rating.
SELECT *
FROM
( 
    SELECT
          branch,
          category,
          AVG(rating) AS avg_rating,
          RANK() OVER(
              PARTITION BY branch
              ORDER BY AVG(rating) DESC
          ) AS rank
    FROM walmart_sales
    GROUP BY branch, category
) t
WHERE rank = 1;

--3)Identify the busiest day for each branch based on number of transaction.
SELECT *
FROM (
    SELECT
        "Branch",
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS no_transaction,
        RANK() OVER (
            PARTITION BY "Branch"
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM walmart_sales
    GROUP BY 1, 2
) t
WHERE rnk = 1;

--4)Calculate the total quantity of items sold per payment method. list the payment_method and total_quantity
select 
      payment_method,
	  sum(quantity) as no_quantity_sold 
from walmart_sales
group by payment_method

--5)Determine the average, minimum and maximum rating of products for each city. list the city, average_rating, min_rating,and max_rating\
SELECT 
    walmart_sales."City", 
	walmart_sales.category,
    AVG(rating) AS average_rating,
    MIN(rating) AS minimum_rating,
    MAX(rating) AS maximum_rating
FROM walmart_sales
GROUP BY 1,2;

--6) calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). list category and total_profit, oredred from highest to lowest profit 
select 
      category,
	  sum("Total") as total_revenue,
	  sum("Total" * profit_margin) as total_profit
from walmart_sales
group by 1
order by total_profit desc

--7)determine the most common payment method for each branch, display the brach and preferred_payment_method.
with cte
as
(select 
     "Branch",
	 payment_method,
	 count(*) as total_transaction,
	 RANK() OVER(PARTITION BY walmart_sales."Branch" order by count(*) desc) as rank
from walmart_sales
group by 1,2
)
select *
from cte
where rank = 1

--8)Categorize sales into 3 groups MORNING, AFTERNOON, EVENING , find oout each of the shifts and numbers of invoices
SELECT
    walmart_sales."Branch",
    CASE
        WHEN time < '12:00:00' THEN 'MORNING'
        WHEN time >= '12:00:00' AND time < '17:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS shift,
    COUNT(*) AS no_of_invoices
FROM walmart_sales
GROUP BY 1,2
ORDER BY 1,3 DESC;

--9)Find the top-selling product category in each branch based on total revenue.
WITH category_sales AS (
    SELECT
        "Branch",
        category,
        SUM("Total") AS revenue
    FROM walmart_sales
    GROUP BY 1,2
),

ranked_categories AS (
    SELECT
        "Branch",
        category,
        revenue,
        RANK() OVER(
            PARTITION BY "Branch"
            ORDER BY revenue DESC
        ) AS rnk
    FROM category_sales
)

SELECT
    "Branch",
    category,
    revenue
FROM ranked_categories
WHERE rnk = 1;

--10)Identify the 5 branch with highest decrese ratio in revenue compare to last year(current year 2023 and last year 2022)
--rdr = last_rev - cr_rev/ls_rev*100
select *,
EXTRACT(YEAR from to_date(date,'DD/MM/YY')) as formated_date
from walmart_sales

--2022 sales 
with revenue_2022
as
 (select 
    walmart_sales."Branch",
	sum(walmart_sales."Total") as revenue 
 from walmart_sales
 where EXTRACT(YEAR from to_date(date,'DD/MM/YY')) = 2022
 group by 1
 ),

revenue_2023
as
(
select 
    walmart_sales."Branch",
	sum(walmart_sales."Total") as revenue 
 from walmart_sales
 where EXTRACT(YEAR from to_date(date,'DD/MM/YY')) = 2023
 group by 1
 )
 select 
 ls."Branch",
 ls.revenue as last_year_revenue,
 cs.revenue as cr_year_revenue
 from revenue_2022 as ls
 join
 revenue_2023 as cs
 ON ls."Branch" = cs."Branch"
 where ls.revenue > cs.revenue