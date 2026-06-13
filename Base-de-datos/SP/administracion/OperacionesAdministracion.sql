USE ParquesNacionales
GO

--INGRESAR DATOS
--Ingresar registros paramétricas.
CREATE OR ALTER PROCEDURE Administracion.IngresarFormaPago 
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
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
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
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

CREATE OR ALTER PROCEDURE Administracion.IngresarTipoFecha
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
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

CREATE OR ALTER PROCEDURE Administracion.IngresarTipoVisitante 
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
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

CREATE OR ALTER PROCEDURE Administracion.IngresarTipoParque
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --CAMPOS NULOS
    IF @descripcion IS NULL
    BEGIN
	RAISERROR('NO ingrese campos NULOS.', 16, 1)
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

CREATE OR ALTER PROCEDURE Administracion.IngresarProvincia
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

    --(TRY-CATCH) 
    BEGIN TRY
        INSERT INTO Administracion.Provincias (descripcion) VALUES (@nombre)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al insertar PROVINCIA: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarLocalidad
    @provincia_id INT = NULL,
    @nombre VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --PROVINCIA
    IF @provincia_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Provincias WHERE @provincia_id = id)
    BEGIN
        RAISERROR('La PROVINCIA no existe o es inválida.', 16, 1)
        RETURN
    END

    --CAMPOS NULOS
    IF @nombre IS NULL
    BEGIN
	RAISERROR('Ingrese un NOMBRE válido para la localidad.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Localidades (provincia_id, descripcion) VALUES (@provincia_id, @nombre)
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar LOCALIDAD: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarParque
    @tipo_parque_id INT = NULL,
	@localidad_id INT = NULL,
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

    --LOCALIDAD
    IF @localidad_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Localidades WHERE @localidad_id = id)
    BEGIN
        RAISERROR('La LOCALIDAD no existe o es inválida.', 16, 1)
        RETURN
    END

    --CAMPOS NULOS
    IF @nombre IS NULL
    BEGIN
	RAISERROR('Ingrese un NOMBRE válido para el parque.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Parques (tipo_parque_id, localidad_id, direccion, nombre, superficie_km_2) VALUES (
        @tipo_parque_id, 
        @localidad_id, 
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

CREATE OR ALTER PROCEDURE Administracion.IngresarTarifaArticulo
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

    IF @tipo_articulo = 'T' AND (@duracion IS NULL OR @cupo IS NULL OR @duracion <= 0 OR @cupo <= 0)
    BEGIN
	RAISERROR('El TOUR no puede tener una DURACIÓN o CUPO nulos.', 16, 1)
        RETURN
    END

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

CREATE OR ALTER PROCEDURE Administracion.IngresarAjuste
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_visitante_id INT = NULL,
    @tipo_fecha_id INT = NULL,
    @porcentaje TINYINT = NULL
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

    --TIPO VISITANTE    
    IF @tipo_visitante_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.TiposDeVisitante WHERE @tipo_visitante_id = id)
    BEGIN
        RAISERROR('El TIPO de VISITANTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --TIPO FECHA
    IF @tipo_fecha_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.TiposDeFecha WHERE @tipo_fecha_id = id)
    BEGIN
        RAISERROR('El TIPO de FECHA no existe o es inválido.', 16, 1)
        RETURN
    END
    
    --CAMPOS NULOS
    IF @porcentaje IS NULL OR @porcentaje < -100
    BEGIN
	RAISERROR('Ingrese un porcentaje válido', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.Ajustes (parque_id, tipo_articulo, tipo_visitante_id, tipo_fecha_id, porcentaje) VALUES (
        @parque_id,
        @tipo_articulo,
        @tipo_visitante_id,
        @tipo_fecha_id,
        @porcentaje
        )
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
        RAISERROR('Error al insertar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarPuntoVenta
    @parque_id INT = NULL,
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    --PARQUE
    IF @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH)
    BEGIN TRY
        INSERT INTO Administracion.PuntosDeVenta (parque_id, descripcion) VALUES (
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
CREATE OR ALTER PROCEDURE Administracion.ActualizarFormaPago
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
    IF NOT EXISTS (SELECT id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('La FORMA DE PAGO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.FormasDePago 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @descripcion_vieja = descripcion
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
    IF NOT EXISTS (SELECT id FROM Administracion.Divisas WHERE @id = id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('La Divisas no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Divisas 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar Divisas: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTipoFecha
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
    IF NOT EXISTS (SELECT id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('El TIPO DE FECHA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TiposDeFecha 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TIPO DE FECHA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTipoParque
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
    IF NOT EXISTS (SELECT id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('El TIPO DE PARQUE no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TiposDeParque 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TIPO DE PARQUE: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarProvincia
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
    IF NOT EXISTS (SELECT id FROM Administracion.Provincias WHERE @id = id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('La PROVINCIA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Provincias 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar PROVINCIA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarLocalidad
    @id INT = NULL,
    @provincia_id INT = NULL,
    @descripcion_vieja VARCHAR(100) = NULL,
    @descripcion_nueva VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @provincia_id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Localidades WHERE @id = id OR @provincia_id = provincia_id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('La LOCALIDAD no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Localidades 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion)
        WHERE @id = id OR @provincia_id = provincia_id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar LOCALIDAD: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarParque
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@localidad_id INT = NULL,
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
    IF (@id IS NULL AND @tipo_parque_id IS NULL AND @localidad_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL) OR 
        (@direccion_nueva IS NULL AND @nombre_nuevo IS NULL AND @superficie_nueva IS NULL)
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Parques 
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @localidad_id = localidad_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2)
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
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @localidad_id = localidad_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTarifaArticulo
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
    IF NOT EXISTS (SELECT id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio)
    BEGIN
        RAISERROR('La TARIFA ARTÍCULO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.TarifasDeArticulo 
        SET tipo_articulo   = ISNULL(@tipo_articulo_nuevo, tipo_articulo),
            descripcion     = ISNULL(@descripcion_nueva, descripcion),
            duracion        = ISNULL(@duracion_nueva, duracion),
            cupo            = ISNULL(@cupo_nuevo, cupo),
            precio          = ISNULL(@precio_nuevo, precio)
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar TARIFA ARTÍCULO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarAjuste
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_visitante_id INT = NULL,
    @tipo_fecha_id INT = NULL,
    @porcentaje TINYINT = NULL,
    @tipo_articulo_nuevo CHAR(1) = NULL,
    @porcentaje_nuevo TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF (@id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_visitante_id IS NULL AND @tipo_fecha_id IS NULL AND @porcentaje IS NULL) OR 
        (@tipo_articulo_nuevo IS NULL AND @porcentaje_nuevo IS NULL)
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Ajustes 
        WHERE id = @id OR parque_id = @parque_id OR tipo_articulo = @tipo_articulo OR tipo_visitante_id = @tipo_visitante_id OR tipo_fecha_id = @tipo_fecha_id OR porcentaje = @porcentaje)
    BEGIN
        RAISERROR('El AJUSTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.Ajustes 
        SET tipo_articulo = ISNULL(@tipo_articulo_nuevo, tipo_articulo), 
               porcentaje = ISNULL(@porcentaje_nuevo, porcentaje) 
        WHERE id = @id OR parque_id = @parque_id OR tipo_articulo = @tipo_articulo OR tipo_visitante_id = @tipo_visitante_id OR tipo_fecha_id = @tipo_fecha_id OR porcentaje = @porcentaje
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarPuntoVenta
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
    IF NOT EXISTS (SELECT id FROM Administracion.PuntosDeVenta WHERE @id = id OR @parque_id = parque_id OR @descripcion_vieja = descripcion)
    BEGIN
        RAISERROR('El PUNTO DE VENTA no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        UPDATE Administracion.PuntosDeVenta 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE @id = id OR @parque_id = parque_id OR @descripcion_vieja = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al actualizar PUNTO DE VENTA: %s', 16, 1, @error)
    END CATCH
END;
GO

/*------------------------------------------------------------------------------------------------------------*/
--ELIMINAR DATOS
CREATE OR ALTER PROCEDURE Administracion.EliminarFormaPago
    @id INT = NULL,
    @descripcion VARCHAR(30) = NULL
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
    IF NOT EXISTS (SELECT id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('La FORMA DE PAGO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.FormasDePago 
        WHERE @id = id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar FORMA DE PAGO: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarDivisas
    @id INT = NULL,
    @descripcion VARCHAR(30) = NULL
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
    IF NOT EXISTS (SELECT id FROM Administracion.Divisas WHERE @id = id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('La Divisas no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Divisas 
        WHERE @id = id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar Divisas: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTipoFecha
    @id INT = NULL,
    @descripcion VARCHAR(30) = NULL
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
    IF NOT EXISTS (SELECT id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('El TIPO DE FECHA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TiposDeFecha
        WHERE @id = id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TIPO DE FECHA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTipoParque
    @id INT = NULL,
    @descripcion VARCHAR(30) = NULL
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
    IF NOT EXISTS (SELECT id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('El TIPO DE PARQUE no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TiposDeParque
        WHERE @id = id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TIPO DE PARQUE: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarProvincia
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
    IF NOT EXISTS (SELECT id FROM Administracion.Provincias WHERE @id = id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('La PROVINCIA no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Provincias
        WHERE @id = id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar PROVINCIA: %s', 16, 1, @error)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarLocalidad
    @id INT = NULL,
    @provincia_id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @provincia_id IS NULL AND @descripcion IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Localidades WHERE @id = id OR @provincia_id = provincia_id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('La LOCALIDAD no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Localidades
        WHERE @id = id OR @provincia_id = provincia_id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar LOCALIDAD: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarParque
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@localidad_id INT = NULL,
    @direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie_km_2 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @tipo_parque_id IS NULL AND @localidad_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Parques 
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @localidad_id = localidad_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2)
    BEGIN
        RAISERROR('El PARQUE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Parques
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @localidad_id = localidad_id OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar PARQUE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTarifaArticulo
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
    IF NOT EXISTS (SELECT id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio)
    BEGIN
        RAISERROR('La TARIFA DE ARTICULO no existe o es inválida.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.TarifasDeArticulo
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar TARIFA DE ARTÍCULO: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarAjuste
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_visitante_id INT = NULL,
    @tipo_fecha_id INT = NULL,
    @porcentaje TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --CAMPOS NULOS
    IF @id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_visitante_id IS NULL AND @tipo_fecha_id IS NULL AND @porcentaje IS NULL
    BEGIN
	    RAISERROR('NO ingrese campos NULOS.', 16, 1)
        RETURN
    END

    --PARÁMETROS INEXISTENTES
    IF NOT EXISTS (SELECT id FROM Administracion.Ajustes 
        WHERE id = @id AND parque_id = @parque_id AND tipo_articulo = @tipo_articulo AND tipo_visitante_id = @tipo_visitante_id AND tipo_fecha_id = @tipo_fecha_id AND porcentaje = @porcentaje)
    BEGIN
        RAISERROR('El AJUSTE no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.Ajustes
        WHERE id = @id AND parque_id = @parque_id AND tipo_articulo = @tipo_articulo AND tipo_visitante_id = @tipo_visitante_id AND tipo_fecha_id = @tipo_fecha_id AND porcentaje = @porcentaje
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar AJUSTE: %s', 16, 1, @error)
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarPuntoVenta
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
    IF NOT EXISTS (SELECT id FROM Administracion.PuntosDeVenta WHERE @id = id OR @parque_id = parque_id OR @descripcion = descripcion)
    BEGIN
        RAISERROR('El PUNTO DE VENTA no existe o es inválido.', 16, 1)
        RETURN
    END

    --(TRY-CATCH) 
    BEGIN TRY
        DELETE FROM Administracion.PuntosDeVenta
        WHERE @id = id OR @parque_id = parque_id OR @descripcion = descripcion
    END TRY
    BEGIN CATCH
        DECLARE @error VARCHAR(500) = ERROR_MESSAGE()
	RAISERROR('Error al eliminar PUNTO DE VENTA: %s', 16, 1, @error)
    END CATCH
END;
GO