-- ============================================================================
-- SCRIPT DE REGLAS DE LIMPIEZA, CALIDAD Y CONTROL DE ERRORES (DATA QUALITY)
-- Base de Datos: TOTTUSMERMA
-- ============================================================================

USE TOTTUSMERMA;
GO

-- 1. CREACIÓN DE TABLA DE CUARENTENA / CONTROL DE ERRORES
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cuarentena_Errores_ETL')
BEGIN
    CREATE TABLE Cuarentena_Errores_ETL (
        id_error INT IDENTITY(1,1) PRIMARY KEY,
        tabla_origen VARCHAR(50) NOT NULL,
        id_registro_origen INT NOT NULL,
        tipo_inconsistencia VARCHAR(100) NOT NULL,
        fecha_registro DATETIME DEFAULT GETDATE()
    );
END;
GO

-- 2. DESVÍO AUTOMÁTICO DE REGISTROS INCONSISTENTES A CUARENTENA
-- Fechas de vencimiento anteriores a la fecha de ingreso
INSERT INTO Cuarentena_Errores_ETL (tabla_origen, id_registro_origen, tipo_inconsistencia)
SELECT 
    'Lote_merma', 
    id_lote, 
    'Fecha de vencimiento anterior a la fecha de ingreso'
FROM TOTTUSMERMA.dbo.Lote_merma
WHERE (fecha_vencimiento < fecha_ingreso_merma OR fecha_vencimiento IS NULL)
  AND id_lote NOT IN (SELECT id_registro_origen FROM Cuarentena_Errores_ETL WHERE tabla_origen = 'Lote_merma');

-- Productos sin código de barras
INSERT INTO Cuarentena_Errores_ETL (tabla_origen, id_registro_origen, tipo_inconsistencia)
SELECT 
    'Producto', 
    id_producto, 
    'Producto sin código de barras o formato inválido'
FROM TOTTUSMERMA.dbo.Producto
WHERE codigo_barras IS NULL OR LTRIM(RTRIM(codigo_barras)) = ''
  AND id_producto NOT IN (SELECT id_registro_origen FROM Cuarentena_Errores_ETL WHERE tabla_origen = 'Producto');
GO

-- 3. DEPURACIÓN DE PEDIDOS DUPLICADOS EN EL ORIGEN (dropDuplicates)
WITH CTE_Duplicados AS (
    SELECT 
        id_pedido,
        ROW_NUMBER() OVER (
            PARTITION BY id_beneficiario, fecha_solicitud, costo_total 
            ORDER BY id_pedido
        ) AS RowNum
    FROM TOTTUSMERMA.dbo.Pedido_rescate
)
DELETE FROM TOTTUSMERMA.dbo.Pedido_rescate
WHERE id_pedido IN (SELECT id_pedido FROM CTE_Duplicados WHERE RowNum > 1);
GO

-- 4. VERIFICACIÓN DE LLAVES HUÉRFANAS (Detalles de pedido sin cabecera)
DELETE FROM TOTTUSMERMA.dbo.detalle_pedido_rescate
WHERE id_pedido NOT IN (SELECT id_pedido FROM TOTTUSMERMA.dbo.Pedido_rescate);
GO