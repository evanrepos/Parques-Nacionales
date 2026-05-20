--CREACION BASE DE DATOS
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	CREATE DATABASE ParquesNacionales
	COLLATE Modern_Spanish_CS_AS
END
GO

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

--IMPORTACION CSV A TABLAS
BULK INSERT #visitasCSV 
FROM 'E:\visitas-residentes-y-no-residentes.csv' 
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\t\n',       
    CODEPAGE = '65001',          
    FIRSTROW = 2
);
GO

BULK INSERT #visitasRegionCSV 
FROM 'E:\visitas-residentes-y-no-residentes-por-region.csv' 
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',       
    CODEPAGE = '65001',          
    FIRSTROW = 2
);
GO

SELECT * FROM #visitasRegionCSV
SELECT * FROM #visitasCSV

--ROLLBACK
DROP TABLE IF EXISTS #visitasCSV
GO
DROP TABLE IF EXISTS #visitasRegionCSV
GO
DROP DATABASE IF EXISTS ParquesNacionales
GO