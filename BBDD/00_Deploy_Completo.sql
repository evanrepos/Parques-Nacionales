/*
Para realizar el despliegue completo, realizar los siguientes pasos:

1. Ve al menú superior: Query → SQLCMD Mode
2. Haz clic sobre esa opción.

Desactivar cuando todo haya terminado.
*/

:setvar ROOT "E:\evanrepos\Parques-Nacionales\BBDD"

:r "$(ROOT)\DDL\00_Borrado_BBDD.sql"
:r "$(ROOT)\DDL\01_Creacion_BBDD.sql"
:r "$(ROOT)\DDL\02_Creacion_Esquemas.sql"
:r "$(ROOT)\DDL\03_Creacion_Tablas.sql"
:r "$(ROOT)\DDL\04_Restricciones.sql"

:r "$(ROOT)\OPERACIONES\Administracion\00_Operaciones_Administracion.sql"
:r "$(ROOT)\OPERACIONES\Administracion\02_Importacion_Administracion.sql"

:r "$(ROOT)\OPERACIONES\Comercial\00_Operaciones_Concesion.sql"
:r "$(ROOT)\OPERACIONES\Comercial\00_Operaciones_Empresa.sql"
:r "$(ROOT)\OPERACIONES\Comercial\02_Importacion_Comercial.sql"

:r "$(ROOT)\OPERACIONES\RRHH\00_Operaciones_Guias.sql"
:r "$(ROOT)\OPERACIONES\RRHH\00_Operaciones_Guardaparques.sql"
:r "$(ROOT)\OPERACIONES\RRHH\02_Importacion_RRHH.sql"

:r "$(ROOT)\OPERACIONES\Ventas\00_Operaciones_Ventas.sql"
:r "$(ROOT)\OPERACIONES\Ventas\02_Importacion_Ventas.sql"