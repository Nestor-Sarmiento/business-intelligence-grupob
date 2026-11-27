-- INTERTEL BI | Fase 5: análisis OLAP mediante SQL (ROLAP)
-- Ejecutar en intertel_bi. Solo lectura. Ejecutar cada consulta individualmente.
-- No se crea un cubo físico: se explotan dimensiones y hechos relacionales.

-- OLAP01 | ROLL-UP: facturación desde mes a trimestre, año y total general.
SELECT d.anio, d.trimestre, d.mes,
       CASE GROUPING(d.anio, d.trimestre, d.mes)
         WHEN 0 THEN 'MES' WHEN 1 THEN 'TRIMESTRE'
         WHEN 3 THEN 'AÑO' WHEN 7 THEN 'TOTAL GENERAL' END AS nivel,
       SUM(f.valor_facturado) AS total_facturado,
       COUNT(*) AS facturas
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
GROUP BY ROLLUP (d.anio, d.trimestre, d.mes)
ORDER BY d.anio NULLS LAST, d.trimestre NULLS LAST, d.mes NULLS LAST;

-- OLAP02 | DRILL-DOWN: partir del total anual 2026 y abrirlo por trimestre/mes.
-- Ejecutar las tres consultas en orden; para bajar a día, consultar d.fecha.
SELECT d.anio, SUM(f.valor_facturado) AS total_facturado
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
WHERE d.anio = 2026 GROUP BY d.anio;

SELECT d.anio, d.trimestre, SUM(f.valor_facturado) AS total_facturado
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
WHERE d.anio = 2026 GROUP BY d.anio, d.trimestre ORDER BY d.trimestre;

SELECT d.anio, d.trimestre, d.mes, d.nombre_mes, SUM(f.valor_facturado) AS total_facturado
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
WHERE d.anio = 2026 GROUP BY d.anio, d.trimestre, d.mes, d.nombre_mes ORDER BY d.mes;

-- OLAP03 | SLICE: fijar una dimensión (año 2026).
SELECT d.mes, d.nombre_mes, SUM(f.valor_facturado) AS total_facturado,
       COUNT(*) AS facturas
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
WHERE d.anio = 2026
GROUP BY d.mes, d.nombre_mes ORDER BY d.mes;

-- OLAP04 | DICE: seleccionar varios valores en dos dimensiones.
-- Meses octubre y noviembre, años 2025/2026 y estados del catálogo seleccionados.
-- Noviembre 2026 es parcial; no interpretar como comparación de meses completos.
SELECT d.anio, d.mes, c.estado_catalogo, SUM(f.valor_facturado) AS total_facturado,
       COUNT(*) AS facturas
FROM dw.fact_facturacion f
JOIN dw.dim_fecha d USING (fecha_sk)
JOIN dw.dim_cliente c USING (cliente_sk)
WHERE d.anio IN (2025, 2026) AND d.mes IN (10, 11)
  AND c.estado_catalogo IN ('COINCIDENCIA_UNICA', 'SIN_COINCIDENCIA')
GROUP BY d.anio, d.mes, c.estado_catalogo
ORDER BY d.anio, d.mes, c.estado_catalogo;

-- OLAP05 | PIVOT: poner los años en columnas, meses en filas.
-- Enero-octubre de ambos años para comparar períodos equivalentes.
SELECT d.mes, d.nombre_mes,
       SUM(f.valor_facturado) FILTER (WHERE d.anio = 2025) AS facturado_2025,
       SUM(f.valor_facturado) FILTER (WHERE d.anio = 2026) AS facturado_2026
FROM dw.fact_facturacion f JOIN dw.dim_fecha d USING (fecha_sk)
WHERE d.anio IN (2025, 2026) AND d.mes BETWEEN 1 AND 10
GROUP BY d.mes, d.nombre_mes ORDER BY d.mes;

-- OLAP06 | CUBE: todas las combinaciones de grupo y estado de datos GPS.
-- El filtro del reporte evita mezclar instantáneas de distintos días.
SELECT CASE WHEN GROUPING(g.grupo_sk) = 1 THEN 'TODOS LOS GRUPOS'
            ELSE g.nombre_grupo END AS grupo,
       CASE WHEN GROUPING(f.estado_datos) = 1 THEN 'TODOS LOS ESTADOS'
            ELSE f.estado_datos END AS estado,
       GROUPING(g.grupo_sk, f.estado_datos) AS nivel_agrupacion,
       COUNT(*) AS registros
FROM dw.fact_estado_gps f JOIN dw.dim_grupo g USING (grupo_sk)
WHERE f.fecha_reporte_sk = 20261119
GROUP BY CUBE ((g.grupo_sk, g.nombre_grupo), f.estado_datos)
ORDER BY nivel_agrupacion, grupo, estado;

-- OLAP07 | GROUPING SETS: elegir explícitamente los niveles de agregación.
SELECT d.anio, c.estado_catalogo,
       CASE GROUPING(d.anio, c.estado_catalogo)
         WHEN 0 THEN 'AÑO Y ESTADO' WHEN 1 THEN 'AÑO'
         WHEN 2 THEN 'ESTADO' WHEN 3 THEN 'TOTAL GENERAL' END AS nivel,
       SUM(f.valor_facturado) AS total_facturado,
       COUNT(*) AS facturas
FROM dw.fact_facturacion f
JOIN dw.dim_fecha d USING (fecha_sk)
JOIN dw.dim_cliente c USING (cliente_sk)
GROUP BY GROUPING SETS ((d.anio, c.estado_catalogo), (d.anio), (c.estado_catalogo), ())
ORDER BY GROUPING(d.anio, c.estado_catalogo), d.anio, c.estado_catalogo;
