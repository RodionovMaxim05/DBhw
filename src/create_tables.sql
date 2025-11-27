-- ===================================
-- Reference tables (dictionaries)
-- ===================================
CREATE TABLE ClientType (
    client_type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE BodyType (
    body_type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE EngineType (
    engine_type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE TransmissionType (
    transmission_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE Position (
    position_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE StatusType (
    status_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- ===================================
-- Main Tables
-- ===================================
CREATE TABLE Client (
    client_id SERIAL PRIMARY KEY,
    client_type_id INT REFERENCES ClientType(client_type_id),
    first_name TEXT,
    last_name TEXT,
    company_name TEXT,
    phone VARCHAR(20),
    email TEXT,
    address TEXT
);

CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    position_id INT REFERENCES Position(position_id),
    phone VARCHAR(20),
    email TEXT,
    hire_date DATE NOT NULL
);

CREATE TABLE Model (
    model_id SERIAL PRIMARY KEY,
    brand TEXT NOT NULL,
    model_name TEXT NOT NULL,
    body_type_id INT REFERENCES BodyType(body_type_id),
    engine_type_id INT REFERENCES EngineType(engine_type_id),
    transmission_id INT REFERENCES TransmissionType(transmission_id)
);

CREATE TABLE Car (
    car_id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES Model(model_id),
    vin VARCHAR(17) NOT NULL UNIQUE,
    year INT CHECK (
        year >= 1900
        AND year <= EXTRACT(
            YEAR
            FROM CURRENT_DATE
        ) + 1
    ),
    color TEXT,
    price INT CHECK (price >= 0),
    status_id INT REFERENCES StatusType(status_id)
);

CREATE TABLE CarCondition (
    car_id INT PRIMARY KEY REFERENCES Car(car_id) ON DELETE CASCADE,
    mileage INT CHECK (mileage >= 0),
    mechanical_condition TEXT,
    body_condition TEXT,
    interior_condition TEXT,
    inspection_date DATE,
    notes TEXT
);

CREATE TABLE Sale (
    sale_id SERIAL PRIMARY KEY,
    car_id INT NOT NULL REFERENCES Car(car_id),
    client_id INT NOT NULL REFERENCES Client(client_id),
    employee_id INT NOT NULL REFERENCES Employee(employee_id),
    sale_date DATE NOT NULL,
    sale_price INT CHECK (sale_price >= 0)
);

CREATE TABLE EmployeeStatistic (
    employee_id INT PRIMARY KEY REFERENCES Employee(employee_id) ON DELETE CASCADE,
    total_sales_count INT DEFAULT 0 CHECK (total_sales_count >= 0),
    total_sales_amount INT DEFAULT 0 CHECK (total_sales_amount >= 0),
    last_sale_date DATE
);

-- ===================================
-- Indexes
-- ===================================
CREATE INDEX idx_car_model ON Car(model_id);

CREATE INDEX idx_sale_employee ON Sale(employee_id);

CREATE INDEX idx_sale_client ON Sale(client_id);

CREATE INDEX idx_sale_date ON Sale(sale_date);

CREATE INDEX idx_car_status ON Car(status_id);

CREATE INDEX idx_model_brand_model ON Model(brand, model_name);

CREATE INDEX idx_car_year ON Car(year);