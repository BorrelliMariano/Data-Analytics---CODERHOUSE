-- ============================================================
-- m5_consultas_joins.sql
-- Proyecto RetailPro — Módulo 5
-- Cruces con JOIN sobre Ventas_Tech_DB
-- Ejecutar después de m3 (schema) y de m5_extension_esquema.sql
-- (agrega segmento, canal y territorios a la base de M3).
-- ============================================================

-- ============================================================
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Cruza ventas, clientes, productos, categorías y territorios
-- en una sola fila enriquecida. Es la fuente que va a consumir
-- Power BI en M7.
-- ============================================================
SELECT
    v.fecha_venta                    AS fecha,
    c.nombre                         AS cliente,
    c.segmento,
    t.region,
    p.nombre_producto,
    cat.nombre_categoria             AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario   AS total_venta,
    v.canal
FROM ventas v
JOIN clientes    c   ON v.id_cliente   = c.id_cliente
JOIN productos   p   ON v.id_producto  = p.id_producto
JOIN categorias  cat ON p.id_categoria = cat.id_categoria
JOIN territorios t   ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;


-- ============================================================
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que todavía no compraron nada.
-- ============================================================
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- ============================================================
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Productos del catálogo sin ningún movimiento registrado.
-- ============================================================
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v   ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- ============================================================
-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Combina ventas Online y Presencial en un único resultado,
-- identificando el origen con la columna canal, y calcula el
-- total facturado por canal.
-- ============================================================
SELECT
    canal,
    COUNT(*)          AS cantidad_ventas,
    SUM(total_venta)  AS total_facturado
FROM (
    SELECT 'Online' AS canal, cantidad * precio_unitario AS total_venta
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT 'Presencial' AS canal, cantidad * precio_unitario AS total_venta
    FROM ventas
    WHERE canal = 'Presencial'
) AS ventas_unificadas
GROUP BY canal
ORDER BY canal;