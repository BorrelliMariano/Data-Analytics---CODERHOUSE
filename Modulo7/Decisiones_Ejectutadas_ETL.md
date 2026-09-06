# Justificación de decisiones técnicas — Pipeline ETL TechStore

**Archivo asociado:** `Pipeline_ETL_Borrelli_Mariano.pbix`
**Módulo:** Pipeline ETL desde SQL con Power Query y M

Este documento explica el criterio técnico aplicado para resolver los duplicados y valores nulos intencionales del dataset `Pipeline_ETL_Dataset.xlsx`, dentro de las consultas `Dim_Clientes` y `Dim_Productos`.

---

## Dim_Clientes

### Duplicado — `id_cliente = 1` (María López)
El registro de María López estaba cargado dos veces con datos idénticos. Se eliminó por `Table.Distinct` usando exclusivamente la columna `id_cliente` como criterio (no todas las columnas), porque esta columna es la clave primaria de la dimensión: debe ser única para que las relaciones 1:N con `Fact_Ventas` funcionen correctamente en el modelo analítico del Módulo 8.

### Nulo en `email` — Valentina Paz (`id_cliente = 9`)
**Decisión:** reemplazar por `"sin-email@techstore.com"` en vez de eliminar la fila.

**Justificación:** el cliente tiene ventas registradas en `Fact_Ventas`. Eliminar la fila rompería la integridad referencial del modelo (quedarían ventas "huérfanas" sin cliente asociado) y distorsionaría cualquier métrica agregada por cliente o segmento. El valor centinela permite identificar fácilmente, en el futuro, qué clientes necesitan actualizar su email para campañas de contacto, sin perder el historial de compras.

### Nulo en `ciudad` — Roberto Díaz (`id_cliente = 11`)
**Decisión:** reemplazar por `"Sin dato"` en vez de eliminar la fila.

**Justificación:** `ciudad` es un campo de segmentación geográfica, no una clave crítica para el cálculo de ingresos ni para las relaciones del modelo. Eliminar la fila haría perder el registro completo de ventas de ese cliente. Reemplazar por un valor explícito ("Sin dato") es preferible a dejarlo en blanco, porque facilita filtrar o agrupar estos casos en reportes futuros sin generar errores de visualización.

---

## Dim_Productos

### Duplicado — `id_producto = 103` (Monitor 4K 27")
Mismo criterio que en clientes: se eliminó por `Table.Distinct` usando `id_producto`, ya que esta tabla también actúa como dimensión y su clave debe ser única para sostener el `merge` con `Fact_Ventas` sin duplicar transacciones.

### Nulo en `precio` — SSD Externo 1TB (`id_producto = 109`)
**Decisión:** reemplazar por **$144,60**, estimado a partir del *markup* promedio del catálogo.

**Justificación:** el precio es un campo crítico — sin él no se puede calcular `total_venta` ni el ingreso de ninguna transacción que incluya este producto. En vez de usar un valor arbitrario o el promedio simple de precios del catálogo (que ignoraría que cada producto tiene un costo distinto), se calculó la relación promedio `precio / costo` de los 11 productos con datos completos (≈ **1.93x**) y se aplicó sobre el costo real del SSD (**$75**):

```
Precio estimado = Costo × Markup promedio = 75 × 1.93 ≈ $144.60
```

Este método respeta la estructura de rentabilidad propia de cada producto, en lugar de imponer un precio desconectado de su costo real.

### Nulo en `categoria` — Laptop Gaming Pro (`id_producto = 111`)
**Decisión:** asignar **"Computación"**, en vez de una etiqueta genérica como "Sin Categoría".

**Justificación:** el propio dataset provee evidencia suficiente para inferir la categoría con confianza: la columna `subcategoria` de este producto es `"Laptops"`, y todos los demás productos con esa misma subcategoría (Laptop Pro 15, Laptop Basic 14) pertenecen a la categoría `"Computación"`. Usar una etiqueta genérica hubiera descartado información disponible y útil para el análisis por categoría en reportes futuros.

---

## Resumen de conteos finales

| Tabla | Filas originales | Filas finales | Motivo de la diferencia |
|---|---|---|---|
| Dim_Clientes | 12 | 11 | 1 duplicado eliminado |
| Dim_Productos | 13 | 12 | 1 duplicado eliminado |
| Dim_Categorias | 4 | 4 | Sin cambios (tabla limpia) |
| Fact_Ventas | 50 | 50 | Sin cambios (tabla limpia) + 2 columnas agregadas por merge |
