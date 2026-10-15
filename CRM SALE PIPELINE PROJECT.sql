-- DATA PROFILING 
USE MAVEN_crm;
show tables;

DESCRIBE Sales_Pipeline; 
DESCRIBE Products;
DESCRIBE Sales_teams;
DESCRIBE accounts;

SELECT * FROM
			Sales_Pipeline;

SELECT * FROM
			Sales_teams;
            
SELECT 
	  count(*) AS Total_Opportunities
      FROM Sales_Pipeline;
      
SELECT 
	Deal_stage, 
    count(*) AS Opportunities
    FROM Sales_Pipeline
    GROUP BY Deal_stage
    ORDER BY Opportunities DESC;
    
SELECT*
	   FROM sales_pipeline
       order by close_value desc
       limit 10;


-- DATA QUALITY        
SELECT 
	count(*) AS Missing_accounts
    FROM Sales_Pipeline
	WHERE account IS NULL OR account = '';
    
SELECT 
	count(*) AS Missing_Close_Date
    FROM Sales_Pipeline
	WHERE Close_Date IS NULL OR Close_Date = '';
    
  SELECT 
	count(*) AS Missing_Close_Value
    FROM Sales_Pipeline
	WHERE Close_Value IS NULL OR Close_Value = '';
 
 SELECT
	  Opportunity_ID,
      count(*) AS Duplicate_count
FROM Sales_pipeline
group by Opportunity_ID
having count(*)>1;
 
-- DATA CLEANING
CREATE TABLE Sales_Pipeline_clean as
SELECT
	  TRIM(Opportunity_id) as opportunity_id,
      TRIM(sales_agent) as Sales_agent,
      TRIM(Product) as Product,
      NULLIF(TRIM(ACCOUNT), '')as Account,
      TRIM(Deal_stage) as deal_stage,
      str_to_date(NULLIF(TRIM(engage_date), ''), '%Y-%m-%d') AS engage_date,
      str_to_date(NULLIF(TRIM(close_date), ''), '%Y-%m-%d') AS close_date,
      CAST(NULLIF(TRIM(CLOSE_VALUE), '') AS DECIMAL(12,2)) AS CLOSE_VALUE
      FROM Sales_Pipeline;
      
DESCRIBE SALES_PIPELINE_CLEAN;

-- Overall Performance
SELECT
	 Deal_stage,
     count(*) AS Opportunity,
     sum(Close_value) AS Total_Revenue
FROM Sales_Pipeline_Clean
Group by Deal_Stage
Order by Total_Revenue Desc;

SELECT
	 count(CASE WHEN Deal_stage = 'won' Then 1 END) AS WON_DEALS,
     count(CASE WHEN Deal_stage = 'LOST' Then 1 END) AS LOST_DEALS,
     ROUND(
		   count(CASE WHEN Deal_stage = 'won' Then 1 END) * 100.0/
		   count(CASE WHEN Deal_stage IN('won','LOST') Then 1 END),2)AS WIN_RATE
FROM Sales_Pipeline_Clean;

SELECT 
	 Product,
     count(*) As Opportunity,
     count(case when deal_stage = 'won' Then 1 END)AS WON_DEALS,
     sum(case when deal_stage = 'won' Then close_value else 0 END) AS WON_REVENUE
FROM Sales_Pipeline_Clean
group by PRODUCT
order by WON_REVENUE desc;
 
SELECT 
	 Sales_agent,
     count(*) As Opportunity,
     count(case when deal_stage = 'won' Then 1 END)AS WON_DEALS,
     sum(case when deal_stage = 'won' Then close_value else 0 END) AS WON_REVENUE
FROM Sales_Pipeline_Clean
group by Sales_agent
order by WON_REVENUE desc;

SELECT 
	  date_format(Close_date, '%Y-%m') AS MONTH,
      SUM(case when deal_stage = 'won' Then close_value else 0 end) as Won_Revenue
