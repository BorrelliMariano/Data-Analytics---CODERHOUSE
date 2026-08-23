-- ============================================================
-- m5_extension_esquema.sql
-- Extiende Ventas_Tech_DB (creada en M3) para soportar las
-- consultas de M5: agrega segmento y territorio a clientes,
-- canal a ventas, y crea la tabla territorios.
-- Ejecutar UNA SOLA VEZ, después de m3/m4 y antes de
-- m5_consultas_joins.sql.
-- Versión T-SQL (SQL Server), con GO entre bloques para evitar
-- el error "Invalid column name" al usar una columna recién
-- agregada dentro del mismo batch.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Tabla territorios (nueva)
-- ------------------------------------------------------------
CREATE TABLE territorios (
    id_territorio INT PRIMARY KEY,
    region        VARCHAR(50) NOT NULL,
    pais          VARCHAR(50) NOT NULL,
    zona          VARCHAR(50)
);
GO

INSERT INTO territorios VALUES (1, 'AMBA',    'Argentina', 'Buenos Aires');
INSERT INTO territorios VALUES (2, 'Centro',  'Argentina', 'Córdoba');
INSERT INTO territorios VALUES (3, 'Litoral', 'Argentina', 'Santa Fe');
INSERT INTO territorios VALUES (4, 'Cuyo',    'Argentina', 'Mendoza');
INSERT INTO territorios VALUES (5, 'NOA',     'Argentina', 'Tucumán');
GO

-- ------------------------------------------------------------
-- 2) clientes: agregar segmento e id_territorio (FK)
-- ------------------------------------------------------------
ALTER TABLE clientes ADD segmento VARCHAR(30);
ALTER TABLE clientes ADD id_territorio INT;
GO

ALTER TABLE clientes ADD CONSTRAINT fk_clientes_territorio
    FOREIGN KEY (id_territorio) REFERENCES territorios (id_territorio);
GO

UPDATE clientes SET segmento = 'Premium',     id_territorio = 1 WHERE id_cliente = 1; -- María López   - Buenos Aires
UPDATE clientes SET segmento = 'Regular',     id_territorio = 2 WHERE id_cliente = 2; -- Carlos Ruiz    - Córdoba
UPDATE clientes SET segmento = 'Premium',     id_territorio = 3 WHERE id_cliente = 3; -- Ana Gómez      - Rosario
UPDATE clientes SET segmento = 'Regular',     id_territorio = 4 WHERE id_cliente = 4; -- Pedro Sanz     - Mendoza
UPDATE clientes SET segmento = 'Corporativo', id_territorio = 5 WHERE id_cliente = 5; -- Laura Torres   - Tucumán
GO

-- Cliente nuevo, sin ninguna venta: sirve para probar la
-- Consulta 2 (clientes sin ventas) con un resultado real.
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
VALUES (6, 'Diego Fernández', 'diego@mail.com', 'La Plata', '2024-03-20');
GO

UPDATE clientes SET segmento = 'Regular', id_territorio = 1 WHERE id_cliente = 6;
GO

-- ------------------------------------------------------------
-- 3) ventas: agregar canal
-- ------------------------------------------------------------
ALTER TABLE ventas ADD canal VARCHAR(20);
GO

UPDATE ventas SET canal = 'Online'     WHERE id_venta IN (1, 3, 5, 7, 9);
UPDATE ventas SET canal = 'Presencial' WHERE id_venta IN (2, 4, 6, 8, 10);
GO

-- ------------------------------------------------------------
-- 4) producto nuevo, sin ninguna venta: sirve para probar la
-- Consulta 3 (productos sin ventas) con un resultado real.
-- ------------------------------------------------------------
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (7, 'Webcam HD', 2, 45.00, 25, 1);
GO