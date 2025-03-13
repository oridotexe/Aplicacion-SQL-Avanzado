-------------------------------------------
--               Parte II                --
-------------------------------------------

-- Consulta 1
SELECT 
    V.VENDEDOR AS "VENDEDOR",
    CLI.NOMBRE_CL AS "CLIENTE",
    COALESCE(SUM(F.TOTAL_FACTURA), 0) AS "FACTURADO",
    COALESCE(SUM(COB.VALOR_COBRADO), 0) AS "COBRADO",
    CASE 
        WHEN COALESCE(SUM(F.TOTAL_FACTURA), 0) - COALESCE(SUM(COB.VALOR_COBRADO), 0) = 0 THEN 'DEUDA SALDADA'
        ELSE TO_CHAR(COALESCE(SUM(F.TOTAL_FACTURA), 0) - COALESCE(SUM(COB.VALOR_COBRADO), 0))
    END AS "DEUDA PENDIENTE"
FROM VENDEDORES V
JOIN FACTURAS F ON (V.ID_VENDEDOR = F.FK_VENDEDORES)
JOIN CLIENTES CLI ON (F.FK_CLIENTES = CLI.ID_CLIENTE) 
LEFT JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
GROUP BY V.VENDEDOR, CLI.NOMBRE_CL;

-- Consulta 2
SELECT 
    EXTRACT (YEAR FROM FECHA_FACTURA) AS "AÑO",
    COUNT(ID_FACTURA) AS "CANTIDAD DE FACTURAS"
FROM FACTURAS
GROUP BY EXTRACT(YEAR FROM FECHA_FACTURA)
HAVING COUNT(ID_FACTURA) > (
    SELECT AVG(COUNT(ID_FACTURA))
    FROM FACTURAS
    GROUP BY EXTRACT(YEAR FROM FECHA_FACTURA)
);

-- Consulta 3 (10 en pdf)
SELECT 
    CN.CANAL_VENTA AS "CANAL DE VENTA",
    COUNT(DISTINCT SERV.ID_SERVICIO) AS "CANTIDAD DE SERVICIOS",
    COUNT(DISTINCT F.ID_FACTURA) AS "CANTIDAD DE FACTURAS",
    COALESCE(SUM(COB.VALOR_COBRADO), 0) AS "MONTO TOTAL COBRADO"
FROM FACTURAS F
JOIN CLIENTES CLI ON (F.FK_CLIENTES = CLI.ID_CLIENTE) 
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN SERVICIOS SERV ON (CLI.ID_CLIENTE = SERV.FK_CLIENTES)
LEFT JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
WHERE CLI.PAIS_CL = 'ESPA�A'
    AND EXTRACT(YEAR FROM SERV.FECHA_INICIO_SERV) = 2017
    AND EXTRACT(MONTH FROM SERV.FECHA_INICIO_SERV) BETWEEN 4 AND 6
GROUP BY CN.CANAL_VENTA
ORDER BY "CANTIDAD DE SERVICIOS" ASC;

-- Consulta 4 (11 en pdf)
SELECT 
    CN.CANAL_VENTA AS "CANAL DE VENTA",
    COUNT(DISTINCT F.ID_FACTURA) AS "CANTIDAD DE FACTURAS",
    AVG(F.TOTAL_FACTURA) AS "MONTO TOTAL PROMEDIO"
FROM FACTURAS F
JOIN CLIENTES CLI ON (F.FK_CLIENTES = CLI.ID_CLIENTE)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN SERVICIOS SERV ON (SERV.FK_CLIENTES = CLI.ID_CLIENTE)
WHERE CLI.PAIS_CL = 'ARGENTINA'
AND SERV.FECHA_INICIO_SERV BETWEEN TO_DATE('2018-10-01', 'YYYY-MM-DD') 
                                AND TO_DATE('2019-03-31', 'YYYY-MM-DD')
GROUP BY CN.CANAL_VENTA;

-- Consulta 5 (12 en pdf)
drop table HISTORICO_SERVICIOS cascade constraints;

