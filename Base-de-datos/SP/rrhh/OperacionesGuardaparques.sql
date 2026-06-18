USE ParquesNacionales;
GO 

-- Crea un nuevo guardaparque
CREATE OR ALTER PROCEDURE RRHH.CrearGuardaparque
    @cuil BIGINT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@cuil IS NULL, '@cuil no puede ser nulo', NULL),
        IIF(@cuil not between 20000000001 and 339999999999, '@cuil invalido', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.Guardaparques WHERE cuil = @cuil), 'El CUIL ya está asociado a un guardaparque', NULL),
        IIF(@nombre IS NULL, '@nombre no puede ser nulo', NULL),
        IIF(@apellido IS NULL, '@apellido no puede ser nulo', NULL),
        IIF(@fecha_nacimiento IS NULL, '@fecha_nacimiento no puede ser nulo', NULL),
        IIF(@fecha_nacimiento < DATEADD(year, -18, GETDATE()), 'El guardaparque debe ser mayor de edad', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    INSERT INTO RRHH.Guardaparques
    (cuil, nombre, apellido, f_nacimiento)
    VALUES
    (@cuil, @nombre, @apellido, @fecha_nacimiento);

    SET @id = SCOPE_IDENTITY();
END;
GO

-- Asigna a un guardaparque, permitiendo que trabaje en un parque.
CREATE OR ALTER PROCEDURE RRHH.AsignarGuardaparque
    @id_guardaparque INT,
    @id_parque INT,
    @fecha_ingreso DATE,
    @id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    -- Reglas de negocio: No se puede asignar si el guardaparque tiene una asignación activa.
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guardaparques WHERE id = @id_guardaparque), 'El guardaparque no existe', NULL),
        IIF(NOT EXISTS (SELECT 1 FROM Administracion.Parques WHERE id = @id_parque), 'El parque no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.AsignacionesDeGuardaparques 
                        WHERE guardaparques_id = @id_guardaparque AND f_egreso IS NULL), 'El guardaparque ya tiene una asignación activa', NULL),
        IIF(@fecha_ingreso IS NULL, '@fecha_ingreso no puede ser nulo', NULL)
    );
    
    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    INSERT INTO RRHH.AsignacionesDeGuardaparques
    (parque_id, guardaparques_id, f_ingreso)
    VALUES
    (@id_parque, @id_guardaparque, @fecha_ingreso);

    SET @id = SCOPE_IDENTITY();
END
GO


-- Remueve la asignación de un guardaparque a un parque.
CREATE OR ALTER PROCEDURE RRHH.FinalizarAsignacionGuardaparque
    @id_guardaparque INT, 
    @fecha_egreso DATE,
    @motivo VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON

    -- Se busca la fecha de ingreso de la asignación activa
    DECLARE @fechaIngreso DATE = (SELECT f_ingreso FROM RRHH.AsignacionesDeGuardaparques WHERE guardaparques_id = @id_guardaparque AND f_egreso IS NULL);

    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(@fechaIngreso IS NULL , 'El guardaparque no tiene una asignación activa', NULL),
        IIF(@fecha_egreso IS NULL, '@fecha_egreso no puede ser nulo', NULL),
        IIF(@fecha_egreso < @fechaIngreso, 'La fecha de egreso no puede ser anterior al ingreso.', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    BEGIN TRANSACTION
    SAVE TRANSACTION ComienzoSP
    BEGIN TRY
        UPDATE RRHH.AsignacionesDeGuardaparques
        SET f_egreso = @fecha_egreso, f_motivo_egreso = @motivo
        WHERE guardaparques_id = @id_guardaparque AND f_egreso IS NULL;

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

-- Editar un Guardaparque
CREATE OR ALTER PROCEDURE RRHH.EditarGuardaparque
    @id INT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guardaparques WHERE id = @id), 'El guardaparque no existe', NULL),
        IIF(@nombre IS NULL, '@nombre no puede ser nulo', NULL),
        IIF(@apellido IS NULL, '@apellido no puede ser nulo', NULL),
        IIF(@fecha_nacimiento IS NULL, '@fecha_nacimiento no puede ser nulo', NULL),
        IIF(@fecha_nacimiento > DATEADD(year, -18, GETDATE()), 'El guardaparque debe ser mayor de edad', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    UPDATE RRHH.Guardaparques
    SET nombre = @nombre,
        apellido = @apellido,
        f_nacimiento = @fecha_nacimiento
    WHERE id = @id;
END;
GO

-- Eliminar un Guardaparque
CREATE OR ALTER PROCEDURE RRHH.EliminarGuardaparque
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validamos que el guardaparque exista y que NUNCA haya tenido una asignación
    DECLARE @mensajeDeError VARCHAR(500) = CONCAT_WS(CHAR(10),
        IIF(NOT EXISTS (SELECT 1 FROM RRHH.Guardaparques WHERE id = @id), 'El guardaparque no existe', NULL),
        IIF(EXISTS (SELECT 1 FROM RRHH.AsignacionesDeGuardaparques WHERE guardaparques_id = @id), 'No se puede eliminar el guardaparque porque tiene o tuvo asignaciones a parques', NULL)
    );

    IF (LEN(@mensajeDeError) > 0) BEGIN
        ;THROW 50000, @mensajeDeError, 1;
    END;

    DELETE FROM RRHH.Guardaparques
    WHERE id = @id;
END;
GO