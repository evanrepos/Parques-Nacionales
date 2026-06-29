/* #####################################
   # Universidad Nacional de la Matanza#
   #      Bases de Datos Aplicada      #
   #####################################

   Participan: 
     - Iván Gonzalez Fernandez

   #####################################
   #       OperacionesVentas.sql      #
   #####################################
   El objetivo de este script es definir todos los 
   store procedures relacionados con las
   operaciones de las ventas...
*/

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarActividad
    @tarifa_id INT NULL,
    @ticket_id INT NULL,
    @f_visita SMALLDATETIME NULL,
    @precio DECIMAL(10, 2) NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @tarifa_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La tarifa de artículo no puede ser nula.';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La tarifa de artículo debe ser existente.';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @ticket_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'El ticket de venta no puede ser nulo, debe ser generado.';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'El guía debe ser existente y estar autorizado.';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @f_visita IS NULL OR @f_visita > GETDATE()
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'La fecha de visita no puede ser nula, ni futura.';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN @precio IS NULL OR @precio < 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'El precio debe ser mayor a cero o gratuito.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        INSERT INTO Ventas.Actividades (
            tarifa_id, ticket_id, f_visita, precio
        ) VALUES (
            @tarifa_id, @ticket_id, ISNULL(@f_visita, GETDATE()), @precio
        );

        SET @id = SCOPE_IDENTITY();
    END
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarTour
    @tarifa_id INT = NULL,
    @guia_id INT = NULL,
    @f_visita SMALLDATETIME = NULL,
    @precio DECIMAL(10, 2) = NULL,
    @cant_cupos INT = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @tarifa_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La tarifa de artículo no puede ser nula.';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La tarifa de artículo debe ser existente.';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @guia_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'El legajo de guía no puede ser nulo.';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM RRHH.AutorizacionesDeGuias WHERE guia_id = @guia_id AND articulo_id = @tarifa_id AND f_fin IS NULL)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'El guía debe ser existente y estar autorizado.';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @f_visita IS NULL OR @f_visita > GETDATE()
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'La fecha de visita no puede ser nula, ni futura.';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN @cant_cupos IS NULL OR @cant_cupos <= 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'La cantidad de cupos no puede ser nula.';
        
    --7. Si 
    DECLARE @condicion7 BIT = CASE 
        WHEN @precio IS NULL OR @precio < 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje7 VARCHAR(100) = 'El precio debe ser mayor a cero o gratuito.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL),
        IIF(@condicion7 = 1, @mensaje7, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        INSERT INTO Ventas.Tours (
            tarifa_id, guia_id, f_visita, precio, cant_cupos
        ) VALUES (
            @tarifa_id, @guia_id, ISNULL(@f_visita, GETDATE()), @precio, @cant_cupos
        );

        SET @id = SCOPE_IDENTITY();
    END
END;
GO

-- Tabla puente: vincula tickets adicionales (acompañantes) a una misma actividad.
CREATE OR ALTER PROCEDURE Ventas.InsertarParticipaEnTour
    @tour_id INT = NULL,
    @ticket_id INT = NULL,
    @cantidad SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @tour_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = '@actividad_id no puede ser nulo';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Ventas.Tours WHERE id = @tour_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tour no existe';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @ticket_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = '@ticket_id no puede ser nulo';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'El ticket no existe';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @cantidad IS NULL OR @cantidad <= 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'La cantidad de participantes debe ser mayor que cero.';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Ventas.ParticipaEnTour WHERE tour_id = @tour_id AND ticket_id = @ticket_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'Ese ticket ya participa en la actividad indicada';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        INSERT INTO Ventas.ParticipaEnTour (
            tour_id , ticket_id , cantidad
        ) VALUES (
            @tour_id , @ticket_id , @cantidad
        );
    END
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarEntrada
    @tarifa_id INT,
    @ticket_id INT,
    @tipo_fecha_id INT,
    @tipo_visitante_id INT,
    @f_visita SMALLDATETIME = NULL, 
    @precio DECIMAL(10, 2) = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @tarifa_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La tarifa de artículo no puede ser nula.';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La tarifa de artículo debe ser existente.';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @ticket_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'El ticket de venta no puede ser nulo, debe ser generado.';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'El ticket de venta no puede ser nulo, debe ser generado.';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @tipo_fecha_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'El tipo de fecha no puede ser nulo.';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TiposDeFecha WHERE id = @tipo_fecha_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'El guía debe ser existente y estar autorizado.';
        
    --7. Si 
    DECLARE @condicion7 BIT = CASE 
        WHEN @tipo_visitante_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje7 VARCHAR(100) = 'El tipo de visitante no puede ser nulo.';
        
    --8. Si 
    DECLARE @condicion8 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TiposDeVisitante WHERE id = @tipo_visitante_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje8 VARCHAR(100) = 'El guía debe ser existente y estar autorizado.';
        
    --9. Si 
    DECLARE @condicion9 BIT = CASE 
        WHEN @f_visita IS NULL OR @f_visita > GETDATE()
        THEN 1 ELSE 0 END;

    DECLARE @mensaje9 VARCHAR(100) = 'La fecha de visita no puede ser nula, ni futura.';
        
    --10. 
    DECLARE @condicion10 BIT = CASE 
        WHEN @precio IS NULL OR @precio < 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje10 VARCHAR(100) = 'El precio debe ser mayor a cero o gratuito.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL),
        IIF(@condicion7 = 1, @mensaje7, NULL),
        IIF(@condicion8 = 1, @mensaje8, NULL),
        IIF(@condicion9 = 1, @mensaje9, NULL),
        IIF(@condicion10 = 1, @mensaje10, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se ingresa la entrada.
    ELSE
    BEGIN
        INSERT INTO Ventas.Entradas (
            tarifa_id, ticket_id, tipo_fecha_id, tipo_visitante_id, f_visita, precio        
        ) VALUES (
            @tarifa_id, @ticket_id, @tipo_fecha_id, @tipo_visitante_id, ISNULL(@f_visita, GETDATE()), @precio
        );

        SET @id = SCOPE_IDENTITY();
    END
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarTicketsDeVenta    
    @punto_venta_id INT,
    @parque_id INT,
    @forma_pago_id INT,
    @divisa_id INT,
    @cotizacion DECIMAL(15, 5) = NULL,
    @f_generacion DATETIME = NULL,
    @tipo_fecha_id INT NULL,
    @total DECIMAL(12, 2) = NULL,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @punto_venta_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = '@punto_venta_id no puede ser nulo';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.PuntosDeVenta WHERE id = @punto_venta_id AND parque_id = @parque_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El punto de venta no existe';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @forma_pago_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = '@forma_pago_id no puede ser nulo';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.FormasDePago WHERE id = @forma_pago_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'La forma de pago no existe';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @divisa_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = '@divisa_id no puede ser nulo';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.Divisas WHERE id = @divisa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'La divisa no existe';
        
    --7. Si 
    DECLARE @condicion7 BIT = CASE 
        WHEN @total IS NOT NULL AND @total < 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje7 VARCHAR(100) = 'El total no puede ser negativo';
        
    --8. Si 
    DECLARE @condicion8 BIT = CASE 
        WHEN @f_generacion IS NOT NULL AND @f_generacion > GETDATE()
        THEN 1 ELSE 0 END;

    DECLARE @mensaje8 VARCHAR(100) = 'La fecha de generación no puede ser futura';
        
    --9. Si 
    DECLARE @condicion9 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE punto_venta_id = @punto_venta_id AND parque_id = @parque_id AND f_generacion = @f_generacion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje9 VARCHAR(100) = 'No puede ocurrir una venta en el mismo punto de venta en el mismo momento.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL),
        IIF(@condicion7 = 1, @mensaje7, NULL),
        IIF(@condicion8 = 1, @mensaje8, NULL),
        IIF(@condicion9 = 1, @mensaje9, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        --Feriado
        DECLARE @link NVARCHAR(200) = 'https://api.argentinadatos.com/v1/feriados/2026';
        DECLARE @Object INT;
        DECLARE @response VARCHAR(8000);
        EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @link, 'false';
        EXEC sp_OAMethod @Object, 'send';
        EXEC sp_OAGetProperty @Object, 'responseText', @response OUT;
        IF EXISTS (SELECT 1
            FROM OPENJSON(@response) 
                CROSS APPLY OPENJSON([value])
            WITH (
                fecha DATE '$.fecha',
                tipo VARCHAR(20) '$.tipo',
                nombre VARCHAR(200) '$.nombre'
            ) WHERE fecha = @f_generacion)
        BEGIN
            SELECT @tipo_fecha_id = id FROM Administracion.TiposDeFecha WHERE descripcion LIKE '%Feriado Nacional%'
        END
        --Dia de semana
        ELSE IF DATEPART(WEEKDAY, @f_generacion) BETWEEN 1 AND 5
        BEGIN
            SELECT @tipo_fecha_id = id FROM Administracion.TiposDeFecha WHERE descripcion LIKE '%Dia Habil%'
        END
        --Fin de semana
        ELSE IF DATEPART(WEEKDAY, @f_generacion) BETWEEN 6 AND 7
        BEGIN
            SELECT @tipo_fecha_id = id FROM Administracion.TiposDeFecha WHERE descripcion LIKE '%Fin de Semana%'
        END

        BEGIN TRY
            INSERT INTO Ventas.TicketsDeVenta (
                punto_venta_id, parque_id, forma_pago_id, divisa_id, cotizacion, f_generacion, tipo_fecha_id, total
            ) VALUES (
                @punto_venta_id, @parque_id, @forma_pago_id, @divisa_id, @cotizacion, ISNULL(@f_generacion, GETDATE()), @tipo_fecha_id, @total
            );

            SET @id = SCOPE_IDENTITY();
        END TRY
        BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE();
        ;THROW 50000, @error, 1;
        END CATCH
    END
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
    @tipo_visitante_id INT = NULL,
    @cantidad SMALLINT = 1,
    @nro_detalle SMALLINT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si 
    DECLARE @condicion1 BIT = CASE 
        WHEN @ticket_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = '@ticket_id no puede ser nulo';

    --2. Si 
    DECLARE @condicion2 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Ventas.TicketsDeVenta WHERE id = @ticket_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El ticket no existe';

    --3. Si 
    DECLARE @condicion3 BIT = CASE 
        WHEN @tarifa_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = '@tarifa_id no puede ser nulo';
        
    --4. Si 
    DECLARE @condicion4 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @tarifa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'La tarifa no existe';
        
    --5. Si 
    DECLARE @condicion5 BIT = CASE 
        WHEN @tipo_visitante_id IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'El tipo de visitante no puede ser nulo';
        
    --6. Si 
    DECLARE @condicion6 BIT = CASE 
        WHEN NOT EXISTS (SELECT 1 FROM Administracion.TiposDeVisitante WHERE id = @tipo_visitante_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'La tarifa no existe';
        
    --7. Si 
    DECLARE @condicion7 BIT = CASE 
        WHEN @cantidad IS NULL OR @cantidad <= 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje7 VARCHAR(100) = '@cantidad debe ser mayor a cero';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL),
        IIF(@condicion6 = 1, @mensaje6, NULL),
        IIF(@condicion7 = 1, @mensaje7, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        -- Datos de la tarifa (para validar el ajuste y calcular el precio)
        DECLARE @precio_base DECIMAL(10, 2);
        DECLARE @tipo_articulo_tarifa CHAR(1);

        SELECT @precio_base = precio, @tipo_articulo_tarifa = tipo_articulo
            FROM Administracion.TarifasDeArticulo
            WHERE id = @tarifa_id;

        -- FECHA DE VISITA
        DECLARE @f_generacion SMALLDATETIME;
        SELECT @f_generacion = f_generacion FROM Ventas.TicketsDeVenta WHERE id = @ticket_id;
        --SELECT @f_generacion

        -- Validación del ajuste: debe existir y su tipo_articulo debe coincidir con el de la tarifa
        -- ID PARQUE
        DECLARE @parque_id INT;
        DECLARE @tipo_fecha_id INT;
        DECLARE @tipo_fecha VARCHAR(MAX);

        --TIPO FECHA
        SELECT @parque_id = parque_id, @tipo_fecha_id = tipo_fecha_id FROM Ventas.TicketsDeVenta WHERE id = @ticket_id;
        SELECT @tipo_fecha = descripcion FROM Administracion.TiposDeFecha WHERE id = @tipo_fecha_id;

        --TIPO VISITANTE
        DECLARE @tipo_visitante VARCHAR(MAX)
        SELECT @tipo_visitante = descripcion FROM Administracion.TiposDeVisitante WHERE id = @tipo_visitante_id;

        --INSERTAR DETALLES DE VENTA Y GENERAR ACTIVIDADES, ENTRADAS Y TOURS.
        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @todo_ok BIT = 0;
            DECLARE @precio_unitario DECIMAL(12, 2) = @precio_base;
            DECLARE @subtotal_calculado DECIMAL(12, 2) = @precio_base * @cantidad;

            IF @tipo_articulo_tarifa = 'E'
            BEGIN            
                DECLARE @factor_fecha DECIMAL(5,2);
                DECLARE @factor_visitante DECIMAL(5,2);

                SELECT @factor_fecha = 1 + (porcentaje / 100.0)
                FROM Administracion.Ajustes
                WHERE parque_id = @parque_id
                AND descripcion = @tipo_fecha;

                SELECT @factor_visitante = 1 + (porcentaje / 100.0)
                FROM Administracion.Ajustes
                WHERE parque_id = @parque_id
                AND descripcion = @tipo_visitante;

                SET @factor_fecha = ISNULL(@factor_fecha, 1);
                SET @factor_visitante = ISNULL(@factor_visitante, 1);

                SET @precio_unitario = ROUND(@precio_base * (@factor_fecha * @factor_visitante), 2);

                SET @subtotal_calculado =
                    ROUND(@precio_unitario * @cantidad, 2);
                
                --SELECT 'FACTOR FECHA' = @factor_fecha, 'FACTOR VISITANTE' = @factor_visitante, 'PRECIO BASE' = @precio_base, 'PRECIO UNITARIO' = @precio_unitario

                EXEC Ventas.InsertarEntrada @tarifa_id, @ticket_id, @tipo_fecha_id, @tipo_visitante_id, @f_generacion, @precio_unitario
                SET @todo_ok = 1;
            END
            ELSE IF @tipo_articulo_tarifa = 'A'
            BEGIN
                --SELECT 'PRECIO UNITARIO' = @precio_unitario

                EXEC Ventas.InsertarActividad @tarifa_id, @ticket_id, @f_generacion, @precio_unitario
                SET @todo_ok = 1;
            END
            ELSE IF @tipo_articulo_tarifa = 'T'
            BEGIN
                DECLARE @tour_id INT;

                -- Buscar el próximo tour disponible con cupos suficientes
                SELECT TOP 1
                    @tour_id = id
                FROM Ventas.Tours
                WHERE tarifa_id = @tarifa_id
                  AND f_visita > @f_generacion
                  AND cant_cupos >= @cantidad
                ORDER BY f_visita;

                IF @tour_id IS NOT NULL
                   AND NOT EXISTS (
                        SELECT 1
                        FROM Ventas.ParticipaEnTour
                        WHERE ticket_id = @ticket_id
                   )
                BEGIN
                    -- Descontar los cupos reservados
                    UPDATE Ventas.Tours
                    SET cant_cupos = cant_cupos - @cantidad
                    WHERE id = @tour_id;

                    /*
                     Aquí hay una decisión de diseño importante.
                    */

                    -- Opción 1 (la más simple):
                    -- Un registro representa una reserva grupal.
                    EXEC Ventas.InsertarParticipaEnTour
                        @tour_id,
                        @ticket_id,
                        @cantidad;

                    SET @todo_ok = 1;
                END
            END
            IF @todo_ok = 1
            BEGIN
                -- nro_detalle: 1 si es el primer detalle del ticket, o el siguiente correlativo
                SELECT @nro_detalle = ISNULL(MAX(nro_detalle), 0) + 1
                FROM Ventas.DetallesDeTicket
                WHERE ticket_id = @ticket_id;

                INSERT INTO Ventas.DetallesDeTicket (
                    nro_detalle, ticket_id, tarifa_id, tipo_visitante_id, cantidad, precio_ud, subtotal
                ) VALUES (
                    @nro_detalle, @ticket_id, @tarifa_id, @tipo_visitante_id, @cantidad, @precio_base, @subtotal_calculado
                );

                UPDATE Ventas.TicketsDeVenta SET total += @subtotal_calculado WHERE id = @ticket_id;
            END

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
            ;THROW;
        END CATCH
    END
END;
GO