CREATE TABLE HISTORICO_SERVICIOS(
    AÑO NUMBER(4) NOT NULL,
    TRIMESTRE NUMBER(1) NOT NULL,
    CANTIDAD_SERVICIOS NUMBER NOT NULL,
    MONTO_TOTAL_SERVICIO NUMBER(10, 2) NOT NULL,
    CANTIDAD_FACTURAS NUMBER NOT NULL,
    MONTO_TOTAL_FACTURADO NUMBER(10, 2) NOT NULL,
    MONTO_TOTAL_COBRADO NUMBER(10, 2) NOT NULL,
    MONTO_TOTAL_POR_COBRAR NUMBER(10, 2) NOT NULL,
    PORCENTAJE_COBRADO NUMBER(5, 2) NOT NULL
);


INSERT INTO HISTORICO_SERVICIOS (
    AÑO, 
    TRIMESTRE, 
    CANTIDAD_SERVICIOS, 
    MONTO_TOTAL_SERVICIO, 
    CANTIDAD_FACTURAS,
    MONTO_TOTAL_FACTURADO,
    MONTO_TOTAL_COBRADO, 
    MONTO_TOTAL_POR_COBRAR, 
    PORCENTAJE_COBRADO
)

SELECT
    COALESCE(SERV.AÑO, F.AÑO, COB.AÑO) AS AÑO,
    COALESCE(SERV.TRIMESTRE, F.TRIMESTRE, COB.TRIMESTRE) AS TRIMESTRE,
    COALESCE(SERV.CANTIDAD_SERVICIOS, 0) AS CANTIDAD_SERVICIOS,
    COALESCE(SERV.MONTO_TOTAL_SERVICIO, 0) AS MONTO_TOTAL_SERVICIO,
    COALESCE(F.CANTIDAD_FACTURAS, 0) AS CANTIDAD_FACTURAS,
    COALESCE(F.MONTO_TOTAL_FACTURADO, 0) AS MONTO_TOTAL_FACTURADO,
    COALESCE(COB.MONTO_TOTAL_COBRADO, 0) AS MONTO_TOTAL_COBRADO,
    COALESCE(F.MONTO_TOTAL_FACTURADO, 0) - COALESCE(COB.MONTO_TOTAL_COBRADO, 0) AS MONTO_TOTAL_POR_COBRAR,
    CASE
        WHEN COALESCE(F.MONTO_TOTAL_FACTURADO, 0) > 0
        THEN (COALESCE(COB.MONTO_TOTAL_COBRADO, 0) / COALESCE(F.MONTO_TOTAL_FACTURADO, 1)) * 100
        ELSE 0
    END AS PORCENTAJE_COBRADO

FROM
    (SELECT
        EXTRACT(YEAR FROM SERV.FECHA_INICIO_SERV) AS AÑO,
        CEIL(EXTRACT(MONTH FROM SERV.FECHA_INICIO_SERV) / 3) AS TRIMESTRE,
        COUNT(DISTINCT SERV.ID_SERVICIO) AS CANTIDAD_SERVICIOS,
        SUM(SERV.COSTO_SERVICIO) AS MONTO_TOTAL_SERVICIO
    FROM SERVICIOS SERV
    GROUP BY EXTRACT(YEAR FROM SERV.FECHA_INICIO_SERV), CEIL(EXTRACT(MONTH FROM SERV.FECHA_INICIO_SERV) / 3)
    ) SERV

FULL OUTER JOIN
    (SELECT
        EXTRACT(YEAR FROM F.FECHA_FACTURA) AS AÑO,
        CEIL(EXTRACT(MONTH FROM F.FECHA_FACTURA) / 3) AS TRIMESTRE,
        COUNT(DISTINCT F.ID_FACTURA) AS CANTIDAD_FACTURAS,
        SUM(F.TOTAL_FACTURA) AS MONTO_TOTAL_FACTURADO
    FROM FACTURAS F
    GROUP BY EXTRACT(YEAR FROM F.FECHA_FACTURA), CEIL(EXTRACT(MONTH FROM F.FECHA_FACTURA) / 3)
    ) F
ON SERV.AÑO = F.AÑO AND SERV.TRIMESTRE = F.TRIMESTRE

