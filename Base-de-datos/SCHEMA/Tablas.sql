-- Eliminar Tablas
DROP TABLE IF EXISTS Administracion.FormasDePago;
DROP TABLE IF EXISTS Administracion.Divisas;
DROP TABLE IF EXISTS Administracion.TiposDeFecha;
DROP TABLE IF EXISTS Administracion.TiposDeVisitante;
DROP TABLE IF EXISTS Administracion.TiposDeParque;
DROP TABLE IF EXISTS Administracion.Provincias;
DROP TABLE IF EXISTS Administracion.Localidades;
DROP TABLE IF EXISTS Administracion.Parques;
DROP TABLE IF EXISTS Administracion.TarifasDeArticulo;
DROP TABLE IF EXISTS Administracion.Ajustes;
DROP TABLE IF EXISTS Administracion.PuntosDeVenta;
DROP TABLE IF EXISTS RRHH.Guardaparques;
DROP TABLE IF EXISTS RRHH.AsignacionesDeGuardaparques;
DROP TABLE IF EXISTS RRHH.Guias;
DROP TABLE IF EXISTS RRHH.AutorizacionesDeGuias;
DROP TABLE IF EXISTS Comercial.Empresas;
DROP TABLE IF EXISTS Comercial.Concesiones;
DROP TABLE IF EXISTS Comercial.ActividadesDeConcesiones;
DROP TABLE IF EXISTS Comercial.CuotasCanon;
DROP TABLE IF EXISTS Ventas.TicketsDeVenta;
DROP TABLE IF EXISTS Ventas.DetallesDeTicket;
DROP TABLE IF EXISTS Ventas.Actividades;
DROP TABLE IF EXISTS Ventas.Ventas.ParticipaEnActividad;
DROP TABLE IF EXISTS Ventas.Entradas;
GO

-- Eliminar Schemas
DROP SCHEMA IF EXISTS [Ventas]
DROP SCHEMA IF EXISTS [RRHH]
DROP SCHEMA IF EXISTS [Comercial]
DROP SCHEMA IF EXISTS [Administracion]
GO

-- Eliminar Base de Datos
USE master
DROP DATABASE IF EXISTS [ParquesNacionales];
GO

--CREACION BASE DE DATOS
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	CREATE DATABASE ParquesNacionales
	COLLATE Modern_Spanish_CS_AS
END
GO

USE ParquesNacionales;
GO

--CREACION ESQUEMAS
-- Posibles schemas:
-- Administracion / Infraestructura ( Info sobre parques, tipos de actividades, tarifas)
-- Ventas (Facturas)
-- RRHH ( Guías, Guardaparques, etc)
-- Comercial (empresas, concesiones)
CREATE SCHEMA Ventas;
GO

CREATE SCHEMA Comercial;
GO

CREATE SCHEMA RRHH;
GO

CREATE SCHEMA Administracion;
GO

--CREACION TABLAS
--Paramétricas
CREATE TABLE Administracion.FormasDePago (
    id INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(30)
);

CREATE TABLE Administracion.Divisas (
    id INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(30)
);

CREATE TABLE Administracion.TiposDeFecha (
    id INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(30)
);

CREATE TABLE Administracion.TiposDeVisitante (
    id INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(30)
);

CREATE TABLE Administracion.TiposDeParque (
	id INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(30) NOT NULL
);

