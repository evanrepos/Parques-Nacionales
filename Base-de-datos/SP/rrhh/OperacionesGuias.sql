USE ParquesNacionales;
GO 

CREATE OR ALTER PROCEDURE RRHH.CrearGuia
    @cuil BIGINT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@cuil IS NULL, '@cuit no puede ser nulo', NULL),
        IIF(@cuil not between 20000000001 and 339999999999, '@cuit invalido', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.Guias WHERE cuil = @cuil), 'El CUIL ya está asociado a un guía', NULL),
        IIF(@nombre IS NULL, '@nombre no puede ser nulo', NULL),
        IIF(@apellido IS NULL, '@apellido no puede ser nulo', NULL),
        IIF(@fecha_nacimiento IS NULL, '@@fecha_nacimiento no puede ser nulo', NULL),
        IIF(@fecha_nacimiento > DATEADD(year, -18, GETDATE()), 'El guía debe ser mayor de edad', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- Un guía nace sin asignación, por lo tanto inactivo.
    INSERT INTO RRHH.Guias
    (cuil, nombre, apellido, esta_activo, f_nacimiento)
    VALUES
    (@cuil, @nombre, @apellido, 0, @fecha_nacimiento);

    SET @id = SCOPE_IDENTITY();
END;
GO

/*CREATE OR ALTER PROCEDURE RRHH.ModificarGuia
    @id INT,
    @cuit BIGINT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE
AS
BEGIN
    UPDATE rrhh.guia
    SET id = @id, 
        cuit = @cuit, 
        nombre = @nombre, 
        apellido = @apellido, 
        fecha_nacimiento = @fecha_nacimiento
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE dbo.EliminarGuia
    @id INT
AS
BEGIN
    -- Validar si existía, validar si falla por estar siendo usado
    DELETE FROM rrhh.guia
    WHERE id = @id;
END;
GO*/

-- Asigna a un guía, permitiendo que trabaje en un parque.
CREATE OR ALTER PROCEDURE RRHH.AsignarGuia
    @id_guia INT,
    @id_parque INT,
    @fecha_ingreso DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    -- Reglas de negocio: No se puede asignar si el guía tiene una asignación activa.
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guias WHERE id = @id_guia), 'El guía no existe', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.Parques WHERE id = @id_parque), 'El parque no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.AsignacionesDeGuias 
                        WHERE guia_id = @id_guia AND f_egreso IS NULL), 'El guía ya tiene una asignación activa', NULL),
        IIF(@fecha_ingreso IS NULL, '@fecha_ingreso no puede ser nulo', NULL)
    );
    
    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION
        SAVE TRANSACTION ComienzoSP

        INSERT INTO RRHH.AsignacionesDeGuias
        (parque_id, guia_id, f_ingreso)
        VALUES
        (@id_parque, @id_guia, @fecha_ingreso);

        SET @id = SCOPE_IDENTITY();

        -- Al tener una asignación vigente, el guía pasa a estar activo
        -- (independientemente de si ya tiene autorizaciones para dar tours o no).
        UPDATE RRHH.Guias
        SET esta_activo = 1
        WHERE id = @id_guia;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ComienzoSP;
        END;
        ;THROW;
    END CATCH
END
GO


-- Remueve la asignación de un guía a un parque.
CREATE OR ALTER PROCEDURE RRHH.FinalizarAsignacionGuia
    @id_guia INT, -- Es ID de la asignación
    @fecha_egreso DATE,
    @motivo VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @fechaIngreso DATE = (SELECT f_ingreso FROM RRHH.AsignacionesDeGuias WHERE guia_id = @id_guia AND f_egreso IS NULL);

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@fechaIngreso IS NULL , 'El guía no tiene una asignación activa', NULL),
        IIF(@fecha_egreso IS NULL, '@fecha_egreso no puede ser nulo', NULL),
        IIF(@fecha_egreso < @fechaIngreso, 'La fecha de egreso no puede ser anterior al ingreso.', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRANSACTION
    SAVE TRANSACTION ComienzoSP
    BEGIN TRY
        UPDATE RRHH.AsignacionesDeGuias
        SET f_egreso = @fecha_egreso, 
            motivo_egreso = @motivo
        WHERE guia_id = @id_guia AND f_egreso IS NULL;

        -- Si un guía deja de estar asignado a un parque, se terminan sus permisos activos.
        UPDATE RRHH.AutorizacionesDeGuias 
        SET f_fin = @fecha_egreso
        WHERE guia_id = @id_guia AND f_fin IS NULL;

        -- Al finalizar la asignación, el guía pasa a estar inactivo.
        UPDATE RRHH.Guias
        SET esta_activo = 0
        WHERE id = @id_guia;

    COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION ComienzoSP;
        END;

        ;THROW;
    END CATCH

END
GO

-- Autoriza a un guía a participar en una actividad.
CREATE OR ALTER PROCEDURE RRHH.AutorizarGuia
    @id_guia INT,
    @id_tarifa INT,
    @fecha_inicio DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    -- 1. La tarifa debe ser un Tour.
    -- 2. El guía debe tener una asignación activa en ese parque.
    DECLARE @tipoArticulo CHAR(1) = (SELECT tipo_articulo 
                                     FROM Administracion.TarifasDeArticulo 
                                     WHERE id = @id_tarifa);
    DECLARE @guiaExiste BIT = IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guias WHERE id = @id_guia), 0, 1);

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@guiaExiste = 0, 'El guía no existe', NULL),
        IIF(@tipoArticulo IS NULL, 'El tour no existe', NULL),
        IIF(@tipoArticulo <> 'T', 'La actividad no es un tour', NULL),
        IIF(@fecha_inicio IS NULL, '@fecha_inicio no puede ser nulo', NULL)
    );

    IF (@tipoArticulo = 'T' AND @guiaExiste = 1)
    begin
        -- Si el tour y el guia son reales, validamos la asignacion del guía al parque
        
        -- Obtenemos el parque del tour.
        DECLARE @parqueId INT = (SELECT parque_id
                                 FROM Administracion.TarifasDeArticulo 
                                 WHERE id = @id_tarifa);
        -- Validamos asignacion
        DECLARE @fechaIngreso DATE = (SELECT f_ingreso FROM RRHH.AsignacionesDeGuias
                                           WHERE guia_id = @id_guia
                                           AND parque_id = @parqueId
                                           AND f_egreso IS NULL);

        SET @mensajeDeError += CONCAT_WS(CHAR(10),
                                   IIF(@fechaIngreso IS NULL, 'El guía no está asignado al parque del tour', NULL),
                                   IIF(@fecha_inicio < @fechaIngreso, 'La fecha de autorizacion no puede ser menor a su ingreso en el parque', NULL)
                               );
    END;

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- INSERT
    INSERT INTO RRHH.AutorizacionesDeGuias 
    (articulo_id, guia_id, f_inicio)
    VALUES (@id_tarifa, @id_guia, @fecha_inicio);

    SET @id = SCOPE_IDENTITY();
