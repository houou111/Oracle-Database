===================================================================================================
===================================================================================================
===================================================================================================
====================OSB_QUEUE
CREATE TABLE ESBTAX.OSB_QUEUE_INI
(
  LOG_ID       NUMBER                           NOT NULL,
  TRANSTYPE    VARCHAR2(40 BYTE),
  TRANSID      VARCHAR2(40 BYTE)                NOT NULL,
  CHANNEL      VARCHAR2(40 BYTE),
  MESSAGEID    VARCHAR2(40 BYTE),
  STATUS       VARCHAR2(3 BYTE),
  LOGTIME      TIMESTAMP(6),
  CONTENT      CLOB,
  PROCESSTIME  TIMESTAMP(6),
  ERROR_CODE   VARCHAR2(20 BYTE),
  ERROR_MSG    VARCHAR2(200 BYTE)
)
LOB (CONTENT) STORE AS (
  TABLESPACE  ESBTAX
  ENABLE      STORAGE IN ROW
  CHUNK       8192
)
TABLESPACE LOGTBS;

BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE('ESBTAX','OSB_QUEUE',DBMS_REDEFINITION.CONS_USE_PK);
END;
/

alter session force parallel dml parallel 8;
alter session force parallel query parallel 8;


BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE(
   uname        => 'ESBTAX',
   orig_table   => 'OSB_QUEUE',
   int_table    => 'OSB_QUEUE_INI',
   col_mapping  => NULL,
   options_flag => DBMS_REDEFINITION.CONS_USE_ROWID);
END;
/


DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
   uname        => 'ESBTAX',
   orig_table   => 'OSB_QUEUE',
   int_table    => 'OSB_QUEUE_INI',
   copy_indexes   =>TRUE,
   copy_triggers  =>TRUE,
   copy_constraints => TRUE,
   copy_privileges  => TRUE,
   ignore_errors    => FALSE,
   num_errors       => num_errors);
END;
/   

select object_name, base_table_name, ddl_txt from       DBA_REDEFINITION_ERRORS;


BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('ESBTAX', 'OSB_QUEUE', 'OSB_QUEUE_INI');
END;
/


BEGIN
DBMS_REDEFINITION.FINISH_REDEF_TABLE('ESBTAX', 'OSB_QUEUE', 'OSB_QUEUE_INI');
END;
/


-----------Original script

CREATE TABLE ESBTAX.OSB_QUEUE
(
  LOG_ID       NUMBER                           NOT NULL,
  TRANSTYPE    VARCHAR2(40 BYTE),
  TRANSID      VARCHAR2(40 BYTE)                NOT NULL,
  CHANNEL      VARCHAR2(40 BYTE),
  MESSAGEID    VARCHAR2(40 BYTE),
  STATUS       VARCHAR2(3 BYTE),
  LOGTIME      TIMESTAMP(6),
  CONTENT      CLOB,
  PROCESSTIME  TIMESTAMP(6),
  ERROR_CODE   VARCHAR2(20 BYTE),
  ERROR_MSG    VARCHAR2(200 BYTE)
)
LOB (CONTENT) STORE AS (
  TABLESPACE  LOGTBS
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING
      STORAGE    (
                  INITIAL          64K
                  NEXT             1M
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                  BUFFER_POOL      DEFAULT
                  FLASH_CACHE      DEFAULT
                  CELL_FLASH_CACHE DEFAULT
                 ))
TABLESPACE LOGTBS
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
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
ENABLE ROW MOVEMENT;


CREATE UNIQUE INDEX ESBTAX.OSB_QUEUE_PK ON ESBTAX.OSB_QUEUE
(LOG_ID)
LOGGING
TABLESPACE LOGTBS
PCTFREE    10
INITRANS   2
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
NOPARALLEL;


CREATE OR REPLACE TRIGGER ESBTAX.OSB_QUEUE_IN_BF_INS_TRGV1
BEFORE INSERT ON ESBTAX.OSB_QUEUE
FOR EACH ROW
BEGIN
  SELECT QUEUE_IN_SEQ.NEXTVAL
  INTO   :new.LOG_ID
  FROM   dual;
END;
/


ALTER TABLE ESBTAX.OSB_QUEUE ADD (
  CONSTRAINT OSB_QUEUE_PK
  PRIMARY KEY
  (LOG_ID)
  USING INDEX ESBTAX.OSB_QUEUE_PK
  ENABLE VALIDATE);

GRANT SELECT ON ESBTAX.OSB_QUEUE TO CUONGDT_USER;

GRANT SELECT ON ESBTAX.OSB_QUEUE TO ESBDATA_RO;

GRANT INSERT, SELECT ON ESBTAX.OSB_QUEUE TO SRV_ESB_DWH;

GRANT SELECT ON ESBTAX.OSB_QUEUE TO TCB_ESB_APO;


