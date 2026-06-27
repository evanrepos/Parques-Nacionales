/*
Para realizar el despliegue completo, realizar los siguientes pasos:

1. Ve al menú superior: Query → SQLCMD Mode
2. Haz clic sobre esa opción.

Desactivar cuando todo haya terminado.
*/
--/*
:r .\BBDD\DDL\00_Borrado_BBDD.sql
:r .\BBDD\DDL\01_Creacion_BBDD.sql
:r .\BBDD\DDL\02_Creacion_Esquemas.sql
:r .\BBDD\DDL\03_Creacion_Tablas.sql
:r .\BBDD\DDL\04_Restricciones.sql

:r .\BBDD\OPERACIONES\Administracion\00_Operaciones_Administracion.sql
:r .\BBDD\OPERACIONES\Administracion\02_Importacion_Administracion.sql

:r .\BBDD\OPERACIONES\Comercial\00_Operaciones_Concesion.sql
:r .\BBDD\OPERACIONES\Comercial\00_Operaciones_Empresa.sql
:r .\BBDD\OPERACIONES\Comercial\02_Importacion_Comercial.sql

:r .\BBDD\OPERACIONES\RRHH\00_Operaciones_Guias.sql
:r .\BBDD\OPERACIONES\RRHH\00_Operaciones_Guardaparques.sql
:r .\BBDD\OPERACIONES\RRHH\02_Importacion_RRHH.sql

:r .\BBDD\OPERACIONES\Ventas\00_Operaciones_Ventas.sql
:r .\BBDD\OPERACIONES\Ventas\02_Importacion_Ventas.sql
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
SELECT * FROM Comercial.Concesiones
SELECT * FROM Comercial.CuotasCanon

-- =============================================
-- RRHH
-- =============================================

SELECT * FROM RRHH.Guardaparques
SELECT * FROM RRHH.AsignacionesDeGuardaparques
SELECT * FROM RRHH.Guias
SELECT * FROM RRHH.AsignacionesDeGuias
SELECT * FROM RRHH.AutorizacionesDeGuias

-- =============================================
-- Ventas
-- =============================================

SELECT * FROM Ventas.TicketsDeVenta
SELECT * FROM Ventas.DetallesDeTicket
SELECT * FROM Ventas.Entradas
SELECT * FROM Ventas.Actividades
SELECT * FROM Ventas.ParticipaEnTour
SELECT * FROM Ventas.Tours
ORDER BY tour_id

SET NOCOUNT ON
*/