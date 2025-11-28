-- ===================================
-- 1) Available cars with model details
-- ===================================
CREATE OR REPLACE VIEW AvailableCars AS
SELECT Car.car_id,
    Model.brand,
    Model.model_name,
    Car.year,
    CarCondition.mileage,
    Car.color,
    Car.price,
    BodyType.name AS body_type,
    EngineType.name AS engine_type_name
FROM Car
    JOIN Model USING (model_id)
    JOIN BodyType ON Model.body_type_id = BodyType.body_type_id
    JOIN EngineType ON Model.engine_type_id = EngineType.engine_type_id
    JOIN StatusType ON Car.status_id = StatusType.status_id
    LEFT JOIN CarCondition ON CarCondition.car_id = Car.car_id
WHERE StatusType.name = 'Available';

SELECT *
FROM AvailableCars;

-- ===================================
-- 2) Full sales history with names
-- ===================================
CREATE OR REPLACE VIEW SalesReport AS
SELECT Sale.sale_id AS sale_id,
    Sale.sale_date AS sale_date,
    Sale.sale_price AS sale_amount,
    Model.brand || ' ' || Model.model_name AS automobile,
    CASE
        WHEN Client.client_type_id = 1 THEN Client.first_name || ' ' || Client.last_name
        ELSE Client.company_name
    END AS customer,
    Employee.first_name || ' ' || Employee.last_name AS salesperson
FROM Sale
    JOIN Employee ON Sale.employee_id = Employee.employee_id
    JOIN Client ON Sale.client_id = Client.client_id
    JOIN Car ON Sale.car_id = Car.car_id
    JOIN Model ON Car.model_id = Model.model_id;

SELECT *
FROM SalesReport;

-- ===================================
-- 3) Employee statistics with name
-- ===================================
CREATE OR REPLACE VIEW EmployeePerformance AS
SELECT Employee.employee_id,
    Employee.first_name,
    Employee.last_name,
    Position.name AS position,
    emp_stat.total_sales_count,
    emp_stat.total_sales_amount,
    emp_stat.last_sale_date
FROM Employee
    JOIN Position ON Employee.position_id = Position.position_id
    JOIN EmployeeStatistic emp_stat ON Employee.employee_id = emp_stat.employee_id;

SELECT *
FROM EmployeePerformance;