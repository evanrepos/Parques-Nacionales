/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--CONFIGURACIÓN PREVIA
/*
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 
    1;

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 
    1;

SELECT name, description 
FROM sys.dm_os_loaded_modules
WHERE name LIKE '%ACE%';
*/

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--DECLARACION TABLAS
CREATE TABLE #visitasCSV (
    indice_tiempo DATE,
    origen_visitantes VARCHAR(100),
    visitas INT,
    observaciones VARCHAR(500)      
);
GO
CREATE TABLE #visitasRegionCSV (
    indice_tiempo DATE,
    region_de_destino VARCHAR(100),
    origen_visitantes VARCHAR(100),
    visitas INT,
    observaciones VARCHAR(500)      
);
GO

CREATE TABLE #PaseDiario (
	id INT IDENTITY(1, 1),
	nombre_parque NVARCHAR(100),
	tarifa_general DECIMAL(10, 2),
	tarifa_nacional DECIMAL(10, 2),
	tarifa_residentes_provinciales DECIMAL(10, 2),
	tarifa_estudiantes DECIMAL(10, 2),
);

CREATE TABLE #Flexipass3Dias (
	id INT IDENTITY(1, 1),
	nombre_parque NVARCHAR(100),
	tarifa_general DECIMAL(10, 2),
	tarifa_nacional DECIMAL(10, 2),
	tarifa_residentes_provinciales DECIMAL(10, 2)
);

CREATE TABLE #Flexipass7Dias (
	id INT IDENTITY(1, 1),
	nombre_parque NVARCHAR(100),
	tarifa_general DECIMAL(10, 2),
	tarifa_nacional DECIMAL(10, 2),
	tarifa_residentes_provinciales DECIMAL(10, 2)
);

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--IMPORTACION CSV A TABLAS
--ESTADISTICAS
SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Text;Database=E:\ParquesNacionales\Estadísticas\;HDR=YES;FMT=Delimited',
    'SELECT * FROM [visitas-residentes-y-no-residentes.csv]'
);

SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Text;Database=E:\ParquesNacionales\Estadísticas\;HDR=YES;FMT=Delimited',
    'SELECT * FROM [visitas-residentes-y-no-residentes-por-region.csv]'
);

--TARIFAS
--Tarifas entradas
SELECT * 
--INTO #PaseDiario
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\Tarifas\TarifasEntradas260618.xlsx',
    'SELECT * FROM [PaseDiario$]'
);

SELECT * 
--INTO #Flexipass3Dias
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\Tarifas\TarifasEntradas260618.xlsx',
    'SELECT * FROM [Flexipass3Dias$]'
);

SELECT * 
--INTO #Flexipass7Dias
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\Tarifas\TarifasEntradas260618.xlsx',
    'SELECT * FROM [Flexipass7Dias$]'
);

--PARQUES NACIONALES
--Areas Protegidas
SELECT * 
--INTO #AreasProtegidas
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\AreasProtegidas\AreasProtegidas.xlsx',
    'SELECT * FROM [Areas_Protegidas$]'
);

--Patrimonio Natural
SELECT * 
--INTO #PatrimonioNatural
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\AreasProtegidas\AreasProtegidas.xlsx',
    'SELECT * FROM [Patrimonio_Natural$]'
);

--Patrimonio Cultural
SELECT * 
--INTO #PatrimonioCultural
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\AreasProtegidas\AreasProtegidas.xlsx',
    'SELECT * FROM [Patrimonio_Cultural$]'
);

--Reservas Biosfera
SELECT * 
--INTO #ReservasBiosfera
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\ParquesNacionales\AreasProtegidas\AreasProtegidas.xlsx',
    'SELECT * FROM [Reservas_Biosfera$]'
);

--SELECT REPLACE(LTRIM(General, '$ '), '.', ',') FROM #PaseDiario
--SELECT * FROM #Flexipass3Dias
--SELECT * FROM #Flexipass7Dias

--PROBAR DATOS
SELECT * FROM #visitasCSV
SELECT TOP 50 * FROM #visitasRegionCSV

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--ROLLBACK
DROP TABLE IF EXISTS #PaseDiario
GO
DROP TABLE IF EXISTS #Flexipass3Dias
GO
DROP TABLE IF EXISTS #Flexipass7Dias
GO
DROP TABLE IF EXISTS #visitasRegionCSV
GO
DROP TABLE IF EXISTS #visitasCSV
GO