select JOB_NAME,JOB_TYPE,JOB_ACTION,START_DATE,REPEAT_INTERVAL,ENABLED,RUN_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE,LOGGING_LEVEL
from DBA_SCHEDULER_JOBS

BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'G2FO.AUTO_GATHER_BIG_TABLE');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'G2FO.AUTO_GATHER_BIG_TABLE'
      ,start_date      => TO_TIMESTAMP_TZ('2018/01/08 18:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm')
      ,repeat_interval => 'FREQ=DAILY;BYHOUR=17;BYMINUTE=30'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'Begin
DBMS_STATS.gather_table_stats(''G2FO'', ''ORDER_HDR''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''ORDER_TRADED_DTL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''ORDER_QTY_DTL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''AUDIT_ORDER_HDR''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_STOCK_BAL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_CASH_BAL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''AUDIT_ORDER_QTY_DTL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_CASH_SUM''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_STOCK_SUM''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_INFO''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''CLIENT_TRADE_ACCT''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''ORDER_HDR_HIST''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''ORDER_QTY_DTL_HIST''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
DBMS_STATS.gather_table_stats(''G2FO'', ''AUDIT_ORDER_TRADED_DTL''  ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE ,GRANULARITY => ''AUTO'',CASCADE => TRUE,degree => 8,force=>true);
END;'
      ,comments        => 'auto gather big table statistic'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'G2FO.AUTO_GATHER_BIG_TABLE'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'G2FO.AUTO_GATHER_BIG_TABLE');
END;
/
