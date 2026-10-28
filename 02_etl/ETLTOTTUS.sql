USE DM_Tottus_Merma;
GO

-- ============================================================================
-- PASO 1: LIMPIEZA DE TABLAS Y REINICIO DE IDENTIDADES
-- ============================================================================
DELETE FROM fact_Gestion_Merma_Rescate;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('fact_Gestion_Merma_Rescate', RESEED, 0);

DELETE FROM dim_Producto;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('dim_Producto', RESEED, 0);

DELETE FROM dim_Sede;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('dim_Sede', RESEED, 0);

DELETE FROM dim_Beneficiario;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('dim_Beneficiario', RESEED, 0);

DELETE FROM dim_Lote;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('dim_Lote', RESEED, 0);

DELETE FROM dim_Canal_Rescate;
IF @@ROWCOUNT <> 0 DBCC CHECKIDENT ('dim_Canal_Rescate', RESEED, 0);

DELETE FROM dim_Tiempo;
GO

-- ============================================================================
-- PASO 2: EXTRACCIÓN Y CARGA DE DIMENSIONES (Sin invención de códigos/datos)
-- ============================================================================

-- 2.1 Dimensión Producto
INSERT INTO DM_Tottus_Merma.dbo.dim_Producto (
    codigo_barras, 
    nombre_producto, 
    categoria, 
    unidad_medida, 
    precio_original
)
SELECT 
    p.codigo_barras,
    p.nombre_producto,
    c.nombre_categoria AS categoria,
    p.unidad_medida,
    p.precio_original
FROM TOTTUSMERMA.dbo.Producto p
INNER JOIN TOTTUSMERMA.dbo.Categoria c ON p.id_categoria = c.id_categoria;
GO

-- 2.2 Dimensión Sede (Extracción limpia del ID/Nombre original)
INSERT INTO DM_Tottus_Merma.dbo.dim_Sede (
    codigo_tienda, 
    nombre_sede, 
    direccion, 
    distrito
)
SELECT 
    CAST(id_sede AS VARCHAR(10)) AS codigo_tienda,
    nombre_sede,
    direccion,
    distrito
FROM TOTTUSMERMA.dbo.Sede_Tottus;
GO

-- 2.3 Dimensión Beneficiario
INSERT INTO DM_Tottus_Merma.dbo.dim_Beneficiario (
    tipo_beneficiario, 
    nombre_institucion, 
    ruc_o_codigo_midis, 
    distrito
)
SELECT 
    tipo_beneficiario,
    nombre_institucion,
    ruc_o_codigo_midis,
    distrito
FROM TOTTUSMERMA.dbo.Beneficiario;
GO

-- 2.4 Dimensión Lote
INSERT INTO DM_Tottus_Merma.dbo.dim_Lote (
    fecha_ingreso_merma, 
    fecha_vencimiento, 
    tipo_destino, 
    estado_lote
)
SELECT 
    fecha_ingreso_merma,
    fecha_vencimiento,
    tipo_destino,
    estado_lote
FROM TOTTUSMERMA.dbo.Lote_merma;
GO

-- 2.5 Dimensión Canal de Rescate (Extraído directamente según tipo_destino del OLTP)
INSERT INTO DM_Tottus_Merma.dbo.dim_Canal_Rescate (nombre_canal, tipo_operacion)
SELECT DISTINCT 
    tipo_destino AS nombre_canal,
    CASE 
        WHEN tipo_destino LIKE '%Donación%' THEN 'Social Gratuita'
        WHEN tipo_destino LIKE '%Venta%' THEN 'Comercial Simbólica'
        ELSE 'Operación Estándar'
    END AS tipo_operacion
FROM TOTTUSMERMA.dbo.Lote_merma;
GO

-- 2.6 Dimensión Tiempo (Basada exactamente en las fechas reales de la BD principal)
DECLARE @inicio DATE, @fin DATE;

SELECT 
    @inicio = MIN(fecha_solicitud), 
    @fin = MAX(fecha_solicitud) 
FROM TOTTUSMERMA.dbo.Pedido_rescate;

WHILE (@inicio <= @fin)
BEGIN
    DECLARE @id_calc INT = CAST(CONVERT(VARCHAR(8), @inicio, 112) AS INT);

    IF NOT EXISTS (SELECT 1 FROM dim_Tiempo WHERE id_tiempo = @id_calc)
    BEGIN
        INSERT INTO dim_Tiempo (
            id_tiempo,
            fecha,
            numero_semana,
            mes,
            nombre_mes,
            año
        )
        VALUES (
            @id_calc,
            @inicio,
            DATEPART(WEEK, @inicio),
            MONTH(@inicio),
            DATENAME(MONTH, @inicio),
            YEAR(@inicio)
        );
    END;

    SET @inicio = DATEADD(DAY, 1, @inicio);
