USE master;
GO

IF DB_ID('ParquesNacionales') IS NOT NULL
BEGIN
    ALTER DATABASE ParquesNacionales
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE ParquesNacionales;
END
GO
