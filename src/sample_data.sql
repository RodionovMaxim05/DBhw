-- ===================================
-- Values ​​for reference dictionaries
-- ===================================
INSERT INTO ClientType (name)
VALUES ('Individual'),
    ('Legal') ON CONFLICT DO NOTHING;

INSERT INTO StatusType (name)
VALUES ('Available'),
    ('Reserved'),
    ('Sold'),
    ('In Service') ON CONFLICT DO NOTHING;

INSERT INTO Position (name)
VALUES ('Salesperson'),
    ('Manager'),
    ('Director') ON CONFLICT DO NOTHING;

INSERT INTO BodyType (name)
VALUES ('Sedan'),
    ('Hatchback'),
    ('SUV'),
    ('CUV'),
    ('Coupe'),
    ('Wagon') ON CONFLICT DO NOTHING;

INSERT INTO EngineType (name)
VALUES ('Petrol'),
    ('Diesel'),
    ('Hybrid'),
    ('Electric') ON CONFLICT DO NOTHING;

INSERT INTO TransmissionType (name)
VALUES ('Manual'),
    ('Automatic') ON CONFLICT DO NOTHING;

-- ===================================
-- Employees
-- ===================================
INSERT INTO Employee (
        first_name,
        last_name,
        position_id,
        phone,
        email,
        hire_date
    )
VALUES (
        'Ivan',
        'Petrov',
        1,
        '+7-900-111-2222',
        'ivan.petrov@example.com',
        '2019-06-15'
    ),
    (
        'Olga',
        'Sidorova',
        1,
        '+7-900-333-4444',
        'olga.sidorova@example.com',
        '2020-03-01'
    ),
    (
        'Mikhail',
        'Ivanov',
        2,
        '+7-900-555-6666',
        'm.ivanov@example.com',
        '2018-01-10'
    ),
    (
        'Filipp',
        'Kovalev',
        3,
        '+7-900-777-8888',
        'f.kovalev@example.com',
        '2021-05-20'
    ) ON CONFLICT DO NOTHING;

-- ===================================
-- Clients (individuals and corporate)
-- ===================================
INSERT INTO Client (
        client_type_id,
        first_name,
        last_name,
        company_name,
        phone,
        email,
        address
    )
VALUES (
        1,
        'Petr',
        'Smirnov',
        NULL,
        '+7-912-000-1111',
        'p.smirnov@example.com',
        'Moscow, Tverskaya 1'
    ),
    (
        2,
        NULL,
        NULL,
        'TechSolutions LLC',
        '+7-912-222-3333',
        'sales@techsolutions.ru',
        'Saint Petersburg, Nevsky 5'
    ),
    (
        1,
        'Anna',
        'Kuznetsova',
        NULL,
        '+7-912-444-5555',
        'anna.k@example.com',
        'Kazan, Baumana 10'
    ),
    (
        1,
        'Dmitriy',
        'Orlov',
        NULL,
        '+7-912-666-7777',
        'd.orlov@example.com',
        'Novosibirsk, Lenina 20'
    ) ON CONFLICT DO NOTHING;

-- ===================================
-- Models
-- ===================================
INSERT INTO Model (
        brand,
        model_name,
        body_type_id,
        engine_type_id,
        transmission_id
    )
VALUES ('Toyota', 'Camry', 1, 1, 2),
    ('Porsche', 'Cayenne', 3, 2, 2),
    ('Porsche', '911', 5, 1, 1),
    ('BMW', 'M4', 1, 1, 2),
    ('Tesla', 'Model 3', 4, 4, 2),
    ('Audi', 'RS6', 6, 1, 2) ON CONFLICT DO NOTHING;

-- ===================================
-- Cars
-- ===================================
INSERT INTO Car (
        model_id,
        vin,
        year,
        color,
        price,
        status_id
    )
