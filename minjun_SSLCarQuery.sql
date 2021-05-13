IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarQuery' AND xtype = 'P')    
    DROP PROC minjun_SSLCarQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-영업차량등록:Query_minjun
 작성일 - '2020-03-18
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml데이터
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- 회사 번호
   ,@LanguageSeq    INT             = 1     -- 언어 번호
   ,@UserSeq        INT             = 0     -- 사용자 번호
   ,@PgmSeq         INT             = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@CarSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @CarSeq       = ISNULL(CarSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (CarSeq       INT)
    
    -- 최종Select
    SELECT  
            A.CarSeq
            ,A.CarNo
            ,A.RegDate
            ,A.CarMngNo
            ,A.Model
            ,A.UMCarType
            ,A.UMOilType
            ,A.Price
            ,C.DeptSeq
            ,C.DeptName
            ,B.EmpSeq
            ,B.EmpName


      FROM  minjun_TSLCar             AS A  WITH(NOLOCK)
             LEFT OUTER JOIN _TDAEmp  AS B    WITH(NOLOCK) ON B.CompanySeq      = A.CompanySeq
                                                         AND B.EmpSeq         = A.EmpSeq
             LEFT OUTER JOIN _TDADept AS C    WITH(NOLOCK) ON C.CompanySeq      = A.CompanySeq
                                                         AND C.Deptseq         = A.Deptseq




     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.CarSeq      = @CarSeq
  
RETURN