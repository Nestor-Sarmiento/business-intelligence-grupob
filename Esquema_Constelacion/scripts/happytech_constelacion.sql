-- =====================================================================
-- HAPPYTECH - Data Warehouse con ESQUEMA CONSTELACIÓN
-- Hechos: fact_pedidos, fact_soporte
-- Dimensiones compartidas: dim_tiempo, dim_producto, dim_cliente
-- Dimensión exclusiva de soporte: dim_motivo
-- Ejecutar completo en pgAdmin (Query Tool) sobre una BD vacía, ej. happytech_dw
-- =====================================================================

DROP SCHEMA IF EXISTS staging CASCADE;
DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA staging;
CREATE SCHEMA dw;

-- ---------------------------------------------------------------------
-- 1. STAGING (datos tal cual vienen del Excel)
-- ---------------------------------------------------------------------
CREATE TABLE staging.pedidos (
    fecha        DATE,
    producto     VARCHAR(60),
    categoria    VARCHAR(40),
    marca        VARCHAR(40),
    cliente      VARCHAR(60),
    ciudad       VARCHAR(40),
    region       VARCHAR(20),
    cantidad     INT,
    total_pedido NUMERIC(12,2)
);

CREATE TABLE staging.soporte (
    fecha                  DATE,
    producto               VARCHAR(60),
    categoria              VARCHAR(40),
    marca                  VARCHAR(40),
    cliente                VARCHAR(60),
    ciudad                 VARCHAR(40),
    region                 VARCHAR(20),
    ticket_id              INT,
    motivo                 VARCHAR(60),
    tiempo_respuesta_horas INT
);

