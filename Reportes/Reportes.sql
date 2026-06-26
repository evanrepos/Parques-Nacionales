USE ParquesNacionales
GO

SET NOCOUNT ON
GO

--CAMBIO HISTORICO DOLAR
CREATE TABLE #cambio_usd (
    indice_tiempo DATE,
    tipo_cambio_bna_vendedor DECIMAL(9, 4),
    tipo_cambio_a3500 DECIMAL(9, 4),
    tipo_cambio_mae DECIMAL(9, 4),
    volumen_mae NVARCHAR(MAX)
)

BULK INSERT #cambio_usd 
FROM 'E:\ParquesNacionales\Estadísticas\cambio-usd.csv'
WITH(
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A', 
    CODEPAGE = '65001',
    FIRSTROW = 2
);
UPDATE #cambio_usd SET volumen_mae = NULL
SELECT * FROM #cambio_usd
ORDER BY indice_tiempo

DROP TABLE #cambio_usd

--DIA DE LA SEMANA
SELECT DATEPART(WEEKDAY, GETDATE())


DECLARE @json JSON = (
SELECT * FROM OPENJSON(@response)
WITH (
    rates NVARCHAR(MAX) '$.rates' AS JSON
))
SELECT * FROM OPENJSON(@json)

EXEC sp_OADestroy @Object;
GO

--COTIZACIONES HISTORICAS DIVISAS
DECLARE @link NVARCHAR(200) = 'https://api.frankfurter.dev/v1/2026-05-01?base=USD&symbols';
DECLARE @Object INT;
DECLARE @response VARCHAR(8000);

EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @link, 'false';
EXEC sp_OAMethod @Object, 'send';
EXEC sp_OAGetProperty @Object, 'responseText', @response OUT;

DECLARE @json JSON = (
SELECT * FROM OPENJSON(@response)
WITH (
    rates NVARCHAR(MAX) '$.rates' AS JSON
))
SELECT * FROM OPENJSON(@json)

EXEC sp_OADestroy @Object;
GO

--DUMP

/*
--DELETE FROM Ventas.TicketsDeVenta
--DBCC CHECKIDENT ('Ventas.TicketsDeVenta', 'RESEED', 0)

/*
SELECT * FROM Ventas.TicketsDeVenta
ORDER BY parque_id, f_generacion

SELECT vt.tarifa_id, vt.guia_id, vt.f_visita, vt.precio, vt.cant_cupos, ata.parque_id 
FROM Ventas.Tours vt INNER JOIN Administracion.TarifasDeArticulo ata ON vt.tarifa_id = ata.id
GO
*/
--SELECT @f_generacion = f_generacion FROM Ventas.TicketsDeVenta
--ORDER BY f_generacion

--DELETE FROM Ventas.Tours
--DBCC CHECKIDENT ('Ventas.Tours', 'RESEED', 0)
*/