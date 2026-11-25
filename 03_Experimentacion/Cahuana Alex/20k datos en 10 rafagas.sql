USE TOTTUSMERMA;
GO

-- 1. Crear tabla de captura en vivo de eventos de góndola/almacén
IF OBJECT_ID('dbo.Auditoria_Gondola_Live', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Gondola_Live;
GO

CREATE TABLE dbo.Auditoria_Gondola_Live (
    id_evento INT IDENTITY(1,1) PRIMARY KEY,
    id_lote INT NOT NULL,
    id_sede INT NOT NULL,
    fecha_lectura DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cantidad_disponible DECIMAL(10,2) NOT NULL
);
GO

-- Limpiar caché previa
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS TIME ON;

DECLARE @Inicio DATETIME2 = SYSDATETIME();
DECLARE @Rafaga INT = 1;

-- 2. Simular llegada de 5 ráfagas de 20,000 lecturas cada una (100,000 total)
WHILE @Rafaga <= 10
BEGIN
    ;WITH E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
          E2(N) AS (SELECT 1 FROM E1 a, E1 b),
          E5(N) AS (SELECT 1 FROM E2 a, E2 b, E1 c),
          Nums AS (SELECT TOP 20000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM E5)
    INSERT INTO dbo.Auditoria_Gondola_Live (id_lote, id_sede, fecha_lectura, fecha_vencimiento, cantidad_disponible)
    SELECT
        ((@Rafaga - 1) * 20000) + n AS id_lote,
        ((((@Rafaga - 1) * 20000) + n - 1) % 20) + 1 AS id_sede,
        CAST('2026-07-15' AS DATE) AS fecha_lectura,
        DATEADD(DAY, ((((@Rafaga - 1) * 20000) + n - 1) % 5) + 1, '2026-07-15') AS fecha_vencimiento,
        CAST(10.00 + ((((@Rafaga - 1) * 20000) + n - 1) % 30) AS DECIMAL(10,2)) AS cantidad_disponible
    FROM Nums;

    SET @Rafaga = @Rafaga + 1;
END;

-- 3. Consulta analítica de detección de alertas tempranas por sede
SELECT 
    s.nombre_sede,
    CASE 
        WHEN DATEDIFF(DAY, a.fecha_lectura, a.fecha_vencimiento) <= 2 THEN 'CRÍTICO (<=48h)'
        WHEN DATEDIFF(DAY, a.fecha_lectura, a.fecha_vencimiento) = 3 THEN 'PREVENTIVO (72h)'
        ELSE 'NORMAL (>72h)'
    END AS nivel_alerta,
    COUNT(*) AS lotes_detectados,
    SUM(a.cantidad_disponible) AS unidades_en_riesgo
INTO #Resumen_Alertas_Live
FROM dbo.Auditoria_Gondola_Live a
INNER JOIN dbo.Sede_Tottus s ON a.id_sede = s.id_sede
GROUP BY 
    s.nombre_sede,
    CASE 
        WHEN DATEDIFF(DAY, a.fecha_lectura, a.fecha_vencimiento) <= 2 THEN 'CRÍTICO (<=48h)'
        WHEN DATEDIFF(DAY, a.fecha_lectura, a.fecha_vencimiento) = 3 THEN 'PREVENTIVO (72h)'
        ELSE 'NORMAL (>72h)'
    END;

DECLARE @Fin DATETIME2 = SYSDATETIME();
DECLARE @Ms INT = DATEDIFF(MILLISECOND, @Inicio, @Fin);

SET STATISTICS TIME OFF;

-- 4. Mostrar métricas de rendimiento y resultado de alertas
SELECT 
    200000 AS Eventos_Procesados,
    @Ms AS Tiempo_Total_ms,
    CAST(@Ms / 1000.0 AS DECIMAL(10,3)) AS Tiempo_Total_seg,
    CAST(200000.0 / NULLIF(@Ms / 1000.0, 0) AS DECIMAL(12,2)) AS Throughput_Eventos_Seg,
    CASE WHEN @Ms < 3000 THEN 'CUMPLE SLA (<3s)' ELSE 'EXCEDE SLA (>3s)' END AS Estado_SLA;

SELECT TOP 10 * FROM #Resumen_Alertas_Live ORDER BY unidades_en_riesgo DESC;
DROP TABLE #Resumen_Alertas_Live;
GO