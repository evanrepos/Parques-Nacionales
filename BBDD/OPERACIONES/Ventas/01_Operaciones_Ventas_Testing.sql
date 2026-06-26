USE ParquesNacionales;
GO

BEGIN TRANSACTION

--#### IDs reutilizados de OperacionesAdministracionTesting.sql ####--
DECLARE @parque INT = 1;
DECLARE @puntoVenta INT = 1;
DECLARE @formaPago INT = 1;
DECLARE @divisa INT = 1;
DECLARE @tipoFecha INT = 1;
DECLARE @tipoVisitante INT = 1;
DECLARE @tarifaEntrada INT = 1;   -- tipo 'E'
DECLARE @tarifaActividad INT = 3; -- tipo 'A'
DECLARE @tarifaTour INT = 4;      -- tipo 'T'
DECLARE @ajusteEntrada INT = 1;   -- tipo 'E', -50%

--#### Registros adicionales necesarios para los tests ####--

-- Un ajuste de tipo 'T', para probar la incompatibilidad ajuste/tarifa
DECLARE @ajusteTour INT;
INSERT INTO Administracion.Ajustes (parque_id, tipo_articulo, tipo_visitante_id, tipo_fecha_id, porcentaje)
VALUES (@parque, 'T', @tipoVisitante, @tipoFecha, -20);
SET @ajusteTour = SCOPE_IDENTITY();

-- Un guía, asignado al parque, y autorizado para el tour de prueba
DECLARE @guia INT;
EXEC RRHH.CrearGuia
    @cuil = 20111111112,
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nacimiento = '1990-01-01',
    @id = @guia OUTPUT;

DECLARE @asignacionGuia INT;
EXEC RRHH.AsignarGuia
    @id_guia = @guia,
    @id_parque = @parque,
    @fecha_ingreso = '2020-01-01',
    @id = @asignacionGuia OUTPUT;

DECLARE @autorizacionGuia INT;
EXEC RRHH.AutorizarGuia
    @id_guia = @guia,
    @id_tarifa = @tarifaTour,
    @fecha_inicio = '2020-01-01',
    @id = @autorizacionGuia OUTPUT;

-- Un segundo guía, NO autorizado para ningún tour (para probar el rechazo correspondiente)
DECLARE @guiaNoAutorizado INT;
EXEC RRHH.CrearGuia
    @cuil = 20222222223,
    @nombre = 'Mario',
    @apellido = 'Gómez',
    @fecha_nacimiento = '1985-05-05',
    @id = @guiaNoAutorizado OUTPUT;


/*================================================================================================*/
--#### Ventas.InsertarTicketsDeVenta ####--
/*================================================================================================*/

DECLARE @ticket1 INT;
DECLARE @ticket2 INT;

-- EXITO: ticket válido, con total
EXEC Ventas.InsertarTicketsDeVenta
    @punto_venta_id = @puntoVenta,
    @forma_pago_id = @formaPago,
    @divisa_id = @divisa,
    @total = 5000,
    @id = @ticket1 OUTPUT;
SELECT CAST(@ticket1 AS VARCHAR) AS 'ID del ticket 1 insertado';

-- EXITO: ticket válido, sin f_generacion (debe tomar la fecha actual por default)
EXEC Ventas.InsertarTicketsDeVenta
    @punto_venta_id = @puntoVenta,
    @forma_pago_id = @formaPago,
    @divisa_id = @divisa,
    @total = 0,
    @id = @ticket2 OUTPUT;

SELECT * FROM Ventas.TicketsDeVenta WHERE id IN (@ticket1, @ticket2);

-- RECHAZO: punto de venta inexistente
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = -1,
        @forma_pago_id = @formaPago,
        @divisa_id = @divisa,
        @total = 1000;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 1 (InsertarTicketsDeVenta) - punto de venta inexistente' END CATCH

-- RECHAZO: forma de pago inexistente
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = @puntoVenta,
        @forma_pago_id = -1,
        @divisa_id = @divisa,
        @total = 1000;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 2 (InsertarTicketsDeVenta) - forma de pago inexistente' END CATCH

