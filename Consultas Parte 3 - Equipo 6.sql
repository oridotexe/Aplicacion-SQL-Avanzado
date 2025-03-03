-------------------------------------------
--              Parte III                --
-------------------------------------------


-- Consulta 1
SELECT 
    SUC.SUCURSAL,
    CLI.NOMBRE_CL, 
    SUM(SERV.COSTO_SERVICIO) AS "SUBTOTALES"
FROM SUCURSALES SUC
JOIN SERVICIOS SERV ON (SUC.ID_SUCURSAL = SERV.FK_SUCURSALES)
JOIN CLIENTES CLI ON (SERV.FK_CLIENTES = CLI.ID_CLIENTE)
WHERE CLI.PAIS_CL = 'ARGENTINA'
GROUP BY ROLLUP (CLI.NOMBRE_CL, SUC.SUCURSAL);

-- Consulta 2
SELECT 
    CLI.NOMBRE_CL, 
    CN.CANAL_VENTA, 
    AVG(COB.VALOR_COBRADO) AS "PROMEDIO"
FROM CLIENTES CLI
JOIN FACTURAS F ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
WHERE EXTRACT(YEAR FROM F.FECHA_FACTURA) = 2019
    AND EXTRACT(MONTH FROM F.FECHA_FACTURA) BETWEEN 4 AND 6
GROUP BY CUBE (CLI.NOMBRE_CL, CN.CANAL_VENTA)
ORDER BY CLI.NOMBRE_CL;

-- Consulta 3
SELECT 
    CLI.NOMBRE_CL, 
    CN.CANAL_VENTA, 
    V.VENDEDOR, 
    AVG(F.TOTAL_FACTURA)
FROM CLIENTES CLI
JOIN FACTURAS F ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN VENDEDORES V ON (F.FK_VENDEDORES = V.ID_VENDEDOR)
WHERE EXTRACT(YEAR FROM F.fecha_factura) = ( 
        SELECT EXTRACT(YEAR FROM fecha_factura) years
        FROM FACTURAS
        GROUP BY EXTRACT(YEAR FROM fecha_factura)
        HAVING COUNT(*) = (
            SELECT MAX(num_facturas)
            FROM (
                SELECT COUNT(*) AS num_facturas
                FROM FACTURAS
                GROUP BY EXTRACT(YEAR FROM fecha_factura)
            )
        )
) 
GROUP BY GROUPING SETS
    (
        (CLI.NOMBRE_CL, CN.CANAL_VENTA), 
        (CLI.NOMBRE_CL, V.VENDEDOR), 
        ()
)
ORDER BY CASE 
        WHEN GROUPING(CLI.NOMBRE_CL) = 1 THEN 3 
        WHEN GROUPING(CN.CANAL_VENTA) = 1 THEN 2 
        ELSE 1 
END, CLI.NOMBRE_CL;

-- Consulta 4
WITH FACTURAS_MAX_AÑO AS (
    SELECT * 
    FROM FACTURAS 
    WHERE EXTRACT(YEAR FROM FECHA_FACTURA) = ( 
        SELECT EXTRACT(YEAR FROM FECHA_FACTURA)
        FROM FACTURAS
        GROUP BY EXTRACT(YEAR FROM FECHA_FACTURA)
        HAVING COUNT(*) = (
            SELECT MAX(num_facturas)
            FROM (
                SELECT COUNT(*) AS num_facturas
                FROM FACTURAS
                GROUP BY EXTRACT(YEAR FROM FECHA_FACTURA)
            ) sub
        )
    )
)

SELECT CLI.NOMBRE_CL, CN.CANAL_VENTA, NULL AS VENDEDOR, AVG(F.TOTAL_FACTURA) AS PROMEDIO
FROM CLIENTES CLI
JOIN FACTURAS_MAX_AÑO F ON CLI.ID_CLIENTE = F.FK_CLIENTES
JOIN CANALES CN ON F.FK_CANALES = CN.ID_CANAL
JOIN VENDEDORES V ON F.FK_VENDEDORES = V.ID_VENDEDOR
GROUP BY CLI.NOMBRE_CL, CN.CANAL_VENTA

UNION ALL

SELECT CLI.NOMBRE_CL, NULL AS CANAL_VENTA, V.VENDEDOR, AVG(F.TOTAL_FACTURA) AS PROMEDIO
FROM CLIENTES CLI
JOIN FACTURAS_MAX_AÑO F ON CLI.ID_CLIENTE = F.FK_CLIENTES
JOIN CANALES CN ON F.FK_CANALES = CN.ID_CANAL
JOIN VENDEDORES V ON F.FK_VENDEDORES = V.ID_VENDEDOR
GROUP BY CLI.NOMBRE_CL, V.VENDEDOR

UNION ALL

SELECT NULL AS NOMBRE_CL, NULL AS CANAL_VENTA, NULL AS VENDEDOR, AVG(F.TOTAL_FACTURA) AS PROMEDIO
FROM FACTURAS_MAX_AÑO F;
