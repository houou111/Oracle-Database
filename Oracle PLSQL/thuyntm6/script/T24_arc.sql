CREATE TABLE THUYNTM_DBA.TABLE_ARCHIVE
(
  TAB_ID          INTEGER                       NOT NULL,
  TABLE_NAME      VARCHAR2(150 BYTE)            NOT NULL,
  TAB_TYPE        NUMBER                        NOT NULL,
  SUB_TYPE        VARCHAR2(15 BYTE),
  PRE_CONDITION   VARCHAR2(100 BYTE),
  DEL_RANGE       VARCHAR2(4 BYTE),
  POST_CONDITION  VARCHAR2(40 BYTE),
  HINT_IDX        VARCHAR2(50 BYTE),
  ADD_CONDITION   VARCHAR2(100 BYTE)
);

CREATE TABLE THUYNTM_DBA.TABLE_ARCHIVE_LOG
(
  TABLE_NAME    VARCHAR2(150 BYTE),
  TAB_TYPE      VARCHAR2(50 BYTE),
  ARCHIVE_YEAR  VARCHAR2(10 BYTE),
  START_TIME    DATE,
  NUMROW_DEL    NUMBER,
  ELAPSED_TIME  VARCHAR2(50 BYTE)
);
CREATE TABLE REBUILD_IDX_LOG
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
--------

Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (1, 'T24LIVE.FBNK_PM_DLY_POSN_CLASS', 1, ' where recid like ''%.___.', '____.%''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (2, 'T24LIVE.F_RE_BC_TRANGTHAI_4711', 1, ' where recid like ''%#___#', '____''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, ADD_CONDITION)
 Values
   (3, 'T24LIVE.FBNK_EB_B005', 1, 'FT', ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c2''),''^A'') <=', 
    '1231', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, DEL_RANGE, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (4, 'T24LIVE.FBNK_QUAN014', 1, ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c6''),''^A'')<=''', '1231', 
    '''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (5, 'T24LIVE.FBNK_OD_ACCT_ACTIVITY', 1, ' where recid like ''______________-', '%''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (6, 'T24LIVE.FBNK_FTBULK_TCB#HIS', 2, 'BC', ' where recid like ''BC', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (7, 'T24LIVE.F_FTBULK_000', 2, 'BC', ' where recid like ''BC', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (8, 'T24LIVE.F_FTBULK_CONTROL_TCB', 2, 'BC', ' where recid like ''BC', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (18, 'T24LIVE.F_DE_O_REPAIR', 1, 'D', ' where recid like ''D', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (19, 'T24LIVE.F_DE_O_MSG_ADVICE', 1, 'D', ' where recid like ''D', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', 
    '0', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', 
    '2', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', 
    '3', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', 
    '1', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (9, 'T24LIVE.FBNK_FTBU000', 2, 'BC', ' where recid like ''BC', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', 
    '3', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', 
    '2', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', 
    '0', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', 
    '3', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', 
    '3', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', 
    '1', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', 
    '2', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', 
    '1', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', 
    '0', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', 
    '2', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', 
    '0', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values
   (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', 
    '1', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'APPLICATION', ' where recid like ''%.APPLICATION.', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'LOGOUT', ' where recid like ''%.LOGOUT.', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'ENQUIRY', ' where recid like ''%.ENQUIRY.', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'CHANGEPASS', ' where recid like ''%.CHANGEPASS.', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (14, 'T24LIVE.FBNK_RE_CONSOL_PROFIT', 1, ' where recid like ''%.VN001____.___.', '%''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (16, 'T24LIVE.F_DE_O_HANDOFF', 1, 'D', ' where recid like ''D', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, 
    POST_CONDITION, ADD_CONDITION)
 Values
   (17, 'T24LIVE.F_DE_O_HEADER', 1, 'D', ' where recid like ''D', 
    '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (20, 'T24LIVE.FBNK_TXN_LOG_TCB', 1, ' where recid like ''%/', '%''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, DEL_RANGE, 
    POST_CONDITION, HINT_IDX, ADD_CONDITION)
 Values
   (21, 'T24LIVE.FBNK_DEPO_WITHDRA', 1, ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c29''),'''')<''', '0901', 
    '''', '/*+index (t IX_FBNK_DEPO_WITHDRA_C29)*/', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, POST_CONDITION, 
    ADD_CONDITION)
 Values
   (22, 'T24LIVE.F_LCR_AUTO_WRK_TCB', 2, ' where recid like ''', '%''', 
    ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE
   (TAB_ID, TABLE_NAME, TAB_TYPE, PRE_CONDITION, DEL_RANGE, 
    ADD_CONDITION)
 Values
   (23, 'T24LIVE.FBNK_SUM_DENO_TCB', 1, ' t WHERE NVL(T24LIVE.NUMCAST(EXTRACTVALUE(t.XMLRECORD,''/row/c16'')),0)<', '0901', 
    ' and rownum<1000001');
COMMIT;

------

CREATE OR REPLACE procedure SYS.archive_data_yearly as
   archive_year   NUMBER;
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   CURSOR c_tab
   IS
        SELECT table_name, tab_type, del_range, pre_condition,post_condition,sub_type, hint_idx ,add_condition
          FROM sys.table_archive
      ORDER BY tab_id desc, del_range;
BEGIN
   FOR tab IN c_tab
   LOOP
      IF tab.tab_type = 1
      THEN
         archive_year := EXTRACT (YEAR FROM SYSDATE) - 1;
      END IF;

      IF tab.tab_type = 2
      THEN
         archive_year := SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1), 3, 4);
      END IF;

      IF tab.tab_type = 3
      THEN
         archive_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
      END IF;

      cmd :='delete '--||tab.hint_idx||' '
      || tab.table_name|| tab.pre_condition|| archive_year||tab.del_range|| tab.post_condition||' '||tab.add_condition;

      LOOP
         DBMS_OUTPUT.put_line (cmd);
         timeStart := SYSDATE;
         execute immediate cmd ;
         timeEnd := SYSDATE;
         counter := SQL%ROWCOUNT;
         COMMIT;
         DBMS_OUTPUT.put_line ( counter|| ' rows deleted('|| tab.sub_type|| archive_year||tab.del_range||  ')');
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

               insert into  sys.table_archive_log (table_name ,tab_type,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name,
               tab.sub_type||tab.del_range,to_char(archive_year) ,timeStart,counter, substr(elapsed,10,10));
               commit;
         exit when  counter < 1000000 ;
      END LOOP;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/

--------
CREATE OR REPLACE procedure SYS.DBA_rebuild_index as
   cmd         VARCHAR2 (4000);
   timeStart   DATE;
   timeEnd     DATE;
   elapsed     VARCHAR2 (50);
   post_rebuild number;
   pre_rebuild number;
   start_seq    number;
   end_seq number;

   CURSOR c_tab
   IS
        SELECT DISTINCT
               tab_id, SUBSTR (table_name, 9, LENGTH (table_name)) AS table_name
          FROM sys.table_archive
      ORDER BY tab_id;

BEGIN
   FOR tab IN c_tab
   LOOP
      FOR c_idx IN (SELECT index_name,partitioned
                      FROM dba_indexes
                     WHERE table_name = tab.table_name AND owner = 'T24LIVE' and index_type not like 'LOB%'
                     and index_type <> 'FUNCTION-BASED NORMAL'
                     )
      LOOP
      if c_idx.partitioned = 'NO' then
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         cmd :=            'alter index T24LIVE.' || c_idx.index_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

           SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);

         COMMIT;

      else

      FOR c_idx1 IN (SELECT partition_name  FROM dba_ind_partitions
                    WHERE index_name = c_idx.index_name AND index_owner = 'T24LIVE' )
      LOOP
                SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         cmd :=            'alter index T24LIVE.' || c_idx.index_name || ' rebuild partition '||c_idx1.partition_name||' online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)
              VALUES (tab.table_name, c_idx.index_name||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);
              commit;

      end loop;
      end if;

      END LOOP;
   END LOOP;
END;
/

