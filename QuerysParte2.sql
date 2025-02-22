-- Parte II

-- Consulta 1
-- Tablas: Vendedores, Clientes, Facturas, Cobranzas

SELECT 
    v.vendedor AS "Vendedor",
    c.nombre_cl AS "Cliente",
    COALESCE(SUM(f.total_factura), 0) AS "Facturado",
    COALESCE(SUM(cb.valor_cobrado), 0) AS "Cobrado",
    CASE 
        WHEN COALESCE(SUM(f.total_factura), 0) - COALESCE(SUM(cb.valor_cobrado), 0) = 0 THEN 'Deuda Saldada'
        ELSE TO_CHAR(COALESCE(SUM(f.total_factura), 0) - COALESCE(SUM(cb.valor_cobrado), 0))
    END AS "Deuda Pendiente"
FROM vendedores v
JOIN  facturas f ON (v.id_vendedor = f.fk_vendedores)
JOIN clientes c ON (f.fk_clientes = c.id_cliente)
LEFT JOIN cobranzas cb ON (f.id_factura = cb.fk_facturas)
GROUP BY v.vendedor, c.nombre_cl;

-- Consulta 2
-- Tablas: Facturas

SELECT 
    EXTRACT(YEAR FROM fecha_factura) AS "Año",
    COUNT(id_factura) AS "Cantidad de Facturas"
FROM facturas
GROUP BY EXTRACT(YEAR FROM fecha_factura)
HAVING COUNT(id_factura) > (
    SELECT AVG(COUNT(id_factura))
    FROM facturas
    GROUP BY EXTRACT(YEAR FROM fecha_factura)
);

-- Consulta 3
-- Tablas: Facturas, Clientes, Canales, Servicios,Cobranzas

SELECT 
    c.canal_venta,
    COUNT(DISTINCT s.id_servicio) AS cantidad_servicios,
    COUNT(DISTINCT f.id_factura) AS cantidad_facturas,
    COALESCE(SUM(cb.valor_cobrado), 0) AS monto_total_cobrado
FROM facturas f
JOIN clientes cl ON (f.fk_clientes = cl.id_cliente)
JOIN canales c ON (f.fk_canales = c.id_canal)
JOIN servicios s ON (s.fk_clientes = cl.id_cliente)
LEFT JOIN cobranzas cb ON (cb.fk_facturas = f.id_factura)
WHERE cl.pais_cl = 'ESPA�A'
AND EXTRACT(YEAR FROM s.fecha_inicio_serv) = 2017
AND EXTRACT(MONTH FROM s.fecha_inicio_serv) BETWEEN 4 AND 6
GROUP BY c.canal_venta
ORDER BY cantidad_servicios ASC;

-- Consulta 4
-- Tablas: Facturas, Clientes, Canales, Servicios
-- En los datos no hay clientes de argentina entonces para probarlo tiene que modificar un cliente colocandolo en argentina

SELECT 
    c.canal_venta,
    COUNT(DISTINCT f.id_factura) AS cantidad_facturas,
    AVG(f.total_factura) AS monto_promedio_facturado
FROM facturas f
JOIN clientes cl ON f.fk_clientes = cl.id_cliente
JOIN canales c ON f.fk_canales = c.id_canal
JOIN servicios s ON s.fk_clientes = cl.id_cliente
WHERE cl.pais_cl = 'ARGENTINA'
AND s.fecha_inicio_serv BETWEEN TO_DATE('2018-10-01', 'YYYY-MM-DD') 
                           AND TO_DATE('2019-03-31', 'YYYY-MM-DD')
GROUP BY c.canal_venta
ORDER BY cantidad_facturas ASC;


-- 5 Crear tabla hitorico_servicio

CREATE TABLE historico_servicios (
    año NUMBER(4) NOT NULL,
    trimestre NUMBER(1) NOT NULL,
    cantidad_servicios NUMBER NOT NULL,
    monto_total_servicio NUMBER(10, 2) NOT NULL,
    cantidad_facturas NUMBER NOT NULL,
    monto_total_facturado NUMBER(10, 2) NOT NULL,
    monto_total_cobrado NUMBER(10, 2) NOT NULL,
    monto_total_por_cobrar NUMBER(10, 2) NOT NULL,
    porcentaje_cobrado NUMBER(5, 2) NOT NULL
);

-- 6 Constraint
ALTER TABLE historico_servicios
ADD CONSTRAINT pk_historico_servicios PRIMARY KEY (año, trimestre);

-- 7 View 
--DROP VIEW COSTOS_SERVICIOS;

CREATE VIEW COSTOS_SERVICIOS AS
    SELECT 
        EXTRACT (YEAR FROM SERV.fecha_inicio_serv) AS año,
        SUC.SUCURSAL,
        SERV.SERVICIO,
        SERV.FECHA_INICIO_SERV,
        SERV.FECHA_FIN_SERV,
        SERV.COSTO_SERVICIO,
        ROUND(SERV.COSTO_SERVICIO /
            (CASE 
                WHEN SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV = 0 THEN 8
                ELSE (SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV) * 8
                END),
         5) AS COSTO_HORA,
        CLI.NOMBRE_CL
FROM SERVICIOS SERV
JOIN SUCURSALES SUC ON SERV.FK_SUCURSALES = SUC.ID_SUCURSAL
JOIN CLIENTES CLI ON SERV.FK_CLIENTES = CLI.ID_CLIENTE;

--SELECT * FROM COSTOS_SERVICIOS; 
