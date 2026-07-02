/*
Para realizar el despliegue completo, realizar los siguientes pasos:

1. Ve al menú superior: Query → SQLCMD Mode
2. Haz clic sobre esa opción.

Desactivar cuando todo haya terminado.
*/
--/*
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\00_Borrado_BBDD.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\01_Creacion_BBDD.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\02_Creacion_Esquemas.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\03_Creacion_Tablas.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\04_Restricciones.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\DDL\05_Indices.sql
:r E:\evanrepos\Parques-Nacionales\Seguridad\00_Cifrado.sql

:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Administracion\00_Operaciones_Administracion.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Administracion\02_Importacion_Administracion.sql

:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Comercial\00_Operaciones_Concesion.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Comercial\00_Operaciones_Empresa.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Comercial\02_Importacion_Comercial.sql

:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\RRHH\00_Operaciones_Guias.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\RRHH\00_Operaciones_Guardaparques.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\RRHH\02_Importacion_RRHH.sql

:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Ventas\00_Operaciones_Ventas.sql
:r E:\evanrepos\Parques-Nacionales\BBDD\OPERACIONES\Ventas\02_Importacion_Ventas.sql

:r E:\evanrepos\Parques-Nacionales\Reportes\00_Generacion_Reportes.sql

!!ECHO :r E:\evanrepos\Parques-Nacionales\Seguridad\02_Backups.sql
/*

*/
--*/

/*
USE ParquesNacionales
GO

SET NOCOUNT OFF
-- =============================================
-- Administracion
-- =============================================

SELECT * FROM Administracion.FormasDePago
SELECT * FROM Administracion.Divisas
SELECT * FROM Administracion.TiposDeFecha
SELECT * FROM Administracion.Feriados
SELECT * FROM Administracion.TiposDeVisitante
SELECT * FROM Administracion.TiposDeParque
SELECT * FROM Administracion.Provincias
SELECT * FROM Administracion.Parques
SELECT * FROM Administracion.PuntosDeVenta
SELECT * FROM Administracion.TarifasDeArticulo
SELECT * FROM Administracion.Ajustes

-- =============================================
-- Comercial
-- =============================================

SELECT * FROM Comercial.ActividadesDeConcesiones
SELECT * FROM Comercial.Empresas

OPEN SYMMETRIC KEY SK_Datos_Sensibles_Empresa
DECRYPTION BY CERTIFICATE CertificadoParques

SELECT 
	id,
	CONVERT(CHAR(11), DECRYPTBYKEY(cuit)),
	razon_social,
	CONVERT(VARCHAR(100), DECRYPTBYKEY(direccion_legal)),
	comienzo_actividad
	FROM Comercial.Empresas

CLOSE SYMMETRIC KEY SK_Datos_Sensibles_Empresa

SELECT * FROM Comercial.Concesiones
SELECT * FROM Comercial.CuotasCanon

-- =============================================
-- RRHH
-- =============================================

SELECT * FROM RRHH.Guardaparques
SELECT * FROM RRHH.AsignacionesDeGuardaparques
SELECT * FROM RRHH.Guias
SELECT * FROM RRHH.AsignacionesDeGuias

OPEN SYMMETRIC KEY SK_Datos_Sensibles_RRHH
DECRYPTION BY CERTIFICATE CertificadoParques

SELECT 
	id,
	CONVERT(CHAR(11), DECRYPTBYKEY(cuil)),
	nombre,
	apellido,
	esta_activo,
	f_nacimiento
FROM RRHH.Guardaparques

SELECT 
	id,
	parque_id,
	guardaparques_id,
	f_ingreso,
	f_egreso,
	CONVERT(VARCHAR(200), DECRYPTBYKEY(motivo_egreso))
FROM RRHH.AsignacionesDeGuardaparques

SELECT 
	id,
	CONVERT(CHAR(11), DECRYPTBYKEY(cuil)),
	nombre,
	apellido,
	esta_activo,
	f_nacimiento
FROM RRHH.Guias

SELECT 
	id,
	parque_id,
	guia_id,
	f_ingreso,
	f_egreso,
	CONVERT(VARCHAR(200), DECRYPTBYKEY(motivo_egreso))
FROM RRHH.AsignacionesDeGuias

CLOSE SYMMETRIC KEY SK_Datos_Sensibles_RRHH

SELECT * FROM RRHH.AutorizacionesDeGuias

-- =============================================
-- Ventas
-- =============================================

SELECT * FROM Ventas.TicketsDeVenta
WHERE divisa_id = 30
SELECT * FROM Ventas.DetallesDeTicket
SELECT * FROM Ventas.Entradas
SELECT * FROM Ventas.Actividades
SELECT * FROM Ventas.ParticipaEnTour
ORDER BY tour_id
SELECT * FROM Ventas.Tours

SELECT t.id, t.f_visita, COUNT(pt.ticket_id) AS participantes, t.cant_cupos
FROM Ventas.Tours t LEFT JOIN Ventas.ParticipaEnTour pt ON t.id = pt.tour_id
GROUP BY t.id, t.f_visita, t.cant_cupos
ORDER BY CAST(t.f_visita AS DATE), t.f_visita;

SET NOCOUNT ON
*/