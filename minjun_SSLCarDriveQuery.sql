IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarDriveQuery' AND xtype = 'P')    
    DROP PROC minjun_SSLCarDriveQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����������:DriveQuery_minjun
 �ۼ��� - '2020-03-18
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarDriveQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml������
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
   ,@UserSeq        INT            = 0     -- ����� ��ȣ
   ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@CarSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @CarSeq            = ISNULL(CarSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (CarSeq        INT)
    
    -- ����Select
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