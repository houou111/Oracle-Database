==================================================================
DELETE T24LIVE.FBNK_RE_C019  WHERE recid LIKE '%.DEBIT.2016%' AND ROWNUM < 1000001
exec dbms_scheduler.disable('SYS.DBA_TEMP_JOB_ARCHIVE_DATA');
Bổ sung 2 bảng T24LIVE.FBNK_RE_C018 và T24LIVE.FBNK_RE_C019  vào danh sách archive định kỳ (chi tiết được bổ sung trong file table_archive_update201807.xlxs)  và thực hiện archive dữ liệu của 2 bảng từ 06/2017 trở về trước

SET DEFINE OFF;
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.','%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT', ' where recid like ''%.DEBIT.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, '5XXXX', ' where recid like ''%.5____.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'OVERDUEPR', ' where recid like ''%.OVERDUEPR.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'LIVECR', ' where recid like ''%.LIVECR.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'ISSUEBL', ' where recid like ''%.ISSUEBL.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'FWDMEMODBBL', ' where recid like ''%.FWDMEMODBBL.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     POST_CONDITION, ADD_CONDITION)
 Values   (25, 'T24LIVE.FBNK_RE_C018', 1, 'LINE', ' where recid like ''%.LINE.',     '%''', ' and rownum<1000001');
