--CREATE OR REPLACE PROCEDURE MOBR5.DROP_OLD_PARTITION AS

DECLARE
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   cmd1          VARCHAR2 (256);
   dem           NUMBER;

   CURSOR c_table
   IS
        SELECT table_name
          FROM all_tables
         WHERE     table_name IN ('MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS','EVT_ENTRY_HANDLER')
               AND owner = 'MOBR5'
      ORDER BY 1 DESC;
BEGIN
   FOR cc IN c_table
   LOOP
      IF cc.table_name = 'EVT_ENTRY_HANDLER'
      THEN
         FOR c_partition
            IN (  SELECT table_name, partition_name, HIGH_VALUE
                    FROM all_tab_partitions
                   WHERE     table_name = 'EVT_ENTRY_HANDLER'
                         AND partition_name NOT IN ('EVT_ENTRY_HANDLER_P1','SYS_P321')
                         AND table_owner = 'MOBR5'
                ORDER BY 1, 2 DESC)
         LOOP
            v_highvalue := SUBSTR (c_partition.HIGH_VALUE, 12, 10);
            v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');

            IF v_date < TO_DATE (SYSDATE) - 40
            THEN
               cmd := 'select count(*)  from MOBR5.'|| c_partition.table_name|| ' partition (' || c_partition.partition_name|| ')';
               EXECUTE IMMEDIATE cmd INTO dem;

               IF dem = 0
               THEN
                  cmd1 := 'alter table MOBR5.' || c_partition.table_name || ' drop partition ' || c_partition.partition_name || ' update global indexes parallel 4';
                  DBMS_OUTPUT.put_line (cmd1);
               --EXECUTE IMMEDIATE cmd1;
               END IF;
            END IF;
         END LOOP;

         --Rebuild index
         FOR c_idx
            IN (SELECT owner, index_name, partitioned
                  FROM dba_indexes
                 WHERE     owner || '.' || table_name ='MOBR5.EVT_ENTRY_HANDLER'
                       AND index_type NOT LIKE 'LOB%'
                       AND index_type <> 'FUNCTION-BASED NORMAL')
         LOOP
            cmd := 'alter index '|| c_idx.owner|| '.'|| c_idx.index_name|| ' rebuild online';
            DBMS_OUTPUT.put_line (cmd);
         --EXECUTE IMMEDIATE cmd;
         END LOOP;
         
      ELSE
         FOR c_partition
            IN (  SELECT table_name, partition_name, HIGH_VALUE
                    FROM all_tab_partitions
                   WHERE     table_name =cc.table_name
                         AND partition_name NOT IN ('AUDIT_P1', 'TRACERQS_P1', 'AUDIT_P2', 'SYS_P724', 'SYS_P721')
                         AND table_owner = 'MOBR5'
                ORDER BY 1, 2 DESC)
         LOOP
            v_highvalue := SUBSTR (c_partition.HIGH_VALUE, 12, 10);
            v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');

            IF v_date < TO_DATE (SYSDATE) - 40
            THEN
               cmd := 'select count(*)  from MOBR5.' || c_partition.table_name|| ' partition ('|| c_partition.partition_name || ')';
               EXECUTE IMMEDIATE cmd INTO dem;

               IF dem = 0
               THEN
                  cmd1 := 'alter table MOBR5.'|| c_partition.table_name|| ' drop partition '|| c_partition.partition_name;
                  DBMS_OUTPUT.put_line (cmd1);
               --EXECUTE IMMEDIATE cmd1;
               END IF;
            END IF;
         END LOOP;
      END IF;
   END LOOP;
END;
/


CREATE OR REPLACE procedure SYS.DBA_LOCK_90DAYS_EXP_ACC as
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   dem           NUMBER;

   CURSOR c_users
   IS
      SELECT username
        FROM dba_users
       WHERE     PROFILE = 'PROFILE_ENDUSER'
             AND username NOT IN ('MOBR5','MBBREADONLY')
             AND SYSDATE - expiry_date > 90;
BEGIN
   FOR cc IN c_users
   LOOP
      cmd := 'ALTER USER ' || cc.username || ' ACCOUNT LOCK';
      DBMS_OUTPUT.put_line (cmd);
      EXECUTE IMMEDIATE cmd;
   END LOOP;
END;
/


BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_LOCK_90DAYS_EXP_ACC'
      ,start_date      => TO_TIMESTAMP_TZ('2019/04/07 23:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY;BYDAY=SUN;INTERVAL=1;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_LOCK_90DAYS_EXP_ACC'
      ,comments        => 'Job to lock account which is expire 90 day'
    );
END;
/
BEGIN
  SYS.DBMS_SCHEDULER.ENABLE
    (name  => 'SYS.DBA_JOB_LOCK_90DAYS_EXP_ACC');
END;
/



BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
      ,start_date      => TO_TIMESTAMP_TZ('2018/05/05 23:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=YEARLY;BYMONTH=4,8;BYMONTHDAY=21,22,23,24,25,26,27;BYDAY=SAT;INTERVAL=1;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_DROP_PARTITION_YEARLY'
      ,comments        => 'Job to drop partition yearly (on Apr and Aug) of T24LIVE'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_DROP_PARTITION_YEARLY'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);
END;
/



declare
   cmd            VARCHAR2 (4000);
   timeStart      DATE;
   timeEnd        DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   post_rebuild number;
   pre_rebuild number;
   CURSOR c_idx
   IS

  select b.owner,b.object_name, b.subobject_name, sum(logical_reads_delta + physical_reads_delta)
from DBA_HIST_SEG_STAT a, dba_objects b, dba_hist_snapshot c, dba_indexes d
where a.obj#=B.OBJECT_ID
and A.SNAP_ID || A.DBID || A.INSTANCE_NUMBER =C.SNAP_ID || C.DBID || C.INSTANCE_NUMBER
and c.begin_interval_time>sysdate-1
and b.owner like 'T24%'
and b.object_type like'INDEX%'
and b.owner||'.'||b.object_name=d.owner||'.'||d.index_name
and d.index_type not in ('LOB','FUNCTION-BASED NORMAL')
group by b.owner,b.object_name, b.subobject_name
order by 4 desc;
BEGIN
   FOR idx IN c_idx
   LOOP

      if idx.subobject_name is null then
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = idx.object_name
         GROUP BY segment_name;

         cmd := 'alter index T24LIVE.' || idx.object_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

           SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = idx.object_name
         GROUP BY segment_name;

--         INSERT INTO sys.index_rebuild_online_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
--              VALUES (idx.table_name, idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);
--
--         COMMIT;

      else

      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = idx.object_name and partition_name=idx.subobject_name
         GROUP BY segment_name,partition_name;

         cmd := 'alter index T24LIVE.' || idx.object_name || ' rebuild partition '||idx.subobject_name||' online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
--         EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = idx.object_name and partition_name=idx.subobject_name
         GROUP BY segment_name,partition_name;

--         INSERT INTO sys.index_rebuild_online_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
--              VALUES (idx.table_name, idx.index_name||'.'||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);
--              commit;

      end if;

      END LOOP;


EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/


declare
   cmd2            VARCHAR2 (4000);
   cmd3            VARCHAR2 (4000);
   cmd4            VARCHAR2 (4000);
   cmd5            VARCHAR2 (4000);
   ind             VARCHAR2 (50);
   resource_busy   EXCEPTION;
   str             VARCHAR2 (4000);
   dem             NUMBER;
     size_before   number;
  size_after   number;
   timeStart      DATE;
   timeEnd        DATE;
   elapsed        VARCHAR2 (50);     
   PRAGMA EXCEPTION_INIT (resource_busy, -54);
   
   CURSOR c_tab
   IS
        SELECT owner, table_name, partitioned
          FROM dba_tables
         WHERE     table_name in ('FBNK_TXN_LOG_TCB','F_USER','FBNK_EVN_LOG_TCB','FBNK_FTBU000','F_RE_BC_TRANGTHAI_4711','FBNK_DYNAMIC_TEXT#NAU','F_DE_O_PRI_ADVPRN','FBNK_FUNDS_TRANSFER','FBNK_AC_HVT_TRIGGER','F_DC_NEW_002','FBNK_ACCT_ENT_FWD','FBNK_LETTER_OF_CREDIT','FBNK_CUSTOMER#NAU','FBNK_PD_PAYMENT_DUE')
         AND owner = 'T24LIVE'
      ORDER BY 2;
BEGIN
   FOR v_tab IN c_tab
   LOOP
      BEGIN
      SELECT    sum(bytes)/1024/1024/1024 into size_before FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%' and segment_name=v_tab.table_name and owner='T24LIVE'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   
s.owner = l.owner AND   s.segment_type like 'LOB%' and l.table_name=v_tab.table_name and l.owner='T24LIVE'
);
         IF v_tab.partitioned = 'NO'
         THEN
            cmd2 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE TABLESPACE DATAT24LIVE';
            cmd3 := 'ALTER TABLE T24LIVE.'|| v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE DATAT24LIVE) ';
            timeStart := SYSDATE;
            --EXECUTE IMMEDIATE cmd2;
             DBMS_OUTPUT.put_line (cmd2);
            --EXECUTE IMMEDIATE cmd3;
            DBMS_OUTPUT.put_line (cmd3);

            FOR c_idx
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE'  AND index_type <> 'LOB')
            LOOP
               cmd4 := 'ALTER INDEX T24LIVE.' || c_idx.index_name || ' REBUILD TABLESPACE INDEXT24LIVE ONLINE';
               --EXECUTE IMMEDIATE cmd4;
               DBMS_OUTPUT.put_line (cmd4);
               
            END LOOP;
            timeEnd := SYSDATE;
            
         ELSE
         timeStart := SYSDATE;
            FOR c_par
               IN (SELECT partition_name, partition_position
                     FROM dba_tab_partitions
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE')
            LOOP
               cmd2 := 'alter table T24LIVE.' || v_tab.table_name|| ' move partition '||c_par.partition_name||' tablespace DATAT24LIVE';
               cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE PARTITION '||c_par.partition_name||' LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
               --EXECUTE IMMEDIATE cmd2;
               DBMS_OUTPUT.put_line (cmd2);
               --EXECUTE IMMEDIATE cmd3;
               DBMS_OUTPUT.put_line (cmd3);

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
                     --EXECUTE IMMEDIATE cmd4;
                     DBMS_OUTPUT.put_line (cmd4);
                  END LOOP;
               END LOOP;
            END LOOP;
timeEnd := SYSDATE;
            FOR c_idx2
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE' AND partitioned = 'NO' AND index_type <> 'LOB')
            LOOP
               cmd4 :='alter index T24LIVE.'|| c_idx2.index_name|| ' rebuild tablespace INDEXT24LIVE online';
               --EXECUTE IMMEDIATE cmd4;
               DBMS_OUTPUT.put_line (cmd4);
            END LOOP;
         END IF;
      EXCEPTION
         WHEN resource_busy
         THEN  str := str || SUBSTR (v_tab.table_name, 12) || '|';
      END;

      DBMS_OUTPUT.put_line (str);
SELECT    sum(bytes)/1024/1024/1024 into size_after FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%' and segment_name=v_tab.table_name and owner='T24LIVE'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   
s.owner = l.owner AND   s.segment_type like 'LOB%' and l.table_name=v_tab.table_name and l.owner='T24LIVE'
);
elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         DBMS_OUTPUT.put_line ( 'Elapsed time: '|| substr(elapsed,10,10));
               insert into  sys.TABLE_REDEFINITION_LOG (table_name ,start_time,elapsed_time,size_before,size_after ) values (v_tab.table_name,
               timeStart, substr(elapsed,10,10),size_before,size_after );
               commit;
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
                 WHERE     table_name in ('FBNK_TXN_LOG_TCB','F_USER','FBNK_EVN_LOG_TCB','FBNK_FTBU000','F_RE_BC_TRANGTHAI_4711','FBNK_DYNAMIC_TEXT#NAU','F_DE_O_PRI_ADVPRN','FBNK_FUNDS_TRANSFER','FBNK_AC_HVT_TRIGGER','F_DC_NEW_002','FBNK_ACCT_ENT_FWD','FBNK_LETTER_OF_CREDIT','FBNK_CUSTOMER#NAU','FBNK_PD_PAYMENT_DUE') AND table_owner = 'T24LIVE'  AND status = 'UNUSABLE')
         LOOP
            cmd5 :=  'alter index T24LIVE.'  || c_idx3.index_name || ' rebuild tablespace INDEXT24LIVE online';
            --EXECUTE IMMEDIATE cmd5;
            DBMS_OUTPUT.put_line (cmd5);
         END LOOP;

         FOR c_idx4
            IN (SELECT index_owner, index_name, partition_name
                  FROM dba_ind_partitions
                 WHERE     index_owner = 'T24LIVE'  AND status = 'UNUSABLE'
                       AND index_name IN (SELECT index_name FROM dba_indexes
                                           WHERE     table_name in ('FBNK_TXN_LOG_TCB','F_USER','FBNK_EVN_LOG_TCB','FBNK_FTBU000','F_RE_BC_TRANGTHAI_4711','FBNK_DYNAMIC_TEXT#NAU','F_DE_O_PRI_ADVPRN','FBNK_FUNDS_TRANSFER','FBNK_AC_HVT_TRIGGER','F_DC_NEW_002','FBNK_ACCT_ENT_FWD','FBNK_LETTER_OF_CREDIT','FBNK_CUSTOMER#NAU','FBNK_PD_PAYMENT_DUE') AND table_owner = 'T24LIVE'))
         LOOP
            cmd5 :='alter index T24LIVE.'|| c_idx4.index_name|| ' rebuild partition '|| c_idx4.partition_name|| ' tablespace INDEXT24LIVE online';
            --EXECUTE IMMEDIATE cmd5;
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


CREATE TABLE SYS.TABLE_REDEFINITION_LOG
(
  TABLE_NAME    VARCHAR2(150 BYTE),
  START_TIME    DATE,
  ELAPSED_TIME  VARCHAR2(50 BYTE),
  size_before   number,
  size_after   number
)

CREATE USER THUYNTM_DBA
  IDENTIFIED BY <password>
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP_NEW
  PROFILE DBA_PROFILE
  ACCOUNT UNLOCK;
  -- 2 Roles for THUYNTM_DBA 
  GRANT CONNECT TO THUYNTM_DBA;
  GRANT DBA TO THUYNTM_DBA;
  ALTER USER THUYNTM_DBA DEFAULT ROLE ALL;
  -- 1 System Privilege for THUYNTM_DBA 
  GRANT UNLIMITED TABLESPACE TO THUYNTM_DBA;
  -- 2 Object Privileges for THUYNTM_DBA 
    GRANT DELETE, INSERT, UPDATE ON SYS.TABLE_ARCHIVE TO THUYNTM_DBA;
    GRANT DELETE, INSERT, UPDATE ON SYS.TABLE_ARCHIVE_LOG TO THUYNTM_DBA;





select *
from
(
select o_ci_id, 'function1' as col_label, count(1) as val
  FROM CITADGW.tbltransactionmsg_org
WHERE  TRX_DATE = '20171020' and o_ci_id in ('97310001','79310001','97310005','97310012')
group by o_ci_id
union
SELECT  o_ci_id, 'function2' as col_label,count(1) val
  from CITADGW.tbltransactionmsg_org
WHERE TRX_DATE  like '2018%'
  AND O_CI_ID in ('79310001','97310001','97310005','97310012')
  AND PROCESS < '5'
  group by o_ci_id
union
SELECT o_ci_id,'function3' as col_label, count(1) val
  from CITADGW.tbltransactionmsg_org
WHERE TRX_DATE like '2018%'
  AND O_CI_ID in ('79310001','97310001','97310005','97310012')
  AND (response_code =  '????' or (response_code is null and process = '5'))
group by o_ci_id
union
SELECT o_ci_id,'function4' as col_label,count(1) val
  FROM CITADGW.tbltransactionmsg_org
WHERE  TRX_DATE like '2018%'
  AND O_CI_ID in ('79310001','97310001','97310005','97310012')
  AND SUBSTR(RESPONSE_CODE, 2, 3) <> '000'
  AND RESPONSE_CODE <> '????'
  AND PROCESS in('7','8','9')
group by o_ci_id
union
SELECT o_ci_id,'function5' as col_label,count(1) val
  FROM CITADGW.tbltransactionmsg_org
WHERE  TRX_DATE like '2018%'
  AND O_CI_ID in ('79310001','97310001','97310005','97310012')
  AND SUBSTR(RESPONSE_CODE, 2, 3) = '000'
group by o_ci_id
)
pivot (max(val) FOR (col_label) IN ('function1','function2','function3','function4','function5'));


