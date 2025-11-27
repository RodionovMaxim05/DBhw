-- ===================================
-- Dictionaries
-- ===================================
SELECT *
FROM ClientType
ORDER BY client_type_id;

SELECT *
FROM BodyType
ORDER BY body_type_id;

SELECT *
FROM EngineType
ORDER BY engine_type_id;

SELECT *
FROM TransmissionType
ORDER BY transmission_id;

SELECT *
FROM Position
ORDER BY position_id;

SELECT *
FROM StatusType
ORDER BY status_id;

-- ===================================
-- Main Tables
-- ===================================
SELECT *
FROM Client
ORDER BY client_id;

SELECT *
FROM Employee
ORDER BY employee_id;

SELECT *
FROM Model
ORDER BY model_id;

SELECT *
FROM Car
ORDER BY car_id;

SELECT *
FROM CarCondition
ORDER BY car_id;

SELECT *
FROM Sale
ORDER BY sale_id;

SELECT *
FROM EmployeeStatistic
ORDER BY employee_id;