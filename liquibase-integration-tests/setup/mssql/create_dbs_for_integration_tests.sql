
/*
 * WARNING: By default, new installations of Microsoft SQL Server only listen to named pipes. The default JDBC
 * connection string for the integration tests expect it to listen on the default TCP port 1433. Please use the
 * "SQL Server Configuration Manager" tool to enable TCP/IP on "SQL Server Network Configuration" ->
 * Protocols for MSSQLSERVER. You do not need to enable it for all network interfaces; localhost (127.0.0.1) is
 * sufficient for the tests.
 *
 * WARNING: You will probably want to adjust the path for the data files in the following script.
 */

USE [master]
GO

/* Tear down everything before creating the objects */
IF EXISTS(SELECT name
          FROM master.sys.databases
          WHERE name = N'liquibase')
  BEGIN
    ALTER DATABASE [liquibase] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [liquibase];
  END
GO

IF EXISTS(SELECT name
          FROM master.sys.databases
          WHERE name = N'liquibasec')
  BEGIN
    ALTER DATABASE [liquibasec] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [liquibasec];
  END
GO

IF EXISTS(SELECT name
          FROM master.sys.syslogins
          WHERE syslogins.name = N'lbuser')
  DROP LOGIN [lbuser]
GO

CREATE DATABASE [liquibase]
 ON  PRIMARY 
( NAME = N'liquibase', FILENAME = N'D:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\liquibase.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'liquibase_log', FILENAME = N'D:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\liquibase_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [liquibase] SET COMPATIBILITY_LEVEL = 100
GO

USE [liquibase]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [liquibase] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
ALTER DATABASE [liquibase] ADD FILEGROUP [liquibase2]
GO
ALTER DATABASE [liquibase] ADD FILE ( NAME = N'liquibase2', FILENAME = N'D:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\liquibase2.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [liquibase2]
GO

CREATE SCHEMA [lbcat2] AUTHORIZATION [dbo]
GO

/* Create a role for the liquibase database that will allow members to create and modify objects on the default (dbo)
 * and the additional (lbcat2) schema.
 */
CREATE ROLE [Application_Schema_Installation] AUTHORIZATION [dbo]
GO

GRANT ALTER ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT CREATE SEQUENCE ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT CONTROL ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT SELECT ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT DELETE ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT INSERT ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT SELECT ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT UPDATE ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO
GRANT REFERENCES ON SCHEMA ::[dbo] TO [Application_Schema_Installation]
GO

GRANT ALTER ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT CREATE SEQUENCE ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT CONTROL ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT SELECT ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT DELETE ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT INSERT ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT SELECT ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT UPDATE ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO
GRANT REFERENCES ON SCHEMA ::[lbcat2] TO [Application_Schema_Installation]
GO

/* Allow members of this role to create tables and views. */
GRANT CREATE TABLE TO [Application_Schema_Installation]
GO
GRANT CREATE VIEW TO [Application_Schema_Installation]
GO

USE [master]
GO
CREATE LOGIN [lbuser] WITH PASSWORD=N'lbuser', DEFAULT_DATABASE=[liquibase], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [liquibase]
GO

CREATE USER [lbuser] FOR LOGIN [lbuser]
GO

--ensure role membership is correct
EXEC sp_addrolemember N'Application_Schema_Installation', N'lbuser'
GO
--Allow user to connect to database
GRANT CONNECT TO [lbuser]

USE [master]
GO

CREATE DATABASE [liquibasec]
 ON  PRIMARY
( NAME = N'liquibasec', FILENAME = N'D:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\liquibasec.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON
( NAME = N'liquibasec_log', FILENAME = N'D:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\liquibasec_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [liquibasec] SET COMPATIBILITY_LEVEL = 100
GO

USE [liquibasec]
GO

CREATE SCHEMA [liquibaseb] AUTHORIZATION [dbo]
GO

CREATE USER [lbuser] FOR LOGIN [lbuser]
GO
GRANT CONNECT TO [lbuser]

USE [master]
-- DONE.
