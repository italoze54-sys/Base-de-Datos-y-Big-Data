-- ============================================================================
-- SCRIPT DE REGLAS DE LIMPIEZA, CALIDAD Y CONTROL DE ERRORES (DATA QUALITY)
-- Base de Datos: TOTTUSMERMA -> DM_Tottus_Merma
-- ============================================================================

USE TOTTUSMERMA;
GO

-- 1. DETECCIÓN Y ELIMINACIÓN DE REGISTROS DUPLICADOS (dropDuplicates Logic)
-- Identifica pedidos con duplicidad basada en clave de negocio e hiper-estampa de tiempo
WITH CTE_Duplicados AS (
    SELECT 
        id_pedido,
        id_beneficiario,
        fecha_solicitud,
        ROW_NUMBER() OVER (
            PARTITION BY id_beneficiario, fecha_solicitud, costo_total 
            ORDER BY id_pedido
        ) AS RowNum
    FROM TOTTUSMERMA.dbo.Pedido_rescate
)
SELECT * FROM CTE_Duplicados WHERE RowNum > 1;
GO

-- 2. VALIDACIÓN DE VALORES NULOS EN CAMPOS CRÍTICOS
-- Filtra registros no procesables antes de ingresar a la tabla de hechos
SELECT 
    'Producto sin código de barras' AS Tipo_Error,
    COUNT(*) AS Cantidad_Registros
FROM TOTTUSMERMA.dbo.Producto
WHERE codigo_barras IS NULL OR LTRIM(RTRIM(codigo_barras)) = ''

UNION ALL

SELECT 
    'Lote con fecha inconsistente',
    COUNT(*)
FROM TOTTUSMERMA.dbo.Lote_merma
WHERE fecha_vencimiento < fecha_ingreso_merma OR fecha_vencimiento IS NULL;
GO

-- 3. CREACIÓN DE TABLA DE CUARENTENA / CONTROL DE ERRORES
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cuarentena_Errores_ETL')
BEGIN
    CREATE TABLE Cuarentena_Errores_ETL (
        id_error INT IDENTITY(1,1) PRIMARY KEY,
        tabla_origen VARCHAR(50),
        id_registro_origen INT,
        tipo_inconsistencia VARCHAR(100),
        fecha_registro DATETIME DEFAULT GETDATE()
    );
END;
GO

-- 4. DESVÍO AUTOMÁTICO DE REGISTROS CON INCONSISTENCIAS A CUARENTENA
INSERT INTO Cuarentena_Errores_ETL (tabla_origen, id_registro_origen, tipo_inconsistencia)
SELECT 
    'Lote_merma', 
    id_lote, 
    'Fecha de vencimiento anterior a la fecha de ingreso'
FROM TOTTUSMERMA.dbo.Lote_merma
WHERE fecha_vencimiento < fecha_ingreso_merma;
GO

-- 5. VERIFICACIÓN DE INTEGRIDAD REFERENCIAL (Búsqueda de llaves huérfanas)
SELECT 
    dpr.id_detalle,
    dpr.id_pedido
FROM TOTTUSMERMA.dbo.detalle_pedido_rescate dpr
LEFT JOIN TOTTUSMERMA.dbo.Pedido_rescate pr ON dpr.id_pedido = pr.id_pedido
WHERE pr.id_pedido IS NULL;
GO