-- RECHAZO: divisa inexistente
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = @puntoVenta,
        @forma_pago_id = @formaPago,
        @divisa_id = -1,
        @total = 1000;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 3 (InsertarTicketsDeVenta) - divisa inexistente' END CATCH

-- RECHAZO: total negativo
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = @puntoVenta,
        @forma_pago_id = @formaPago,
        @divisa_id = @divisa,
        @total = -500;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 4 (InsertarTicketsDeVenta) - total negativo' END CATCH

-- RECHAZO: fecha de generación futura
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = @puntoVenta,
        @forma_pago_id = @formaPago,
        @divisa_id = @divisa,
        @f_generacion = '2099-01-01',
        @total = 1000;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 5 (InsertarTicketsDeVenta) - fecha futura' END CATCH

-- RECHAZO: todos los parámetros obligatorios nulos
BEGIN TRY
    EXEC Ventas.InsertarTicketsDeVenta
        @punto_venta_id = NULL,
        @forma_pago_id = NULL,
        @divisa_id = NULL;
END TRY
BEGIN CATCH 
    SELECT value AS 'Errores 6 (InsertarTicketsDeVenta) - todo nulo'
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));
END CATCH


/*================================================================================================*/
--#### Ventas.InsertarDetallesDeTicket ####--
/*================================================================================================*/

DECLARE @detalle1 SMALLINT;
DECLARE @detalle2 SMALLINT;
DECLARE @detalle3 SMALLINT;

-- EXITO: primer detalle del ticket1 (entrada, sin ajuste) -> nro_detalle debe ser 1
EXEC Ventas.InsertarDetallesDeTicket
    @ticket_id = @ticket1,
    @tarifa_id = @tarifaEntrada,
    @cantidad = 2,
    @nro_detalle = @detalle1 OUTPUT;
SELECT CAST(@detalle1 AS VARCHAR) AS 'nro_detalle 1 (debe ser 1)';

-- EXITO: segundo detalle del MISMO ticket1 (entrada con ajuste de jubilado) -> nro_detalle debe ser 2
EXEC Ventas.InsertarDetallesDeTicket
    @ticket_id = @ticket1,
    @tarifa_id = @tarifaEntrada,
    @ajuste_id = @ajusteEntrada,
    @cantidad = 1,
    @nro_detalle = @detalle2 OUTPUT;
SELECT CAST(@detalle2 AS VARCHAR) AS 'nro_detalle 2 (debe ser 2)';

-- EXITO: primer detalle de un ticket DISTINTO (ticket2) -> nro_detalle debe volver a ser 1
EXEC Ventas.InsertarDetallesDeTicket
    @ticket_id = @ticket2,
    @tarifa_id = @tarifaEntrada,
    @cantidad = 1,
    @nro_detalle = @detalle3 OUTPUT;
SELECT CAST(@detalle3 AS VARCHAR) AS 'nro_detalle 3, en otro ticket (debe ser 1)';

-- Verificación de precio/subtotal calculados:
-- detalle1: 2 entradas a precio de lista (5000), sin ajuste -> precio_ud=5000, subtotal=10000
-- detalle2: 1 entrada con ajuste -50% (5000 * 0.5 = 2500) -> precio_ud=2500, subtotal=2500
SELECT * FROM Ventas.DetallesDeTicket WHERE ticket_id IN (@ticket1, @ticket2) ORDER BY ticket_id, nro_detalle;

-- RECHAZO: ticket inexistente
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = -1,
        @tarifa_id = @tarifaEntrada;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 1 (InsertarDetallesDeTicket) - ticket inexistente' END CATCH

-- RECHAZO: tarifa inexistente
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = @ticket1,
        @tarifa_id = -1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 2 (InsertarDetallesDeTicket) - tarifa inexistente' END CATCH

-- RECHAZO: cantidad cero
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = @ticket1,
        @tarifa_id = @tarifaEntrada,
        @cantidad = 0;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 3 (InsertarDetallesDeTicket) - cantidad cero' END CATCH

-- RECHAZO: cantidad negativa
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = @ticket1,
        @tarifa_id = @tarifaEntrada,
        @cantidad = -3;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 4 (InsertarDetallesDeTicket) - cantidad negativa' END CATCH

