SELECT p.inst_id, p.server_name,s.username,s.sql_id, p.status FROM gv$px_process p, gv$session s WHERE p.SID=s.SID AND p.serial#=s.serial# AND s.username='ELIXIR';
SELECT /* running SQL */ inst_id, SID, sql_id, SQL_PLAN_HASH_VALUE,status, MODULE, trunc(elapsed_time/1000000) AS elapsed_seconds , BUFFER_GETS, USER_IO_WAIT_TIME/1000000 io_wait_seconds, APPLICATION_WAIT_TIME/1000000 app_wait_seconds, CONCURRENCY_WAIT_TIME/1000000 concurr_wait_seconds, CLUSTER_WAIT_TIME/1000000 cluster_wait_seconds, sql_text, PX_SERVERS_REQUESTED, PX_SERVERS_ALLOCATED FROM Gv$sql_monitor WHERE sql_text IS NOT NULL AND status IN ('EXECUTING','QUEUED') ORDER BY elapsed_seconds DESC;
SELECT /* just done SQL */ inst_id, SID, sql_id, SQL_PLAN_HASH_VALUE, to_char(SQL_EXEC_START,'dd-mon hh24:mi:ss'),status, MODULE, trunc(elapsed_time/1000000) AS elapsed_seconds , BUFFER_GETS, USER_IO_WAIT_TIME/1000000 io_wait_seconds, APPLICATION_WAIT_TIME/1000000 app_wait_seconds, CONCURRENCY_WAIT_TIME/1000000 concurr_wait_seconds, CLUSTER_WAIT_TIME/1000000 cluster_wait_seconds, sql_text, PX_SERVERS_REQUESTED, PX_SERVERS_ALLOCATED FROM Gv$sql_monitor WHERE sql_text IS NOT NULL AND status LIKE 'DONE%' ORDER BY SQL_EXEC_START DESC;
SELECT /* List plans */ sql_id, plan_hash_value,s.instance_number inst,s.snap_id,to_char(s.begin_interval_time,'YYYYMMDD:HH24:MI') snap_time, executions_delta executions, trunc((CASE WHEN executions_delta>0 THEN ((cpu_time_delta/1000000)/executions_delta) ELSE 0 END),2) cpu_per_exe, trunc((CASE WHEN executions_delta>0 THEN ((elapsed_time_delta/1000000)/executions_delta) ELSE 0 END),2) ela_per_exe, trunc((CASE WHEN executions_delta>0 THEN (buffer_gets_delta/executions_delta) ELSE 0 END)) buff_per_exe, trunc((CASE WHEN executions_delta>0 THEN (disk_reads_delta/executions_delta) ELSE 0 END)) prd_per_exe, round((CASE WHEN executions_delta>0 THEN (rows_processed_delta/executions_delta) ELSE 0 END)) rows_per_exe FROM   dba_hist_sqlstat b,   dba_hist_snapshot s WHERE   b.sql_id = '&sqlid'   AND b.snap_id = s.snap_id   AND s.begin_interval_time >= SYSDATE-1000   AND s.instance_number = b.instance_number ORDER BY snap_time DESC;
SELECT /* SQL monitor */ DBMS_SQLTUNE.report_sql_monitor(sql_id=>'6u5kwqxg2wd21',TYPE=>'TEXT', report_level => 'ALL') AS report FROM dual;
SELECT /* Session waiting now*/ * FROM GV$SESSION_WAIT w, gv$session s where w.wait_class <> 'Idle';
SELECT /* Active session hist */ m.INST_ID,m.SESSION_ID,m.SESSION_SERIAL#,m.SESSION_TYPE,s.USERNAME,m.SQL_ID,m.SQL_OPNAME,m.SQL_PLAN_OPERATION,m.MODULE,m.SESSION_STATE,m.EVENT,m.WAIT_CLASS,m.WAIT_TIME,m.TIME_WAITED,m.TM_DELTA_DB_TIME,DELTA_TIME,m.BLOCKING_SESSION_STATUS,m.BLOCKING_HANGCHAIN_INFO,m.CURRENT_FILE#,m.CURRENT_OBJ#,m.P1,m.P1TEXT,m.P2,m.P2TEXT,m.P3,m.P3TEXT,m.MACHINE,m.PROGRAM FROM GV$ACTIVE_SESSION_HISTORY m, GV$SESSION s WHERE m.SESSION_ID=s.SID AND m.SESSION_SERIAL#=s.SERIAL# AND m.SAMPLE_TIME IN (SELECT MAX(d.SAMPLE_TIME) FROM GV$ACTIVE_SESSION_HISTORY d WHERE d.SESSION_ID=d.session_id );
SELECT /* 10g Active session hist */ m.INST_ID,m.SESSION_ID,m.SESSION_SERIAL#, m.SESSION_TYPE,s.USERNAME,m.SQL_ID,m.MODULE,m.SESSION_STATE,m.EVENT,m.WAIT_CLASS,m.WAIT_TIME,m.TIME_WAITED,m.CURRENT_FILE#,m.CURRENT_OBJ#,m.P1,m.P1TEXT,m.P2,m.P2TEXT,m.P3,m.P3TEXT,m.PROGRAM FROM GV$ACTIVE_SESSION_HISTORY m, GV$SESSION s WHERE m.sql_id IS NOT NULL AND m.SESSION_ID=s.SID AND m.SESSION_SERIAL#=s.SERIAL# AND m.SAMPLE_TIME IN (SELECT MAX(d.SAMPLE_TIME) FROM GV$ACTIVE_SESSION_HISTORY d WHERE d.SESSION_ID=d.session_id );
SELECT /* Active SQL */ s.inst_id, s.SID, s.username, s.PDML_STATUS, s.module, s.event, s.wait_time, s.SECONDS_IN_WAIT,s.wait_class, s.sql_id, sq.sql_text FROM gv$session s, gv$sqlarea sq WHERE sq.ADDRESS=s.SQL_ADDRESS AND sq.HASH_VALUE=s.SQL_HASH_VALUE AND s.username <> 'SYS' AND status='ACTIVE'  ORDER BY 1,2;
SELECT /* Search for sql_text */ INST_ID,sql_id, PLAN_HASH_VALUE,child_number, PARSING_SCHEMA_NAME,sql_fulltext FROM gv$sql WHERE sql_text like '%10053sh%';
SELECT /* display plan from explain plan */ * FROM TABLE(dbms_xplan.display);
SELECT /* display plan from cursor */ * FROM TABLE(dbms_xplan.display_cursor('6h39y4ss19trc'));
SELECT /* display plan from cursor */ * FROM TABLE(dbms_xplan.display_cursor(sql_id=>'fvpkb348fhr5k',cursor_child_no=>0,format=>'ALL LAST iostats -Projection -alias'));
SELECT /* display plan from awr */ * FROM TABLE(dbms_xplan.display_awr(db_id=>2079716415, sql_id=>'35wjpfzq5p3xj', plan_hash_value=>2004874965, format=>'ADVANCED -Projection'));
SELECT /* display plan from awr */ * FROM TABLE(dbms_xplan.display_awr(sql_id=>'&sql_id', format=>'ADVANCED -Projection'));
SELECT /* display plan from awr */ * FROM TABLE(dbms_xplan.display_awr('32jnrz9tqzqpb'));
SELECT /* Active session history for sql_id */ SQL_OPNAME,SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS,event,P1TEXT,P2TEXT,P3TEXT,count(*) FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SQL_ID='&sql_id' AND SQL_PLAN_HASH_VALUE='&plan' group by SQL_OPNAME,SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS,event,P1TEXT,P2TEXT,P3TEXT ORDER BY SQL_PLAN_LINE_ID;
SELECT /* display plan from sql_baseline */ * FROM TABLE (DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(sql_handle=>'SQL_c404897453beb5dd', plan_name=>'SQL_PLAN_c8149fj9vxdfx793250c5'));
SELECT /* check if sql_id is using sql_baseline*/ sql_id,SQL_PLAN_BASELINE FROM gv$sql WHERE sql_id='8w791z9bd4rnu';
SELECT /* Index selectivity */ TABLE_OWNER,TABLE_NAME,INDEX_NAME,DISTINCT_KEYS,NUM_ROWS,trunc((DISTINCT_KEYS/NUM_ROWS)*100,2) sel,to_char(LAST_ANALYZED,'dd-mon hh24:mi') FROM DBA_INDEXES WHERE TABLE_NAME='&table_name';
SELECT /* Column in index */ TABLE_OWNER,TABLE_NAME,INDEX_NAME, LISTAGG(COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY COLUMN_POSITION) FROM DBA_IND_COLUMNS WHERE TABLE_NAME='&table_name' GROUP BY TABLE_OWNER,TABLE_NAME,INDEX_NAME ORDER BY 1;
SELECT /* Column statistics */ OWNER, TABLE_NAME, COLUMN_NAME,NUM_DISTINCT,NUM_NULLS,NUM_BUCKETS,LAST_ANALYZED FROM DBA_TAB_COL_STATISTICS WHERE TABLE_NAME='&table_name' order by 1,2,3;
SELECT /* stale=yes */ * FROM DBA_TAB_STATISTICS where TABLE_NAME='TBLN_APLPLG' and STALE_STATS='YES';
SELECT /* statistics history */ ob.owner, ob.object_name, ob.object_type, rowcnt, avgrln ,samplesize, to_char(analyzetime,'dd-mon-rr hh24:mi') last_analyzed FROM sys.WRI$_OPTSTAT_TAB_HISTORY, dba_objects ob WHERE object_name=upper('&TABLE') and object_type in ('TABLE','INDEX') AND object_id=obj# order by savtime desc;
SELECT /* Bind captured in awr */ sn.END_INTERVAL_TIME 	,sb.NAME 	,sb.VALUE_STRING FROM DBA_HIST_SQLBIND sb 	,DBA_HIST_SNAPSHOT sn WHERE sb.sql_id = '&sql_id' AND sb.WAS_CAPTURED = 'YES' AND sn.snap_id = sb.snap_id ORDER BY sb.snap_id 	,sb.NAME; 
SELECT /* Bind captured in cursor */NAME, POSITION,DATATYPE_STRING, VALUE_STRING FROM V$SQL_BIND_CAPTURE WHERE SQL_ID='d9myghq8vck6r' AND CHILD_NUMBER = 0;
SELECT /* AWR - List DBID, DB_NAME */ DISTINCT DB_NAME,DBID, INSTANCE_NAME, INSTANCE_NUMBER FROM DBA_HIST_DATABASE_INSTANCE;
SELECT /* AWR - Min Max snap range */ DBID,instance_number, MIN(SNAP_ID),MAX(snap_id) FROM dba_hist_snapshot GROUP BY DBID,INSTANCE_NUMBER;
SELECT /* AWR - snap range */ DBID,instance_number, SNAP_ID,to_char(BEGIN_INTERVAL_TIME,'dd-Mon-yyyy hh24:mi') FROM dba_hist_snapshot WHERE DBID=:v_dbid AND INSTANCE_NUMBER=1 ORDER BY 1,2,3;
SELECT /* AWR - AWR Configuration*/ * FROM DBA_HIST_WR_CONTROL;
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>15);
EXECUTE DBMS_WORKLOAD_REPOSITORY.DROP_SNAPSHOT_RANGE(low_snap_id=>15658, high_snap_id=>15682, dbid=>2153449404);
exec DBMS_STATS.GATHER_DATABASE_STATS(DEGREE=>4, CASCADE=>TRUE);
exec DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>'HR', CASCADE=>TRUE); 
exec DBMS_STATS.GATHER_TABLE_STATS(ownname=>'SCOTT', tabname=>'EMPLOYEES', CASCADE=>TRUE);
SELECT /* List hints */ * FROM V$SQL_HINT where name like '%LEADING%';
select /* PGA*/ inst_id, sum(PGA_USED_MEM)/1024/1024/1024 using_gb, sum(PGA_ALLOC_MEM)/1024/1024/1024 curr_GB, sum(PGA_MAX_MEM)/1024/1024/1024 max_GB from gv$process group by inst_id;
SELECT /* get DDL SQL */ dbms_metadata.get_ddl ('TABLE', 'PO_XML_TAB_CLOB', 'SYS') FROM dual;
--SQLSET/SPM
exec DBMS_SQLTUNE.CREATE_SQLSET (sqlset_name => 'ACS');
SELECT * FROM dba_sqlset;
select sql_id, PLAN_HASH_VALUE,PARSING_SCHEMA_NAME,ELAPSED_TIME/1000000 elapsed_seconds,substr(sql_text,1,40) text from dba_sqlset_statements where sqlset_name = 'ACS' order by sql_id;
exec DBMS_SQLTUNE.DELETE_SQLSET(sqlset_name=>'ACS');
SELECT * FROM table (DBMS_XPLAN.DISPLAY_SQLSET(sqlset_name=>'ACS', sql_id=>'f09y9z75ruc0s', plan_hash_value=>1483475006, format=>'ALL'));
SELECT * FROM dba_sql_plan_baselines;
SELECT sql_id, PLAN_HASH_VALUE, PARSING_SCHEMA_NAME,sql_text FROM v$sql where sql_text like '%Sales%';
--Blocker vs waiter 11g
select INST_ID, SID hanging_sid, SESS_SERIAL# hanging_serial, BLOCKER_SID, BLOCKER_SESS_SERIAL# from gV$SESSION_BLOCKERS order by 1;
--Blocker vs waiter 10g
select l.sid, l.REQUEST,LMODE, l.BLOCK, l.id1, l.id2, l.ctime, s.ROW_WAIT_OBJ#, s.SQL_ID, s.PREV_SQL_ID from gv$lock l, gv$session s where l.INST_ID=s.INST_ID and l.sid=s.sid and l.type='TX' and (l.REQUEST=6 or l.LMODE=6) order by l.BLOCK desc, l.id1, l.ctime desc ;
--Trace by object_id
SELECT * FROM dba_objects where OBJECT_ID=&object_id;
--row lock waits
select object_name, subobject_name,object_type, statistic_name, value from  v$segment_statistics where statistic_name like '%allocate%' order by value desc;
select distinct statistic_name from v$segment_statistics where statistic_name like '%allocate%';
--Follow a session
--Time spent
SELECT INST_ID,sid,STAT_NAME,trunc(VALUE/1000000) seconds FROM GV$SESS_TIME_MODEL where sid=&SID order by value desc;
--Current waits
SELECT * FROM GV$SESSION_WAIT WHERE SID=&SID AND INST_ID=&inst_id;
SELECT * FROM GV$SESSION_WAIT where wait_class <> 'Idle';
--10 history wait
SELECT * FROM GV$SESSION_WAIT_HISTORY WHERE SID=&SID AND INST_ID=&inst_id;
SELECT * FROM GV$SESSION_WAIT_HISTORY where sid=973;
-- Wait categories
SELECT * FROM GV$SESSION_EVENT where sid=&SID and INST_ID=&inst_id order by TIME_WAITED desc;
--Session vs process
SELECT S.SID, S.SERIAL#, S.USERNAME, S.PROCESS client_proc, P.SPID ser_proc FROM V$SESSION S, V$PROCESS P WHERE S.PADDR  = P.ADDR AND S.SID=&SID;
--Trace file name
SELECT TRACEFILE FROM V$PROCESS P WHERE P.SPID=&PROCESS_ID;
--Statistics
select  a.column_name, a.NUM_DISTINCT, a.density, a.num_nulls, display_raw(a.low_value,b.data_type) as low_val, display_raw(a.high_value,b.data_type) as high_val, b.data_type FROM DBA_tab_col_statistics A, DBA_tab_cols b WHERE a.table_name='CUSTOMERS' and A.table_name=b.table_name AND a.column_name=b.column_name;
SELECT COLUMN_NAME,HISTOGRAM,NUM_BUCKETS, NUM_DISTINCT,NUM_NULLS FROM DBA_TAB_COLUMNS WHERE TABLE_NAME='CUSTOMERS' AND OWNER='SH' and HISTOGRAM != 'NONE';

--script to create report
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 150
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF
SPOOL report_sql.htm
SELECT DBMS_SQLTUNE.report_sql_monitor(sql_id=>'&sql_id',type=>'TEXT',report_level => 'ALL') AS report FROM dual;
SPOOL OFF

----detail report
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 150
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF
SPOOL report_sql_detail.htm
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id=> '&sql_id', type=> 'ACTIVE',report_level => 'ALL') AS report FROM dual;
SPOOL OFF

------
SELECT * FROM gv$session WHERE status='ACTIVE' AND username IS NOT NULL;
select * from v$instance;