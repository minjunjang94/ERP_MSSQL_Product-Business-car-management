IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarListQuery' AND xtype = 'P')    
    DROP PROC minjun_SSLCarListQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-영업차량조회_minjun
 작성일 - '2020-03-18
 작성자 - 장민준
 수정자 -  
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarListQuery
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
    DECLARE @docHandle                  INT
           ,@RegDateFr                  NCHAR(8)
           ,@RegDateTo                  NCHAR(8)
           ,@EmpSeq                     INT
           ,@DeptSeq                    INT
           ,@CarNo                      nvarchar(100)
           ,@CarMngNo                   nvarchar(100)
           ,@Model                      nvarchar(200)
           ,@UMCarType                  INT
           ,@UMOilType                  INT


    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  
             @RegDateFr                = RTRIM(LTRIM(ISNULL(RegDateFr     , '')))
            ,@RegDateTo                = RTRIM(LTRIM(ISNULL(RegDateTo     , '')))
            ,@EmpSeq                   = RTRIM(LTRIM(ISNULL(EmpSeq        , 0 )))
            ,@DeptSeq                  = RTRIM(LTRIM(ISNULL(DeptSeq       , 0 )))
            ,@CarNo                    = RTRIM(LTRIM(ISNULL(CarNo         , '')))
            ,@CarMngNo                 = RTRIM(LTRIM(ISNULL(CarMngNo      , '')))
            ,@Model                    = RTRIM(LTRIM(ISNULL(Model         , '')))
            ,@UMCarType                = RTRIM(LTRIM(ISNULL(UMCarType     , '')))
            ,@UMOilType                = RTRIM(LTRIM(ISNULL(UMOilType     , '')))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)

      WITH (   
      docHandle                  INT
      ,RegDateFr                  NCHAR(8)
      ,RegDateTo                  NCHAR(8)
      ,EmpSeq                     INT
      ,DeptSeq                    INT
      ,CarNo                      nvarchar(100)
      ,CarMngNo                   nvarchar(100)
      ,Model                      nvarchar(200)
      ,UMCarType                  INT
      ,UMOilType                  INT
      )

      IF @RegDateFr = '' SET @RegDateFr = '19000101'
      IF @RegDateTo = '' SET @RegDateTo = '99991231'



    
    -- 최종Select
    SELECT  
            A.CarNo
            , A.RegDate
            , A.CarMngNo
            , A.CarSeq
            , A.Model
            , A.UMCarType
            , E.MinorName       AS UMCarTypeName
            , A.UMOilType
            , F.MinorName       AS UMOilTypeName
            , C.DeptName
            , C.DeptSeq
            , B.EmpName
            , B.EmpSeq
            , D.TotDistance
            , D.TotAmt


      FROM  minjun_TSLCar               AS A  WITH(NOLOCK)
            LEFT OUTER JOIN _TDAEmp AS B     WITH(NOLOCK)    ON B.CompanySeq      = A.CompanySeq
                                                            AND B.EmpSeq         = A.EmpSeq
            LEFT OUTER JOIN _TDADept AS C    WITH(NOLOCK)    ON C.CompanySeq      = A.CompanySeq
                                                            AND C.Deptseq         = A.Deptseq

            LEFT OUTER JOIN(select x.CompanySeq
                                , x.CarSeq
                                , sum(x.Distance)   as TotDistance
                                , sum(x.Amt)        as TotAmt
                                from minjun_TSLCarDrive  as X with(nolock)
                                group by X.CompanySeq, X.CarSeq
                                ) AS D       
                                ON  D.CompanySeq        = A.CompanySeq  
                                AND D.CarSeq            = A.CarSeq

            LEFT OUTER JOIN _TDAUMinor        AS E    WITH(NOLOCK)    ON  E.CompanySeq     = A.CompanySeq
                                                                     AND  E.MinorSeq       = A.UMCarType
            LEFT OUTER JOIN _TDAUMinor        AS F    WITH(NOLOCK)    ON  F.CompanySeq  = A.CompanySeq
                                                                     AND  F.MinorSeq       = A.UMOilType
           

                                                                
     WHERE  A.CompanySeq    =  @CompanySeq
       AND A.RegDate BETWEEN @RegDateFr And @RegDateTo
       AND (@EmpSeq     =0          OR  B.EmpSeq            = @EmpSeq      )      
       AND (@DeptSeq    =0          OR  C.DeptSeq           = @DeptSeq     )  
       AND (@Model      =''         OR  A.Model             LIKE @Model         + '%'  ) 
       AND (@CarMngNo   =''         OR  A.CarMngNo          LIKE @CarMngNo      + '%'  ) 
       AND (@UMCarType  =0          OR  A.UMCarType         = @UMCarType   ) 
       AND (@UMOilType  =0          OR  A.UMOilType         = @UMOilType   ) 
       AND (@CarNo      =''         OR  A.CarNo             LIKE @CarNo         + '%'  )
  
RETURN

select * from minjun_TSLCar