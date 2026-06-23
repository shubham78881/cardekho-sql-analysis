-- ============================================================
--   CarDekho Sales Data Analysis -- Full SQL Project
--   Author  : Subham Sarin
--   Dataset : CarDekho (Kaggle)
--   Tool    : MySQL 8.0+
--   Note    : Data already imported in 'cardekho_dataset' table
-- ============================================================
-- Standard Kaggle CarDekho Columns Used:
-- car_name, brand, model, vehicle_age, km_driven,
-- seller_type, fuel_type, transmission,
-- mileage, engine, max_power, seats, selling_price
-- ============================================================

USE cardekho_db;

-- ============================================================
-- SECTION 1 : BASIC DATA EXPLORATION
-- ============================================================

-- Q1. View first 10 rows of dataset
SELECT * FROM cardekho_dataset LIMIT 10;

-- Q2. Total number of cars in dataset
SELECT COUNT(*) AS total_cars FROM cardekho_dataset;

-- Q3. All unique brands
SELECT DISTINCT brand FROM cardekho_dataset ORDER BY brand;

-- Q4. All unique fuel types
SELECT DISTINCT fuel_type FROM cardekho_dataset;

-- Q5. All unique transmission types
SELECT DISTINCT transmission FROM cardekho_dataset;

-- Q6. All unique seller types
SELECT DISTINCT seller_type FROM cardekho_dataset;

-- Q7. Total number of unique brands
SELECT COUNT(DISTINCT brand) AS total_brands FROM cardekho_dataset;

-- ============================================================
-- SECTION 2 : PRICE ANALYSIS
-- ============================================================

-- Q8. Most expensive car
SELECT car_name, brand, selling_price
FROM cardekho_dataset
ORDER BY selling_price DESC
LIMIT 1;

-- Q9. Least expensive car
SELECT car_name, brand, selling_price
FROM cardekho_dataset
ORDER BY selling_price ASC
LIMIT 1;

-- Q10. Average selling price of all cars
SELECT ROUND(AVG(selling_price), 2) AS avg_selling_price
FROM cardekho_dataset;

-- Q11. Most expensive car of each brand
SELECT brand, MAX(selling_price) AS max_price
FROM cardekho_dataset
GROUP BY brand
ORDER BY max_price DESC;

-- Q12. Cheapest car of each brand
SELECT brand, MIN(selling_price) AS min_price
FROM cardekho_dataset
GROUP BY brand
ORDER BY min_price ASC;

-- Q13. Average selling price per fuel type
SELECT fuel_type,
       COUNT(*) AS total_cars,
       ROUND(AVG(selling_price), 2) AS avg_price
FROM cardekho_dataset
GROUP BY fuel_type
ORDER BY avg_price DESC;

-- Q14. Average selling price by transmission type
SELECT transmission,
       COUNT(*) AS total_cars,
       ROUND(AVG(selling_price), 2) AS avg_price
FROM cardekho_dataset
GROUP BY transmission
ORDER BY avg_price DESC;

-- Q15. Price range (max - min) per brand
SELECT brand,
       MAX(selling_price) AS max_price,
       MIN(selling_price) AS min_price,
       (MAX(selling_price) - MIN(selling_price)) AS price_range
FROM cardekho_dataset
GROUP BY brand
ORDER BY price_range DESC;

-- ============================================================
-- SECTION 3 : SALES & DEMAND ANALYSIS
-- ============================================================

-- Q16. Which fuel type has most cars listed
SELECT fuel_type, COUNT(*) AS total_cars
FROM cardekho_dataset
GROUP BY fuel_type
ORDER BY total_cars DESC;

-- Q17. Which brand has most cars listed
SELECT brand, COUNT(*) AS total_listings
FROM cardekho_dataset
GROUP BY brand
ORDER BY total_listings DESC;

-- Q18. Which transmission type is more popular
SELECT transmission, COUNT(*) AS total
FROM cardekho_dataset
GROUP BY transmission
ORDER BY total DESC;

-- Q19. Which seller type lists most cars
SELECT seller_type, COUNT(*) AS total
FROM cardekho_dataset
GROUP BY seller_type
ORDER BY total DESC;

-- Q20. Number of cars per seat capacity
SELECT seats, COUNT(*) AS total_cars
FROM cardekho_dataset
GROUP BY seats
ORDER BY total_cars DESC;

-- Q21. Top 10 most listed car models
SELECT model, COUNT(*) AS total
FROM cardekho_dataset
GROUP BY model
ORDER BY total DESC
LIMIT 10;

-- ============================================================
-- SECTION 4 : MILEAGE & ENGINE ANALYSIS
-- ============================================================

-- Q22. Top 5 brands with best average mileage
SELECT brand, ROUND(AVG(mileage), 2) AS avg_mileage
FROM cardekho_dataset
WHERE mileage IS NOT NULL AND mileage > 0
GROUP BY brand
ORDER BY avg_mileage DESC
LIMIT 5;

-- Q23. Fuel type with best average mileage
SELECT fuel_type, ROUND(AVG(mileage), 2) AS avg_mileage
FROM cardekho_dataset
WHERE mileage IS NOT NULL AND mileage > 0
GROUP BY fuel_type
ORDER BY avg_mileage DESC;

-- Q24. Cars with engine capacity greater than 1500cc
SELECT car_name, brand, engine, selling_price
FROM cardekho_dataset
WHERE engine > 1500
ORDER BY engine DESC;