FULL OUTER JOIN
    (SELECT
        EXTRACT(YEAR FROM COB.FECHA_COBRO) AS AÑO,
        CEIL(EXTRACT(MONTH FROM COB.FECHA_COBRO) / 3) AS TRIMESTRE,
        COALESCE(SUM(COB.VALOR_COBRADO), 0) AS MONTO_TOTAL_COBRADO
    FROM COBRANZAS COB
    GROUP BY EXTRACT(YEAR FROM COB.FECHA_COBRO), CEIL(EXTRACT(MONTH FROM COB.FECHA_COBRO) / 3)
    ) COB
ON COALESCE(SERV.AÑO, F.AÑO) = COB.AÑO AND COALESCE(SERV.TRIMESTRE, F.TRIMESTRE) = COB.TRIMESTRE;

-- Constraint 6 (13 en pdf)
ALTER TABLE historico_servicios
ADD CONSTRAINT pk_historico_servicios PRIMARY KEY (año, trimestre);

-- Vista 7 (14 en pdf)
CREATE VIEW COSTOS_SERVICIOS AS
    SELECT 
        EXTRACT (YEAR FROM SERV.fecha_inicio_serv) AS año,
        SUC.SUCURSAL AS "SUCURSAL",
        SERV.SERVICIO "SERVICIO",
        SERV.FECHA_INICIO_SERV "FECHA INICIO SERVICIO",
        SERV.FECHA_FIN_SERV "FECHA FIN SERVICIO",
        SERV.COSTO_SERVICIO "COSTO DEL SERVICIO",
        ROUND((SERV.COSTO_SERVICIO /
            (CASE 
                WHEN SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV = 0 THEN 8
                ELSE (SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV) * 8
                END)
         ), 5) AS COSTO_HORA,
        CLI.NOMBRE_CL
FROM SERVICIOS SERV
JOIN SUCURSALES SUC ON (SERV.FK_SUCURSALES = SUC.ID_SUCURSAL)
JOIN CLIENTES CLI ON (SERV.FK_CLIENTES = CLI.ID_CLIENTE)
WITH READ ONLY;

-- Consulta 8 (15 en pdf)
WITH COSTO_HORA_HISTORICO AS (
    SELECT AÑO, SUM(MONTO_TOTAL_SERVICIO)/(SUM(CANTIDAD_SERVICIOS) * 90 * 8) AS COSTO_HORA
    FROM HISTORICO_SERVICIOS GROUP BY AÑO
)
SELECT
    CO.AÑO,
    CO.SUCURSAL,
    H.COSTO_HORA AS "COSTO/HORA HISTORICO",
    AVG(CO.COSTO_HORA) AS "COSTO/HORA VISTA",
    ABS((H.COSTO_HORA - AVG(CO.COSTO_HORA))) AS "DIFERENCIA"
FROM COSTOS_SERVICIOS CO
JOIN COSTO_HORA_HISTORICO H ON CO.AÑO = H.AÑO
GROUP BY CO.AÑO, CO.SUCURSAL, H.COSTO_HORA
ORDER BY CO.AÑO, CO.SUCURSAL;

-- Consulta 9 (16 en pdf)
SELECT 
    SUCURSAL,
    AVG(COSTO_HORA) AS "COSTO PROMEDIO POR HORA"
FROM COSTOS_SERVICIOS
GROUP BY SUCURSAL;

-- Consulta 10 (17 en pdf)
SELECT COUNT(*) AS "TOTAL DE SUCURSALES"
FROM SUCURSALES SUC
WHERE SUC.ID_SUCURSAL IN (
    SELECT DISTINCT SERV.FK_SUCURSALES
    FROM SERVICIOS SERV
    JOIN COBRANZAS COB ON SERV.FK_CLIENTES = COB.FK_CLIENTES 
);

-- Consulta 11 (18 en pdf)
SELECT 
    V.VENDEDOR AS "VENDEDOR",
    SUM(F.TOTAL_FACTURA) AS "MONTO TOTAL FACTURADO",
    SUM(F.TOTAL_FACTURA) * 0.10 AS "COMISION"
