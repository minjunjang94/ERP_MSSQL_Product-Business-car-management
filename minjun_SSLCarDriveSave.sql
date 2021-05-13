IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarDriveSave' AND xtype = 'P')    
    DROP PROC minjun_SSLCarDriveSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����������:DriveSave_minjun
 �ۼ��� - '2020-03-18
 �ۼ��� - �����
 ������ -  
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarDriveSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_TSLCarDrive'
           ,@SeqName        = N'CarSeq'
           ,@SerlName       = N'Serl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TSLCarDrive (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#TSLCarDrive' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#TSLCarDrive'       ,		-- �ӽ� ���̺��      
                  'CarSeq, Serl'     ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCarDrive WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #TSLCarDrive               AS M
                JOIN minjun_TSLCarDrive          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.CarSeq      = M.CarSeq
                                                           AND  A.Serl     = M.Serl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCarDrive WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TSLCarDrive 
           SET  
             DriveDate      = M.DriveDate  
            ,Departure      = M.Departure  
            ,Destination    = M.Destination
            ,Distance       = M.Distance   
            ,Amt            = M.Amt        
            ,Purpose        = M.Purpose    
            ,EmpSeq         = M.EmpSeq     
            ,LastUserSeq    = @UserSeq
            ,LastDateTime   = GETDATE()
            ,PgmSeq         = @PgmSeq
            

          FROM  #TSLCarDrive                            AS M
                JOIN minjun_TSLCarDrive          AS A  WITH(NOLOCK)     ON  A.CompanySeq    = @CompanySeq
                                                                        AND  A.CarSeq      = M.CarSeq
                                                                        AND  A.Serl     = M.Serl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCarDrive WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TSLCarDrive (
                CompanySeq
                ,CarSeq
                ,Serl
                ,DriveDate
                ,Departure
                ,Destination
                ,Distance
                ,Amt
                ,Purpose
                ,EmpSeq
                ,LastUserSeq
                ,LastDateTime
                ,PgmSeq
        )
        SELECT  
        @CompanySeq
        ,M.CarSeq
        ,M.Serl
        ,M.DriveDate
        ,M.Departure
        ,M.Destination
        ,M.Distance
        ,M.Amt
        ,M.Purpose
        ,M.EmpSeq
        ,@UserSeq
        ,GETDATE()
        ,@PgmSeq

          FROM  #TSLCarDrive          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #TSLCarDrive
   
RETURN  
 /***************************************************************************************************************/