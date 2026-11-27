-- INTERTEL BI | Fase 5: preguntas de negocio
-- Ejecutar en intertel_bi, desde pgAdmin. Consultas de solo lectura.
-- Ejecutar un bloque a la vez para visualizar su resultado.
-- Facturación = importe emitido, no cobrado. Cliente = nombre normalizado.
-- GPS = registros del reporte del 19/11/2026, no flota total ni estado en vivo.
-- Para proteger datos personales, los rankings identifican clientes/dispositivos por SK.

-- PN01. ¿Cuánto se ha facturado por año, trimestre y mes?
SELECT d.anio, d.trimestre, d.mes, d.nombre_mes,
       SUM(f.valor_facturado) AS total_facturado,
       COUNT(*) AS cantidad_facturas
FROM dw.fact_facturacion f
JOIN dw.dim_fecha d ON d.fecha_sk = f.fecha_sk
GROUP BY d.anio, d.trimestre, d.mes, d.nombre_mes
ORDER BY d.anio, d.mes;

-- PN02. ¿Cómo evolucionó la facturación entre enero y octubre de 2025 y 2026?
-- Se excluye noviembre de ambos años porque noviembre de 2026 está incompleto.
-- Comparación de registros disponibles: confirmar cobertura completa con Intertel.
WITH periodos AS (
    SELECT
        SUM(f.valor_facturado) FILTER (WHERE d.anio = 2025) AS total_2025,
        SUM(f.valor_facturado) FILTER (WHERE d.anio = 2026) AS total_2026
    FROM dw.fact_facturacion f
    JOIN dw.dim_fecha d ON d.fecha_sk = f.fecha_sk
    WHERE d.anio IN (2025, 2026) AND d.mes BETWEEN 1 AND 10
)
SELECT total_2025, total_2026,
       total_2026 - total_2025 AS diferencia,
       ROUND(100.0 * (total_2026 - total_2025) / NULLIF(total_2025, 0), 2) AS variacion_pct
FROM periodos;

-- PN03. ¿Cuáles son los diez clientes facturados con mayor importe?
SELECT c.cliente_sk, c.estado_catalogo,
       COUNT(*) AS cantidad_facturas,
       SUM(f.valor_facturado) AS total_facturado
FROM dw.fact_facturacion f
JOIN dw.dim_cliente c ON c.cliente_sk = f.cliente_sk
GROUP BY c.cliente_sk, c.estado_catalogo
ORDER BY total_facturado DESC, c.cliente_sk
LIMIT 10;

-- PN04. ¿Qué porcentaje de facturación corresponde a los diez principales clientes?
WITH por_cliente AS (
    SELECT cliente_sk, SUM(valor_facturado) AS total_cliente
    FROM dw.fact_facturacion GROUP BY cliente_sk
), ranking AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY total_cliente DESC, cliente_sk) AS posicion
    FROM por_cliente
)
SELECT SUM(total_cliente) AS total_facturado,
       SUM(total_cliente) FILTER (WHERE posicion <= 10) AS facturacion_top_10,
       ROUND(100.0 * SUM(total_cliente) FILTER (WHERE posicion <= 10)
             / NULLIF(SUM(total_cliente), 0), 2) AS concentracion_top_10_pct
FROM ranking;

-- PN05. ¿Cuál es el importe promedio de una factura?
SELECT COUNT(*) AS cantidad_facturas,
       SUM(valor_facturado) AS total_facturado,
       ROUND(AVG(valor_facturado), 2) AS ticket_promedio
FROM dw.fact_facturacion;

-- PN06. ¿Cuántos nombres de clientes diferentes registran facturación cada mes?
SELECT d.anio, d.mes, d.nombre_mes,
       COUNT(DISTINCT f.cliente_sk) AS clientes_facturados,
       COUNT(*) AS cantidad_facturas
FROM dw.fact_facturacion f
JOIN dw.dim_fecha d ON d.fecha_sk = f.fecha_sk
GROUP BY d.anio, d.mes, d.nombre_mes
ORDER BY d.anio, d.mes;