v_cmd:='BEGIN DBMS_STATS.GATHER_SCHEMA_STATS (OwnName => ''SYS'', Options => ''GATHER'', Estimate_Percent   => DBMS_STATS.auto_sample_size,Method_Opt => ''FOR ALL COLUMNS SIZE AUTO'', Degree => 7); END;';
execute immediate v_cmd;


SELECT distinct CASE
          WHEN A.host_name LIKE 'd_-oradb-0_' THEN 'FARMZ'
          WHEN A.host_name LIKE 'd_-ora-db0_' THEN 'FARM_OLD'
          WHEN A.host_name LIKE 'd_-citad%' THEN 'CITAD'
          WHEN A.host_name LIKE 'dw0_%' THEN 'DWH'
          WHEN A.host_name = 'dc-emv-db.Headquarter.techcombank.com.vn' THEN 'EMV'
          WHEN A.host_name LIKE 'd_-esb-db-0_' THEN 'ESB'
          WHEN A.host_name LIKE 'd_-core-db-0_' THEN 'T24'
          WHEN A.host_name LIKE 'd_-tcbs-db-0_' THEN 'TCBS'
          WHEN A.host_name LIKE 'd_-card-db-0_' THEN 'CARD'
          WHEN A.host_name='dc-em13c-db01.techcombank.com.vn' THEN 'EM13C'
          ELSE             A.host_name
       END host_name,
       Case 
            When A.type_qualifier3='RACINST' then  substr(A.target_name,0,length(A.target_name)-1)
            else A.target_name
       end target_name, 
       Case
            when Db_Audit is null then 'data not collected'
            when Db_Audit <29 and B.target_name in ('t24r14dc1','t24r14dc2','t24rptdc_1','t24rptdc_2','t24rptdr_1','t24rptdr_2','monthend1','year12','year13','year14','year15','year16','year17') 
            then 'NOK - '||Db_Audit||'/29'
            else 'OK'
       end Db_Audit, 
       Case
            when DB_param='false|true|os|false|true|10|drop,3|log|false|true' then 'OK'
            when DB_param is null then 'data not collected'
            else 'NOK'
       end param,           
       Case 
            when Public_privs=0 then 'OK'
            when Public_privs>0 then 'NOK'
            when Public_privs is null then 'data not collected'
       end Public_privs, 
       Case 
            when user_profile ='MDSYS' then 'OK'
            when user_profile is null then 'data not collected'
            else 'NOK'
       end user_profile, 
       case 
            when Profile_Enduser like '16.%|%|%|%|5|%|%|%|10|60|1|4|240|%verify_function|%|10' then 'OK'
            when Profile_Enduser is null then 'data not collected'
            when Profile_Enduser like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_Enduser, 
       Case
            when Profile_Service like '16.%|%|%|%|unlimited|%|%|%|%|unlimited|%|%|%|%verify_function|%|unlimited' then 'OK'
            when Profile_Service is null then 'data not collected'
            when Profile_Service like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_Service, 
       case 
            when Profile_DBA like '16.%|%|%|%|5|%|%|%|%|unlimited|1|%|%|%verify_function|%|%' then 'OK'
            when Profile_DBA is null then 'data not collected'
            when Profile_DBA like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_DBA

       Case
            when Db_Audit is null then 'data not collected'
            when Db_Audit <29 and B.target_name in ('t24r14dc1','t24r14dc2','t24rptdc_1','t24rptdc_2','t24rptdr_1','t24rptdr_2','monthend1','year12','year13','year14','year15','year16','year17') 
            then 'NOK - '||Db_Audit||'/29'
            else 'OK'
       end Db_Audit, 
       
              Case
            when DB_param='false|true|os|false|true|10|drop,3|log|false|true' then 'OK'
            when DB_param is null then 'data not collected'
            else 'NOK'
       end param,  
       
              Case 
            when Public_privs=0 then 'OK'
            when Public_privs>0 then 'NOK'
            when Public_privs is null then 'data not collected'
       end Public_privs,

select target_name,
max(case when metric_name= 'ME$TCTSCH_Audit' and VALUE=29 then 'ok' 
         when metric_name= 'ME$TCTSCH_Audit' and value!=29 then 'nok' end) AS Audit_DB,
max(case when metric_name= 'ME$TCTSCH_DB_param' and VALUE='false|true|os|false|true|10|drop,3|log|false|true' then 'ok' 
        when metric_name= 'ME$TCTSCH_DB_param' and VALUE <>'false|true|os|false|true|10|drop,3|log|false|true' then 'nok' end) AS DB_PARAM,
max(case when metric_name= 'ME$TCTSCH_Public_privs' and VALUE=0 then 'ok' 
else 'nok' end) AS Public_privs
--max(DECODE(metric_name, 'ME$TCTSCH_Audit', VALUE, '')) AS Audit_DB,
--max(DECODE(metric_name, 'ME$TCTSCH_DB_param', VALUE, '')) AS DB_parameter,
--max(DECODE(metric_name, 'ME$TCTSCH_Public_privs', VALUE, '')) AS Public_privs,
--max(DECODE(metric_name, 'ME$TCTSCH_user_profile', VALUE, '')) AS User_profile,
--max(DECODE(metric_name, 'ME$TCTSCH_Profile_Enduser', VALUE, '')) AS Profile_Enduser,
--max(DECODE(metric_name, 'ME$TCTSCH_Profile_Service', VALUE, '')) AS Profile_Service,
--max(DECODE(metric_name, 'ME$TCTSCH_Profile_dba', VALUE, '')) AS Profile_dba
 from (
SELECT     c.target_name ,c.metric_name, value
          FROM mgmt$metric_current c,  mgmt$target tar , mgmt$availability_current  avai
         WHERE    tar.target_type = 'oracle_database'
               AND c.target_name=tar.target_name
               AND tar.type_qualifier4 NOT LIKE '%Standby'
               AND avai.AVAILABILITY_STATUS = 'Target Up'
               AND tar.target_name=avai.target_name
               AND c.metric_name in ('ME$TCTSCH_Audit','ME$TCTSCH_DB_param','ME$TCTSCH_Public_privs','ME$TCTSCH_user_profile','ME$TCTSCH_Profile_Enduser','ME$TCTSCH_Profile_Service','ME$TCTSCH_Profile_dba') 
               AND c.collection_timestamp > SYSDATE - 1           
               )
               group by target_name
               
               pivot (max(VALUE) FOR (metric_name) IN ('ME$TCTSCH_Audit','ME$TCTSCH_DB_param','ME$TCTSCH_Public_privs','ME$TCTSCH_user_profile','ME$TCTSCH_Profile_Enduser','ME$TCTSCH_Profile_Service','ME$TCTSCH_Profile_dba'));
order by 1               
               

			   ==============================
			   
			   DECLARE
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (1000);   
   cmd1          VARCHAR2 (1000);
   cmd2          VARCHAR2 (1000);
   cmd3          VARCHAR2 (1000);
   arc_time      VARCHAR2 (128);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   post_rebuild number;
   pre_rebuild number;
   trigg_name      VARCHAR2 (128);
   have_trigg      number;
   
   CURSOR c_partitions
   IS
      SELECT owner,table_name 
        FROM SYS.dba_tables
       WHERE owner || '.' || table_name IN ('THUYNTM_DBA.XML_TEST');
       --('ESBDATA.PG_TRANSLOG','ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE');
BEGIN
   FOR cc IN c_partitions
   LOOP
      IF cc.owner||'.'||cc.table_name = 'THUYNTM_DBA.XML_TEST'--'ESBDATA.PG_TRANSLOG'
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -31 ';
      END IF;
      
      IF cc.owner||'.'||cc.table_name in ( 'ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE')
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -170 ';
      END IF;
      
      cmd :='select owner||''.''||trigger_name  from dba_triggers where table_owner||''.''||table_name='''||cc.owner||'.'||cc.table_name||'''  and triggering_event=''DELETE''';
      execute immediate cmd into trigg_name;
      cmd1 := 'ALTER TRIGGER '||trigg_name||' ENABLE';
      cmd2 := 'delete from '|| cc.owner||'.'||cc.table_name || arc_time||' and rownum<10001';
      cmd3 := 'ALTER TRIGGER '||trigg_name||' DISABLE';
            --enable trigger 
            have_trigg := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (cmd);
            --DBMS_OUTPUT.put_line (have_trigg);
            if have_trigg >0 then
            DBMS_OUTPUT.put_line (cmd1);
            execute immediate cmd1 ;

            --delete
            DBMS_OUTPUT.put_line (cmd2);
            timeStart := SYSDATE;
            --execute immediate cmd2;
            timeEnd := SYSDATE;
            counter := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (counter);
            COMMIT;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               insert into  sys.table_archive_log (table_name ,start_time,numrow_del ,elapsed_time ) 
               values (cc.owner||'.'||cc.table_name,timeStart,counter, substr(elapsed,10,10));
               commit; 
                
            --disable trigger 
            DBMS_OUTPUT.put_line (cmd3);
            --execute immediate cmd3 ;    
            end if;                      
  
      --Rebuild index
      FOR c_idx IN (SELECT owner,index_name,partitioned
                      FROM dba_indexes
                     WHERE owner||'.'||table_name = cc.owner||'.'||cc.table_name  and index_type not like 'LOB%' and index_type <> 'FUNCTION-BASED NORMAL'
                     )
      LOOP
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         cmd := 'alter index ' ||c_idx.owner||'.'|| c_idx.index_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         /*INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);

         COMMIT;*/
      END LOOP;
      
      
   END LOOP;
END;
/

==========================






CREATE TABLE THUYNTM_DBA.XML_TEST
(
  RECID      VARCHAR2(255 BYTE),
  XMLRECORD  SYS.XMLTYPE
)
XMLTYPE XMLRECORD STORE AS CLOB (
  TABLESPACE  DATAT24LIVE
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  PCTVERSION  10
  NOCACHE
  NOLOGGING)
NOCOMPRESS 
TABLESPACE DATAT24LIVE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    20
INITRANS   120
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY HASH (RECID)
  PARTITIONS 256
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX THUYNTM_DBA.XML_TEST_PAR_PK ON THUYNTM_DBA.XML_TEST
(RECID)
  TABLESPACE DATAT24LIVE
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;


ALTER TABLE THUYNTM_DBA.XML_TEST ADD (
  CONSTRAINT XML_TEST_PAR_PK
  PRIMARY KEY
  (RECID)
  USING INDEX LOCAL
  ENABLE VALIDATE);
  
  
 
  CREATE TABLE THUYNTM_DBA.XML_TEST_HIST
(
  RECID      VARCHAR2(255 BYTE),
  XMLRECORD  SYS.XMLTYPE
)
XMLTYPE XMLRECORD STORE AS CLOB (
  TABLESPACE  DATAT24LIVE
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  PCTVERSION  10
  NOCACHE
  NOLOGGING)
NOCOMPRESS 
TABLESPACE DATAT24LIVE
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    20
INITRANS   120
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY HASH (RECID)
  PARTITIONS 256
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX THUYNTM_DBA.XML_TEST_PAR_HIS_PK ON THUYNTM_DBA.XML_TEST_HIST
(RECID)
  TABLESPACE DATAT24LIVE
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;
  
  
---merge
declare
x number;
y number;
cmd varchar2(4000);
BEGIN  
FOR loop_counter IN 1..10000
LOOP 
x := round(dbms_random.value(1,1000));
y := dbms_random.value(1,100000);
cmd :='MERGE INTO THUYNTM_DBA.XML_TEST USING DUAL ON (RECID like '''||x||'.%'') '||                                                     
'WHEN MATCHED THEN UPDATE SET XMLRECORD=XMLTYPE(''<row id="'||y||'COMPOSITE.SCREEN_'||y||'_823480617001" xml:space="preserve"><c2>AI.USER.RSA.DATE.NULL</c2><c3>ARCUSER</c3><c4>COMPOSITE.SCREEN_0968563075_823480617001</c4><c5/><c6>'||x||'</c6></row>'', NULL, 1, 1)                                                                     
WHEN NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(XMLTYPE(''<row id="'||y||'COMPOSITE.SCREEN_'||y||'_823480617001" xml:space="preserve"><c2>AI.USER.RSA.DATE.NULL</c2><c3>ARCUSER</c3><c4>COMPOSITE.SCREEN_0968563075_823480617001</c4><c5/><c6>'||x||'</c6></row>'', NULL, 1, 1) ,'''
||x||'.INSERT.'||round(DBMS_RANDOM.VALUE(100,10000),10)||''')';
execute immediate (cmd);
--DBMS_OUTPUT.put_line (cmd);
COMMIT;
END LOOP;  
END;
/


--enable trigger
DECLARE
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (1000);   
   cmd1          VARCHAR2 (1000);
   cmd2          VARCHAR2 (1000);
   cmd3          VARCHAR2 (1000);
   arc_time      VARCHAR2 (128);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   post_rebuild number;
   pre_rebuild number;
   trigg_name      VARCHAR2 (128);
   have_trigg      number;
   
   CURSOR c_partitions
   IS
      SELECT owner,table_name 
        FROM SYS.dba_tables
       WHERE owner || '.' || table_name IN ('THUYNTM_DBA.XML_TEST');
       --('ESBDATA.PG_TRANSLOG','ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE');
BEGIN
   FOR cc IN c_partitions
   LOOP
      IF cc.owner||'.'||cc.table_name = 'THUYNTM_DBA.XML_TEST'--'ESBDATA.PG_TRANSLOG'
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -31 ';
      END IF;
      
      IF cc.owner||'.'||cc.table_name in ( 'ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE')
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -170 ';
      END IF;
      
      cmd :='select owner||''.''||trigger_name  from dba_triggers where table_owner||''.''||table_name='''||cc.owner||'.'||cc.table_name||'''  and triggering_event=''DELETE''';
      execute immediate cmd into trigg_name;
      cmd1 := 'ALTER TRIGGER '||trigg_name||' ENABLE';
      cmd2 := 'delete from '|| cc.owner||'.'||cc.table_name || arc_time||' and rownum<10001';
      cmd3 := 'ALTER TRIGGER '||trigg_name||' DISABLE';
            --enable trigger 
            have_trigg := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (cmd);
            --DBMS_OUTPUT.put_line (have_trigg);
            if have_trigg >0 then
            DBMS_OUTPUT.put_line (cmd1);
            execute immediate cmd1 ;

            --delete
            DBMS_OUTPUT.put_line (cmd2);
            timeStart := SYSDATE;
            --execute immediate cmd2;
            timeEnd := SYSDATE;
            counter := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (counter);
            COMMIT;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               insert into  sys.table_archive_log (table_name ,start_time,numrow_del ,elapsed_time ) 
               values (cc.owner||'.'||cc.table_name,timeStart,counter, substr(elapsed,10,10));
               commit; 
                
            --disable trigger 
            DBMS_OUTPUT.put_line (cmd3);
            --execute immediate cmd3 ;    
            end if;                      
  
      --Rebuild index
      FOR c_idx IN (SELECT owner,index_name,partitioned
                      FROM dba_indexes
                     WHERE owner||'.'||table_name = cc.owner||'.'||cc.table_name  and index_type not like 'LOB%' and index_type <> 'FUNCTION-BASED NORMAL'
                     )
      LOOP
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         cmd := 'alter index ' ||c_idx.owner||'.'|| c_idx.index_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         /*INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);

         COMMIT;*/
      END LOOP;
      
      
   END LOOP;
END;
/


DECLARE
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);   
   cmd1          VARCHAR2 (128);
   cmd2          VARCHAR2 (128);
   arc_time      VARCHAR2 (128);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   timeCheck      DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   post_rebuild number;
   pre_rebuild number;
   
   CURSOR c_partitions
   IS
      SELECT owner,table_name 
        FROM SYS.dba_tables
       WHERE owner || '.' || table_name IN ('T24LIVE.F_OS_TOKEN');
       --('ESBDATA.PG_TRANSLOG','ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE');
