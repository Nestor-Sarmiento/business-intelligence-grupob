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
