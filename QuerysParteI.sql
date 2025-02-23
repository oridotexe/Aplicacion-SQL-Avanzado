-- Parte I

-- Consulta 1
-- Tablas: Factura, cliente y vendedor

SELECT F.id_factura, F.fecha_factura, F.vr_antes_iva
FROM FACTURAS F 
JOIN VENDEDORES V ON (V.ID_VENDEDOR = F.FK_VENDEDORES)
JOIN CLIENTES CLI ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
WHERE V.VENDEDOR = UPPER('Pablo Marmol') AND CLI.CIUDAD_CL = UPPER('Medellin');

-- Consulta 2
-- Tablas: Cliente

SELECT
    'El Cliente ' ||  
    INITCAP(SUBSTR(NOMBRE_CL, INSTR(NOMBRE_CL, ' ') + 1)) || 
    ' ' || 
    INITCAP(SUBSTR(NOMBRE_CL, 1, INSTR(NOMBRE_CL, ' ') - 1)) ||
    CASE SEGMENTO_CL
        WHEN 'HOMBRE' THEN ' es un '
        ELSE ' es una ' 
    END || 
    INITCAP (SEGMENTO_CL) ||
    ' que reside en la ciudad ' ||
    INITCAP(CIUDAD_CL) ||
    ' del País ' ||
    INITCAP(PAIS_CL) AS "Informacion Clientes"
FROM CLIENTES
WHERE SEGMENTO_CL = 'HOMBRE' OR SEGMENTO_CL = 'MUJER';

-- Consulta 3
-- Tablas: Vendedores, Facturas, Canales

SELECT V.VENDEDOR, F.FECHA_FACTURA, F.TOTAL_FACTURA, CANALES.CANAL_VENTA
FROM FACTURAS F
JOIN VENDEDORES V ON (V.ID_VENDEDOR = F.FK_VENDEDORES)
JOIN CANALES ON (CANALES.ID_CANAL = F.FK_CANALES)
ORDER BY V.VENDEDOR ASC, CANALES.CANAL_VENTA DESC;

-- Consulta 4
-- Tablas: Sucursales, Clientes, Servicios, Cobranzas

SELECT SUC.SUCURSAL, SERV.ID_SERVICIO, SERV.COSTO_SERVICIO, CLI.NOMBRE_CL
FROM SERVICIOS SERV
JOIN SUCURSALES SUC ON (SERV.FK_SUCURSALES = SUC.ID_SUCURSAL)
JOIN CLIENTES CLI ON (SERV.FK_CLIENTES = CLI.ID_CLIENTE)
WHERE CLI.SEGMENTO_CL = 'HOMBRE' AND (TO_DATE(SERV.FECHA_FIN_SERV) - TO_DATE(FECHA_INICIO_SERV)) > 10;

-- Consulta 5
-- Tablas: Clientes, Facturas

SELECT F.ID_FACTURA, F.TOTAL_FACTURA, CASE (CLI.SEGMENTO_CL) 
    WHEN 'MUJER' THEN
        UPPER('segmento ' || CLI.SEGMENTO_CL || ' reside en el país ' || CLI.PAIS_CL)
    WHEN 'HOMBRE' THEN 
        UPPER('segmento ' || CLI.SEGMENTO_CL || ' reside en la ciudad ' || CLI.CIUDAD_CL)
    END Mensaje
FROM FACTURAS F
JOIN CLIENTES CLI ON (F.FK_CLIENTES = CLI.ID_CLIENTE)
WHERE 
    CLI.PAIS_CL = 'PER�' AND
    (CLI.SEGMENTO_CL = 'HOMBRE' OR CLI.SEGMENTO_CL = 'MUJER');

-- Consulta 6
SELECT CLI.NOMBRE_CL, F.FECHA_FACTURA, F.TOTAL_FACTURA, SUM(COB.VALOR_COBRADO)
FROM CLIENTES CLI
JOIN FACTURAS F ON (CLI.ID_CLIENTE = F.FK_CLIENTES)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
WHERE CLI.PAIS_CL = 'ESPA�A' AND CN.CANAL_VENTA = 'PUNTOS DE VENTAS'
GROUP BY CLI.NOMBRE_CL, F.FECHA_FACTURA, F.TOTAL_FACTURA
HAVING F.TOTAL_FACTURA = SUM(COB.VALOR_COBRADO);

-- Consulta 7

SELECT V.VENDEDOR, CN.CANAL_VENTA, F.ID_FACTURA, F.TOTAL_FACTURA, COB.VALOR_COBRADO, 
    ROUND((COB.VALOR_COBRADO/F.TOTAL_FACTURA)*100 , 2) AS Porcentaje, 
    CASE 
        WHEN (COB.VALOR_COBRADO / F.TOTAL_FACTURA) = 1 THEN 'Cobro Total'
        ELSE 'Cobro Parcial'
    END AS "ESTADO COBRANZA"
FROM VENDEDORES V
JOIN FACTURAS F ON (V.ID_VENDEDOR = F.FK_VENDEDORES)
JOIN CLIENTES CLI ON (F.FK_CLIENTES = CLI.ID_CLIENTE)
JOIN CANALES CN ON (F.FK_CANALES = CN.ID_CANAL)
JOIN COBRANZAS COB ON (F.ID_FACTURA = COB.FK_FACTURAS)
ORDER BY CLI.NOMBRE_CL, F.ID_FACTURA;

-- Consulta 8 Revisar!!

SELECT SU.SUCURSAL, S.FECHA_INICIO_SERV, S.FECHA_FIN_SERV, C.NOMBRE_CL, CO.FECHA_COBRO, CO.VALOR_COBRADO
FROM SERVICIOS S
JOIN SUCURSALES SU ON S.FK_SUCURSALES = SU.ID_SUCURSAL
JOIN CLIENTES C ON S.FK_CLIENTES = C.ID_CLIENTE
JOIN COBRANZAS CO ON C.ID_CLIENTE = CO.FK_CLIENTES
WHERE LENGTH(C.CIUDAD_CL) > 6 AND CO.FECHA_COBRO BETWEEN TO_DATE('2019-01-01', 'YYYY-MM-DD') AND TO_DATE('2019-03-31', 'YYYY-MM-DD');

-- Consulta 9
SELECT DISTINCT SUC.SUCURSAL 
FROM SUCURSALES SUC
JOIN SERVICIOS SERV ON (SUC.ID_SUCURSAL = SERV.FK_SUCURSALES);

