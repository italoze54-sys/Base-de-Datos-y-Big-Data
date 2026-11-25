USE TOTTUSMERMA;
GO

-- 1. Agregar 100 registros nuevos a Lote_merma (IDs 101 al 200)
;WITH Nums AS (
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Lote_merma (id_producto, id_sede, fecha_ingreso_merma, fecha_vencimiento, cantidad_disponible, tipo_destino, precio_rescate, estado_lote)
SELECT
    ((n - 1) % 100) + 1 AS id_producto,
    ((n - 1) % 20) + 1 AS id_sede,
    DATEADD(DAY, (n % 60), '2026-07-01') AS fecha_ingreso_merma,
    DATEADD(DAY, (n % 60) + 3, '2026-07-01') AS fecha_vencimiento,
    CAST(12.00 + (n % 25) AS DECIMAL(10,2)) AS cantidad_disponible,
    CASE WHEN n % 2 = 0 THEN 'Donación Social' ELSE 'Venta Preferencial' END AS tipo_destino,
    CAST(2.00 + (n % 10) * 0.50 AS DECIMAL(10,2)) AS precio_rescate,
    CASE WHEN n % 3 = 0 THEN 'Agotado' ELSE 'Disponible' END AS estado_lote
FROM Nums;
GO

-- 2. Agregar sus 100 registros correspondientes en Pedido_rescate (IDs 101 al 200)
INSERT INTO Pedido_rescate (id_beneficiario, id_sede, fecha_solicitud, costo_total, estado_pedido)
SELECT
    ((id_lote - 1) % 100) + 1,
    id_sede,
    DATEADD(DAY, 1, fecha_ingreso_merma),
    ROUND(precio_rescate * 5.00, 2),
    CASE WHEN id_lote % 6 = 0 THEN 'Pendiente' ELSE 'Entregado' END
FROM Lote_merma
WHERE id_lote > 100;
GO

-- 3. Agregar sus 100 registros correspondientes en detalle_pedido_rescate (IDs 101 al 200)
INSERT INTO detalle_pedido_rescate (id_pedido, id_lote, cantidad_solicitada, subtotal)
SELECT
    p.id_pedido,
    l.id_lote,
    5.00,
    p.costo_total
FROM Pedido_rescate p
INNER JOIN Lote_merma l ON p.id_pedido = l.id_lote
WHERE p.id_pedido > 100;
GO

-- 4. Agregar sus 100 registros correspondientes en Entrega_despacho (IDs 101 al 200)
INSERT INTO Entrega_despacho (id_pedido, responsable_transporte, fecha_hora_salida, fecha_hora_recepcion, conformidad_recibida, firma_o_constancia)
SELECT
    id_pedido,
    CASE (id_pedido % 4)
        WHEN 0 THEN 'Logística Tottus Express 1'
        WHEN 1 THEN 'Transportes San Martín 1'
        WHEN 2 THEN 'Servicios Logísticos del Norte'
        ELSE 'Logística Tottus Express 2'
    END,
    DATEADD(HOUR, 8, CAST(fecha_solicitud AS DATETIME)),
    DATEADD(HOUR, 10, CAST(fecha_solicitud AS DATETIME)),
    CASE WHEN estado_pedido = 'Pendiente' THEN 'Pendiente' ELSE 'Conforme' END,
    CASE WHEN estado_pedido = 'Pendiente' THEN NULL ELSE CONCAT('CONST-', RIGHT('0000' + CAST(id_pedido AS VARCHAR(4)), 4)) END
FROM Pedido_rescate
WHERE id_pedido > 100;
GO

-- 5. LIMPIAR CACHÉ Y MEDIR EL TIEMPO DEL ETL CON 200 REGISTROS
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

-- Comando nativo de SQL Server para mostrar tiempo de CPU y tiempo transcurrido en "Mensajes"
SET STATISTICS TIME ON;
GO

DECLARE @Inicio DATETIME2 = SYSDATETIME();

EXEC DM_Tottus_Merma.dbo.sp_Ejecutar_ETL_Tottus;

DECLARE @Fin DATETIME2 = SYSDATETIME();
DECLARE @Ms INT = DATEDIFF(MILLISECOND, @Inicio, @Fin);

SET STATISTICS TIME OFF;
GO

-- Tabla resumen en la pestaña "Resultados"
SELECT 
    COUNT(*) AS Filas_En_Fact,
    (SELECT DATEDIFF(MILLISECOND, MAX(create_date), SYSDATETIME()) FROM sys.objects WHERE name = 'sp_Ejecutar_ETL_Tottus') AS Ref_Check
FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate;
GO

-- 5. LIMPIAR CACHÉ Y MEDIR EL TIEMPO DEL ETL CON 200 REGISTROS
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS TIME ON;

DECLARE @Inicio DATETIME2 = SYSDATETIME();
EXEC DM_Tottus_Merma.dbo.sp_Ejecutar_ETL_Tottus;
DECLARE @Fin DATETIME2 = SYSDATETIME();

SET STATISTICS TIME OFF;

SELECT 
    (SELECT COUNT(*) FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate) AS Filas_En_Fact,
    DATEDIFF(MILLISECOND, @Inicio, @Fin) AS Tiempo_ETL_ms,
    CAST(DATEDIFF(MILLISECOND, @Inicio, @Fin) / 1000.0 AS DECIMAL(10,3)) AS Tiempo_ETL_seg;
GO