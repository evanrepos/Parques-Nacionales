USE ParquesNacionales;
GO

-- =============================================
-- TicketsDeVenta
-- =============================================
CREATE OR ALTER PROCEDURE Ventas.InsertarTicketsDeVenta    
    @punto_venta_id INT,
    @forma_pago_id INT,
    @divisa_id INT,
    @cotizacion DECIMAL(15, 5) = NULL,
    @f_generacion DATE = NULL,
    @total DECIMAL(12, 2) = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Validaciones
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@punto_venta_id IS NULL, '@punto_venta_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.PuntosDeVenta WHERE id = @punto_venta_id), 'El punto de venta no existe', NULL),
        IIF(@forma_pago_id IS NULL, '@forma_pago_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.FormasDePago WHERE id = @forma_pago_id), 'La forma de pago no existe', NULL),
        IIF(@divisa_id IS NULL, '@divisa_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.Divisas WHERE id = @divisa_id), 'La divisa no existe', NULL),
        IIF(@total IS NOT NULL AND @total < 0, 'El total no puede ser negativo', NULL),
        IIF(@f_generacion IS NOT NULL AND @f_generacion > GETDATE(), 'La fecha de generación no puede ser futura', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRY
        INSERT INTO Ventas.TicketsDeVenta (
            punto_venta_id, forma_pago_id, divisa_id, cotizacion, f_generacion, total
        ) VALUES (
            @punto_venta_id, @forma_pago_id, @divisa_id, @cotizacion, ISNULL(@f_generacion, GETDATE()), @total
        );

        SET @id = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE();
        ;THROW 50000, @error, 1;
    END CATCH
END;
GO

-- =============================================
-- DetallesDeTicket
-- =============================================
-- El precio_ud y el subtotal se calculan a partir de la tarifa y el ajuste (si corresponde).
-- El nro_detalle se calcula automáticamente: arranca en 1 para el primer detalle de
-- cada ticket, y continúa de forma correlativa por ticket_id.
CREATE OR ALTER PROCEDURE Ventas.InsertarDetallesDeTicket
    @ticket_id INT,
    @tarifa_id INT,
    @ajuste_id INT = NULL,
    @cantidad SMALLINT = 1,
    @nro_detalle SMALLINT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Validaciones
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@ticket_id IS NULL, '@ticket_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id), 'El ticket no existe', NULL),
        IIF(@tarifa_id IS NULL, '@tarifa_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id), 'La tarifa no existe', NULL),
        IIF(@cantidad IS NULL OR @cantidad <= 0, '@cantidad debe ser mayor a cero', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- Datos de la tarifa (para validar el ajuste y calcular el precio)
    DECLARE @precioBase DECIMAL(10, 2);
    DECLARE @tipoArticuloTarifa CHAR(1);
    SELECT @precioBase = precio, @tipoArticuloTarifa = tipo_articulo
    FROM Administracion.TarifasDeArticulo
    WHERE id = @tarifa_id;

    -- Validación del ajuste: debe existir y su tipo_articulo debe coincidir con el de la tarifa
    DECLARE @porcentajeAjuste TINYINT;
    IF (@ajuste_id IS NOT NULL)
    BEGIN
        DECLARE @tipoArticuloAjuste CHAR(1);
        SELECT @porcentajeAjuste = porcentaje, @tipoArticuloAjuste = tipo_articulo
        FROM Administracion.Ajustes
        WHERE id = @ajuste_id;

        SET @mensajeDeError = CONCAT_WS(CHAR(10),
            IIF(@porcentajeAjuste IS NULL, 'El ajuste no existe', NULL),
            IIF(@porcentajeAjuste IS NOT NULL AND @tipoArticuloAjuste <> @tipoArticuloTarifa,
                'El ajuste no corresponde al tipo de artículo de la tarifa', NULL)
        );

        IF (LEN(@mensajeDeError) > 0)
        BEGIN
            ;THROW 50000, @mensajeDeError, 1;
        END;
    END;

    -- Cálculo de precio_ud (ajuste multiplicativo: descuento o recargo) y subtotal
    DECLARE @precioUnidad DECIMAL(10, 2) = @precioBase * (1 + ISNULL(@porcentajeAjuste, 0) / 100.0);
    DECLARE @subtotalCalculado DECIMAL(12, 2) = @precioUnidad * @cantidad;

    BEGIN TRY
        BEGIN TRANSACTION;
        SAVE TRANSACTION ComienzoSP;

        -- nro_detalle: 1 si es el primer detalle del ticket, o el siguiente correlativo
        SELECT @nro_detalle = ISNULL(MAX(nro_detalle), 0) + 1
        FROM Ventas.DetallesDeTicket
        WHERE ticket_id = @ticket_id;

        INSERT INTO Ventas.DetallesDeTicket (
            nro_detalle, ticket_id, tarifa_id, ajuste_id, cantidad, precio_ud, subtotal
        ) VALUES (
            @nro_detalle, @ticket_id, @tarifa_id, @ajuste_id, @cantidad, @precioUnidad, @subtotalCalculado
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ComienzoSP;
        END;
        ;THROW;
    END CATCH
END;
GO

-- =============================================
-- Actividades
-- =============================================
-- El tipo_actividad NO se recibe como parámetro: se deriva directamente del
-- tipo_articulo de la tarifa, para evitar combinaciones inconsistentes
-- (ej. una tarifa de Tour insertada como tipo_actividad = 'A').
-- Solo se aceptan tarifas de tipo 'T' (Tour) o 'A' (Actividad); las de tipo
-- 'E' (Entrada) se gestionan con Ventas.InsertarEntradas.
CREATE OR ALTER PROCEDURE Ventas.InsertarActividades
    @tarifa_id INT,
    @ticket_id INT,
    @guia_id INT = NULL,
    @f_visita DATE = NULL,
    @precio DECIMAL(10, 2) = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Validaciones
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@tarifa_id IS NULL, '@tarifa_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id), 'La tarifa no existe', NULL),
        IIF(@ticket_id IS NULL, '@ticket_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id), 'El ticket no existe', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- El tipo de actividad se deriva de la tarifa, no se recibe por parámetro
    DECLARE @tipoArticulo CHAR(1);
    DECLARE @parqueTarifa INT;
    SELECT @tipoArticulo = tipo_articulo, @parqueTarifa = parque_id
    FROM Administracion.TarifasDeArticulo
    WHERE id = @tarifa_id;

    SET @mensajeDeError = CONCAT_WS(CHAR(10),
        IIF(@tipoArticulo NOT IN ('T', 'A'), 'La tarifa indicada no corresponde a un tour ni a una actividad', NULL),
        -- Regla de guía según tipo: igual que el CHECK de la tabla, validado acá para dar un mensaje claro
        IIF(@tipoArticulo = 'A' AND @guia_id IS NOT NULL, 'Las actividades no llevan guía asignado', NULL),
        IIF(@tipoArticulo = 'T' AND @guia_id IS NULL, 'Los tours requieren un guía asignado', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- Si es un tour, el guía debe estar autorizado para esa tarifa puntual
    IF (@tipoArticulo = 'T')
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM RRHH.AutorizacionesDeGuias
            WHERE guia_id = @guia_id AND articulo_id = @tarifa_id AND f_fin IS NULL
        )
        BEGIN
            ;THROW 50000, 'El guía no está autorizado para dar este tour', 1;
        END;
    END;

    BEGIN TRY
        INSERT INTO Ventas.Actividades (
            tarifa_id, ticket_id, guia_id, tipo_actividad, f_visita, precio
        ) VALUES (
            @tarifa_id, @ticket_id, @guia_id, @tipoArticulo, ISNULL(@f_visita, GETDATE()), @precio
        );

        SET @id = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE();
        ;THROW 50000, @error, 1;
    END CATCH
END;
GO

-- =============================================
-- ParticipaEnActividad
-- =============================================
-- Tabla puente: vincula tickets adicionales (acompañantes) a una misma actividad.
CREATE OR ALTER PROCEDURE Ventas.InsertarParticipaEnActividad
    @actividad_id INT,
    @ticket_id INT
AS
BEGIN
    SET NOCOUNT ON;

    --Validaciones
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@actividad_id IS NULL, '@actividad_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Ventas.Actividades WHERE id = @actividad_id), 'La actividad no existe', NULL),
        IIF(@ticket_id IS NULL, '@ticket_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id), 'El ticket no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM Ventas.ParticipaEnActividad WHERE actividad_id = @actividad_id AND ticket_id = @ticket_id),
            'Ese ticket ya participa en la actividad indicada', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRY
        INSERT INTO Ventas.ParticipaEnActividad (
            actividad_id, ticket_id 
        ) VALUES (
            @actividad_id, @ticket_id 
        );
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE();
        ;THROW 50000, @error, 1;
    END CATCH
END;
GO

-- =============================================
-- Entradas
-- =============================================
-- Solo se aceptan tarifas de tipo 'E' (Entrada).
CREATE OR ALTER PROCEDURE Ventas.InsertarEntradas
    @tarifa_id INT,
    @ticket_id INT,
    @tipo_fecha_id INT,
    @tipo_visitante_id INT,
    @f_visita DATE = NULL, 
    @precio DECIMAL(10, 2) = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Validaciones
    DECLARE @tipoArticulo CHAR(1) = (SELECT tipo_articulo FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id);

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@tarifa_id IS NULL, '@tarifa_id no puede ser nulo', NULL),
        IIF(@tipoArticulo IS NULL, 'La tarifa no existe', NULL),
        IIF(@tipoArticulo IS NOT NULL AND @tipoArticulo <> 'E', 'La tarifa indicada no corresponde a una entrada', NULL),
        IIF(@ticket_id IS NULL, '@ticket_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id), 'El ticket no existe', NULL),
        IIF(@tipo_fecha_id IS NULL, '@tipo_fecha_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.TiposDeFecha WHERE id = @tipo_fecha_id), 'El tipo de fecha no existe', NULL),
        IIF(@tipo_visitante_id IS NULL, '@tipo_visitante_id no puede ser nulo', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.TiposDeVisitante WHERE id = @tipo_visitante_id), 'El tipo de visitante no existe', NULL)
    );

    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRY
        INSERT INTO Ventas.Entradas (
            tarifa_id, ticket_id, tipo_fecha_id, tipo_visitante_id, f_visita, precio        
        ) VALUES (
            @tarifa_id, @ticket_id, @tipo_fecha_id, @tipo_visitante_id, ISNULL(@f_visita, GETDATE()), @precio
        );

        SET @id = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE();
        ;THROW 50000, @error, 1;
    END CATCH
END;
GO