COMMIT;



Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '01', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '02', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '03', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '04', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '05', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '06', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '07', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '08', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '09', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '10', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '11', '%''', ' and rownum<1000001');
Insert into SYS.TABLE_ARCHIVE   (TAB_ID, TABLE_NAME, TAB_TYPE, SUB_TYPE, PRE_CONDITION,     DEL_RANGE, POST_CONDITION, ADD_CONDITION)
 Values   (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT', ' where recid like ''%.CREDIT.',     '12', '%''', ' and rownum<1000001');
 commit;
 
 
CREATE procedure SYS.DBA_TEMP_archive_data_yearly as
   archive_year   NUMBER;
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   post_rebuild number;
   pre_rebuild number;
   start_seq    number;
   end_seq number;
   CURSOR c_tab
   IS

  SELECT table_name,tab_type,del_range,pre_condition,post_condition,sub_type,hint_idx,add_condition,SUBSTR (table_name, 9, LENGTH (table_name))  tab_name
    FROM sys.table_archive
   WHERE table_name || sub_type || del_range NOT IN
   (SELECT DISTINCT a.table_name|| a.sub_type|| a.del_range
         FROM sys.table_archive a,sys.table_archive_log b
        WHERE        a.table_name|| a.sub_type|| a.del_range = b.table_name|| b.sub_type|| b.del_range
           AND start_time >TRUNC (SYSDATE,'year')
           AND numrow_del <1000000)
           --and table_name in ('T24LIVE.FBNK_PM_DLY_POSN_CLASS','T24LIVE.FBNK_AI_CORP_TXN_LOG')
   ORDER BY tab_id ,sub_type, del_range;
BEGIN
select sysdate into timeCheck from dual;
   FOR tab IN c_tab
   LOOP
      --DBMS_OUTPUT.put_line ('====' || tab.table_name);
      IF tab.tab_type = 1
      THEN
         archive_year := EXTRACT (YEAR FROM SYSDATE) - 2;
      END IF;

      --cmd :='delete '|| tab.table_name|| tab.pre_condition|| archive_year|| tab.del_range || tab.post_condition;
      cmd :='delete '||tab.hint_idx||' '|| tab.table_name|| tab.pre_condition|| archive_year||tab.del_range|| tab.post_condition||' '||tab.add_condition;

      LOOP
         DBMS_OUTPUT.put_line (cmd);
         timeStart := SYSDATE;
         execute immediate cmd ;
         timeEnd := SYSDATE;
         counter := SQL%ROWCOUNT;
         COMMIT;
         DBMS_OUTPUT.put_line ( counter|| ' rows deleted('|| tab.sub_type|| archive_year||tab.del_range||  ')');
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         DBMS_OUTPUT.put_line ( 'Elapsed time: '|| substr(elapsed,10,10));
               insert into  sys.table_archive_log (table_name ,sub_type,del_range,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name,
               tab.sub_type,tab.del_range,to_char(archive_year) ,timeStart,counter, substr(elapsed,10,10));
               commit;
         duration := trunc((sysdate -timeCheck)*24);
         DBMS_OUTPUT.put_line ( sysdate -timeCheck);
         exit when  counter < 1000000 or duration >= 7 ;
      END LOOP;

      --REBUILD INDEX----------
      DBMS_OUTPUT.put_line ('check: '|| counter);
      IF counter < 1000000
      THEN
      FOR c_idx IN (SELECT index_name,partitioned
                      FROM dba_indexes
                     WHERE table_name = tab.tab_name AND owner = 'T24LIVE' and index_type not like 'LOB%'
                     and index_type <> 'FUNCTION-BASED NORMAL'
                     )
      LOOP
      if c_idx.partitioned = 'NO' then
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         cmd := 'alter index T24LIVE.' || c_idx.index_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --select max(sequence#) into start_seq from v$archived_log;
         EXECUTE IMMEDIATE cmd;
         --execute immediate 'alter system archive log current';
         --select max(sequence#) into end_seq from v$archived_log;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

           SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);

         COMMIT;

      else

      FOR c_idx1 IN (SELECT partition_name  FROM dba_ind_partitions
                    WHERE index_name = c_idx.index_name AND index_owner = 'T24LIVE' )
      LOOP
                SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         cmd := 'alter index T24LIVE.' || c_idx.index_name || ' rebuild partition '||c_idx1.partition_name||' online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --select max(sequence#) into start_seq from v$archived_log;
         EXECUTE IMMEDIATE cmd;
         --execute immediate 'alter system archive log current';
         --select max(sequence#) into end_seq from v$archived_log;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name||'.'||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);
              commit;

      end loop;
      end if;

      END LOOP;
      END IF;
      ---------------
      duration := trunc((sysdate -timeCheck)*24);
      exit when  duration >= 7;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/

==================================================================
Bổ sung bảng T24LIVE.F_JOB_TIMES vào job xử lý phân mảnh định kỳ các bảng F_JOB_LISTS*	

CREATE OR REPLACE PROCEDURE SYS.DEFRAG_FJOBLIST AS
   cmd2            VARCHAR2 (4000);
   cmd3            VARCHAR2 (4000);
   cmd4            VARCHAR2 (4000);
   cmd5            VARCHAR2 (4000);
   ind             VARCHAR2 (50);
   resource_busy   EXCEPTION;
   str             VARCHAR2 (4000);
   dem             NUMBER;
   PRAGMA EXCEPTION_INIT (resource_busy, -54);

   CURSOR c_tab
   IS
        SELECT owner, table_name, partitioned
          FROM dba_tables
         WHERE     (table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\' OR table_name='F_JOB_TIMES') AND owner = 'T24LIVE'
      ORDER BY 2;
BEGIN
   UPDATE T24LIVE.F_TIS_DW_CONTROL
      SET xmlrecord = UPDATEXML (xmlrecord,'/row/c4/text()','RUNNING','/row/c3/text()', TO_CHAR (SYSDATE, 'hh24:mi:ss dd/mm/yyyy'))
    WHERE recid = 'FLA.CLEAR.JOB.LIST';
   COMMIT;

   FOR v_tab IN c_tab
   LOOP
      BEGIN
         IF v_tab.partitioned = 'NO'
         THEN
            cmd2 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE TABLESPACE DATAT24LIVE';
            cmd3 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE DATAT24LIVE) ';
            EXECUTE IMMEDIATE cmd2;
            EXECUTE IMMEDIATE cmd3;

            FOR c_idx
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE'  AND index_type <> 'LOB')
            LOOP
               cmd4 := 'ALTER INDEX T24LIVE.' || c_idx.index_name || ' REBUILD TABLESPACE INDEXT24LIVE ONLINE';
               EXECUTE IMMEDIATE cmd4;
            END LOOP;
         ELSE
            FOR c_par
               IN (SELECT partition_name, partition_position
                     FROM dba_tab_partitions
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE')
            LOOP
               cmd2 := 'alter table T24LIVE.' || v_tab.table_name|| ' move partition '||c_par.partition_name||' tablespace DATAT24LIVE';
               cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE PARTITION '||c_par.partition_name||' LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
               EXECUTE IMMEDIATE cmd2;
               EXECUTE IMMEDIATE cmd3;

               FOR c_idx
                  IN (SELECT index_name
                        FROM dba_indexes
                       WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE' AND partitioned = 'YES'  AND index_type <> 'LOB')
               LOOP
                  FOR c_idx2
                     IN (SELECT partition_name
                           FROM dba_ind_partitions
                          WHERE     index_name = c_idx.index_name AND partition_position =  c_par.partition_position)
                  LOOP
                     cmd4 :='alter index T24LIVE.'|| c_idx.index_name|| ' rebuild partition '|| c_idx2.partition_name|| ' tablespace INDEXT24LIVE online';
                     EXECUTE IMMEDIATE cmd4;
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR c_idx2
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE' AND partitioned = 'NO' AND index_type <> 'LOB')
            LOOP
               cmd4 :='alter index T24LIVE.'|| c_idx2.index_name|| ' rebuild tablespace INDEXT24LIVE online';
               EXECUTE IMMEDIATE cmd4;
            END LOOP;
         END IF;
      EXCEPTION
         WHEN resource_busy
         THEN  str := str || SUBSTR (v_tab.table_name, 12) || '|';
      END;

      DBMS_OUTPUT.put_line (str);

      UPDATE T24LIVE.F_TIS_DW_CONTROL
         SET xmlrecord = UPDATEXML (xmlrecord,'/row/c1/text()', str||' ','/row/c3/text()', TO_CHAR (SYSDATE, 'hh24:mi:ss dd/mm/yyyy'), '/row/c4/text()','NOT RUNNING')
       WHERE recid = 'FLA.CLEAR.JOB.LIST';

      COMMIT;
   END LOOP;

   SELECT a.num + b.num INTO dem
     FROM (SELECT COUNT (*) num FROM dba_indexes WHERE status = 'UNUSABLE') a,
          (SELECT COUNT (*) num FROM dba_ind_PARTITIONS WHERE status = 'UNUSABLE') b;

   IF dem > 0
   THEN
      LOOP
         FOR c_idx3
            IN (SELECT owner, index_name
                  FROM dba_indexes
                 WHERE     table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\' AND table_owner = 'T24LIVE'  AND status = 'UNUSABLE')
         LOOP
            cmd5 :=  'alter index T24LIVE.'  || c_idx3.index_name || ' rebuild tablespace INDEXT24LIVE online';
            EXECUTE IMMEDIATE cmd5;
         END LOOP;

         FOR c_idx4
            IN (SELECT index_owner, index_name, partition_name
                  FROM dba_ind_partitions
                 WHERE     index_owner = 'T24LIVE'  AND status = 'UNUSABLE'
                       AND index_name IN (SELECT index_name FROM dba_indexes
                                           WHERE     table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\' AND table_owner = 'T24LIVE'))
         LOOP
            cmd5 :='alter index T24LIVE.'|| c_idx4.index_name|| ' rebuild partition '|| c_idx4.partition_name|| ' tablespace INDEXT24LIVE online';
            EXECUTE IMMEDIATE cmd5;
         END LOOP;

         SELECT a.num + b.num INTO dem
           FROM (SELECT COUNT (*) num FROM dba_indexes WHERE status = 'UNUSABLE') a,
                (SELECT COUNT (*) num FROM dba_ind_PARTITIONS WHERE status = 'UNUSABLE') b;
         EXIT WHEN dem = 0;
      END LOOP;
   END IF;

END;
/

==================================================================
'Xử lý phân mảnh với 2 bảng T24LIVE.FBNK_TXN_LOG_TCB và T24LIVE.FBNK_TIETKIEMGIAODUC 	
select * from dba_lobs where       table_name in ('FBNK_TXN_LOG_TCB','FBNK_TIETKIEMGIAODUC')



select sum(bytes/1024/1024/1024),segment_name from dba_segments where segment_name in 
('FBNK_TXN_LOG_TCB','FBNK_TIETKIEMGIAODUC','SYS_LOB0000125361C00003$$','SYS_LOB0058131689C00003$$')
group by segment_name


--CREATE OR REPLACE PROCEDURE SYS.DEFRAG_FJOBLIST AS
declare
   cmd2            VARCHAR2 (4000);
   cmd3            VARCHAR2 (4000);
   cmd4            VARCHAR2 (4000);
   cmd5            VARCHAR2 (4000);
   ind             VARCHAR2 (50);
   resource_busy   EXCEPTION;
   str             VARCHAR2 (4000);
   dem             NUMBER;
   PRAGMA EXCEPTION_INIT (resource_busy, -54);

   CURSOR c_tab
   IS
        SELECT owner, table_name, partitioned
          FROM dba_tables
         WHERE     table_name in ('FBNK_TXN_LOG_TCB','FBNK_TIETKIEMGIAODUC') AND owner = 'T24LIVE'
      ORDER BY 2;
BEGIN

   FOR v_tab IN c_tab
   LOOP
      BEGIN
         IF v_tab.partitioned = 'NO'
         THEN
            cmd2 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE TABLESPACE DATAT24LIVE';
            cmd3 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE DATAT24LIVE) ';
            EXECUTE IMMEDIATE cmd2;
            DBMS_OUTPUT.put_line (cmd2);

            FOR c_idx
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE'  AND index_type <> 'LOB')
            LOOP
               cmd4 := 'ALTER INDEX T24LIVE.' || c_idx.index_name || ' REBUILD TABLESPACE INDEXT24LIVE ONLINE';
               EXECUTE IMMEDIATE cmd4;
               DBMS_OUTPUT.put_line (cmd4);
            END LOOP;
         ELSE
            FOR c_par
               IN (SELECT partition_name, partition_position
                     FROM dba_tab_partitions
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE')
            LOOP
               cmd2 := 'alter table T24LIVE.' || v_tab.table_name|| ' move partition '||c_par.partition_name||' tablespace DATAT24LIVE';
               --cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE PARTITION '||c_par.partition_name||' LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
               EXECUTE IMMEDIATE cmd2;
               DBMS_OUTPUT.put_line (cmd2);

               FOR c_idx
                  IN (SELECT index_name
                        FROM dba_indexes
                       WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE' AND partitioned = 'YES'  AND index_type <> 'LOB')
               LOOP
                  FOR c_idx2
                     IN (SELECT partition_name
                           FROM dba_ind_partitions
                          WHERE     index_name = c_idx.index_name AND partition_position =  c_par.partition_position)
                  LOOP
                     cmd4 :='alter index T24LIVE.'|| c_idx.index_name|| ' rebuild partition '|| c_idx2.partition_name|| ' tablespace INDEXT24LIVE online';
                     EXECUTE IMMEDIATE cmd4;
                     DBMS_OUTPUT.put_line (cmd4);
                  END LOOP;
               END LOOP;
            END LOOP;

            FOR c_idx2
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE' AND partitioned = 'NO' AND index_type <> 'LOB')
            LOOP
               cmd4 :='alter index T24LIVE.'|| c_idx2.index_name|| ' rebuild tablespace INDEXT24LIVE online';
               EXECUTE IMMEDIATE cmd4;
               DBMS_OUTPUT.put_line (cmd4);
            END LOOP;
         END IF;
      EXCEPTION
         WHEN resource_busy
         THEN  str := str || SUBSTR (v_tab.table_name, 12) || '|';
      END;

      DBMS_OUTPUT.put_line (str);

   END LOOP;

   SELECT a.num + b.num INTO dem
     FROM (SELECT COUNT (*) num FROM dba_indexes WHERE status = 'UNUSABLE') a,
          (SELECT COUNT (*) num FROM dba_ind_PARTITIONS WHERE status = 'UNUSABLE') b;

   IF dem > 0
   THEN
      LOOP
         FOR c_idx3
            IN (SELECT owner, index_name
                  FROM dba_indexes
                 WHERE     table_name in ('FBNK_TXN_LOG_TCB','FBNK_TIETKIEMGIAODUC') AND table_owner = 'T24LIVE'  AND status = 'UNUSABLE')
         LOOP
            cmd5 :=  'alter index T24LIVE.'  || c_idx3.index_name || ' rebuild tablespace INDEXT24LIVE online';
            EXECUTE IMMEDIATE cmd5;
            DBMS_OUTPUT.put_line (cmd5);
         END LOOP;

         FOR c_idx4
            IN (SELECT index_owner, index_name, partition_name
                  FROM dba_ind_partitions
                 WHERE     index_owner = 'T24LIVE'  AND status = 'UNUSABLE'
                       AND index_name IN (SELECT index_name FROM dba_indexes
                                           WHERE     table_name in ('FBNK_TXN_LOG_TCB','FBNK_TIETKIEMGIAODUC') AND table_owner = 'T24LIVE'))
         LOOP
            cmd5 :='alter index T24LIVE.'|| c_idx4.index_name|| ' rebuild partition '|| c_idx4.partition_name|| ' tablespace INDEXT24LIVE online';
            EXECUTE IMMEDIATE cmd5;
            DBMS_OUTPUT.put_line (cmd5);
         END LOOP;

         SELECT a.num + b.num INTO dem
           FROM (SELECT COUNT (*) num FROM dba_indexes WHERE status = 'UNUSABLE') a,
                (SELECT COUNT (*) num FROM dba_ind_PARTITIONS WHERE status = 'UNUSABLE') b;
         EXIT WHEN dem = 0;
      END LOOP;
   END IF;

END;
/

''
==================================================================
Thực hiện tăng initrans với bảng T24LIVE.F_EB_USER_CONTEXT theo recommend của Temenos và Oracle	

select sum(bytes/1024/1024/1024),segment_name from dba_segments where segment_name in 
('F_EB_USER_CONTEXT','F_EB_USER_CONTEXT_INI','LOB_F_EB_USER_CONTEXT','LOB_F_EB_USER_CONTEXT_INI')
group by segment_name


CREATE TABLE T24LIVE.F_EB_USER_CONTEXT_INI
(
  RECID      VARCHAR2(255 BYTE)                 NOT NULL,
  XMLRECORD  BLOB
)
LOB (XMLRECORD) STORE AS LOB_F_EB_USER_CONTEXT_INI (
  TABLESPACE  DATAT24LIVE
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  CACHE
  LOGGING
      STORAGE    (
                  INITIAL          64K
                  NEXT             1M
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                 ))
TABLESPACE DATAT24LIVE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   60
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX T24LIVE.PK_F_EB_USER_CONTEXT_INI ON T24LIVE.F_EB_USER_CONTEXT_INI
(RECID)
LOGGING
TABLESPACE INDEXT24LIVE
PCTFREE    10
INITRANS   60
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
           )
NOPARALLEL;


ALTER TABLE T24LIVE.F_EB_USER_CONTEXT_INI ADD (
  CONSTRAINT PK_F_EB_USER_CONTEXT_INI
  PRIMARY KEY
  (RECID)
  USING INDEX T24LIVE.PK_F_EB_USER_CONTEXT_INI
  ENABLE VALIDATE);


 

BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE('T24LIVE','F_EB_USER_CONTEXT',DBMS_REDEFINITION.CONS_USE_PK);
END;
/

alter session force parallel dml parallel 4;
alter session force parallel query parallel 4;

   
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE('T24LIVE', 'F_EB_USER_CONTEXT','F_EB_USER_CONTEXT_INI',
null,dbms_redefinition.cons_use_pk);
END;
/



DBMS_REDEFINITION.ABORT_REDEF_TABLE

CREATE SNAPSHOT "T24LIVE"."F_EB_USER_CONTEXT_INI"
   ON PREBUILT TABLE WITH REDUCED PRECISION
   REFRESH FAST WITH PRIMARY KEY
AS
   SELECT *
     FROM "T24LIVE"."F_EB_USER_CONTEXT" "F_EB_USER_CONTEXT"
	 
--Elapsed: 00:02:20.90

--4. Copy dependent objects. (Automatically create any triggers, indexes, materialized view logs, grants, and constraints
DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('T24LIVE','F_EB_USER_CONTEXT','F_EB_USER_CONTEXT_INI',   DBMS_REDEFINITION.cons_use_pk, TRUE, TRUE, TRUE, TRUE, num_errors, FALSE);
END;
/
--Elapsed: 00:02:04.24

--5. Query the DBA_REDEFINITION_ERRORS view to check for errors.
select object_name, base_table_name, ddl_txt from       DBA_REDEFINITION_ERRORS;

--6. Synchronize the interim table 
BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('T24LIVE', 'F_EB_USER_CONTEXT','F_EB_USER_CONTEXT_INI');
END;
/

--7. Complete the redefinition
BEGIN
DBMS_REDEFINITION.FINISH_REDEF_TABLE('T24LIVE', 'F_EB_USER_CONTEXT','F_EB_USER_CONTEXT_INI');
END;
/ 

--Elapsed: 00:00:04.69