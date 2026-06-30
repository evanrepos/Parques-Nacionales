USE ParquesNacionales
GO

SET NOCOUNT ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Detalle de Venta (GENERABLE)
-- =============================================

CREATE OR ALTER PROCEDURE Ventas.GenerarDetallesDeVenta (@ticket_id INT, @parque_id INT, @f_generacion DATETIME)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            --TIPOS DE VISITANTE
            DECLARE
                @idResidente INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Residente Nacional%'),
                @idProvincial INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Residente Provincial%'),
                @idJubilado INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Jubilado%'),
                @idEstudiante INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Estudiante%'),
                @idExtranjero INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE descripcion LIKE '%Extranjero%');
            --VARIABLES
            DECLARE @indiceDetalle INT;
            DECLARE @cantDetalles INT;
            DECLARE @tarifaId INT;
            DECLARE @tipoVisitante INT;
            DECLARE @factorVisitante FLOAT;
            DECLARE @factorCantidad FLOAT;
            DECLARE @cantidad INT;
            DECLARE @detallesTicket TABLE (
                id INT IDENTITY(1, 1),
                tarifa_id INT NOT NULL
            )

            -- 0. Validar parámetros
            --1. Si el número de ticket es nulo
            DECLARE @condicion1 BIT = CASE 
                WHEN @ticket_id IS NULL
                THEN 1 ELSE 0 END;

            DECLARE @mensaje1 VARCHAR(100) = 'El número de ticket no puede ser nulo.';

            --2. Si el parque es nulo
            DECLARE @condicion2 BIT = CASE 
                WHEN @parque_id IS NULL
                THEN 1 ELSE 0 END;

            DECLARE @mensaje2 VARCHAR(100) = 'El parque no puede ser nulo.';

            --3. Si la fecha de generacion es nula
            DECLARE @condicion3 BIT = CASE 
                WHEN @f_generacion IS NULL
                THEN 1 ELSE 0 END;

            DECLARE @mensaje3 VARCHAR(100) = 'La fecha de generacion no puede ser nula.';

            --Generación del mensaje de error.
            DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
                IIF(@condicion1 = 1, @mensaje1, NULL),
                IIF(@condicion2 = 1, @mensaje2, NULL),
                IIF(@condicion3 = 1, @mensaje3, NULL)
                );

            --Si falló, muestra mensaje de error, no hace cambios.
            IF (LEN(@mensajeDeError) > 0)
            BEGIN
                RAISERROR(@mensajeDeError, 1, 1);
            END;

            --Si todo salió bien, ... .
            ELSE
            BEGIN
                -- 1.1. Generar la cantidad de unidades. 
                SET @factorCantidad = RAND(CHECKSUM(NEWID()));
                SET @cantidad =
                CASE
                    WHEN @factorCantidad < 0.7 THEN 1
                    WHEN @factorCantidad < 0.9 THEN 2
                    ELSE 3
                END;

                -- 1.2. Generar la cantidad de detalles para el ticket
                SET @indiceDetalle = 1;
                SET @cantDetalles = (1 + ABS(CHECKSUM(NEWID())) % 5);
                INSERT INTO @detallesTicket
                    SELECT TOP (@cantDetalles) 
                        tarifa.id
                    FROM Administracion.TarifasDeArticulo tarifa LEFT JOIN
                        Ventas.Tours tour ON
                        tarifa.id = tour.tarifa_id
                    WHERE parque_id = @parque_id AND 
                        ((tour.cant_cupos >= @cantidad AND tour.f_visita > @f_generacion) OR 
                        (tarifa.tipo_articulo <> 'T'))
                    ORDER BY NEWID()

                -- 1.3 Por cada detalle ingresado en la tabla temporal
                WHILE @indiceDetalle <= @cantDetalles
                BEGIN
                    -- 1.3.1. Obtener el número de tarifa que corresponda 
                    SELECT @tarifaId = tarifa_id FROM @detallesTicket WHERE id = @indiceDetalle

                    --TIPOS DE VISITANTE
                    SELECT @factorVisitante = RAND(CHECKSUM(NEWID()));
                    IF @factorVisitante < 0.4
                    BEGIN
                        SET @tipoVisitante = @idResidente
                    END
                    ELSE IF @factorVisitante BETWEEN 0.4 AND 0.65
                    BEGIN
                        SET @tipoVisitante = @idProvincial
                    END
                    ELSE IF @factorVisitante BETWEEN 0.65 AND 0.75
                    BEGIN
                        SET @tipoVisitante = @idJubilado 
                    END
                    ELSE IF @factorVisitante BETWEEN 0.75 AND 0.85
                    BEGIN
                        SET @tipoVisitante = @idEstudiante 
                    END
                    ELSE IF @factorVisitante BETWEEN 0.85 AND 1
                    BEGIN
                        SET @tipoVisitante = @idExtranjero 
                    END
  
                    --GENERACION DETALLE DE TICKET
                    EXEC Ventas.InsertarDetallesDeTicket @ticket_id, @tarifaId, @tipoVisitante, @cantidad

                    SET @indiceDetalle += 1
                END        
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
-- Ticket de Venta (GENERABLE)
-- =============================================
CREATE OR ALTER PROCEDURE Ventas.GenerarTicketsDeVenta (@fecha_inicio DATE, @fecha_fin DATE = @fecha_inicio, @hora_apertura TIME = '07:00:00', @hora_cierre TIME = '19:00:00')
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            --ITERAR POR TIEMPO, NO POR CANTIDAD DE VENTAS
            DECLARE @puntoVentaId INT;
            DECLARE @parqueId INT;
            DECLARE @formaPago INT;
            DECLARE @idPesoArgentino INT = (SELECT id FROM Administracion.Divisas WHERE codigo_iso = 'ARS');
            DECLARE @divisaId INT = @idPesoArgentino;
            DECLARE @esExtranjero BIT;
            DECLARE @cotizacion DECIMAL(18, 2);
            DECLARE @tipoFechaId INT;
            DECLARE @fIteradora DATETIME = CAST(@fecha_inicio AS DATETIME) + CAST(@hora_apertura AS DATETIME);
            DECLARE @fCierre DATETIME = CAST(@fecha_fin AS DATETIME) + CAST(@hora_cierre AS DATETIME);
            DECLARE @ticketId INT;
            --DECLARE @mes_venta INT;
            DECLARE @incremento INT;
            DECLARE @incrementoMax INT;

            -- 1. Desde la hora de apertura, hasta la hora de cierre
            WHILE @fIteradora <= @fCierre
            BEGIN
                -- 1.1. Elegir un punto de venta al azar, donde realizar la venta. NO PUEDE generarse en el mismo punto de venta al mismo tiempo.
                SELECT TOP 1 @puntoVentaId = id, @parqueId = parque_id
                    FROM Administracion.PuntosDeVenta ptoVenta
                    WHERE NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE punto_venta_id = ptoVenta.id AND parque_id = ptoVenta.parque_id AND f_generacion = @fIteradora)
                    ORDER BY NEWID();
                -- 1.1.1. Si el punto de venta o el parque son nulos (porque no hay otra opción) -> incrementar la fecha iteradora
                IF @puntoVentaId IS NULL OR @parqueId IS NULL
                BEGIN
                    SET @incrementoMax =
                    CASE
                        -- Verano (alta temporada)
                        WHEN MONTH(@fIteradora) IN (1, 2) THEN 15

                        -- Vacaciones de invierno
                        WHEN MONTH(@fIteradora) = 7 THEN 20

                        -- Temporada media
                        WHEN MONTH(@fIteradora) IN (3, 4, 9, 10, 11, 12) THEN 30

                        -- Temporada baja
                        ELSE 45
                    END;

                    SET @incremento = ABS(CHECKSUM(NEWID()) % @incrementoMax);
                    IF CAST(CAST(@fIteradora AS DATE) AS DATETIME) + CAST(@hora_cierre AS DATETIME) < DATEADD(SECOND, @incremento, @fIteradora)
                    BEGIN
                        -- Pasó la hora de cierre: ir al día siguiente a la hora de apertura
                        SET @fIteradora =
                            CAST(DATEADD(DAY, 1, CAST(@fIteradora AS DATE)) AS DATETIME) + CAST(@hora_apertura AS DATETIME);

                        SELECT @tipoFechaId = Administracion.ObtenerTipoDeFecha(@fIteradora)
                    END
                    ELSE
                    BEGIN
                        -- Sigue dentro del horario del día actual
                        SET @fIteradora = DATEADD(SECOND, @incremento, @fIteradora);
                    END
                END

                -- 1.2. Elegir una forma de pago aleatoria
                SET @formaPago = (SELECT TOP 1 id FROM Administracion.FormasDePago ORDER BY NEWID());
    
                -- 1.3. Elegir la divisa
                SET @divisaId = @idPesoArgentino;
                SET @cotizacion = NULL;
    
                -- 1.3.1 Calcular la cotización de la divisa en el momento.
                SET @esExtranjero = (SELECT CAST(0.15 + RAND(CHECKSUM(NEWID())) AS INT));
                IF @esExtranjero = 1
                BEGIN     
                    DECLARE @fActualizacion DATETIME;
                    SET @divisaId = (SELECT TOP 1 id FROM Administracion.Divisas WHERE codigo_iso <> 'ARS' ORDER BY NEWID());
                    SELECT @cotizacion = cotizacion, @fActualizacion = f_actualizacion FROM Administracion.Divisas WHERE id = @divisaId;
                    IF @fActualizacion <> @fIteradora
                    BEGIN
                        EXEC Administracion.ActualizarCotizacionDivisa @divisaId, @fIteradora;
                        SELECT @cotizacion = cotizacion, @fActualizacion = f_actualizacion FROM Administracion.Divisas WHERE id = @divisaId;
                    END
                END

                -- 1.4. Insertar el ticket de venta con los parámetros generados.
                EXEC Ventas.InsertarTicketsDeVenta 
                    @punto_venta_id = @puntoVentaId, 
                    @parque_id = @parqueId, 
                    @forma_pago_id = @formaPago, 
                    @divisa_id = @divisaId, 
                    @cotizacion = @cotizacion, 
                    @f_generacion = @fIteradora,
                    @tipo_fecha_id = @tipoFechaId,
                    @total = 0, 
                    @id = @ticketId OUTPUT;

                -- 1.5. Generar detalles de ticket para el ticket ingresado.
                EXEC Ventas.GenerarDetallesDeVenta @ticketId, @parqueId, @fIteradora

                -- 1.6. Incrementar la fecha iteradora
                SET @incrementoMax =
                CASE
                    -- Verano (alta temporada)
                    WHEN MONTH(@fIteradora) IN (1, 2) THEN 15

                    -- Vacaciones de invierno
                    WHEN MONTH(@fIteradora) = 7 THEN 20

                    -- Temporada media
                    WHEN MONTH(@fIteradora) IN (3, 4, 9, 10, 11, 12) THEN 30

                    -- Temporada baja
                    ELSE 45
                END;

                SET @incremento = ABS(CHECKSUM(NEWID()) % @incrementoMax);
                IF CAST(CAST(@fIteradora AS DATE) AS DATETIME) + CAST(@hora_cierre AS DATETIME) < DATEADD(SECOND, @incremento, @fIteradora)
                BEGIN
                    -- Pasó la hora de cierre: ir al día siguiente a la hora de apertura
                    SET @fIteradora =
                        CAST(DATEADD(DAY, 1, CAST(@fIteradora AS DATE)) AS DATETIME)
                        + CAST(@hora_apertura AS DATETIME);
                    SELECT @tipoFechaId = Administracion.ObtenerTipoDeFecha(@fIteradora)
                END
                ELSE
                BEGIN
                    -- Sigue dentro del horario del día actual
                    SET @fIteradora = DATEADD(SECOND, @incremento, @fIteradora);
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
-- Tours (GENERABLE)
-- =============================================
--Generar TOURS para cada parque en forma periódica, y no a pedido. Por cada pedido, restar el cupo de tour.
CREATE OR ALTER PROCEDURE Ventas.GenerarTours (@fecha_inicio DATE, @fecha_fin DATE = @fecha_inicio, @hora_apertura TIME = '09:00:00', @hora_cierre TIME = '17:00:00')
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @tarifaId INT; 
            DECLARE @guia_id INT; 
            DECLARE @f_visita SMALLDATETIME;
            DECLARE @precio INT; 
            DECLARE @cant_cupos INT;
            DECLARE @duracion SMALLINT; --Duracion permite saber cada cuanto repetir el tour durante el día.
            DECLARE @fIteradora DATETIME = CAST(@fecha_inicio AS DATETIME) + CAST(@hora_apertura AS DATETIME);
            DECLARE @f_cierre DATETIME = CAST(@fecha_fin AS DATETIME) + CAST(@hora_cierre AS DATETIME);
            

            DECLARE @indice_parque INT = 1;
            DECLARE @cant_parques INT = (SELECT COUNT(1) FROM Administracion.Parques);
            WHILE @indice_parque <= @cant_parques
            BEGIN
                --Buscar tours por parque con un guía asignado aleatorio para realizar la excursión
                SELECT TOP 1 
                    @tarifaId = tarifa.id,
                    @guia_id = autorizacion.guia_id,
                    @cant_cupos = tarifa.cupo,
                    @duracion = tarifa.duracion,
                    @precio = tarifa.precio
                FROM Administracion.TarifasDeArticulo tarifa INNER JOIN
                    RRHH.AutorizacionesDeGuias autorizacion ON
                    tarifa.id = autorizacion.articulo_id
                WHERE tipo_articulo = 'T' AND parque_id = @indice_parque
                ORDER BY NEWID()

                --Por cada período en el día
                SET @f_visita = @fIteradora;
                WHILE @f_visita <= @f_cierre
                BEGIN
                    EXEC Ventas.InsertarTour 
                        @tarifa_id = @tarifaId, 
                        @guia_id = @guia_id, 
                        @f_visita = @f_visita, 
                        @precio = @precio, 
                        @cant_cupos = @cant_cupos

                    SET @guia_id = (SELECT TOP 1 guia_id FROM RRHH.AutorizacionesDeGuias WHERE articulo_id = @tarifaId ORDER BY NEWID());

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
                SET @indice_parque += 1;
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
            EXEC Ventas.GenerarTours @fecha_inicio, @fecha_fin, '08:00:00', '17:00:00'

            EXEC Ventas.GenerarTicketsDeVenta @fecha_inicio, @fecha_fin, @hora_apertura, @hora_cierre 
            
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

DECLARE @fIteradora DATE = '2025-01-01';
DECLARE @fFin DATE = '2026-06-30';
WHILE @fIteradora <= @fFin
BEGIN
    DECLARE @incrementoDias INT = ABS(CHECKSUM(NEWID())) % 7;

    EXEC Ventas.GenerarDatos @fecha_inicio = @fIteradora

    SET @fIteradora = DATEADD(DAY, @incrementoDias, @fIteradora);
END
