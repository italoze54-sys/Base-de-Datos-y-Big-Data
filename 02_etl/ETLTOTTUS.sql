-- ============================================================================
-- PASO 1: LIMPIEZA DE TABLAS Y REINICIO DE IDENTIDADES
-- ============================================================================

DELETE FROM fact_Gestion_Merma_Rescate;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('fact_Gestion_Merma_Rescate', RESEED, 0);
GO

DELETE FROM dim_Producto;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('dim_Producto', RESEED, 0);
GO

DELETE FROM dim_Sede;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('dim_Sede', RESEED, 0);
GO

DELETE FROM dim_Beneficiario;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('dim_Beneficiario', RESEED, 0);
GO

DELETE FROM dim_Lote;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('dim_Lote', RESEED, 0);
GO

DELETE FROM dim_Canal_Rescate;
IF @@ROWCOUNT <> 0    
    DBCC CHECKIDENT ('dim_Canal_Rescate', RESEED, 0);
GO

DELETE FROM dim_Tiempo;
GO


-- ============================================================================
-- PASO 2: EXTRACCIÓN Y CARGA DE DIMENSIONES
-- ============================================================================

-- 2.1 Cargar Dimensión Producto (Transformación: desnormaliza Producto y Categoría)
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

SELECT * FROM DM_Tottus_Merma.dbo.dim_Producto;
GO

-- 2.2 Cargar Dimensión Sede
INSERT INTO DM_Tottus_Merma.dbo.dim_Sede (
    codigo_tienda, 
    nombre_sede, 
    direccion, 
    distrito
)
SELECT 
    CONCAT('TOT-', RIGHT('000' + CAST(id_sede AS VARCHAR(3)), 3)) AS codigo_tienda,
    nombre_sede,
    direccion,
    distrito
FROM TOTTUSMERMA.dbo.Sede_Tottus;
GO

SELECT * FROM DM_Tottus_Merma.dbo.dim_Sede;
GO

-- 2.3 Cargar Dimensión Beneficiario
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

SELECT * FROM DM_Tottus_Merma.dbo.dim_Beneficiario;
GO

-- 2.4 Cargar Dimensión Lote
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

SELECT * FROM DM_Tottus_Merma.dbo.dim_Lote;
GO

-- 2.5 Cargar Dimensión Canal de Rescate
INSERT INTO DM_Tottus_Merma.dbo.dim_Canal_Rescate (nombre_canal, tipo_operacion)
VALUES 
('Donación a Ollas Comunes', 'Social Gratuita'),
('Donación a Comedores Populares', 'Social Gratuita'),
('Venta a Bodegas y Minimarkets', 'Comercial Simbólica'),
('Venta a Pequeños Restaurantes / Menús', 'Comercial Simbólica'),
('Descarte / Baja Irrecuperable', 'Baja por Caducidad');
GO

SELECT * FROM DM_Tottus_Merma.dbo.dim_Canal_Rescate;
GO

-- 2.6 Cargar Dimensión Tiempo de forma dinámica a partir de las fechas operacionales
DECLARE @inicio DATE, @fin DATE;

SELECT 
    @inicio = MIN(fecha_solicitud), 
    @fin = MAX(fecha_solicitud) 
FROM TOTTUSMERMA.dbo.Pedido_rescate;

IF @inicio IS NULL OR @inicio = @fin
BEGIN
    SET @inicio = '2026-06-01';
    SET @fin = '2026-08-31';
END;

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
            CASE MONTH(@inicio)
                WHEN 1 THEN 'Enero'
                WHEN 2 THEN 'Febrero'
                WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril'
                WHEN 5 THEN 'Mayo'
                WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio'
                WHEN 8 THEN 'Agosto'
                WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre'
                WHEN 11 THEN 'Noviembre'
                WHEN 12 THEN 'Diciembre'
            END,
            YEAR(@inicio)
        );
    END;

    SET @inicio = DATEADD(DAY, 1, @inicio);
END;
GO

SELECT * FROM DM_Tottus_Merma.dbo.dim_Tiempo;
GO


