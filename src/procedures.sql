-- ===================================
-- 1) Car reservation
-- ===================================
CREATE OR REPLACE PROCEDURE reserve_car(car_id_param INT) LANGUAGE plpgsql AS $$
DECLARE reserved_status_id INT;

current_status TEXT;

BEGIN
SELECT StatusType.name INTO current_status
FROM Car
    JOIN StatusType ON Car.status_id = StatusType.status_id
WHERE Car.car_id = car_id_param;

IF current_status = 'Sold' THEN RAISE EXCEPTION 'Cannot reserve sold car';

END IF;

SELECT status_id INTO reserved_status_id
FROM StatusType
WHERE name = 'Reserved'
LIMIT 1;

UPDATE Car
SET status_id = reserved_status_id
WHERE car_id = car_id_param;

END;

$$;

-- CALL reserve_car(3);
-- 
-- ===================================
-- 2) Return/cancellation of the most recent sale for a car
-- ===================================
CREATE OR REPLACE PROCEDURE refund_sale(
        IN p_car_id INT,
        OUT refunded_sale_id INT,
        OUT refunded_amount INT,
        OUT refunded_car_id INT
    ) LANGUAGE plpgsql AS $$
DECLARE v_sale RECORD;

BEGIN
SELECT * INTO v_sale
FROM Sale
WHERE car_id = p_car_id
ORDER BY sale_date DESC,
    sale_id DESC
LIMIT 1;

IF NOT FOUND THEN RAISE EXCEPTION 'No sale found for car %',
p_car_id;

END IF;

refunded_sale_id := v_sale.sale_id;

refunded_amount := v_sale.sale_price;

refunded_car_id := v_sale.car_id;

DELETE FROM Sale
WHERE sale_id = v_sale.sale_id;

PERFORM update_employee_stat(v_sale.employee_id);

UPDATE Car
SET status_id = (
        SELECT status_id
        FROM StatusType
        WHERE name = 'Available'
        LIMIT 1
    )
WHERE car_id = p_car_id;

END;

$$;

-- CALL refund_sale(1, NULL, NULL, NULL);