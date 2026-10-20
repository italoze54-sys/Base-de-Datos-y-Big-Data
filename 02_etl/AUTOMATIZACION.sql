-- ============================================================================
-- 3.4.3 AUTOMATIZACIÓN DEL PROCESO ETL (SQL SERVER AGENT + STORED PROCEDURE)
-- Proyecto: Sistema de Rescate y Gestión de Mermas - Hipermercados Tottus
-- ============================================================================

USE DM_Tottus_Merma;
GO

-- ----------------------------------------------------------------------------
-- PARTE 1: ENCAPSULAMIENTO EN PROCEDIMIENTO ALMACENADO (sp_Ejecutar_ETL_Tottus)
-- ----------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Ejecutar_ETL_Tottus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Ejecutar_ETL_Tottus;
GO

CREATE PROCEDURE dbo.sp_Ejecutar_ETL_Tottus
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Limpieza de tablas OLAP e identidades (Garantiza Idempotencia)
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

        -- 2. Carga de Dimensiones
        INSERT INTO DM_Tottus_Merma.dbo.dim_Producto (codigo_barras, nombre_producto, categoria, unidad_medida, precio_original)
        SELECT p.codigo_barras, p.nombre_producto, c.nombre_categoria, p.unidad_medida, p.precio_original
        FROM TOTTUSMERMA.dbo.Producto p
        INNER JOIN TOTTUSMERMA.dbo.Categoria c ON p.id_categoria = c.id_categoria;

        INSERT INTO DM_Tottus_Merma.dbo.dim_Sede (codigo_tienda, nombre_sede, direccion, distrito)
        SELECT CONCAT('TOT-', RIGHT('000' + CAST(id_sede AS VARCHAR(3)), 3)), nombre_sede, direccion, distrito
        FROM TOTTUSMERMA.dbo.Sede_Tottus;

        INSERT INTO DM_Tottus_Merma.dbo.dim_Beneficiario (tipo_beneficiario, nombre_institucion, ruc_o_codigo_midis, distrito)
        SELECT tipo_beneficiario, nombre_institucion, ruc_o_codigo_midis, distrito
        FROM TOTTUSMERMA.dbo.Beneficiario;

        INSERT INTO DM_Tottus_Merma.dbo.dim_Lote (fecha_ingreso_merma, fecha_vencimiento, tipo_destino, estado_lote)
        SELECT fecha_ingreso_merma, fecha_vencimiento, tipo_destino, estado_lote
        FROM TOTTUSMERMA.dbo.Lote_merma;

        INSERT INTO DM_Tottus_Merma.dbo.dim_Canal_Rescate (nombre_canal, tipo_operacion)
        VALUES 
        ('Donación a Ollas Comunes', 'Social Gratuita'),
        ('Donación a Comedores Populares', 'Social Gratuita'),
        ('Venta a Bodegas y Minimarkets', 'Comercial Simbólica'),
        ('Venta a Pequeños Restaurantes / Menús', 'Comercial Simbólica'),
        ('Descarte / Baja Irrecuperable', 'Baja por Caducidad');

        -- Carga dinámica de la dimensión tiempo
        DECLARE @inicio DATE, @fin DATE;
        SELECT @inicio = MIN(fecha_solicitud), @fin = MAX(fecha_solicitud) FROM TOTTUSMERMA.dbo.Pedido_rescate;
        IF @inicio IS NULL SET @inicio = '2026-06-01';
        IF @fin IS NULL SET @fin = '2026-08-31';

        WHILE (@inicio <= @fin)
        BEGIN
            DECLARE @id_calc INT = CAST(CONVERT(VARCHAR(8), @inicio, 112) AS INT);
            IF NOT EXISTS (SELECT 1 FROM dim_Tiempo WHERE id_tiempo = @id_calc)
            BEGIN
                INSERT INTO dim_Tiempo (id_tiempo, fecha, numero_semana, mes, nombre_mes, año)
                VALUES (@id_calc, @inicio, DATEPART(WEEK, @inicio), MONTH(@inicio), DATENAME(MONTH, @inicio), YEAR(@inicio));
            END;
            SET @inicio = DATEADD(DAY, 1, @inicio);
        END;

        -- 3. Carga de la Tabla de Hechos
        INSERT INTO DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate (
            id_tiempo, id_producto, id_lote, id_sede, id_beneficiario, id_canal,
            cantidad_rescatada, cantidad_merma_perdida, monto_perdida_merma, monto_recuperado_rescate, ahorro_social_donado
        )
        SELECT 
            CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT),
            dp.id_producto, dl.id_lote, ds.id_sede, db.id_beneficiario,
            CASE 
                WHEN b.tipo_beneficiario = 'Olla Comun' THEN 1
                WHEN b.tipo_beneficiario = 'Comedor Popular' THEN 2
                WHEN b.tipo_beneficiario = 'Bodega Aliada MYPE' THEN 3
                ELSE 4
            END,
            SUM(dpr.cantidad_solicitada), 0.00, 0.00, SUM(dpr.subtotal),
            SUM(dpr.cantidad_solicitada * prod.precio_original) - SUM(dpr.subtotal)
        FROM TOTTUSMERMA.dbo.Pedido_rescate pr
        INNER JOIN TOTTUSMERMA.dbo.detalle_pedido_rescate dpr ON pr.id_pedido = dpr.id_pedido
        INNER JOIN TOTTUSMERMA.dbo.Lote_merma lm ON dpr.id_lote = lm.id_lote
        INNER JOIN TOTTUSMERMA.dbo.Producto prod ON lm.id_producto = prod.id_producto
        INNER JOIN TOTTUSMERMA.dbo.Beneficiario b ON pr.id_beneficiario = b.id_beneficiario
        INNER JOIN TOTTUSMERMA.dbo.Sede_Tottus st ON pr.id_sede = st.id_sede
        INNER JOIN DM_Tottus_Merma.dbo.dim_Producto dp ON prod.codigo_barras = dp.codigo_barras
        INNER JOIN DM_Tottus_Merma.dbo.dim_Beneficiario db ON b.ruc_o_codigo_midis = db.ruc_o_codigo_midis
        INNER JOIN DM_Tottus_Merma.dbo.dim_Sede ds ON st.nombre_sede = ds.nombre_sede
        INNER JOIN DM_Tottus_Merma.dbo.dim_Lote dl ON lm.id_lote = dl.id_lote
        GROUP BY CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT), dp.id_producto, dl.id_lote, ds.id_sede, db.id_beneficiario, b.tipo_beneficiario;

        COMMIT TRANSACTION;
        PRINT 'ETL ejecutado con éxito e idempotencia garantizada.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ----------------------------------------------------------------------------
