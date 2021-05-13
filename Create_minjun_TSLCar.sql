IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TSLCar' AND xtype = 'U' )
    Drop table minjun_TSLCar

CREATE TABLE minjun_TSLCar
(
    CompanySeq		INT 	 NOT NULL, 
    CarSeq		INT 	 NOT NULL, 
    CarNo		NVARCHAR(50) 	 NULL, 
    RegDate		NCHAR(8) 	 NULL, 
    CarMngNo		NVARCHAR(50) 	 NULL, 
    Model		NVARCHAR(100) 	 NULL, 
    UMCarType		INT 	 NULL, 
    UMOilType		INT 	 NULL, 
    Price		DECIMAL(19,5) 	 NULL, 
    DeptSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_TSLCar PRIMARY KEY CLUSTERED (CompanySeq ASC, CarSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TSLCarLog' AND xtype = 'U' )
    Drop table minjun_TSLCarLog

CREATE TABLE minjun_TSLCarLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    CarSeq		INT 	 NOT NULL, 
    CarNo		NVARCHAR(50) 	 NULL, 
    RegDate		NCHAR(8) 	 NULL, 
    CarMngNo		NVARCHAR(50) 	 NULL, 
    Model		NVARCHAR(100) 	 NULL, 
    UMCarType		INT 	 NULL, 
    UMOilType		INT 	 NULL, 
    Price		DECIMAL(19,5) 	 NULL, 
    DeptSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TSLCarLog ON minjun_TSLCarLog (LogSeq)
go