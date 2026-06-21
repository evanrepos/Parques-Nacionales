USE ParquesNacionales
GO

-- =============================================
-- Actividades Concesión (GENERABLE)
-- =============================================

EXEC Comercial.CrearActividadDeConcesion 'Gastronomía', 'Confiterías, restaurantes y kioscos de comida dentro del área protegida.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Alojamiento', 'Hosterías, cabañas y campings concesionados para visitantes.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Navegación turística', 'Paseos en lancha o catamarán por lagos, ríos o costas del parque.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Transporte interno', 'Telesillas, vehículos 4x4 o combis para traslado de visitantes dentro del parque.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Alquiler de equipos recreativos', 'Kayaks, bicicletas, equipo de esquí o snorkel.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Escuela de actividades deportivas', 'Clases de esquí, buceo o kayak dictadas por instructores de la empresa concesionaria.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Comercio de productos regionales', 'Venta de artesanías, librerías y productos típicos de la zona.'
GO
EXEC Comercial.CrearActividadDeConcesion 'Estacionamiento', 'Guarda y custodia de vehículos de visitantes.'
GO

-- =============================================
-- Empresas (GENERABLE)
-- =============================================

EXEC Comercial.RegistrarEmpresa
    @cuit = 20345678001,
    @razon_social = 'Patagonia Aventura S.A.',
    @direccion_legal = 'Av. San Martin 1250, San Carlos de Bariloche, Rio Negro',
    @comienzo_actividad = '2008-03-15';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27345678012,
    @razon_social = 'Turismo Andino SRL',
    @direccion_legal = 'Belgrano 845, Mendoza, Mendoza',
    @comienzo_actividad = '2012-07-20';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30765432011,
    @razon_social = 'Expediciones del Sur S.A.',
    @direccion_legal = 'Av. Libertador 455, El Calafate, Santa Cruz',
    @comienzo_actividad = '2005-11-02';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20456789013,
    @razon_social = 'Navegacion Iguazu SRL',
    @direccion_legal = 'Ruta 12 Km 5, Puerto Iguazu, Misiones',
    @comienzo_actividad = '2010-05-10';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30567890124,
    @razon_social = 'Senderos Naturales S.A.',
    @direccion_legal = 'Av. Costanera 330, Ushuaia, Tierra del Fuego',
    @comienzo_actividad = '2015-01-18';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27678901235,
    @razon_social = 'EcoTur Patagonia SRL',
    @direccion_legal = 'Mitre 987, Esquel, Chubut',
    @comienzo_actividad = '2011-09-12';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20789012346,
    @razon_social = 'Aventura Austral S.A.',
    @direccion_legal = 'Rivadavia 122, Rio Gallegos, Santa Cruz',
    @comienzo_actividad = '2009-04-30';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30890123457,
    @razon_social = 'Excursiones Nahuel Huapi S.A.',
    @direccion_legal = 'Moreno 675, San Carlos de Bariloche, Rio Negro',
    @comienzo_actividad = '2006-08-14';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20901234568,
    @razon_social = 'Turismo del Litoral SRL',
    @direccion_legal = 'Junin 1400, Corrientes, Corrientes',
    @comienzo_actividad = '2014-06-22';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27012345679,
    @razon_social = 'Servicios Ecologicos del Norte SRL',
    @direccion_legal = 'Sarmiento 520, Salta, Salta',
    @comienzo_actividad = '2013-02-01';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20123456780,
    @razon_social = 'Andes Trekking S.A.',
    @direccion_legal = 'Las Heras 210, San Martin de los Andes, Neuquen',
    @comienzo_actividad = '2007-10-11';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30234567891,
    @razon_social = 'Cordillera Travel S.A.',
    @direccion_legal = 'España 990, Neuquen Capital, Neuquen',
    @comienzo_actividad = '2016-12-05';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27321098765,
    @razon_social = 'Aventuras del Ibera SRL',
    @direccion_legal = 'San Juan 445, Mercedes, Corrientes',
    @comienzo_actividad = '2017-03-09';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20432109876,
    @razon_social = 'Selva Viva Turismo SRL',
    @direccion_legal = 'Av. Victoria Aguirre 111, Puerto Iguazu, Misiones',
    @comienzo_actividad = '2011-08-03';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30543210987,
    @razon_social = 'Patagonia Extrema S.A.',
    @direccion_legal = '25 de Mayo 710, El Chalten, Santa Cruz',
    @comienzo_actividad = '2004-06-15';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27654321098,
    @razon_social = 'Turismo Serrano SRL',
    @direccion_legal = 'San Martin 150, Mina Clavero, Cordoba',
    @comienzo_actividad = '2018-04-27';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20765432109,
    @razon_social = 'Lagos y Bosques S.A.',
    @direccion_legal = 'Belgrano 305, Villa La Angostura, Neuquen',
    @comienzo_actividad = '2009-11-19';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30876543210,
    @razon_social = 'Turismo Federal S.A.',
    @direccion_legal = 'Av. Colon 2222, Cordoba Capital, Cordoba',
    @comienzo_actividad = '2003-01-20';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20987654321,
    @razon_social = 'Naturaleza Viva SRL',
    @direccion_legal = 'Mitre 780, Posadas, Misiones',
    @comienzo_actividad = '2020-02-14';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27098765432,
    @razon_social = 'Aventura del Fin del Mundo SRL',
    @direccion_legal = 'Maipu 50, Ushuaia, Tierra del Fuego',
    @comienzo_actividad = '2010-09-01';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20111222334,
    @razon_social = 'Paseos del Glaciar S.A.',
    @direccion_legal = 'Av. Libertador 1120, El Calafate, Santa Cruz',
    @comienzo_actividad = '2012-05-07';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30222333445,
    @razon_social = 'Senderos del Chaco S.A.',
    @direccion_legal = 'Güemes 250, Resistencia, Chaco',
    @comienzo_actividad = '2019-10-10';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27333444556,
    @razon_social = 'Excursiones Yungas SRL',
    @direccion_legal = 'Lavalle 612, San Salvador de Jujuy, Jujuy',
    @comienzo_actividad = '2016-07-18';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20444555667,
    @razon_social = 'Pampa Ecoturismo SRL',
    @direccion_legal = 'Av. Roca 410, Santa Rosa, La Pampa',
    @comienzo_actividad = '2013-03-26';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30555666778,
    @razon_social = 'Turismo de Altura S.A.',
    @direccion_legal = 'San Martin 80, San Juan, San Juan',
    @comienzo_actividad = '2008-12-12';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27666777889,
    @razon_social = 'Explora Argentina SRL',
    @direccion_legal = 'Av. Alem 999, Buenos Aires, Buenos Aires',
    @comienzo_actividad = '2015-05-05';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20777888990,
    @razon_social = 'Reserva Natural Servicios SRL',
    @direccion_legal = '9 de Julio 456, Formosa, Formosa',
    @comienzo_actividad = '2017-08-21';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 30888999001,
    @razon_social = 'Operadora Turistica Nacional S.A.',
    @direccion_legal = 'Corrientes 1500, Buenos Aires, Buenos Aires',
    @comienzo_actividad = '2001-04-01';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 20999000112,
    @razon_social = 'Destino Patagonia SRL',
    @direccion_legal = 'Av. San Martin 455, Trelew, Chubut',
    @comienzo_actividad = '2021-01-15';
GO

EXEC Comercial.RegistrarEmpresa
    @cuit = 27100111223,
    @razon_social = 'Turismo Sustentable SRL',
    @direccion_legal = 'Italia 321, Rosario, Santa Fe',
    @comienzo_actividad = '2018-11-08';
GO