VALUES (
        (
            SELECT model_id
            FROM model
            WHERE brand = 'Toyota'
                AND model_name = 'Camry'
            LIMIT 1
        ), 'JTNBB46KX20000001', 2021, 'Black', 3000000, 1
    ), (
        (
            SELECT model_id
            FROM model
            WHERE brand = 'Porsche'
                AND model_name = '911'
            LIMIT 1
        ), '2T3RFREV9FW000002', 2024, 'White', 28000000, 1
    ), (
        (
            SELECT model_id
            FROM model
            WHERE brand = 'BMW'
                AND model_name = 'M4'
            LIMIT 1
        ), 'WBA8E1C50GK000003', 2021, 'Blue', 9000000, 1
    ),(
        (
            SELECT model_id
            FROM model
            WHERE brand = 'Audi'
                AND model_name = 'RS6'
            LIMIT 1
        ), '1HGBH41JXMN109186', 2023, 'Gray', 12000000, 2
    ) ON CONFLICT DO NOTHING;

-- ===================================
-- Car conditions (for used cars)
-- ===================================
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
        (
            SELECT car_id
            FROM car
            WHERE vin = 'JTNBB46KX20000001'
        ),
        50000,
        'Ok',
        'Replaced bumper',
        'Good',
        '2025-11-01',
        'Service done at 40000 km'
    ),
    (
        (
            SELECT car_id
            FROM car
            WHERE vin = '2T3RFREV9FW000002'
        ),
        112,
        'Perfect',
        'Perfect',
        'Perfect',
        '2025-10-15',
        NULL
    ),
    (
        (
            SELECT car_id
            FROM car
            WHERE vin = 'WBA8E1C50GK000003'
        ),
        32000,
        'Engine goes tuk-tuk',
        'Good',
        'Good',
        '2025-09-20',
        'Engine needs check'
    ) ON CONFLICT DO NOTHING;

-- ===================================
-- Sales
-- ===================================
INSERT INTO Sale (
        sale_date,
        car_id,
        client_id,
        employee_id,
        sale_price
    )
VALUES (
        '2025-11-02',
        (
            SELECT car_id
            FROM Car
            WHERE vin = 'JTNBB46KX20000001'
        ),
        (
            SELECT client_id
            FROM Client
            WHERE last_name = 'Smirnov'
            LIMIT 1
        ),(
            SELECT employee_id
            FROM Employee
            WHERE last_name = 'Petrov'
            LIMIT 1
        ), 2930000
    ), (
        '2025-10-10',(
            SELECT car_id
            FROM Car
            WHERE vin = 'WBA8E1C50GK000003'
        ),
        (
            SELECT client_id
            FROM Client
            WHERE last_name = 'Kuznetsova'
            LIMIT 1
        ),(
            SELECT employee_id
            FROM Employee
            WHERE last_name = 'Sidorova'
            LIMIT 1
        ), 9005000
    ), (
        '2025-03-15',(
            SELECT car_id
            FROM Car
            WHERE vin = 'JTNBB46KX20000001'
        ),
        (
            SELECT client_id
            FROM Client
            WHERE last_name = 'Orlov'
            LIMIT 1
        ),(
            SELECT employee_id
            FROM Employee
            WHERE last_name = 'Kovalev'
            LIMIT 1
        ), 2700000
    ) ON CONFLICT DO NOTHING;

-- ===================================
-- Rebuild EmployeeStatistic from current sales
-- ===================================
-- INSERT INTO EmployeeStatistic (
--         employee_id,
--         total_sales_count,
--         total_sales_amount,
--         last_sale_date
--     )
-- SELECT empl.employee_id,
--     COUNT(Sale.sale_id) AS cnt,
--     COALESCE(SUM(Sale.sale_price), 0) AS amt,
--     MAX(Sale.sale_date)
-- FROM Employee empl
--     LEFT JOIN Sale ON Sale.employee_id = empl.employee_id
-- GROUP BY empl.employee_id ON CONFLICT (employee_id) DO
-- UPDATE
-- SET total_sales_count = EXCLUDED.total_sales_count,
--     total_sales_amount = EXCLUDED.total_sales_amount,
--     last_sale_date = EXCLUDED.last_sale_date;