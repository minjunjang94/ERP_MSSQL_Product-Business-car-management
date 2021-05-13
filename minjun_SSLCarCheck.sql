IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SSLCarCheck' AND xtype = 'P')    
    DROP PROC minjun_SSLCarCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����������:Check_minjun
 �ۼ��� - '2020-03-18
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SSLCarCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Table Ű�� ��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TSLCar'
           ,@SeqName    = N'CarSeq'
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TSLCar (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#TSLCar' 
    
    IF @@ERROR <> 0 RETURN
    





    -- üũ����
EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,6                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%��%�Է�%'
                           ,@LanguageSeq
                           ,0, '����'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, '��ȣ'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #TSLCar
       SET  Result          = REPLACE(@Results, '@2', M.CarNo)
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #TSLCar     AS M
            JOIN(   SELECT  X.CarName
                      FROM  minjun_TSLCar         AS X   WITH(NOLOCK)
                     WHERE  X.CompanySeq    = @CompanySeq
                       AND  NOT EXISTS( SELECT  1
                                          FROM  #TSLCar
                                         WHERE  WorkingTag IN('U', 'D')
                                           AND  Status = 0
                                           AND  CarSeq     = X.CarSeq)
                    INTERSECT
                    SELECT  Y.CarNo
                      FROM  #TSLCar         AS Y   WITH(NOLOCK)
                     WHERE  Y.WorkingTag IN('A', 'U')
                       AND  Y.Status = 0
                                   )AS A    ON  A.CarNo  = M.CarNo
     WHERE  M.WorkingTag IN('A', 'U')
       AND  M.Status = 0






    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #TSLCar WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- �����ڵ�ä�� : ���̺��� �ý��ۿ��� Max������ �ڵ� ä���� ���� �����Ͽ� ä��
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #TSLCar
           SET  CarSeq = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
        -- �ܺι�ȣ ä���� ���� ���ڰ�
        SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
        
        -- �ܺι�ȣä�� : ������ �ܺ�Ű�������ǵ�� ȭ�鿡�� ���ǵ� ä����Ģ���� ä��
        EXEC dbo._SCOMCreateNo 'HR', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
        
        UPDATE  #TSLCar
           SET  CarMngNo = @MaxNo
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #TSLCar
    
RETURN