BEGIN
   FOR cc IN c_partitions
   LOOP
      IF cc.owner||'.'||cc.table_name = 'T24LIVE.F_OS_TOKEN'--'ESBDATA.PG_TRANSLOG'
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -31 ';
      END IF;
      
      IF cc.owner||'.'||cc.table_name in ( 'ESBTAX.OSB_QUEUE_OUT','ESBTAX.OSB_QUEUE')
      THEN
            arc_time := ' where logtime < trunc(sysdate,''MM'') -170 ';
      END IF;
      
      cmd1 := 'insert into '|| cc.owner||'.'||cc.table_name || '_HIS select * from '|| cc.owner||'.'||cc.table_name || arc_time;
      cmd2 := 'delete from '|| cc.owner||'.'||cc.table_name || arc_time||' and rownum<1000001';
      
            --insert 
            DBMS_OUTPUT.put_line (cmd1);
            timeStart := SYSDATE;
            --execute immediate cmd1 ;
            timeEnd := SYSDATE;
            counter := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (counter);
            COMMIT;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               /*insert into  sys.table_archive_log (table_name ,start_time,numrow_del ,elapsed_time ) 
               values (cc.owner||'.'||cc.table_name||'_HIS',timeStart,counter, substr(elapsed,10,10));
               commit;*/
               
            --delete
            DBMS_OUTPUT.put_line (cmd2);
            timeStart := SYSDATE;
            --execute immediate cmd2;
            timeEnd := SYSDATE;
            counter := SQL%ROWCOUNT;
            DBMS_OUTPUT.put_line (counter);
            COMMIT;
            elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               /*insert into  sys.table_archive_log (table_name ,start_time,numrow_del ,elapsed_time ) 
               values (cc.owner||'.'||cc.table_name,timeStart,counter, substr(elapsed,10,10));
               commit;*/               
  
      --Rebuild index
      FOR c_idx IN (SELECT owner,index_name,partitioned
                      FROM dba_indexes
                     WHERE owner||'.'||table_name = cc.owner||'.'||cc.table_name  and index_type not like 'LOB%' and index_type <> 'FUNCTION-BASED NORMAL'
                     )
      LOOP
      SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         cmd := 'alter index ' ||c_idx.owner||'.'|| c_idx.index_name || ' rebuild online';
         DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner||'.'||segment_name = c_idx.owner||'.'||c_idx.index_name
         GROUP BY segment_name;

         /*INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);

         COMMIT;*/
      END LOOP;
      
      
   END LOOP;
END;
/



IF cc.tab = 'ESBDATA.ACCOUNTING_TRANSACTION'
      THEN
         FOR c_drop
            IN (  SELECT table_owner,table_name,partition_name,HIGH_VALUE
                    FROM SYS.dba_tab_partitions
                   WHERE     table_owner || '.' || table_name =cc.tab
                         AND PARTITION_NAME <> 'ACCOUNTING_TRANSACTION_P1'
                         AND partition_position <
                                (SELECT MAX (partition_position) - 4
                                   FROM SYS.dba_tab_partitions
                                  WHERE table_owner || '.' || table_name =cc.tab)
                ORDER BY partition_position)
         LOOP
            v_highvalue := SUBSTR (c_drop.HIGH_VALUE, 12, 10);
            v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');

            IF v_date < TO_DATE (SYSDATE) - 95
            THEN
               DBMS_OUTPUT.put_line (v_highvalue);
               cmd := 'alter table '|| cc.tab || ' drop partition ' || c_drop.partition_name || ' update indexes';
               DBMS_OUTPUT.put_line (cmd);
            END IF;
         END LOOP;
      END IF;


FBNK_TXN_LOG_TCB	SYS_IL0058131689C00003$$	0.0068359375
FBNK_TXN_LOG_TCB	SYS_LOB0058131689C00003$$	0.8427734375
FBNK_TXN_LOG_TCB	FBNK_TXN_LOG_TCB	1.3330078125
FBNK_TXN_LOG_TCB	FBNK_TXN_LOG_TCB_P1_PK	0.03125

FBNK_TXN_LOG_TCB	SYS_IL0058131689C00003$$	0.0068359375
FBNK_TXN_LOG_TCB	SYS_LOB0058131689C00003$$	20.9697265625
FBNK_TXN_LOG_TCB	FBNK_TXN_LOG_TCB	1.2900390625
FBNK_TXN_LOG_TCB	FBNK_TXN_LOG_TCB_P1_PK	0.0400390625


FBNK_TIETKIEMGIAODUC	FBNK_TIETKIEMGIAODUC	1
FBNK_TIETKIEMGIAODUC	SYS_LOB0000125361C00003$$	1.123046875
FBNK_TIETKIEMGIAODUC	SYS_IL0000125361C00003$$	0.0546875
FBNK_TIETKIEMGIAODUC	FBNK_TIETKIEMGIAODUC_P1_PK	0.0078125

FBNK_TIETKIEMGIAODUC	FBNK_TIETKIEMGIAODUC	1.0029296875
FBNK_TIETKIEMGIAODUC	SYS_LOB0000125361C00003$$	1.1171875
FBNK_TIETKIEMGIAODUC	SYS_IL0000125361C00003$$	0.0546875
FBNK_TIETKIEMGIAODUC	FBNK_TIETKIEMGIAODUC_P1_PK	0.0078125


CREATE OR REPLACE function SYS.ora12c_strong_verify_function
(username varchar2,
 password varchar2,
 old_password varchar2)
return boolean IS
   differ integer;
begin
   if not ora_complexity_check(password, chars => 9, upper => 2, lower => 2,
                           digit => 2, special => 2) then
      return(false);
   end if;

   -- Check if the password differs from the previous password by at least
   -- 4 characters
   if old_password is not null then
      differ := ora_string_distance(old_password, password);
      if differ < 4 then
         raise_application_error(-20032, 'Password should differ from previous '
                                 || 'password by at least 4 characters');
      end if;
   end if;

   return(true);
end;
/




9/14/2018 4:32:38 PM	73msngn4qx7v2	5	SELECT RECID, t.XMLRECORD.GetClobVal() FROM F_PROTOCOL t
5480	33523
c3wtw65vn8nhy SELECT t.RECID FROM FBNK_CUSTOMER t ORDER BY NVL(XMLCAST(XMLQUERY('$v/row/c1' PASSING XMLRECORD AS "v" RETURNING CONTENT) AS VARCHAR(256)), CHR(1)) ,NUMSORT(RECID) 

bhjz9warg545n	SELECT t.RECID FROM FBNK_INFO_CARD t ORDER BY NUMSORT(RECID) 

tcb1 1vg7pk6a2nhag	SELECT RECID, t.XMLRECORD.GetClobVal() FROM FBNK_QUANLYTHE t


tcb1 bn011286 dvakwknyqtg7p	SELECT RECID, t.XMLRECORD.GetClobVal() FROM FBNK_FUNDS_TRANSFER t

jpqn@t24tcb1 (TNS V1-V3)	9/17/2018 2:34:24 PM	2d9uab6w7nvfd	18	SELECT RECID, t.XMLRECORD.GetClobVal() FROM FBNK_INFO_CARD t

DECLARE
   cmd         VARCHAR2 (4000);
   cmd2        VARCHAR2 (4000);
   my_cursor   SYS_REFCURSOR;

   CURSOR c_partitions
   IS
      SELECT DISTINCT table_owner, table_name, tablespace_name
        FROM dba_tab_partitions
       WHERE     tablespace_name = 'DATAT24LIVE'
             AND table_name IN ('FBNK_FUNDS_TRANSFER#HIS', 'FBNK_STMT_ENTRY');
BEGIN
   FOR cc IN c_partitions
   LOOP
       FOR cmd IN (SELECT * FROM ( SELECT PARTITION_NAME FROM dba_tab_partitions a, dba_users b  WHERE  tablespace_name =
          cc.tablespace_name AND a.TABLE_OWNER = b.USERNAME AND a.table_name = cc.table_name ORDER BY table_name,partition_position desc) where rownum<3)
        loop
        DBMS_OUTPUT.put_line (cc.table_owner||'     '||cc.table_name||'     '||cmd.PARTITION_NAME);
       end loop;
   END LOOP;
END;
/





DECLARE
   cmd2        VARCHAR2 (4000);

BEGIN
   FOR v_tab IN (Select instance_name from v$instance)
   LOOP
        cmd2 := 'create pfile=''/home/oracle/bkinit_'||v_tab.instance_name||'.ora'' from spfile';
        DBMS_OUTPUT.put_line (cmd2);
        -- EXECUTE IMMEDIATE cmd3;     

   END LOOP;
END;
/



DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);

   CURSOR c_tab
   IS
select table_name from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','REVOKE CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR  ','DBMS_JAVA  ','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY  ','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;


select  listagg( username,''',''') WITHIN GROUP (ORDER BY username)
from dba_users where account_status='OPEN' and username not in ('SYS','SYSTEM','T24_LIVE_DWH','T24LIVE')

BEGIN
   FOR v_tab IN c_tab
   LOOP
   
        cmd2 := 'select ''grant execute on ' || v_tab.table_name || 
        ' to  ''|| listagg( USERNAME,'','') WITHIN GROUP (ORDER BY DEFAULT_TABLESPACE) || ''''from dba_users where PROFILE in (''PROFILE_SERVICE_ACCOUNT'',''DEFAULT'')';
         --DBMS_OUTPUT.put_line (cmd2);
             EXECUTE IMMEDIATE cmd2 into cmd3; 
             DBMS_OUTPUT.put_line (cmd3);
            -- EXECUTE IMMEDIATE cmd3;     

   END LOOP;
END;
/


DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);

   CURSOR c_tab
   IS
select table_name from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','REVOKE CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR  ','DBMS_JAVA  ','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY  ','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;

BEGIN
   FOR v_tab IN c_tab
   LOOP
   for c_user in  (select username from dba_users where PROFILE in ('PROFILE_SERVICE_ACCOUNT','DEFAULT'))
   loop
        cmd2 := 'grant execute on ' || v_tab.table_name || ' to '||c_user.username;
         DBMS_OUTPUT.put_line (cmd2);
       --      EXECUTE IMMEDIATE cmd4;   
    end loop;
   END LOOP;
END;
/


select bytes/1024/1024/1024 from dba_segments where segment_name='PK_FBNK_RE_C019'

46.8076171875

30.5706787109375



-------------NEW
ALTER TABLE SYS.TABLE_ARCHIVE ADD (Keep_year NUMBER);
ALTER TABLE SYS.TABLE_ARCHIVE ADD (archive_year NUMBER);
SET DEFINE OFF;
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (1, 'T24LIVE.FBNK_PM_DLY_POSN_CLASS', 1, ' where recid like ''%.___.', '____.%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (2, 'T24LIVE.F_RE_BC_TRANGTHAI_4711', 1, ' where recid like ''%#___#', '____''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, add_condition, keep_year, archive_year)
 Values   (3, 'T24LIVE.FBNK_EB_B005', 1, 'FT', ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c2''),''^A'') <=', '1231', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values   (4, 'T24LIVE.FBNK_QUAN014', 1, ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c6''),''^A'')<=''', '1231', '''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (5, 'T24LIVE.FBNK_OD_ACCT_ACTIVITY', 1, ' where recid like ''______________-', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (6, 'T24LIVE.FBNK_FTBULK_TCB#HIS', 2, 'BC', ' where recid like ''BC', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (7, 'T24LIVE.F_FTBULK_000', 2, 'BC', ' where recid like ''BC', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (8, 'T24LIVE.F_FTBULK_CONTROL_TCB', 2, 'BC', ' where recid like ''BC', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values   (9, 'T24LIVE.FBNK_FTBU000', 2, 'BC', ' where recid like ''BC', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', '0', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', '1', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', '0', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', '2', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', '0', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', '1', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', '2', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', '1', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'FT', ' where recid like ''FT', '3', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', '3', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'TT', ' where recid like ''TT', '2', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (10, 'T24LIVE.FBNK_PM_TRAN_ACTIVITY', 2, 'DC', ' where recid like ''DC', '3', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'LOGOUT', ' where recid like ''%.LOGOUT.', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'ENQUIRY', ' where recid like ''%.ENQUIRY.', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'APPLICATION', ' where recid like ''%.APPLICATION.', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (11, 'T24LIVE.FBNK_AI_USER_LOG', 1, 'CHANGEPASS', ' where recid like ''%.CHANGEPASS.', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (14, 'T24LIVE.FBNK_RE_CONSOL_PROFIT', 1, ' where recid like ''%.VN001____.___.', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', '1', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', '0', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', '2', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (15, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', '3', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (16, 'T24LIVE.F_DE_O_HANDOFF', 1, 'D', ' where recid like ''D', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (17, 'T24LIVE.F_DE_O_HEADER', 1, 'D', ' where recid like ''D', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (18, 'T24LIVE.F_DE_O_REPAIR', 1, 'D', ' where recid like ''D', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (19, 'T24LIVE.F_DE_O_MSG_ADVICE', 1, 'D', ' where recid like ''D', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (20, 'T24LIVE.FBNK_TXN_LOG_TCB', 1, ' where recid like ''%/', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, del_range, post_condition, hint_idx, add_condition, keep_year, archive_year)
 Values (21, 'T24LIVE.FBNK_DEPO_WITHDRA', 1, ' t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,''/row/c29''),'''')<''', '0901', '''', '/*+index (t IX_FBNK_DEPO_WITHDRA_C29)*/', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (22, 'T24LIVE.F_LCR_AUTO_WRK_TCB', 2, ' where recid like ''', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, del_range, add_condition, keep_year, archive_year)
 Values (23, 'T24LIVE.FBNK_SUM_DENO_TCB', 1, ' t WHERE NVL(T24LIVE.NUMCAST(EXTRACTVALUE(t.XMLRECORD,''/row/c16'')),0)<', '0901', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT01', ' where recid like ''%.DEBIT.', '01', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT01', ' where recid like ''%.CREDIT.', '01', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT04', ' where recid like ''%.DEBIT.', '04', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT02', ' where recid like ''%.DEBIT.', '02', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT06', ' where recid like ''%.CREDIT.', '06', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT05', ' where recid like ''%.CREDIT.', '05', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT04', ' where recid like ''%.CREDIT.', '04', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT03', ' where recid like ''%.CREDIT.', '03', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'CREDIT02', ' where recid like ''%.CREDIT.', '02', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT06', ' where recid like ''%.DEBIT.', '06', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT05', ' where recid like ''%.DEBIT.', '05', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (24, 'T24LIVE.FBNK_RE_C019', 1, 'DEBIT03', ' where recid like ''%.DEBIT.', '03', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY06', ' where recid like ''%.', '06', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY02', ' where recid like ''%.', '02', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY03', ' where recid like ''%.', '03', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY12', ' where recid like ''%.', '12', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY01', ' where recid like ''%.', '01', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY05', ' where recid like ''%.', '05', '%''', ' and rownum<1000001', 1, 1);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, del_range, post_condition, add_condition, keep_year, archive_year)
 Values (25, 'T24LIVE.FBNK_RE_C018', 1, 'YYYY04', ' where recid like ''%.', '04', '%''', ' and rownum<1000001', 1, 1);

Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (28, 'T24LIVE.FBNK_RE_STAT_LINE_BAL', 1, ' where recid like ''%-', '%*%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (31, 'T24LIVE.FBNK_BENEFICIARY', 2, 'BEN', ' where recid like ''BEN', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (32, 'T24LIVE.FBNK_AC_C002', 2, 'CHG', ' where recid like ''CHG', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (33, 'T24LIVE.FBNK_EBANK_BULK_TCB', 2, 'FEB', ' where recid like ''FEB', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (35, 'T24LIVE.FBNK_AI_CORP_TXN_LOG', 2, 'FT', ' where recid like ''FT', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (36, 'T24LIVE.F_OFS_RESPONSE_QUEUE', 3, ' where recid < ''', '%''', ' and rownum<1000001', 1, 8); 
 
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (26, 'T24LIVE.FBNK_AI_LOG_247_TCB', 2, 'FT', ' where recid like ''FT', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (27, 'T24LIVE.FBNK_CATEG_ENT_ACTIVITY', 1, ' where recid like ''_____.', '____.%''', ' and rownum<1000001', 1, 8);
 Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (27, 'T24LIVE.FBNK_CATEG_ENT_ACTIVITY', 1, ' where recid like ''_____.', '____CL.%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (29, 'T24LIVE.FBNK_CONT_ACTIVITY', 1, ' where recid like ''%*', '__''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (29, 'T24LIVE.FBNK_CONT_ACTIVITY', 1, ' where recid like ''%*', '__*%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (30, 'T24LIVE.F_DE_O_MSG', 1, 'D', ' where recid like ''D', '%''', ' and rownum<1000001', 1, 8);
Insert into SYS.TABLE_ARCHIVE (tab_id, table_name, tab_type, sub_type, pre_condition, post_condition, add_condition, keep_year, archive_year)
 Values (37, 'T24LIVE.FBNK_AI_T000', 2, 'TR', ' where recid like ''TR', '%''', ' and rownum<1000001', 1, 8);
COMMIT;
-------------------------------
gen command
Declare
   arc_year       varchar2(10);
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

  SELECT table_name,tab_type,del_range,pre_condition,post_condition,sub_type,hint_idx,add_condition,
  SUBSTR (table_name, 9, LENGTH (table_name))  tab_name, keep_year,archive_year
    FROM sys.table_archive
   WHERE table_name || sub_type || del_range NOT IN
   (SELECT DISTINCT a.table_name|| a.sub_type|| a.del_range
         FROM sys.table_archive a,sys.table_archive_log b
        WHERE        a.table_name|| a.sub_type|| a.del_range = b.table_name|| b.sub_type|| b.del_range
           AND start_time >TRUNC (SYSDATE,'year')
           AND numrow_del <1000000)
           --and table_name in ('T24LIVE.FBNK_PM_DLY_POSN_CLASS','T24LIVE.FBNK_AI_CORP_TXN_LOG')
   ORDER BY tab_id DESC, del_range;
BEGIN
select sysdate into timeCheck from dual;

   FOR tab IN c_tab
   LOOP
     For i in 0 .. tab.archive_year
     Loop
      IF tab.tab_type = 1
      THEN
         arc_year := EXTRACT (YEAR FROM SYSDATE) - 1 - i - tab.keep_year + 1 ;
      END IF;

      IF tab.tab_type = 2
      THEN
         arc_year := SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1 - i - tab.keep_year + 1 ), 3, 4);
      END IF;

      IF tab.tab_type = 3
      THEN
         arc_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
      END IF;

      cmd :='delete '||tab.hint_idx||' '|| tab.table_name|| tab.pre_condition|| arc_year||tab.del_range|| tab.post_condition||' '||tab.add_condition;

      LOOP
         DBMS_OUTPUT.put_line (cmd);
         timeStart := SYSDATE;
         --execute immediate cmd ;
         timeEnd := SYSDATE;
         counter := SQL%ROWCOUNT;
         COMMIT;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               /*insert into  sys.table_archive_log (table_name ,sub_type,del_range,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name,
               tab.sub_type,tab.del_range,arc_year ,timeStart,counter, substr(elapsed,10,10));
               commit;*/
         duration := trunc((sysdate -timeCheck)*24);
         exit when  counter < 1000000 or duration >= 7 ;
      END LOOP;
    End loop;

      --REBUILD INDEX----------
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
         --DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

           SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         /*INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);

         COMMIT;*/

      else

      FOR c_idx1 IN (SELECT partition_name  FROM dba_ind_partitions
                    WHERE index_name = c_idx.index_name AND index_owner = 'T24LIVE' )
      LOOP
                SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO pre_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         cmd := 'alter index T24LIVE.' || c_idx.index_name || ' rebuild partition '||c_idx1.partition_name||' online';
         --DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         --EXECUTE IMMEDIATE cmd;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         /*INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size)--,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name||'.'||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);
              commit;*/

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


