USE ParquesNacionales
GO

--INGRESAR DATOS
--Ingresar registros paramétricas.
CREATE OR ALTER PROCEDURE Administracion.IngresarFormasDePago 
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1 
        FROM Administracion.FormasDePago 
        WHERE descripcion = @descripcion
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.FormasDePago (descripcion) VALUES (@descripcion)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar FORMA DE PAGO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarDivisas 
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1 
        FROM Administracion.Divisas 
        WHERE descripcion = @descripcion
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        INSERT INTO Administracion.Divisas (descripcion) VALUES (@descripcion)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al insertar Divisas: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeFecha
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1 
        FROM Administracion.TiposDeFecha 
        WHERE descripcion  =
          @descripcion 
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        INSERT INTO Administracion.TiposDeFecha (descripcion) VALUES (@descripcion)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al insertar TIPO DE FECHA: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeVisitante 
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1 
        FROM Administracion.TiposDeVisitante 
        WHERE descripcion  =
          @descripcion 
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        INSERT INTO Administracion.TiposDeVisitante (descripcion) VALUES (@descripcion)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al insertar TIPO DE VISITANTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeParque
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1 
        FROM Administracion.TiposDeParque 
        WHERE descripcion  =
          @descripcion 
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        INSERT INTO Administracion.TiposDeParque (descripcion) VALUES (@descripcion)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al insertar TIPO DE PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarProvincias
    @nombre VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @nombre IS NULL
    BEGIN
	RAISERROR('Ingrese un NOMBRE válido para la provincia.', 16, 1)
        RETURN
    END

    --REGISTRO REPETIDO
    IF EXISTS (
        SELECT 1
        FROM Administracion.Provincias 
        WHERE descripcion  =
          @nombre 
          )
    BEGIN
	    RAISERROR('NO ingrese REPETIDOS.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Provincias (descripcion) VALUES (@nombre)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar provincia: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarParques
    @tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
	@direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --TIPO PARQUE
    IF @tipo_parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.TiposDeParque WHERE @tipo_parque_id = id)
    BEGIN
        RAISERROR('El TIPO de PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --provincia
    IF @provincia_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Provincias WHERE @provincia_id = id)
    BEGIN
        RAISERROR('La provincia no existe o es inválida.', 16, 1)
        RETURN
    END

    --CAMPOS NULOS
    IF @nombre IS NULL
    BEGIN
	RAISERROR('Ingrese un NOMBRE válido para el parque.', 16, 1)
        RETURN
    END

    --SUPERFICIE
    IF @superficie <= 0
    BEGIN
	RAISERROR('Ingrese una superficie mayor que cero.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Parques (tipo_parque_id, provincia_id, direccion, nombre, superficie_km_2) VALUES (
        @tipo_parque_id, 
        @provincia_id, 
        @direccion,
        @nombre,
        @superficie
        )
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTarifasDeArticulo
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @duracion INT = NULL,
    @cupo INT = NULL,
    @precio DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --PARQUE
    IF @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --TIPO ARTICULO
    IF @tipo_articulo IS NULL OR @tipo_articulo NOT IN ('E', 'A', 'T')
    BEGIN
        RAISERROR('El TIPO de ARTÍCULO no existe o es inválido.', 16, 1)
        RETURN
    END

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('Ingrese una DESCRIPCION válida para el producto.', 16, 1)
        RETURN
    END

    --TOUR SIN DURACION O CUPO
    IF @tipo_articulo = 'T' AND (@duracion IS NULL OR @cupo IS NULL OR @duracion <= 0 OR @cupo <= 0)
    BEGIN
	RAISERROR('El TOUR no puede tener una DURACIÓN o CUPO nulos.', 16, 1)
        RETURN
    END

    --PRECIO
    IF @precio IS NULL OR @precio < 0 --El artículo podría ser GRATUITO, ojo!
    BEGIN
	RAISERROR('Ingrese un PRECIO válido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.TarifasDeArticulo (parque_id, tipo_articulo, descripcion, duracion, cupo, precio) VALUES (
        @parque_id,
        @tipo_articulo,
        @descripcion,
        @duracion,
        @cupo,
        @precio
        )
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar TARIFA DE ARTÍCULO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarAjustes
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_ajuste CHAR(1) = NULL,
    @descripcion VARCHAR(30) = NULL,
    @porcentaje SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --PARQUE
    IF @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --TIPO ARTICULO
    IF @tipo_articulo IS NULL OR @tipo_articulo NOT IN ('E', 'A', 'T')
    BEGIN
        RAISERROR('El TIPO de ARTÍCULO no existe o es inválido.', 16, 1)
        RETURN
    END

    --TIPO AJUSTE
    IF @tipo_ajuste IS NULL OR @tipo_ajuste NOT IN ('F', 'V', 'TE')
    BEGIN
        RAISERROR('El TIPO de AJUSTE no existe o es inválido.', 16, 1)
        RETURN
    END
    
    --CAMPOS NULOS
    IF @descripcion IS NULL OR @porcentaje IS NULL OR @porcentaje < -100
    BEGIN
	RAISERROR('Ingrese campos válidos', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Ajustes (parque_id, tipo_articulo, tipo_ajuste, descripcion, porcentaje) VALUES (
        @parque_id,
        @tipo_articulo,
        @tipo_ajuste,
        @descripcion,
        @porcentaje
        )
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarPuntosDeVenta
    @parque_id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id SMALLINT;
    
    --PARQUE
    IF @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        SELECT @id = ISNULL(MAX(id), 0) + 1
            FROM Administracion.PuntosDeVenta
            WHERE parque_id = @parque_id;
        INSERT INTO Administracion.PuntosDeVenta (id, parque_id, descripcion) VALUES (
                @id,
                @parque_id,
                @descripcion
                )
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar PUNTO DE VENTA: %s', 16, 1, @error)
    END CATCH
END;
GO

/*------------------------------------------------------------------------------------------------------------*/
--ACTUALIZAR DATOS
CREATE OR ALTER PROCEDURE Administracion.ActualizarFormasDePago
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @id_real_fdp INT
    SELECT @id_real_fdp = id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion_vieja = descripcion

    IF @id_real_fdp IS NULL
    BEGIN
        RAISERROR('La FORMA DE PAGO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.FormasDePago 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @id_real_fdp
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar FORMA DE PAGO: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarDivisas
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @id_real_div INT
    SELECT @id_real_div = id FROM Administracion.Divisas WHERE @id = id OR @descripcion_vieja = descripcion

    IF @id_real_div IS NULL
    BEGIN
        RAISERROR('La Divisas no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Divisas 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @id_real_div
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar Divisas: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeFecha
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @id_real_tdf INT
    SELECT @id_real_tdf = id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion_vieja = descripcion

    IF @id_real_tdf IS NULL
    BEGIN
        RAISERROR('El TIPO DE FECHA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TiposDeFecha 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @id_real_tdf
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TIPO DE FECHA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeVisitante
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @id_real_tdv INT
    SELECT @id_real_tdv = id FROM Administracion.TiposDeVisitante WHERE @id = id OR @descripcion_vieja = descripcion

    IF @id_real_tdv IS NULL
    BEGIN
        RAISERROR('El TIPO DE VISITANTE no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TiposDeVisitante 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @id_real_tdv
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TIPO DE VISITANTE: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeParque
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTDP INT
    SELECT @idRealTDP = id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion_vieja = descripcion

    IF @idRealTDP IS NULL
    BEGIN
        RAISERROR('El TIPO DE PARQUE no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TiposDeParque 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealTDP
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TIPO DE PARQUE: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarProvincias
    @id INT = NULL,
    @descripcion_vieja VARCHAR(100) = NULL,
    @descripcion_nueva VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealProv INT
    SELECT @idRealProv = id FROM Administracion.Provincias WHERE @id = id OR @descripcion_vieja = descripcion

    IF @idRealProv IS NULL
    BEGIN
        RAISERROR('La Provincias no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Provincias 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealProv
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar Provincias: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarProvincias
    @id INT = NULL,
    @descripcion_vieja VARCHAR(100) = NULL,
    @descripcion_nueva VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealLoc INT
    SELECT @idRealLoc = id FROM Administracion.Provincias WHERE @id = id OR @descripcion_vieja = descripcion

    IF @idRealLoc IS NULL
    BEGIN
        RAISERROR('La provincia no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Provincias 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion)
        WHERE id = @idRealLoc
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar provincia: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarParques
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
    @direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie_km_2 INT = NULL,
    @direccion_nueva VARCHAR(150) = NULL,
	@nombre_nuevo VARCHAR(100) = NULL,
	@superficie_nueva INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @tipo_parque_id IS NULL AND @provincia_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL) OR 
        (@direccion_nueva IS NULL AND @nombre_nuevo IS NULL AND @superficie_nueva IS NULL)
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealParque INT
    SELECT @idRealParque = id FROM Administracion.Parques 
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @provincia_id = provincia_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2

    IF @idRealParque IS NULL
    BEGIN
        RAISERROR('La PARQUE no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Parques 
        SET    direccion    = ISNULL(@direccion_nueva, direccion),
               nombre       = ISNULL(@nombre_nuevo, nombre),
            superficie_km_2 = ISNULL(@superficie_nueva, superficie_km_2)
        WHERE id = @idRealParque
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTarifasDeArticulo
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @duracion INT = NULL,
    @cupo INT = NULL,
    @precio DECIMAL(10, 2) = NULL,
    @tipo_articulo_nuevo CHAR(1) = NULL,
    @descripcion_nueva VARCHAR(50) = NULL,
    @duracion_nueva INT = NULL,
    @cupo_nuevo INT = NULL,
    @precio_nuevo DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @descripcion IS NULL AND @duracion IS NULL AND @cupo IS NULL AND @precio IS NULL) OR 
        (@tipo_articulo_nuevo IS NULL AND @descripcion_nueva IS NULL  AND @duracion_nueva IS NULL AND @cupo_nuevo IS NULL AND @precio_nuevo IS NULL)
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTarifa INT
    SELECT @idRealTarifa = id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio

    IF @idRealTarifa IS NULL
    BEGIN
        RAISERROR('La TARIFA ARTÍCULO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TarifasDeArticulo 
        SET tipo_articulo = ISNULL(@tipo_articulo_nuevo, tipo_articulo),
            descripcion    = ISNULL(@descripcion_nueva, descripcion),
            duracion       = ISNULL(@duracion_nueva, duracion),
            cupo           = ISNULL(@cupo_nuevo, cupo),
            precio         = ISNULL(@precio_nuevo, precio)
        WHERE id = @idRealTarifa
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TARIFA ARTÍCULO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarAjustes
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_ajuste CHAR(1) = NULL,
    @descripcion VARCHAR(30) = NULL,
    @porcentaje TINYINT = NULL,
    @tipo_articulo_nuevo CHAR(1) = NULL,
    @tipo_ajuste_nuevo CHAR(1) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL,
    @porcentaje_nuevo TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_ajuste IS NULL AND @descripcion IS NULL AND @porcentaje IS NULL) OR 
        (@tipo_articulo_nuevo IS NULL AND @tipo_ajuste_nuevo IS NULL AND @descripcion_nueva IS NULL AND @porcentaje_nuevo IS NULL)
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealAjuste INT
    SELECT @idRealAjuste = id FROM Administracion.Ajustes 
        WHERE id = @id OR parque_id = @parque_id OR tipo_articulo = @tipo_articulo OR tipo_ajuste = @tipo_ajuste OR descripcion = @descripcion OR porcentaje = @porcentaje

    IF @idRealAjuste IS NULL
    BEGIN
        RAISERROR('El AJUSTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Ajustes 
        SET tipo_articulo = ISNULL(@tipo_articulo_nuevo, tipo_articulo), 
              tipo_ajuste = ISNULL(@tipo_ajuste_nuevo, tipo_ajuste), 
              descripcion = ISNULL(@descripcion_nueva, descripcion), 
              porcentaje  = ISNULL(@porcentaje_nuevo, porcentaje) 
        WHERE id = @idRealAjuste
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarPuntosDeVenta
    @id INT = NULL,
    @parque_id INT = NULL,
    @descripcion_vieja VARCHAR(100) = NULL,
    @descripcion_nueva VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @parque_id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealPDV INT
    SELECT @idRealPDV = id FROM Administracion.PuntosDeVenta WHERE @id = id OR @parque_id = parque_id OR @descripcion_vieja = descripcion

    IF @idRealPDV IS NULL
    BEGIN
        RAISERROR('El PUNTO DE VENTA no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.PuntosDeVenta 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealPDV
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar PUNTO DE VENTA: %s', 16, 1, @error)
    END CATCH
END;
GO

/*------------------------------------------------------------------------------------------------------------*/
--ELIMINAR DATOS
CREATE OR ALTER PROCEDURE Administracion.EliminarFormasDePago
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealFDP INT
    SELECT @idRealFDP = id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion = descripcion

    IF @idRealFDP IS NULL
    BEGIN
        RAISERROR('La FORMA DE PAGO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.FormasDePago 
        WHERE id = @idRealFDP
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar FORMA DE PAGO: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarDivisas
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealDiv INT
    SELECT @idRealDiv = id FROM Administracion.Divisas WHERE @id = id OR @descripcion = descripcion

    IF @idRealDiv IS NULL
    BEGIN
        RAISERROR('La Divisas no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Divisas 
        WHERE id = @idRealDiv
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar Divisas: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeFecha
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTDF INT
    SELECT @idRealTDF = id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion = descripcion

    IF @idRealTDF IS NULL
    BEGIN
        RAISERROR('El TIPO DE FECHA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TiposDeFecha
        WHERE id = @idRealTDF
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TIPO DE FECHA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeVisitante
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTDV INT
    SELECT @idRealTDV = id FROM Administracion.TiposDeVisitante WHERE @id = id OR @descripcion = descripcion

    IF @idRealTDV IS NULL
    BEGIN
        RAISERROR('El TIPO DE VISITANTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TiposDeVisitante
        WHERE id = @idRealTDV
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TIPO DE VISITANTE: %s', 16, 1, @error)
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeParque
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTDP INT
    SELECT @idRealTDP = id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion = descripcion

    IF @idRealTDP IS NULL
    BEGIN
        RAISERROR('El TIPO DE PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TiposDeParque
        WHERE id = @idRealTDP
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TIPO DE PARQUE: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarProvincias
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealProv INT
    SELECT @idRealProv = id FROM Administracion.Provincias WHERE @id = id OR @descripcion = descripcion

    IF @idRealProv IS NULL
    BEGIN
        RAISERROR('La Provincia no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Provincias
        WHERE id = @idRealProv
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar Provincias: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarProvincias
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealLoc INT
    SELECT @idRealLoc = id FROM Administracion.Provincias WHERE @id = id OR @descripcion = descripcion

    IF @idRealLoc IS NULL
    BEGIN
        RAISERROR('La provincia no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Provincias
        WHERE id = @idRealLoc
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar provincia: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarParques
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
    @direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie_km_2 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @tipo_parque_id IS NULL AND @provincia_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealParque INT
    SELECT @idRealParque = id FROM Administracion.Parques 
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @provincia_id = provincia_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2

    IF @idRealParque IS NULL
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Parques
        WHERE id = @idRealParque
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTarifasDeArticulo
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @duracion INT = NULL,
    @cupo INT = NULL,
    @precio DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @descripcion IS NULL AND @duracion IS NULL AND @cupo IS NULL AND @precio IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealTarifa INT
    SELECT @idRealTarifa = id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio

    IF @idRealTarifa IS NULL
    BEGIN
        RAISERROR('La TARIFA DE ARTICULO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TarifasDeArticulo
        WHERE id = @idRealTarifa
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TARIFA DE ARTÍCULO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarAjustes
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_ajuste INT = NULL,
    @descripcion INT = NULL,
    @porcentaje TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_ajuste IS NULL AND @descripcion IS NULL AND @porcentaje IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealAjuste INT
    SELECT @idRealAjuste = id FROM Administracion.Ajustes 
        WHERE id = @id AND parque_id = @parque_id AND tipo_articulo = @tipo_articulo AND tipo_ajuste = @tipo_ajuste AND descripcion = @descripcion AND porcentaje = @porcentaje

    IF @idRealAjuste IS NULL
    BEGIN
        RAISERROR('El AJUSTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Ajustes
        WHERE id = @idRealAjuste
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarPuntosDeVenta
    @id INT = NULL,
    @parque_id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @parque_id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    DECLARE @idRealPDV INT
    SELECT @idRealPDV = id FROM Administracion.PuntosDeVenta WHERE @id = id OR @parque_id = parque_id OR @descripcion = descripcion

    IF @idRealPDV IS NULL
    BEGIN
        RAISERROR('El PUNTO DE VENTA no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.PuntosDeVenta
        WHERE id = @idRealPDV
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar PUNTO DE VENTA: %s', 16, 1, @error)
    END CATCH
END;
GO