USE ParquesNacionales
GO

SET NOCOUNT ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Ticket de Venta (GENERABLE)
-- =============================================
CREATE OR ALTER PROCEDURE Ventas.GenerarTicketsDeVenta (@fecha_inicio DATE, @fecha_fin DATE = @fecha_inicio, @hora_apertura TIME = '07:00:00', @hora_cierre TIME = '19:00:00')
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            --ITERAR POR TIEMPO, NO POR CANTIDAD DE VENTAS
            DECLARE @punto_venta_id INT;
            DECLARE @parque_id INT;
            DECLARE @forma_pago INT;
            DECLARE @divisa_id INT;
            DECLARE @es_extranjero BIT;
            DECLARE @cotizacion DECIMAL(18, 2);
            DECLARE @f_actualizacion DATETIME;
            DECLARE @f_inicio DATETIME = CAST(@fecha_inicio AS DATETIME) + CAST(@hora_apertura AS DATETIME);
            DECLARE @f_fin DATETIME = CAST(@fecha_fin AS DATETIME) + CAST(@hora_cierre AS DATETIME);
            
            SELECT TOP 1 @punto_venta_id = id, @parque_id = parque_id FROM Administracion.PuntosDeVenta ORDER BY NEWID();
            WHILE @f_inicio <= @f_fin
            BEGIN
                --PUNTO DE VENTA
                --PARQUE
                SELECT TOP 1 @punto_venta_id = id, @parque_id = parque_id
                    FROM Administracion.PuntosDeVenta ptoVenta
                    WHERE NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE punto_venta_id = ptoVenta.id AND parque_id = ptoVenta.parque_id AND f_generacion = @f_inicio)
                    ORDER BY NEWID();
                IF @punto_venta_id IS NULL OR @parque_id IS NULL
                BEGIN
                    DECLARE @incremento_max INT;

                    SET @incremento_max =
                    CASE
                        -- Verano (alta temporada)
                        WHEN MONTH(@f_inicio) IN (1, 2) THEN 15

                        -- Vacaciones de invierno
                        WHEN MONTH(@f_inicio) = 7 THEN 20

                        -- Temporada media
                        WHEN MONTH(@f_inicio) IN (3, 4, 9, 10, 11, 12) THEN 30

                        -- Temporada baja
                        ELSE 45
                    END;

                    DECLARE @incremento INT = ABS(CHECKSUM(NEWID()) % @incremento_max);
                    IF CAST(CAST(@f_inicio AS DATE) AS DATETIME) + CAST(@hora_cierre AS DATETIME) < DATEADD(SECOND, @incremento, @f_inicio)
                    BEGIN
                        -- Pasó la hora de cierre: ir al día siguiente a la hora de apertura
                        SET @f_inicio =
                            CAST(DATEADD(DAY, 1, CAST(@f_inicio AS DATE)) AS DATETIME)
                            + CAST(@hora_apertura AS DATETIME);
                    END
                    ELSE
                    BEGIN
                        -- Sigue dentro del horario del día actual
                        SET @f_inicio = DATEADD(SECOND, @incremento, @f_inicio);
                    END
                END

                --FORMA DE PAGO
                SET @forma_pago = (SELECT TOP 1 id FROM Administracion.FormasDePago ORDER BY NEWID());
    
                --DIVISA
                SET @divisa_id = (SELECT id FROM Administracion.Divisas WHERE codigo_iso = 'ARS');
                SET @cotizacion = NULL;
    
                --COTIZACION DE LA DIVISA EN EL MOMENTO
                SET @es_extranjero = (SELECT CAST(0.15 + RAND(CHECKSUM(NEWID())) AS INT));
                IF @es_extranjero = 1
                BEGIN
                    SET @divisa_id = (SELECT TOP 1 id FROM Administracion.Divisas WHERE codigo_iso <> 'ARS' ORDER BY NEWID());
                    SELECT @cotizacion = cotizacion, @f_actualizacion = f_actualizacion FROM Administracion.Divisas WHERE id = @divisa_id;
                    DECLARE @desfazaje INT = DATEDIFF(HOUR, ISNULL(@f_actualizacion, '1900-01-01T00:00:00'), GETDATE());
                    IF @desfazaje > 24
                    BEGIN
                        EXEC Administracion.ActualizarCotizacionDivisa @divisa_id;
                    END
                END

                --FECHA DE GENERACION
                --DECLARE @total DECIMAL(12, 2) = NULL;
    
                --SELECT @punto_venta_id, @parque_id, @forma_pago, @divisa_id, @cotizacion, @f_generacion, @total
                EXEC Ventas.InsertarTicketsDeVenta @punto_venta_id, @parque_id, @forma_pago, @divisa_id, @cotizacion, @f_inicio, NULL;
    
                --O sino, que decida cuando generar incrementos nulos, para simular ventas de tours y agotar cupos ;D
                --DECLARE @incremento_max INT;

                SET @incremento_max =
                CASE
                    -- Verano (alta temporada)
                    WHEN MONTH(@f_inicio) IN (1, 2) THEN 15

                    -- Vacaciones de invierno
                    WHEN MONTH(@f_inicio) = 7 THEN 20

                    -- Temporada media
                    WHEN MONTH(@f_inicio) IN (3, 4, 9, 10, 11, 12) THEN 30

                    -- Temporada baja
                    ELSE 45
                END;

                SET @incremento = ABS(CHECKSUM(NEWID()) % @incremento_max);
                IF CAST(CAST(@f_inicio AS DATE) AS DATETIME) + CAST(@hora_cierre AS DATETIME) < DATEADD(SECOND, @incremento, @f_inicio)
                BEGIN
                    -- Pasó la hora de cierre: ir al día siguiente a la hora de apertura
                    SET @f_inicio =
                        CAST(DATEADD(DAY, 1, CAST(@f_inicio AS DATE)) AS DATETIME)
                        + CAST(@hora_apertura AS DATETIME);
                END
                ELSE
                BEGIN
                    -- Sigue dentro del horario del día actual
                    SET @f_inicio = DATEADD(MINUTE, @incremento, @f_inicio);
                END
            END

        COMMIT TRANSACTION;
        --ROLLBACK TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Mensaje NVARCHAR(MAX);

        SET @Mensaje = CONCAT(
            'Error N° ', ERROR_NUMBER(),
            '. Línea: ', ERROR_LINE(),
            '. Procedimiento: ', ISNULL(ERROR_PROCEDURE(), 'N/A'),
            '. Descripción: ', ERROR_MESSAGE()
        );

        THROW 50000, @Mensaje, 1;

    END CATCH;