-------------------------------New procedure
CREATE OR REPLACE procedure SYS.DBA_archive_data_yearly as
   arc_year       varchar2(10);
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

  SELECT table_name,tab_type,del_range,pre_condition,post_condition,sub_type,hint_idx,add_condition,
  SUBSTR (table_name, 9, LENGTH (table_name))  tab_name, keep_year,archive_year
    FROM sys.table_archive
   WHERE table_name || sub_type || del_range NOT IN
   (SELECT DISTINCT a.table_name|| a.sub_type|| a.del_range
         FROM sys.table_archive a,sys.table_archive_log b
        WHERE        a.table_name|| a.sub_type|| a.del_range = b.table_name|| b.sub_type|| b.del_range
           AND start_time >TRUNC (SYSDATE,'year')
           AND numrow_del <1000000)
           --and table_name in ('T24LIVE.FBNK_PM_DLY_POSN_CLASS','T24LIVE.FBNK_AI_CORP_TXN_LOG')
   ORDER BY tab_id DESC, del_range;
BEGIN
select sysdate into timeCheck from dual;

   FOR tab IN c_tab
   LOOP
     For i in 0 .. tab.archive_year
     Loop
      IF tab.tab_type = 1
      THEN
         arc_year := EXTRACT (YEAR FROM SYSDATE) - 1 - i - tab.keep_year + 1 ;
      END IF;

      IF tab.tab_type = 2
      THEN
         arc_year := SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1 - i - tab.keep_year + 1 ), 3, 4);
      END IF;

      IF tab.tab_type = 3
      THEN
         arc_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
      END IF;

      cmd :='delete '||tab.hint_idx||' '|| tab.table_name|| tab.pre_condition|| arc_year||tab.del_range|| tab.post_condition||' '||tab.add_condition;

      LOOP
         DBMS_OUTPUT.put_line (cmd);
         timeStart := SYSDATE;
         execute immediate cmd ;
         timeEnd := SYSDATE;
         counter := SQL%ROWCOUNT;
         COMMIT;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
               insert into  sys.table_archive_log (table_name ,sub_type,del_range,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name,
               tab.sub_type,tab.del_range,arc_year ,timeStart,counter, substr(elapsed,10,10));
               commit;
         duration := trunc((sysdate -timeCheck)*24);
         exit when  counter < 1000000 or duration >= 7 ;
      END LOOP;
    End loop;

      --REBUILD INDEX----------
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
         --DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         EXECUTE IMMEDIATE cmd;

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
         --DBMS_OUTPUT.put_line(cmd);
         timeStart := SYSDATE;
         EXECUTE IMMEDIATE cmd;

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


-------------------------------



BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_ARCHIVE_DATA_YEARLY'
     ,attribute => 'START_DATE'
     ,value     => TO_TIMESTAMP_TZ('2018/11/2 8:03:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr'));
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.ENABLE
    (name  => 'SYS.DBA_JOB_ARCHIVE_DATA_YEARLY');
END;
/

=====
   

BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'INSTANCE_ID'
     ,value     => 1);
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'SYS.DBA_JOB_GATHER_NODE1');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_GATHER_NODE1'
      ,start_date      => TO_TIMESTAMP_TZ('2018/04/08 07:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_ANALYZE_NODE1'
      ,comments        => 'Job to analyze on instance1.'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE1'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_GATHER_NODE1');
END;
/



BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'SYS.DBA_JOB_GATHER_NODE2');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_GATHER_NODE2'
      ,start_date      => TO_TIMESTAMP_TZ('2018/04/08 07:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_ANALYZE_NODE2'
      ,comments        => 'Job to analyze on instance2.'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER_NODE2'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_GATHER_NODE2');
END;
/


TMP=/tmp/info_gg.txt
TMP1=/home/oraem/temp1.txt
TMP2=/home/oraem/temp2.txt

FIRST=`grep -n 'MANAGER' $TMP |head -1|sed  's/\([0-9]*\).*/\1/'`

tail -n +$FIRST $TMP > $TMP2 
head -n -3  $TMP2 > $TMP1

while read LINE 
do
#name=$(echo "$LINE" | cut -f3)
#    name=`awk '{print $3}' "$LINE"`
name=$(echo $LINE | awk '{print $3}'| sed -e 's/^[[:space:]]*//')
if [ "$name" != "" ]
then
status=$(echo $LINE | awk '{print $2}'| sed -e 's/^[[:space:]]*//')

lag_at_cp=$(echo $LINE | awk '{print $4}'| sed -e 's/^[[:space:]]*//')
hour1=`echo $lag_at_cp|cut -c 1-2`
min1=`echo $lag_at_cp|cut -c 4-5`
sec1=`echo $lag_at_cp|cut -c 7-8`
time1=$[3600*$hour1+60*$hour1+$sec1]

time_since_cp=$(echo $LINE | awk '{print $5}'| sed -e 's/^[[:space:]]*//')
l1=`echo $time_since_cp| grep -b -o ':'| awk 'BEGIN {FS=":"}{print $1}'|head -1`
hour2=`echo $time_since_cp|cut -c 1-$l1`
min2=`echo $time_since_cp|cut -c $[$l1+2]-$[$l1+3]`
sec2=`echo $time_since_cp|cut -c $[$l1+5]-$[$l1+6]`
time2=$[3600*$hour2+60*$hour2+$sec2]
echo "em_result=$name|$time1|$time2|$status"
fi
done < "$TMP1"


===========================================================================
====================Archive data MBB++=====================================
===========================================================================
/* Formatted on 4/24/2018 9:06:43 AM (QP5 v5.252.13127.32847) */
BEGIN
   DBMS_SCHEDULER.create_job ('DBA_DROP_PARTITION',
      job_type              => 'STORED_PROCEDURE',
      job_action            => 'MOBR5.DROP_OLD_PARTITION',
      number_of_arguments   => 0,
      start_date            => TO_TIMESTAMP_TZ ('03-NOV-2017 11.30.00.000000000 PM +07:00','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'),
      repeat_interval       => 'FREQ=WEEKLY;INTERVAL=1; BYDAY=FRI;',
      end_date              => NULL,
      job_class             => '"DEFAULT_JOB_CLASS"',
      enabled               => FALSE,
      auto_drop             => TRUE,
      comments              => 'Job to drop partitions which have no data.');
   DBMS_SCHEDULER.enable ('DBA_DROP_PARTITION');
   COMMIT;
END;
/



PROCEDURE       DROP_OLD_PARTITION AS
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   cmd1          VARCHAR2 (256);
   dem           NUMBER;

   CURSOR c_partitions
   IS
        SELECT table_name, partition_name, HIGH_VALUE
          FROM all_tab_partitions
         WHERE     table_name IN ('MOB_AUDIT_LOGS', 'MOB_TRACEABLE_REQUESTS')
               AND partition_name not in ('AUDIT_P1','TRACERQS_P1','AUDIT_P2')
               AND table_owner = 'MOBR5'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_partitions
   LOOP
      v_highvalue := SUBSTR (cc.HIGH_VALUE, 12, 10);
      v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');

      IF v_date < TO_DATE (SYSDATE) - 65
      THEN
         cmd :='select count(*)  from MOBR5.'|| cc.table_name|| ' partition ('|| cc.partition_name||
 ')';


         EXECUTE IMMEDIATE cmd INTO dem;

         IF dem = 0
         THEN
            cmd1 :='alter table MOBR5.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
            --DBMS_OUTPUT.put_line (cmd1);
            EXECUTE IMMEDIATE cmd1;
         END IF;
      END IF;
   END LOOP;
END;
/


BEGIN
   DBMS_SCHEDULER.create_job ('ARCHIVEOLDDT',
      job_type              => 'STORED_PROCEDURE',
      job_action            => 'MOBR5.ARCHIVEOLDDATA',
      number_of_arguments   => 0,
      start_date            => TO_TIMESTAMP_TZ ('10-MAY-2017 12.00.00.000000000 AM +07:00','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'),
      repeat_interval       => 'FREQ=WEEKLY',
      end_date              => NULL,
      job_class             => '"DEFAULT_JOB_CLASS"',
      enabled               => FALSE,
      auto_drop             => TRUE,
      comments              => 'Automatically archive old data to history tables');
   DBMS_SCHEDULER.enable ('ARCHIVEOLDDT');
   COMMIT;
END;
/

PROCEDURE       archiveOldData as
   l_date   DATE := sysdate;
   ist      VARCHAR2 (256);
   del      VARCHAR2 (256);
   n        NUMBER := 100;
   vcol     DBMS_OUTPUT.chararr;

   CURSOR c_arc
   IS
    SELECT l_date-reten dat, base_table_name, hist_table_name
    FROM MOBR5.lookup_table;

