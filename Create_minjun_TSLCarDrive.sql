IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TSLCarDrive' AND xtype = 'U' )
    Drop table minjun_TSLCarDrive

CREATE TABLE minjun_TSLCarDrive
(
    CompanySeq		INT 	 NOT NULL, 
    CarSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    DriveDate		NCHAR(8) 	 NULL, 
    Departure		NVARCHAR(100) 	 NULL, 
    Destination		NVARCHAR(100) 	 NULL, 
    Distance		DECIMAL(19,5) 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    Purpose		NVARCHAR(MAX) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_TSLCarDrive PRIMARY KEY CLUSTERED (CompanySeq ASC, CarSeq ASC, Serl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TSLCarDriveLog' AND xtype = 'U' )
    Drop table minjun_TSLCarDriveLog

CREATE TABLE minjun_TSLCarDriveLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    CarSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    DriveDate		NCHAR(8) 	 NULL, 
    Departure		NVARCHAR(100) 	 NULL, 
    Destination		NVARCHAR(100) 	 NULL, 
    Distance		DECIMAL(19,5) 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    Purpose		NVARCHAR(MAX) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TSLCarDriveLog ON minjun_TSLCarDriveLog (LogSeq)
go