CREATE TABLE Administracion.Provincias (
	id INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE Administracion.Localidades (
	id INT PRIMARY KEY IDENTITY(1,1),
	provincias_id INT NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	CONSTRAINT FK_Localidades_Provincias FOREIGN KEY (provincias_id) REFERENCES Administracion.Provincias(id)
);

--Tablas comunes
CREATE TABLE Administracion.Parques (
	id INT PRIMARY KEY IDENTITY(1,1),
	tipos_parque_id INT NOT NULL,
	localidades_id INT NOT NULL,
	direccion VARCHAR(150) NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	superficie_km_2 INT NOT NULL CHECK (superficie_km_2 > 0),
	CONSTRAINT FK_Parques_Localidades FOREIGN KEY (localidades_id) REFERENCES Administracion.Localidades(id),
	CONSTRAINT FK_Parques_Tipos FOREIGN KEY (tipos_parque_id) REFERENCES Administracion.TiposDeParque(id)
);

CREATE TABLE Administracion.TarifasDeArticulo (
    id INT PRIMARY KEY IDENTITY(1, 1),
    parques_id INT NOT NULL,
    tipos_articulo CHAR(1) NOT NULL CHECK (tipos_articulo IN ('E', 'T', 'A')), --El tipo de artículo ahora es un char.
    descripcion VARCHAR(50),
    duracion INT NULL,
    cupo INT NULL,
    precio DECIMAL(10, 2) CHECK (precio >= 0),
    CONSTRAINT CK_Duracion CHECK (tipos_articulo <> 'T' OR (duracion IS NOT NULL AND duracion > 0)),
    CONSTRAINT CK_Cupo CHECK (tipos_articulo <> 'T' OR (cupo IS NOT NULL AND cupo > 0)),
    CONSTRAINT FK_Tarifas_Parques FOREIGN KEY (parques_id) REFERENCES Administracion.Parques(id)
);

CREATE TABLE Administracion.Ajustes (
    id INT PRIMARY KEY IDENTITY(1, 1),
    parques_id INT NOT NULL, --Ajuste se vincula con parque, para saber los ajustes que se aplican en cada parque.
    tipos_articulo CHAR(1) NOT NULL CHECK (tipos_articulo IN ('E', 'T', 'A')),
    tipos_visitante_id INT NOT NULL,
    tipos_fecha_id INT NOT NULL,
    porcentaje TINYINT,
    CONSTRAINT FK_Ajustes_Parques FOREIGN KEY (parques_id) REFERENCES Administracion.Parques(id),
    CONSTRAINT FK_Ajustes_Visitantes FOREIGN KEY (tipos_visitante_id) REFERENCES Administracion.TiposDeVisitante(id),
    CONSTRAINT FK_Ajustes_Fechas FOREIGN KEY (tipos_fecha_id) REFERENCES Administracion.TiposDeFecha(id)
);

CREATE TABLE Administracion.PuntosDeVenta (
    id INT PRIMARY KEY IDENTITY(1,1),
    parques_id INT NOT NULL,
    descripcion VARCHAR(30),
    CONSTRAINT FK_Puntos_De_Venta_Parques FOREIGN KEY (parques_id) REFERENCES Administracion.Parques(id)
);

CREATE TABLE RRHH.Guardaparques (
    id INT PRIMARY KEY IDENTITY(1,1),
    cuil BIGINT UNIQUE NOT NULL CHECK (cuil between 20000000001 and 339999999999),
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    f_nacimiento DATE NOT NULL
);

-- CORREGIR: NOT NULL A FECHAS
CREATE TABLE RRHH.AsignacionesDeGuardaparques (
    id INT PRIMARY KEY IDENTITY(1,1),
    parques_id INT NOT NULL,
    guardaparques_id INT NOT NULL,
    f_ingreso DATE NOT NULL,
    f_egreso DATE,
    f_motivo_egreso VARCHAR(200),
    CONSTRAINT FK_Asignaciones_Parques FOREIGN KEY (parques_id) REFERENCES Administracion.Parques(id),
    CONSTRAINT FK_Asignaciones_Guardaparques FOREIGN KEY (guardaparques_id) REFERENCES RRHH.Guardaparques(id)
);

CREATE TABLE RRHH.Guias (
	id INT PRIMARY KEY IDENTITY(1,1),
	cuil BIGINT UNIQUE NOT NULL CHECK (cuil between 20000000001 and 339999999999),
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(200) NOT NULL,
    f_nacimiento DATE NOT NULL
);

CREATE TABLE RRHH.AutorizacionesDeGuias (
    id INT PRIMARY KEY IDENTITY(1, 1),
    articulos_id INT NOT NULL,
    guias_id INT NOT NULL,
    f_inicio DATE NOT NULL,
    f_fin DATE,
    CONSTRAINT FK_Autorizaciones_Articulos FOREIGN KEY (articulos_id) REFERENCES Administracion.TarifasDeArticulo(id),
    CONSTRAINT FK_Autorizaciones_Guias FOREIGN KEY (guias_id) REFERENCES RRHH.Guias(id)
);

CREATE TABLE Comercial.ActividadesDeConcesiones (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(30),
    descripcion VARCHAR(100)
);

CREATE TABLE Comercial.Empresas (
	id INT PRIMARY KEY IDENTITY(1,1),
	cuit BIGINT UNIQUE NOT NULL CHECK (cuit between 20000000001 and 339999999999),
	razon_social VARCHAR(100) NOT NULL,
	direccion_legal VARCHAR(100) NOT NULL,
	comienzo_actividad DATE NOT NULL
);

CREATE TABLE Comercial.Concesiones (
    id INT PRIMARY KEY IDENTITY(1,1),
    parques_id INT NOT NULL,
    empresas_id INT NOT NULL,
    tipos_actividades_id INT NOT NULL,
    f_firma DATE NOT NULL,
    f_inicio_vigencia DATE NOT NULL,
    f_fin_vigencia DATE,
    canon_mensual DECIMAL (12, 2),
    CONSTRAINT FK_Concesiones_parques FOREIGN KEY (parques_id) REFERENCES Administracion.Parques(id),
    CONSTRAINT FK_Concesiones_empresas FOREIGN KEY (empresas_id) REFERENCES Comercial.Empresas(id),
    CONSTRAINT FK_Concesiones_actividades FOREIGN KEY (tipos_actividades_id) REFERENCES Comercial.ActividadesDeConcesiones(id)
);

CREATE TABLE Comercial.CuotasCanon (
    id INT PRIMARY KEY IDENTITY(1,1),
    concesiones_id INT NOT NULL,
    formas_pago_id INT,
    f_vencimiento DATE NOT NULL,
    f_pago DATE,
    CONSTRAINT FK_Cuotas_Concesiones FOREIGN KEY (concesiones_id) REFERENCES Comercial.Concesiones(id),
    CONSTRAINT FK_Cuotas_Pagos FOREIGN KEY (formas_pago_id) REFERENCES Administracion.FormasDePago(id)
);

CREATE TABLE Ventas.TicketsDeVenta (
    id INT PRIMARY KEY IDENTITY(1,1),
    puntos_venta_id INT NOT NULL,
    formas_pago_id INT NOT NULL,
    divisas_id INT NOT NULL,
    cotizacion DECIMAL(15, 5),
    f_generacion DATE DEFAULT GETDATE() NOT NULL,
    total DECIMAL(12, 2),
    CONSTRAINT FK_tickets_Puntos_De_Venta FOREIGN KEY (puntos_venta_id) REFERENCES Administracion.PuntosDeVenta(id),
    CONSTRAINT FK_tickets_Pagos FOREIGN KEY (formas_pago_id) REFERENCES Administracion.FormasDePago(id),
    CONSTRAINT FK_tickets_Divisas FOREIGN KEY (divisas_id) REFERENCES Administracion.Divisas(id)
);

CREATE TABLE Ventas.DetallesDeTicket (
    nro_detalle SMALLINT NOT NULL, --Si se deja así, hay que almacenar números enteros positivos en forma ascendente, por cada venta iniciada.
    tickets_id INT NOT NULL,
    tarifas_id INT NOT NULL,
    ajustes_id INT,
    cantidad SMALLINT,
    precio_ud DECIMAL(10, 2),
    subtotal DECIMAL(12, 2),
    CONSTRAINT PK_Detalles_Tickets PRIMARY KEY CLUSTERED (tickets_id, nro_detalle),
    CONSTRAINT FK_Detalles_Tickets FOREIGN KEY (tickets_id) REFERENCES Ventas.TicketsDeVenta(id),
    CONSTRAINT FK_Detalles_Articulos FOREIGN KEY (tarifas_id) REFERENCES Administracion.TarifasDeArticulo(id),
    CONSTRAINT FK_Detalles_Ajustes FOREIGN KEY (ajustes_id) REFERENCES Administracion.Ajustes(id)
);

CREATE TABLE Ventas.Actividades (
    id INT PRIMARY KEY IDENTITY(1, 1),
    tarifas_id INT NOT NULL,
    tickets_id INT NOT NULL,
    guias_id INT,
    tipos_actividad CHAR(1) NOT NULL CHECK (tipos_actividad IN ('T', 'A')),
    f_visita DATE DEFAULT GETDATE() NOT NULL,
    precio DECIMAL(10, 2),
    CONSTRAINT CK_Guias_Por_Tipo CHECK (
        (tipos_actividad = 'A' AND guias_id IS NULL    ) OR
        (tipos_actividad = 'T' AND guias_id IS NOT NULL)
    ),
    CONSTRAINT FK_Actividades_Tarifas FOREIGN KEY (tarifas_id) REFERENCES Administracion.TarifasDeArticulo(id),
    CONSTRAINT FK_Actividades_Tickets FOREIGN KEY (tickets_id) REFERENCES Ventas.TicketsDeVenta(id),
    CONSTRAINT FK_Actividades_Guias FOREIGN KEY (guias_id) REFERENCES RRHH.Guias(id)
);

CREATE TABLE Ventas.ParticipaEnActividad (
    actividades_id INT NOT NULL, --OJO! Esta tabla puede tomar actividades que no sean tours.
    tickets_id INT NOT NULL,
    CONSTRAINT FK_En_Actividad FOREIGN KEY (actividades_id) REFERENCES Ventas.Actividades(id),
    CONSTRAINT FK_Tickets_En FOREIGN KEY (tickets_id) REFERENCES Ventas.TicketsDeVenta(id)
);

CREATE TABLE Ventas.Entradas (
	id INT PRIMARY KEY IDENTITY(1,1),
	tarifas_id INT NOT NULL,
    tickets_id INT NOT NULL,
    tipos_fecha_id INT NOT NULL,
    tipos_visitante_id INT NOT NULL,
    f_visita DATE DEFAULT GETDATE() NOT NULL,
    precio DECIMAL(10, 2),
	CONSTRAINT FK_Entradas_Tarifas FOREIGN KEY (tarifas_id) REFERENCES Administracion.TarifasDeArticulo(id),
    CONSTRAINT FK_Entradas_Tickets FOREIGN KEY (tickets_id) REFERENCES Ventas.TicketsDeVenta(id),
    CONSTRAINT FK_Entradas_Fechas FOREIGN KEY (tipos_fecha_id) REFERENCES Administracion.TiposDeFecha(id),
    CONSTRAINT FK_Entradas_Visitantes FOREIGN KEY (tipos_visitante_id) REFERENCES Administracion.TiposDeVisitante(id)
);