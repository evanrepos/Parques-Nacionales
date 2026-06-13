USE ParquesNacionales

--INGRESAR DATOS

-- =============================================
-- FormasDePago
-- =============================================
-- RECHAZO: descripcion nula
EXEC Administracion.IngresarFormasDePago
GO
-- EXITO: descripcion valida
EXEC Administracion.IngresarFormasDePago @descripcion = 'Efectivo'
GO
EXEC Administracion.IngresarFormasDePago @descripcion = 'Tarjeta de débito'
GO
EXEC Administracion.IngresarFormasDePago @descripcion = 'Tarjeta de crédito'
GO
EXEC Administracion.IngresarFormasDePago @descripcion = 'Transferencia bancaria'
GO

-- =============================================
-- Divisas
-- =============================================
-- RECHAZO: descripcion nula
EXEC Administracion.IngresarDivisas
GO
-- EXITO: descripcion valida
EXEC Administracion.IngresarDivisas @descripcion = 'Peso argentino'
GO
EXEC Administracion.IngresarDivisas @descripcion = 'Dólar estadounidense'
GO
EXEC Administracion.IngresarDivisas @descripcion = 'Euro'
GO

-- =============================================
-- TiposDeFecha
-- =============================================
-- RECHAZO: descripcion nula
EXEC Administracion.IngresarTiposDeFecha
GO
-- EXITO: descripcion valida
EXEC Administracion.IngresarTiposDeFecha @descripcion = 'Temporada alta'
GO
EXEC Administracion.IngresarTiposDeFecha @descripcion = 'Temporada baja'
GO
EXEC Administracion.IngresarTiposDeFecha @descripcion = 'Feriado nacional'
GO

-- =============================================
-- TiposDeVisitante
-- =============================================
-- RECHAZO: descripcion nula
EXEC Administracion.IngresarTiposDeVisitante
GO
-- EXITO: descripcion valida
EXEC Administracion.IngresarTiposDeVisitante @descripcion = 'Comun'
GO
EXEC Administracion.IngresarTiposDeVisitante @descripcion = 'Jubilado'
GO
EXEC Administracion.IngresarTiposDeVisitante @descripcion = 'Estudiante'
GO
EXEC Administracion.IngresarTiposDeVisitante @descripcion = 'Extranjero'
GO

-- =============================================
-- TiposDeParque
-- =============================================
-- RECHAZO: descripcion nula
EXEC Administracion.IngresarTiposDeParque
GO
-- EXITO: descripcion valida
EXEC Administracion.IngresarTiposDeParque @descripcion = 'Nacional'
GO
EXEC Administracion.IngresarTiposDeParque @descripcion = 'Provincial'
GO
EXEC Administracion.IngresarTiposDeParque @descripcion = 'Reserva natural'
GO

-- =============================================
-- Provincias
-- =============================================
-- RECHAZO: nombre nulo
EXEC Administracion.IngresarProvincias
GO
-- EXITO: nombre valido
EXEC Administracion.IngresarProvincias @nombre = 'Buenos Aires'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Córdoba'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Neuquén'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Río Negro'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Chubut'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Santa Cruz'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Tierra del Fuego'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Mendoza'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Salta'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Jujuy'
GO
EXEC Administracion.IngresarProvincias @nombre = 'Misiones'
GO