BEGIN
   DBMS_OUTPUT.enable (100000);
   DELETE FROM MOBR5.EVT_ENTRY_DATA where ID in (select ID from MOBR5.EVT_ENTRY_HANDLER where DAT_CR
EATION <= to_date(sysdate) - 30);

   DBMS_OUTPUT.put_line('DELETE FROM MOBR5.EVT_ENTRY_DATA where ID in (select ID from MOBR5.EVT_ENTR
Y_HANDLER where DAT_CREATION <= to_date(sysdate) - 30);');

   commit;
   FOR x IN c_arc
   LOOP
        IF x.hist_table_name is NULL
            THEN
                del := 'delete from MOBR5.' ||
                x.base_table_name ||
                ' where dat_creation <= ''' ||
                x.dat || '''';
                DBMS_OUTPUT.put_line (del);
                execute immediate del;
                commit;
            ELSE
                ist := 'insert /*+ append */ into MOBR5.' ||
                x.hist_table_name ||
                ' select * from MOBR5.' ||
                x.base_table_name ||
                ' where dat_creation <= ''' ||
                x.dat || '''';
                DBMS_OUTPUT.put_line (ist);
                execute immediate ist;
                commit;

                del := 'delete from MOBR5.' ||
                x.base_table_name ||
                ' where dat_creation <= ''' ||
                x.dat || '''';
                DBMS_OUTPUT.put_line (del);
                execute immediate del;
                commit;
        END IF;
    END LOOP;
    DBMS_OUTPUT.get_lines (vcol, n);
    FOR i IN 1 .. n
        LOOP
            INSERT INTO MOBR5.outputlog (char_col, procname, log_date)
            VALUES (vcol (i), 'archiveOldData', SYSDATE);
            commit;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;

END;
/

===========================================================================
====================Archive data MBB=======================================
===========================================================================



===========================================================================
==================== +=====================================
===========================================================================

E:\Setup\Toad\Quest Software\Toad for Oracle 12

DECLARE
   cmd           VARCHAR2 (4000);
   cmd1          VARCHAR2 (4000);
   dem           number;

   CURSOR c_partitions
   IS
      SELECT *
        FROM (  SELECT table_owner,
                       table_name,
                       partition_name,
                       default_tablespace
                  FROM dba_tab_partitions a, dba_users b
                 WHERE     tablespace_name = 'DATAT24LIVE'
                       AND compression = 'DISABLED'
                       AND a.TABLE_OWNER = b.USERNAME
                       AND table_name = 'FBNK_STMT_ENTRY'
              ORDER BY table_owner, table_name, partition_name)
       WHERE ROWNUM <= 2;
BEGIN
   FOR cc IN c_partitions
   LOOP
      SELECT count(*) into dem
                  FROM dba_tab_partitions 
                 WHERE     compression = 'DISABLED'
                       AND table_name = cc.table_name;
      cmd :='ALTER TABLE '|| cc.TABLE_OWNER|| '.'|| cc.table_name|| ' MOVE PARTITION '|| cc.PARTITION_NAME|| ' TABLESPACE '|| cc.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4';
      DBMS_OUTPUT.put_line (cmd);
      --execute immediate cmd;
      
      FOR c_index IN (SELECT INDEX_OWNER, index_name, PARTITION_NAME
                        FROM dba_ind_partitions
                       WHERE  index_owner||'.'||index_name in (select distinct owner||'.'||index_name from dba_indexes where table_owner=cc.table_owner and table_name=cc.table_name)
                       AND status = 'UNUSABLE')
      LOOP
      cmd1 :='alter index '||c_index.INDEX_OWNER||'.'||c_index.index_name ||' rebuild partition '||c_index.PARTITION_NAME||' TABLESPACE '||cc.DEFAULT_TABLESPACE||' online PARALLEL 4';
      DBMS_OUTPUT.put_line (cmd1);
      --execute immediate cmd1;
      end loop;
      exit when  dem = 2;
   END LOOP;
END;
/

#########################gather statistic t24################
create or replace PROCEDURE     DBA_ANALYZE_NODE1
AS
   v_cmd   varchar2 (500);
   v_cmd1  varchar2 (500);
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab
   IS
      SELECT DISTINCT  t.owner, t.table_name
                FROM dba_tables t, dba_indexes i, dba_part_tables p
               WHERE     t.owner = i.table_owner
                     AND t.owner = p.owner
                     AND t.table_name = I.TABLE_NAME
                     AND t.table_name = p.TABLE_NAME
                     AND t.owner = 'T24LIVE'
                     AND t.partitioned = 'YES'
                     AND P.PARTITIONING_TYPE = 'HASH'
                     AND i.index_type LIKE 'FUNCTION%';

   CURSOR c_tab1
   IS
        SELECT DISTINCT t.owner, t.table_name
                  FROM dba_tables t, dba_indexes i
                 WHERE     t.owner = i.table_owner
                       AND t.table_name = I.TABLE_NAME
                       AND t.owner = 'T24LIVE'
                       AND t.partitioned = 'NO'
                       AND i.index_type LIKE 'FUNCTION%'
                       AND t.last_analyzed < SYSDATE - 6
              ORDER BY 2;
BEGIN
v_cmd:='BEGIN DBMS_STATS.GATHER_SCHEMA_STATS (OwnName => ''SYS'', Options => ''GATHER'', Estimate_Percent   => DBMS_STATS.auto_sample_size,Method_Opt => ''FOR ALL COLUMNS SIZE AUTO'', Degree => 7); END;';
execute immediate v_cmd;

v_cmd1 :='BEGIN DBMS_STATS.GATHER_SCHEMA_STATS (OwnName => ''T24_LIVE_DWH'', Options => ''GATHER'', Estimate_Percent => DBMS_STATS.auto_sample_size, Method_Opt => ''FOR ALL COLUMNS SIZE AUTO'', Degree => 7); END;';
execute immediate v_cmd1;

   FOR cc IN c_tab
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 7 );end;';
      DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE v_tab;

      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE     table_name = cc.table_name
                    AND owner = 'T24LIVE'
                    AND index_type NOT LIKE 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,Degree => 7 );end;';
         DBMS_OUTPUT.put_line (v_ind);

         EXECUTE IMMEDIATE v_ind;
      END LOOP;
   END LOOP;

   FOR cc IN c_tab1
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 7  );end;';
      DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE v_tab;

      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE     table_name = cc.table_name
                    AND owner = 'T24LIVE'
                    AND index_type NOT LIKE 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,Degree => 7 );end;';
         DBMS_OUTPUT.put_line (v_ind);

         EXECUTE IMMEDIATE v_ind;
      END LOOP;
   END LOOP;

END;
/

create or replace PROCEDURE     DBA_ANALYZE_NODE2
AS
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab2
   IS
        SELECT DISTINCT t.owner, t.object_name, t.subobject_name
          FROM dba_objects t,
               dba_indexes i,
               dba_part_tables p,
               DBA_HIST_SEG_STAT se
         WHERE     t.owner = i.table_owner
               AND t.owner = p.owner
               AND t.object_name = I.TABLE_NAME
               AND t.object_name = p.TABLE_NAME
               AND t.owner = 'T24LIVE'
               AND t.object_type = 'TABLE PARTITION'
               AND P.PARTITIONING_TYPE = 'RANGE'
               AND t.object_id = se.obj#
               AND se.SPACE_USED_DELTA <> 0
               AND se.snap_id > (SELECT MIN (SNAP_ID)
                                   FROM DBA_HIST_SNAPSHOT
                                  WHERE BEGIN_INTERVAL_TIME > SYSDATE - 10)
      ORDER BY 2;

   CURSOR c_tab3
   IS
        SELECT DISTINCT t.owner, t.table_name
          FROM dba_tables t
         WHERE t.owner = 'T24LIVE' AND t.last_analyzed < SYSDATE - 6
      ORDER BY 2;

BEGIN
   FOR cc IN c_tab2
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.object_name
         || ''',Partname=>'''
         || cc.subobject_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 7 );end;';

      --DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE v_tab;

      FOR c_index_go
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE     table_name = cc.object_name
                    AND owner = 'T24LIVE'
                    AND partitioned = 'NO'
                    AND index_type NOT LIKE 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index_go.owner
            || ''',IndName=>'''
            || c_index_go.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE ,Degree => 7 );end;';

         --DBMS_OUTPUT.put_line (v_ind);
         EXECUTE IMMEDIATE v_ind;
      END LOOP;

      FOR c_index_lo
         IN (SELECT i.index_owner, i.index_name, i.partition_name
               FROM dba_ind_partitions i,
                    dba_tab_partitions t,
                    dba_indexes idx
              WHERE     i.index_owner = idx.owner
                    AND i.index_name = idx.index_name
                    AND t.table_owner = idx.table_owner
                    AND idx.table_name = t.table_name
                    AND i.index_owner = 'T24LIVE'
                    AND t.table_owner = 'T24LIVE'
                    AND idx.table_name = cc.object_name
                    AND t.partition_position = i.partition_position
                    AND t.partition_name = cc.subobject_name
                    AND idx.index_type NOT LIKE 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index_lo.index_owner
            || ''',IndName=>'''
            || c_index_lo.index_name
            || ''',Partname=>'''
            || c_index_lo.partition_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE ,Degree => 7 );end;';

         --DBMS_OUTPUT.put_line (v_ind);
         EXECUTE IMMEDIATE v_ind;
      END LOOP;
   END LOOP;



   FOR cc IN c_tab3
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 7 );end;';

      --DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE v_tab;

      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE     table_name = cc.table_name
                    AND owner = 'T24LIVE'
                    AND index_type NOT LIKE 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,Degree => 7  );end;';

         --DBMS_OUTPUT.put_line (v_ind);
         EXECUTE IMMEDIATE v_ind;
      END LOOP;
   END LOOP;

END;
/


#########################DROP PARTITION TABLE t24################
--CREATE OR REPLACE procedure SYS.DBA_Drop_partition_yearly as
declare
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   dem           NUMBER;

   CURSOR c_partitions
   IS
        SELECT table_name, partition_name, HIGH_VALUE
          FROM all_tab_partitions          
         WHERE table_name IN ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS','FBNK_STMT_ENTRY','FBNK_RE_C017','FBNK_CATEG_ENTRY') 
         and table_owner='T24LIVE'
         and partition_name not like '%MAX%'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_partitions
   LOOP
   if cc.table_name in ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS' )
   then 
      v_highvalue := to_number(SUBSTR (cc.HIGH_VALUE, 4, 2));
          if v_highvalue < to_number(to_char(sysdate, 'YY'))
          then
          cmd := 'alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
          DBMS_OUTPUT.put_line (cmd);
          EXECUTE IMMEDIATE cmd;
          end if;
      else
      v_highvalue := to_number(SUBSTR (cc.HIGH_VALUE, 2, 5));
          if v_highvalue <= trunc(sysdate,'YEAR')-to_date ('31/12/1967','dd/mm/yyyy') 
          then
          cmd := 'alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
          DBMS_OUTPUT.put_line (cmd);
          EXECUTE IMMEDIATE cmd;
          end if;
      end if;      
   END LOOP;
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'JOB_DROP_PARTITION2'
      ,start_date      => TO_TIMESTAMP_TZ('2018/04/21 10:17:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=YEARLY;BYMONTH=4,8;BYMONTHDAY=21,22,23,24,25,26,27;BYDAY=SAT;INTERVAL=1;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_DROP_PARTITION_YEARLY' --procedure name
      ,comments        => 'Job to automatic drop partition.'
     
    );
  SYS.DBMS_SCHEDULER.ENABLE  (name => 'JOB_DROP_PARTITION2');
END;
/

----1st quarter of the year drop last 1st and 2nd quarter, 3rd quarter frop last 3rd,4th quarter
--CREATE OR REPLACE procedure SYS.DBA_Drop_partition_yearly as
/* Formatted on 3/29/2018 9:31:53 AM (QP5 v5.252.13127.32867) */
DECLARE
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   dem           NUMBER;

   CURSOR c_partitions
   IS
        SELECT table_name, partition_name, HIGH_VALUE
          FROM all_tab_partitions
         WHERE     table_name IN ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS','FBNK_STMT_ENTRY', 'FBNK_RE_C017','FBNK_CATEG_ENTRY')
               AND table_name NOT IN (select distinct table_name from dba_indexes 
                                        where table_name in ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS','FBNK_STMT_ENTRY', 'FBNK_RE_C017','FBNK_CATEG_ENTRY')
                                        and partitioned='NO'   )
               AND table_owner = 'T24LIVE'
               AND partition_name NOT LIKE '%MAX%'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_partitions
   LOOP
      IF cc.table_name IN ('FBNK_FUNDS_TRANSFER#HIS', 'FBNK_TELLER#HIS')
      THEN
         v_highvalue := TO_NUMBER (SUBSTR (cc.HIGH_VALUE, 4, 5));

         --DBMS_OUTPUT.put_line (v_highvalue);
         IF TO_NUMBER (TO_CHAR (SYSDATE, 'MM'))  <= 6
         THEN
            IF v_highvalue <
                  (TO_NUMBER (TO_CHAR (SYSDATE, 'YY')) - 1) * 1000 + 184
            THEN
               cmd :=  'alter table T24LIVE.' || cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
            -- EXECUTE IMMEDIATE cmd;
            END IF;
         ELSE
            IF v_highvalue < TO_NUMBER (TO_CHAR (SYSDATE, 'YY')) * 1000
            THEN
               cmd :='alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
            -- EXECUTE IMMEDIATE cmd;
            END IF;
         END IF;
      ELSE
         v_highvalue := TO_NUMBER (SUBSTR (cc.HIGH_VALUE, 2, 5));

         IF TO_NUMBER (TO_CHAR (SYSDATE, 'MM'))  <= 6
         THEN
            IF v_highvalue <= TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'dd/mm/yyyy') - 184
            THEN
               cmd :='alter table T24LIVE.' || cc.table_name || ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
            --EXECUTE IMMEDIATE cmd;
            END IF;
         ELSE
            IF v_highvalue <=TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'dd/mm/yyyy')
            THEN
               cmd := 'alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
            --EXECUTE IMMEDIATE cmd;
            END IF;
         END IF;
      END IF;
   END LOOP;
END;
/


select table_name, 
trunc(sum(to_number(substr (elapsed_time,1,1))*24*60 + to_number(substr (elapsed_time,3,2))*60+to_number( substr (elapsed_time,6,2))+ to_number(substr (elapsed_time,9,2))/60)) total_time
,sum(numrow_del) 
from sys.table_archive_log where start_time >sysdate -1
group by table_name

---T24LIVE.FBNK_AI_CORP_TXN_LOG
select table_name,trunc(sum(pre_size),2), trunc(sum(post_size),2),
trunc(sum(to_number(substr (elapsed_time,1,1))*24*60 + to_number(substr (elapsed_time,3,2))*60+to_number( substr (elapsed_time,6,2))+ to_number(substr (elapsed_time,9,2))/60)) total_time
from sys.rebuild_idx_log where start_time >sysdate-1
group by table_name

--CREATE  procedure SYS.DBA_archive_data_yearly as
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
   ORDER BY tab_id DESC, del_range;
BEGIN
select sysdate into timeCheck from dual;
   FOR tab IN c_tab
   LOOP
      --DBMS_OUTPUT.put_line ('====' || tab.table_name);
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
              VALUES (tab.table_name, c_idx.index_name||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild);--,start_seq,end_seq);
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


--=======================DWH create partition
declare 
   cmd1           VARCHAR2 (256);
   cmd2           VARCHAR2 (256);
   CURSOR c_table
   IS
         SELECT table_name
          FROM all_tables          
         WHERE table_name IN ('STMT_ENTRY','MBB_AUDIT_LOGS','PROTOCOL','GROUP_ACCOUNT','FUNDS_TRANSFER','TBL_T24_ERRORS','PD_BALANCES','LMM_ACCOUNT_BALANCES','CONSOLIDATE_ASST_LIAB','CATEG_ENTRY','RE_CONSOL_CONTRACT','CMS_TRANSACTION','RE_CRF_SBVGL','RE_CONSOL_SPEC_ENTRY','RE_STAT_LINE_CONT','PD_PAYMENT_DUE','CMS_COLLECTIONCENTRALBANK')  
        and owner='DWH';
   
BEGIN
   FOR cc IN c_table
   LOOP
      DBMS_OUTPUT.put_line ('DWH.'||cc.table_name);
      
      for c_par in (SELECT  partition_name,high_value
          FROM all_tab_partitions          
         WHERE table_name=  cc.table_name    and table_owner='DWH')
      loop
      cmd1:='PARTITION '||c_par.partition_name||'_NEW VALUES LESS THAN ('||c_par.high_value||'),  ';
      DBMS_OUTPUT.put_line (cmd1);
      end loop;
           
   END LOOP;
END;
/
col type_name for a20
col name for a20
col action for a20
 select kind,type_name,name,action,enabled from dba_java_policy where grantee='A4M';
--=======================DWH exchange partitiondeclare
declare 
 v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd1           VARCHAR2 (128);
   cmd2           VARCHAR2 (128);
   cmd3           VARCHAR2 (128);
   cmd4           VARCHAR2 (2000);
   dem           NUMBER;

   CURSOR c_table
   IS
        SELECT owner,table_name
          FROM dba_tables          
         WHERE table_name IN ('ACCOUNT') and owner='DWH2017'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_table
   LOOP
      cmd1 := 'CREATE TABLE DWH2017.EXC_'||cc.table_name||' as select * from DWH.'||cc.table_name||' where 2=1';
      DBMS_OUTPUT.put_line (cmd1);
      --EXECUTE IMMEDIATE cmd1;
      
      cmd2 := 'grant select, alter on DWH.'||cc.table_name||' to DWH2017';
      DBMS_OUTPUT.put_line (cmd2);
      --EXECUTE IMMEDIATE cmd2;
      
      for c_partition in
      (SELECT table_name, partition_name,partition_position
          FROM all_tab_partitions          
         WHERE table_name =cc.table_name and table_owner='DWH'
      ORDER BY 3 ASC)
      loop
      cmd3:='alter table DWH.'||c_partition.table_name||' exchange partition '||c_partition.partition_name||' with table DWH2017.EXC_'||c_partition.table_name||' INCLUDING INDEXES WITHOUT VALIDATION ';
      DBMS_OUTPUT.put_line (cmd3);
      --EXECUTE IMMEDIATE cmd3;
      
      for c_par_exchange in
      (SELECT table_name, partition_name,partition_position
          FROM all_tab_partitions          
         WHERE table_name =cc.table_name and table_owner='DWH2017' and partition_position=c_partition.partition_position)
      loop
      cmd4:='alter table DWH2017.'||c_par_exchange.table_name||' exchange partition '||c_par_exchange.partition_name||' with table DWH2017.EXC_'||c_par_exchange.table_name||' INCLUDING INDEXES WITHOUT VALIDATION ';
      DBMS_OUTPUT.put_line (cmd4);
      --EXECUTE IMMEDIATE cmd4;
      end loop;
      
      end loop;
      
   END LOOP;
END;
/

--=======================DEFRAG F_JOB_LIST
/* Formatted on 9/14/2017 2:37:50 PM (QP5 v5.252.13127.32867) */
SELECT   owner, table_name, TRUNC(sum(bytes)/1024/1024/1024) GB FROM (          
SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  
AND   s.owner = l.owner AND   s.segment_type like 'LOB%')
where table_name like 'F\_JOB\_LIST\_%' escape '\'
GROUP BY owner  ,table_name ORDER BY 3 desc;

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
         WHERE     table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\' AND owner = 'T24LIVE'
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


declare
   cmd2            VARCHAR2 (4000);
BEGIN
   FOR c_cmd
      IN (SELECT    'alter database datafile '''
                 || file_name
                 || ''' resize '
                 || CEIL ( (NVL (hwm, 1) * 8192) / 1024 / 1024)
                 || 'm'  as command
            FROM dba_data_files a,
                 (  SELECT file_id, MAX (block_id + blocks - 1) hwm
                      FROM dba_extents
                  GROUP BY file_id) b
           WHERE     a.file_id = b.file_id(+)
                 AND   CEIL (blocks * 8192 / 1024 / 1024)
                     - CEIL ( (NVL (hwm, 1) * 8192) / 1024 / 1024) > 0)
   LOOP
      DBMS_OUTPUT.put_line (c_cmd.command);
      EXECUTE IMMEDIATE c_cmd.command;
   END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE SYS.DEFRAG_FJOBLIST AS
   cmd2            VARCHAR2 (4000);
   cmd3            VARCHAR2 (4000);
   cmd4            VARCHAR2 (4000);
   ind             VARCHAR2 (50);
   resource_busy   EXCEPTION;
   str             VARCHAR2 (4000);
   PRAGMA EXCEPTION_INIT (resource_busy, -54);

   CURSOR c_tab
   IS
        SELECT owner, table_name, partitioned
          FROM dba_tables
         WHERE     table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\' AND owner = 'T24LIVE'
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
            cmd2 := 'alter table T24LIVE.'|| v_tab.table_name || ' move tablespace DATAT24LIVE';
            cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
            EXECUTE IMMEDIATE cmd2;
            EXECUTE IMMEDIATE cmd3;
            DBMS_OUTPUT.put_line (cmd2);
            DBMS_OUTPUT.put_line (cmd3);

            FOR c_idx
               IN (SELECT index_name
                     FROM dba_indexes
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE'  AND index_type <> 'LOB')
            LOOP
               cmd4 := 'alter index T24LIVE.' || c_idx.index_name || ' rebuild tablespace INDEXT24LIVE online';
               EXECUTE IMMEDIATE cmd4;
               DBMS_OUTPUT.put_line (cmd4);
            END LOOP;
         ELSE
            FOR c_par
               IN (SELECT partition_name, partition_position
                     FROM dba_tab_partitions
                    WHERE     table_name = v_tab.table_name AND table_owner = 'T24LIVE')
            LOOP
               cmd2 := 'alter table T24LIVE.' || v_tab.table_name || ' move partition '|| c_par.partition_name|| ' tablespace DATAT24LIVE';
               cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE PARTITION '||c_par.partition_name||' LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
               EXECUTE IMMEDIATE cmd2;
               EXECUTE IMMEDIATE cmd3;
               DBMS_OUTPUT.put_line (cmd2);
               DBMS_OUTPUT.put_line (cmd3);

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

      UPDATE T24LIVE.F_TIS_DW_CONTROL
         SET xmlrecord = UPDATEXML (xmlrecord,'/row/c1/text()', str||' ','/row/c3/text()', TO_CHAR (SYSDATE, 'hh24:mi:ss dd/mm/yyyy'), '/row/c4/text()','NOT RUNNING')
       WHERE recid = 'FLA.CLEAR.JOB.LIST';

      COMMIT;
   END LOOP;
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_DEFRAG_FJOBLIST'
      ,start_date      => TO_TIMESTAMP_TZ('2017/09/28 15:10:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY;INTERVAL=1; BYDAY=THU;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DEFRAG_FJOBLIST'
      ,comments        => 'Job to move F_JOB_LIST tables and rebuild indexes to defragment.'
    );

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_DEFRAG_FJOBLIST');
END;
/

----drop partition MBBDB
/* Formatted on 9/25/2017 4:23:34 PM (QP5 v5.252.13127.32867) */
declare
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   dem           NUMBER;

   CURSOR c_partitions
   IS
        SELECT table_name, partition_name, HIGH_VALUE
          FROM all_tab_partitions          
         WHERE table_name IN ('MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS') and table_owner='MOBR5'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_partitions
   LOOP
      v_highvalue := SUBSTR (cc.HIGH_VALUE, 12, 10);
      DBMS_OUTPUT.put_line (v_highvalue);
      v_date := TO_DATE (v_highvalue, 'yyyy-mm-dd');
      DBMS_OUTPUT.put_line (v_date);

      IF v_date < TO_DATE (SYSDATE) - 65
      THEN
         cmd :='select count(*)  from MOBR5.'||cc.table_name||' partition ('|| cc.partition_name|| ')';

         EXECUTE IMMEDIATE cmd INTO dem;

         DBMS_OUTPUT.put_line (dem);

         IF dem = 0
         THEN
            cmd := 'alter table MOBR5.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
            DBMS_OUTPUT.put_line (cmd);
         END IF;
      END IF;
   END LOOP;
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_DROP_MOBR5'
      ,start_date      => TO_TIMESTAMP_TZ('2017/10/25 18:06:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY;INTERVAL=1; BYDAY=WED;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DROP_PARTITION_MOBR5'
      ,comments        => 'Job to drop partition MOBR5.'
    );

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_DROP_MOBR5');
END;
/

----
DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);
   ind         varchar2 (50);
   resource_busy exception;
pragma exception_init (resource_busy,-54);

   CURSOR c_tab
   IS
SELECT owner, table_name  FROM dba_tables
                         WHERE     table_name LIKE  'TEST'  and owner='THUYNTM_DBA' and partitioned='NO' order by 2;
BEGIN
UPDATE T24LIVE.F_TIS_DW_CONTROL SET xmlrecord =  UPDATEXML(xmlrecord,'/row/c4/text()','RUNNING','/row/c3/text()',to_char (sysdate,'hh24:mi:ss dd/mm/yyyy'))
 where recid='FLA.CLEAR.JOB.LIST';
   FOR v_tab IN c_tab
   LOOP
     begin 
      cmd2 := 'alter table Thuyntm_dba.' || v_tab.table_name || ' move tablespace USERS';
      execute immediate cmd2;
       exception   when resource_busy then DBMS_OUTPUT.put_line ('Busy');;
     end;
UPDATE T24LIVE.F_TIS_DW_CONTROL SET xmlrecord =  UPDATEXML(xmlrecord,'/row/c4/text()','NOT RUNNING','/row/c3/text()',to_char (sysdate,'hh24:mi:ss dd/mm/yyyy'))
 where recid='FLA.CLEAR.JOB.LIST';
   END LOOP;
   END;
/



DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);
   sz_tab_bf   NUMBER;
   sz_Lob_bf   NUMBER;
   sz_tab_af   NUMBER;
   sz_Lob_af   NUMBER;
   timeStart   DATE;
   timeEnd     DATE;
   elapsed     VARCHAR2 (50);
   ind         varchar2 (50);

   CURSOR c_tab
   IS
SELECT owner, table_name  FROM dba_tables
                         WHERE     table_name LIKE  'F\_JOB\_LIST\_%' ESCAPE '\' and owner='T24LIVE' and partitioned='NO' order by 2;
BEGIN
   FOR v_tab IN c_tab
   LOOP
       select index_name into ind from dba_indexes where table_name =v_tab.table_name and index_type not like 'LOB';      
      cmd2 := 'alter table T24live.' || v_tab.table_name || ' move tablespace datat24live';
      cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
      cmd4 := 'alter index T24LIVE.' || ind || ' rebuild online';

      EXECUTE IMMEDIATE cmd2;
      EXECUTE IMMEDIATE cmd3;
      EXECUTE IMMEDIATE cmd4;   

   END LOOP;
END;
/

====================

/* Formatted on 8/9/2017 4:03:40 PM (QP5 v5.252.13127.32867) */
DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);
   sz_tab_bf   NUMBER;
   sz_Lob_bf   NUMBER;
   sz_tab_af   NUMBER;
   sz_Lob_af   NUMBER;
   timeStart   DATE;
   timeEnd     DATE;
   elapsed     VARCHAR2 (50);
   ind         varchar2 (50);

   CURSOR c_tab
   IS
      SELECT owner, table_name  FROM (  SELECT owner,table_name,TRUNC (SUM (bytes) / 1024 / 1024 / 1024) GB
                  FROM (SELECT segment_name table_name, owner, bytes FROM dba_segments
                         WHERE     segment_type LIKE 'TABLE%'  AND segment_name LIKE  'F\_JOB\_LIST\_%' ESCAPE '\'
                        UNION ALL
                        SELECT l.table_name, l.owner, s.bytes  FROM dba_lobs l, dba_segments s  WHERE     s.segment_name = l.segment_name  AND l.table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\'
                               AND s.owner = l.owner
                               AND s.segment_type LIKE 'LOB%')
              GROUP BY owner, table_name
                HAVING TRUNC (SUM (bytes) / 1024 / 1024 / 1024) >= 1
              ORDER BY 3 DESC)
       WHERE ROWNUM < 51;
BEGIN
   FOR v_tab IN c_tab
   LOOP
       select index_name into ind from dba_indexes where table_name =v_tab.table_name and index_type not like 'LOB';      
      cmd2 := 'alter table T24live.' || v_tab.table_name || ' move tablespace datat24live';
      cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
      cmd4 := 'alter index T24LIVE.' || ind || ' rebuild online';

      EXECUTE IMMEDIATE cmd2;
      EXECUTE IMMEDIATE cmd3;
      EXECUTE IMMEDIATE cmd4;   

   END LOOP;
END;
/


SELECT owner, index_name
FROM dba_indexes
WHERE status = 'UNUSABLE';

SELECT 'alter index '||index_owner||'.'|| index_name||'rebuild partition '|| partition_name ||' online; '
FROM dba_ind_PARTITIONS
WHERE status = 'UNUSABLE';

SELECT index_owner, index_name, partition_name, subpartition_name
FROM dba_ind_SUBPARTITIONS
WHERE status = 'UNUSABLE';


---
create table sys.log_move_fjoblist
(
segment_name varchar2(150),
sizeKB_tab_bf number,
sizeKB_tab_af number,
sizeKB_lob_bf number,
sizeKB_lob_af number,
elapse_time varchar2(50)
)
/* Formatted on 8/9/2017 4:03:40 PM (QP5 v5.252.13127.32867) */
/* Formatted on 8/9/2017 4:03:40 PM (QP5 v5.252.13127.32867) */
DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   sz_tab_bf   NUMBER;
   sz_Lob_bf   NUMBER;
   sz_tab_af   NUMBER;
   sz_Lob_af   NUMBER;
   timeStart   DATE;
   timeEnd     DATE;
   elapsed     VARCHAR2 (50);
   ind         varchar2 (50);

   CURSOR c_tab
   IS
      SELECT owner, table_name
        FROM (  SELECT owner,table_name,TRUNC (SUM (bytes) / 1024 / 1024 / 1024) GB
                  FROM (SELECT segment_name table_name, owner, bytes FROM dba_segments
                         WHERE     segment_type LIKE 'TABLE%'  AND segment_name LIKE  'F\_JOB\_LIST\_%' ESCAPE '\'
                        UNION ALL
                        SELECT l.table_name, l.owner, s.bytes  FROM dba_lobs l, dba_segments s  WHERE     s.segment_name = l.segment_name  AND l.table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\'
                               AND s.owner = l.owner
                               AND s.segment_type LIKE 'LOB%')
              GROUP BY owner, table_name
                HAVING TRUNC (SUM (bytes) / 1024 / 1024 / 1024) >= 3
              ORDER BY 3 DESC)
       WHERE ROWNUM < 51;
BEGIN
   FOR v_tab IN c_tab
   LOOP
      SELECT ROUND (bytes / 1024)  INTO sz_tab_bf FROM sys.dba_segments WHERE segment_name = v_tab.table_name;
      SELECT ROUND (bytes / 1024) INTO sz_Lob_bf FROM sys.dba_segments
       WHERE segment_name = (SELECT segment_name FROM dba_lobs WHERE table_name = v_tab.table_name AND owner = v_tab.owner);
       select index_name into ind from dba_indexes where table_name =v_tab.table_name and index_type not like 'LOB';
       
      cmd2 := 'alter table T24live.' || v_tab.table_name || ' move tablespace datat24live';
      DBMS_OUTPUT.put_line (cmd2);
      cmd3 := 'ALTER TABLE T24live.' || v_tab.table_name|| ' MOVE LOB (XMLRECORD) STORE AS (TABLESPACE datat24live) ';
      DBMS_OUTPUT.put_line (cmd3);
      cmd4 := 'alter index T24LIVE.' || ind || ' rebuild online';
      DBMS_OUTPUT.put_line (cmd4);

      timeStart := SYSDATE;
      EXECUTE IMMEDIATE cmd2;
      EXECUTE IMMEDIATE cmd3;
      timeEnd := SYSDATE;
      elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

      SELECT ROUND (bytes / 1024) INTO sz_tab_af FROM sys.dba_segments WHERE segment_name = v_tab.table_name;

      SELECT ROUND (bytes / 1024) INTO sz_Lob_af FROM sys.dba_segments WHERE segment_name =
                (SELECT segment_name FROM dba_lobs WHERE table_name = v_tab.table_name AND owner = v_tab.owner);

      INSERT INTO sys.log_move_fjoblist (segment_name, sizeKB_tab_bf, sizeKB_tab_af, sizeKB_lob_bf, sizeKB_lob_af,  elapse_time)
           VALUES (v_tab.owner || '.' || v_tab.table_name, sz_tab_bf, sz_tab_af, sz_Lob_bf, sz_Lob_af,  elapsed);
      COMMIT;
      
      
      
   END LOOP;
END;
/

=========================='


DECLARE
   cmd1   VARCHAR2 (4000);
   cmd2   VARCHAR2 (4000);
   cmd3   VARCHAR2 (4000);
   cmd4   VARCHAR2 (4000);

   CURSOR c_tab
   IS
        SELECT owner , table_name 
          FROM dba_tables
         WHERE     table_name LIKE 'F\_JOB\_LIST\_%' ESCAPE '\'
               AND owner = 'T24LIVE'
      ORDER BY 1;
BEGIN
   FOR v_tab IN c_tab
   LOOP
      cmd1 := 'drop table ' || v_tab.owner||'.'||v_tab.table_name || ' purge';
      DBMS_OUTPUT.put_line (cmd1);
      execute immediate cmd1;
      
      cmd2 := 'create table ' || v_tab.owner||'.'||v_tab.table_name || '(  RECID      VARCHAR2(255 BYTE),  XMLRECORD  BLOB)
      LOB (XMLRECORD) STORE AS SECUREFILE ( TABLESPACE  DATAT24LIVE) TABLESPACE DATAT24LIVE PARTITION BY HASH (RECID)   PARTITIONS 64';
      DBMS_OUTPUT.put_line (cmd2);
      execute immediate cmd2;
      
      cmd3 := 'CREATE UNIQUE INDEX '|| v_tab.owner||'.'||v_tab.table_name|| '_PK ON '|| v_tab.owner||'.'||v_tab.table_name||' (RECID) LOCAL TABLESPACE INDEXT24LIVE';
      DBMS_OUTPUT.put_line (cmd3);
      execute immediate cmd3;
      
      cmd4 := 'ALTER TABLE '|| v_tab.owner||'.'||v_tab.table_name || ' ADD ( CONSTRAINT '|| v_tab.table_name|| '_PK   PRIMARY KEY  (RECID)   USING INDEX LOCAL   ENABLE VALIDATE)';
      DBMS_OUTPUT.put_line (cmd4);
      execute immediate cmd4;
      
       DBMS_OUTPUT.put_line (chr(10));
   END LOOP;
END;
/


-------
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where recid like '%.VN001____.___.2016%' and rownum<1000001

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
--F_DE_O_REPAIR
SET DEFINE OFF;
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


---------------
CREATE OR REPLACE procedure SYS.archive_data_yearly_spec as
   archive_year   NUMBER;
   ayear          number;
   d              number;
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   ST 			  date;
   elapsed        VARCHAR2 (50);
   duration       number;
   CURSOR c_tab
   IS
        SELECT table_name, tab_type, del_range, pre_condition,post_condition,sub_type, hint_idx ,add_condition
          FROM sys.table_archive
         WHERE tab_id =14
      ORDER BY tab_id, del_range;
BEGIN
   FOR tab IN c_tab
   LOOP
      --DBMS_OUTPUT.put_line ('====' || tab.table_name);
      IF tab.tab_type = 1
      THEN
         archive_year := to_number(EXTRACT (YEAR FROM SYSDATE) - 1);
      END IF;

      IF tab.tab_type = 2
      THEN
         archive_year := to_number(SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1), 3, 4));
      END IF;

      IF tab.tab_type = 3
      THEN
         archive_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
      END IF;
	  ST := sysdate;

	  /*if tab.table_name = 'T24LIVE.FBNK_PM_DLY_POSN_CLASS' then d := 14;
      else  d :=4;
      end if;
      */

      for i in 5 .. 14
      loop
      ayear :=archive_year-i;
      cmd :='delete '||tab.hint_idx||' '|| tab.table_name|| tab.pre_condition|| ayear||tab.del_range|| tab.post_condition||' '||tab.add_condition;

        LOOP
         DBMS_OUTPUT.put_line (cmd);
         timeStart := SYSDATE;
         execute immediate cmd ;
         timeEnd := SYSDATE;
         counter := SQL%ROWCOUNT;
         COMMIT;
         DBMS_OUTPUT.put_line ( counter|| ' rows deleted('|| tab.sub_type|| ayear||tab.del_range||  ')');
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

               insert into  sys.table_archive_log (table_name ,tab_type,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name,
               tab.sub_type||tab.del_range,to_char(ayear) ,timeStart,counter, substr(elapsed,10,10));
               commit;
		 duration := trunc((sysdate -ST)*24);
         exit when  counter < 1000000 or duration >= 11;
        END LOOP;
		exit when  duration >= 11;
      end loop;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/

----------------------------------------------------- 
--Archive du lieu T24 hang nam
-----------------------------------------------------
CREATE  procedure sys.test_thuyntm as
   archive_year   NUMBER;
   cmd            VARCHAR2 (4000);
   counter        NUMBER;
   timeStart      DATE;
   timeEnd        DATE;
   ST                   DATE;
   elapsed        VARCHAR2 (50);
   duration       number;
   CURSOR c_tab
   IS
        SELECT table_name, tab_type, del_range, pre_condition,post_condition,sub_type, hint_idx ,add_condition
          FROM sys.table_archive
         WHERE tab_id=21
		 --table_name||sub_type||del_range not in (select table_name||tab_type from thuyntm_dba.table_archive_log where start_time > sysdate -7)
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

      cmd :='delete '||tab.hint_idx||' ' || tab.table_name|| tab.pre_condition|| archive_year||tab.del_range|| tab.post_condition||' '||tab.add_condition;
ST :=SYSDATE;
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
         duration := trunc((sysdate -ST)*24);
         exit when  counter < 1000000 or duration >= 7; 
      END LOOP;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK;
END;
/


-----
DECLARE
   archive_year   NUMBER;
   cmd             VARCHAR2 (4000);
   counter         NUMBER;
   timeStart       DATE;
   timeEnd         DATE;
   elapsed         varchar2 (50);

   CURSOR c_tab
   IS
      SELECT table_name, tab_type, del_range,pre_condition,post_condition,sub_type 
      FROM thuyntm_dba.table_archive 
      Where tab_id<=6--table_name||sub_type||del_range not in (select table_name||tab_type from thuyntm_dba.table_archive_log where start_time > sysdate -7)
      order by tab_id, del_range;
BEGIN
  
  FOR tab IN c_tab
   LOOP   
      --DBMS_OUTPUT.put_line ('====' || tab.table_name);
      IF tab.tab_type = 1
         THEN     archive_year := EXTRACT (YEAR FROM SYSDATE) - 1;
      --DBMS_OUTPUT.put_line (archive_year);
         END IF;
      IF tab.tab_type = 2
         THEN     archive_year :=  SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1), 3, 4);
         END IF;
      IF tab.tab_type = 3      
         THEN     archive_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
      --DBMS_OUTPUT.put_line (archive_year);      
         END IF;
      
      cmd :='delete '|| tab.table_name|| tab.pre_condition|| archive_year||tab.del_range|| tab.post_condition;       
      DBMS_OUTPUT.put_line (cmd);
      timeStart := SYSDATE;
      --execute immediate cmd ;
      timeEnd := SYSDATE;
      --counter := SQL%ROWCOUNT;
      --COMMIT;
      --DBMS_OUTPUT.put_line ( counter|| ' rows deleted('|| tab.sub_type|| archive_year||tab.del_range||  ')');
      elapsed :=TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);
      --DBMS_OUTPUT.put_line ( 'Elapsed time: '|| substr(elapsed,10,10));

      insert into  thuyntm_dba.table_archive_log (table_name ,tab_type,archive_year,start_time,numrow_del ,elapsed_time ) values (tab.table_name, 
      tab.sub_type||tab.del_range,to_char(archive_year) ,timeStart,counter, substr(elapsed,10,10));
      commit;

      --DBMS_OUTPUT.put_line (CHR (10));
   END LOOP;
  EXCEPTION  WHEN OTHERS THEN ROLLBACK;
END;
/

--------------------test on monthend + archive log size
DECLARE
   archive_year   NUMBER;
   cmd             VARCHAR2 (4000);
   counter         NUMBER;
   timeStart       DATE;
   timeEnd         DATE;
   start_seq    number;
   end_seq number;
   elapsed         varchar2 (50);

   CURSOR c_tab
   IS
      SELECT table_name, tab_type, del_range,pre_condition,post_condition,sub_type 
      FROM thuyntm_dba.table_archive 
      Where tab_id >=11
      order by tab_id, del_range;
BEGIN
  
  FOR tab IN c_tab
   LOOP   
      IF tab.tab_type = 1
         THEN     archive_year := EXTRACT (YEAR FROM SYSDATE) - 1;
         END IF;
      IF tab.tab_type = 2
         THEN     archive_year :=  SUBSTR (TO_CHAR (EXTRACT (YEAR FROM SYSDATE) - 1), 3, 4);
         END IF;
      IF tab.tab_type = 3      
         THEN     archive_year := TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');    
         END IF;
      
      cmd :='delete '|| tab.table_name|| tab.pre_condition|| archive_year||tab.del_range|| tab.post_condition;       
      DBMS_OUTPUT.put_line (cmd);
      timeStart := SYSDATE;
      select max(sequence#) into start_seq from v$archived_log;
      execute immediate cmd ;
      timeEnd := SYSDATE;
      counter := SQL%ROWCOUNT;
      COMMIT;
      select max(sequence#) into end_seq from v$archived_log;
      elapsed :=TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

      insert into  thuyntm_dba.table_archive_log (table_name ,tab_type,archive_year,start_time,numrow_del ,elapsed_time,start_seq,end_seq ) values (tab.table_name, 
      tab.sub_type||tab.del_range,to_char(archive_year) ,timeStart,counter, substr(elapsed,10,10),start_seq,end_seq);
      commit;

   END LOOP;
  EXCEPTION  WHEN OTHERS THEN ROLLBACK;
END;
/

-----------
16:23:29 SQL> select count(*) /*+index (t IX_FBNK_DEPO_WITHDRA_C29)*/ from T24LIVE.FBNK_DEPO_WITHDRA t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c29'),'')<'20160101';    
                                                                 
COUNT(*)/*+INDEX(TIX_FBNK_DEPO_WITHDRA_C29)*/
---------------------------------------------
                                         6209

Elapsed: 02:48:05.76

16:18:31 SQL> select count(*) /*+index (t IX_FBNK_DEPO_WITHDRA_C29)*/ from T24LIVE.FBNK_DEPO_WITHDRA t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c29'),'')<'20160901';
                                                                        
COUNT(*)/*+INDEX(TIX_FBNK_DEPO_WITHDRA_C29)*/
---------------------------------------------
                                      6223077

08:54:19 SQL> select count(*) from T24LIVE.FBNK_RE_CONSOL_PROFIT where recid like '%.VN001____.___.2016%';
                                                                                                                                               
  COUNT(*)
----------
 101819564

Elapsed: 06:07:29.32
----------------------rebuild index and size index after rebuild

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
)
/* Formatted on 6/7/2017 2:50:04 PM (QP5 v5.252.13127.32867) */
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
          where tab_id  = 14
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
         select max(sequence#) into start_seq from v$archived_log;
         EXECUTE IMMEDIATE cmd;
         execute immediate 'alter system archive log current';
         select max(sequence#) into end_seq from v$archived_log;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

           SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name
         GROUP BY segment_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild,start_seq,end_seq);

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
         select max(sequence#) into start_seq from v$archived_log;
         EXECUTE IMMEDIATE cmd;
         execute immediate 'alter system archive log current';
         select max(sequence#) into end_seq from v$archived_log;

         timeEnd := SYSDATE;
         elapsed := TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND);

         SELECT SUM (bytes) / 1024 / 1024 / 1024 INTO post_rebuild
             FROM dba_segments
            WHERE owner = 'T24LIVE' AND segment_name = c_idx.index_name and partition_name=c_idx1.partition_name
         GROUP BY segment_name,partition_name;

         INSERT INTO sys.rebuild_idx_log (table_name, index_name,start_time,elapsed_time, Pre_size,post_size,start_seq,end_seq)
              VALUES (tab.table_name, c_idx.index_name||c_idx1.partition_name,timeStart, substr(elapsed,10,10), pre_rebuild, post_rebuild,start_seq,end_seq);
              commit;

      end loop;
      end if;

      END LOOP;
   END LOOP;
END;
/


--check table not change since SCN
DECLARE
   rec_count      NUMBER;
   cmd            VARCHAR2 (200);
   c_dependence   NUMBER;
   dem            NUMBER;

   CURSOR c_table_name
   IS
      SELECT *
        FROM (SELECT t.owner, t.table_name
                FROM dba_tables t
               WHERE t.owner = 'T24LIVE' AND t.partitioned = 'NO' )
      MINUS
      (SELECT DISTINCT table_owner, table_name
         FROM dba_indexes
        WHERE table_owner = 'T24LIVE' AND index_type LIKE 'FUNCTION%');
BEGIN
   FOR cc IN c_table_name
   LOOP
      SELECT COUNT (*)
        INTO dem
        FROM all_dependencies
       WHERE REFERENCED_NAME = cc.table_name AND referenced_owner = cc.owner;

      IF dem = 0
      THEN
         cmd :=
               'SELECT count(*)  FROM '
            || cc.owner
            || '.'
            || cc.table_name
            || ' where ora_rowscn< 10462779897888';

         --DBMS_OUTPUT.put_line(str);

         EXECUTE IMMEDIATE cmd INTO rec_count;

         IF rec_count = 0
         THEN
            DBMS_OUTPUT.put_line (cc.table_name);
         END IF;
      END IF;
   END LOOP;
END;
/

------------------------------------------------------------------
--====ONLINE REDE
------------------------------------------------------------------
DECLARE
   v_ddl    VARCHAR2 (4000);
   cmd      VARCHAR2 (4000);

   CURSOR c_index
   IS
      select owner,table_name from dba_tables where table_name in ('FBNK_ACCOUNT') ;
      --('ACCOUNT_IPL','ACCOUNT_VT24','ACCT_ACTIVITY','ACCT_ACTIVITY_VT24','ACCT_GEN_CONDITION','AZ_ACCT_BAL','CATEG_ENTRY','COLLATERAL','COLLATERAL_TSD','COMPANY_CHECK','COMPANY_CHECK_TSD','CONSOLIDATE_ASST_LIAB','CT_TRANSFER_TCB','CUSTOMER','CUSTOMER_TSD','DBFS_BACKUP_METADATA_APP','DBFS_BACKUP_METADATA_ETL','DBFS_BACKUP_METADATA_RPT','DC_NEW_COLLECTION_ITEM','DRAWINGS','DRAWINGS_TSD','EB_CONTRACT_BALANCES','EB_CONTRACT_BALANCES_TSD','EB_CONTRACT_BALANCES_VT24','EB_SYSTEM_SUMMARY_TCB','INFO_CARD','INFO_CARD_TSD','LC_ACCOUNT_BALANCES','LD_LOANS_AND_DEPOSITS','LD_LOANS_AND_DEPOSITS_TSD','LD_SCHEDULE_DEFINE','LD_SCHEDULE_DEFINE_TSD','LETTER_OF_CREDIT','LETTER_OF_CREDIT_TSD','LMM_CUSTOMER','LMM_SCHEDULES_PAST','LMM_SCHEDULES_PAST_VT24','LMM_SCHEDULE_DATES','LMM_SCHEDULE_DATES_TSD','MD_BALANCES','MD_DEAL','MD_DEAL_TSD','OSB_QUEUE','OSB_QUEUE_OUT','PD_BALANCES','PD_BALANCES_HIST','PD_PAYMENT_DUE','PERIODIC_INTEREST','RAOS_BB_RAW','RAOS_PFS_FTR','RAOS_WB_RAW','RELATED_INFO_CUS_TCB','RELATED_INFO_CUS_TCB_TSD','RE_CONSOL_CONTRACT','RE_CONSOL_CONTRACT_SEQU','RE_STAT_LINE_CONT','SC_POS_ASSET','SC_POS_ASSET_SV','STMT_ENTRY','STMT_ENTRY_CARD','SUM_DENO_TCB','TBL_BACKUP_METADATA','TBL_T24_DICTIONARY','TELLER_ID','TMP','TMP_ACCT_ENT_TODAY','TMP_CATEG_ENTRY_NONFT','TMP_DWH_STMT_DUP_ENT_TODAY','TMP_STMT_ENTRY_NONFT','TMP_TBL_DDL','TMP_TBL_ETL_CATEG_FT_TT_1','TMP_TBL_ETL_STMT_FT_TT_1','TXN_LOG_TCB','USERTBL','USER_SMS_GROUP')
	  --and owner='';
BEGIN
   FOR cc IN c_index
   LOOP
      DBMS_OUTPUT.put_line ('--'||cc.owner||'.'||cc.table_name);
      DBMS_OUTPUT.put_line ('BEGIN   DBMS_REDEFINITION.CAN_REDEF_TABLE ('''||cc.owner||''','''||cc.table_name||''',DBMS_REDEFINITION.CONS_USE_ROWID); END;');
      DBMS_OUTPUT.put_line ('/');
      DBMS_OUTPUT.put_line (chr(10));
      
      DBMS_OUTPUT.put_line ('BEGIN   DBMS_REDEFINITION.START_REDEF_TABLE ('''||cc.owner||''','''||cc.table_name||''','''||cc.table_name||'_TMP'',NULL,DBMS_REDEFINITION.CONS_USE_ROWID);END;');
      DBMS_OUTPUT.put_line ('/');
      DBMS_OUTPUT.put_line (chr(10));      
      
      DBMS_OUTPUT.put_line ('DECLARE num_errors PLS_INTEGER;');
      DBMS_OUTPUT.put_line ('BEGIN   DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS ('''||cc.owner||''','''||cc.table_name||''','''||cc.table_name||'_TMP'',DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);END;');
      DBMS_OUTPUT.put_line ('/');
      DBMS_OUTPUT.put_line (chr(10));
      
      DBMS_OUTPUT.put_line ('BEGIN   DBMS_REDEFINITION.SYNC_INTERIM_TABLE ('''||cc.owner||''','''||cc.table_name||''','''||cc.table_name||'_TMP'');');
      DBMS_OUTPUT.put_line ('/');
      DBMS_OUTPUT.put_line (chr(10));      
      
      DBMS_OUTPUT.put_line ('BEGIN   DBMS_REDEFINITION.FINISH_REDEF_TABLE ('''||cc.owner||''','''||cc.table_name||''','''||cc.table_name||''');');
      DBMS_OUTPUT.put_line ('/');
      DBMS_OUTPUT.put_line (chr(10));
      
      DBMS_OUTPUT.put_line ('EXEC   DBMS_STATS.gather_table_stats('''||cc.owner||''','''||cc.table_name||''');');
      DBMS_OUTPUT.put_line (chr(10));
      
      DBMS_OUTPUT.put_line ('drop table '||cc.owner||'.'||cc.table_name||'_TMP cascade constraints purge;');
      DBMS_OUTPUT.put_line (chr(10));
      
   END LOOP;
END;
/

------------------------------------------------------------------
--Get DDL  -- SUA DDL
------------------------------------------------------------------

SELECT    'alter table '
       || table_owner
       || '.'
       || table_name
       || ' drop index '
       || owner
       || '.'
       || index_name
       || ';'
  FROM dba_indexes a
 WHERE     a.partitioned = 'NO'
       AND a.table_owner || '.' || a.table_name IN (SELECT DISTINCT table_owner|| '.'|| table_name  FROM dba_tab_partitions)
       AND a.owner ||'.'|| a.index_name NOT IN (SELECT DISTINCT  index_owner || '.'  || index_name  FROM dba_constraints)
                                             
                                             
SELECT    'create '
       || CASE WHEN a.uniqueness = 'UNIQUE' THEN ' UNIQUE ' ELSE '' END
       || ' index '
       || a.owner
       || '.'
       || a.index_name
       || ' on ('
       || b.list_ind||
          ')local nologing tablespace '||a.tablespace_name||' online parallel 4;' as command
from dba_indexes  a,
(
  SELECT index_owner,
         index_name,
         table_owner,
         table_name,
         LISTAGG (column_name, ',') WITHIN GROUP (ORDER BY column_position)
            list_ind
    FROM dba_ind_columns
GROUP BY index_owner,
         index_name,
         table_owner,
         table_name) b
where a.partitioned='NO' and
a.table_owner||'.'||a.table_name in (select distinct table_owner||'.'||table_name from dba_tab_partitions)
and A.owner||'.'||a.index_name=b.index_owner||'.'||b.index_name
and a.table_owner||'.'||a.table_name=b.table_owner||'.'||b.table_name
and a.owner||a.index_name not in (select distinct index_owner||'.'||index_name from dba_constraints)


--create or replace procedure thuyntm_dba.drop_index as
DECLARE
   v_ddl    VARCHAR2 (4000);
   cmd      VARCHAR2 (4000);

   CURSOR c_index
   IS
      SELECT DISTINCT   a.table_owner, a.table_name,  'select dbms_metadata.get_ddldbms_metadata.get_ddl(''INDEX'',''' || a.index_name || ''',''' || a.owner  || ''') from dual'   AS command
        FROM (SELECT DISTINCT table_owner, table_name FROM sys.dba_tab_partitions) b,
             sys.dba_indexes a
       WHERE   --a.partitioned = 'NO'   AND
                 a.table_owner = b.table_owner
             AND a.table_name = b.table_name
             AND a.table_owner LIKE 'SYS'
             AND a.index_name = 'WRH$_DLM_MISC_PK';
             --AND a.owner ||'.'|| a.index_name NOT IN (SELECT DISTINCT index_owner || '.' || index_name FROM dba_constraints)
BEGIN
   FOR cc IN c_index
   LOOP
      --DBMS_OUTPUT.put_line (cc.command);
      EXECUTE IMMEDIATE cc.command INTO v_ddl;
      DBMS_OUTPUT.put_line (REGEXP_REPLACE (v_ddl, '\)', ') local',1,1)||';');
   END LOOP;
END;
/

--
DECLARE
v_ddl    VARCHAR2 (4000);
cmd      VARCHAR2 (4000);

   CURSOR c_index
   IS
    SELECT A.TABLE_OWNER||'.'||A.TABLE_NAME tab , A.OWNER||'.'||A.INDEX_NAME idx,
    'select dbms_metadata.get_ddl(''INDEX'',''' || a.INDEX_NAME || ''',''' || A.OWNER  || ''') from dual'   AS COMMAND
    FROM sys.DBA_INDEXES A, sys.DBA_TABLES B
    WHERE A.TABLE_OWNER=B.OWNER
        AND A.TABLE_NAME=B.TABLE_NAME
        AND B.PARTITIONED='YES'
        AND A.PARTITIONED='NO'
        AND A.TABLE_OWNER='SYS'
        and a.uniqueness='NONUNIQUE' --not drop index unique
        --and a.table_name='SYS_EXPORT_SCHEMA_03'
        AND A.OWNER||'.'||A.INDEX_NAME NOT IN (SELECT DISTINCT INDEX_OWNER||'.'|| INDEX_NAME FROM sys.DBA_CONSTRAINTS  )  
        ;
BEGIN
   FOR cc IN c_index
   LOOP
      --DBMS_OUTPUT.put_line (cc.command);
      EXECUTE IMMEDIATE cc.command INTO v_ddl;
      DBMS_OUTPUT.put_line ('  alter table '||cc.tab||' drop index '||cc.idx ||';');
      DBMS_OUTPUT.put_line (REGEXP_REPLACE (v_ddl, '\)', ') local ONLINE',1,1)||';');
      DBMS_OUTPUT.put_line (chr(10));
   END LOOP;
END;
/


---
DECLARE
   v_ddl   VARCHAR2 (4000);
   cmd     VARCHAR2 (4000);

   CURSOR c_index
   IS
        SELECT TABLE_NAME, COUNT (1)
          FROM sys.DBA_TABLES
         WHERE owner IN ('DWH', 'DWH2013')
        HAVING COUNT (1) > 1
      GROUP BY table_name;
BEGIN
   FOR cc IN c_index
   LOOP
      FOR c_index_2013 IN (SELECT OWNER || '.' || INDEX_NAME ind2013
                             FROM dba_indexes
                            WHERE table_name = CC.TABLE_NAME)
      LOOP
         DBMS_OUTPUT.put_line ( '  drop index ' || c_index_2013.ind2013 || ';');
      END LOOP;

      FOR idx_dwh
         IN (SELECT A.OWNER || '.' || A.INDEX_NAME idx,
                       'select dbms_metadata.get_ddl(''INDEX'',''' || a.INDEX_NAME|| ''',''' || A.OWNER || ''') from dual' AS COMMAND
               FROM sys.DBA_INDEXES A, sys.DBA_TABLES B
              WHERE     A.TABLE_OWNER = B.OWNER
                    AND A.TABLE_NAME = B.TABLE_NAME
                    AND A.TABLE_OWNER = 'DWH'
                    AND a.table_name = cc.table_name
                    AND a.uniqueness = 'NONUNIQUE'     --not drop index unique
                    --and a.table_name='SYS_EXPORT_SCHEMA_03'
                    AND A.OWNER || '.' || A.INDEX_NAME NOT IN (SELECT DISTINCT INDEX_OWNER  || '.' || INDEX_NAME FROM sys.DBA_CONSTRAINTS WHERE table_name =  cc.table_name))
      LOOP
         EXECUTE IMMEDIATE idx_dwh.command INTO v_ddl;

         DBMS_OUTPUT.put_line (REGEXP_REPLACE (REGEXP_REPLACE (v_ddl,'\)',') local ONLINE',1,1),'\"DWH"','"DWH2013"') || ';');
         DBMS_OUTPUT.put_line (CHR (10));
      END LOOP;
   END LOOP;
END;
/

select distinct a.table_owner,a.table_name from dba_indexes a, (
SELECT TABLE_NAME , count(1)
    FROM  sys.DBA_TABLES
    WHERE owner in ('SYS','SYSMAN') 
    having count(1) > 1   
    group by table_name ) b
    where A.TABLE_OWNER='DWH'
    and a.table_name=b.table_name
    and a.uniqueness='NONUNIQUE'
    ;
	
	DECLARE
v_ddl    VARCHAR2 (4000);
cmd      VARCHAR2 (4000);

   CURSOR c_index
   IS
    SELECT A.TABLE_OWNER||'.'||A.TABLE_NAME tab , A.OWNER,A.INDEX_NAME ,
    'select dbms_metadata.get_ddl(''INDEX'',''' || a.INDEX_NAME || ''',''' || A.OWNER  || ''') from dual'   AS COMMAND
    FROM sys.DBA_INDEXES A, sys.DBA_TABLES B
    WHERE A.TABLE_OWNER=B.OWNER
        AND A.TABLE_NAME=B.TABLE_NAME
        AND B.PARTITIONED='YES'
        AND A.PARTITIONED='NO'
        AND A.TABLE_OWNER='SYS'
        and a.uniqueness='NONUNIQUE' --not drop index unique
        --and a.table_name='SYS_EXPORT_SCHEMA_03'
        AND A.OWNER||'.'||A.INDEX_NAME NOT IN (SELECT DISTINCT INDEX_OWNER||'.'|| INDEX_NAME FROM sys.DBA_CONSTRAINTS  )  
        ;
BEGIN
   FOR cc IN c_index
   LOOP
      --DBMS_OUTPUT.put_line (cc.command);
      EXECUTE IMMEDIATE cc.command INTO v_ddl;
      DBMS_OUTPUT.put_line ('  alter table '||cc.tab||' drop index '||cc.owner||'.'||cc.index_name ||';');
      DBMS_OUTPUT.put_line (REGEXP_REPLACE (v_ddl, '\)', ') local ONLINE',1,1)||';');
      DBMS_OUTPUT.put_line (chr(10));
      DBMS_OUTPUT.put_line ('EXECUTE DBMS_STATS.gather_table_stats(OwnName =>'''||cc.owner||''',IndName=>'''||cc.index_name||''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 4 );');
   END LOOP;
