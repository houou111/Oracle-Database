set serveroutput on
set lines 300
set pages 300

DECLARE
   cmd           VARCHAR2 (4000);
   cmd2           VARCHAR2 (4000);
   TBS	 VARCHAR2 (4000):='EDW_DMT_TBS';
   CURSOR c_partitions
   IS
		SELECT distinct table_name
        FROM dba_tab_partitions a, dba_users b
        WHERE tablespace_name = 'EDW_DMT_TBS'
        AND a.TABLE_OWNER = b.USERNAME
        AND table_name in ('AR_BHVR_ANL_FCT','CST_INSIGHT_ANL_FCT','R_TBL_DW_CA_0004_PH_THE','AR_BHVR_ANL_FCT_TXN','R_TBL_CU_0005_TRUNG_KH','FTP_ANL_FCT','R_TBL_AC_0019','R_TBL_PST_ENTR_SMY','R_TBL_AC_0017','AR_ST_ANL_FCT','R_TBL_STMT_SMY','CST_CNL_ANL_FCT','RPT_SOPHU_KTTH','R_TBL_FI_0010_SKTKGL','R_TBL_DS_0004_DLC_MM','TBL_SSP_SUMMARY_FACT','KDR_PL_FCT','TXN_DIM','MV_AR_DIM_X_ADJ_FNC_ST','PFT_ANL_FCT','R_TBL_DS_0006','CMP3$837653625','R_TBL_AC_0016_THSP_TCB','CNL_TXN_ANL_FCT','SALE_PERF_ANL_FCT','BSH_ANL_FCT','TMP_FTP_ANL_FCT_201712','PFS_CLV_CUS_PD_BL_MO');

BEGIN
   FOR cc IN c_partitions
   LOOP
		cmd := 'SELECT * FROM ( SELECT table_name,PARTITION_NAME FROM dba_tab_partitions a, dba_users b  WHERE  tablespace_name = '''||TBS||''' AND a.TABLE_OWNER = b.USERNAME AND a.table_name ='''|| cc.table_name||''' AND ROWNUM <= 3 ORDER BY table_name,partition_name);';
		DBMS_OUTPUT.put_line (cmd);
		--execute immediate cmd into cmd2;
		--DBMS_OUTPUT.put_line (cmd2);
   END LOOP;
END;
/


set serveroutput on
set lines 300
set pages 300
DECLARE
   cmd         VARCHAR2 (4000);
   cmd2        VARCHAR2 (4000);
   my_cursor   SYS_REFCURSOR;

   CURSOR c_partitions
   IS
      SELECT DISTINCT table_owner, table_name, tablespace_name
        FROM dba_tab_partitions
       WHERE     tablespace_name = 'EDW_SOR_TBS'
             AND table_name IN ('AR_TVR_SMY','AU_SMY','FTP_SMY','PST_ENTR','AU_BAL','ACS_FCY_TVR_SMY','TXN','TXN_TTT','AR_X_TXN','AR_INT_SMY','AR_AVY_SMY','KDR_SCR_SMY','AR_X_CL');
BEGIN
   FOR cc IN c_partitions
   LOOP
       FOR cmd IN (SELECT * FROM ( SELECT PARTITION_NAME FROM dba_tab_partitions a, dba_users b  WHERE  tablespace_name =
          cc.tablespace_name AND a.TABLE_OWNER = b.USERNAME AND a.table_name = cc.table_name ORDER BY table_name,partition_position desc) where rownum<4)
        loop
        DBMS_OUTPUT.put_line (cc.table_owner||'.'||cc.table_name||':'||cmd.PARTITION_NAME);
       end loop;
   END LOOP;
END;
/


