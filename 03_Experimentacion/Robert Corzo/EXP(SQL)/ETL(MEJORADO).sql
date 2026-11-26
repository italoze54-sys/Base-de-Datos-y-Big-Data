USE DM_Tottus_Merma;
GO

IF OBJECT_ID('dbo.sp_Ejecutar_ETL_Incremental_Tottus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Ejecutar_ETL_Incremental_Tottus;
GO

CREATE PROCEDURE dbo.sp_Ejecutar_ETL_Incremental_Tottus
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Asegurar tabla de cuarentena en OLTP
        IF OBJECT_ID('TOTTUSMERMA.dbo.Cuarentena_Errores_ETL', 'U') IS NULL
        BEGIN
            CREATE TABLE TOTTUSMERMA.dbo.Cuarentena_Errores_ETL (
                id_error INT IDENTITY(1,1) PRIMARY KEY,
                tabla_origen VARCHAR(50) NOT NULL,
                id_registro_origen INT NOT NULL,
                tipo_inconsistencia VARCHAR(100) NOT NULL,
                fecha_registro DATETIME DEFAULT GETDATE()
            );
            CREATE INDEX IX_Cuarentena_Tabla_Id
                ON TOTTUSMERMA.dbo.Cuarentena_Errores_ETL (tabla_origen, id_registro_origen);
        END;

        -- 2. Registrar solo inconsistencias nuevas en cuarentena
        INSERT INTO TOTTUSMERMA.dbo.Cuarentena_Errores_ETL (tabla_origen, id_registro_origen, tipo_inconsistencia)
        SELECT 'Lote_merma', lm.id_lote, 'Fecha de vencimiento anterior a fecha de ingreso'
        FROM TOTTUSMERMA.dbo.Lote_merma lm
        WHERE (lm.fecha_vencimiento < lm.fecha_ingreso_merma OR lm.fecha_vencimiento IS NULL)
          AND NOT EXISTS (
              SELECT 1
              FROM TOTTUSMERMA.dbo.Cuarentena_Errores_ETL c
              WHERE c.tabla_origen = 'Lote_merma'
                AND c.id_registro_origen = lm.id_lote
          );

        INSERT INTO TOTTUSMERMA.dbo.Cuarentena_Errores_ETL (tabla_origen, id_registro_origen, tipo_inconsistencia)
        SELECT 'Producto', p.id_producto, 'Producto sin código de barras o formato inválido'
        FROM TOTTUSMERMA.dbo.Producto p
        WHERE (p.codigo_barras IS NULL OR LTRIM(RTRIM(p.codigo_barras)) = '')
          AND NOT EXISTS (
              SELECT 1
              FROM TOTTUSMERMA.dbo.Cuarentena_Errores_ETL c
              WHERE c.tabla_origen = 'Producto'
                AND c.id_registro_origen = p.id_producto
          );

        -- 3. Carga incremental de dimensiones (solo registros nuevos)
        INSERT INTO DM_Tottus_Merma.dbo.dim_Producto (
            codigo_barras, nombre_producto, categoria, unidad_medida, precio_original
        )
        SELECT
            p.codigo_barras,
            p.nombre_producto,
            c.nombre_categoria,
            p.unidad_medida,
            p.precio_original
        FROM TOTTUSMERMA.dbo.Producto p
        INNER JOIN TOTTUSMERMA.dbo.Categoria c
            ON p.id_categoria = c.id_categoria
        LEFT JOIN TOTTUSMERMA.dbo.Cuarentena_Errores_ETL cua
            ON cua.id_registro_origen = p.id_producto
           AND cua.tabla_origen = 'Producto'
        WHERE cua.id_error IS NULL
          AND NOT EXISTS (
              SELECT 1
              FROM DM_Tottus_Merma.dbo.dim_Producto dp
              WHERE dp.codigo_barras = p.codigo_barras
          );

        INSERT INTO DM_Tottus_Merma.dbo.dim_Sede (
            codigo_tienda, nombre_sede, direccion, distrito
        )
        SELECT
            CAST(st.id_sede AS VARCHAR(10)),
            st.nombre_sede,
            st.direccion,
            st.distrito
        FROM TOTTUSMERMA.dbo.Sede_Tottus st
        WHERE NOT EXISTS (
            SELECT 1
            FROM DM_Tottus_Merma.dbo.dim_Sede ds
            WHERE ds.codigo_tienda = CAST(st.id_sede AS VARCHAR(10))
        );

        INSERT INTO DM_Tottus_Merma.dbo.dim_Beneficiario (
            tipo_beneficiario, nombre_institucion, ruc_o_codigo_midis, distrito
        )
        SELECT
            b.tipo_beneficiario,
            b.nombre_institucion,
            b.ruc_o_codigo_midis,
            b.distrito
        FROM TOTTUSMERMA.dbo.Beneficiario b
        WHERE NOT EXISTS (
            SELECT 1
            FROM DM_Tottus_Merma.dbo.dim_Beneficiario db
            WHERE db.ruc_o_codigo_midis = b.ruc_o_codigo_midis
        );

        INSERT INTO DM_Tottus_Merma.dbo.dim_Lote (
            fecha_ingreso_merma, fecha_vencimiento, tipo_destino, estado_lote
        )
        SELECT
            lm.fecha_ingreso_merma,
            lm.fecha_vencimiento,
            lm.tipo_destino,
            lm.estado_lote
        FROM TOTTUSMERMA.dbo.Lote_merma lm
        LEFT JOIN TOTTUSMERMA.dbo.Cuarentena_Errores_ETL cua
            ON cua.id_registro_origen = lm.id_lote
           AND cua.tabla_origen = 'Lote_merma'
        WHERE cua.id_error IS NULL
          AND NOT EXISTS (
              SELECT 1
              FROM DM_Tottus_Merma.dbo.dim_Lote dl
              WHERE dl.fecha_ingreso_merma = lm.fecha_ingreso_merma
                AND dl.fecha_vencimiento = lm.fecha_vencimiento
                AND dl.tipo_destino = lm.tipo_destino
                AND dl.estado_lote = lm.estado_lote
          );

        INSERT INTO DM_Tottus_Merma.dbo.dim_Canal_Rescate (
            nombre_canal, tipo_operacion
        )
        SELECT DISTINCT
            lm.tipo_destino,
            CASE
                WHEN lm.tipo_destino LIKE '%Donación%' THEN 'Social Gratuita'
                WHEN lm.tipo_destino LIKE '%Venta%' THEN 'Comercial Simbólica'
                ELSE 'Operación Estándar'
            END
        FROM TOTTUSMERMA.dbo.Lote_merma lm
        WHERE NOT EXISTS (
            SELECT 1
            FROM DM_Tottus_Merma.dbo.dim_Canal_Rescate dc
            WHERE dc.nombre_canal = lm.tipo_destino
        );

        -- 4. Dimensión tiempo incremental en una sola pasada
        DECLARE @inicio DATE, @fin DATE;
        SELECT
            @inicio = MIN(fecha_solicitud),
            @fin = MAX(fecha_solicitud)
        FROM TOTTUSMERMA.dbo.Pedido_rescate;

        IF @inicio IS NOT NULL AND @fin IS NOT NULL
        BEGIN
            ;WITH Calendario AS (
                SELECT @inicio AS fecha
                UNION ALL
                SELECT DATEADD(DAY, 1, fecha)
                FROM Calendario
                WHERE fecha < @fin
            )
            INSERT INTO DM_Tottus_Merma.dbo.dim_Tiempo (
                id_tiempo, fecha, numero_semana, mes, nombre_mes, año
            )
            SELECT
                CAST(CONVERT(VARCHAR(8), cal.fecha, 112) AS INT),
                cal.fecha,
                DATEPART(WEEK, cal.fecha),
                MONTH(cal.fecha),
                DATENAME(MONTH, cal.fecha),
                YEAR(cal.fecha)
            FROM Calendario cal
            WHERE NOT EXISTS (
                SELECT 1
                FROM DM_Tottus_Merma.dbo.dim_Tiempo dt
                WHERE dt.fecha = cal.fecha
            )
            OPTION (MAXRECURSION 0);
        END;

        -- 5. Carga incremental en Tabla de Hechos (solo lotes/combinaciones aún no cargadas)
        ;WITH ResumenRescate AS (
            SELECT
                CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT) AS id_tiempo,
                prod.codigo_barras,
                b.ruc_o_codigo_midis,
                st.nombre_sede,
                lm.id_lote,
                lm.tipo_destino,
                lm.cantidad_disponible,
                prod.precio_original,
                SUM(dpr.cantidad_solicitada) AS total_rescatado,
                SUM(dpr.subtotal) AS total_recuperado,
                SUM(dpr.cantidad_solicitada * prod.precio_original) AS valor_bruto_rescatado
            FROM TOTTUSMERMA.dbo.Pedido_rescate pr
            INNER JOIN TOTTUSMERMA.dbo.detalle_pedido_rescate dpr
                ON pr.id_pedido = dpr.id_pedido
            INNER JOIN TOTTUSMERMA.dbo.Lote_merma lm
                ON dpr.id_lote = lm.id_lote
            INNER JOIN TOTTUSMERMA.dbo.Producto prod
                ON lm.id_producto = prod.id_producto
            INNER JOIN TOTTUSMERMA.dbo.Beneficiario b
                ON pr.id_beneficiario = b.id_beneficiario
            INNER JOIN TOTTUSMERMA.dbo.Sede_Tottus st
                ON pr.id_sede = st.id_sede
            LEFT JOIN TOTTUSMERMA.dbo.Cuarentena_Errores_ETL cua
                ON cua.id_registro_origen = lm.id_lote
               AND cua.tabla_origen = 'Lote_merma'
            WHERE cua.id_error IS NULL
            GROUP BY
                CAST(CONVERT(VARCHAR(8), pr.fecha_solicitud, 112) AS INT),
                prod.codigo_barras,
                b.ruc_o_codigo_midis,
                st.nombre_sede,
                lm.id_lote,
                lm.tipo_destino,
                lm.cantidad_disponible,
                prod.precio_original
        ),
        CalculoMerma AS (
            SELECT
                *,
                CASE
                    WHEN (cantidad_disponible - total_rescatado) > 0
                    THEN (cantidad_disponible - total_rescatado)
                    ELSE CAST(0.00 AS DECIMAL(8,2))
                END AS merma_no_rescatada
            FROM ResumenRescate
        )
        INSERT INTO DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate (
            id_tiempo, id_producto, id_lote, id_sede, id_beneficiario, id_canal,
            cantidad_rescatada, cantidad_merma_perdida, monto_perdida_merma,
            monto_recuperado_rescate, ahorro_social_donado
        )
        SELECT
            cm.id_tiempo,
            dp.id_producto,
            dl.id_lote,
            ds.id_sede,
            db.id_beneficiario,
            dc.id_canal,
            cm.total_rescatado,
            cm.merma_no_rescatada,
            cm.merma_no_rescatada * cm.precio_original,
            cm.total_recuperado,
            cm.valor_bruto_rescatado - cm.total_recuperado
        FROM CalculoMerma cm
        INNER JOIN DM_Tottus_Merma.dbo.dim_Producto dp
            ON cm.codigo_barras = dp.codigo_barras
        INNER JOIN DM_Tottus_Merma.dbo.dim_Beneficiario db
            ON cm.ruc_o_codigo_midis = db.ruc_o_codigo_midis
        INNER JOIN DM_Tottus_Merma.dbo.dim_Sede ds
            ON cm.nombre_sede = ds.nombre_sede
        INNER JOIN DM_Tottus_Merma.dbo.dim_Lote dl
            ON cm.id_lote = dl.id_lote
        INNER JOIN DM_Tottus_Merma.dbo.dim_Canal_Rescate dc
            ON cm.tipo_destino = dc.nombre_canal
        WHERE NOT EXISTS (
            SELECT 1
            FROM DM_Tottus_Merma.dbo.fact_Gestion_Merma_Rescate f
            WHERE f.id_tiempo = cm.id_tiempo
              AND f.id_producto = dp.id_producto
              AND f.id_lote = dl.id_lote
              AND f.id_sede = ds.id_sede
              AND f.id_beneficiario = db.id_beneficiario
              AND f.id_canal = dc.id_canal
        );

        COMMIT TRANSACTION;
        PRINT 'ETL incremental ejecutado con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO