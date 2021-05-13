IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarQuery' AND xtype = 'P')    
    DROP PROC minjun_SSLCarQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����������:Query_minjun
 �ۼ��� - '2020-03-18
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@CarSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @CarSeq       = ISNULL(CarSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (CarSeq       INT)
    
    -- ����Select
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