SELECT * FROM staging.clientes
ORDER BY fila_origen ASC 

SELECT COUNT(*) 
FROM staging.clientes;

SELECT COUNT(*) 
FROM staging.facturacion;

SELECT COUNT(*)
FROM staging.dispositivos;

Consulta 1 — Cantidad de registros extraídos
SELECT 
    'Clientes' AS fuente,
    COUNT(*) AS registros
FROM staging.clientes

UNION ALL

SELECT 
    'Facturacion',
    COUNT(*)
FROM staging.facturacion

UNION ALL

SELECT 
    'Dispositivos',
    COUNT(*)
FROM staging.dispositivos;


Consulta 2 — Facturas completas

SELECT COUNT(*) AS facturas_completas
FROM staging.facturacion
WHERE NULLIF(TRIM(numero_factura), '') IS NOT NULL
  AND NULLIF(TRIM(nombre), '') IS NOT NULL
  AND NULLIF(TRIM(total), '') IS NOT NULL
  AND NULLIF(TRIM(fecha), '') IS NOT NULL;

Consulta 3 — Facturación total

SELECT
    COUNT(*) AS cantidad_facturas,
    SUM(REPLACE(TRIM(total), ',', '.')::NUMERIC)
        AS total_facturado
FROM staging.facturacion
WHERE numero_factura ~ '^[0-9]+$'
  AND NULLIF(TRIM(nombre), '') IS NOT NULL
  AND REPLACE(TRIM(total), ',', '.')
      ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND NULLIF(TRIM(fecha), '') IS NOT NULL;
  

Consulta 4 — Dispositivos sin información

SELECT
    COUNT(*) AS total_registros,

    COUNT(*) FILTER (
        WHERE hora ILIKE '%Nada se ha encontrado%'
    ) AS sin_informacion,

    COUNT(*) FILTER (
        WHERE hora IS NULL
           OR TRIM(hora) = ''
    ) AS hora_vacia,

    COUNT(*) FILTER (
        WHERE grupo IS NULL
           OR TRIM(grupo) = ''
    ) AS sin_grupo

FROM staging.dispositivos;

Consulta 5 — Nombres duplicados de clientes
SELECT
    UPPER(TRIM(nombre)) AS nombre,
    COUNT(*) AS repeticiones
FROM staging.clientes
GROUP BY UPPER(TRIM(nombre))
HAVING COUNT(*) > 1;