CREATE TABLE MOBR5.MOB_TXNS_HIST
(
  ID_TXN                    NUMBER(18),
  BOL_IS_CANCELLED          CHAR(1 BYTE),
  ID_PAYER                  NUMBER(18),
  ID_PAYER_PI               NUMBER(18),
  ID_PAYEE                  NUMBER(18),
  ID_PAYEE_PI               NUMBER(18),
  ID_CURRENCY               CHAR(3 BYTE),
  STR_TEXT                  VARCHAR2(255 CHAR),
  DAT_MERCHANT_TIMESTAMP    TIMESTAMP(6),
  STR_MERCHANT_ORDER_ID     VARCHAR2(80 CHAR),
  DAT_EXPIRATION            TIMESTAMP(6),
  ID_AUTH_METHOD_PAYER      NUMBER(5),
  AMNT_AMOUNT               NUMBER(18),
  BOL_IS_AUTOCAPTURE        CHAR(1 BYTE),
  ID_USE_CASE               NUMBER(5),
  ID_AUTH_METHOD_PAYEE      NUMBER(5),
  ID_TXN_STATUS             NUMBER(5),
  ID_ERROR_CODE             NUMBER(5),
  STR_AUTHORISATION_CODE    VARCHAR2(6 CHAR),
  BOL_IS_TEST               CHAR(1 BYTE),
  ID_REF_TXN                NUMBER(18),
  ID_ORDER_CHANNEL          NUMBER(5),
  BOL_IS_LOCKED             CHAR(1 BYTE),
  STR_PAYEE_IDENTIFICATION  VARCHAR2(80 CHAR),
  STR_PAYER_IDENTIFICATION  VARCHAR2(80 CHAR),
  BOL_REQ_DELIVERY_ADDRESS  CHAR(1 BYTE),
  STR_SPARE_1               VARCHAR2(80 CHAR),
  STR_SPARE_2               VARCHAR2(80 CHAR),
  STR_SPARE_3               VARCHAR2(80 CHAR),
  STR_SPARE_4               VARCHAR2(80 CHAR),
  STR_SPARE_5               VARCHAR2(80 CHAR),
  STR_SPARE_6               VARCHAR2(80 CHAR),
  STR_SPARE_7               VARCHAR2(80 CHAR),
  STR_SPARE_8               VARCHAR2(80 CHAR),
  STR_SPARE_9               VARCHAR2(80 CHAR),
  STR_SPARE_10              VARCHAR2(80 CHAR),
  DAT_SPARE_1               TIMESTAMP(6),
  DAT_SPARE_2               TIMESTAMP(6),
  DAT_SPARE_3               TIMESTAMP(6),
  DAT_SPARE_4               TIMESTAMP(6),
  DAT_SPARE_5               TIMESTAMP(6),
  INT_SPARE_1               NUMBER(18),
  INT_SPARE_2               NUMBER(18),
  INT_SPARE_3               NUMBER(18),
  INT_SPARE_4               NUMBER(18),
  INT_SPARE_5               NUMBER(18),
  BOL_SPARE_1               CHAR(1 BYTE),
  BOL_SPARE_2               CHAR(1 BYTE),
  BOL_SPARE_3               CHAR(1 BYTE),
  BOL_SPARE_4               CHAR(1 BYTE),
  BOL_SPARE_5               CHAR(1 BYTE),
  CLOB_SPARE_1              CLOB,
  DAT_CREATION              TIMESTAMP(6),
  ID_CUSTOMER_CREATION      NUMBER(18),
  DAT_LAST_UPDATE           TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE   NUMBER(18)
)
LOB (CLOB_SPARE_1) STORE AS (
  TABLESPACE  MOBR5
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
TABLESPACE MOBR5
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
MONITORING;


CREATE INDEX MOBR5.IDX_TXNS_HIST_ERROR_LOCKED ON MOBR5.MOB_TXNS_HIST
(ID_ERROR_CODE, BOL_IS_LOCKED)
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_TXNS_HIST_MERCHANTID ON MOBR5.MOB_TXNS_HIST
(STR_MERCHANT_ORDER_ID)
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_TXNS_HIST_MERCHANTID_UPPER ON MOBR5.MOB_TXNS_HIST
(UPPER("STR_MERCHANT_ORDER_ID"))
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_TXNS_HIST_PAYEE ON MOBR5.MOB_TXNS_HIST
(ID_PAYEE)
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_TXNS_HIST_PAYER ON MOBR5.MOB_TXNS_HIST
(ID_PAYER)
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_TXNS_HIST_STATUS_ERROR ON MOBR5.MOB_TXNS_HIST
(ID_TXN_STATUS, ID_ERROR_CODE)
LOGGING
TABLESPACE MOBR5
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


CREATE UNIQUE INDEX MOBR5.PK_TXNS2_HIST ON MOBR5.MOB_TXNS_HIST
(ID_TXN)
LOGGING
TABLESPACE MOBR5
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


ALTER TABLE MOBR5.MOB_TXNS_HIST ADD (
  CHECK ("ID_TXN" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("BOL_IS_CANCELLED" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_CURRENCY" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("BOL_IS_AUTOCAPTURE" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_USE_CASE" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_TXN_STATUS" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_ERROR_CODE" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("BOL_IS_TEST" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("BOL_IS_LOCKED" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("BOL_REQ_DELIVERY_ADDRESS" IS NOT NULL)
  ENABLE NOVALIDATE,
  CONSTRAINT PK_TXNS2_HIST
  PRIMARY KEY
  (ID_TXN)
  USING INDEX MOBR5.PK_TXNS2_HIST
  ENABLE NOVALIDATE);


GRANT SELECT ON MOBR5.MOB_TXNS_HIST TO SRV_DWH_MBB;

GRANT SELECT ON MOBR5.MOB_TXNS_HIST TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_TXNS_HIST TO TCB_MBB_DEVL3;
--===================
CREATE TABLE MOBR5.MOB_SUB_TXNS_HIST
(
  ID_SUB_TXN                  NUMBER(18),
  AMNT_AMOUNT                 NUMBER(18),
  STR_PAYER_PI_TXN_REFERENCE  VARCHAR2(80 CHAR),
  DAT_PAYER_PI_TIMESTAMP      TIMESTAMP(6),
  STR_PAYEE_PI_TXN_REFERENCE  VARCHAR2(80 CHAR),
  DAT_PAYEE_PI_TIMESTAMP      TIMESTAMP(6),
  AMNT_VAT                    NUMBER(18),
  AMNT_PAYER_PI_BALANCE       NUMBER(18),
  AMNT_PAYEE_PI_BALANCE       NUMBER(18),
  AMNT_EXCHANGE_RATE_PAYEE    NUMBER(38,19),
  AMNT_EXCHANGE_RATE_PAYER    NUMBER(38,19),
  ID_SUB_TXN_TYPE             NUMBER(5),
  ID_TXN                      NUMBER(18),
  ID_ERROR_CODE               NUMBER(5),
  STR_ORIGIN                  VARCHAR2(80 CHAR),
  STR_TRACE_NUMBER            VARCHAR2(80 CHAR),
  ID_CALLER                   NUMBER(18),
  ID_PAYMENT_PAYER            NUMBER(18),
  ID_PAYMENT_PAYEE            NUMBER(18),
  STR_CALLER_IDENTIFICATION   VARCHAR2(80 CHAR),
  STR_CALLBACK_URL            VARCHAR2(200 CHAR),
  STR_RETURN_URL              VARCHAR2(2048 CHAR),
  ID_CALLBACK_STATUS          NUMBER(5),
  DAT_CREATION                TIMESTAMP(6),
  ID_CUSTOMER_CREATION        NUMBER(18),
  DAT_LAST_UPDATE             TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE     NUMBER(18)
)
TABLESPACE MOBR5
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
MONITORING;


CREATE INDEX MOBR5.IDX_SUB_TXNS_HIST ON MOBR5.MOB_SUB_TXNS_HIST
(ID_SUB_TXN_TYPE, ID_TXN)
LOGGING
TABLESPACE MOBR5
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


CREATE INDEX MOBR5.IDX_SUB_TXNS_HIST_IDTXN ON MOBR5.MOB_SUB_TXNS_HIST
(ID_TXN)
LOGGING
TABLESPACE MOBR5
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


CREATE UNIQUE INDEX MOBR5.PK_SUB_TXNS_HIST ON MOBR5.MOB_SUB_TXNS_HIST
(ID_SUB_TXN)
LOGGING
TABLESPACE MOBR5
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


ALTER TABLE MOBR5.MOB_SUB_TXNS_HIST ADD (
  CHECK ("ID_SUB_TXN" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("AMNT_AMOUNT" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("AMNT_EXCHANGE_RATE_PAYEE" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("AMNT_EXCHANGE_RATE_PAYER" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_ERROR_CODE" IS NOT NULL)
  ENABLE NOVALIDATE,
  CHECK ("ID_CALLBACK_STATUS" IS NOT NULL)
  ENABLE NOVALIDATE,
  CONSTRAINT PK_SUB_TXNS_HIST
  PRIMARY KEY
  (ID_SUB_TXN)
  USING INDEX MOBR5.PK_SUB_TXNS_HIST
  ENABLE NOVALIDATE);

GRANT SELECT ON MOBR5.MOB_SUB_TXNS_HIST TO SRV_DWH_MBB;

GRANT SELECT ON MOBR5.MOB_SUB_TXNS_HIST TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_SUB_TXNS_HIST TO TCB_MBB_DEVL3;


=====
CREATE TABLE MOBR5.TABLE_ARCHIVE
(
  TAB_ID          INTEGER                       NOT NULL,
  TABLE_NAME      VARCHAR2(150 BYTE)            NOT NULL,
  TABLE_NAME_HIST VARCHAR2(150 BYTE)            ,
  TAB_TYPE        NUMBER                        NOT NULL,
  PRE_CONDITION   VARCHAR2(100 BYTE),
  DEL_RANGE       VARCHAR2(4 BYTE),
  ADD_CONDITION   VARCHAR2(100 BYTE)
);

create table mobr5.TABLE_ARCHIVE_LOG
(
  TABLE_NAME    VARCHAR2(150 BYTE),
  OPERATION VARCHAR2(10 BYTE),
  START_TIME    DATE,
  NUMROW    NUMBER,
  ELAPSED_TIME  VARCHAR2(50 BYTE)
);


create table mobr5.REBUILD_IDX_LOG
(
  TABLE_NAME    VARCHAR2(50 BYTE),
  INDEX_NAME    VARCHAR2(50 BYTE),
  START_TIME    DATE,
  ELAPSED_TIME  VARCHAR2(50 BYTE),
  PRE_SIZE      NUMBER,
  POST_SIZE     NUMBER,
  START_SEQ     NUMBER,
  END_SEQ       NUMBER
);

SET DEFINE OFF;
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values  (1, 'EVT_ENTRY_HANDLER', 1, ' where dat_creation <', '30');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values   (2, 'EVT_ENTRY', 1, ' where dat_creation <', '30');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values   (3, 'MOB_SESSIONS', 1, ' where dat_creation <', '30');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values   (4, 'MOB_TRACEABLE_REQUESTS', 1, ' where dat_creation <', '30');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (5, 'MOB_FEES', 'MOB_FEES_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (6, 'MOB_TXN_ATTRIBUTES', 'MOB_TXN_ATTRIBUTES_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (7, 'AMS_PI_BALANCES', 'AMS_PI_BALANCES_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (8, 'MOB_INV_TXNS', 'MOB_INV_TXNS_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (9, 'AMS_DOCS', 'AMS_DOCS_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (10, 'MOB_AUDIT_LOGS', 'MOB_AUDIT_LOGS_HIST', 2, ' where dat_creation <',     '30');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (11, 'AMS_BOOKINGS', 'AMS_BOOKINGS_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (12, 'TCB_PUBLIC_INBOX_CUSTOMER_READ', 'TCB_PUBLIC_INBOX_CUSTOMER_READ_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (13, 'TCB_PRIVATE_INBOX', 'TCB_PRIVATE_INBOX_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (14, 'TCB_PUBLIC_INBOX', 'TCB_PUBLIC_INBOX_HIST', 2, ' where dat_creation <',     '366');
Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (15, 'MOB_SUB_TXNS', 'MOB_SUB_TXNS_HIST', 3, ' where id_sub_txn <',     '366');
 Insert into MOBR5.TABLE_ARCHIVE   (tab_id, table_name, table_name_hist, tab_type, pre_condition,     del_range)
 Values   (16, 'MOB_TXNS', 'MOB_TXNS_HIST', 3, ' where id_txn < ',     '366');
COMMIT;





/* Formatted on 4/27/2019 9:19:03 AM (QP5 v5.252.13127.32847) */
DECLARE
   delete_cmd     VARCHAR2 (4000);
   delete_cmd1    VARCHAR2 (4000);
   insert_cmd     VARCHAR2 (4000);
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   DURATION       NUMBER;
   post_rebuild   NUMBER;
   pre_rebuild    NUMBER;
   Del_val        NUMBER;
   sys_date date;
   sys_date3 date;

   CURSOR c_tab
   IS
        SELECT table_name,
               table_name_hist,
               tab_type,
               pre_condition,
               del_range,
               add_condition
          FROM mobr5.table_archive
      ORDER BY tab_id;
BEGIN
   delete_cmd1 := 'DELETE FROM MOBR5.EVT_ENTRY_DATA where ID in (select ID from MOBR5.EVT_ENTRY_HANDLER where DAT_CREATION <= to_date(sysdate) - 30)';
   DBMS_OUTPUT.put_line (delete_cmd1);
   execute immediate delete_cmd1;
   commit;
   
         SELECT MIN (id_txn)  INTO del_val
           FROM MOBR5.MOB_TXNS
          WHERE     dat_creation >= trunc(sysdate) - 367
                AND dat_creation <= trunc(sysdate) - 367 + 1 / 24;

   FOR tab IN c_tab
   LOOP
   sys_date := trunc(sysdate)- tab.del_range;
      IF tab.tab_type = 1
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
      END IF;

      IF tab.tab_type = 2
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
      END IF;


      IF tab.tab_type = 3
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||del_val ;
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||del_val;
      END IF;

      IF tab.tab_type in (2,3)
      THEN
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (insert_cmd);
      EXECUTE IMMEDIATE insert_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION,start_time,numrow,elapsed_time)
                 VALUES (tab.table_name,'INSERT',timeStart, counter, SUBSTR (elapsed, 10, 10));
            COMMIT;

      END IF;
      

      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (delete_cmd);
      EXECUTE IMMEDIATE delete_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION, start_time, numrow, elapsed_time)
                 VALUES (tab.table_name, 'DELETE',timeStart, counter,SUBSTR (elapsed, 10, 10));
            COMMIT;

      --rebuild global index
      FOR c_idx
         IN (SELECT index_name, partitioned
               FROM dba_indexes
              WHERE     table_name = tab.table_name
                    AND owner = 'MOBR5'
                    AND index_type NOT LIKE 'LOB%'
                    AND index_type <> 'FUNCTION-BASED NORMAL' AND partitioned = 'NO')
      LOOP

              SELECT SUM (bytes) / 1024 / 1024 / 1024
                INTO pre_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name
            GROUP BY segment_name;

            cmd := 'alter index MOBR5.' || c_idx.index_name || ' rebuild online';

            timeStart := SYSDATE;
            DBMS_OUTPUT.put_line (cmd);
            EXECUTE IMMEDIATE cmd;

            timeEnd := SYSDATE;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

              SELECT SUM (bytes) / 1024 / 1024 / 1024
                INTO post_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name
            GROUP BY segment_name;
                     INSERT INTO mobr5.rebuild_idx_log (table_name, index_name, start_time, elapsed_time, Pre_size, post_size)
                          VALUES (tab.table_name, c_idx.index_name, timeStart, SUBSTR (elapsed, 10, 10), pre_rebuild,post_rebuild);
                     COMMIT;

         
      END LOOP; 

   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/


DELETE FROM MOBR5.EVT_ENTRY_DATA where ID in (select ID from MOBR5.EVT_ENTRY_HANDLER where DAT_CREATION <= to_date(sysdate) - 30)
delete from MOBR5.EVT_ENTRY_HANDLER where dat_creation <'07-APR-19'
alter index MOBR5.IDX_ENTRY_HANDLER_NEW rebuild online
alter index MOBR5.PK_EVT_ENTRY_HANDLER_NEW rebuild online
delete from MOBR5.EVT_ENTRY where dat_creation <'07-APR-19'
alter index MOBR5.EVT_ENTRY_PK2_NEW rebuild online
alter index MOBR5.IDX_ENTRY_CREATED2_NEW rebuild online
alter index MOBR5.IDX_ENTRY_TRIGGER2_NEW rebuild online
delete from MOBR5.MOB_SESSIONS where dat_creation <'07-APR-19'
alter index MOBR5.PK_SESSIONS_2 rebuild online
alter index MOBR5.IDX_MOB_SESSIONS_2 rebuild online
delete from MOBR5.MOB_TRACEABLE_REQUESTS where dat_creation <'07-APR-19'
alter index MOBR5.PK_MOB_TRACEABLE_REQUESTS rebuild online
alter index MOBR5.IDX_ORIG_TRACE rebuild online
insert into MOBR5.MOB_FEES_HIST select * from MOBR5.MOB_FEES where dat_creation <'06-MAY-18'
delete from MOBR5.MOB_FEES where dat_creation <'06-MAY-18'
alter index MOBR5.PK_FEES rebuild online
alter index MOBR5.IDX_FEES_TXN rebuild online
insert into MOBR5.MOB_TXN_ATTRIBUTES_HIST select * from MOBR5.MOB_TXN_ATTRIBUTES where dat_creation <'06-MAY-18'
delete from MOBR5.MOB_TXN_ATTRIBUTES where dat_creation <'06-MAY-18'
alter index MOBR5.PK_TXN_ATTRIBUTES rebuild online
alter index MOBR5.IDX_TXN_ATR_STRVALUE rebuild online
insert into MOBR5.AMS_PI_BALANCES_HIST select * from MOBR5.AMS_PI_BALANCES where dat_creation <'06-MAY-18'
delete from MOBR5.AMS_PI_BALANCES where dat_creation <'06-MAY-18'
alter index MOBR5.PK_PI_BALANCES rebuild online
insert into MOBR5.MOB_INV_TXNS_HIST select * from MOBR5.MOB_INV_TXNS where dat_creation <'06-MAY-18'
delete from MOBR5.MOB_INV_TXNS where dat_creation <'06-MAY-18'
alter index MOBR5.IDX_INV_TXNS_TXN rebuild online
alter index MOBR5.INV_TXNS_PK rebuild online
insert into MOBR5.AMS_DOCS_HIST select * from MOBR5.AMS_DOCS where dat_creation <'06-MAY-18'
delete from MOBR5.AMS_DOCS where dat_creation <'06-MAY-18'
alter index MOBR5.AMS_IDX_FOREIGNTXN rebuild online
alter index MOBR5.PK_DOCS rebuild online
insert into MOBR5.MOB_AUDIT_LOGS_HIST select * from MOBR5.MOB_AUDIT_LOGS where dat_creation <'07-APR-19'
delete from MOBR5.MOB_AUDIT_LOGS where dat_creation <'07-APR-19'
alter index MOBR5.PK_ACTIVITIES rebuild online
insert into MOBR5.AMS_BOOKINGS_HIST select * from MOBR5.AMS_BOOKINGS where dat_creation <'06-MAY-18'
delete from MOBR5.AMS_BOOKINGS where dat_creation <'06-MAY-18'
alter index MOBR5.AMS_IDX_BOOKING_PI rebuild online
alter index MOBR5.PK_BOOKINGS rebuild online
alter index MOBR5.AMS_IDX_BOOKINGS_CLRNUM rebuild online
insert into MOBR5.TCB_PUBLIC_INBOX_CUSTOMER_READ_HIST select * from MOBR5.TCB_PUBLIC_INBOX_CUSTOMER_READ where dat_creation <'06-MAY-18'
delete from MOBR5.TCB_PUBLIC_INBOX_CUSTOMER_READ where dat_creation <'06-MAY-18'
alter index MOBR5.IDX_PUB_MSG_ACTIVE rebuild online
alter index MOBR5.SYS_C0017562 rebuild online
insert into MOBR5.TCB_PRIVATE_INBOX_HIST select * from MOBR5.TCB_PRIVATE_INBOX where dat_creation <'06-MAY-18'
delete from MOBR5.TCB_PRIVATE_INBOX where dat_creation <'06-MAY-18'
alter index MOBR5.IDX_MESSAGE_ACTIVE rebuild online
alter index MOBR5.SYS_C0017503 rebuild online
insert into MOBR5.TCB_PUBLIC_INBOX_HIST select * from MOBR5.TCB_PUBLIC_INBOX where dat_creation <'06-MAY-18'
delete from MOBR5.TCB_PUBLIC_INBOX where dat_creation <'06-MAY-18'
alter index MOBR5.SYS_C0017563 rebuild online
insert into MOBR5.MOB_TXNS_HIST select * from MOBR5.MOB_TXNS where id_txn <2339829167
delete from MOBR5.MOB_TXNS where id_txn < 2339829167
alter index MOBR5.IDX_TXNS_STATUS_ERROR rebuild online
alter index MOBR5.PK_TXNS2 rebuild online
alter index MOBR5.IDX_TXNS_ERROR_LOCKED rebuild online
alter index MOBR5.IDX_TXNS_MERCHANTID rebuild online
alter index MOBR5.IDX_TXNS_PAYEE rebuild online
alter index MOBR5.IDX_TXNS_PAYER rebuild online
alter index MOBR5.IDX_ID_REF_TXN rebuild online
insert into MOBR5.MOB_SUB_TXNS_HIST select * from MOBR5.MOB_SUB_TXNS where id_sub_txn <2339829167
delete from MOBR5.MOB_SUB_TXNS where id_sub_txn <2339829167
alter index MOBR5.IDX_SUB_TXNS rebuild online
alter index MOBR5.IDX_SUB_TXNS_IDTXN rebuild online
alter index MOBR5.PK_SUB_TXNS rebuild online


DECLARE
   delete_cmd     VARCHAR2 (4000);
   delete_cmd1    VARCHAR2 (4000);
   insert_cmd     VARCHAR2 (4000);
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   DURATION       NUMBER;
   post_rebuild   NUMBER;
   pre_rebuild    NUMBER;
   TXNS_del_val        NUMBER;
   EVT_del_val		NUMBER;
   sys_date date;
   sys_date3 date;

   CURSOR c_tab
   IS
        SELECT table_name,
               table_name_hist,
               tab_type,
               pre_condition,
               del_range,
               add_condition
          FROM mobr5.table_archive 
      ORDER BY tab_id;
BEGIN
   --delete_cmd1 := 'DELETE FROM MOBR5.EVT_ENTRY_DATA where ID in (select ID from MOBR5.EVT_ENTRY_HANDLER where DAT_CREATION <= to_date(sysdate) - 30)';
   --DBMS_OUTPUT.put_line (delete_cmd1);
   --execute immediate delete_cmd1;
   --commit;
   
         SELECT MIN (id_txn)  INTO TXNS_del_val
           FROM MOBR5.MOB_TXNS
          WHERE     dat_creation >= trunc(sysdate) - 367
                AND dat_creation <= trunc(sysdate) - 367 + 1 / 24;
				
	     SELECT  min(ID) INTO EVT_del_val FROM MOBR5.EVT_ENTRY 
            where dat_creation >= trunc(sysdate) - 32
               AND dat_creation <= trunc(sysdate) - 32 + 1 / 24;
				
				--SELECT  min(ID) INTO EVT_del_val   FROM MOBR5.EVT_ENTRY where dat_creation <= trunc(sysdate) -29;
   FOR tab IN c_tab
   LOOP
   sys_date := trunc(sysdate)- tab.del_range;
      IF tab.tab_type = 1
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;

      IF tab.tab_type = 2
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;


      IF tab.tab_type = 3
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||TXNS_del_val ;
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||TXNS_del_val||' and rownum <1000001';
      END IF;
	  
      IF tab.tab_type = 4
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||EVT_del_val||' and rownum <1000001';
      END IF;	  

      IF tab.tab_type in (2,3)
      THEN
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (insert_cmd);
      EXECUTE IMMEDIATE insert_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION,start_time,numrow,elapsed_time)
                 VALUES (tab.table_name,'INSERT',timeStart, counter, SUBSTR (elapsed, 10, 10));
            COMMIT;

      END IF;
      
      LOOP
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (delete_cmd);
      EXECUTE IMMEDIATE delete_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION, start_time, numrow, elapsed_time)
                 VALUES (tab.table_name, 'DELETE',timeStart, counter,SUBSTR (elapsed, 10, 10));
            COMMIT;
      exit when  counter < 1000000 ;
	  END LOOP; 
      --rebuild global index
      FOR c_idx
         IN (SELECT index_name, partitioned
               FROM dba_indexes
              WHERE     table_name = tab.table_name
                    AND owner = 'MOBR5'
                    AND index_type NOT LIKE 'LOB%'
                    AND index_type <> 'FUNCTION-BASED NORMAL' AND partitioned = 'NO')
      LOOP

              SELECT SUM (bytes) / 1024 / 1024 / 1024
                INTO pre_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name
            GROUP BY segment_name;

            cmd := 'alter index MOBR5.' || c_idx.index_name || ' rebuild online';

            timeStart := SYSDATE;
            DBMS_OUTPUT.put_line (cmd);
            EXECUTE IMMEDIATE cmd;

            timeEnd := SYSDATE;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

              SELECT SUM (bytes) / 1024 / 1024 / 1024
                INTO post_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name
            GROUP BY segment_name;
                     INSERT INTO mobr5.rebuild_idx_log (table_name, index_name, start_time, elapsed_time, Pre_size, post_size)
                          VALUES (tab.table_name, c_idx.index_name, timeStart, SUBSTR (elapsed, 10, 10), pre_rebuild,post_rebuild);
                     COMMIT;

         
      END LOOP; 

   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/

SET DEFINE OFF;
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (1, 'EVT_ENTRY_HANDLER', 4, ' where EVENT_ID < ', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (2, 'EVT_ENTRY_DATA', 4, ' where EVENT_ID < ', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (3, 'EVT_ENTRY', 1, ' where dat_creation <', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (4, 'MOB_SESSIONS', 1, ' where dat_creation <', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (5, 'MOB_TRACEABLE_REQUESTS', 1, ' where dat_creation <', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (6, 'MOB_FEES', 'MOB_FEES_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (7, 'MOB_TXN_ATTRIBUTES', 'MOB_TXN_ATTRIBUTES_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (8, 'AMS_PI_BALANCES', 'AMS_PI_BALANCES_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (9, 'MOB_INV_TXNS', 'MOB_INV_TXNS_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (10, 'AMS_DOCS', 'AMS_DOCS_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (11, 'MOB_AUDIT_LOGS', 'MOB_AUDIT_LOGS_HIST', 2, ' where dat_creation <', 
    '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (12, 'AMS_BOOKINGS', 'AMS_BOOKINGS_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (13, 'TCB_PUBLIC_INBOX_CUSTOMER_READ', 'TCB_PUBLIC_INBOX_CUSTOMER_READ_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (14, 'TCB_PRIVATE_INBOX', 'TCB_PRIVATE_INBOX_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (15, 'TCB_PUBLIC_INBOX', 'TCB_PUBLIC_INBOX_HIST', 2, ' where dat_creation <', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (16, 'MOB_TXNS', 'MOB_TXNS_HIST', 3, ' where id_txn < ', 
    '366');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (17, 'MOB_SUB_TXNS', 'MOB_SUB_TXNS_HIST', 3, ' where id_sub_txn <', 
    '366');
COMMIT;



-------------------NEW
SET DEFINE OFF;
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (1, 'EVT_ENTRY_HANDLER', 4, ' where EVENT_ID < ', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (2, 'EVT_ENTRY_DATA', 4, ' where EVENT_ID < ', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (3, 'EVT_ENTRY', 1, ' where dat_creation <', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, tab_type, pre_condition, del_range)
 Values
   (4, 'MOB_SESSIONS', 1, ' where dat_creation <', '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (6, 'MOB_FEES', 'MOB_FEES_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (7, 'MOB_TXN_ATTRIBUTES', 'MOB_TXN_ATTRIBUTES_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (8, 'AMS_PI_BALANCES', 'AMS_PI_BALANCES_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (9, 'MOB_INV_TXNS', 'MOB_INV_TXNS_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (10, 'AMS_DOCS', 'AMS_DOCS_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (11, 'MOB_AUDIT_LOGS', 'MOB_AUDIT_LOGS_HIST', 2, ' where dat_creation <', 
    '31');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (12, 'AMS_BOOKINGS', 'AMS_BOOKINGS_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (13, 'TCB_PUBLIC_INBOX_CUSTOMER_READ', 'TCB_PUBLIC_INBOX_CUSTOMER_READ_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (14, 'TCB_PRIVATE_INBOX', 'TCB_PRIVATE_INBOX_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (15, 'TCB_PUBLIC_INBOX', 'TCB_PUBLIC_INBOX_HIST', 2, ' where dat_creation <', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (16, 'MOB_TXNS', 'MOB_TXNS_HIST', 3, ' where id_txn < ', 
    '190');
Insert into MOBR5.TABLE_ARCHIVE
   (tab_id, table_name, table_name_hist, tab_type, pre_condition, 
    del_range)
 Values
   (17, 'MOB_SUB_TXNS', 'MOB_SUB_TXNS_HIST', 3, ' where id_sub_txn <', 
    '190');
COMMIT;



DECLARE
   delete_cmd     VARCHAR2 (4000);
   delete_cmd1    VARCHAR2 (4000);
   insert_cmd     VARCHAR2 (4000);
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   DURATION       NUMBER;
   post_rebuild   NUMBER;
   pre_rebuild    NUMBER;
   TXNS_del_val        NUMBER;
   EVT_del_val        NUMBER;
   sys_date date;
   sys_date3 date;

   CURSOR c_tab
   IS
        SELECT table_name,table_name_hist, tab_type,  pre_condition,  del_range,  add_condition
          FROM mobr5.table_archive where tab_id >11
      ORDER BY tab_id;
BEGIN
select sysdate into timeCheck from dual;
  
         SELECT MIN (id_txn)  INTO TXNS_del_val
           FROM MOBR5.MOB_TXNS
          WHERE     dat_creation >= trunc(sysdate) - 190
                AND dat_creation <= trunc(sysdate) - 190 + 1 / 24;
                
         SELECT  min(ID) INTO EVT_del_val FROM MOBR5.EVT_ENTRY 
            where dat_creation >= trunc(sysdate) - 32
               AND dat_creation <= trunc(sysdate) - 32 + 1 / 24; 
               
   FOR tab IN c_tab
   LOOP
   sys_date := trunc(sysdate)- tab.del_range;
      IF tab.tab_type = 1
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;

      IF tab.tab_type = 2
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;


      IF tab.tab_type = 3
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||TXNS_del_val ;
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||TXNS_del_val||' and rownum <1000001';
      END IF;
      
      IF tab.tab_type = 4
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||EVT_del_val||' and rownum <1000001';
      END IF;      

      IF tab.tab_type in (2,3)
      THEN
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (insert_cmd);
      EXECUTE IMMEDIATE insert_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION,start_time,numrow,elapsed_time)
                 VALUES (tab.table_name,'INSERT',timeStart, counter, SUBSTR (elapsed, 10, 10));
            COMMIT;

      END IF;
      
      LOOP
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (delete_cmd);
      EXECUTE IMMEDIATE delete_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION, start_time, numrow, elapsed_time)
                 VALUES (tab.table_name, 'DELETE',timeStart, counter,SUBSTR (elapsed, 10, 10));
            COMMIT;
      duration := trunc((sysdate -timeCheck)*24);			
      exit when  counter < 1000000 or duration >= 7;
      END LOOP; 
      
      --rebuild global index
      FOR c_idx
         IN (SELECT index_name, partitioned
               FROM dba_indexes
              WHERE     table_name = tab.table_name
                    AND owner = 'MOBR5'
                    AND index_type NOT LIKE 'LOB%'
                    AND index_type <> 'FUNCTION-BASED NORMAL' AND partitioned = 'NO')
      LOOP

              SELECT SUM (bytes) / 1024 / 1024 / 1024  INTO pre_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name ;

            cmd := 'alter index MOBR5.' || c_idx.index_name || ' rebuild online';

            timeStart := SYSDATE;
            DBMS_OUTPUT.put_line (cmd);
            EXECUTE IMMEDIATE cmd;

            timeEnd := SYSDATE;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

              SELECT SUM (bytes) / 1024 / 1024 / 1024   INTO post_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name ;
                     INSERT INTO mobr5.rebuild_idx_log (table_name, index_name, start_time, elapsed_time, Pre_size, post_size)
                          VALUES (tab.table_name, c_idx.index_name, timeStart, SUBSTR (elapsed, 10, 10), pre_rebuild,post_rebuild);
                     COMMIT;

         
      END LOOP; 
	duration := trunc((sysdate -timeCheck)*24);
      exit when  duration >= 7;  

   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/

---final
DECLARE
   delete_cmd     VARCHAR2 (4000);
   delete_cmd1    VARCHAR2 (4000);
   insert_cmd     VARCHAR2 (4000);
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   inserted       NUMBER;
   DURATION       NUMBER;
   post_rebuild   NUMBER;
   pre_rebuild    NUMBER;
   TXNS_del_val        NUMBER;
   EVT_del_val        NUMBER;
   sys_date date;
   sys_date3 date;

   CURSOR c_tab
   IS
   
   SELECT table_name,table_name_hist, tab_type,  pre_condition,  del_range,  add_condition
    FROM mobr5.table_archive
   WHERE table_name  NOT IN
   (     
   SELECT DISTINCT a.table_name
         FROM mobr5.table_archive a,mobr5.table_archive_log b
        WHERE        a.table_name = b.table_name
           AND numrow <1000000 and operation='DELETE'
           AND start_time> sysdate-4                     
           )
   ORDER BY tab_id;
   
BEGIN
select sysdate into timeCheck from dual;
  
         SELECT MIN (id_txn)  INTO TXNS_del_val
           FROM MOBR5.MOB_TXNS
          WHERE     dat_creation >= trunc(sysdate) - 190
                AND dat_creation <= trunc(sysdate) - 190 + 1 / 24;
                
         SELECT  min(ID) INTO EVT_del_val FROM MOBR5.EVT_ENTRY 
            where dat_creation >= trunc(sysdate) - 32
               AND dat_creation <= trunc(sysdate) - 32 + 1 / 24; 
               
   FOR tab IN c_tab
   LOOP
   sys_date := trunc(sysdate)- tab.del_range;
      IF tab.tab_type = 1
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;

      IF tab.tab_type = 2
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||'''';
         delete_cmd :=  'delete from MOBR5.' || tab.table_name || tab.pre_condition ||''''|| sys_date||''' and rownum <1000001';
      END IF;


      IF tab.tab_type = 3
      THEN
         insert_cmd :=  'insert into MOBR5.' || tab.table_name_hist || ' select * from MOBR5.' || tab.table_name || tab.pre_condition ||TXNS_del_val ;
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||TXNS_del_val||' and rownum <1000001';
      END IF;
      
      IF tab.tab_type = 4
      THEN
         delete_cmd :=  'delete from MOBR5.' || tab.table_name  || tab.pre_condition ||EVT_del_val||' and rownum <1000001';
      END IF;      

      IF tab.tab_type in (2,3)
      THEN
      
         SELECT count(a.table_name) into inserted
         FROM mobr5.table_archive a,mobr5.table_archive_log b
        WHERE        a.table_name = b.table_name
           AND operation='INSERT'
           AND a.table_name=tab.table_name 
           AND start_time> sysdate-4 ;

        IF inserted =0 then
      
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (insert_cmd);
      EXECUTE IMMEDIATE insert_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION,start_time,numrow,elapsed_time)
                VALUES (tab.table_name,'INSERT',timeStart, counter, SUBSTR (elapsed, 10, 10));
            COMMIT;
        end if;
      END IF;
      
      LOOP
      timeStart := SYSDATE;
      DBMS_OUTPUT.put_line (delete_cmd);
      EXECUTE IMMEDIATE delete_cmd;

      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

            INSERT INTO mobr5.table_archive_log (table_name,OPERATION, start_time, numrow, elapsed_time)
                 VALUES (tab.table_name, 'DELETE',timeStart, counter,SUBSTR (elapsed, 10, 10));
            COMMIT;
      duration := trunc((sysdate -timeCheck)*24);            
      exit when  counter < 1000000 or duration >= 7;
      END LOOP; 
      
      --rebuild global index
      FOR c_idx
         IN (SELECT index_name, partitioned
               FROM dba_indexes
              WHERE     table_name = tab.table_name
                    AND owner = 'MOBR5'
                    AND index_type NOT LIKE 'LOB%'
                    AND index_type <> 'FUNCTION-BASED NORMAL' AND partitioned = 'NO')
      LOOP

              SELECT SUM (bytes) / 1024 / 1024 / 1024  INTO pre_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name ;

            cmd := 'alter index MOBR5.' || c_idx.index_name || ' rebuild online';

            timeStart := SYSDATE;
            DBMS_OUTPUT.put_line (cmd);
            EXECUTE IMMEDIATE cmd;

            timeEnd := SYSDATE;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

              SELECT SUM (bytes) / 1024 / 1024 / 1024   INTO post_rebuild
                FROM dba_segments
               WHERE owner = 'MOBR5' AND segment_name = c_idx.index_name ;
                     INSERT INTO mobr5.rebuild_idx_log (table_name, index_name, start_time, elapsed_time, Pre_size, post_size)
                          VALUES (tab.table_name, c_idx.index_name, timeStart, SUBSTR (elapsed, 10, 10), pre_rebuild,post_rebuild);
                     COMMIT;
       
      END LOOP; 
    duration := trunc((sysdate -timeCheck)*24);
      exit when  duration >= 7;  

   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/



/* Formatted on 5/13/2019 4:41:50 PM (QP5 v5.252.13127.32847) */
--CREATE OR REPLACE PROCEDURE MOBR5.DROP_OLD_PARTITION AS
declare
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   cmd1          VARCHAR2 (256);
   dem           NUMBER;

   CURSOR c_table
   IS
        SELECT table_name
          FROM all_tables
         WHERE     table_name IN ('MOB_AUDIT_LOGS',
                                  'MOB_TRACEABLE_REQUESTS',
                                  'EVT_ENTRY_HANDLER')
               AND owner = 'MOBR5'
      ORDER BY 1 DESC;
      
BEGIN
   FOR cc IN c_table
   LOOP
      FOR c_partition
         IN (  SELECT table_name, partition_name, HIGH_VALUE
                 FROM all_tab_partitions
                WHERE     table_name = cc.table_name
                      AND partition_name NOT IN ('EVT_ENTRY_HANDLER_P1',
                                                 'SYS_P321',
                                                 'AUDIT_P1',
                                                 'TRACERQS_P1',
                                                 'AUDIT_P2',
                                                 'SYS_P724',
                                                 'SYS_P721')
                      AND table_owner = 'MOBR5'
             ORDER BY 1, 2 DESC)
      LOOP
         v_highvalue := SUBSTR (c_partition.HIGH_VALUE, 12, 10);
         v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');

         IF v_date < TO_DATE (SYSDATE) - 35
         THEN
            IF cc.table_name = 'MOB_TRACEABLE_REQUESTS'
            THEN
               cmd1 :=  'alter table MOBR5.'   || c_partition.table_name  || ' drop partition ' || c_partition.partition_name;
            ELSE
               cmd :=  'select count(*)  from MOBR5.'  || c_partition.table_name  || ' partition ('  || c_partition.partition_name  || ')';

               EXECUTE IMMEDIATE cmd INTO dem;
               DBMS_OUTPUT.put_line (cc.table_name||'.'||c_partition.table_name||dem);

               IF dem = 0
               THEN
                  IF cc.table_name = 'EVT_ENTRY_HANDLER'
                  THEN
                     cmd1 := 'alter table MOBR5.' || c_partition.table_name || ' drop partition ' || c_partition.partition_name || ' update global indexes parallel 4';
                  ELSE
                     cmd1 := 'alter table MOBR5.' || c_partition.table_name || ' drop partition ' || c_partition.partition_name;
                  END IF;


               END IF;
            END IF;
            DBMS_OUTPUT.put_line (cmd1);
            --EXECUTE IMMEDIATE cmd1;
         END IF;
      END LOOP;

      --Rebuild index
      IF cc.table_name = 'EVT_ENTRY_HANDLER'
      THEN
      FOR c_idx
         IN (SELECT owner, index_name, partitioned
               FROM dba_indexes
              WHERE     owner || '.' || table_name =
                           'MOBR5.EVT_ENTRY_HANDLER'
                    AND index_type NOT LIKE 'LOB%'
                    AND index_type <> 'FUNCTION-BASED NORMAL')
      LOOP
         cmd :=  'alter index ' || c_idx.owner  || '.' || c_idx.index_name  || ' rebuild online';
         DBMS_OUTPUT.put_line (cmd);
      --EXECUTE IMMEDIATE cmd;
      END LOOP;
      END IF;
   END LOOP;
END;
/