END
GO

-- Revoca el permiso de un guía a participar en una actividad de un parque.
CREATE OR ALTER PROCEDURE RRHH.FinalizarAutorizacionGuia
    @id_guia INT,
    @id_tarifa INT,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON

    -- 1. El guía debe estar autorizado al tour que se desea remover.
       -- (por consistencia de los Store Procedures, si está autorizado a dar el tour, está asignado al parque y la actividad es un tour)
    DECLARE @tipoArticulo CHAR(1) = (SELECT tipo_articulo 
                                     FROM Administracion.TarifasDeArticulo 
                                     WHERE id = @id_tarifa);
    DECLARE @guiaExiste BIT = IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guias WHERE id = @id_guia), 0, 1);
    DECLARE @tarifaExiste BIT = IIF(NOT EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE id = @id_tarifa), 0, 1);

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@guiaExiste = 0, 'El guía no existe', NULL),
        IIF(@tarifaExiste = 0, 'La tarifa no existe', NULL)
    );

    IF (@guiaExiste = 1 AND @tarifaExiste = 1)
    begin
        -- Si el tour y el guia son reales, validamos la autorizacion, y las fechas
        DECLARE @fechaInicio DATE = (SELECT f_inicio 
        FROM RRHH.AutorizacionesDeGuias
        WHERE guia_id = @id_guia AND articulo_id = @id_tarifa AND f_fin IS NULL);

        SET @mensajeDeError += CONCAT_WS(CHAR(10),
                                   IIF(@fechaInicio IS NULL, 'El guía no está autorizado a dar ese tour', ''),
                                   IIF(@fecha_fin < @fechaInicio, 'La fecha de fin no puede ser anterior a la fecha de autorizacion', '')
                               );
    END;

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    -- INSERT
    UPDATE RRHH.AutorizacionesDeGuias
    SET f_fin = @fecha_fin
    WHERE guia_id = @id_guia AND articulo_id = @id_tarifa AND f_fin IS NULL;

END
GO

-- Editar un Guía
CREATE OR ALTER PROCEDURE RRHH.EditarGuia
    @id INT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guias WHERE id = @id), 'El guía no existe', NULL),
        IIF(@nombre IS NULL, '@nombre no puede ser nulo', NULL),
        IIF(@apellido IS NULL, '@apellido no puede ser nulo', NULL),
        IIF(@fecha_nacimiento IS NULL, '@fecha_nacimiento no puede ser nulo', NULL),
        IIF(@fecha_nacimiento > DATEADD(year, -18, GETDATE()), 'El guía debe ser mayor de edad', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    UPDATE RRHH.Guias
    SET nombre = @nombre,
        apellido = @apellido,
        f_nacimiento = @fecha_nacimiento
    WHERE id = @id;
END;
GO

-- Eliminar un Guía
CREATE OR ALTER PROCEDURE RRHH.EliminarGuia
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validamos que el guía exista y que NUNCA haya tenido una asignación
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guias WHERE id = @id), 'El guía no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.AsignacionesDeGuias WHERE guia_id = @id), 'No se puede eliminar el guía porque tiene o tuvo asignaciones a parques/actividades', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    DELETE FROM RRHH.Guias
    WHERE id = @id;
END;
GO