FROM Sales_Pipeline_Clean
WHERE CLOSE_DATE IS NOT NULL
group by date_format(Close_date, '%Y-%m')
order by MONTH;

SELECT
      st.manager,
      st.regional_office,
      count(*) as Opportunity,
      count(case when deal_stage = 'won' Then 1 End) As Won_deals,
      sum(case when deal_stage = 'won' Then close_value else 0 end) as Won_revenue
FROM Sales_Pipeline_Clean as sp
JOIN Sales_teams as st
On sp.sales_agent=st.sales_agent
group by st.manager, st.regional_office
order by Won_revenue DESC;
    
SELECT 
	 Product,
     count(case when deal_stage in('won','lost')then 1 end) As Closed_deals,
     count(case when deal_stage = 'won' Then 1 END)AS WON_DEALS,
     round(
     count(case when deal_stage = 'won'then 1 end) * 100.0/
     Nullif(count(case when deal_stage in ('won','lost') Then 1 end),0),2
     )as win_rate
FROM Sales_Pipeline_Clean
Group by Product
order by win_rate desc;
	
SELECT 
	 Sales_agent,
     count(case when deal_stage in ('won','lost') Then 1 end)as Closed_deals,
     count(case when deal_stage = 'won' Then 1 end)as Won_deals,
round(
    count(case when deal_stage = 'won' Then 1 end) * 100.0/
    Nullif(count(case when deal_stage in ('won','lost') Then 1 end),0),2) as win_rate
FROM Sales_Pipeline_Clean
group by Sales_agent
order by win_rate desc;

SELECT
	year(Close_date) as Year,
    quarter(Close_date) as Quarter,
    sum(case when deal_stage = 'won' Then Close_value else 0 end) as Won_revenue
FROM Sales_Pipeline_clean
Where close_date is not null
group by year(Close_date), quarter(Close_date)
order by Year,Quarter;

SELECT 
	 ACCOUNT,
     COUNT(*)AS OPPORTUNITIES,
     SUM(CASE WHEN DEAL_STAGE = 'WON' THEN CLOSE_VALUE ELSE 0 END)AS WON_REVENUE
     FROM SALES_PIPELINE_CLEAN
     WHERE ACCOUNT IS NOT NULL
     GROUP BY ACCOUNT
     ORDER BY WON_REVENUE DESC
     LIMIT 10;
     
-- ADVANCED SQL
WITH Agent_sales AS(
SELECT Sales_agent,
sum(case when deal_stage = 'won' Then close_value else 0 end) as Won_revenue
FROM SALES_PIPELINE_CLEAN
group by SALES_AGENT
)
SELECT 
	 Sales_agent,
     Won_revenue
FROM Agent_Sales
order by Won_revenue desc;

WITH Agent_sales AS(
SELECT Sales_agent,
sum(case when deal_stage = 'won' Then close_value else 0 end) as Won_revenue
FROM SALES_PIPELINE_CLEAN
group by SALES_AGENT
)
SELECT 
	 Sales_agent,
     Won_revenue,
     rank() OVER(order by WON_REVENUE desc) AS Revenue_rank
     from agent_sales
     order by revenue_rank;
     
SELECT DISTINCT SP.PRODUCT
FROM SALES_PIPELINE_CLEAN AS SP
LEFT JOIN PRODUCTS AS P
ON SP.PRODUCT = P.PRODUCT
WHERE P.PRODUCT IS NULL;

SELECT 
	 (SELECT Count(*)
     FROM Sales_Pipeline) AS RAW_ROWS;
     
SELECT 
	 (SELECT Count(*)
     FROM Sales_Pipeline_Clean) AS CLEAN_ROWS;
     
SELECT 
	 DISTINCT Product
     FROM Sales_Pipeline_Clean
     WHERE Product LIKE '%GTX%';
     
SET SQL_SAFE_UPDATES = 0;
UPDATE 
	  Sales_Pipeline_Clean
      SET Product ='GTX Pro'
      WHERE Product = 'GTXPro';
SET SQL_SAFE_UPDATES = 1;
     




