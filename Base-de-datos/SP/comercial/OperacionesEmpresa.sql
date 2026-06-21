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
GO

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

    SET @id = SCOPE_IDENTITY();
END
GO

-- Para identificar la empresa a modificar, se acepta @id o @cuit (ambos son únicos).
-- Los nuevos valores son opcionales: solo se actualiza lo que se envíe (patrón ISNULL).
CREATE OR ALTER PROCEDURE Comercial.ModificarEmpresa
    @id INT = NULL,
    @cuit BIGINT = NULL,
    @razon_social_nueva VARCHAR(100) = NULL,
    @direccion_legal_nueva VARCHAR(100) = NULL,
    @comienzo_actividad_nuevo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@id IS NULL AND @cuit IS NULL, 'Debe indicar @id o @cuit para identificar la empresa', NULL),
        IIF(@razon_social_nueva IS NULL AND @direccion_legal_nueva IS NULL AND @comienzo_actividad_nuevo IS NULL, 'Debe indicar al menos un campo a modificar', NULL),
        IIF(@comienzo_actividad_nuevo > GETDATE(), '@comienzo_actividad_nuevo no puede ser posterior a la fecha actual', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- Resolución de la PK real a partir de @id o @cuit
    DECLARE @id_real INT;
    SELECT @id_real = id
    FROM Comercial.Empresas
    WHERE id = @id OR cuit = @cuit;

    IF (@id_real IS NULL) BEGIN
        ;THROW 50000, 'La empresa no existe', 1;
    END;

    UPDATE Comercial.Empresas
    SET razon_social       = ISNULL(@razon_social_nueva, razon_social),
        direccion_legal     = ISNULL(@direccion_legal_nueva, direccion_legal),
        comienzo_actividad = ISNULL(@comienzo_actividad_nuevo, comienzo_actividad)
    WHERE id = @id_real;

END
GO

-- Para identificar la empresa a eliminar, se acepta @id o @cuit (ambos son únicos).
CREATE OR ALTER PROCEDURE Comercial.EliminarEmpresa
    @id INT = NULL,
    @cuit BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON

    IF (@id IS NULL AND @cuit IS NULL) BEGIN
        ;THROW 50000, 'Debe indicar @id o @cuit para identificar la empresa', 1;
    END;

    DECLARE @id_real INT;
    SELECT @id_real = id
    FROM Comercial.Empresas
    WHERE id = @id OR cuit = @cuit;

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@id_real IS NULL, 'La empresa no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM Comercial.Concesiones WHERE empresa_id = @id_real), 'La empresa tiene concesiones asociadas.', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    DELETE FROM Comercial.Empresas
    WHERE id = @id_real;
END
GO