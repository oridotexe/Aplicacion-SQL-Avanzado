-- Parte III

-- Consulta 1
-- Tablas: Servicios, Sucursales y Clientes

SELECT SUC.SUCURSAL, CLI.NOMBRE_CL, SUM(SERV.COSTO_SERVICIO) SUBTOTALES
FROM SUCURSALES SUC
JOIN SERVICIOS SERV ON (SUC.ID_SUCURSAL = SERV.FK_SUCURSALES)
JOIN CLIENTES CLI ON (SERV.FK_CLIENTES = CLI.ID_CLIENTE)
WHERE CLI.PAIS_CL = 'CHILE'
GROUP BY ROLLUP (CLI.NOMBRE_CL, SUC.SUCURSAL);

-- Consulta 2
SELECT CLI.NOMBRE_CL, CN.CANAL_VENTA, AVG(COB.VALOR_COBRADO) PROMEDIO
FROM CLIENTES CLI
JOIN FACTURAS F ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
WHERE F.FECHA_FACTURA BETWEEN '01/04/2019' AND '30/06/2019'
GROUP BY CUBE (CLI.NOMBRE_CL, CN.CANAL_VENTA)
ORDER BY CLI.NOMBRE_CL;

-- SELECT CLI.NOMBRE_CL, CN.CANAL_VENTA, AVG(COB.VALOR_COBRADO), SUM(COB.VALOR_COBRADO)
-- FROM CLIENTES CLI
-- JOIN FACTURAS F ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
-- JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
-- JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
-- WHERE F.FECHA_FACTURA BETWEEN '01/04/2019' AND '30/06/2019'
-- GROUP BY CUBE (CLI.NOMBRE_CL, CN.CANAL_VENTA)
-- ORDER BY CLI.NOMBRE_CL;

-- Consulta 3
-- Se necesita conocer en una sola consulta el promedio de los montos facturados desagregados por
-- dos grupos (agrupamientos): 1) nombre de cliente y nombre del canal de venta, 2) nombre de
-- cliente y nombre de vendedor con los subtotales respectivos para el año que más se facturo.

SELECT CLI.NOMBRE_CL, CN.CANAL_VENTA, V.VENDEDOR, AVG(F.TOTAL_FACTURA)
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
END;