-- RECHAZO: ajuste inexistente
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = @ticket1,
        @tarifa_id = @tarifaEntrada,
        @ajuste_id = -1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 5 (InsertarDetallesDeTicket) - ajuste inexistente' END CATCH

-- RECHAZO: ajuste de tipo 'T' aplicado a una tarifa de tipo 'E' (incompatibilidad)
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = @ticket1,
        @tarifa_id = @tarifaEntrada,
        @ajuste_id = @ajusteTour;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 6 (InsertarDetallesDeTicket) - ajuste no corresponde al tipo de artículo' END CATCH

-- RECHAZO: ticket y tarifa nulos
BEGIN TRY
    EXEC Ventas.InsertarDetallesDeTicket
        @ticket_id = NULL,
        @tarifa_id = NULL;
END TRY
BEGIN CATCH 
    SELECT value AS 'Errores 7 (InsertarDetallesDeTicket) - todo nulo'
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));
END CATCH


/*================================================================================================*/
--#### Ventas.InsertarActividades ####--
/*================================================================================================*/

DECLARE @actividad1 INT; -- Actividad (kayak), sin guía
DECLARE @actividad2 INT; -- Tour, con guía autorizado

-- EXITO: actividad (tipo 'A'), sin guía
EXEC Ventas.InsertarActividades
    @tarifa_id = @tarifaActividad,
    @ticket_id = @ticket1,
    @precio = 8000,
    @id = @actividad1 OUTPUT;
SELECT CAST(@actividad1 AS VARCHAR) AS 'ID actividad 1 (kayak, sin guía)';

-- EXITO: tour (tipo 'T'), con guía autorizado
EXEC Ventas.InsertarActividades
    @tarifa_id = @tarifaTour,
    @ticket_id = @ticket1,
    @guia_id = @guia,
    @precio = 15000,
    @id = @actividad2 OUTPUT;
SELECT CAST(@actividad2 AS VARCHAR) AS 'ID actividad 2 (tour, con guía)';

SELECT * FROM Ventas.Actividades WHERE id IN (@actividad1, @actividad2);

-- RECHAZO: tarifa inexistente
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = -1,
        @ticket_id = @ticket1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 1 (InsertarActividades) - tarifa inexistente' END CATCH

-- RECHAZO: ticket inexistente
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = @tarifaActividad,
        @ticket_id = -1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 2 (InsertarActividades) - ticket inexistente' END CATCH

-- RECHAZO: tarifa de tipo Entrada (no es Tour ni Actividad)
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = @tarifaEntrada,
        @ticket_id = @ticket1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 3 (InsertarActividades) - tarifa de tipo Entrada' END CATCH

-- RECHAZO: actividad (tipo 'A') con guía asignado (no debería llevar guía)
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = @tarifaActividad,
        @ticket_id = @ticket1,
        @guia_id = @guia;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 4 (InsertarActividades) - actividad con guía' END CATCH

-- RECHAZO: tour (tipo 'T') sin guía asignado (debería ser obligatorio)
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = @tarifaTour,
        @ticket_id = @ticket1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 5 (InsertarActividades) - tour sin guía' END CATCH

-- RECHAZO: tour con un guía que existe, pero NO está autorizado para ese tour
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = @tarifaTour,
        @ticket_id = @ticket1,
        @guia_id = @guiaNoAutorizado;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 6 (InsertarActividades) - guía no autorizado' END CATCH

-- RECHAZO: tarifa y ticket nulos
BEGIN TRY
    EXEC Ventas.InsertarActividades
        @tarifa_id = NULL,
        @ticket_id = NULL;
END TRY
BEGIN CATCH 
    SELECT value AS 'Errores 7 (InsertarActividades) - todo nulo'
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));
END CATCH


/*================================================================================================*/
--#### Ventas.InsertarParticipaEnActividad ####--
/*================================================================================================*/

-- EXITO: el ticket2 participa también de la actividad1 (ej. un acompañante)
EXEC Ventas.InsertarParticipaEnActividad
    @actividad_id = @actividad1,
    @ticket_id = @ticket2;

