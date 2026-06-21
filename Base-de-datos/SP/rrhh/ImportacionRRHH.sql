--GENERADOR

SET NOCOUNT ON
DECLARE @json NVARCHAR(MAX);

SELECT @json = BulkColumn
FROM OPENROWSET(
    BULK 'E:\ParquesNacionales\Otros\data.json',
    SINGLE_CLOB
) AS j

SELECT value INTO #Apellidos
FROM OPENJSON(@json, '$.lastname')

SELECT value INTO #NombresMasculinos
FROM OPENJSON(@json, '$.malename')

SELECT value INTO #NombresFemeninos
FROM OPENJSON(@json, '$.femalename')
GO

-- =============================================
-- Guías Turísticos (GENERABLE)
-- =============================================
DECLARE @i INT = 1;
DECLARE @cant_guias INT = 100 + ABS(CHECKSUM(NEWID())) % (400 - 100);
WHILE @i <= @cant_guias
    BEGIN
    DECLARE @decisor_sexo BIT = ABS(CHECKSUM(NEWID())) % 2;
    DECLARE @factor FLOAT = RAND(CHECKSUM(NEWID()));
    DECLARE @cuil BIGINT = @factor * 309999998;
    DECLARE @nombre VARCHAR(100);
    DECLARE @apellido VARCHAR(100);
    DECLARE @f_nacimiento DATE = DATEADD(D, @factor * 14600, '1965-01-01');

    --Generador CUIL
    --Decisor de género.
    IF (@decisor_sexo = 0)
    BEGIN
        --CUIL Masculino
        SELECT @cuil = @cuil + 20160000001 

        --Nombre Masculino
        SELECT TOP 1 @nombre = value FROM #NombresMasculinos
        ORDER BY NEWID()

    END
    ELSE IF (@decisor_sexo = 1)
    BEGIN
        --CUIL Femenino
        SELECT @cuil = @cuil + 27160000001

        --Nombre Femenino
        SELECT TOP 1 @nombre = value FROM #NombresFemeninos
        ORDER BY NEWID()
    END
    --Apellido
    SELECT TOP 1 @apellido = value FROM #Apellidos
    ORDER BY NEWID()

    --SELECT @cuil, @nombre, @apellido, @f_nacimiento

    EXEC RRHH.CrearGuia @cuil, @nombre, @apellido, @f_nacimiento
    SET @i = @i + 1;
END
GO

SELECT TOP 50 * FROM RRHH.Guias
SELECT 'Cantidad de guías: ', COUNT(1) FROM RRHH.Guias

-- =============================================
-- Guardaparques (GENERABLE)
-- =============================================

DECLARE @i INT = 1;
DECLARE @cant_gpques INT = 200 + ABS(CHECKSUM(NEWID())) % (500 - 200);
WHILE @i <= @cant_gpques
    BEGIN
    DECLARE @decisor_sexo BIT = ABS(CHECKSUM(NEWID())) % 2;
    DECLARE @factor FLOAT = RAND(CHECKSUM(NEWID()));
    DECLARE @cuil BIGINT = @factor * 309999998;
    DECLARE @nombre VARCHAR(100);
    DECLARE @apellido VARCHAR(100);
    DECLARE @f_nacimiento DATE = DATEADD(D, @factor * 14600, '1965-01-01');

    --Generador CUIL
    --Decisor de género.
    IF (@decisor_sexo = 0)
    BEGIN
        --CUIL Masculino
        SELECT @cuil = @cuil + 20160000001 

        --Nombre Masculino
        SELECT TOP 1 @nombre = value FROM #NombresMasculinos
        ORDER BY NEWID()

    END
    ELSE IF (@decisor_sexo = 1)
    BEGIN
        --CUIL Femenino
        SELECT @cuil = @cuil + 27160000001

        --Nombre Femenino
        SELECT TOP 1 @nombre = value FROM #NombresFemeninos
        ORDER BY NEWID()
    END
    --Apellido
    SELECT TOP 1 @apellido = value FROM #Apellidos
    ORDER BY NEWID()

    EXEC RRHH.CrearGuardaparque @cuil, @nombre, @apellido, @f_nacimiento
    SET @i = @i + 1;
END
GO

SELECT TOP 50 * FROM RRHH.Guardaparques
SELECT 'Cantidad de guardaparques: ', COUNT(1) FROM RRHH.Guardaparques

-------------------------------------------------
DROP TABLE #Apellidos
DROP TABLE #NombresFemeninos
DROP TABLE #NombresMasculinos

--DELETE FROM RRHH.Guias
--DBCC CHECKIDENT('RRHH.Guias', 'RESEED', 0)

--DELETE FROM RRHH.Guardaparques
--DBCC CHECKIDENT('RRHH.Guardaparques', 'RESEED', 0)

