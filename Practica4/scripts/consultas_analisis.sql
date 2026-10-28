-- 1. ¿Cuantas ventas se realizaron por categoria de producto y mes?
SELECT d.year AS anio,
       d.month AS mes,
       p.category AS categoria,
       COUNT(DISTINCT f.order_number) AS numero_ventas
FROM dw_ventas.fact_sales AS f
JOIN dw_ventas.dim_product AS p ON f.product_key = p.product_key
JOIN dw_ventas.dim_date AS d ON f.order_date_key = d.date_key
GROUP BY d.year, d.month, p.category
ORDER BY anio, mes, categoria;

-- 2. ¿Cual es el ingreso total (ventas) por cliente y genero?
SELECT c.source_customer_key AS cliente,
       c.gender AS genero,
       SUM(f.sales_amount) AS ingreso_total
FROM dw_ventas.fact_sales AS f
JOIN dw_ventas.dim_customer AS c ON f.customer_key = c.customer_key
GROUP BY c.source_customer_key, c.gender
ORDER BY ingreso_total DESC, cliente;

-- 3. ¿Cual es la cantidad total vendida por producto?
SELECT p.source_product_key AS producto_id,
       p.product_name AS producto,
       SUM(f.quantity) AS cantidad_total
FROM dw_ventas.fact_sales AS f
JOIN dw_ventas.dim_product AS p ON f.product_key = p.product_key
GROUP BY p.source_product_key, p.product_name
ORDER BY cantidad_total DESC, producto;

-- 4. ¿Cual fue la cantidad enviada por mes de envio?
SELECT d.year AS anio_envio,
       d.month AS mes_envio,
       SUM(f.quantity) AS cantidad_enviada
FROM dw_ventas.fact_sales AS f
JOIN dw_ventas.dim_date AS d ON f.ship_date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY anio_envio, mes_envio;

-- 5. ¿Cuanto se vendio por tamano de producto y estado civil del cliente?
SELECT p.size AS tamano_producto,
       c.marital_status AS estado_civil,
       SUM(f.sales_amount) AS ingreso_total
FROM dw_ventas.fact_sales AS f
JOIN dw_ventas.dim_product AS p ON f.product_key = p.product_key
JOIN dw_ventas.dim_customer AS c ON f.customer_key = c.customer_key
GROUP BY p.size, c.marital_status
ORDER BY tamano_producto, estado_civil;