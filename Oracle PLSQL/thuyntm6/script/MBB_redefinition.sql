BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE('MOBR5','MOB_AUDIT_LOGS_HIST',DBMS_REDEFINITION.CONS_USE_ROWID);
END;
/

--------------
CREATE TABLE MOBR5.MOB_AUDIT_LOGS_HIST_INI
(
  ID_ENTITY                  NUMBER(18)         NOT NULL,
  ID_CALLER                  NUMBER(18)         NOT NULL,
  STR_SESSION_ID             VARCHAR2(80 CHAR),
  STR_DEVICE                 VARCHAR2(200 CHAR),
  STR_DEVICE_ID              VARCHAR2(80 CHAR),
  STR_OTHER_DEVICE_ID        VARCHAR2(80 CHAR),
  STR_APPLICATION            VARCHAR2(80 CHAR),
  STR_APPLICATION_VERSION    VARCHAR2(80 CHAR),
  STR_ACTION                 VARCHAR2(80 CHAR)  NOT NULL,
  STR_ACTION_RESULT_CODE     VARCHAR2(80 CHAR),
  INT_DURATION_MILLISECONDS  NUMBER(18),
  STR_ORIGIN                 VARCHAR2(80 CHAR),
  STR_TRACE_NO               VARCHAR2(80 CHAR),
  STR_INSTANCE               VARCHAR2(80 CHAR),
  ID_CATEGORY                VARCHAR2(6 CHAR)   NOT NULL,
  ID_CUSTOMER                NUMBER(18),
  ID_TXN                     NUMBER(18),
  STR_PARAMETER_1            VARCHAR2(80 CHAR),
  STR_PARAMETER_2            VARCHAR2(80 CHAR),
  STR_PARAMETER_3            VARCHAR2(80 CHAR),
  STR_PARAMETER_4            VARCHAR2(80 CHAR),
  STR_PARAMETER_5            VARCHAR2(80 CHAR),
  STR_PARAMETER_6            VARCHAR2(80 CHAR),
  STR_PARAMETER_7            VARCHAR2(80 CHAR),
  STR_PARAMETER_8            VARCHAR2(80 CHAR),
  STR_PARAMETER_9            VARCHAR2(80 CHAR),
  DAT_CREATION               TIMESTAMP(6),
  ID_CUSTOMER_CREATION       NUMBER(18),
  DAT_LAST_UPDATE            TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE    NUMBER(18)
)
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY RANGE (DAT_CREATION)
INTERVAL( NUMTOYMINTERVAL(1,'MONTH'))
(  
  PARTITION AUDIT_P1 VALUES LESS THAN (TIMESTAMP' 2017-05-01 00:00:00')    TABLESPACE USERS
) 	
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

--------------
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE('MOBR5', 'MOB_AUDIT_LOGS_HIST','MOB_AUDIT_LOGS_HIST_INI',
null,dbms_redefinition.CONS_USE_ROWID);
END;
/
--------------
DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('MOBR5', 'MOB_AUDIT_LOGS_HIST','MOB_AUDIT_LOGS_HIST_INI',
   0, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/


select object_name, base_table_name, ddl_txt from       DBA_REDEFINITION_ERRORS;

--------------
BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('MOBR5', 'MOB_AUDIT_LOGS_HIST','MOB_AUDIT_LOGS_HIST_INI');
END;
/


BEGIN
DBMS_REDEFINITION.FINISH_REDEF_TABLE('MOBR5', 'MOB_AUDIT_LOGS_HIST','MOB_AUDIT_LOGS_HIST_INI');
END;
/
-----------
GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO TCB_MBB_DEVL3;

--------------abort
begin 
dbms_redefinition.abort_redef_table('MOBR5', 'MOB_AUDIT_LOGS_HIST','MOB_AUDIT_LOGS_HIST_INI');
