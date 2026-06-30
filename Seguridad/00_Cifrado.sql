USE ParquesNacionales
GO

-- Crear Master Key
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Contraseña';

-- Crear Certificado
CREATE CERTIFICATE CertificadoParques
WITH SUBJECT = 'Certificado de cifrado';

-- Crear clave simétrica
CREATE SYMMETRIC KEY SK_Datos_Sensibles_Empresa
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoParques;

CREATE SYMMETRIC KEY SK_Datos_Sensibles_RRHH
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoParques;