/*
Para realizar el despliegue completo, realizar los siguientes pasos:

1. Ve al menú superior: Query → SQLCMD Mode
2. Haz clic sobre esa opción.

Desactivar cuando todo haya terminado.
*/

:r .\DDL\00_Borrado_BBDD.sql
:r .\DDL\01_Creacion_BBDD.sql
:r .\DDL\02_Creacion_Esquemas.sql
:r .\DDL\03_Creacion_Tablas.sql
:r .\DDL\04_Restricciones.sql

:r .\OPERACIONES\Administracion\00_Operaciones_Administracion.sql
:r .\OPERACIONES\Administracion\02_Importacion_Administracion.sql

:r .\OPERACIONES\Comercial\00_Operaciones_Concesion.sql
:r .\OPERACIONES\Comercial\00_Operaciones_Empresa.sql
:r .\OPERACIONES\Comercial\02_Importacion_Comercial.sql

:r .\OPERACIONES\RRHH\00_Operaciones_Guias.sql
:r .\OPERACIONES\RRHH\00_Operaciones_Guardaparques.sql
:r .\OPERACIONES\RRHH\02_Importacion_RRHH.sql

:r .\OPERACIONES\Ventas\00_Operaciones_Ventas.sql
:r .\OPERACIONES\Ventas\02_Importacion_Ventas.sql