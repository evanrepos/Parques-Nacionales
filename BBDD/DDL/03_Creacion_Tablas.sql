USE ParquesNacionales;
GO

--CREACION TABLAS
--Paramétricas
IF OBJECT_ID('Administracion.FormasDePago', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.FormasDePago (
        id INT PRIMARY KEY IDENTITY(1,1),
        descripcion VARCHAR(100) NOT NULL
    );
END
GO

IF OBJECT_ID('Administracion.Divisas', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.Divisas (
        id INT PRIMARY KEY IDENTITY(1,1),
        codigo_iso VARCHAR(6) NOT NULL,
        descripcion VARCHAR(100) NOT NULL,
        cotizacion DECIMAL(19, 6) NOT NULL
            CONSTRAINT DF_Divisas_Cotizacion DEFAULT 0,
        f_actualizacion SMALLDATETIME NOT NULL
            CONSTRAINT DF_Divisas_Fecha_Actualizacion DEFAULT GETDATE(),
    );
END
GO

IF OBJECT_ID('Administracion.TiposDeFecha', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.TiposDeFecha (
        id INT PRIMARY KEY IDENTITY(1,1),
        descripcion VARCHAR(100) NOT NULL
    );
END
GO

IF OBJECT_ID('Administracion.TiposDeVisitante', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.TiposDeVisitante (
        id INT PRIMARY KEY IDENTITY(1,1),
        descripcion VARCHAR(100) NOT NULL
    );
END
GO

IF OBJECT_ID('Administracion.TiposDeParque', 'U') IS NULL
BEGIN
CREATE TABLE Administracion.TiposDeParque (
	id INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(100) NOT NULL
);
END
GO

IF OBJECT_ID('Administracion.Provincias', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.Provincias (
    	id INT PRIMARY KEY IDENTITY(1,1),
    	descripcion VARCHAR(100) NOT NULL,
    );
END
GO

--Tablas comunes
IF OBJECT_ID('Administracion.Parques', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.Parques (
    	id INT PRIMARY KEY IDENTITY(1,1),
    	tipo_parque_id INT NOT NULL,
    	provincia_id INT NOT NULL,
    	direccion VARCHAR(150) NOT NULL,
    	nombre VARCHAR(100) NOT NULL,
    	superficie_km_2 INT NOT NULL,
        año_creacion SMALLINT NOT NULL,
        CONSTRAINT CK_Parques_Superficie CHECK (superficie_km_2 > 0),
        CONSTRAINT CK_Parques_Año_Creacion CHECK (1500 < año_creacion AND año_creacion <= YEAR(GETDATE())),
    	CONSTRAINT FK_Parques_Provincias FOREIGN KEY (provincia_id) REFERENCES Administracion.Provincias(id),
    	CONSTRAINT FK_Parques_Tipos FOREIGN KEY (tipo_parque_id) REFERENCES Administracion.TiposDeParque(id)
    );
END
GO

IF OBJECT_ID('Administracion.TarifasDeArticulo', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.TarifasDeArticulo (
        id INT PRIMARY KEY IDENTITY(1, 1),
        parque_id INT NOT NULL,
        tipo_articulo CHAR(1) NOT NULL, --El tipo de artículo ahora es un char.
        descripcion VARCHAR(100) NOT NULL,
        duracion INT NULL,
        cupo INT NULL,
        precio DECIMAL(10, 2) NOT NULL,
        CONSTRAINT CK_Tarifas_Tipo_Articulo CHECK (tipo_articulo IN ('E', 'T', 'A')),
        CONSTRAINT CK_Tarifas_Precio CHECK (precio >= 0),
        CONSTRAINT CK_Tarifas_Duracion CHECK (tipo_articulo <> 'T' OR (duracion IS NOT NULL OR duracion > 0)),
        CONSTRAINT CK_Tarifas_Cupo CHECK (tipo_articulo <> 'T' OR (cupo IS NOT NULL OR cupo > 0)),
        CONSTRAINT FK_Tarifas_Parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id)
    );
END
GO

IF OBJECT_ID('Administracion.Ajustes', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.Ajustes (
        id INT PRIMARY KEY IDENTITY(1, 1),
        parque_id INT NOT NULL,
        tipo_articulo CHAR(1) NOT NULL,
        tipo_ajuste CHAR(1) NOT NULL,
        descripcion VARCHAR(30) NOT NULL,
        porcentaje SMALLINT NOT NULL,
        CONSTRAINT CK_Ajustes_Tipo_Articulo CHECK (tipo_articulo IN ('E', 'T', 'A')),
        CONSTRAINT CK_Ajustes_Tipo_Ajuste CHECK (tipo_ajuste IN ('F', 'V', 'TE')), -- F: Fecha, V: Visitante, TE: Tipo Entrada
        CONSTRAINT FK_Ajustes_Parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id)
    );
END
GO

IF OBJECT_ID('Administracion.PuntosDeVenta', 'U') IS NULL
BEGIN
    CREATE TABLE Administracion.PuntosDeVenta (
        id SMALLINT NOT NULL,
        parque_id INT NOT NULL,
        descripcion VARCHAR(100) NULL,
        CONSTRAINT PK_Puntos_De_Venta PRIMARY KEY (id, parque_id),
        CONSTRAINT FK_Puntos_De_Venta_Parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id)
    );
END
GO

IF OBJECT_ID('RRHH.Guardaparques', 'U') IS NULL
BEGIN
    CREATE TABLE RRHH.Guardaparques (
        id INT PRIMARY KEY IDENTITY(1,1),
        cuil BIGINT NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL,
        esta_activo BIT NOT NULL
            CONSTRAINT DF_Guardaparques_Esta_Activo DEFAULT 0,
        f_nacimiento DATE NOT NULL,
        CONSTRAINT UQ_Guardaparques_Cuil UNIQUE (cuil),
        CONSTRAINT CK_Guardaparques_Cuil CHECK (cuil BETWEEN 20000000001 AND 339999999999)
    );
END
GO

IF OBJECT_ID('RRHH.AsignacionesDeGuardaparques', 'U') IS NULL
BEGIN
    CREATE TABLE RRHH.AsignacionesDeGuardaparques (
        id INT PRIMARY KEY IDENTITY(1,1),
        parque_id INT NOT NULL,
        guardaparques_id INT NOT NULL,
        f_ingreso DATE NOT NULL,
        f_egreso DATE NULL,
        f_motivo_egreso VARCHAR(200) NULL,
        CONSTRAINT FK_AsignacionesGuardaparques_Parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id),
        CONSTRAINT FK_Asignaciones_Guardaparques FOREIGN KEY (guardaparques_id) REFERENCES RRHH.Guardaparques(id)
    );
END
GO

IF OBJECT_ID('RRHH.Guias', 'U') IS NULL
BEGIN
    CREATE TABLE RRHH.Guias (
    	id INT PRIMARY KEY IDENTITY(1,1),
    	cuil BIGINT NOT NULL,
    	nombre VARCHAR(100) NOT NULL,
    	apellido VARCHAR(100) NOT NULL,
        esta_activo BIT NOT NULL
            CONSTRAINT DF_Guias_Esta_Activo DEFAULT 0,
        f_nacimiento DATE NOT NULL,
        CONSTRAINT UQ_Guias_Cuil UNIQUE (cuil),
        CONSTRAINT CK_Guias_Cuil CHECK (cuil BETWEEN 20000000001 AND 339999999999)
    );
END
GO

IF OBJECT_ID('RRHH.AsignacionesDeGuias', 'U') IS NULL
BEGIN
    CREATE TABLE RRHH.AsignacionesDeGuias (
        id INT PRIMARY KEY IDENTITY(1,1),
        parque_id INT NOT NULL,
        guia_id INT NOT NULL,
        f_ingreso DATE NOT NULL,
        f_egreso DATE,
        motivo_egreso VARCHAR(200),
        CONSTRAINT FK_AsignacionesDeGuias_Parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id),
        CONSTRAINT FK_AsignacionesDeGuias_Guia FOREIGN KEY (guia_id) REFERENCES RRHH.Guias(id)
    );
END
GO

IF OBJECT_ID('RRHH.AutorizacionesDeGuias', 'U') IS NULL
BEGIN
    CREATE TABLE RRHH.AutorizacionesDeGuias (
        id INT PRIMARY KEY IDENTITY(1, 1),
        articulo_id INT NOT NULL,
        guia_id INT NOT NULL,
        f_inicio DATE NOT NULL,
        f_fin DATE NULL,
        CONSTRAINT FK_AutorizacionesDeGuias_Articulos FOREIGN KEY (articulo_id) REFERENCES Administracion.TarifasDeArticulo(id),
        CONSTRAINT FK_AutorizacionesDeGuias_Guias FOREIGN KEY (guia_id) REFERENCES RRHH.Guias(id)
    );
END
GO

IF OBJECT_ID('Comercial.ActividadesDeConcesiones', 'U') IS NULL
BEGIN
    CREATE TABLE Comercial.ActividadesDeConcesiones (
        id INT PRIMARY KEY IDENTITY(1,1),
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(100) NULL
    );
END
GO

IF OBJECT_ID('Comercial.Empresas', 'U') IS NULL
BEGIN
    CREATE TABLE Comercial.Empresas (
    	id INT PRIMARY KEY IDENTITY(1,1),
    	cuit BIGINT NOT NULL,
    	razon_social VARCHAR(100) NOT NULL,
    	direccion_legal VARCHAR(100) NOT NULL,
    	comienzo_actividad DATE NOT NULL
        CONSTRAINT UQ_Empresas_Cuit UNIQUE (cuit),
        CONSTRAINT CK_Empresas_Cuit CHECK (cuit BETWEEN 20000000001 AND 339999999999)
    );
END
GO

-- TODO: Regla de negocio, al menos dos semanas de concesion ?
IF OBJECT_ID('Comercial.Concesiones', 'U') IS NULL
BEGIN
    CREATE TABLE Comercial.Concesiones (
        id INT PRIMARY KEY IDENTITY(1,1),
        parque_id INT NOT NULL,
        empresa_id INT NOT NULL,
        tipo_actividad_id INT NOT NULL,
        f_firma DATE NOT NULL,
        f_inicio_vigencia DATE NOT NULL,
        f_fin_vigencia DATE NULL,
        canon_mensual DECIMAL(12, 2) NOT NULL,
        CONSTRAINT FK_Concesiones_parques FOREIGN KEY (parque_id) REFERENCES Administracion.Parques(id),
        CONSTRAINT FK_Concesiones_empresas FOREIGN KEY (empresa_id) REFERENCES Comercial.Empresas(id),
        CONSTRAINT FK_Concesiones_actividades FOREIGN KEY (tipo_actividad_id) REFERENCES Comercial.ActividadesDeConcesiones(id)
    );
END
GO

IF OBJECT_ID('Comercial.CuotasCanon', 'U') IS NULL
BEGIN
    CREATE TABLE Comercial.CuotasCanon (
        id INT PRIMARY KEY IDENTITY(1,1),
        concesion_id INT NOT NULL,
        forma_pago_id INT NULL,
        f_vencimiento DATE NOT NULL,
        f_pago DATE NULL,
        CONSTRAINT FK_Cuotas_Concesiones FOREIGN KEY (concesion_id) REFERENCES Comercial.Concesiones(id),
        CONSTRAINT FK_Cuotas_Pagos FOREIGN KEY (forma_pago_id) REFERENCES Administracion.FormasDePago(id)
    );
END
GO

IF OBJECT_ID('Ventas.TicketsDeVenta', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.TicketsDeVenta (
        id INT PRIMARY KEY IDENTITY(1,1),
        punto_venta_id SMALLINT NOT NULL,
        parque_id INT NOT NULL,
        forma_pago_id INT NOT NULL,
        divisa_id INT NOT NULL,
        cotizacion DECIMAL(19, 6),
        f_generacion SMALLDATETIME NOT NULL
            CONSTRAINT DF_Tickets_Fecha_Generacion DEFAULT GETDATE(),
        tipo_fecha_id INT NOT NULL,
        total DECIMAL(12, 2),
        CONSTRAINT FK_Ticket_Puntos_De_Venta FOREIGN KEY (punto_venta_id, parque_id) REFERENCES Administracion.PuntosDeVenta(id, parque_id),
        CONSTRAINT FK_Ticket_Pagos FOREIGN KEY (forma_pago_id) REFERENCES Administracion.FormasDePago(id),
        CONSTRAINT FK_Ticket_Divisas FOREIGN KEY (divisa_id) REFERENCES Administracion.Divisas(id),
        CONSTRAINT FK_Detalles_Tipo_Fecha FOREIGN KEY (tipo_fecha_id) REFERENCES Administracion.TiposDeFecha(id)
    );
END
GO

IF OBJECT_ID('Ventas.DetallesDeTicket', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.DetallesDeTicket (
        nro_detalle SMALLINT NOT NULL,
        ticket_id INT NOT NULL,
        tarifa_id INT NOT NULL,
        tipo_visitante_id INT NOT NULL,
        cantidad SMALLINT
            CONSTRAINT DF_Detalles_Cantidad_Unidades DEFAULT 1,
        precio_ud DECIMAL(10, 2),
        subtotal DECIMAL(12, 2),
        CONSTRAINT PK_Detalles_Tickets PRIMARY KEY CLUSTERED (ticket_id, nro_detalle),
        CONSTRAINT FK_Detalles_Tickets FOREIGN KEY (ticket_id) REFERENCES Ventas.TicketsDeVenta(id),
        CONSTRAINT FK_Detalles_Visitante FOREIGN KEY (tipo_visitante_id) REFERENCES Administracion.TiposDeVisitante(id),
        CONSTRAINT FK_Detalles_Articulos FOREIGN KEY (tarifa_id) REFERENCES Administracion.TarifasDeArticulo(id)
    );
END
GO

IF OBJECT_ID('Ventas.Tours', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Tours (
        id INT PRIMARY KEY IDENTITY(1, 1),
        tarifa_id INT NOT NULL,
        guia_id INT NOT NULL,
        f_visita SMALLDATETIME NOT NULL
            CONSTRAINT DF_Tours_Fecha_Visita DEFAULT GETDATE(),
        precio DECIMAL(10, 2),
        cant_cupos TINYINT, --Se agrega la cantidad de cupos, teniendo en cuenta que las actividades son diarias, y no por convocatoria.
        CONSTRAINT CK_Tours_Precio CHECK (precio >= 0),
        CONSTRAINT CK_Tours_Cantidad_Cupos CHECK (cant_cupos >= 0),
        CONSTRAINT FK_Tours_Tarifas FOREIGN KEY (tarifa_id) REFERENCES Administracion.TarifasDeArticulo(id),
        CONSTRAINT FK_Tours_Guias FOREIGN KEY (guia_id) REFERENCES RRHH.Guias(id)
    );
END
GO

IF OBJECT_ID('Ventas.Actividades', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Actividades (
        id INT PRIMARY KEY IDENTITY(1, 1),
        tarifa_id INT NOT NULL,
        ticket_id INT NOT NULL,
        f_visita SMALLDATETIME NOT NULL
            CONSTRAINT DF_Actividades_Fecha_Visita DEFAULT GETDATE(),
        precio DECIMAL(10, 2) NOT NULL,
        CONSTRAINT CK_Actividades_Precio CHECK (precio >= 0),
        CONSTRAINT FK_Actividades_Tarifas FOREIGN KEY (tarifa_id) REFERENCES Administracion.TarifasDeArticulo(id),
        CONSTRAINT FK_Actividades_Tickets FOREIGN KEY (ticket_id) REFERENCES Ventas.TicketsDeVenta(id)
    );
END
GO

IF OBJECT_ID('Ventas.ParticipaEnTour', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.ParticipaEnTour (
        tour_id INT NOT NULL, --OJO! Esta tabla puede tomar actividades que no sean tours.
        ticket_id INT NOT NULL,
        CONSTRAINT FK_Participacion_Tour FOREIGN KEY (tour_id) REFERENCES Ventas.Tours(id),
        CONSTRAINT FK_Participacion_Tickets FOREIGN KEY (ticket_id) REFERENCES Ventas.TicketsDeVenta(id)
    );
END
GO

IF OBJECT_ID('Ventas.Entradas', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Entradas (
	    id INT PRIMARY KEY IDENTITY(1,1),
	    tarifa_id INT NOT NULL,
        ticket_id INT NOT NULL,
        tipo_fecha_id INT NOT NULL,
        tipo_visitante_id INT NOT NULL,
        f_visita SMALLDATETIME NOT NULL
            CONSTRAINT DF_Entradas_Fecha_Visita DEFAULT GETDATE(),
        precio DECIMAL(10, 2) NOT NULL,
        CONSTRAINT CK_Entradas_Precio CHECK (precio >= 0),
	    CONSTRAINT FK_Entradas_Tarifas FOREIGN KEY (tarifa_id) REFERENCES Administracion.TarifasDeArticulo(id),
        CONSTRAINT FK_Entradas_Tickets FOREIGN KEY (ticket_id) REFERENCES Ventas.TicketsDeVenta(id),
        CONSTRAINT FK_Entradas_Fechas FOREIGN KEY (tipo_fecha_id) REFERENCES Administracion.TiposDeFecha(id),
        CONSTRAINT FK_Entradas_Visitantes FOREIGN KEY (tipo_visitante_id) REFERENCES Administracion.TiposDeVisitante(id)
    );
END
GO
