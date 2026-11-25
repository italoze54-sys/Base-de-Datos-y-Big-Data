USE TOTTUSMERMA;
GO

-- 1. Limpiar tablas transaccionales y reiniciar IDENTITY a 0
DELETE FROM Entrega_despacho;
DELETE FROM detalle_pedido_rescate;
DELETE FROM Pedido_rescate;
DELETE FROM Lote_merma;

DBCC CHECKIDENT ('Entrega_despacho', RESEED, 0);
DBCC CHECKIDENT ('detalle_pedido_rescate', RESEED, 0);
DBCC CHECKIDENT ('Pedido_rescate', RESEED, 0);
DBCC CHECKIDENT ('Lote_merma', RESEED, 0);
GO

-- 2. Poblar Lote_merma con 1,000,000 de registros (IDs 1 al 1,000,000)
;WITH E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
      E2(N) AS (SELECT 1 FROM E1 a, E1 b),
      E4(N) AS (SELECT 1 FROM E2 a, E2 b),
      E6(N) AS (SELECT 1 FROM E4 a, E2 b),
      Nums AS (SELECT TOP 1000000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM E6)
INSERT INTO Lote_merma (id_producto, id_sede, fecha_ingreso_merma, fecha_vencimiento, cantidad_disponible, tipo_destino, precio_rescate, estado_lote)
SELECT
    ((n - 1) % 100) + 1 AS id_producto,
    ((n - 1) % 20) + 1 AS id_sede,
    DATEADD(DAY, (n % 90), '2026-06-01') AS fecha_ingreso_merma,
    DATEADD(DAY, (n % 90) + 3, '2026-06-01') AS fecha_vencimiento,
    CAST(10.00 + (n % 40) AS DECIMAL(10,2)) AS cantidad_disponible,
    CASE WHEN n % 2 = 0 THEN 'Donación Social' ELSE 'Venta Preferencial' END AS tipo_destino,
    CAST(1.50 + (n % 15) * 0.50 AS DECIMAL(10,2)) AS precio_rescate,
    CASE WHEN n % 3 = 0 THEN 'Agotado' ELSE 'Disponible' END AS estado_lote
FROM Nums;
GO

-- 3. Poblar Pedido_rescate con 1,000,000 de registros
INSERT INTO Pedido_rescate (id_beneficiario, id_sede, fecha_solicitud, costo_total, estado_pedido)
SELECT
    ((id_lote - 1) % 100) + 1,
    id_sede,
    DATEADD(DAY, 1, fecha_ingreso_merma),
    ROUND(precio_rescate * 5.00, 2),
    CASE WHEN id_lote % 6 = 0 THEN 'Pendiente' ELSE 'Entregado' END
FROM Lote_merma;
GO

-- 4. Poblar detalle_pedido_rescate con 1,000,000 de registros
INSERT INTO detalle_pedido_rescate (id_pedido, id_lote, cantidad_solicitada, subtotal)
SELECT
    p.id_pedido,
    l.id_lote,
    5.00,
    p.costo_total
FROM Pedido_rescate p
INNER JOIN Lote_merma l ON p.id_pedido = l.id_lote;
GO

-- 5. Poblar Entrega_despacho con 1,000,000 de registros
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
    CASE WHEN estado_pedido = 'Pendiente' THEN NULL ELSE CONCAT('CONST-', RIGHT('0000000' + CAST(id_pedido AS VARCHAR(7)), 7)) END
FROM Pedido_rescate;
GO

-- 6. LIMPIAR CACHÉ Y MEDIR EL TIEMPO DEL ETL CON 1,000,000 DE REGISTROS
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
    CAST(DATEDIFF(MILLISECOND, @Inicio, @Fin) / 1000.0 AS DECIMAL(10,3)) AS Tiempo_ETL_seg,
    CAST(1000000.0 / NULLIF(DATEDIFF(MILLISECOND, @Inicio, @Fin) / 1000.0, 0) AS DECIMAL(12,2)) AS Throughput_Filas_Seg;
GO