INSERT INTO staging.pedidos (fecha, producto, categoria, marca, cliente, ciudad, region, cantidad, total_pedido) VALUES
('2025-01-01', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5930),
('2025-01-12', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 3, 3951),
('2025-01-08', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 1, 342),
('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 1780),
('2025-01-02', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 947),
('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 2738),
('2025-01-14', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 3, 831),
('2025-01-07', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3820),
('2025-01-25', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 2, 768),
('2025-01-25', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 1, 242),
('2025-01-11', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Delta', 'Ambato', 'Sierra', 2, 1060),
('2025-01-20', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Alfa', 'Quito', 'Sierra', 1, 481),
('2025-01-03', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 762),
('2025-01-07', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 2, 2836),
('2025-01-18', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 2, 5622),
('2025-01-25', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 2, 3756),
('2025-01-05', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 2242),
('2025-01-19', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 1, 1324),
('2025-01-05', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 2, 4744),
('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5378),
('2025-01-14', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 1, 1203),
('2025-01-30', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Gama', 'Cuenca', 'Sierra', 3, 8331),
('2025-01-23', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3728),
('2025-01-29', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 2224),
('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 3, 7470),
('2025-01-11', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2505),
('2025-01-30', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 856),
('2025-01-25', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 2, 344),
('2025-01-17', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 1, 2098),
('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 2, 3924),
('2025-01-29', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 2723),
('2025-01-08', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 2, 4614),
('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2586),
('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 2, 4158),
('2025-01-19', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 3, 4404),
('2025-01-29', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 3, 1026),
('2025-01-27', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 3, 5577),
('2025-01-23', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 1, 2912),
('2025-01-19', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 2428),
('2025-01-12', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 2, 4278),
('2025-01-11', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Delta', 'Ambato', 'Sierra', 2, 5828),
('2025-01-28', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 2, 3524),
('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 3, 7602),
('2025-01-01', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Alfa', 'Quito', 'Sierra', 2, 4860),
('2025-01-21', 'Router AX10', 'Redes', 'NetGo', 'Empresa Alfa', 'Quito', 'Sierra', 1, 2203),
('2025-01-20', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1, 1514),
('2025-01-24', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 3, 2964),
('2025-01-03', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 2, 5558),
('2025-01-13', 'Router AX10', 'Redes', 'NetGo', 'Empresa Alfa', 'Quito', 'Sierra', 3, 3672),
('2025-01-27', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 3, 3690);

INSERT INTO staging.soporte (fecha, producto, categoria, marca, cliente, ciudad, region, ticket_id, motivo, tiempo_respuesta_horas) VALUES
('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 4535, 'Actualización de software', 26),
('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 2148, 'Consulta técnica', 48),
('2025-01-13', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 1420, 'Configuración', 12),
('2025-01-15', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 9637, 'Consulta técnica', 5),
('2025-01-11', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 7580, 'Actualización de software', 39),
('2025-01-11', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 7221, 'Actualización de software', 28),
('2025-01-02', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 6057, 'Actualización de software', 10),
('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 1417, 'Falla de hardware', 40),
('2025-01-17', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 7863, 'Falla de hardware', 28),
('2025-01-20', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 7769, 'Falla de hardware', 46),
('2025-01-24', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 9058, 'Actualización de software', 40),
('2025-01-02', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 1112, 'Consulta técnica', 20),
('2025-01-01', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 4325, 'Falla de hardware', 47),
('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 5940, 'Consulta técnica', 27),
('2025-01-27', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 5895, 'Falla de hardware', 14),
('2025-01-10', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 2510, 'Falla de hardware', 7),
('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 1422, 'Consulta técnica', 13),
('2025-01-18', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 3976, 'Configuración', 24),
('2025-01-17', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 3207, 'Consulta técnica', 27),
('2025-01-22', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Delta', 'Ambato', 'Sierra', 6484, 'Falla de hardware', 10),
('2025-01-26', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 1521, 'Falla de hardware', 7),
('2025-01-08', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 6533, 'Configuración', 20),
('2025-01-26', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Beta', 'Guayaquil', 'Costa', 5844, 'Falla de hardware', 11),
('2025-01-04', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 6467, 'Falla de hardware', 31),
('2025-01-27', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 4523, 'Falla de hardware', 27),
('2025-01-07', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 4747, 'Actualización de software', 25),
('2025-01-27', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Gama', 'Cuenca', 'Sierra', 4641, 'Actualización de software', 33),
('2025-01-07', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Alfa', 'Quito', 'Sierra', 9307, 'Configuración', 36),
('2025-01-09', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Épsilon', 'Manta', 'Costa', 7727, 'Consulta técnica', 6),
('2025-01-05', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 6500, 'Falla de hardware', 12),
('2025-01-23', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 1830, 'Actualización de software', 3),
('2025-01-27', 'Router AX10', 'Redes', 'NetGo', 'Empresa Beta', 'Guayaquil', 'Costa', 8978, 'Configuración', 35),
('2025-01-10', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Gama', 'Cuenca', 'Sierra', 2570, 'Consulta técnica', 38),
('2025-01-06', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Delta', 'Ambato', 'Sierra', 4487, 'Consulta técnica', 12),
('2025-01-18', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 7755, 'Consulta técnica', 45),
('2025-01-12', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 8249, 'Actualización de software', 7),
('2025-01-17', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Delta', 'Ambato', 'Sierra', 7022, 'Actualización de software', 15),
('2025-01-16', 'Router AX10', 'Redes', 'NetGo', 'Empresa Gama', 'Cuenca', 'Sierra', 5319, 'Configuración', 31),
('2025-01-24', 'Impresora Z500', 'Impresoras', 'PrintAll', 'Empresa Beta', 'Guayaquil', 'Costa', 9035, 'Falla de hardware', 47),
('2025-01-23', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Gama', 'Cuenca', 'Sierra', 6058, 'Falla de hardware', 44),
('2025-01-12', 'Router AX10', 'Redes', 'NetGo', 'Empresa Épsilon', 'Manta', 'Costa', 4104, 'Consulta técnica', 19),
('2025-01-26', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Delta', 'Ambato', 'Sierra', 4312, 'Configuración', 33),
('2025-01-19', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Alfa', 'Quito', 'Sierra', 9796, 'Falla de hardware', 46),
('2025-01-06', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Alfa', 'Quito', 'Sierra', 4518, 'Configuración', 7),
('2025-01-02', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Gama', 'Cuenca', 'Sierra', 6387, 'Consulta técnica', 6),
('2025-01-07', 'Servidor Rack M3', 'Servidores', 'DataCore', 'Empresa Épsilon', 'Manta', 'Costa', 6008, 'Falla de hardware', 42),
('2025-01-29', 'Cámara IP C20', 'Vigilancia', 'SafeView', 'Empresa Épsilon', 'Manta', 'Costa', 3828, 'Configuración', 22),
('2025-01-10', 'Router AX10', 'Redes', 'NetGo', 'Empresa Delta', 'Ambato', 'Sierra', 7221, 'Configuración', 19),
('2025-01-21', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Beta', 'Guayaquil', 'Costa', 5495, 'Consulta técnica', 29),
('2025-01-15', 'Scanner S1', 'Digitalización', 'ScanTech', 'Empresa Épsilon', 'Manta', 'Costa', 8871, 'Configuración', 40);

-- ---------------------------------------------------------------------
-- 2. DIMENSIONES
-- ---------------------------------------------------------------------
CREATE TABLE dw.dim_tiempo (
    id_tiempo     INT PRIMARY KEY,          -- formato AAAAMMDD
    fecha         DATE NOT NULL UNIQUE,
    dia           INT,
    mes           INT,
    nombre_mes    VARCHAR(15),
    trimestre     INT,
    anio          INT,
    dia_semana    VARCHAR(15)
);

CREATE TABLE dw.dim_producto (
    id_producto   SERIAL PRIMARY KEY,
    producto      VARCHAR(60) NOT NULL UNIQUE,
    categoria     VARCHAR(40) NOT NULL,
    marca         VARCHAR(40) NOT NULL
);

CREATE TABLE dw.dim_cliente (
    id_cliente    SERIAL PRIMARY KEY,
    cliente       VARCHAR(60) NOT NULL UNIQUE,
    ciudad        VARCHAR(40) NOT NULL,
    region        VARCHAR(20) NOT NULL
);

CREATE TABLE dw.dim_motivo (
    id_motivo     SERIAL PRIMARY KEY,
    motivo        VARCHAR(60) NOT NULL UNIQUE
);

-- Carga de dimensiones (fechas y productos/clientes de AMBOS procesos)
INSERT INTO dw.dim_tiempo
SELECT DISTINCT
    TO_CHAR(f,'YYYYMMDD')::INT,
    f,
    EXTRACT(DAY FROM f)::INT,
    EXTRACT(MONTH FROM f)::INT,
    (ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto',
           'Septiembre','Octubre','Noviembre','Diciembre'])[EXTRACT(MONTH FROM f)::INT],
    EXTRACT(QUARTER FROM f)::INT,
    EXTRACT(YEAR FROM f)::INT,
    (ARRAY['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'])[EXTRACT(DOW FROM f)::INT + 1]
FROM (SELECT fecha AS f FROM staging.pedidos
      UNION SELECT fecha FROM staging.soporte) t;

INSERT INTO dw.dim_producto (producto, categoria, marca)
SELECT DISTINCT producto, categoria, marca FROM staging.pedidos
UNION
SELECT DISTINCT producto, categoria, marca FROM staging.soporte
ORDER BY 1;

INSERT INTO dw.dim_cliente (cliente, ciudad, region)
SELECT DISTINCT cliente, ciudad, region FROM staging.pedidos
UNION
SELECT DISTINCT cliente, ciudad, region FROM staging.soporte
ORDER BY 1;

INSERT INTO dw.dim_motivo (motivo)
SELECT DISTINCT motivo FROM staging.soporte ORDER BY 1;

-- ---------------------------------------------------------------------
-- 3. TABLAS DE HECHOS
-- ---------------------------------------------------------------------
CREATE TABLE dw.fact_pedidos (
    id_pedido     SERIAL PRIMARY KEY,
    id_tiempo     INT NOT NULL REFERENCES dw.dim_tiempo(id_tiempo),
    id_producto   INT NOT NULL REFERENCES dw.dim_producto(id_producto),
    id_cliente    INT NOT NULL REFERENCES dw.dim_cliente(id_cliente),
    cantidad      INT NOT NULL,
    total_pedido  NUMERIC(12,2) NOT NULL
);

CREATE TABLE dw.fact_soporte (
    id_soporte             SERIAL PRIMARY KEY,   -- clave subrogada (ticket_id se repite: 7221)
    id_tiempo              INT NOT NULL REFERENCES dw.dim_tiempo(id_tiempo),
    id_producto            INT NOT NULL REFERENCES dw.dim_producto(id_producto),
    id_cliente             INT NOT NULL REFERENCES dw.dim_cliente(id_cliente),
    id_motivo              INT NOT NULL REFERENCES dw.dim_motivo(id_motivo),
    ticket_id              INT,                  -- dimensión degenerada
    tiempo_respuesta_horas INT NOT NULL
);

INSERT INTO dw.fact_pedidos (id_tiempo, id_producto, id_cliente, cantidad, total_pedido)
SELECT t.id_tiempo, p.id_producto, c.id_cliente, s.cantidad, s.total_pedido
FROM staging.pedidos s
JOIN dw.dim_tiempo   t ON t.fecha    = s.fecha
JOIN dw.dim_producto p ON p.producto = s.producto
JOIN dw.dim_cliente  c ON c.cliente  = s.cliente;

INSERT INTO dw.fact_soporte (id_tiempo, id_producto, id_cliente, id_motivo, ticket_id, tiempo_respuesta_horas)
SELECT t.id_tiempo, p.id_producto, c.id_cliente, m.id_motivo, s.ticket_id, s.tiempo_respuesta_horas
FROM staging.soporte s
JOIN dw.dim_tiempo   t ON t.fecha    = s.fecha
JOIN dw.dim_producto p ON p.producto = s.producto
JOIN dw.dim_cliente  c ON c.cliente  = s.cliente
JOIN dw.dim_motivo   m ON m.motivo   = s.motivo;

-- ---------------------------------------------------------------------
-- 4. VERIFICACIÓN (debe dar 50 y 50)
-- ---------------------------------------------------------------------
SELECT 'fact_pedidos' AS tabla, COUNT(*) FROM dw.fact_pedidos
UNION ALL SELECT 'fact_soporte', COUNT(*) FROM dw.fact_soporte;

-- ---------------------------------------------------------------------
-- 5. CONSULTAS DE LAS 4 PREGUNTAS (para comprobar antes de Power BI)
-- ---------------------------------------------------------------------
-- 1) Productos y categorías más vendidos por ciudad
SELECT c.ciudad, p.categoria, p.producto, SUM(f.cantidad) AS unidades, SUM(f.total_pedido) AS ventas
FROM dw.fact_pedidos f
JOIN dw.dim_producto p USING (id_producto)
JOIN dw.dim_cliente  c USING (id_cliente)
GROUP BY c.ciudad, p.categoria, p.producto
ORDER BY c.ciudad, unidades DESC;

-- 2) Clientes que más compran por ciudad
SELECT c.ciudad, c.cliente, SUM(f.cantidad) AS unidades, SUM(f.total_pedido) AS ventas
FROM dw.fact_pedidos f JOIN dw.dim_cliente c USING (id_cliente)
GROUP BY c.ciudad, c.cliente ORDER BY unidades DESC;

-- 3) Productos y categorías con más tickets
SELECT p.categoria, p.producto, COUNT(*) AS tickets, ROUND(AVG(f.tiempo_respuesta_horas),1) AS horas_prom
FROM dw.fact_soporte f JOIN dw.dim_producto p USING (id_producto)
GROUP BY p.categoria, p.producto ORDER BY tickets DESC;

-- 4) Clientes con más tickets
SELECT c.cliente, c.ciudad, COUNT(*) AS tickets
FROM dw.fact_soporte f JOIN dw.dim_cliente c USING (id_cliente)
GROUP BY c.cliente, c.ciudad ORDER BY tickets DESC;

-- Análisis cruzado (gracias a las dimensiones compartidas): ventas vs tickets por producto
SELECT p.producto,
       (SELECT SUM(cantidad) FROM dw.fact_pedidos fp WHERE fp.id_producto = p.id_producto) AS unidades_vendidas,
       (SELECT COUNT(*)      FROM dw.fact_soporte fs WHERE fs.id_producto = p.id_producto) AS tickets
FROM dw.dim_producto p ORDER BY tickets DESC;