-- =============================================
-- Localidades
-- =============================================
-- RECHAZO: nombre nulo (provincia valida)
EXEC Administracion.IngresarLocalidad @provincias_id = 1
GO
-- RECHAZO: provincia inexistente (nombre valido)
EXEC Administracion.IngresarLocalidad @provincias_id = 9999, @nombre = 'San Carlos de Bariloche'
GO
-- EXITO: provincia y nombre validos
-- (Asumir que Buenos Aires = 1, Córdoba = 2, Neuquén = 3, Río Negro = 4,
--  Chubut = 5, Santa Cruz = 6, Tierra del Fuego = 7, Mendoza = 8, Salta = 9,
--  Jujuy = 10, Misiones = 11, según orden de inserción de Provincias)
EXEC Administracion.IngresarLocalidad @provincias_id = 4, @nombre = 'San Carlos de Bariloche'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 4, @nombre = 'El Bolsón'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 3, @nombre = 'San Martín de los Andes'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 3, @nombre = 'Villa La Angostura'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 5, @nombre = 'Esquel'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 6, @nombre = 'Calafate'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 7, @nombre = 'Ushuaia'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 9, @nombre = 'Cachi'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 10, @nombre = 'Tilcara'
GO
EXEC Administracion.IngresarLocalidad @provincias_id = 11, @nombre = 'Puerto Iguazú'
GO

/*Parques: Verificar:
	+ RECHAZO al ingresar parques con TIPO DE PARQUE INEXISTENTE.
	+ RECHAZO al ingresar parques con LOCALIDAD INEXISTENTE.
	+ RECHAZO al ingresar parques con SUPERFICIE NEGATIVA.
*/
EXEC Administracion.IngresarParques 
GO

/*TarifasDeArtículo: Verificar:
	+ RECHAZO al ingresar PARQUE INEXISTENTE.
	+ RECHAZO al ingresar TIPO DE ARTÍCULO INCOMPATIBLE.
	+ RECHAZO al ingresar TOUR sin DURACION O CUPO.
	+ RECHAZO al ingresar PRECIO NEGATIVO (Cuidado, el artículo puede ser gratuíto)
*/
EXEC Administracion.IngresarTarifasDeArticulo
GO

/*Ajuste: Verificar:
	+ RECHAZO al ingresar PARQUE INEXISTENTE.
	+ RECHAZO al ingresar TIPO DE ARTÍCULO INCOMPATIBLE.
	+ RECHAZO al ingresar TIPO DE VISITANTE INEXISTENTE.
	+ RECHAZO al ingresar TIPO DE FECHA INEXISTENTE.
*/

EXEC Administracion.IngresarAjustes
GO

--Punto de venta: Verificar RECHAZO al ingresar PARQUE INEXISTENTE.

EXEC Administracion.IngresarPuntosDeVenta
GO

/*------------------------------------------------------------------------------------------------------------*/
--ACTUALIZAR DATOS
--TODOS: Verificar RECHAZO al ingresar PARAMETROS DE CONSULTA NULOS, o PARAMETROS DE MODIFICACION NULOS.
EXEC Administracion.ActualizarFormasDePago
GO
EXEC Administracion.ActualizarDivisas
GO
EXEC Administracion.ActualizarTiposDeFecha
GO
EXEC Administracion.ActualizarTiposDeVisitante
GO
EXEC Administracion.ActualizarTiposDeParque
GO
EXEC Administracion.ActualizarProvincias
GO
EXEC Administracion.ActualizarLocalidades
GO
EXEC Administracion.ActualizarParques
GO
EXEC Administracion.ActualizarTarifasDeArticulo
GO
EXEC Administracion.ActualizarAjustes
GO
EXEC Administracion.ActualizarPuntosDeVenta
GO

/*------------------------------------------------------------------------------------------------------------*/
--ELIMINAR DATOS
--TODOS: Verificar RECHAZO al ingresar PARAMETROS DE CONSULTA NULOS, o PARAMETROS DE MODIFICACION NULOS.
EXEC Administracion.EliminarFormasDePago
GO
EXEC Administracion.EliminarDivisas
GO
EXEC Administracion.EliminarTiposDeFecha
GO
EXEC Administracion.EliminarTiposDeVisitante
GO
EXEC Administracion.EliminarTiposDeParque
GO
EXEC Administracion.EliminarProvincias
GO
EXEC Administracion.EliminarLocalidades
GO
EXEC Administracion.EliminarParques
GO
EXEC Administracion.EliminarTarifasDeArticulo
GO
EXEC Administracion.EliminarAjustes
GO
EXEC Administracion.EliminarPuntosDeVenta
GO