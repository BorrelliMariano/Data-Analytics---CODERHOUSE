-- ============================================================
-- m4_consultas_negocio.sql
-- Proyecto RetailPro — Módulo 4
-- Consultas de negocio sobre Ventas_Tech_DB (tabla ventas)
-- Versión T-SQL (SQL Server)
-- Ejecutar después de haber corrido ventas_tech_db.sql (M3)
-- ============================================================

-- ============================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio,
-- agrupados por mes.
-- ============================================================
SELECT
    MONTH(fecha_venta)                             AS mes,
    COUNT(*)                                       AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)                AS total_facturado,
    AVG(cantidad * precio_unitario)                AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- ============================================================
-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades
-- vendidas y total generado.
-- ============================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- ============================================================
-- Consulta 3 — Clientes recurrentes
-- id_cliente con más de un pedido, cantidad de pedidos y
-- total gastado.
-- ============================================================
SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ============================================================
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado según se ubique por
-- encima o por debajo del promedio mensual general.
-- ============================================================
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_mes) FROM (
            SELECT SUM(cantidad * precio_unitario) AS total_mes
            FROM ventas
            GROUP BY MONTH(fecha_venta)
        ) AS totales_por_mes)
            THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_mes) FROM (
            SELECT SUM(cantidad * precio_unitario) AS total_mes
            FROM ventas
            GROUP BY MONTH(fecha_venta)
        ) AS totales_por_mes)
            THEN 'Por debajo'
        ELSE 'En el promedio'
    END AS comparacion_vs_promedio
FROM (
    SELECT
        MONTH(fecha_venta)               AS mes,
        SUM(cantidad * precio_unitario)  AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS resumen_mensual
ORDER BY mes;


-- ============================================================
-- Hallazgos
-- ============================================================
-- 1. Los 10 registros de venta cargados en M3 caen todos dentro
--    de un único mes (marzo 2024), por lo que las consultas 1 y 4
--    devuelven una sola fila. La comparación mes contra mes va a
--    volverse relevante recién cuando se cargue un dataset con
--    ventas distribuidas en varios meses (por ejemplo, al conectar
--    datos reales en M6).
-- 2. El producto id_producto = 1 (Laptop Pro 15) concentra la
--    mayor facturación individual: con solo 2 pedidos (3 unidades
--    en total) generó $3.600, más del doble que el segundo puesto
--    (id_producto = 3, con $1.350). Es el producto a priorizar en
--    cualquier análisis de mix o de reposición de stock.
-- 3. Los 5 clientes cargados compraron exactamente 2 veces cada
--    uno, así que todos califican como "recurrentes" (>1 pedido)
--    con el dataset actual — no hay compradores de una sola vez
--    para contrastar. Este patrón cambiará cuando se sumen más
--    clientes y transacciones reales.