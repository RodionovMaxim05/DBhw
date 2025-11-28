-- ===================================
-- 1) Car reservation
-- ===================================
CREATE OR REPLACE PROCEDURE ReserveCar(
        car_id_param INT,
        client_id_param INT,
        employee_id_param INT
    ) LANGUAGE plpgsql AS $$
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

-- CALL ReserveCar(3, 1, 1);
-- 
-- ===================================
-- 2) Return/cancellation of sale
-- ===================================
CREATE OR REPLACE PROCEDURE RefundSale(
        IN p_sale_id INT,
        OUT refunded_sale_id INT,
        OUT refunded_amount INT,
        OUT refunded_car_id INT
    ) LANGUAGE plpgsql AS $$
DECLARE v_sale RECORD;

BEGIN
SELECT * INTO v_sale
FROM Sale
WHERE sale_id = p_sale_id;

IF NOT FOUND THEN RAISE EXCEPTION 'Sale % does not exist',
p_sale_id;

END IF;

refunded_sale_id := v_sale.sale_id;

refunded_amount := v_sale.sale_price;

refunded_car_id := v_sale.car_id;

DELETE FROM Sale
WHERE sale_id = p_sale_id;

PERFORM update_employee_stat(v_sale.employee_id);

IF NOT EXISTS (
    SELECT 1
    FROM Sale
    WHERE car_id = v_sale.car_id
) THEN
UPDATE Car
SET status_id = (
        SELECT status_id
        FROM StatusType
        WHERE name = 'Available'
    )
WHERE Car.car_id = v_sale.car_id;

END IF;

END;

$$;

-- CALL RefundSale(2, NULL, NULL, NULL);