USE TOTTUSMERMA;
GO

-- Limpiar |
IF OBJECT_ID('dbo.test_lote_merma_1k_completa', 'U') IS NOT NULL
    DROP TABLE dbo.test_lote_merma_1k_completa;
GO

-- Creación de la tabla
CREATE TABLE dbo.test_lote_merma_1k_completa (
    id_lote INT,
    id_producto INT,
    id_sede INT,
    fecha_ingreso_merma DATE,
    fecha_vencimiento DATE,
    cantidad_disponible DECIMAL(5,2),
    tipo_destino VARCHAR(50),
    precio_rescate DECIMAL(5,2),
    estado_lote VARCHAR(15)
);
GO

-- Inserción de 3,000,000 registros
DECLARE @t_inicio DATETIME2 = SYSDATETIME();

INSERT INTO dbo.test_lote_merma_1k_completa (
    id_lote, id_producto, id_sede, fecha_ingreso_merma, fecha_vencimiento, 
    cantidad_disponible, tipo_destino, precio_rescate, estado_lote
)
SELECT TOP (3000000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id_lote,
    ABS(CHECKSUM(NEWID())) % 50 + 1 AS id_producto,
    ABS(CHECKSUM(NEWID())) % 20 + 1 AS id_sede,
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 150, '2026-01-01') AS fecha_ingreso_merma,
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 30, '2026-06-01') AS fecha_vencimiento,
    CAST((ABS(CHECKSUM(NEWID())) % 5000 + 100) / 100.0 AS DECIMAL(5,2)) AS cantidad_disponible,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Donación Social' ELSE 'Venta Preferencial' END AS tipo_destino,
    CAST((ABS(CHECKSUM(NEWID())) % 2000 + 100) / 100.0 AS DECIMAL(5,2)) AS precio_rescate,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Disponible' ELSE 'Agotado' END AS estado_lote
FROM master.dbo.spt_values t1
CROSS JOIN master.dbo.spt_values t2;

DECLARE @t_fin DATETIME2 = SYSDATETIME();

-- Resultados de tiempo:
SELECT 
    DATEDIFF(millisecond, @t_inicio, @t_fin) AS Tiempo_Total_Ms,
    DATEDIFF(second, @t_inicio, @t_fin) AS Tiempo_Total_Segundos;

SELECT COUNT(*) AS Total_Filas, SUM(cantidad_disponible) AS Total_Cantidad 
FROM dbo.test_lote_merma_1k_completa;
GO