-- =============================================
-- Asignación Guía (GENERABLE)
-- =============================================

--¿Cuántos parques hay?
DECLARE @cant_parques INT = (SELECT COUNT(1) FROM Administracion.Parques);

--¿Cuántos guías hay?
DECLARE @cant_guias INT = (SELECT COUNT(1) FROM RRHH.Guias);

--Se distribuyen los guardaparques
--La parte entera de 'Repartición' es lo que se va a distribuir entre cada parque.

DECLARE @guia INT = 1;
DECLARE @prorrateo INT = (SELECT @cant_guias / @cant_parques);
DECLARE @parque INT = (@guia / @prorrateo) + 1;
DECLARE @f_ingreso DATETIME = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());
WHILE @guia < (@prorrateo * @cant_parques)
BEGIN
    SET @parque = (@guia / @prorrateo) + 1;
    SET @f_ingreso = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());

    EXEC RRHH.AsignarGuia @id_guia = @guia, @id_parque = @parque, @fecha_ingreso = @f_ingreso;
    SET @guia = @guia + 1
END

--La parte sobrante se distribuirá entre todos los parques aleatoriamente.
SET @guia = @cant_parques * @prorrateo; --CHEQUEAR
DECLARE @resto INT = (SELECT @cant_guias % @cant_parques);
WHILE @guia <= (@cant_parques * @prorrateo) + @resto
BEGIN
    SET @parque = 1 + ABS(CHECKSUM(NEWID())) % @cant_parques;
    SET @f_ingreso = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());

    EXEC RRHH.AsignarGuia @id_guia = @guia, @id_parque = @parque, @fecha_ingreso = @f_ingreso;
    SET @guia = @guia + 1
END
GO

SELECT TOP 50 * FROM RRHH.AsignacionesDeGuias
ORDER BY NEWID()

--PASO EXTRA: Destituir aleatoriamente algunos guías.

DECLARE @factor_destitucion DECIMAL(3, 2) = 0.15;
DECLARE @cant_guias INT = (SELECT COUNT(1) FROM RRHH.Guias WHERE esta_activo = 1);

DECLARE @motivos TABLE (
    id INT IDENTITY(1, 1),
    descripcion VARCHAR(50)
)
INSERT INTO @motivos VALUES
('Renuncia voluntaria'),
('Jubilacion'),
('Finalizacion de contrato'),
('Reestructuracion administrativa'),
('Incumplimiento de funciones'),
('Faltas reiteradas'),
('Sancion disciplinaria'),
('Inhabilitacion profesional'),
('Problemas de salud'),
('Fallecimiento'),
('Traslado a otro organismo'),
('Rescision de concesion');

DECLARE @guias_activos TABLE (
    id INT IDENTITY(1, 1),
    guia_id INT
)
INSERT INTO @guias_activos
    SELECT id FROM RRHH.Guías WHERE esta_activo = 1

DECLARE @i INT = 1;
WHILE @i < CAST(@factor_destitucion * @cant_guias AS INT)
BEGIN
    DECLARE @guia_id INT = (SELECT TOP 1 guia_id FROM @guias_activos ORDER BY NEWID());
    DECLARE @f_ingreso DATETIME = (SELECT f_ingreso FROM RRHH.AsignacionesDeGuias WHERE guia_id = @guia_id);
    DECLARE @cant_dias INT = (SELECT DATEDIFF(D,  @f_ingreso, GETDATE()) );
    DECLARE @f_egreso DATETIME = DATEADD(D, 0.8 * RAND(CHECKSUM(NEWID())) * @cant_dias,@f_ingreso);
    DECLARE @motivo VARCHAR(200) = (SELECT TOP 1 descripcion FROM @motivos ORDER BY NEWID());

    EXEC RRHH.FinalizarAsignacionGuia @guia_id, @f_egreso, @motivo
    DELETE FROM @guias_activos WHERE guia_id = @guia_id
    SET @i = @i + 1
END

SELECT TOP 50 * FROM RRHH.AsignacionesDeGuias
ORDER BY NEWID()

-- =============================================
-- Asignación Guardaparques (GENERABLE)
-- =============================================

--¿Cuántos parques hay?
DECLARE @cant_parques INT = (SELECT COUNT(1) FROM Administracion.Parques);

--¿Cuántos guardaparques hay?
DECLARE @cant_gpques INT = (SELECT COUNT(1) FROM RRHH.Guardaparques);

--Se distribuyen los guardaparques
--La parte entera de 'Repartición' es lo que se va a distribuir entre cada parque.

