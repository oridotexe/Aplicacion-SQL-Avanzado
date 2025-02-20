-- Parte II

-- Consulta 1
-- Tablas: Vendedores, Clientes, Facturas, Cobranzas

SELECT 
    v.vendedor AS "Vendedor",
    c.nombre_cl AS "Cliente",
    SUM(f.total_factura) AS "Facturado",
    SUM(co.valor_cobrado) AS "Cobrado",
    CASE 
        WHEN SUM(f.total_factura) - SUM(co.valor_cobrado) > 0 
        THEN TO_CHAR(SUM(f.total_factura) - SUM(co.valor_cobrado))
        ELSE 'Deuda Saldada'
    END AS "Deuda Pendiente"
FROM facturas f
JOIN vendedores v ON (f.fk_vendedores = v.id_vendedor)
JOIN clientes c ON (f.fk_clientes = c.id_cliente)
LEFT JOIN cobranzas co ON (f.id_factura = co.fk_facturas)
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
ORDER BY cantidad_facturas DESC;

