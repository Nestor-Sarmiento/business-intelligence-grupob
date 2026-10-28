-- Limpieza de datos de la tabla de staging
UPDATE stg_products
SET product_name = regexp_replace(btrim(product_name), '\s+', ' ', 'g'),
    category = btrim(category),
    subcategory = btrim(subcategory);


-- Carga de datos desde la tabla de staging a la tabla de dimensión de producto
INSERT INTO dim_product
    (product_id, product_name, category, subcategory)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    subcategory
FROM stg_products
ORDER BY product_id;

-- VENTAS

-- Limpieza de datos de la tabla de staging de ventas
UPDATE public.stg_ventas
SET product_code = BTRIM(product_code),
    product_name = REGEXP_REPLACE(BTRIM(product_name), '[[:space:]]+', ' ', 'g'),
    color = BTRIM(color),
    size = BTRIM(size),
    category = BTRIM(category),
    subcategory = BTRIM(subcategory),
    marital_status = BTRIM(marital_status),
    gender = UPPER(BTRIM(gender)),
    home_owner = BTRIM(home_owner),
    order_number = BTRIM(order_number);

-- Carga de datos desde la tabla de staging a la tabla de dimensión de producto
INSERT INTO dw_ventas.dim_product
    (source_product_key, product_code, product_name, list_price,
     color, size, category, subcategory)
SELECT DISTINCT product_key, product_code, product_name, list_price,
       color, size, category, subcategory
FROM public.stg_ventas
WHERE product_key IS NOT NULL
ON CONFLICT (source_product_key) DO NOTHING;

-- Carga de datos desde la tabla de staging a la tabla de dimensión de cliente
INSERT INTO dw_ventas.dim_customer
    (source_customer_key, birth_date, marital_status, gender, income,
     children, home_owner, cars)
SELECT DISTINCT customer_key, birth_date, marital_status, gender, income,
       children, home_owner, cars
FROM public.stg_ventas
WHERE customer_key IS NOT NULL
ON CONFLICT (source_customer_key) DO NOTHING;

-- Carga de datos desde la tabla de staging a la tabla de dimensión de fecha
INSERT INTO dw_ventas.dim_date
    (date_key, full_date, year, quarter, month, month_name, day)
SELECT TO_CHAR(fecha, 'YYYYMMDD')::INTEGER,
       fecha,
       EXTRACT(YEAR FROM fecha)::INTEGER,
       EXTRACT(QUARTER FROM fecha)::INTEGER,
       EXTRACT(MONTH FROM fecha)::INTEGER,
       TO_CHAR(fecha, 'TMMonth'),
       EXTRACT(DAY FROM fecha)::INTEGER
FROM (
    SELECT order_date AS fecha FROM public.stg_ventas
    UNION
    SELECT ship_date AS fecha FROM public.stg_ventas
) AS fechas
WHERE fecha IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;

-- Carga de datos desde la tabla de staging a la tabla de hechos de ventas
INSERT INTO dw_ventas.fact_sales
    (product_key, customer_key, order_date_key, ship_date_key,
     order_number, order_line_number, quantity, unit_price,
     product_cost, sales_amount)
SELECT p.product_key,
       c.customer_key,
       v.order_date_key,
       v.ship_date_key,
       v.order_number,
       v.order_line_number,
       v.quantity,
       v.unit_price,
       v.product_cost,
       v.sales_amount
FROM public.stg_ventas AS v
JOIN dw_ventas.dim_product AS p
  ON p.source_product_key = v.product_key
JOIN dw_ventas.dim_customer AS c
  ON c.source_customer_key = v.customer_key
JOIN dw_ventas.dim_date AS od
  ON od.date_key = v.order_date_key
JOIN dw_ventas.dim_date AS sd
  ON sd.date_key = v.ship_date_key
WHERE TRUE
ON CONFLICT (order_number, order_line_number) DO NOTHING;