IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarSave' AND xtype = 'P')    
    DROP PROC minjun_SSLCarSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����������:Save_minjun
 �ۼ��� - '2020-03-18
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarSave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- ��Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_TSLCar'
           ,@ItemTblName    = N'minjun_TSLCarDrive'
           ,@SeqName        = N'CarSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TSLCar (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#TSLCar' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#TSLCar'    ,		-- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCar WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#TSLCar'       ,		-- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #TSLCar          AS M
                JOIN minjun_TSLCarDrive      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.CarSeq      = M.CarSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
        
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #TSLCar          AS M
                JOIN minjun_TSLCar          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.CarSeq      = M.CarSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCar WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET  
                CarNo           = M.CarNo     
                ,RegDate        = M.RegDate  
                ,CarMngNo       = M.CarMngNo 
                ,Model          = M.Model    
                ,UMCarType      = M.UMCarType
                ,UMOilType      = M.UMOilType
                ,Price          = M.Price    
                ,DeptSeq        = M.DeptSeq  
                ,EmpSeq         = M.EmpSeq   
                ,LastUserSeq    = @UserSeq
                ,LastDateTime   = GETDATE()
                ,PgmSeq         = @PgmSeq

          FROM  #TSLCar                     AS M
                JOIN minjun_TSLCar          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                AND  A.CarSeq      = M.CarSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TSLCar WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TSLCar (
             CompanySeq
            ,CarSeq
            ,CarNo
            ,RegDate
            ,CarMngNo
            ,Model
            ,UMCarType
            ,UMOilType
            ,Price
            ,DeptSeq
            ,EmpSeq
            ,LastUserSeq
            ,LastDateTime
            ,PgmSeq
        )
        SELECT  
         @CompanySeq
        ,M.CarSeq
        ,M.CarNo
        ,M.RegDate
        ,M.CarMngNo
        ,M.Model
        ,M.UMCarType
        ,M.UMOilType
        ,M.Price
        ,M.DeptSeq
        ,M.EmpSeq
        ,@UserSeq
        ,GETDATE()
        ,@PgmSeq

          FROM  #TSLCar          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #TSLCar
   
RETURN