-- ===================================
-- 1) Cars that were never sold
-- ===================================
SELECT Car.car_id,
    Model.brand || ' ' || Model.model_name AS model,
    Car.year,
    Car.price,
    CarCondition.inspection_date
FROM Car
    JOIN Model ON Car.model_id = Model.model_id
    LEFT JOIN Sale ON Car.car_id = Sale.car_id
    JOIN CarCondition ON CarCondition.car_id = Car.car_id
WHERE Sale.sale_id IS NULL
ORDER BY Car.year DESC;

-- ===================================
-- 2) Average price by brand
-- ===================================
SELECT Model.brand,
    ROUND(AVG(Car.price), 2) AS average_price
FROM Car
    JOIN Model ON Car.model_id = Model.model_id
GROUP BY Model.brand
ORDER BY average_price DESC;

-- ===================================
-- 3) Average mileage by body type for cars
-- ===================================
SELECT bt.name AS body_type,
    COUNT(*) AS cars_count,
    ROUND(AVG(cc.mileage), 0) AS avg_mileage
FROM Car Car
    JOIN Model ON Car.model_id = Model.model_id
    JOIN BodyType bt ON Model.body_type_id = bt.body_type_id
    JOIN CarCondition cc ON Car.car_id = cc.car_id
WHERE cc.mileage > 0
GROUP BY bt.name
HAVING COUNT(*) >= 1
ORDER BY avg_mileage DESC;

-- ===================================
-- 4) Monthly sales report for the past year
-- ===================================
SELECT EXTRACT(
        YEAR
        FROM sale_date
    ) AS year,
    EXTRACT(
        MONTH
        FROM sale_date
    ) AS MONTH,
    TO_CHAR(sale_date, 'Month') AS month_name,
    COUNT(*) AS sales_count,
    SUM(sale_amount) AS total_revenue
FROM v_sales_report
WHERE sale_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY year,
    MONTH,
    month_name
ORDER BY year,
    MONTH;

-- ===================================
-- 5) Customers who bought Volkswagen
-- ===================================
SELECT Client.client_id,
    CASE
        WHEN Client.client_type_id = 1 THEN Client.first_name || ' ' || Client.last_name
        ELSE Client.company_name
    END AS customer,
    Client.email,
    Client.address,
    Model.brand || ' ' || Model.model_name AS automobile
FROM Client
    JOIN Sale ON Client.client_id = Sale.client_id
    JOIN Car ON Sale.car_id = Car.car_id
    JOIN Model ON Model.model_id = Sale.car_id
WHERE EXISTS (
        SELECT *
        FROM Sale
            JOIN Car ON Sale.car_id = Car.car_id
            JOIN Model ON Car.model_id = Model.model_id
        WHERE Sale.client_id = Client.client_id
            AND Model.brand = 'Volkswagen'
    );

-- ===================================
-- 6) Available cars with mileage over 50,000 km
-- ===================================
SELECT car_id,
    brand,
    model_name,
    year,
    mileage,
    color,
    price
FROM v_available_cars
WHERE mileage > 50000
ORDER BY mileage DESC;

-- ===================================
-- 7) Brands with the highest sales in the last 3 months
-- ===================================
SELECT SPLIT_PART(automobile, ' ', 1) AS brand,
    COUNT(*) AS sales_count,
    SUM(sale_amount) AS total_revenue
FROM v_sales_report
WHERE sale_date >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY SPLIT_PART(automobile, ' ', 1)
HAVING COUNT(*) >= 1
ORDER BY sales_count DESC,
    total_revenue DESC;

-- ===================================
-- 8) Employees with no sales in the last 2 months
-- ===================================
SELECT e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    p.name AS position
FROM Employee e
    JOIN Position p ON e.position_id = p.position_id
WHERE NOT EXISTS (
        SELECT 1
        FROM Sale s
        WHERE s.employee_id = e.employee_id
            AND s.sale_date >= CURRENT_DATE - INTERVAL '2 months'
    )
ORDER BY e.hire_date DESC;

-- ===================================
-- 9) All contact emails (clients + employees)
-- ===================================
SELECT email
FROM Client
WHERE email IS NOT NULL
UNION
SELECT email
FROM Employee
WHERE email IS NOT NULL;

-- ===================================
-- 10) Top 3 most expensive sales
-- ===================================
SELECT *
FROM Sale
WHERE sale_price IN (
        SELECT DISTINCT sale_price
        FROM Sale
        ORDER BY sale_price DESC
        LIMIT 3
    )
ORDER BY sale_price DESC;

-- ===================================
-- 11) The most profitable employees for the current month
-- ===================================
SELECT es.employee_id,
    Employee.first_name || ' ' || Employee.last_name AS salesperson,
    es.total_sales_amount,
    (
        SELECT COUNT(*)
        FROM Sale
        WHERE employee_id = es.employee_id
            AND EXTRACT(
                MONTH
                FROM sale_date
            ) = EXTRACT(
                MONTH
                FROM CURRENT_DATE
            )
            AND EXTRACT(
                YEAR
                FROM sale_date
            ) = EXTRACT(
                YEAR
                FROM CURRENT_DATE
            )
    ) AS sales
FROM Employee
    JOIN EmployeeStatistic es ON Employee.employee_id = es.employee_id
WHERE es.total_sales_amount > 0
ORDER BY sales DESC;

-- ===================================
-- 12) Cars priced above the average for their brand
-- ===================================
SELECT ac.car_id,
    ac.brand,
    ac.model_name,
    ac.price,
    (
        SELECT ROUND(AVG(price), 2)
        FROM Car c2
            JOIN Model m2 ON c2.model_id = m2.model_id
        WHERE m2.brand = ac.brand
            AND c2.status_id = (
                SELECT status_id
                FROM StatusType
                WHERE name = 'Available'
            )
    ) AS avg_brand_price
FROM v_available_cars ac
WHERE ac.price > (
        SELECT AVG(c2.price)
        FROM Car c2
            JOIN Model m2 ON c2.model_id = m2.model_id
        WHERE m2.brand = ac.brand
            AND c2.status_id = (
                SELECT status_id
                FROM StatusType
                WHERE name = 'Available'
            )
    );

-- ===================================
-- 13) Average price difference between original and sold cars by brand
-- ===================================
SELECT Model.brand,
    ROUND(AVG(Sale.sale_price - Car.price), 2) AS avg_price_difference,
    COUNT(*) AS sales_count,
    ROUND(AVG(Car.price), 2) AS avg_original_price,
    ROUND(AVG(Sale.sale_price), 2) AS avg_sold_price
FROM Sale
    JOIN Car ON Sale.car_id = Car.car_id
    JOIN Model ON Car.model_id = Model.model_id
GROUP BY Model.brand
ORDER BY avg_price_difference DESC;