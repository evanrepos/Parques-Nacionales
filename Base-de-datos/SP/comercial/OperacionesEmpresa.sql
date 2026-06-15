/* #####################################
   # Universidad Nacional de la Matanza#
   #      Bases de Datos Aplicada      #
   #####################################

   Participan: 
     - Iván Gonzalez Fernandez
     - Matías Josué Lista

   #####################################
   #       OperacionesEmpresa.sql      #
   #####################################
   El objetivo de este script es definir todos los 
   store procedures relacionados con las
   operaciones de las empresas...
*/
USE ParquesNacionales;

CREATE OR ALTER PROCEDURE Comercial.RegistrarEmpresa
    @cuit BIGINT,
    @razon_social VARCHAR(100),
    @direccion_legal VARCHAR(100),
    @comienzo_actividad DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@cuit IS NULL, '@cuit no puede ser nulo', NULL),
        IIF(@cuit not between 20000000001 and 339999999999, '@cuit invalido', NULL),
        IIF(EXISTS (SELECT 1 FROM Comercial.Empresas WHERE cuit = @cuit), 'El CUIT ya está asociado a una empresa', NULL),
        IIF(@razon_social IS NULL, '@razon social no puede ser nulo', NULL),
        IIF(@direccion_legal IS NULL, '@direccion_legal no puede ser nulo', NULL),
        IIF(@comienzo_actividad IS NULL, '@comienzo_actividad no puede ser nulo', NULL),
        IIF(@comienzo_actividad > GETDATE(), '@comienzo_actividad no puede ser posterior a la fecha actual', NULL)
        );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    INSERT INTO Comercial.Empresas
    (cuit, razon_social, direccion_legal, comienzo_actividad)
    VALUES
    (@cuit, @razon_social, @direccion_legal, @comienzo_actividad);

    set @id = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE Comercial.ModificarEmpresa
    @id INT,
    @razon_social VARCHAR(100),
    @direccion_legal VARCHAR(100),
    @comienzo_actividad DATE
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@razon_social IS NULL, '@razon social no puede ser nulo', NULL),
        IIF(@direccion_legal IS NULL, '@direccion_legal no puede ser nulo', NULL),
        IIF(@comienzo_actividad IS NULL, '@comienzo_actividad no puede ser nulo', NULL),
        IIF(EXISTS (SELECT 1 FROM Comercial.Empresas WHERE id = @id), 'La empresa no existe', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    UPDATE Comercial.Empresas
    SET razon_social       = @razon_social,
        direccion_legal     = @direccion_legal,
        comienzo_actividad = @comienzo_actividad
    WHERE id = @id;

    set @id = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE Comercial.EliminarEmpresa
    @id INT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM Comercial.Empresas WHERE id = @id), 'La empresa no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM Comercial.Concesiones WHERE empresa_id = @id), 'La empresa tiene  concesiones asociadas.', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    DELETE FROM Comercial.Empresas
    WHERE id = @id;

    set @id = SCOPE_IDENTITY();
END
GO




