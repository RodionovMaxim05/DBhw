-- ===================================
-- Automatically update EmployeeStatistics upon sale
-- ===================================
CREATE OR REPLACE FUNCTION update_employee_statistic() RETURNS TRIGGER AS $$ BEGIN
INSERT INTO EmployeeStatistic (
        employee_id,
        total_sales_count,
        total_sales_amount,
        last_sale_date
    )
VALUES (
        NEW.employee_id,
        1,
        NEW.sale_price,
        NEW.sale_date
    ) ON CONFLICT (employee_id) DO
UPDATE
SET total_sales_count = EmployeeStatistic.total_sales_count + 1,
    total_sales_amount = EmployeeStatistic.total_sales_amount + NEW.sale_price,
    last_sale_date = GREATEST(EmployeeStatistic.last_sale_date, NEW.sale_date);

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stat_after_sale
AFTER
INSERT ON Sale FOR EACH ROW EXECUTE FUNCTION update_employee_statistic();

-- ===================================
-- Automatically set the vehicle status to "Sold" upon sale
-- ===================================
CREATE OR REPLACE FUNCTION set_car_status_to_sold() RETURNS TRIGGER AS $$ BEGIN
UPDATE Car
SET status_id = (
        SELECT status_id
        FROM StatusType
        WHERE name = 'Sold'
        LIMIT 1
    )
WHERE car_id = NEW.car_id;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_car_sold_after_sale
AFTER
INSERT ON Sale FOR EACH ROW EXECUTE FUNCTION set_car_status_to_sold();