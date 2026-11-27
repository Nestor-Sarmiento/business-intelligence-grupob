-- Intertel BI | Fase 3 | PostgreSQL 10+
-- Ejecutar en intertel_bi, después de crear el modelo de la fase 1.
-- Solo crea funciones y vistas: NO carga ni modifica las tablas dw.
BEGIN;

CREATE OR REPLACE FUNCTION staging.normalizar_texto(valor text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
 SELECT NULLIF(btrim(regexp_replace(translate(upper(valor),
 'ÁÉÍÓÚÜÀÈÌÒÙ','AEIOUUAEIOU'), '[[:space:]]+', ' ', 'g')), '');
$$;

-- Acepta formatos inequívocos ISO y día-mes-año. No adivina formatos MM/dd.
CREATE OR REPLACE FUNCTION staging.leer_timestamp(valor text)
RETURNS timestamp LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE t text := btrim(valor); iso text;
BEGIN
 IF t ~ '^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)?$' THEN
   iso := replace(t,'/','-');
 ELSIF t ~ '^[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}([ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)?$' THEN
   iso := regexp_replace(t, '^([0-9]{2})[-/]([0-9]{2})[-/]([0-9]{4})', '\3-\2-\1');
 ELSE RETURN NULL;
 END IF;
 RETURN iso::timestamp;
EXCEPTION WHEN invalid_datetime_format OR datetime_field_overflow THEN RETURN NULL;
END; $$;

-- No acepta separadores de miles ambiguos ni notación científica.
CREATE OR REPLACE FUNCTION staging.leer_decimal(valor text)
RETURNS numeric LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE t text := replace(btrim(valor), ',', '.');
BEGIN
 IF t !~ '^-?[0-9]+(\.[0-9]+)?$' THEN RETURN NULL; END IF;
 RETURN t::numeric;
EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN RETURN NULL;
END; $$;

-- Fecha del archivo original, no fecha de ejecución del ETL.
-- Para otro reporte, cambiar únicamente esta vista ANTES de ejecutar GPS.
CREATE OR REPLACE VIEW staging.v_config_reporte AS
SELECT DATE '2026-11-19' AS fecha_reporte;

CREATE OR REPLACE VIEW staging.v_factura_revision AS
WITH base AS (
 SELECT fila_origen, NULLIF(btrim(numero_factura),'') AS numero_factura,
 staging.normalizar_texto(nombre) AS nombre_normalizado,
 staging.leer_decimal(total) AS importe,
 staging.leer_timestamp(fecha)::date AS fecha_factura
 FROM staging.facturacion
), revisada AS (
 SELECT *, CASE
 WHEN numero_factura IS NULL OR numero_factura !~ '^[0-9]+$' THEN 'NUMERO_FACTURA_INVALIDO'
 WHEN nombre_normalizado IS NULL THEN 'NOMBRE_FALTANTE'
 WHEN importe IS NULL OR abs(importe) >= 999999999999.995 THEN 'IMPORTE_INVALIDO'
 WHEN fecha_factura IS NULL THEN 'FECHA_INVALIDA'
 ELSE NULL END AS regla_base
 FROM base
), variantes AS (
 SELECT numero_factura, count(*) AS cantidad_variantes
 FROM (SELECT DISTINCT numero_factura, nombre_normalizado, round(importe,2), fecha_factura
       FROM revisada WHERE regla_base IS NULL) x GROUP BY numero_factura
), ordenadas AS (
 SELECT r.*, v.cantidad_variantes,
 row_number() OVER (PARTITION BY r.numero_factura ORDER BY (r.regla_base IS NOT NULL), r.fila_origen) AS orden
 FROM revisada r LEFT JOIN variantes v USING(numero_factura)
)
SELECT fila_origen, numero_factura, nombre_normalizado,
 CASE WHEN regla_base IS NULL THEN importe::numeric(14,2) END AS valor_facturado,
 fecha_factura,
 CASE WHEN regla_base IS NOT NULL THEN regla_base
      WHEN cantidad_variantes > 1 THEN 'FACTURA_CONFLICTIVA'
      WHEN orden > 1 THEN 'FACTURA_DUPLICADA'
      ELSE NULL END AS regla
FROM ordenadas;

CREATE OR REPLACE VIEW staging.v_factura_limpia AS
SELECT fila_origen, numero_factura, nombre_normalizado, valor_facturado, fecha_factura
FROM staging.v_factura_revision WHERE regla IS NULL;

CREATE OR REPLACE VIEW staging.v_carga_dim_cliente AS
WITH catalogo AS (
 SELECT staging.normalizar_texto(nombre) AS nombre_normalizado,
 count(*)::integer AS coincidencias_catalogo,
 CASE WHEN count(*)=1 THEN min(NULLIF(btrim(codigo),'')) END AS codigo_origen
 FROM staging.clientes WHERE staging.normalizar_texto(nombre) IS NOT NULL GROUP BY 1
), nombres AS (
 SELECT nombre_normalizado FROM catalogo UNION
 SELECT nombre_normalizado FROM staging.v_factura_limpia
)
SELECT n.nombre_normalizado, c.codigo_origen,
 COALESCE(c.coincidencias_catalogo,0)::integer AS coincidencias_catalogo,
 CASE WHEN c.coincidencias_catalogo IS NULL THEN 'SIN_COINCIDENCIA'
      WHEN c.coincidencias_catalogo=1 THEN 'COINCIDENCIA_UNICA'
      ELSE 'COINCIDENCIA_MULTIPLE' END AS estado_catalogo
FROM nombres n LEFT JOIN catalogo c USING(nombre_normalizado);

CREATE OR REPLACE VIEW staging.v_gps_limpio AS
WITH base AS (
 SELECT d.fila_origen, staging.normalizar_texto(d.dispositivo) AS nombre_dispositivo,
 staging.normalizar_texto(d.grupo) AS grupo_normalizado,
 NULLIF(btrim(d.numero_sim),'') AS sim, NULLIF(btrim(d.hora),'') AS hora_original,
 staging.leer_timestamp(d.hora) AS fecha_leida,
 regexp_match(btrim(d.posicion), '^(-?[0-9]+(\.[0-9]+)?)[[:space:]]*,[[:space:]]*(-?[0-9]+(\.[0-9]+)?)$') AS coords,
 staging.leer_decimal(regexp_replace(btrim(d.distancia),'[[:space:]]*km[[:space:]]*$','','i')) AS distancia_leida,
 c.fecha_reporte
 FROM staging.dispositivos d CROSS JOIN staging.v_config_reporte c
), clasificada AS (
 SELECT *, CASE WHEN hora_original IS NULL OR hora_original ILIKE '%Nada se ha encontrado%' THEN 'SIN_DATOS'
 WHEN fecha_leida IS NULL OR fecha_leida::date > fecha_reporte THEN 'FECHA_INVALIDA'
 ELSE 'CON_DATOS' END AS estado_datos
 FROM base
)
SELECT fila_origen, nombre_dispositivo,
 CASE WHEN sim IS NOT NULL THEN 'N:' || md5(json_build_array(nombre_dispositivo,sim)::text)
 ELSE 'F:' || fecha_reporte::text || ':' || fila_origen::text END AS clave_origen,
 (sim IS NOT NULL) AS tiene_sim, true AS identidad_provisional,
 CASE WHEN grupo_normalizado IS NULL THEN 'M:' ELSE 'G:' || grupo_normalizado END AS clave_grupo,
 COALESCE(grupo_normalizado,'SIN GRUPO') AS nombre_grupo,
 (grupo_normalizado IS NULL) AS es_sin_grupo,
 fecha_reporte, estado_datos,
 CASE WHEN estado_datos='CON_DATOS' THEN fecha_leida END AS ultimo_registro,
 CASE WHEN estado_datos='CON_DATOS' THEN fecha_reporte-fecha_leida::date END AS dias_sin_registro,
 COALESCE(staging.leer_decimal(coords[1]) BETWEEN -90 AND 90 AND staging.leer_decimal(coords[3]) BETWEEN -180 AND 180,false) AS tiene_posicion,
 CASE WHEN distancia_leida >= 0 AND distancia_leida < 9999999999999.9995 THEN distancia_leida::numeric(16,3) END AS distancia_km
FROM clasificada;

CREATE OR REPLACE VIEW staging.v_carga_dim_dispositivo AS
SELECT DISTINCT clave_origen, nombre_dispositivo, tiene_sim, identidad_provisional
FROM staging.v_gps_limpio WHERE nombre_dispositivo IS NOT NULL;

CREATE OR REPLACE VIEW staging.v_carga_dim_grupo AS
SELECT DISTINCT clave_grupo, nombre_grupo, es_sin_grupo
FROM staging.v_gps_limpio WHERE nombre_dispositivo IS NOT NULL;

CREATE OR REPLACE VIEW staging.v_carga_dim_fecha AS
WITH limites AS (
 SELECT least(DATE '2022-01-01', (SELECT min(fecha_factura) FROM staging.v_factura_limpia),
   (SELECT min(ultimo_registro::date) FROM staging.v_gps_limpio), (SELECT fecha_reporte FROM staging.v_config_reporte)) AS desde,
 greatest(DATE '2026-12-31', (SELECT max(fecha_factura) FROM staging.v_factura_limpia),
   (SELECT max(ultimo_registro::date) FROM staging.v_gps_limpio), (SELECT fecha_reporte FROM staging.v_config_reporte)) AS hasta
), dias AS (
 SELECT g::date AS fecha FROM limites, LATERAL generate_series(desde::timestamp,hasta::timestamp,interval '1 day') AS g
)
SELECT to_char(fecha,'YYYYMMDD')::integer AS fecha_sk, fecha,
 extract(year FROM fecha)::smallint AS anio, extract(quarter FROM fecha)::smallint AS trimestre,
 extract(month FROM fecha)::smallint AS mes,
 (ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'])[extract(month FROM fecha)::integer]::varchar(12) AS nombre_mes,
 extract(day FROM fecha)::smallint AS dia, extract(isodow FROM fecha)::smallint AS dia_semana,
 (ARRAY['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'])[extract(isodow FROM fecha)::integer]::varchar(12) AS nombre_dia
FROM dias;

CREATE OR REPLACE VIEW staging.v_carga_fact_facturacion AS
SELECT c.cliente_sk, d.fecha_sk, f.numero_factura, f.valor_facturado,
 1::smallint AS cantidad_facturas, f.fila_origen
FROM staging.v_factura_limpia f
JOIN dw.dim_cliente c USING(nombre_normalizado)
JOIN dw.dim_fecha d ON d.fecha=f.fecha_factura;

CREATE OR REPLACE VIEW staging.v_carga_fact_estado_gps AS
SELECT d.dispositivo_sk, g.grupo_sk, fr.fecha_sk AS fecha_reporte_sk,
 fu.fecha_sk AS fecha_registro_sk, s.ultimo_registro, s.estado_datos,
 s.dias_sin_registro, s.tiene_posicion, s.distancia_km,
 1::smallint AS cantidad_registros, s.fila_origen
FROM staging.v_gps_limpio s
JOIN dw.dim_dispositivo d USING(clave_origen)
JOIN dw.dim_grupo g USING(clave_grupo)
JOIN dw.dim_fecha fr ON fr.fecha=s.fecha_reporte
LEFT JOIN dw.dim_fecha fu ON fu.fecha=s.ultimo_registro::date
WHERE s.nombre_dispositivo IS NOT NULL;

-- Incidencias consultables sin exponer nombres, SIM ni identificaciones.
-- La persistencia en audit.incidencia_etl se realizará con el Job de fase 4.
CREATE OR REPLACE VIEW staging.v_incidencias AS
SELECT 'FACTURACION'::text AS fuente, fila_origen, regla, 'RECHAZO'::text AS severidad
FROM staging.v_factura_revision WHERE regla IS NOT NULL
UNION ALL
SELECT 'GPS', fila_origen, 'DISPOSITIVO_FALTANTE','RECHAZO' FROM staging.v_gps_limpio WHERE nombre_dispositivo IS NULL
UNION ALL
SELECT 'GPS', fila_origen, 'SIN_GRUPO','ADVERTENCIA' FROM staging.v_gps_limpio WHERE es_sin_grupo
UNION ALL
SELECT 'GPS', fila_origen, 'SIN_SIM','ADVERTENCIA' FROM staging.v_gps_limpio WHERE NOT tiene_sim
UNION ALL
SELECT 'GPS', fila_origen, estado_datos,'ADVERTENCIA' FROM staging.v_gps_limpio WHERE estado_datos<>'CON_DATOS'
UNION ALL
SELECT 'FACTURACION', f.fila_origen, c.estado_catalogo,'ADVERTENCIA'
FROM staging.v_factura_limpia f JOIN staging.v_carga_dim_cliente c USING(nombre_normalizado)
WHERE c.estado_catalogo <> 'COINCIDENCIA_UNICA';
COMMIT;