DECLARE @guardaparques INT = 1;
DECLARE @prorrateo INT = (SELECT @cant_gpques / @cant_parques);
DECLARE @parque INT = (@guardaparques / @prorrateo) + 1;
DECLARE @f_ingreso DATETIME = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());
WHILE @guardaparques < (@prorrateo * @cant_parques)
BEGIN
    SET @parque = (@guardaparques / @prorrateo) + 1;
    SET @f_ingreso = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());

    EXEC RRHH.AsignarGuardaparque @id_guardaparque = @guardaparques, @id_parque = @parque, @fecha_ingreso = @f_ingreso;
    SET @guardaparques = @guardaparques + 1
END

--La parte sobrante se distribuirá entre todos los parques aleatoriamente.
SET @guardaparques = @cant_parques * @prorrateo; --CHEQUEAR
DECLARE @resto INT = (SELECT @cant_gpques % @cant_parques);
WHILE @guardaparques <= (@cant_parques * @prorrateo) + @resto
BEGIN
    SET @parque = 1 + ABS(CHECKSUM(NEWID())) % @cant_parques;
    SET @f_ingreso = DATEADD(D, - ABS(CHECKSUM(NEWID())) % (365 * 20), GETDATE());

    EXEC RRHH.AsignarGuardaparque @id_guardaparque = @guardaparques, @id_parque = @parque, @fecha_ingreso = @f_ingreso;
    SET @guardaparques = @guardaparques + 1
END
GO

SELECT TOP 50 * FROM RRHH.AsignacionesDeGuardaparques
ORDER BY NEWID()

--PASO EXTRA: Destituir aleatoriamente algunos guardaparques.

DECLARE @factor_destitucion DECIMAL(3, 2) = 0.30;
DECLARE @cant_gpques INT = (SELECT COUNT(1) FROM RRHH.Guardaparques WHERE esta_activo = 1);

DECLARE @motivos TABLE (
    id INT IDENTITY(1, 1),
    descripcion VARCHAR(50)
)
INSERT INTO @motivos VALUES
('Renuncia voluntaria'),
('Jubilacion'),
('Finalizacion de contrato'),
('Reestructuracion administrativa'),
('Incumplimiento de funciones'),
('Faltas reiteradas'),
('Sancion disciplinaria'),
('Inhabilitacion profesional'),
('Problemas de salud'),
('Fallecimiento'),
('Traslado a otro organismo'),
('Rescision de concesion');

DECLARE @gpques_activos TABLE (
    id INT IDENTITY(1, 1),
    gpques_id INT
)
INSERT INTO @gpques_activos
    SELECT id FROM RRHH.Guías WHERE esta_activo = 1

DECLARE @i INT = 1;
WHILE @i < CAST(@factor_destitucion * @cant_gpques AS INT)
BEGIN
    DECLARE @gpques_id INT = (SELECT TOP 1 gpques_id FROM @gpques_activos ORDER BY NEWID());
    DECLARE @f_ingreso DATETIME = (SELECT f_ingreso FROM RRHH.AsignacionesDeGuardaparques WHERE guardaparques_id = @gpques_id);
    DECLARE @cant_dias INT = (SELECT DATEDIFF(D, @f_ingreso, GETDATE()) );
    DECLARE @f_egreso DATETIME = DATEADD(D, 0.8 * RAND(CHECKSUM(NEWID())) * @cant_dias, @f_ingreso);
    DECLARE @motivo VARCHAR(200) = (SELECT TOP 1 descripcion FROM @motivos ORDER BY NEWID());

    EXEC RRHH.FinalizarAsignacionGuardaparque @gpques_id, @f_egreso, @motivo
    DELETE FROM @gpques_activos WHERE gpques_id = @gpques_id
    SET @i = @i + 1
END

SELECT TOP 50 * FROM RRHH.AsignacionesDeGuardaparques
ORDER BY NEWID()

-- =============================================
-- Autorizaciones de Guías (GENERABLE)
-- =============================================

--¿Cuantos guías hay activos?
SELECT TOP 20 * FROM RRHH.AsignacionesDeGuias
WHERE f_egreso IS NULL

--¿Cuántos tours hay?
SELECT * FROM Administracion.TarifasDeArticulo
WHERE tipo_articulo = 'T'

--¿Qué tours pueden impartir cada guía activo en cada parque?
SELECT TOP 20 rag.guia_id, rag.parque_id, ata.tipo_articulo, ata.descripcion, ata.duracion, ata.cupo, ata.precio
FROM RRHH.AsignacionesDeGuias rag INNER JOIN 
Administracion.TarifasDeArticulo ata ON
rag.parque_id = ata.parque_id
WHERE rag.f_egreso IS NULL AND ata.tipo_articulo = 'T'


DECLARE @guia INT = 1;
DECLARE @cant_guias INT = (SELECT COUNT(1) FROM RRHH.AsignacionesDeGuias WHERE f_egreso IS NULL);
WHILE @guia <= @cant_guias
BEGIN

    EXEC RRHH.AutorizarGuia @id_guia = @guia, @id_tarifa, @fecha_inicio
    SET @guia = @guia + 1
END
GO