-- ============================================================================
-- PASO 3: CARGA DE LA TABLA DE HECHOS (fact_Gestion_Merma_Rescate)
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
    -- 1. Tiempo en formato entero YYYYMMDD
    CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT) AS id_tiempo,
    
    -- 2. Claves foráneas hacia las dimensiones cargadas
    dp.id_producto,
    dl.id_lote,
    ds.id_sede,
    db.id_beneficiario,
    
    -- 3. Canal deducido según el tipo de beneficiario
    CASE 
        WHEN b.tipo_beneficiario = 'Olla Comun' THEN 1
        WHEN b.tipo_beneficiario = 'Comedor Popular' THEN 2
        WHEN b.tipo_beneficiario = 'Bodega Aliada MYPE' THEN 3
        ELSE 4
    END AS id_canal,
    
    -- 4. Métricas cuantitativas
    SUM(dpr.cantidad_solicitada) AS cantidad_rescatada,
    0.00 AS cantidad_merma_perdida,
    0.00 AS monto_perdida_merma,
    SUM(dpr.subtotal) AS monto_recuperado_rescate,
    
    -- Ahorro social: (Cantidad solicitada * Precio regular) - Subtotal cobrado
    SUM(dpr.cantidad_solicitada * prod.precio_original) - SUM(dpr.subtotal) AS ahorro_social_donado

FROM TOTTUSMERMA.dbo.Pedido_rescate pr
INNER JOIN TOTTUSMERMA.dbo.detalle_pedido_rescate dpr ON pr.id_pedido = dpr.id_pedido
INNER JOIN TOTTUSMERMA.dbo.Lote_merma lm ON dpr.id_lote = lm.id_lote
INNER JOIN TOTTUSMERMA.dbo.Producto prod ON lm.id_producto = prod.id_producto
INNER JOIN TOTTUSMERMA.dbo.Beneficiario b ON pr.id_beneficiario = b.id_beneficiario
INNER JOIN TOTTUSMERMA.dbo.Sede_Tottus st ON pr.id_sede = st.id_sede

-- Cruce con dimensiones para enlazar los IDs
INNER JOIN DM_Tottus_Merma.dbo.dim_Producto dp ON prod.codigo_barras = dp.codigo_barras
INNER JOIN DM_Tottus_Merma.dbo.dim_Beneficiario db ON b.ruc_o_codigo_midis = db.ruc_o_codigo_midis
INNER JOIN DM_Tottus_Merma.dbo.dim_Sede ds ON st.nombre_sede = ds.nombre_sede
INNER JOIN DM_Tottus_Merma.dbo.dim_Lote dl ON lm.id_lote = dl.id_lote

GROUP BY 
    CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT),
    dp.id_producto,
    dl.id_lote,
    ds.id_sede,
    db.id_beneficiario,
    b.tipo_beneficiario;
GO

-- ============================================================================
-- VERIFICACIÓN FINAL EN EL DATA MART
-- ============================================================================
SELECT 'dim_Tiempo' AS Tabla, COUNT(*) AS Total FROM DM_Tottus_Merma.dbo.dim_Tiempo
UNION ALL
SELECT 'dim_Producto', COUNT(*) FROM DM_Tottus_Merma.dbo.dim_Producto
UNION ALL
SELECT 'dim_Sede', COUNT(*) FROM DM_Tottus_Merma.dbo.dim_Sede
UNION ALL
SELECT 'dim_Beneficiario', COUNT(*) FROM DM_Tottus_Merma.dbo.dim_Beneficiario
UNION ALL
SELECT 'dim_Lote', COUNT(*) FROM DM_Tottus_Merma.dbo.dim_Lote
UNION ALL
SELECT 'dim_Canal_Rescate', COUNT(*) FROM DM_Tottus_Merma.dbo.dim_Canal_Rescate
UNION ALL
SELECT 'fact_Gestion_Merma_Rescate', COUNT(*) FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate;
GO






USE DM_Tottus_Merma;
GO


--Total base operacional OLTP (Origen)
SELECT 
    'TOTTUSMERMA (OLTP)' AS Base_Datos,
    SUM(cantidad_solicitada) AS Total_Cantidad_Kilos_Unidades,
    SUM(subtotal) AS Total_Monto_Recuperado_Soles
FROM TOTTUSMERMA.dbo.detalle_pedido_rescate

UNION ALL

--Total  Data Mart analítico OLAP (Destino)
SELECT 
    'DM_Tottus_Merma (OLAP)' AS Base_Datos,
    SUM(cantidad_rescatada) AS Total_Cantidad_Kilos_Unidades,
    SUM(monto_recuperado_rescate) AS Total_Monto_Recuperado_Soles
FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate;
GO
use DM_Tottus_Merma
select * from fact_Gestion_Merma_Rescate


-- ==============================================================================
-- SCRIPT DE ACTUALIZACIÓN DE DATOS PARA LA TABLA DE HECHOS (70 REGISTROS)
-- Simula escenarios de rescate exitoso, rescate parcial y merma total por caducidad.
-- ==============================================================================

select * from dim_Canal_Rescate
select * from dim_Beneficiario