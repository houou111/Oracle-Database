BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'G2FO.AUTO_GATHER_TOP_TABLE');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'G2FO.AUTO_GATHER_TOP_TABLE'
      ,start_date      => TO_TIMESTAMP_TZ('2021/12/08 12:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm')
      ,repeat_interval => 'freq=minutely; byhour=8,9,18; byminute=55'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'DECLARE     
cmd    VARCHAR2 (4000);
 CURSOR broken_jobs_cur     
 IS     
select owner,table_name from dba_tables where table_name in (''CLIENT_STOCK_BAL'',''CLIENT_CASH_BAL'',''FIXIN_MESSAGES'' , ''FIXIN_REPLY_MSG'' , ''FIXIN_SESSIONS'',''DX_MSG_HIST'',''CLIENT_CASH_SUM'',''CLIENT_STOCK_SUM'',''UPCOM_PREOUT_MESSAGES'',''UPCOM_IN_MESSAGES'',''UPCOM_RSA'',''UPCOM_DMA_ADVERTISEMENT'',''UPCOM_MESSAGES'',''UPCOM_SESSIONS'',''SUSPECT_SAME_ORDER_LIST'',''DMA_ORDER_OSN_MAP'',''DMA_HOSE_INMSG'',''DMA_HOSE_PROCESSED_INMSG'',''DMA_HOSE_MKT_SESSION'',''DMA_MSG_GA'',''DMA_ADVERTISEMENT'',''DMA_MSG_HISTORY'',''ORDER_EXCHG_REPLY'',''ORDER_TRADED_DTL'',''ORDER_QTY_DTL'',''ORDER_INSTRUCTION'',''DX_MASTER'',''MKT_INSTRUMENT'',''MARKET'',''RISK_GRP_STOCK_MARGIN''
,''NEW_SSI_SALES_NODE_PATH_DEF'',''ORDER_HOLD_CASH'',''HNX_MESSAGES'',''USER_LOGIN_SESSION'',''SYS_PARA'',''HNX_IN_MESSAGES'',''HNX_PREOUT_MESSAGES''
,''HNX_DCTERM_ORDER'',''HNX_DCTERM_TRADE'',''HNX_DMA_ADVERTISEMENT'',''HNX_DMA_CHANNEL_SORTING'',''HNX_FIRM_INFO'',''HNX_NEWS'',''HNX_RSA'',''HNX_SESSIONS''
,''USER_CLIENT_GRP_DEF'',''EXCHANGE'',''ORDER_NOTES'',''CLIENTHOTLIST'',''USER_APPROV_ORDER_RECORD'',''CUSTOMER_INFO'',''ORDER_HDR'',''SYS_EXCHG_TIME_GAP'') and owner=''G2FO'';        
BEGIN       
 FOR job_rec IN broken_jobs_cur     
 LOOP       
  cmd :=''BEGIN DBMS_STATS.gather_table_stats(OwnName =>''''''||job_rec.OWNER||'''''',TabName =>''''''||job_rec.table_name||'''''',GRANULARITY => ''''AUTO'''',estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,degree =>16,CASCADE => TRUE,force=>true); END;'';
execute immediate cmd;
 
 END LOOP; 
     
END; 
'
      ,comments        => 'auto gather top table statistic'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_TOP_TABLE'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'G2FO.AUTO_GATHER_TOP_TABLE');
END;
/
