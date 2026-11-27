-- Ejecutar después del script 01, conectado a intertel_bi.
-- Deben aparecer 11 tablas: staging (3), dw (6), audit (2).
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('staging','dw','audit') AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

-- Deben aparecer 11 claves primarias y 6 foráneas en dw.
SELECT table_schema, table_name, constraint_type, constraint_name
FROM information_schema.table_constraints
WHERE table_schema IN ('staging','dw','audit')
  AND constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
ORDER BY table_schema, table_name, constraint_type;

-- Antes del ETL deben aparecer 0 filas en las seis tablas dimensionales.
SELECT 'dim_fecha' AS tabla, COUNT(*) AS filas FROM dw.dim_fecha
UNION ALL SELECT 'dim_cliente', COUNT(*) FROM dw.dim_cliente
UNION ALL SELECT 'dim_grupo', COUNT(*) FROM dw.dim_grupo
UNION ALL SELECT 'dim_dispositivo', COUNT(*) FROM dw.dim_dispositivo
UNION ALL SELECT 'fact_facturacion', COUNT(*) FROM dw.fact_facturacion
UNION ALL SELECT 'fact_estado_gps', COUNT(*) FROM dw.fact_estado_gps;