END;
/


DECLARE
v_ddl    VARCHAR2 (4000);
tmp_ddl  VARCHAR2 (4000);
tmp  VARCHAR2 (4000);
position1 int ;
position2 int;
cmd      VARCHAR2 (4000);

   CURSOR c_index
   IS
    SELECT A.TABLE_OWNER||'.'||A.TABLE_NAME tab , A.OWNER,A.INDEX_NAME ,
    'select dbms_metadata.get_ddl(''INDEX'',''' || a.INDEX_NAME || ''',''' || A.OWNER  || ''') from dual'   AS COMMAND
    FROM sys.DBA_INDEXES A, sys.DBA_TABLES B
    WHERE A.TABLE_OWNER=B.OWNER
        AND A.TABLE_NAME=B.TABLE_NAME
        AND B.PARTITIONED='YES'
        AND A.PARTITIONED='NO'
        --AND A.TABLE_OWNER='SYS'
        and a.uniqueness='NONUNIQUE' --not drop index unique
        --and a.table_name='SYS_EXPORT_SCHEMA_03'
        AND A.OWNER||'.'||A.INDEX_NAME NOT IN (SELECT DISTINCT INDEX_OWNER||'.'|| INDEX_NAME FROM sys.DBA_CONSTRAINTS  )  
        ;
BEGIN
   FOR cc IN c_index
   LOOP
      --DBMS_OUTPUT.put_line (cc.command);
      EXECUTE IMMEDIATE cc.command INTO v_ddl;
      DBMS_OUTPUT.put_line ('  drop index '||cc.owner||'.'||cc.index_name ||';');
      tmp_ddl :=REGEXP_REPLACE (v_ddl, '\)', ') local ONLINE',1,1);
      position1 :=instr (tmp_ddl, 'TABLESPACE')+10;
      position2 :=instr (tmp_ddl,'" ',position1 );
      tmp := substr (tmp_ddl,1,position1)||' "NEW' ||substr(tmp_ddl,position2);
      DBMS_OUTPUT.put_line (tmp||';');
      DBMS_OUTPUT.put_line (chr(10));
      DBMS_OUTPUT.put_line ('EXECUTE DBMS_STATS.gather_table_stats(OwnName =>'''||cc.owner||''',IndName=>'''||cc.index_name||''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 4 );end;');
   END LOOP;