END;
GO

-- ============================================================================
-- PASO 3: CARGA DE LA TABLA DE HECHOS (Cálculo real de Rescate y Merma Perdida)
-- ============================================================================
INSERT INTO DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate (
    id_tiempo,
    id_producto,
    id_lote,
    id_sede,
    id_beneficiario,
    id_canal,
    cantidad_rescatada,
    cantidad_merma_perdida,
    monto_perdida_merma,
    monto_recuperado_rescate,
    ahorro_social_donado
)
SELECT 
    CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT) AS id_tiempo,
    dp.id_producto,
    dl.id_lote,
    ds.id_sede,
    db.id_beneficiario,
    dc.id_canal,
    
    -- 1. Cantidad real rescatada desde las solicitudes
    SUM(dpr.cantidad_solicitada) AS cantidad_rescatada,
    
    -- 2. Merma no rescatada (Diferencia real entre lo ingresado al lote y lo rescatado)
    CASE 
        WHEN (lm.cantidad_disponible - SUM(dpr.cantidad_solicitada)) > 0 
        THEN (lm.cantidad_disponible - SUM(dpr.cantidad_solicitada))
        ELSE 0.00 
    END AS cantidad_merma_perdida,
    
    -- 3. Pérdida monetaria real según el precio original del producto
    CASE 
        WHEN (lm.cantidad_disponible - SUM(dpr.cantidad_solicitada)) > 0 
        THEN (lm.cantidad_disponible - SUM(dpr.cantidad_solicitada)) * prod.precio_original
        ELSE 0.00 
    END AS monto_perdida_merma,
    
    -- 4. Monto financiero recuperado
    SUM(dpr.subtotal) AS monto_recuperado_rescate,
    
    -- 5. Valor del ahorro social
    SUM(dpr.cantidad_solicitada * prod.precio_original) - SUM(dpr.subtotal) AS ahorro_social_donado

FROM TOTTUSMERMA.dbo.Pedido_rescate pr
INNER JOIN TOTTUSMERMA.dbo.detalle_pedido_rescate dpr ON pr.id_pedido = dpr.id_pedido
INNER JOIN TOTTUSMERMA.dbo.Lote_merma lm ON dpr.id_lote = lm.id_lote
INNER JOIN TOTTUSMERMA.dbo.Producto prod ON lm.id_producto = prod.id_producto
INNER JOIN TOTTUSMERMA.dbo.Beneficiario b ON pr.id_beneficiario = b.id_beneficiario
INNER JOIN TOTTUSMERMA.dbo.Sede_Tottus st ON pr.id_sede = st.id_sede

-- Cruce directo con las dimensiones pobladas
INNER JOIN DM_Tottus_Merma.dbo.dim_Producto dp ON prod.codigo_barras = dp.codigo_barras
INNER JOIN DM_Tottus_Merma.dbo.dim_Beneficiario db ON b.ruc_o_codigo_midis = db.ruc_o_codigo_midis
INNER JOIN DM_Tottus_Merma.dbo.dim_Sede ds ON st.nombre_sede = ds.nombre_sede
INNER JOIN DM_Tottus_Merma.dbo.dim_Lote dl ON lm.id_lote = dl.id_lote
INNER JOIN DM_Tottus_Merma.dbo.dim_Canal_Rescate dc ON lm.tipo_destino = dc.nombre_canal

GROUP BY 
    CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT),
    dp.id_producto,
    dl.id_lote,
    ds.id_sede,
    db.id_beneficiario,
    dc.id_canal,
    lm.cantidad_disponible,
    prod.precio_original;
GO

-- ============================================================================
-- VERIFICACIÓN DE CONSISTENCIA
-- ============================================================================
SELECT 
    'TOTTUSMERMA (OLTP)' AS Origen,
    SUM(cantidad_solicitada) AS Cantidad_Total,
    SUM(subtotal) AS Monto_Total
FROM TOTTUSMERMA.dbo.detalle_pedido_rescate

UNION ALL

SELECT 
    'DM_Tottus_Merma (OLAP)' AS Destino,
    SUM(cantidad_rescatada) AS Cantidad_Total,
    SUM(monto_recuperado_rescate) AS Monto_Total
FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate;
GO