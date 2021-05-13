IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarDriveQuery' AND xtype = 'P')    
    DROP PROC minjun_SSLCarDriveQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-영업차량등록:DriveQuery_minjun
 작성일 - '2020-03-18
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarDriveQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- 회사 번호
   ,@LanguageSeq    INT            = 1     -- 언어 번호
   ,@UserSeq        INT            = 0     -- 사용자 번호
   ,@PgmSeq         INT            = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@CarSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @CarSeq            = ISNULL(CarSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (CarSeq        INT)
    
    -- 최종Select
    SELECT   
            B.Serl
            ,B.CarSeq
            ,B.DriveDate
            ,B.Departure
            ,B.Destination
            ,B.Distance
            ,B.Amt
            ,B.Purpose
            ,C.EmpSeq
            ,C.EmpName
      FROM  minjun_TSLCar                   AS  A  WITH(NOLOCK)
            JOIN minjun_TSLCarDrive         AS  B   WITH(NOLOCK) ON B.CompanySeq        = A.CompanySeq
                                                                AND B.CarSeq           = A.CarSeq
            LEFT OUTER JOIN _TDAEmp         AS  C   WITH(NOLOCK) ON C.CompanySeq        = B.CompanySeq
                                                                AND C.EmpSeq            = B.EmpSeq


     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.CarSeq        = @CarSeq
  
RETURN