END;
/
	EXECUTE DBMS_STATS.gather_table_stats(OwnName =>'SYS',TabName =>'X$DIAG_IPS_FILE_METADATA',estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 4 );
	
	
	--super set index
	/* Formatted on 4/1/2017 9:54:08 AM (QP5 v5.252.13127.32867) */
DECLARE
   v_ddl   VARCHAR2 (4000);
   cmd     VARCHAR2 (4000);

   CURSOR c_tab
   IS
        SELECT table_owner,table_name, column_name,COUNT (1)
          FROM dba_ind_columns
         WHERE table_owner = 'SYS' AND column_position = 1
        HAVING COUNT (1) > 1
      GROUP BY table_owner, table_name, column_name;
BEGIN
   FOR cc IN c_tab
   LOOP
      DBMS_OUTPUT.put_line ('--table_name: '||cc.table_owner || '.' || cc.table_name || '--Column_name : ' || cc.column_name);

      FOR c_ind1
         IN (  SELECT b.index_owner, b.index_name, COUNT (1) dem
                 FROM (SELECT DISTINCT index_owner, index_name
                         FROM dba_ind_columns
                        WHERE     table_owner = cc.table_owner
                              AND table_name = cc.table_name
                              AND column_name = cc.column_name
                              AND column_position = 1) a,
                      dba_ind_columns b
                WHERE     a.index_owner = b.index_owner
                      AND a.index_name = b.index_name
               HAVING COUNT (1) = 1
             GROUP BY b.index_owner, b.index_name
             ORDER BY 3)
      LOOP
         DBMS_OUTPUT.put_line (
            'drop index ' || c_ind1.index_name || ';--num of column: ' || c_ind1.dem);

         FOR c_ind2
            IN (  SELECT b.index_owner, b.index_name, COUNT (1) dem
                    FROM (SELECT DISTINCT index_owner, index_name
                            FROM dba_ind_columns
                           WHERE     table_owner = cc.table_owner
                                 AND table_name = cc.table_name
                                 AND column_name = cc.column_name
                                 AND column_position = 1) a,
                         dba_ind_columns b
                   WHERE     a.index_owner = b.index_owner
                         AND a.index_name = b.index_name
                  HAVING COUNT (1) > 1
                GROUP BY b.index_owner, b.index_name
                ORDER BY 3)
         LOOP
            DBMS_OUTPUT.put_line ('--super set index '|| c_ind2.index_name|| '--num of column: '|| c_ind2.dem);
         END LOOP;
      END LOOP;

      DBMS_OUTPUT.put_line (CHR (10));
   END LOOP;