-- PN07. ¿Qué meses tienen mayor y menor facturación?
-- Se excluye noviembre de 2026 (parcial) y los meses sin registros.
WITH mensual AS (
    SELECT d.anio, d.mes, d.nombre_mes, SUM(f.valor_facturado) AS total_facturado
    FROM dw.fact_facturacion f
    JOIN dw.dim_fecha d ON d.fecha_sk = f.fecha_sk
    WHERE d.fecha >= DATE '2025-01-01' AND d.fecha < DATE '2026-11-01'
    GROUP BY d.anio, d.mes, d.nombre_mes
), ranking AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY total_facturado DESC) AS mayor,
              DENSE_RANK() OVER (ORDER BY total_facturado ASC) AS menor
    FROM mensual
)
SELECT CASE WHEN mayor = 1 THEN 'MAYOR' ELSE 'MENOR' END AS clasificacion,
       anio, mes, nombre_mes, total_facturado
FROM ranking WHERE mayor = 1 OR menor = 1
ORDER BY mayor, anio, mes;

-- PN08. ¿Con qué frecuencia se emiten facturas por nombre de cliente?
SELECT f.cliente_sk, COUNT(*) AS facturas,
       COUNT(DISTINCT (d.anio, d.mes)) AS meses_con_facturas,
       MIN(d.fecha) AS primera_factura, MAX(d.fecha) AS ultima_factura,
       ROUND(COUNT(*)::numeric / NULLIF(COUNT(DISTINCT (d.anio, d.mes)), 0), 2)
           AS facturas_por_mes_con_actividad
FROM dw.fact_facturacion f
JOIN dw.dim_fecha d ON d.fecha_sk = f.fecha_sk
GROUP BY f.cliente_sk
ORDER BY facturas DESC, f.cliente_sk;

-- PN09. ¿Cuántos registros y claves de dispositivo aparecen en el reporte?
SELECT COUNT(*) AS registros_gps,
       COUNT(DISTINCT dispositivo_sk) AS dispositivos_identificados_provisionalmente,
       COUNT(DISTINCT f.grupo_sk) FILTER (WHERE NOT g.es_sin_grupo) AS grupos_identificados
FROM dw.fact_estado_gps f
JOIN dw.dim_grupo g USING (grupo_sk)
WHERE f.fecha_reporte_sk = 20261119;

-- PN10. ¿Qué grupos concentran más registros de dispositivos?
SELECT g.grupo_sk, g.nombre_grupo, g.es_sin_grupo,
       COUNT(*) AS registros_gps,
       COUNT(DISTINCT f.dispositivo_sk) AS claves_dispositivo,
       ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) AS participacion_pct
FROM dw.fact_estado_gps f JOIN dw.dim_grupo g USING (grupo_sk)
WHERE f.fecha_reporte_sk = 20261119
GROUP BY g.grupo_sk, g.nombre_grupo, g.es_sin_grupo
ORDER BY registros_gps DESC, g.grupo_sk;

-- PN11. ¿Qué proporción de registros tiene información GPS disponible?
SELECT estado_datos, COUNT(*) AS registros,
       ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) AS porcentaje
FROM dw.fact_estado_gps WHERE fecha_reporte_sk = 20261119
GROUP BY estado_datos ORDER BY registros DESC;

-- PN12. ¿Qué grupos presentan más registros sin datos y qué proporción representan?
SELECT g.grupo_sk, g.nombre_grupo, COUNT(*) AS total_registros,
       COUNT(*) FILTER (WHERE f.estado_datos = 'SIN_DATOS') AS sin_datos,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.estado_datos = 'SIN_DATOS')
             / NULLIF(COUNT(*), 0), 2) AS sin_datos_pct
FROM dw.fact_estado_gps f JOIN dw.dim_grupo g USING (grupo_sk)
WHERE f.fecha_reporte_sk = 20261119
GROUP BY g.grupo_sk, g.nombre_grupo
ORDER BY sin_datos DESC, sin_datos_pct DESC, g.grupo_sk;

-- PN13. ¿Cuál es la antigüedad de la información GPS disponible?
WITH rangos AS (
    SELECT CASE WHEN estado_datos = 'SIN_DATOS' THEN 5
                WHEN estado_datos = 'FECHA_INVALIDA' THEN 6
                WHEN dias_sin_registro = 0 THEN 1
                WHEN dias_sin_registro BETWEEN 1 AND 7 THEN 2
                WHEN dias_sin_registro BETWEEN 8 AND 30 THEN 3
                ELSE 4 END AS orden
    FROM dw.fact_estado_gps WHERE fecha_reporte_sk = 20261119
)
SELECT orden, CASE orden WHEN 1 THEN 'Mismo día' WHEN 2 THEN '1-7 días'
       WHEN 3 THEN '8-30 días' WHEN 4 THEN 'Más de 30 días'
       WHEN 5 THEN 'Sin datos' ELSE 'Fecha inválida' END AS rango,
       COUNT(*) AS registros,
       ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) AS porcentaje
FROM rangos GROUP BY orden ORDER BY orden;

-- PN14. ¿Qué grupos requieren revisión por registros con más de 30 días de antigüedad?
SELECT g.grupo_sk, g.nombre_grupo, COUNT(*) AS registros,
       COUNT(*) FILTER (WHERE f.estado_datos = 'CON_DATOS') AS con_datos,
       COUNT(*) FILTER (WHERE f.dias_sin_registro > 30) AS mas_30_dias,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.dias_sin_registro > 30)
          / NULLIF(COUNT(*) FILTER (WHERE f.estado_datos = 'CON_DATOS'), 0), 2) AS pct_sobre_con_datos
FROM dw.fact_estado_gps f JOIN dw.dim_grupo g USING (grupo_sk)
WHERE f.fecha_reporte_sk = 20261119
GROUP BY g.grupo_sk, g.nombre_grupo
ORDER BY mas_30_dias DESC, g.grupo_sk;

-- PN15 (reformulada). ¿Cuántos registros cuentan con coordenadas válidas?
-- El DW solo guarda tiene_posicion, no latitud/longitud ni ciudad.
SELECT COUNT(*) AS registros,
       COUNT(*) FILTER (WHERE tiene_posicion) AS con_posicion,
       COUNT(*) FILTER (WHERE NOT tiene_posicion) AS sin_posicion,
       ROUND(100.0 * COUNT(*) FILTER (WHERE tiene_posicion) / NULLIF(COUNT(*), 0), 2) AS cobertura_pct
FROM dw.fact_estado_gps WHERE fecha_reporte_sk = 20261119;

-- PN16. ¿Qué proporción de facturas no coincide por nombre con el catálogo?
SELECT c.estado_catalogo, COUNT(*) AS facturas,
       SUM(f.valor_facturado) AS valor_facturado,
       ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) AS porcentaje_facturas
FROM dw.fact_facturacion f JOIN dw.dim_cliente c USING (cliente_sk)
GROUP BY c.estado_catalogo ORDER BY facturas DESC;

-- PN17. ¿Cuántos registros GPS carecen de grupo o SIM?
SELECT COUNT(*) AS registros,
       COUNT(*) FILTER (WHERE g.es_sin_grupo) AS sin_grupo,
       COUNT(*) FILTER (WHERE NOT d.tiene_sim) AS sin_sim,
       COUNT(*) FILTER (WHERE g.es_sin_grupo AND NOT d.tiene_sim) AS sin_ambos
FROM dw.fact_estado_gps f
JOIN dw.dim_grupo g USING (grupo_sk)
JOIN dw.dim_dispositivo d USING (dispositivo_sk)
WHERE f.fecha_reporte_sk = 20261119;

-- PN18. ¿Qué incidencias de calidad fueron detectadas en la última carga exitosa?
-- Usar solo la última ejecución evita contabilizar nuevamente el mismo archivo.
SELECT fuente, regla, severidad, COUNT(*) AS incidencias
FROM audit.incidencia_etl
WHERE ejecucion_sk = (SELECT MAX(ejecucion_sk) FROM audit.ejecucion_etl WHERE estado = 'EXITOSO')
GROUP BY fuente, regla, severidad ORDER BY fuente, severidad, regla;
