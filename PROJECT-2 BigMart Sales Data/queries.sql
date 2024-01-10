SELECT * FROM bigmart;

SELECT DISTINCT(item_fat_content) FROM bigmart;
SELECT DISTINCT(item_type) FROM bigmart;
SELECT DISTINCT(outlet_size) FROM bigmart;
SELECT DISTINCT(outlet_location_type) FROM bigmart;
SELECT DISTINCT(outlet_type) FROM bigmart;

-- Data Cleaning
-- 1. item_fat_content column
UPDATE bigmart
SET item_fat_content = 
    CASE 
	     WHEN item_fat_content IN ('low fat' , 'LF') THEN 'Low Fat'
	     WHEN item_fat_content IN ('reg') THEN 'Regular'
	     ELSE item_fat_content
	END;

-- Exploratory Analysis

--1. Find the Total Sales for Each Item Type in Each Outlet Type.

SELECT item_type, 
       outlet_type,
	   SUM(item_outlet_sales) AS Total_Sales
FROM bigmart
GROUP BY item_type, outlet_type
ORDER BY Total_Sales DESC;

--2. In each outlet type, find item with the highest sales

WITH item_sales AS (
      SELECT outlet_type,
	         item_type,
	         SUM(item_outlet_sales) AS Total_sales,
             ROW_NUMBER() OVER(PARTITION BY outlet_type ORDER BY SUM(item_outlet_sales) DESC) AS rank_outlet
      FROM bigmart
      GROUP BY outlet_type, item_type)

SELECT *
FROM item_sales
WHERE rank_outlet = 1;

-- snack foods - greocery store and supermarket type 2; fruits and vegetables - supermarket type 1 and supermarket type 3

--3. Find top 3 most selling item

WITH top_selling AS (
    SELECT 
        item_type,
        SUM(item_outlet_sales) AS total_sales,
        ROW_NUMBER() OVER (ORDER BY SUM(item_outlet_sales) DESC) AS item_rank
    FROM bigmart
    GROUP BY item_type
)

SELECT item_type , total_sales
FROM top_selling
WHERE item_rank <= 3;

-- Fruits and vegetables -2820059, snack foods-2732786, household-2055493

--4. what percenatge of item_fat_content is most sold at each outlet_type

WITH top_selling AS (
    SELECT 
        item_fat_content,
        outlet_type,
        SUM(item_outlet_sales) AS total_sales,
        (SUM(item_outlet_sales) * 100.0) / SUM(SUM(item_outlet_sales)) OVER (PARTITION BY outlet_type) AS percentage,
        ROW_NUMBER() OVER (PARTITION BY outlet_type ORDER BY SUM(item_outlet_sales) DESC) AS rank_size
    FROM bigmart
    GROUP BY item_fat_content, outlet_type
)

SELECT 
    item_fat_content, 
    outlet_type, 
    percentage
FROM top_selling
WHERE rank_size = 1;

-- low fat in all outlets with more than 63% in each

--5. which item have the most visiblity and which one the least

WITH visibility AS (
    SELECT 
        item_type,
        item_visibility,
        ROW_NUMBER() OVER (ORDER BY item_visibility DESC) AS high_visibility,
	    ROW_NUMBER() OVER (ORDER BY item_visibility) AS low_visibility
    FROM bigmart
    GROUP BY item_type,item_visibility
)

SELECT 
    item_type , item_visibility
FROM visibility
WHERE high_visibility = 1 OR low_visibility = 1
GROUP BY item_type, item_visibility;
-- canned with highest visibility and frozen foods with least

--6. find average item_visibility for item_fat_content and the percentage of it.

SELECT item_fat_content,
       AVG(item_visibility) AS average_visibility,
	   (COUNT(*) * 100.0)/(SELECT COUNT(*) FROM bigmart) AS percentage
FROM bigmart
GROUP BY item_fat_content;
--regular-0.069,35.36% ; Low fat - 0.064, 64.73%

--7. Find one Item with Sales Higher Than the Average Sales for Their Outlet Type.

WITH RankedItems AS (
    SELECT 
        item_type,
        outlet_type,
        item_outlet_sales,
        ROW_NUMBER() OVER (PARTITION BY outlet_type ORDER BY item_outlet_sales DESC) AS rank
    FROM (
        SELECT 
            item_type,
            outlet_type,
            item_outlet_sales,
            AVG(item_outlet_sales) OVER (PARTITION BY outlet_type) AS avg_sales_by_outlet
        FROM bigmart
    ) AS subquery
    WHERE item_outlet_sales > avg_sales_by_outlet
)

SELECT 
    item_type,
    outlet_type,
    item_outlet_sales
FROM RankedItems
WHERE rank = 1
ORDER BY item_outlet_sales DESC;
--household-supermarket type3 and grocery store ; dairy-supermarkettype1; canned-supermarkettype2

--8. Calculate Cumulative Sales for Each Outlet location Type Over Time.

WITH sales AS (
    SELECT 
        Outlet_Location_Type,
        Outlet_Establishment_Year,
        SUM(Item_Outlet_Sales) OVER (PARTITION BY Outlet_Location_Type ORDER BY Outlet_Establishment_Year) AS Cumulative_Sales
    FROM bigmart
)

SELECT *
FROM sales
GROUP BY outlet_location_type, outlet_establishment_year, cumulative_sales
ORDER BY outlet_establishment_year;

--9. Investigate the relationship between Item_MRP and Item_Outlet_Sales.

SELECT 
    CORR(Item_MRP, Item_Outlet_Sales) AS correlation
FROM bigmart;
--positive correlation

--10. Identify which item had highest total sales in each year.

WITH RankedItems AS (
    SELECT 
        outlet_establishment_year,
        item_type,
        item_outlet_sales,
        ROW_NUMBER() OVER (PARTITION BY outlet_establishment_year ORDER BY item_outlet_sales DESC) AS rank
    FROM bigmart
)

SELECT 
    outlet_establishment_year,
    item_type,
    item_outlet_sales
FROM RankedItems
WHERE rank = 1
ORDER BY outlet_establishment_year, item_outlet_sales DESC;
