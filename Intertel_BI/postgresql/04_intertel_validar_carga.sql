-- Intertel BI | Fase 3 | Ejecutar después de las seis transformaciones.
-- 1. Comparación de fuentes limpias y destino
SELECT 'dim_fecha' AS tabla, (SELECT count(*) FROM staging.v_carga_dim_fecha) AS esperados, (SELECT count(*) FROM dw.dim_fecha) AS cargados
UNION ALL SELECT 'dim_cliente', (SELECT count(*) FROM staging.v_carga_dim_cliente), (SELECT count(*) FROM dw.dim_cliente)
UNION ALL SELECT 'dim_dispositivo', (SELECT count(*) FROM staging.v_carga_dim_dispositivo), (SELECT count(*) FROM dw.dim_dispositivo)
UNION ALL SELECT 'dim_grupo', (SELECT count(*) FROM staging.v_carga_dim_grupo), (SELECT count(*) FROM dw.dim_grupo)
UNION ALL SELECT 'fact_facturacion', (SELECT count(*) FROM staging.v_factura_limpia), (SELECT count(*) FROM dw.fact_facturacion)
UNION ALL SELECT 'fact_estado_gps', (SELECT count(*) FROM staging.v_gps_limpio WHERE nombre_dispositivo IS NOT NULL),
 (SELECT count(*) FROM dw.fact_estado_gps f JOIN dw.dim_fecha d ON d.fecha_sk=f.fecha_reporte_sk JOIN staging.v_config_reporte c ON c.fecha_reporte=d.fecha);

-- 2. Conciliación financiera exacta
SELECT (SELECT sum(valor_facturado) FROM staging.v_factura_limpia) AS total_origen_limpio,
 (SELECT sum(valor_facturado) FROM dw.fact_facturacion) AS total_dw,
 (SELECT sum(valor_facturado) FROM staging.v_factura_limpia)-(SELECT sum(valor_facturado) FROM dw.fact_facturacion) AS diferencia;

-- 3. Incidencias y excepciones (una fila puede tener varias reglas)
SELECT fuente, regla, severidad, count(*) AS cantidad FROM staging.v_incidencias GROUP BY 1,2,3 ORDER BY 1,3,2;

-- 4. Coincidencias por nombre: no equivalen a identidades verificadas.
SELECT c.estado_catalogo, count(*) AS facturas, sum(f.valor_facturado) AS valor_facturado
FROM dw.fact_facturacion f JOIN dw.dim_cliente c USING(cliente_sk) GROUP BY 1 ORDER BY 1;

-- 5. Estado GPS del reporte seleccionado
SELECT f.estado_datos, count(*) AS registros, count(*) FILTER (WHERE f.dias_sin_registro>30) AS registros_mas_30_dias
FROM dw.fact_estado_gps f JOIN dw.dim_fecha d ON d.fecha_sk=f.fecha_reporte_sk JOIN staging.v_config_reporte c ON c.fecha_reporte=d.fecha GROUP BY 1 ORDER BY 1;

-- 6. Control de claves foráneas y antigüedad
SELECT count(*) AS gps_inconsistentes
FROM dw.fact_estado_gps f JOIN dw.dim_fecha d ON d.fecha_sk=f.fecha_reporte_sk
LEFT JOIN dw.dim_fecha u ON u.fecha_sk=f.fecha_registro_sk
WHERE f.estado_datos='CON_DATOS' AND (u.fecha IS NULL OR f.dias_sin_registro IS DISTINCT FROM d.fecha-u.fecha);
