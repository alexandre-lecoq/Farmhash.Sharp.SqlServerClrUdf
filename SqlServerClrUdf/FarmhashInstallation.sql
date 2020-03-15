-- Installation script for farmhash functions.
SET NOCOUNT ON ;
GO

-- !! MODIFY TO SUIT YOUR TEST ENVIRONMENT !!
USE FarmhashTest
GO

-------------------------------------------------------------------------------------------------------------------------------

-- Turn advanced options on
EXEC sys.sp_configure @configname = 'show advanced options', @configvalue = 1 ;
GO
RECONFIGURE WITH OVERRIDE ;
GO

-- Enable CLR
EXEC sys.sp_configure @configname = 'clr enabled', @configvalue = 1 ;
GO
RECONFIGURE WITH OVERRIDE ;
GO

-- Enable CLR
EXEC sys.sp_configure @configname = 'clr strict security', @configvalue = 0 ;
GO
RECONFIGURE WITH OVERRIDE ;
GO

-------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER ON;
SET CONCAT_NULL_YIELDS_NULL, NUMERIC_ROUNDABORT OFF;
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
BEGIN TRANSACTION
GO

-------------------------------------------------------------------------------------------------------------------------------

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[StringFarmhash64]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[StringFarmhash64]
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[BinaryFarmhash64]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[BinaryFarmhash64]
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[Farmhash64]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[Farmhash64]
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[StringFarmhash32]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[StringFarmhash32]
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[BinaryFarmhash32]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[BinaryFarmhash32]
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[Farmhash32]')
                    AND type = N'FS' ) 
    DROP FUNCTION [dbo].[Farmhash32]
GO

IF EXISTS ( SELECT  *
            FROM    sys.assemblies asms
            WHERE   asms.name = N'SqlServerClrUdf'
                    AND is_user_defined = 1 ) 
    DROP ASSEMBLY [SqlServerClrUdf]
GO

IF EXISTS ( SELECT  *
            FROM    sys.assemblies asms
            WHERE   asms.name = N'Farmhash.Sharp'
                    AND is_user_defined = 1 ) 
    DROP ASSEMBLY [Farmhash.Sharp]
GO

-------------------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [Farmhash.Sharp]...';
GO
CREATE ASSEMBLY [Farmhash.Sharp]
    AUTHORIZATION [dbo]
	FROM _FARMHASH_SHARP_DLL_HEX_
    WITH PERMISSION_SET = UNSAFE;
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO
ALTER ASSEMBLY [Farmhash.Sharp]
    DROP FILE ALL
	ADD FILE FROM _FARMHASH_SHARP_PDB_HEX_
    AS N'Farmhash.Sharp.pdb';
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO
EXEC sys.sp_addextendedproperty 
    @name = N'URL',
    @value = N'https://github.com/alexandre-lecoq/Farmhash.Sharp.SqlServerClrUdf',
    @level0type = N'ASSEMBLY',
    @level0name = N'Farmhash.Sharp'
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [SqlServerClrUdf]...';
GO
CREATE ASSEMBLY [SqlServerClrUdf]
    AUTHORIZATION [dbo]
	FROM _FARMHASH_SHARP_SQLSERVERCLRUDF_DLL_HEX_
    WITH PERMISSION_SET = SAFE;
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO
ALTER ASSEMBLY [SqlServerClrUdf]
    DROP FILE ALL
	ADD FILE FROM _FARMHASH_SHARP_SQLSERVERCLRUDF_PDB_HEX_
    AS N'SqlServerClrUdf.pdb';
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO
EXEC sys.sp_addextendedproperty 
    @name = N'URL',
    @value = N'https://github.com/alexandre-lecoq/Farmhash.Sharp.SqlServerClrUdf',
    @level0type = N'ASSEMBLY',
    @level0name = N'SqlServerClrUdf'
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [dbo].[Farmhash32]...';
GO
CREATE FUNCTION [dbo].[Farmhash32](@input SQL_VARIANT NULL)
    RETURNS BINARY(4) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[Farmhash32]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [dbo].[StringFarmhash32]...';
GO
CREATE FUNCTION [dbo].[StringFarmhash32](@input NVARCHAR(4000) NULL)
    RETURNS BINARY(4) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[StringFarmhash32]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [dbo].[BinaryFarmhash32]...';
GO
CREATE FUNCTION [dbo].[BinaryFarmhash32](@input VARBINARY(8000) NULL)
    RETURNS BINARY(4) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[BinaryFarmhash32]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------


PRINT N'Creating [dbo].[Farmhash64]...';
GO
CREATE FUNCTION [dbo].[Farmhash64](@input SQL_VARIANT NULL)
    RETURNS BINARY(8) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[Farmhash64]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [dbo].[StringFarmhash64]...';
GO
CREATE FUNCTION [dbo].[StringFarmhash64](@input NVARCHAR(4000) NULL)
    RETURNS BINARY(8) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[StringFarmhash64]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------

PRINT N'Creating [dbo].[BinaryFarmhash64]...';
GO
CREATE FUNCTION [dbo].[BinaryFarmhash64](@input VARBINARY(8000) NULL)
    RETURNS BINARY(8) AS
    EXTERNAL NAME [SqlServerClrUdf].[SqlServerClrUdf.FarmhashFunctions].[BinaryFarmhash64]

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0
    BEGIN
        ROLLBACK;
    END
IF @@TRANCOUNT = 0
    BEGIN
        INSERT  INTO #tmpErrors (Error)
        VALUES                 (1);
        BEGIN TRANSACTION;
    END
GO

-------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT N'The transacted portion of the database update succeeded.'
COMMIT TRANSACTION
END
ELSE PRINT N'The transacted portion of the database update failed.'
GO
DROP TABLE #tmpErrors

-------------------------------------------------------------------------------------------------------------------
GO
