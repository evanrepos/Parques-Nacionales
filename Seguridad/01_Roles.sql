USE ParquesNacionales
GO

CREATE ROLE rol_administrador;

CREATE ROLE rol_ventas;

CREATE ROLE rol_importador;

CREATE ROLE rol_consultas;

CREATE ROLE rol_rrhh;
DENY SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::gestion
TO rol_ventas;