-- Q25. Average engine size per brand
SELECT brand, ROUND(AVG(engine), 0) AS avg_engine_cc
FROM cardekho_dataset
WHERE engine IS NOT NULL
GROUP BY brand
ORDER BY avg_engine_cc DESC;

-- Q26. Average max_power per fuel type
SELECT fuel_type, ROUND(AVG(max_power), 2) AS avg_max_power
FROM cardekho_dataset
WHERE max_power IS NOT NULL
GROUP BY fuel_type
ORDER BY avg_max_power DESC;

-- ============================================================
-- SECTION 5 : KM DRIVEN ANALYSIS
-- ============================================================

-- Q27. Top 10 most driven cars
SELECT car_name, brand, km_driven, selling_price
FROM cardekho_dataset
ORDER BY km_driven DESC
LIMIT 10;

-- Q28. Cars with km_driven below average (well maintained)
SELECT car_name, brand, km_driven, selling_price
FROM cardekho_dataset
WHERE km_driven < (SELECT AVG(km_driven) FROM cardekho_dataset)
ORDER BY km_driven ASC;

-- Q29. Average km driven per brand
SELECT brand, ROUND(AVG(km_driven), 0) AS avg_km
FROM cardekho_dataset
GROUP BY brand
ORDER BY avg_km DESC;

-- Q30. Average km driven by fuel type
SELECT fuel_type, ROUND(AVG(km_driven), 0) AS avg_km
FROM cardekho_dataset
GROUP BY fuel_type
ORDER BY avg_km DESC;

-- ============================================================
-- SECTION 6 : VEHICLE AGE ANALYSIS
-- ============================================================

-- Q31. Average selling price by vehicle age group
SELECT
    CASE
        WHEN vehicle_age <= 2  THEN '0-2 Years (New)'
        WHEN vehicle_age <= 5  THEN '3-5 Years (Mid)'
        WHEN vehicle_age <= 10 THEN '6-10 Years (Old)'
        ELSE '10+ Years (Very Old)'
    END AS age_group,
    COUNT(*)                     AS total_cars,
    ROUND(AVG(selling_price), 2) AS avg_price,
    MAX(selling_price)           AS max_price,
    MIN(selling_price)           AS min_price
FROM cardekho_dataset
GROUP BY age_group
ORDER BY avg_price DESC;

-- Q32. Which vehicle age has most listings
SELECT vehicle_age, COUNT(*) AS total_cars
FROM cardekho_dataset
GROUP BY vehicle_age
ORDER BY total_cars DESC
LIMIT 10;

-- ============================================================
-- SECTION 7 : ADVANCED ANALYSIS (Subqueries, CTEs, Window Functions)
-- ============================================================

-- Q33. Cars priced above their own brand's average (Correlated Subquery)
SELECT car_name, brand, selling_price
FROM cardekho_dataset AS c
WHERE selling_price > (
    SELECT AVG(selling_price)
    FROM cardekho_dataset AS c2
    WHERE c2.brand = c.brand
)
ORDER BY brand, selling_price DESC;

-- Q34. Percentage contribution of each brand to total sales value
SELECT brand,
       SUM(selling_price)  AS total_value,
       ROUND(SUM(selling_price) * 100.0 / (SELECT SUM(selling_price) FROM cardekho_dataset), 2) AS pct_contribution
FROM cardekho_dataset
GROUP BY brand
ORDER BY pct_contribution DESC;

-- Q35. Rank cars by selling price within each brand (Window Function)
SELECT car_name, brand, selling_price,
       RANK() OVER (PARTITION BY brand ORDER BY selling_price DESC) AS price_rank
FROM cardekho_dataset;

-- Q36. Top 3 most expensive cars per brand (CTE + Window Function)
WITH ranked_cars AS (
    SELECT car_name, brand, selling_price,
           RANK() OVER (PARTITION BY brand ORDER BY selling_price DESC) AS rnk
    FROM cardekho_dataset
)
SELECT car_name, brand, selling_price, rnk
FROM ranked_cars
WHERE rnk <= 3
ORDER BY brand, rnk;

-- Q37. Running total of selling price by vehicle age (Window Function)
SELECT car_name, vehicle_age, selling_price,
       SUM(selling_price) OVER (
           ORDER BY vehicle_age
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM cardekho_dataset;

-- Q38. Each car's price vs brand average price (Window Function)
SELECT car_name, brand, selling_price,
       ROUND(AVG(selling_price) OVER (PARTITION BY brand), 2) AS brand_avg_price,
       (selling_price - ROUND(AVG(selling_price) OVER (PARTITION BY brand), 2)) AS diff_from_avg
FROM cardekho_dataset
ORDER BY brand, diff_from_avg DESC;

-- Q39. Cheapest automatic car
SELECT car_name, brand, transmission, selling_price
FROM cardekho_dataset
WHERE LOWER(transmission) = 'automatic'
ORDER BY selling_price ASC
LIMIT 1;

-- Q40. Cheapest petrol car under 50,000 km driven
SELECT car_name, brand, fuel_type, km_driven, selling_price
FROM cardekho_dataset
WHERE LOWER(fuel_type) = 'petrol'
  AND km_driven < 50000
ORDER BY selling_price ASC
LIMIT 5;

-- ============================================================
-- END OF PROJECT
-- ============================================================
