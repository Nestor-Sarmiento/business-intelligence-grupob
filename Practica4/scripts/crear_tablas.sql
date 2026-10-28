-- Creación de tablas de staging
DROP TABLE IF EXISTS stg_products;

CREATE TABLE stg_products (
    product_id      VARCHAR(5),
    product_name    VARCHAR(150),
    category        VARCHAR(80),
    subcategory     VARCHAR(80)
);

-- Creación de tabla de dimensión de producto
DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product (
    product_key  BIGSERIAL PRIMARY KEY,
    product_id   VARCHAR(5) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(80) NOT NULL,
    subcategory  VARCHAR(80) NOT NULL
);

-- VENTAS

-- Creación de tabla de staging de ventas
DROP TABLE IF EXISTS stg_ventas;

CREATE TABLE stg_ventas (
    product_key INTEGER,
    product_code VARCHAR(50),
    product_name VARCHAR(150),
    list_price NUMERIC(12,2),
    color VARCHAR(50),
    size VARCHAR(50),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    customer_key INTEGER,
    birth_date DATE,
    marital_status VARCHAR(30),
    gender VARCHAR(10),
    income NUMERIC(12,2),
    children INTEGER,
    home_owner VARCHAR(10),
    cars INTEGER,
    order_date_key INTEGER,
    order_date DATE,
    ship_date_key INTEGER,
    ship_date DATE,
    order_number VARCHAR(50),
    order_line_number INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    product_cost NUMERIC(12,2),
    sales_amount NUMERIC(12,2)
);

-- Creación de esquema para ventas
CREATE SCHEMA IF NOT EXISTS dw_ventas;

-- Creación de tabla de dimensión de producto
CREATE TABLE IF NOT EXISTS dw_ventas.dim_product (
    product_key         BIGSERIAL PRIMARY KEY,
    source_product_key  INTEGER NOT NULL UNIQUE,
    product_code        VARCHAR(50) NOT NULL,
    product_name        VARCHAR(150) NOT NULL,
    list_price          NUMERIC(12,2),
    color               VARCHAR(50),
    size                VARCHAR(50),
    category            VARCHAR(100),
    subcategory         VARCHAR(100)
);

-- Creación de tabla de dimensión de cliente
CREATE TABLE IF NOT EXISTS dw_ventas.dim_customer (
    customer_key         BIGSERIAL PRIMARY KEY,
    source_customer_key  INTEGER NOT NULL UNIQUE,
    birth_date           DATE,
    marital_status       VARCHAR(30),
    gender               VARCHAR(10),
    income               NUMERIC(12,2),
    children             INTEGER,
    home_owner           VARCHAR(10),
    cars                 INTEGER
);

-- Creación de tabla de dimensión de fecha
CREATE TABLE IF NOT EXISTS dw_ventas.dim_date (
    date_key       INTEGER PRIMARY KEY,
    full_date      DATE NOT NULL UNIQUE,
    year           INTEGER NOT NULL,
    quarter        INTEGER NOT NULL,
    month          INTEGER NOT NULL,
    month_name     VARCHAR(20) NOT NULL,
    day            INTEGER NOT NULL
);

-- Creación de tabla de hechos de ventas
CREATE TABLE IF NOT EXISTS dw_ventas.fact_sales (
    sales_key          BIGSERIAL PRIMARY KEY,
    product_key        BIGINT NOT NULL REFERENCES dw_ventas.dim_product(product_key),
    customer_key       BIGINT NOT NULL REFERENCES dw_ventas.dim_customer(customer_key),
    order_date_key     INTEGER NOT NULL REFERENCES dw_ventas.dim_date(date_key),
    ship_date_key      INTEGER NOT NULL REFERENCES dw_ventas.dim_date(date_key),
    order_number       VARCHAR(50) NOT NULL,
    order_line_number  INTEGER NOT NULL,
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    unit_price         NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    product_cost       NUMERIC(12,2),
    sales_amount       NUMERIC(12,2) NOT NULL CHECK (sales_amount >= 0),
    CONSTRAINT uq_fact_sales_order_line UNIQUE (order_number, order_line_number)
);