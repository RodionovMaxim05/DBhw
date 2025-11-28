-- ===================================
-- Delete Procedures
-- ===================================
DROP PROCEDURE IF EXISTS ReserveCar(INT, INT, INT);

DROP PROCEDURE IF EXISTS RefundSale(INT, OUT INT, OUT INT, OUT INT);

-- ===================================
-- Delete Triggers
-- ===================================
DROP TRIGGER IF EXISTS trg_update_stat_after_sale ON Sale;

DROP TRIGGER IF EXISTS trg_set_car_sold_after_sale ON Sale;

DROP TRIGGER IF EXISTS trg_maintain_car_condition ON Car;

DROP TRIGGER IF EXISTS trg_prevent_sale_of_sold_car ON Sale;

-- ===================================
-- Delete Functions
-- ===================================
DROP FUNCTION IF EXISTS update_employee_stat(INT);

DROP FUNCTION IF EXISTS get_inventory_json();

DROP FUNCTION IF EXISTS set_car_sold();

DROP FUNCTION IF EXISTS maintain_car_condition();

DROP FUNCTION IF EXISTS prevent_sale_of_sold_car();

-- ===================================
-- Delete Views
-- ===================================
DROP VIEW IF EXISTS AvailableCars;

DROP VIEW IF EXISTS SalesReport;

DROP VIEW IF EXISTS EmployeePerformance;

-- ===================================
-- Delete Tables
-- ===================================
DROP TABLE IF EXISTS EmployeeStatistic CASCADE;

DROP TABLE IF EXISTS Sale CASCADE;

DROP TABLE IF EXISTS CarCondition CASCADE;

DROP TABLE IF EXISTS Car CASCADE;

DROP TABLE IF EXISTS Model CASCADE;

DROP TABLE IF EXISTS Client CASCADE;

DROP TABLE IF EXISTS Employee CASCADE;

DROP TABLE IF EXISTS StatusType CASCADE;

DROP TABLE IF EXISTS Position CASCADE;

DROP TABLE IF EXISTS TransmissionType CASCADE;

DROP TABLE IF EXISTS EngineType CASCADE;

DROP TABLE IF EXISTS BodyType CASCADE;

DROP TABLE IF EXISTS ClientType CASCADE;