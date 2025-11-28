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

-- ===================================
-- 3) Maintaining CarCondition data when adding/removing a Car
-- ===================================
CREATE OR REPLACE FUNCTION maintain_car_condition() RETURNS TRIGGER AS $$ BEGIN IF (TG_OP = 'INSERT') THEN
INSERT INTO CarCondition (
        car_id,
        mileage,
        mechanical_condition,
        body_condition,
        interior_condition,
        inspection_date,
        notes
    )
VALUES (
        NEW.car_id,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    );

RETURN NEW;

ELSIF (TG_OP = 'DELETE') THEN
DELETE FROM CarCondition
WHERE car_id = OLD.car_id;

RETURN OLD;

END IF;

RETURN NULL;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maintain_car_condition
AFTER
INSERT
    OR DELETE ON Car FOR EACH ROW EXECUTE FUNCTION maintain_car_condition();

-- ===================================
-- 4) Prohibition on selling a car if its status is sold
-- ===================================
CREATE OR REPLACE FUNCTION prevent_sale_of_sold_car() RETURNS TRIGGER AS $$
DECLARE current_status_name TEXT;

BEGIN
SELECT st.name INTO current_status_name
FROM Car
    JOIN StatusType st ON Car.status_id = st.status_id
WHERE Car.car_id = NEW.car_id;

IF current_status_name = 'Sold' THEN RAISE EXCEPTION 'Cannot sell car %: it is already sold',
NEW.car_id;

END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_sale_of_sold_car BEFORE
INSERT ON Sale FOR EACH ROW EXECUTE FUNCTION prevent_sale_of_sold_car();