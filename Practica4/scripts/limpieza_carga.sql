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