FROM VENDEDORES V
JOIN FACTURAS F ON V.ID_VENDEDOR = F.FK_VENDEDORES
JOIN CLIENTES CLI ON F.FK_CLIENTES = CLI.ID_CLIENTE
WHERE CLI.CIUDAD_CL = 'CARACAS'
GROUP BY V.VENDEDOR
HAVING SUM(F.TOTAL_FACTURA) > (
    SELECT AVG(TOTAL_FACTURADO)
    FROM (
        SELECT SUM(F.TOTAL_FACTURA) AS TOTAL_FACTURADO
        FROM FACTURAS F
        JOIN CLIENTES CLI ON F.FK_CLIENTES = CLI.ID_CLIENTE
        WHERE CLI.CIUDAD_CL = 'CARACAS'
        GROUP BY F.FK_VENDEDORES
    )
);

-- Consulta 12 (19 en pdf)
SELECT COUNT(*) AS VENDEDOR_SIN_FACTURA
FROM VENDEDORES VER
WHERE VER.ID_VENDEDOR NOT IN(
    SELECT DISTINCT FK_VENDEDORES FROM FACTURAS
);

-- Consulta 13 (20 en pdf)
SELECT 
    CN.CANAL_VENTA AS "CANAL_VENTA", 
    CLI.PAIS_CL AS "PAIS", 
    SUM(F.IVA) AS "MONTO_TOTAL_IVA"
FROM (
    SELECT 
        F.ID_FACTURA, 
        F.FK_CANALES, 
        F.FK_CLIENTES, 
        F.IVA, 
        COALESCE(SUM(COB.VALOR_COBRADO), 0) AS TOTAL_COBRADO
    FROM FACTURAS F
    LEFT JOIN COBRANZAS COB ON F.ID_FACTURA = COB.FK_FACTURAS
    WHERE EXTRACT(YEAR FROM F.FECHA_FACTURA) = 2019
    GROUP BY F.ID_FACTURA, F.FK_CANALES, F.FK_CLIENTES, F.IVA
    HAVING COALESCE(SUM(COB.VALOR_COBRADO), 0) < F.IVA
) F
JOIN CLIENTES CLI ON F.FK_CLIENTES = CLI.ID_CLIENTE
JOIN CANALES CN ON F.FK_CANALES = CN.ID_CANAL
GROUP BY CN.CANAL_VENTA, CLI.PAIS_CL;

-- Consulta 14 (21 en pdf)
drop table VENTA_SUCURSAL cascade constraints;

CREATE TABLE VENTA_SUCURSAL AS
SELECT 
    SUC.ID_SUCURSAL AS "ID_SUCURSAL",
    SUC.SUCURSAL AS "SUCURSAL",
    SUM(F.VR_ANTES_IVA) AS "MONTO_TOTAL_SIN_IVA",
    SUM(F.TOTAL_FACTURA) * 0.15 AS "COMISION"
FROM FACTURAS F
JOIN CLIENTES CLI ON F.FK_CLIENTES = CLI.ID_CLIENTE
JOIN SERVICIOS SERV ON SERV.FK_CLIENTES = CLI.ID_CLIENTE
JOIN SUCURSALES SUC ON SERV.FK_SUCURSALES = SUC.ID_SUCURSAL
WHERE (SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV) <= (
    SELECT AVG(SERV.FECHA_FIN_SERV - SERV.FECHA_INICIO_SERV)
    FROM SERVICIOS SERV
    WHERE SERV.FK_SUCURSALES = SUC.ID_SUCURSAL
)
GROUP BY SUC.ID_SUCURSAL, SUC.SUCURSAL;

-- Consulta 15 (22 en pdf)
SELECT 
    CLI.NOMBRE_CL AS "NOMBRE_CLIENTE",
    F.ID_FACTURA AS "ID_FACTURA",
    COALESCE (COB.ID_COBRANZA, 'SIN COBRANZA') AS "ID_COBRANZA"
FROM FACTURAS F
JOIN CLIENTES CLI ON F.FK_CLIENTES = CLI.ID_CLIENTE
LEFT JOIN COBRANZAS COB ON F.ID_FACTURA = COB.FK_FACTURAS
ORDER BY CLI.NOMBRE_CL, F.ID_FACTURA;