-- PARTE 2: PROGRAMACIÓN DE TAREA DESATENDIDA (JOB EN SQL SERVER AGENT)
-- ----------------------------------------------------------------------------
USE msdb;
GO

-- Elimina el job previo si existe
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = 'Job_ETL_Diario_Tottus')
    EXEC sp_delete_job @job_name = 'Job_ETL_Diario_Tottus';
GO

-- Crear el nuevo Job
EXEC sp_add_job 
    @job_name = 'Job_ETL_Diario_Tottus', 
    @enabled = 1, 
    @description = 'Ejecución automática diaria del ETL de Mermas a las 02:00 AM';

-- Crear el Paso 1: Ejecutar el procedimiento almacenado
EXEC sp_add_jobstep 
    @job_name = 'Job_ETL_Diario_Tottus', 
    @step_name = 'Ejecutar Stored Procedure ETL', 
    @subsystem = 'TSQL', 
    @command = 'EXEC DM_Tottus_Merma.dbo.sp_Ejecutar_ETL_Tottus;', 
    @database_name = 'DM_Tottus_Merma';

-- Programar el horario (Schedule): Todos los días a las 02:00:00 AM
EXEC sp_add_jobschedule 
    @job_name = 'Job_ETL_Diario_Tottus', 
    @name = 'Programacion_Diaria_Nocturna', 
    @freq_type = 4,         -- Frecuencia diaria
    @freq_interval = 1,     -- Cada 1 día
    @active_start_time = 020000; -- 02:00:00 AM

-- Asignar el job al servidor local
EXEC sp_add_jobserver 
    @job_name = 'Job_ETL_Diario_Tottus', 
    @server_name = '(local)';
GO



USE DM_Tottus_Merma;
GO

SELECT 'dim_Tiempo' AS Tabla, COUNT(*) AS Total FROM dim_Tiempo
UNION ALL
SELECT 'dim_Producto', COUNT(*) FROM dim_Producto
UNION ALL
SELECT 'dim_Sede', COUNT(*) FROM dim_Sede
UNION ALL
SELECT 'dim_Beneficiario', COUNT(*) FROM dim_Beneficiario
UNION ALL
SELECT 'dim_Lote', COUNT(*) FROM dim_Lote
UNION ALL
SELECT 'dim_Canal_Rescate', COUNT(*) FROM dim_Canal_Rescate
UNION ALL
SELECT 'fact_Gestion_Merma_Rescate', COUNT(*) FROM fact_Gestion_Merma_Rescate;
GO