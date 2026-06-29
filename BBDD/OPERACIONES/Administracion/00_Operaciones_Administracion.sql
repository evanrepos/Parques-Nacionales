/* #####################################
   # Universidad Nacional de la Matanza#
   #      Bases de Datos Aplicada      #
   #####################################

   Participan: 
     - Iván Gonzalez Fernandez

   #####################################
   #       OperacionesAdministracion.sql      #
   #####################################
   El objetivo de este script es definir todos los 
   store procedures relacionados con las
   operaciones administrativas...
*/

USE ParquesNacionales
GO

--INGRESAR DATOS
--Ingresar registros paramétricas.
CREATE OR ALTER PROCEDURE Administracion.IngresarFormasDePago 
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripción es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción ingresada es nula.';

    --2. Si ya existe una forma de pago con la descripcion ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.FormasDePago WHERE descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La forma de pago ingresada ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se ingresa la forma de pago.
    ELSE
    BEGIN
        INSERT INTO Administracion.FormasDePago (descripcion) VALUES (@descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarDivisas 
    @codigo_iso VARCHAR(6) = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripcion ingresada es nula o el código iso es nulo.
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL OR @codigo_iso IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción o el código iso no pueden ser nulos.';

    --2. Si ...
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.Divisas WHERE codigo_iso = @codigo_iso OR descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La divisa ingresada ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se ingresa la divisa.
    ELSE
    BEGIN
        INSERT INTO Administracion.Divisas (codigo_iso, descripcion) VALUES (@codigo_iso, @descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeFecha
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripción es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción ingresada es nula.';

    --2. Si ya existe un tipo de fecha con la descripcion ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.TiposDeFecha WHERE descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tipo de fecha ingresado ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se ingresa el tipo de fecha.
    ELSE
    BEGIN
        INSERT INTO Administracion.TiposDeFecha (descripcion) VALUES (@descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeVisitante 
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripción es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción ingresada es nula.';

    --2. Si ya existe un tipo de visitante con la descripcion ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.TiposDeVisitante WHERE descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tipo de fecha ingresado ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se ingresa el tipo de visitante.
    ELSE
    BEGIN
        INSERT INTO Administracion.TiposDeVisitante (descripcion) VALUES (@descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarTiposDeParque
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripción es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción ingresada es nula.';

    --2. Si ya existe un tipo de parque con la descripcion ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.TiposDeParque WHERE descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tipo de parque ingresado ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se inserta el tipo de parque.
    ELSE
    BEGIN
        INSERT INTO Administracion.TiposDeParque (descripcion) VALUES (@descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarProvincias
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la descripción es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'La descripción ingresada es nula.';

    --2. Si ya existe una provincia con la descripcion ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.Provincias WHERE descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La provincia ingresada ya existe.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se inserta la provincia.
    ELSE
    BEGIN
        INSERT INTO Administracion.Provincias (descripcion) VALUES (@descripcion)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarParques
    @tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
	@direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie INT = NULL,
    @año_creacion SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el tipo de parque es nulo o inexistente
    DECLARE @condicion1 BIT = CASE 
        WHEN @tipo_parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.TiposDeParque WHERE @tipo_parque_id = id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'El tipo de parque no puede ser nulo, o inexistente.';

    --2. Si la provincia es nula o inexistente
    DECLARE @condicion2 BIT = CASE 
        WHEN @provincia_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Provincias WHERE @provincia_id = id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'La provincia no puede ser nula, o inexistente.';

    --3. Si el nombre ingresado es nulo
    DECLARE @condicion3 BIT = CASE 
        WHEN @nombre IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'El nombre ingresado no puede ser nulo.';
        
    --4. Si la superficie ingresada es nula o, menor o igual a 0
    DECLARE @condicion4 BIT = CASE 
        WHEN @superficie IS NULL OR @superficie <= 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'La superficie ingresada no puede ser menor o igual a 0.';
        
    --5. Si el año de creación es nulo, anterior al 1500, o posterior al actual
    DECLARE @condicion5 BIT = CASE 
        WHEN @año_creacion IS NULL OR @año_creacion < 1500 OR @año_creacion > YEAR(GETDATE())
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'El año de creación debe estar entre el 1500 y el año actual.';
        
    --6. Si el nombre del parque y su provincia ya existen
    DECLARE @condicion6 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.Parques WHERE nombre = @nombre AND provincia_id = @provincia_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'Ya existe un parque con esas características.';

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

    --Si todo salió bien, se inserta el parque.
    ELSE
    BEGIN
        INSERT INTO Administracion.Parques (tipo_parque_id, provincia_id, direccion, nombre, superficie_km_2, año_creacion) VALUES
            (@tipo_parque_id, @provincia_id, @direccion, @nombre, @superficie, @año_creacion)
    END
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

    --Condiciones de falla
    --1. Si el parque es nulo o inexistente
    DECLARE @condicion1 BIT = CASE 
        WHEN @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'El parque ingresado no puede ser nulo, o inexistente.';

    --2. Si el tipo de articulo es nulo o no corresponde a 'E': Entrada, 'A': Actividad, 'T': Tour
    DECLARE @condicion2 BIT = CASE 
        WHEN @tipo_articulo IS NULL OR @tipo_articulo NOT IN ('E', 'A', 'T')
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tipo de articulo debe ser ''E'': Entrada, ''A'': Actividad, ''T'': Tour';

    --3. Si la descripción ingresada es nula
    DECLARE @condicion3 BIT = CASE 
        WHEN @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'La descripción no puede ser nula.';
        
    --4. Si el artículo es de tipo tour, y su duración o cupo son nulos o, menores o iguales a 0
    DECLARE @condicion4 BIT = CASE 
        WHEN @tipo_articulo = 'T' AND (@duracion IS NULL OR @cupo IS NULL OR @duracion <= 0 OR @cupo <= 0)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'El tour debe tener una duración o cantidad de cupos mayor a 0.';
        
    --5. Si el precio es nulo o menor a 0 (admitiendo artículos gratuítos)
    DECLARE @condicion5 BIT = CASE 
        WHEN @precio IS NULL OR @precio < 0
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'El precio no puede ser nulo, o negativo.';

    --6. Si existe un artículo con la descripción, el parque, o el tipo de artículo ingresados
    DECLARE @condicion6 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.TarifasDeArticulo WHERE descripcion = @descripcion AND parque_id = @parque_id AND tipo_articulo = @tipo_articulo)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje6 VARCHAR(100) = 'El artículo ya existe.';

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

    --Si todo salió bien, se inserta el artículo.
    ELSE
    BEGIN
        INSERT INTO Administracion.TarifasDeArticulo (parque_id, tipo_articulo, descripcion, duracion, cupo, precio) VALUES 
            (@parque_id, @tipo_articulo, @descripcion, @duracion, @cupo, @precio)
    END
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

    --Condiciones de falla
    --1. Si el parque es nulo o inexistente
    DECLARE @condicion1 BIT = CASE 
        WHEN @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'El parque ingresado no puede ser nulo, o inexistente.';

    --2. Si el tipo de articulo es nulo o no corresponde a 'E': Entrada, 'A': Actividad, 'T': Tour
    DECLARE @condicion2 BIT = CASE 
        WHEN @tipo_articulo IS NULL OR @tipo_articulo NOT IN ('E', 'A', 'T')
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El tipo de articulo debe ser ''E'': Entrada, ''A'': Actividad, ''T'': Tour';

    --3. Si el tipo de ajuste es nulo o no corresponde a 'F': Tipo de Fecha, 'V': Tipo de Visitante, 'TE': Tipo de entrada
    DECLARE @condicion3 BIT = CASE 
        WHEN @tipo_ajuste IS NULL OR @tipo_ajuste NOT IN ('F', 'V', 'TE')
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'El tipo de ajuste debe ser ''F'': Tipo de Fecha, ''V'': Tipo de Visitante, ''TE'': Tipo de entrada';
        
    --4. Si la descripción es nula, o el porcentaje es nulo o menor a -100%
    DECLARE @condicion4 BIT = CASE 
        WHEN @descripcion IS NULL OR @porcentaje IS NULL OR @porcentaje < -100
        THEN 1 ELSE 0 END;

    DECLARE @mensaje4 VARCHAR(100) = 'La descripción y el porcentaje no pueden ser nulos, ni el porcentaje puede ser menor al -100%.';
        
    --5. Si ya existe un ajuste con el parque y la descripción ingresadas
    DECLARE @condicion5 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.Ajustes WHERE parque_id = @parque_id AND descripcion = @descripcion)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje5 VARCHAR(100) = 'Ya existe un ajuste con las características ingresadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL),
        IIF(@condicion3 = 1, @mensaje3, NULL),
        IIF(@condicion4 = 1, @mensaje4, NULL),
        IIF(@condicion5 = 1, @mensaje5, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien,  .
    ELSE
    BEGIN
        INSERT INTO Administracion.Ajustes (parque_id, tipo_articulo, tipo_ajuste, descripcion, porcentaje) VALUES 
            (@parque_id, @tipo_articulo, @tipo_ajuste, @descripcion, @porcentaje) 
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.IngresarPuntosDeVenta
    @parque_id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el parque ingresado es nulo o inexistente
    DECLARE @condicion1 BIT = CASE 
        WHEN @parque_id IS NULL OR NOT EXISTS (SELECT id FROM Administracion.Parques WHERE @parque_id = id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'El parque ingresado no puede ser nulo, o inexistente.';

    --2. Si ya existe un punto de venta con el parque y la descripción ingresada
    DECLARE @condicion2 BIT = CASE 
        WHEN EXISTS (SELECT 1 FROM Administracion.PuntosDeVenta WHERE parque_id = @parque_id AND ISNULL(descripcion, '') = ISNULL(@descripcion, ''))
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'Ya existe un punto de venta con esas características.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, ... .
    ELSE
    BEGIN
        DECLARE @id SMALLINT;
        SELECT @id = ISNULL(MAX(id), 0) + 1
            FROM Administracion.PuntosDeVenta
            WHERE parque_id = @parque_id;
        INSERT INTO Administracion.PuntosDeVenta (id, parque_id, descripcion) VALUES 
            (@id, @parque_id, @descripcion) 
    END
END;
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--ACTUALIZAR DATOS
CREATE OR ALTER PROCEDURE Administracion.ActualizarFormasDePago
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una forma de pago con esa descripción
    DECLARE @idRealFDP INT = (SELECT id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealFDP IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una forma de pago con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la forma de pago.
    ELSE
    BEGIN
        UPDATE Administracion.FormasDePago 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealFDP
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarDivisas
    @id INT = NULL,
    @codigo_iso VARCHAR(6) = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @codigo_iso IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una forma de pago con esa descripción
    DECLARE @idRealDiv INT = (SELECT id FROM Administracion.Divisas WHERE @id = id OR @codigo_iso = codigo_iso OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealDiv IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una divisa con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la divisa.
    ELSE
    BEGIN
        UPDATE Administracion.Divisas 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealDiv
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarCotizacionDivisa
    @divisa_id VARCHAR(6) = NULL
AS
BEGIN
    SET NOCOUNT ON

    --Condiciones de falla
    --1. Si la divisa ingresada es la argentina
    DECLARE @codigo_iso NVARCHAR(6) = (SELECT codigo_iso FROM Administracion.Divisas WHERE id = @divisa_id);
    DECLARE @condicion1 BIT = CASE 
        WHEN @codigo_iso = 'ARS'
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'No puede calcularse el valor de la moneda argentina.';

    --2. Si la divisa ingresada es nula o inexistente
    DECLARE @condicion2 BIT = CASE 
        WHEN @codigo_iso IS NULL OR @divisa_id IS NULL OR NOT EXISTS (SELECT 1 FROM Administracion.Divisas WHERE id = @divisa_id)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'El código ISO y la descripción no pueden ser nulos, o inexistentes.';
        
    --3. Si la fecha de actualización es menor a 24 horas (Política de la API)
    DECLARE @f_actualizacion SMALLDATETIME = (SELECT f_actualizacion FROM Administracion.Divisas WHERE id = @divisa_id);
    DECLARE @condicion3 BIT = CASE 
        WHEN DATEDIFF(HOUR, @f_actualizacion, GETDATE()) < 24
        THEN 1 ELSE 0 END;

    DECLARE @mensaje3 VARCHAR(100) = 'La divisa ya fue consultada anteriormente, espere 24 horas después de la última actualización.';
        
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

    --Si todo salió bien, se actualiza la cotizacion de la divisa.
    ELSE
    BEGIN
        DECLARE @link NVARCHAR(200) = 
            (SELECT LTRIM(CONCAT('https://api.currencyfreaks.com/latest?apikey=63af7539cf5947cba710cd39b1be8797&symbols=ARS,', @codigo_iso), ' '));
        DECLARE @Object INT;
        DECLARE @response VARCHAR(8000);

        EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
        EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @link, 'false';
        EXEC sp_OAMethod @Object, 'send';
        EXEC sp_OAGetProperty @Object, 'responseText', @response OUT;

        CREATE TABLE #cotizacion (
            ars NVARCHAR(30),
            iso NVARCHAR(30)
        )

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
            INSERT INTO #cotizacion 
                SELECT JSON_VALUE(@response, ''$.rates.ARS''), JSON_VALUE(@response, ''$.rates.' + @codigo_iso + ''')';
        EXEC sp_executesql @sql, N'@response NVARCHAR(MAX)', @response = @response;
        EXEC sp_OADestroy @Object;

        DECLARE @cotizacion DECIMAL(18, 2);
        SELECT @cotizacion = CAST(ars AS DECIMAL(18, 2)) / CAST(iso AS DECIMAL(22, 6)), @f_actualizacion = GETDATE() FROM #cotizacion

        UPDATE Administracion.Divisas SET cotizacion = @cotizacion, f_actualizacion = @f_actualizacion WHERE id = @divisa_id;
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeFecha
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe un tipo de fecha con esa descripción
    DECLARE @idRealTDF INT = (SELECT id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDF IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de fecha con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza el tipo de fecha.
    ELSE
    BEGIN
        UPDATE Administracion.TiposDeFecha 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealTDF
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeVisitante
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una forma de pago con esa descripción
    DECLARE @idRealTDV INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE @id = id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDV IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de visitante con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza el tipo de visitante.
    ELSE
    BEGIN
        UPDATE Administracion.TiposDeVisitante 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealTDV
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTiposDeParque
    @id INT = NULL,
    @descripcion_vieja VARCHAR(30) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe un tipo de parque con esa descripción
    DECLARE @idRealTDP INT = (SELECT id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDP IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de parque con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza el tipo de parque.
    ELSE
    BEGIN
        UPDATE Administracion.TiposDeParque 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealTDP
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarProvincias
    @id INT = NULL,
    @descripcion_vieja VARCHAR(100) = NULL,
    @descripcion_nueva VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una provincia con esa descripción
    DECLARE @idRealProv INT = (SELECT id FROM Administracion.Provincias WHERE @id = id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealProv IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una provincia con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la provincia.
    ELSE
    BEGIN
        UPDATE Administracion.Provincias 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealProv
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarParques
    --Parámetros de búsqueda
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
    @direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie_km_2 INT = NULL,
    @año_creacion SMALLINT = NULL,
    --Parámetros de cambio
    @direccion_nueva VARCHAR(150) = NULL,
	@nombre_nuevo VARCHAR(100) = NULL,
	@superficie_nueva INT = NULL,
    @año_creacion_nuevo SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda, o los parámetros de cambio, son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @tipo_parque_id IS NULL AND @provincia_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL AND @año_creacion IS NULL) 
            OR (@direccion_nueva IS NULL AND @nombre_nuevo IS NULL AND @superficie_nueva IS NULL AND @año_creacion_nuevo IS NULL)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una provincia con esa descripción
    DECLARE @idRealParque INT = (SELECT id FROM Administracion.Parques 
            WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @provincia_id = provincia_id 
                           OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2 
                           OR @año_creacion = año_creacion)
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealParque IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un parque con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la provincia.
    ELSE
    BEGIN
        UPDATE Administracion.Parques 
        SET       direccion = ISNULL(@direccion_nueva, direccion),
                     nombre = ISNULL(@nombre_nuevo, nombre),
            superficie_km_2 = ISNULL(@superficie_nueva, superficie_km_2),
               año_creacion = ISNULL(@año_creacion_nuevo, año_creacion)
        WHERE id = @idRealParque
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarTarifasDeArticulo
    --Parámetros de búsqueda
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @descripcion VARCHAR(50) = NULL,
    @duracion INT = NULL,
    @cupo INT = NULL,
    @precio DECIMAL(10, 2) = NULL,
    --Parámetros de cambio
    @tipo_articulo_nuevo CHAR(1) = NULL,
    @descripcion_nueva VARCHAR(50) = NULL,
    @duracion_nueva INT = NULL,
    @cupo_nuevo INT = NULL,
    @precio_nuevo DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda, o los parámetros de cambio, son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @descripcion IS NULL AND @duracion IS NULL AND @cupo IS NULL AND @precio IS NULL) 
            OR (@tipo_articulo_nuevo IS NULL AND @descripcion_nueva IS NULL  AND @duracion_nueva IS NULL AND @cupo_nuevo IS NULL AND @precio_nuevo IS NULL)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una provincia con esa descripción
    DECLARE @idRealTarifa INT
    SELECT @idRealTarifa = id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio

    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTarifa IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una tarifa con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la provincia.
    ELSE
    BEGIN
        UPDATE Administracion.TarifasDeArticulo 
        SET tipo_articulo = ISNULL(@tipo_articulo_nuevo, tipo_articulo),
           descripcion    = ISNULL(@descripcion_nueva, descripcion),
           duracion       = ISNULL(@duracion_nueva, duracion),
           cupo           = ISNULL(@cupo_nuevo, cupo),
           precio         = ISNULL(@precio_nuevo, precio)
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarAjustes
    --Parámetros de búsqueda
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_ajuste CHAR(1) = NULL,
    @descripcion VARCHAR(30) = NULL,
    @porcentaje INT = NULL,
    --Parámetros de cambio
    @tipo_articulo_nuevo CHAR(1) = NULL,
    @tipo_ajuste_nuevo CHAR(1) = NULL,
    @descripcion_nueva VARCHAR(30) = NULL,
    @porcentaje_nuevo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda, o los parámetros de cambio, son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_ajuste IS NULL AND @descripcion IS NULL AND @porcentaje IS NULL) 
            OR (@tipo_articulo_nuevo IS NULL AND @tipo_ajuste_nuevo IS NULL AND @descripcion_nueva IS NULL AND @porcentaje_nuevo IS NULL)
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe una provincia con esa descripción
    DECLARE @idRealAjuste INT
    SELECT @idRealAjuste = id FROM Administracion.Ajustes 
        WHERE id = @id OR parque_id = @parque_id OR tipo_articulo = @tipo_articulo OR tipo_ajuste = @tipo_ajuste OR descripcion = @descripcion OR porcentaje = @porcentaje

    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealAjuste IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una tarifa con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la provincia.
    ELSE
    BEGIN
        UPDATE Administracion.Ajustes 
        SET tipo_articulo = ISNULL(@tipo_articulo_nuevo, tipo_articulo), 
              tipo_ajuste = ISNULL(@tipo_ajuste_nuevo, tipo_ajuste), 
              descripcion = ISNULL(@descripcion_nueva, descripcion), 
              porcentaje  = ISNULL(@porcentaje_nuevo, porcentaje) 
        WHERE id = @idRealAjuste
    END
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
    
    --Condiciones de falla
    --1. Si la forma de pago y la descripción son nulas, o la descripción nueva a ingresar es nula
    DECLARE @condicion1 BIT = CASE 
        WHEN (@id IS NULL AND @parque_id IS NULL AND @descripcion_vieja IS NULL) OR @descripcion_nueva IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si se ingresa solo la descripción, pero no existe un punto de venta con esa descripción
    DECLARE @idRealPDV INT = (SELECT id FROM Administracion.PuntosDeVenta WHERE @parque_id = parque_id OR @descripcion_vieja = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealPDV IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una provincia con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se actualiza la provincia.
    ELSE
    BEGIN
        UPDATE Administracion.PuntosDeVenta 
        SET descripcion = ISNULL(@descripcion_nueva, descripcion) 
        WHERE id = @idRealPDV
    END
END;
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--ELIMINAR DATOS
CREATE OR ALTER PROCEDURE Administracion.EliminarFormasDePago
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe una forma de pago con las características indicadas
    DECLARE @idRealFDP INT = (SELECT id FROM Administracion.FormasDePago WHERE @id = id OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealFDP IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una forma de pago con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina la forma de pago.
    ELSE
    BEGIN
        DELETE FROM Administracion.FormasDePago 
        WHERE id = @idRealFDP
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarDivisas
    @id INT = NULL,
    @codigo_iso VARCHAR(6) = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id, el código iso y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @codigo_iso IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe una divisa con las características indicadas
    DECLARE @idRealDiv INT = (SELECT id FROM Administracion.Divisas WHERE @id = id OR @codigo_iso = codigo_iso OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealDiv IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una divisa con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina la divisa.
    ELSE
    BEGIN
        DELETE FROM Administracion.Divisas 
        WHERE id = @idRealDiv
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeFecha
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe un tipo de fecha con las características indicadas
    DECLARE @idRealTDF INT = (SELECT id FROM Administracion.TiposDeFecha WHERE @id = id OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDF IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de fecha con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina el tipo de fecha.
    ELSE
    BEGIN
        DELETE FROM Administracion.TiposDeFecha
        WHERE id = @idRealTDF
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeVisitante
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe un tipo de visitante con las características indicadas
    DECLARE @idRealTDV INT = (SELECT id FROM Administracion.TiposDeVisitante WHERE @id = id OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDV IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de visitante con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina el tipo de visitante.
    ELSE
    BEGIN
        DELETE FROM Administracion.TiposDeVisitante
        WHERE id = @idRealTDV
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarTiposDeParque
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe un tipo de parque con las características indicadas
    DECLARE @idRealTDP INT = (SELECT id FROM Administracion.TiposDeParque WHERE @id = id OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTDP IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un tipo de parque con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina el tipo de parque.
    ELSE
    BEGIN
        DELETE FROM Administracion.TiposDeParque
        WHERE id = @idRealTDP
    END
END
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarProvincias
    @id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si el id y la descripción son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe una provincia con las características indicadas
    DECLARE @idRealProv INT = (SELECT id FROM Administracion.Provincias WHERE @id = id OR @descripcion = descripcion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealProv IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una provincia con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina la provincia.
    ELSE
    BEGIN
        DELETE FROM Administracion.Provincias
        WHERE id = @idRealProv
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarParques
    @id INT = NULL,
	@tipo_parque_id INT = NULL,
	@provincia_id INT = NULL,
    @direccion VARCHAR(150) = NULL,
	@nombre VARCHAR(100) = NULL,
	@superficie_km_2 INT = NULL,
    @año_creacion SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @tipo_parque_id IS NULL AND @provincia_id IS NULL AND @direccion IS NULL AND @nombre IS NULL AND @superficie_km_2 IS NULL AND @año_creacion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe un parque con las características indicadas
    DECLARE @idRealParque INT = (SELECT id FROM Administracion.Parques 
        WHERE @id = id OR @tipo_parque_id = tipo_parque_id OR @provincia_id = provincia_id 
                       OR @direccion = direccion OR @nombre = nombre OR @superficie_km_2 = superficie_km_2 
                       OR @año_creacion = año_creacion);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealParque IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un parque con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina el parque.
    ELSE
    BEGIN
        DELETE FROM Administracion.Parques
        WHERE id = @idRealParque
    END
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

    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @descripcion IS NULL AND @duracion IS NULL AND @cupo IS NULL AND @precio IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe una tarifa de artículo con las características indicadas
    DECLARE @idRealTarifa INT = (SELECT id FROM Administracion.TarifasDeArticulo 
        WHERE @id = id OR @parque_id = parque_id OR @tipo_articulo = tipo_articulo OR @descripcion = descripcion OR @duracion = duracion OR @cupo = cupo OR @precio = precio);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealTarifa IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe una tarifa de artículo con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina la tarifa de artículo.
    ELSE
    BEGIN
        DELETE FROM Administracion.TarifasDeArticulo
        WHERE id = @idRealTarifa
    END
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarAjustes
    @id INT = NULL,
    @parque_id INT = NULL,
    @tipo_articulo CHAR(1) = NULL,
    @tipo_ajuste CHAR(1) = NULL,
    @descripcion VARCHAR(30) = NULL,
    @porcentaje SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si todos los parámetros de búsqueda son nulos
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @parque_id IS NULL AND @tipo_articulo IS NULL AND @tipo_ajuste IS NULL AND @descripcion IS NULL AND @porcentaje IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda no pueden ser nulos.';

    --2. Si no existe un ajuste con las características indicadas
    DECLARE @idRealAjuste INT = (SELECT id FROM Administracion.Ajustes 
        WHERE id = @id OR parque_id = @parque_id OR tipo_articulo = @tipo_articulo OR tipo_ajuste = @tipo_ajuste OR descripcion = @descripcion OR porcentaje = @porcentaje);
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealAjuste IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un ajuste con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, se elimina el ajuste.
    ELSE
    BEGIN
        DELETE FROM Administracion.Ajustes
        WHERE id = @idRealAjuste
    END
END;
GO


CREATE OR ALTER PROCEDURE Administracion.EliminarPuntosDeVenta
    @id INT = NULL,
    @parque_id INT = NULL,
    @descripcion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Condiciones de falla
    --1. Si ...
    DECLARE @condicion1 BIT = CASE 
        WHEN @id IS NULL AND @parque_id IS NULL AND @descripcion IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje1 VARCHAR(100) = 'Los parámetros de búsqueda y de cambio no pueden ser nulos.';

    --2. Si 
    DECLARE @idRealPDV INT
    SELECT @idRealPDV = id FROM Administracion.PuntosDeVenta WHERE @id = id OR @parque_id = parque_id OR @descripcion = descripcion
    DECLARE @condicion2 BIT = CASE 
        WHEN @idRealPDV IS NULL
        THEN 1 ELSE 0 END;

    DECLARE @mensaje2 VARCHAR(100) = 'No existe un punto de venta con las características indicadas.';

    --Generación del mensaje de error.
    DECLARE @mensajeDeError VARCHAR(MAX) = CONCAT_WS(CHAR(10),
        IIF(@condicion1 = 1, @mensaje1, NULL),
        IIF(@condicion2 = 1, @mensaje2, NULL)
        );

    --Si falló, muestra mensaje de error, no hace cambios.
    IF (LEN(@mensajeDeError) > 0)
    BEGIN
        RAISERROR(@mensajeDeError, 1, 1);
    END;

    --Si todo salió bien, ... .
    ELSE
    BEGIN
        DELETE FROM Administracion.PuntosDeVenta
        WHERE id = @idRealPDV
    END
END;
GO