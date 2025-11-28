-- ===================================
-- 1) Automatically update EmployeeStatistics upon sale
-- ===================================
CREATE OR REPLACE FUNCTION trg_update_stat_after_sale() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN PERFORM update_employee_stat(NEW.employee_id);

RETURN NEW;

END;

$$;

CREATE TRIGGER trg_update_stat_after_sale
AFTER
INSERT ON Sale FOR EACH ROW EXECUTE FUNCTION trg_update_stat_after_sale();

-- ===================================
-- 2) Automatically set the vehicle status to "Sold" upon sale
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