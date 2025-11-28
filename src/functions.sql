-- ===================================
-- 1) A universal function for updating statistics for one employee
-- ===================================
CREATE OR REPLACE FUNCTION update_employee_stat(p_employee_id INT) RETURNS VOID LANGUAGE plpgsql AS $$ BEGIN
UPDATE EmployeeStatistic emp_stat
SET total_sales_count = sub.cnt,
    total_sales_amount = sub.amt,
    last_sale_date = sub.last_dt
FROM (
        SELECT COUNT(Sale.sale_id) AS cnt,
            COALESCE(SUM(Sale.sale_price), 0) AS amt,
            MAX(Sale.sale_date) AS last_dt
        FROM Sale
        WHERE Sale.employee_id = p_employee_id
    ) sub
WHERE emp_stat.employee_id = p_employee_id;

INSERT INTO EmployeeStatistic(
        employee_id,
        total_sales_count,
        total_sales_amount,
        last_sale_date
    )
SELECT p_employee_id AS employee_id,
    sub.cnt,
    sub.amt,
    sub.last_dt
FROM (
        SELECT COUNT(sale_id) AS cnt,
            COALESCE(SUM(sale_price), 0) AS amt,
            MAX(sale_date) AS last_dt
        FROM Sale
        WHERE employee_id = p_employee_id
    ) sub ON CONFLICT (employee_id) DO
UPDATE
SET total_sales_count = EXCLUDED.total_sales_count,
    total_sales_amount = EXCLUDED.total_sales_amount,
    last_sale_date = EXCLUDED.last_sale_date;

END;

$$;

-- CALL update_employee_stat(1);
--
-- ===================================
-- 2) Car warehouse valuation in JSON format
-- ===================================
CREATE OR REPLACE FUNCTION get_inventory_json() RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE report_data JSONB;

tag_summary JSONB;

tag_financials JSONB;

tag_brands JSONB;

tag_status_breakdown JSONB;

tag_analytics JSONB;

tag_total_cars INT;

tag_sold_cars INT;

BEGIN
SELECT jsonb_build_object(
        'total_cars',
        COUNT(*),
        'available_cars',
        COUNT(*) FILTER (
            WHERE st.name = 'Available'
        ),
        'reserved_cars',
        COUNT(*) FILTER (
            WHERE st.name = 'Reserved'
        ),
        'sold_cars',
        COUNT(*) FILTER (
            WHERE st.name = 'Sold'
        )
    ),
    jsonb_build_object(
        'total_inventory_value',
        COALESCE(
            SUM(Car.price) FILTER (
                WHERE st.name = 'Available'
            ),
            0
        ),
        'total_reserved_value',
        COALESCE(
            SUM(Car.price) FILTER (
                WHERE st.name = 'Reserved'
            ),
            0
        ),
        'total_sold_value',
        COALESCE(
            SUM(Car.price) FILTER (
                WHERE st.name = 'Sold'
            ),
            0
        ),
        'avg_available_price',
        COALESCE(
            ROUND(
                AVG(Car.price) FILTER (
                    WHERE st.name = 'Available'
                ),
                2
            ),
            0
        )
    ),
    COUNT(*),
    COUNT(*) FILTER (
        WHERE st.name = 'Sold'
    ) INTO tag_summary,
    tag_financials,
    tag_total_cars,
    tag_sold_cars
FROM Car
    JOIN StatusType st ON Car.status_id = st.status_id;

SELECT jsonb_agg(
        jsonb_build_object(
            'brand',
            brand,
            'car_count',
            car_count,
            'total_value',
            total_value,
            'avg_price',
            avg_price
        )
    ) INTO tag_brands
FROM (
        SELECT Model.brand,
            COUNT(*) AS car_count,
            SUM(Car.price) AS total_value,
            ROUND(AVG(Car.price), 2) AS avg_price
        FROM Car
            JOIN Model ON Car.model_id = Model.model_id
            JOIN StatusType st ON Car.status_id = st.status_id
        WHERE st.name = 'Available'
        GROUP BY Model.brand
    ) AS brand_data;

SELECT jsonb_agg(
        jsonb_build_object(
            'status',
            status_name,
            'count',
            car_count,
            'total_value',
            total_value,
            'min_price',
            min_price,
            'max_price',
            max_price
        )
    ) INTO tag_status_breakdown
FROM (
        SELECT st.name AS status_name,
            COUNT(*) AS car_count,
            COALESCE(SUM(Car.price), 0) AS total_value,
            COALESCE(MIN(Car.price), 0) AS min_price,
            COALESCE(MAX(Car.price), 0) AS max_price
        FROM Car
            JOIN StatusType st ON Car.status_id = st.status_id
        GROUP BY st.name
        ORDER BY st.name
    ) AS status_data;

tag_analytics := jsonb_build_object(
    'turnover_rate_percent',
    CASE
        WHEN tag_total_cars > 0 THEN ROUND(
            (tag_sold_cars::NUMERIC / tag_total_cars) * 100,
            2
        )
        ELSE 0
    END
);

report_data := jsonb_build_object(
    'generated_at',
    CURRENT_TIMESTAMP,
    'summary',
    tag_summary,
    'financials',
    tag_financials,
    'brands',
    COALESCE(tag_brands, '[]'::JSONB),
    'status_breakdown',
    COALESCE(tag_status_breakdown, '[]'::JSONB),
    'analytics',
    tag_analytics
);

RETURN report_data;

END;

$$;

-- SELECT get_inventory_json();