===================================================================================================
===================================================================================================
===================================================================================================
====================OSB_QUEUE_OUT
CREATE TABLE ESBTAX.OSB_QUEUE_OUT_INI
(
  LOG_ID       NUMBER                           NOT NULL,
  TRANSTYPE    VARCHAR2(40 BYTE),
  TRANSID      VARCHAR2(40 BYTE)                NOT NULL,
  CHANNEL      VARCHAR2(40 BYTE),
  MESSAGEID    VARCHAR2(40 BYTE),
  STATUS       VARCHAR2(3 BYTE),
  LOGTIME      TIMESTAMP(6),
  CONTENT      CLOB,
  PROCESSTIME  TIMESTAMP(6),
  ERROR_CODE   VARCHAR2(20 BYTE),
  ERROR_MSG    VARCHAR2(200 BYTE)
)
LOB (CONTENT) STORE AS (
  TABLESPACE  LOGTBS
  ENABLE      STORAGE IN ROW
  CHUNK       8192)
TABLESPACE LOGTBS;

BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE('ESBTAX','OSB_QUEUE_OUT',DBMS_REDEFINITION.CONS_USE_PK);
END;
/

alter session force parallel dml parallel 8;
alter session force parallel query parallel 8;


BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE(
   uname        => 'ESBTAX',
   orig_table   => 'OSB_QUEUE_OUT',
   int_table    => 'OSB_QUEUE_OUT_INI',
   col_mapping  => NULL,
   options_flag => DBMS_REDEFINITION.CONS_USE_ROWID);
END;
/


DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
   uname        => 'ESBTAX',
   orig_table   => 'OSB_QUEUE_OUT',
   int_table    => 'OSB_QUEUE_OUT_INI',
   copy_indexes   =>TRUE,
   copy_triggers  =>TRUE,
   copy_constraints => TRUE,
   copy_privileges  => TRUE,
   ignore_errors    => FALSE,
   num_errors       => num_errors);
END;
/   

select object_name, base_table_name, ddl_txt from       DBA_REDEFINITION_ERRORS;


BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('ESBTAX', 'OSB_QUEUE_OUT', 'OSB_QUEUE_OUT_INI');
END;
/


BEGIN
DBMS_REDEFINITION.FINISH_REDEF_TABLE('ESBTAX', 'OSB_QUEUE_OUT', 'OSB_QUEUE_OUT_INI');
END;
/
-------------------original script
ALTER TABLE ESBTAX.OSB_QUEUE_OUT
 DROP PRIMARY KEY CASCADE;

DROP TABLE ESBTAX.OSB_QUEUE_OUT CASCADE CONSTRAINTS;

CREATE TABLE ESBTAX.OSB_QUEUE_OUT
(
  LOG_ID       NUMBER                           NOT NULL,
  TRANSTYPE    VARCHAR2(40 BYTE),
  TRANSID      VARCHAR2(40 BYTE)                NOT NULL,
  CHANNEL      VARCHAR2(40 BYTE),
  MESSAGEID    VARCHAR2(40 BYTE),
  STATUS       VARCHAR2(3 BYTE),
  LOGTIME      TIMESTAMP(6),
  CONTENT      CLOB,
  PROCESSTIME  TIMESTAMP(6),
  ERROR_CODE   VARCHAR2(20 BYTE),
  ERROR_MSG    VARCHAR2(200 BYTE)
)
LOB (CONTENT) STORE AS (
  TABLESPACE  LOGTBS
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING
      STORAGE    (
                  INITIAL          64K
                  NEXT             1M
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                  BUFFER_POOL      DEFAULT
                  FLASH_CACHE      DEFAULT
                  CELL_FLASH_CACHE DEFAULT
                 ))
TABLESPACE LOGTBS
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
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
ENABLE ROW MOVEMENT;


CREATE UNIQUE INDEX ESBTAX.OSB_QUEUE_OUT_PK ON ESBTAX.OSB_QUEUE_OUT
(LOG_ID)
LOGGING
TABLESPACE LOGTBS
PCTFREE    10
INITRANS   2
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
NOPARALLEL;


CREATE OR REPLACE TRIGGER ESBTAX.OSB_QUEUE_OUT_BF_INS_TRGV1
BEFORE INSERT ON ESBTAX.OSB_QUEUE_OUT
FOR EACH ROW
BEGIN
  SELECT QUEUE_OUT_SEQ.NEXTVAL
  INTO   :new.LOG_ID
  FROM   dual;
END;
/


ALTER TABLE ESBTAX.OSB_QUEUE_OUT ADD (
  CONSTRAINT OSB_QUEUE_OUT_PK
  PRIMARY KEY
  (LOG_ID)
  USING INDEX ESBTAX.OSB_QUEUE_OUT_PK
  ENABLE VALIDATE);

GRANT SELECT ON ESBTAX.OSB_QUEUE_OUT TO CUONGDT_USER;

GRANT SELECT ON ESBTAX.OSB_QUEUE_OUT TO ESBDATA_RO;

GRANT SELECT ON ESBTAX.OSB_QUEUE_OUT TO SRV_ESB_DWH;

GRANT SELECT ON ESBTAX.OSB_QUEUE_OUT TO TCB_ESB_APO;
