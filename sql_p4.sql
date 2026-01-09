-- Active: 1764344437790@@127.0.0.1@3306@walmart_db
use walmart_db

--Business problem

-- 01.Find the differnt payment method and number of transation and quantity sold

select payment_method,
      count(*)as num_payment,
      sum(quantity) as num_of_qnt
     
    from walmart
    GROUP BY 1

-- 02.identyfty the highest rated category in each branch,display the branch and catagery.

select branch,category FROM 
(
  SELECT branch,
         category,
         AVG(rating) AS avg_rating,
         RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
  FROM walmart
  GROUP BY 1, 2
) 
WHERE rnk = 1;

-- 03.Identify the busy day for each branch based on the number of transaction.

select branch,day_name,num_of_transaction from 
(SELECT branch,
       DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
       count(*) as num_of_transaction,
       rank() OVER(PARTITION BY Branch ORDER  BY count(*)desc)as rnk
FROM walmart
group by 1,2)as t
where rnk=1

-- 04.Calculate the total quantity of items sold in each payment method.
--list payment method dnad total_quantity

select payment_method,
    
      sum(quantity) as num_of_qnt
     
    from walmart
    GROUP BY 1


-- 05.Determine the avg,maximum,minimum rating of product for each city.
--list the city,avg_rating,min_rating,max_rating product

select city,category,
    round(avg(rating),3) avg_rating,
    min(rating) min_rating,
    max(rating) max_rating
 from walmart
GROUP BY 1,2



-- 06.Calculate the total profit for each category 
--by considering total_profit as (unit_price * quantity * profit_margin).
--List category and total_profit, ordered from highest to lowest profit.

select category,
         round(sum(total_price),3)as revenue,
        round(sum(total_price*profit_margin),3)as profit
        from walmart
        GROUP BY 1
        order BY 2 desc


-- 07Determine the most common payment method for each Branch. 
--Display Branch and the preferred_payment_method
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_payment,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)

SELECT *
FROM cte 
where rnk=1


--08 Categorize sales into 3 group MORNING, AFTERNOON, EVENING Find out each of the shift and number of invoices

select branch,
case when (hour(time(time )))<12 then 'Morning'
     when(hour(time(time ))) BETWEEN 12 and 17 then 'Afternoon'
else 'Evening' 
end  as day_time,
count(*)

from walmart
group BY 1,2
order by 1,3 desc

--09 Identify 5 branch with highest decrese ratio in
--revevenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
     round(((ls.revenue-cs.revenue)/ls.revenue)*100,2) as rev_dec_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cs
ON ls.branch = cs.branch
where ls.revenue>cs.revenue