END;
/
------------------------------------------------------------------
--DROP Partition
------------------------------------------------------------------
--create or replace procedure thuyntm_dba.drop_partition as
declare
   v_date        date;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);

   CURSOR c_partitions
   IS
   
   SELECT table_owner, table_name, partition_name, HIGH_VALUE
        FROM SYS.dba_tab_partitions
       WHERE table_owner ='ESBLOG_TEST'
       AND table_name IN ( 'MESSAGES_CARDV1_QUERY','MESSAGES_OSBV1_QUERY')
       AND PARTITION_NAME NOT IN ('MESS_CARDV1_QUERY_P1','MESSAGES_OSBV1_QUERY_P1');    
       
BEGIN
   FOR cc IN c_partitions
   LOOP
   
      v_highvalue := SUBSTR (cc.HIGH_VALUE, 12, 10);
      v_date :=   TO_DATE (v_highvalue, 'yyyy-mm-dd');
      IF v_date < to_date(sysdate) - 35
      THEN
         cmd :='alter table '|| cc.table_owner|| '.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
         DBMS_OUTPUT.put_line (cmd);
      --execute immediate cmd;
      END IF;
   END LOOP;
END;
/

--schedule
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'JOB_DROP_PARTITION'
      ,start_date      => TO_TIMESTAMP_TZ('2017/03/24 22:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY' --;INTERNVAL=2'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'THUYNTM_DBA.DROP_PARTITION' --procedure name
      ,comments        => 'Job to automatic drop 1-month-ago partition.'
     
    );
  SYS.DBMS_SCHEDULER.ENABLE  (name => 'JOB_DROP_PARTITION');
  --SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(attribute   => 'database_role',value       =>'PRIMARY');
END;
/


select enabled from dba_scheduler_jobs where job_name=''
select status,actual_start_date from dba_scheduler_job_run_details  where job_name=''

-------
- Tạo procedure
create  procedure esblog.drop_partition as
   v_date        date;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);

   CURSOR c_partitions
   IS
   
   SELECT table_name, partition_name, HIGH_VALUE
        FROM user_tab_partitions
       WHERE table_name IN ( 'MESSAGES_CARDV1_QUERY','MESSAGES_OSBV1_QUERY')
       AND PARTITION_NAME NOT IN ('MESS_CARDV1_QUERY_P1','MESSAGES_OSBV1_QUERY_P1');    
       
BEGIN
   FOR cc IN c_partitions
   LOOP
   
      v_highvalue := SUBSTR (cc.HIGH_VALUE, 12, 10);
      v_date :=   TO_DATE (v_highvalue, 'yyyy-mm-dd');
      IF v_date < to_date(sysdate) - 35
      THEN
         cmd :='alter table '|| cc.table_name|| ' drop partition '|| cc.partition_name;
         execute immediate cmd;
      END IF;
   END LOOP;
END;
/
- Tạo Job
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'ESBLOG.JOB_DROP_PARTITION'
      ,start_date      => TO_TIMESTAMP_TZ('2017/03/30 14:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY' --;INTERNVAL=2'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'ESBLOG.DROP_PARTITION' 
      ,comments        => 'Job to automatic drop 1-month-ago partition.'
     
    );
  SYS.DBMS_SCHEDULER.ENABLE  (name => 'ESBLOG.JOB_DROP_PARTITION');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(attribute   => 'database_role',value       =>'PRIMARY');
END;
/
- Kiểm tra log thực thi của job (đảm bảo status là SUCCEEDED)
select status,actual_start_date from dba_scheduler_job_run_details  where job_name=''
***Các bước thực hiện roll out plan
- Disable job 
BEGIN
  SYS.DBMS_SCHEDULER.DISABLE (name => 'ESBLOG.JOB_DROP_PARTITION');
END;
/
- Kiểm tra lại trạng thái của job
select enabled from dba_scheduler_jobs where job_name='JOB_DROP_PARTITION' and owner='ESBLOG';