END
GO

-- =============================================
-- Detalle de Venta (GENERABLE)
-- =============================================

CREATE OR ALTER PROCEDURE Ventas.GenerarDetallesDeVenta
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            
            CREATE TABLE #detalles_ticket (
                id INT IDENTITY(1, 1),
                tarifa_id INT NOT NULL,
                parque_id INT NOT NULL,
                tipo_articulo CHAR(1),
                duracion INT,
                cupo INT,
                precio DECIMAL(10, 2)
            )

            DECLARE @indice_ticket INT = 1;
            DECLARE @cant_tickets INT = (SELECT COUNT(1) FROM Ventas.TicketsDeVenta);
            WHILE @indice_ticket <= @cant_tickets
            BEGIN
                --NUMERO TICKET
                DECLARE @ticket_id INT;
                DECLARE @parque_id INT;
                SELECT @ticket_id = id, @parque_id = parque_id FROM Ventas.TicketsDeVenta WHERE id = @indice_ticket;

                --CANTIDAD DE DETALLES POR TICKET
                DECLARE @indice_detalle INT = 1;
                DECLARE @cant_detalles INT = (1 + ABS(CHECKSUM(NEWID())) % 5);
                INSERT INTO #detalles_ticket
                    SELECT TOP (@cant_detalles) id, parque_id, tipo_articulo, duracion, cupo, precio FROM Administracion.TarifasDeArticulo WHERE parque_id = @parque_id 
                    ORDER BY NEWID()

                WHILE @indice_detalle <= @cant_detalles
                BEGIN
                    --TARIFA
                    DECLARE @tarifa_id INT;
                    SELECT @tarifa_id = tarifa_id FROM #detalles_ticket WHERE id = @indice_detalle

                    --TIPOS DE VISITANTE
                    DECLARE @tipo_visitante INT;
                    DECLARE @factor_visitante FLOAT;
                    SELECT @factor_visitante = RAND(CHECKSUM(NEWID()));
                    IF @factor_visitante < 0.4
                    BEGIN
                        SELECT @tipo_visitante = id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Residente Nacional%'
                    END
                    ELSE IF @factor_visitante BETWEEN 0.4 AND 0.65
                    BEGIN
                        SELECT @tipo_visitante = id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Residente Provincial%'
                    END
                    ELSE IF @factor_visitante BETWEEN 0.65 AND 0.75
                    BEGIN
                        SELECT @tipo_visitante = id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Jubilado%'
                    END
                    ELSE IF @factor_visitante BETWEEN 0.75 AND 0.85
                    BEGIN
                        SELECT @tipo_visitante = id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Estudiante%'
                    END
                    ELSE IF @factor_visitante BETWEEN 0.85 AND 1
                    BEGIN
                        SELECT @tipo_visitante = id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Extranjero%'
                    END
  
                    --CANTIDAD DE UNIDADES
                    DECLARE @cantidad INT;
                    SET @cantidad =
                    CASE
                        WHEN RAND(CHECKSUM(NEWID())) < 0.7 THEN 1
                        WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 2
                        ELSE 3
                    END;

                    --GENERACION DETALLE DE TICKET
                    EXEC Ventas.InsertarDetallesDeTicket @ticket_id, @tarifa_id, @tipo_visitante, @cantidad
                    SET @indice_detalle += 1
                END
                TRUNCATE TABLE #detalles_ticket
                SET @indice_ticket = @indice_ticket + 1;
            END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Mensaje NVARCHAR(MAX);

        SET @Mensaje = CONCAT(
            'Error N° ', ERROR_NUMBER(),
            '. Línea: ', ERROR_LINE(),
            '. Procedimiento: ', ISNULL(ERROR_PROCEDURE(), 'N/A'),
            '. Descripción: ', ERROR_MESSAGE()
        );

        THROW 50000, @Mensaje, 1;

    END CATCH;
END
GO

-- =============================================
-- Tours (GENERABLE)
-- =============================================
--Generar TOURS para cada parque en forma periódica, y no a pedido. Por cada pedido, restar el cupo de tour.
CREATE OR ALTER PROCEDURE Ventas.GenerarTours (@fecha_inicio DATE, @fecha_fin DATE = @fecha_inicio, @hora_apertura TIME = '09:00:00', @hora_cierre TIME = '17:00:00')
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @tarifa_id INT; 
            DECLARE @guia_id INT; 
            DECLARE @f_visita SMALLDATETIME;
            DECLARE @precio INT; 
            DECLARE @cant_cupos INT;
            DECLARE @duracion SMALLINT; --Duracion permite saber cada cuanto repetir el tour durante el día.
            DECLARE @f_inicio DATETIME = CAST(@fecha_inicio AS DATETIME) + CAST(@hora_apertura AS DATETIME);
            DECLARE @f_cierre DATETIME = CAST(@fecha_fin AS DATETIME) + CAST(@hora_cierre AS DATETIME);
            
            CREATE TABLE #tours_asignados (
                id INT IDENTITY(1, 1),
                tour_id INT,
                guia_id INT,
                cupo TINYINT,
                duracion SMALLINT,
                precio DECIMAL(10, 2),
                parque_id INT
            );

            --Buscar tours por parque con un guía asignado aleatorio para realizar la excursión
            WITH tours AS (
                SELECT *,
                        ROW_NUMBER() OVER (
                            PARTITION BY parque_id
                            ORDER BY NEWID()
                        ) AS rn
                FROM Administracion.TarifasDeArticulo
                WHERE tipo_articulo = 'T'
            )

            INSERT INTO #tours_asignados     
                SELECT
                    t.id AS tour_id,
                    g.guia_id,
                    t.cupo,
                    t.duracion,
                    t.precio,
                    t.parque_id
                FROM tours t
                CROSS APPLY (
                    SELECT TOP 1
                        ag.guia_id
                    FROM RRHH.AutorizacionesDeGuias ag
                    WHERE ag.articulo_id = t.id
                    ORDER BY NEWID()
                ) g
                WHERE t.rn = 1;

            --Por cada tour de la tabla
            DECLARE @indice_actividad INT = 1;
            DECLARE @cant_actividades INT = (SELECT COUNT(1) FROM #tours_asignados);
            WHILE @indice_actividad <= @cant_actividades
            BEGIN
                SELECT @tarifa_id = tour_id, @guia_id = guia_id, @cant_cupos = cupo, @duracion = duracion, @precio = precio 
                FROM #tours_asignados
                WHERE id = @indice_actividad

                --Por cada período en el día
                SET @f_visita = @f_inicio;
                WHILE @f_visita <= @f_cierre
                BEGIN
                    EXEC Ventas.InsertarTour 
                        @tarifa_id = @tarifa_id, 
                        @guia_id = @guia_id, 
                        @f_visita = @f_visita, 
                        @precio = @precio, 
                        @cant_cupos = @cant_cupos

                    SET @guia_id = (SELECT TOP 1 guia_id FROM RRHH.AutorizacionesDeGuias WHERE articulo_id = @tarifa_id ORDER BY NEWID());

                    IF CAST(CAST(@f_visita AS DATE) AS DATETIME) + CAST(@hora_cierre AS DATETIME) < DATEADD(MINUTE, @duracion, @f_visita)
                    BEGIN
                        -- Pasó la hora de cierre: ir al día siguiente a la hora de apertura
                        SET @f_visita =
                            CAST(DATEADD(DAY, 1, CAST(@f_visita AS DATE)) AS DATETIME)
                            + CAST(@hora_apertura AS DATETIME);
                    END
                    ELSE
                    BEGIN
                        -- Sigue dentro del horario del día actual
                        SET @f_visita = DATEADD(MINUTE, @duracion, @f_visita);
                    END
                END

                SET @indice_actividad += 1;
            END
            --SELECT * FROM Ventas.Tours
        COMMIT TRANSACTION;
        --ROLLBACK TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Mensaje NVARCHAR(MAX);

        SET @Mensaje = CONCAT(
            'Error N° ', ERROR_NUMBER(),
            '. Línea: ', ERROR_LINE(),
            '. Procedimiento: ', ISNULL(ERROR_PROCEDURE(), 'N/A'),
            '. Descripción: ', ERROR_MESSAGE()
        );

        THROW 50000, @Mensaje, 1;

    END CATCH;
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- CARGA
-- =============================================

CREATE OR ALTER PROCEDURE Ventas.GenerarDatos (@fecha_inicio DATE, @fecha_fin DATE = @fecha_inicio, @hora_apertura TIME = '07:00:00', @hora_cierre TIME = '19:00:00')
AS
BEGIN
    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
        BEGIN TRANSACTION;
            EXEC Ventas.GenerarTicketsDeVenta @fecha_inicio, @fecha_fin, @hora_apertura, @hora_cierre 
            
            EXEC Ventas.GenerarTours @fecha_inicio, @fecha_fin, '08:00:00', '17:00:00'
        --COMMIT TRANSACTION
        --BEGIN TRANSACTION
            EXEC Ventas.GenerarDetallesDeVenta 
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
        BEGIN
            DELETE FROM Ventas.TicketsDeVenta
            DBCC CHECKIDENT ('Ventas.TicketsDeVenta', 'RESEED', 0)
            DELETE FROM Ventas.DetallesDeTicket
            DELETE FROM Ventas.Entradas
            DBCC CHECKIDENT ('Ventas.Entradas', 'RESEED', 0)
            DELETE FROM Ventas.Actividades
            DBCC CHECKIDENT ('Ventas.Actividades', 'RESEED', 0)
            DELETE FROM Ventas.Tours
            DBCC CHECKIDENT ('Ventas.Tours', 'RESEED', 0)
            DELETE FROM Ventas.ParticipaEnTour
            ROLLBACK TRANSACTION;
        END
        DECLARE @Mensaje NVARCHAR(MAX);

        SET @Mensaje = CONCAT(
            'Error N° ', ERROR_NUMBER(),
            '. Línea: ', ERROR_LINE(),
            '. Procedimiento: ', ISNULL(ERROR_PROCEDURE(), 'N/A'),
            '. Descripción: ', ERROR_MESSAGE()
        );

        THROW 50000, @Mensaje, 1;

    END CATCH;
END
GO

EXEC Ventas.GenerarDatos @fecha_inicio = '2020-01-01', @fecha_fin = '2026-06-27'
