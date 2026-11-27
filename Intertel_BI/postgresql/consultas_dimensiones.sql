Consulta dimesion fecha 

SELECT COUNT(*)
FROM dw.dim_fecha;

Consulta dimesion cliente 

SELECT COUNT(*)
FROM dw.dim_cliente;

Consulta dimesion dispositivo 
SELECT
    COUNT(*) AS dispositivos,
    COUNT(*) FILTER (
        WHERE tiene_sim
    ) AS con_sim,
    COUNT(*) FILTER (
        WHERE NOT tiene_sim
    ) AS sin_sim
FROM dw.dim_dispositivo;

SELECT COUNT(*)
FROM staging.v_carga_dim_dispositivo;

Consulta dimension grupo 
SELECT COUNT(*)
FROM dw.dim_grupo;

Consulta fact_facturacion
SELECT
    COUNT(*) AS cantidad_facturas,
    SUM(valor_facturado) AS total_facturado,
    ROUND(AVG(valor_facturado), 2) AS ticket_promedio
FROM dw.fact_facturacion;


Consulta fact_estado_gps
SELECT COUNT(*)
FROM dw.fact_estado_gps;

SELECT
    estado_datos,
    COUNT(*) AS cantidad,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS porcentaje
FROM dw.fact_estado_gps
GROUP BY estado_datos;

Consulta Validar las dimensiones y las tablas de hechos
SELECT
    '04 - dim_fecha' AS tabla,
    (SELECT COUNT(*) FROM staging.v_carga_dim_fecha) AS esperados,
    (SELECT COUNT(*) FROM dw.dim_fecha) AS cargados

UNION ALL

SELECT
    '05 - dim_cliente',
    (SELECT COUNT(*) FROM staging.v_carga_dim_cliente),
    (SELECT COUNT(*) FROM dw.dim_cliente)

UNION ALL

SELECT
    '06 - dim_dispositivo',
    (SELECT COUNT(*) FROM staging.v_carga_dim_dispositivo),
    (SELECT COUNT(*) FROM dw.dim_dispositivo)

UNION ALL

SELECT
    '07 - dim_grupo',
    (SELECT COUNT(*) FROM staging.v_carga_dim_grupo),
    (SELECT COUNT(*) FROM dw.dim_grupo)

UNION ALL

SELECT
    '08 - fact_facturacion',
    (SELECT COUNT(*) FROM staging.v_factura_limpia),
    (SELECT COUNT(*) FROM dw.fact_facturacion)

UNION ALL

SELECT
    '09 - fact_estado_gps',
    (SELECT COUNT(*)
     FROM staging.v_gps_limpio
     WHERE nombre_dispositivo IS NOT NULL),
    (SELECT COUNT(*)
     FROM dw.fact_estado_gps f
     JOIN dw.dim_fecha d
         ON d.fecha_sk = f.fecha_reporte_sk
     JOIN staging.v_config_reporte c
         ON c.fecha_reporte = d.fecha);


Validar la facturacion total 
SELECT
    COUNT(*) AS cantidad_facturas,
    SUM(valor_facturado) AS total_facturado,
    ROUND(AVG(valor_facturado), 2) AS ticket_promedio
FROM dw.fact_facturacion;


Validar los estados GPS
SELECT
    estado_datos,
    COUNT(*) AS cantidad
FROM dw.fact_estado_gps
GROUP BY estado_datos;

Consulta ETL
SELECT
    ejecucion_sk,
    inicio,
    fin,
    fin - inicio AS duracion,
    estado,
    observacion
FROM audit.ejecucion_etl
ORDER BY ejecucion_sk DESC;