SELECT * FROM Ventas.ParticipaEnActividad WHERE actividad_id = @actividad1;

-- RECHAZO: actividad inexistente
BEGIN TRY
    EXEC Ventas.InsertarParticipaEnActividad
        @actividad_id = -1,
        @ticket_id = @ticket2;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 1 (InsertarParticipaEnActividad) - actividad inexistente' END CATCH

-- RECHAZO: ticket inexistente
BEGIN TRY
    EXEC Ventas.InsertarParticipaEnActividad
        @actividad_id = @actividad1,
        @ticket_id = -1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 2 (InsertarParticipaEnActividad) - ticket inexistente' END CATCH

-- RECHAZO: participación duplicada (mismo par actividad+ticket ya insertado arriba)
BEGIN TRY
    EXEC Ventas.InsertarParticipaEnActividad
        @actividad_id = @actividad1,
        @ticket_id = @ticket2;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 3 (InsertarParticipaEnActividad) - participación duplicada' END CATCH

-- RECHAZO: actividad y ticket nulos
BEGIN TRY
    EXEC Ventas.InsertarParticipaEnActividad
        @actividad_id = NULL,
        @ticket_id = NULL;
END TRY
BEGIN CATCH 
    SELECT value AS 'Errores 4 (InsertarParticipaEnActividad) - todo nulo'
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));
END CATCH


/*================================================================================================*/
--#### Ventas.InsertarEntradas ####--
/*================================================================================================*/

DECLARE @entrada1 INT;

-- EXITO: entrada válida
EXEC Ventas.InsertarEntradas
    @tarifa_id = @tarifaEntrada,
    @ticket_id = @ticket2,
    @tipo_fecha_id = @tipoFecha,
    @tipo_visitante_id = @tipoVisitante,
    @precio = 5000,
    @id = @entrada1 OUTPUT;
SELECT CAST(@entrada1 AS VARCHAR) AS 'ID entrada 1 insertada';

SELECT * FROM Ventas.Entradas WHERE id = @entrada1;

-- RECHAZO: tarifa inexistente
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = -1,
        @ticket_id = @ticket2,
        @tipo_fecha_id = @tipoFecha,
        @tipo_visitante_id = @tipoVisitante;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 1 (InsertarEntradas) - tarifa inexistente' END CATCH

-- RECHAZO: tarifa que no es de tipo Entrada (ej. el tour)
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = @tarifaTour,
        @ticket_id = @ticket2,
        @tipo_fecha_id = @tipoFecha,
        @tipo_visitante_id = @tipoVisitante;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 2 (InsertarEntradas) - tarifa no es de tipo Entrada' END CATCH

-- RECHAZO: ticket inexistente
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = @tarifaEntrada,
        @ticket_id = -1,
        @tipo_fecha_id = @tipoFecha,
        @tipo_visitante_id = @tipoVisitante;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 3 (InsertarEntradas) - ticket inexistente' END CATCH

-- RECHAZO: tipo de fecha inexistente
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = @tarifaEntrada,
        @ticket_id = @ticket2,
        @tipo_fecha_id = -1,
        @tipo_visitante_id = @tipoVisitante;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 4 (InsertarEntradas) - tipo de fecha inexistente' END CATCH

-- RECHAZO: tipo de visitante inexistente
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = @tarifaEntrada,
        @ticket_id = @ticket2,
        @tipo_fecha_id = @tipoFecha,
        @tipo_visitante_id = -1;
END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() AS 'Error 5 (InsertarEntradas) - tipo de visitante inexistente' END CATCH

-- RECHAZO: todos los parámetros obligatorios nulos
BEGIN TRY
    EXEC Ventas.InsertarEntradas
        @tarifa_id = NULL,
        @ticket_id = NULL,
        @tipo_fecha_id = NULL,
        @tipo_visitante_id = NULL;
END TRY
BEGIN CATCH 
    SELECT value AS 'Errores 6 (InsertarEntradas) - todo nulo'
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));
END CATCH


/*================================================================================================*/
--#### Limpieza ####--
/*================================================================================================*/

-- Rollback para no dejar datos de prueba en la base
IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRANSACTION;
END;