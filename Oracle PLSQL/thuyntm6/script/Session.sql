	E:\jtds\jtds-1.3.1-dist\x64\SSO

C:\Setup\sqldeveloper-4.0.3.16.84-x64\sqldeveloper\jdk\jre\bin

select
   c.owner||'.'||   c.object_name,
   b.sid||'.'||   b.serial#
from
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id
   order by 1;
   
   
select * from v$locked_object a, dba_objects b
where a.object_id=b.object_id
and b.object_name='FBNK_RE_CONSOL_PROFIT'   

----========long running sql
select module,sql_exec_start,sql_id,round(elapsed_time/60000000,0) elapsed_time,sql_text 
from sv$sql_monitor where elapsed_time/60000000>10 and last_refresh_time>TRUNC(SYSDATE,'MI')--and status='EXECUTING'

----========long transaction in golden gate-->wait commit
http://rajkiran-dba.blogspot.com/2013/05/oracle-golden-gate-long-running.html
./ggsci
stop ET24DC
Long Running Transaction: XID 826.0.225946, Items 1357, Extract ET24DC, Redo Thread 1, SCN 2455.4202581884 (10548347293564), Redo Seq #31304, Redo RBA 1143368148.
select * from gv$transaction where xidusn=826;--ADDR

select sid,serial#,event,machine,sql_id,seconds_in_wait,prev_sql_id,module,program,action from gv$session where taddr='0000001BFF3DEBD8'; --SQL_ID

select hash_value, address, executions,buffer_gets, disk_reads,round(buffer_gets/decode(executions, 0, 1, executions), 1) avg_gets,
round(disk_reads/decode(executions, 0, 1, executions), 1) avg_disk,last_load_time,module,sql_fulltext
from v$sqlarea
where sql_id='&sql_id';

select logon_time,status,LAST_CALL_ET from gv$session where sid=9871 and inst_id=2;

--or you can use:
set echo on
set timing on
col sid format 999999
col sid format 999999
col serial# format 999999
alter session set nls_date_format='MM/DD/YYYY HH24:MI:SS';
select  t.start_time,t.status TSTATUS, s.status SSTATUS,s.sid, s.serial# ,s.machine , s.sql_id,s.prev_sql_id,s.process,t.XIDUSN||'.'||t.XIDSLOT||'.'||t.XIDSQN XID 
from gv$transaction t, gv$session s  
where t.addr=s.taddr and t.inst_id=s.inst_id and t.start_date < (sysdate-1/142) order  by t.start_time;

alter system kill session '9871,167';

----========trace session
https://oracle-base.com/articles/misc/sql-trace-10046-trcsess-and-tkprof
http://www.petefinnigan.com/ramblings/how_to_set_trace.htm
http://www.juliandyke.com/Diagnostics/Packages/DBMS_MONITOR/SESSION_TRACE_ENABLE.php
https://www.dba-scripts.com/scripts/diagnostic-and-tuning/troubleshooting/dbms_monitor_trace/

 select x.ksppinm name,y.ksppstvl value
from sys.x$ksppi x,sys.x$ksppcv y
where x.inst_id=userenv('Instance')
and y.inst_id=userenv('Instance')
and x.indx=y.indx
and x.ksppinm='_trace_files_public';

--enable trace
exec dbms_monitor.session_trace_enable(sid,serial#,TRUE,FALSE);

select 'exec dbms_monitor.session_trace_enable('||sid||','||serial#||',TRUE,FALSE);' from gv$session where username='T24LIVE'  and machine='dr-core-app-poc' and osuser='t24';

EXECUTE DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE('janedoe', TRUE,FALSE);

execute dbms_monitor.session_trace_enable(session_id => <sid>,
                                          serial_num => <serial#>,
                                          waits => TRUE,
                                          binds => FALSE);

--find logfile
SELECT s.sid,p.tracefile
FROM   gv$session s
       JOIN gv$process p ON s.paddr = p.addr and s.inst_id=p.inst_id
WHERE  s.sid in (7496);

--convert logfile to readable
cd /u01/app/oracle/admin/DEV/udump/
tkprof dev1_ora_367660.trc translated.txt explain=test/test table=sys.plan_table sys=no waits=yes										  
tkprof t24dev1_ora_965.trc session_trace_5014.txt explain=dbsnmp/PAssw0rd sys=no waits=yes	

--disable trace
exec DBMS_MONITOR.SESSION_TRACE_DISABLE(sid,serial#);


CREATE TRIGGER ON_MY_SCHEMA_LOGIN
AFTER LOGON ON DATABASE
WHEN ( osuser='devpost')
BEGIN
execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

CREATE  TRIGGER SYS.LOGON_TRIGGER_TEST
AFTER LOGON ON DATABASE
BEGIN
IF SYS_CONTEXT('USERENV','OS_USER') in ('t24test3')
AND SYS_CONTEXT('USERENV','HOST') in ('t24tcb9')
THEN
execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
END IF;
 EXCEPTION
 WHEN OTHERS THEN
 RETURN;
 END;
/
										  

CREATE OR REPLACE TRIGGER logon_trace AFTER LOGON ON DATABASE
DECLARE
command varchar2(4000);

BEGIN
IF (SYS_CONTEXT ('USERENV','OS_USER') IN ('test2os'))

THEN
for cmd in ( SELECT sid, serial# FROM v$session WHERE osuser = 'test2os' )
loop
command := 'DBMS_MONITOR.SESSION_TRACE_ENABLE('||cmd.sid||','||cmd.serial#||', true, false)';
EXECUTE IMMEDIATE cmd;
end loop;
ELSE
NULL;
END IF;
END;
/


--> trigger trace session for os_user
CREATE OR REPLACE TRIGGER logon_trace AFTER LOGON ON DATABASE
DECLARE
cmd varchar2(4000);

BEGIN
IF (SYS_CONTEXT ('USERENV','OS_USER') IN ('test2os'))
THEN

for cmd in ( SELECT 'DBMS_MONITOR.SESSION_TRACE_ENABLE('||sid||','||serial#||', true, false)' sa FROM gv$session WHERE osuser = 'test2os')
loop
EXECUTE IMMEDIATE cmd.sa;
end loop;

END IF;
END;
/
----========Wait event 
select wait_class,count(*) from gV$SESSION_WAIT
where wait_class <> 'Idle'
group by wait_class
order by 2 desc

----========find event wait most
select event,count(*) from v$session 
where  status='ACTIVE'
group by event
order by 2 desc

----========enq: TX row lock contention
--Finding Blockers: Details of the object / block / row that caused the wait can usually be found in the ROW_WAIT_* columns
SELECT row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#
  FROM v$session
 WHERE event='enq: TX - row lock contention'
   AND state='WAITING';

If the OBJ# is -1 then the object could not be determined.
P2 and P3 correspond to the ID1 and ID2 columns of [G]V$LOCK for rows with TYPE='TX'.
P2 and P3 also give the XIDUSN/XIDSLOT/XIDSQN values of the blocking transaction in [G]V$TRANSACTION.

--You can identify the specific TX lock being waited on, and blocking tranaction id, using SQL like this:
SELECT 
   sid, seq#, state, seconds_in_wait,
   'TX-'||lpad(ltrim(p2raw,'0'),8,'0')||'-'||lpad(ltrim(p3raw,'0'),8,'0') TX,
   trunc(p2/65536)      XIDUSN,
   trunc(mod(p2,65536)) XIDSLOT,
   p3                   XIDSQN
  FROM v$session_wait 
 WHERE event='enq: TX - row lock contention';

 --You can find current blockers by querying GV$LOCK like this:
SELECT distinct w.tx, l.inst_id, l.sid, l.lmode, l.request
 FROM 
  ( SELECT p2,p3,
     'TX-'||lpad(ltrim(p2raw,'0'),8,'0')||'-'||lpad(ltrim(p3raw,'0'),8,'0') TX
      FROM v$session_wait 
     WHERE event='enq: TX - row lock contention'
       and state='WAITING'
  ) W, 
  gv$lock L
 WHERE l.type(+)='TX'
   and l.id1(+)=w.p2
   and l.id2(+)=w.p3
 ORDER BY tx, lmode desc, request desc;

If the sequence of events leading to the row contention is not clear then one could use LogMiner to get details of what the transactions involved did in what order.

----========login fail
select username, os_username, userhost, client_id, to_char(timestamp,'YYYY/MM/DD HH24:MI'), returncode, count(*) logins
from dba_audit_trail
where timestamp>trunc(sysdate)+10/24 and timestamp<trunc(sysdate)+10/24+1/48
--and returncode=1017 --1017=invalid user/password
group by username,os_username,userhost, client_id, to_char(timestamp,'YYYY/MM/DD HH24:MI'), returncode 
order by to_char(timestamp,'YYYY/MM/DD HH24:MI');


----========Longops
select substr(message,0,30) ||'...('||'User '|| username||' - '|| sql_text||')' as Message,round(time_remaining/3600,2) as remain_by_hour 
from gV$SESSION_LONGOPS a, gv$sqlarea b
where a.sql_id=b.sql_id 
and time_remaining/3600>4
and last_update_time > SYSDATE - 1 / 48
and username <> 'SYS'
and username not like '%_DBA'
and username not like '%_DBA'
and a.inst_id=b.inst_id

----========lock object / session 
SELECT B.Owner, B.Object_Name,A.session_id, A.Oracle_Username, A.OS_User_Name  
FROM V$Locked_Object A, dba_Objects B
WHERE A.Object_ID = B.Object_ID
and B.owner=''

select count(*), sql_address from v$session where username =''
group by sql_address
order by 1 desc

select sql_text  from v$sqltext  
where address=''
order by piece


----========kill
select 'alter system kill session '''||SID||','||Serial#||','||',@'||INST_ID||''';' from gv$session
alter system kill session 'sid, serial#';


----========block session
SELECT 
   l1.inst_id,l1.sid || ' is blocking ' || l2.sid blocking_sessions
FROM 
   gv$lock l1, gv$lock l2
WHERE
   l1.block = 1 AND
   l2.request > 0 AND
   l1.id1 = l2.id1 AND
   l1.id2 = l2.id2
   and l1.inst_id=l2.inst_id

   
   
COLUMN "SID-SPID-PID" FORMAT A15
      COLUMN "User"         FORMAT A12
      COLUMN "OSUser"       FORMAT A12
      COLUMN "Machine"      FORMAT A10
      COLUMN "Ty"           FORMAT A3
      COLUMN "Md"           FORMAT 99
      COLUMN "RowId"        FORMAT A18
      COLUMN "ObjId"        FORMAT 999999
      COLUMN "Waiting Row"  FORMAT A19

      SET PAGES 24
      SET NEWPAGE 0
      SET LINES 132
      SET FEEDBACK OFF

      TTITLE LEFT '|------------------HOLDING-----------------||----------------------------------------WAITING--------------------- ------------------|'

      SELECT /*+ RULE */
              h.sid||'-'||hp.spid||'-'||hp.pid   "SID-SPID-PID",
              nvl(hs.client_info,hs.osuser) "OSUser",
              hs.machine                    "Machine",
              h.lmode                       "Md",
              nvl(ws.client_info,ws.osuser) "OSUser",
              ws.machine                    "Machine",
              w.type                        "Type",
              w.request                     "Md",
              w.id1,
              w.id2,
              ws.ROW_WAIT_OBJ#||'-'||ws.ROW_WAIT_FILE#||'-'||ws.ROW_WAIT_BLOCK#||'-'||ws.ROW_WAIT_ROW#  "Waiting Row",
              w.sid||'-'||wp.spid||'-'||wp.pid   "SID-SPID-PID"
          --  dbms_rowid.rowid_create(1,ws.ROW_WAIT_OBJ#,ws.ROW_WAIT_FILE#,ws.ROW_WAIT_BLOCK#,ws.ROW_WAIT_ROW#) "RowId"
        FROM (SELECT sid, type, lmode, request, id1, id2 FROM V$LOCK ) w,
             (SELECT sid, type, lmode, id1, id2, block,ctime FROM V$LOCK ) h,
              V$SESSION hs, V$SESSION ws,
              V$PROCESS hp, V$PROCESS wp
       WHERE h.block    = 1
         AND  h.lmode   !=  0
         AND  h.lmode   !=  1
         AND  h.sid      = hs.sid
         AND  w.sid      = ws.sid
         AND  w.request !=  0
         AND  w.type     =  h.type
         AND  w.type     IN  ('TM','TX')
         AND  w.id1      =  h.id1
         AND  w.id2      =  h.id2
         AND  hs.paddr   =  hp.addr
         AND  ws.paddr   =  wp.addr
                                AND  h.ctime>300;
   
----========user status
select schemaname, status, count(*) from v$session 
where schemaname='ESBDATA'
group by schemaname, status
order by 3 desc

----========Getting specific row information
select
    owner||'.'||object_name||':'||nvl(subobject_name,'-') obj_name,
    dbms_rowid.rowid_create (
        1,
        o.data_object_id,
        row_wait_file#,
        row_wait_block#,
        row_wait_row#
    ) row_id
from v$session s, dba_objects o
where sid = &sid
and o.data_object_id = s.row_wait_obj#

----========Listing consumer groups 
select sample_time, session_state, event, consumer_group_id
from v$active_session_history
where user_id = 92
and sample_time between
    to_date('29-SEP-12 04.55.02 PM','dd-MON-yy hh:mi:ss PM')
    and
    to_date('29-SEP-12 05.05.02 PM','dd-MON-yy hh:mi:ss PM')
and session_id = 44
--machine = 'prolaps01'
order by 1;

select name
from v$rsrc_consumer_group
where id in (12166,12162); 

----========Getting row lock information from the Active Session History archive 
select sample_time, session_state, blocking_session,
owner||'.'||object_name||':'||nvl(subobject_name,'-') obj_name,
    dbms_ROWID.ROWID_create (
        1,
        o.data_object_id,
        current_file#,
        current_block#,
        current_row#
    ) row_id
from dba_hist_active_sess_history s, dba_objects o
where user_id = 92
and sample_time between
    to_date('29-SEP-12 04.55.02 PM','dd-MON-yy hh:mi:ss PM')
    and
    to_date('29-SEP-12 05.05.02 PM','dd-MON-yy hh:mi:ss PM')
and event = 'enq: TX - row lock contention'
and o.data_object_id = s.current_obj#
order by 1,2;

----========enq: SQ - contention
select sql_id,count(*)
from v$active_session_history
where event='enq: SQ - contention' and
to_char(SAMPLE_TIME,'DDMMYYYY HH24:MI')>='06092017 09:00'
--and to_char(SAMPLE_TIME,'DDMMYYYY HH24:MI')<'05092017 08:50'
group by sql_id
order by 2 desc; 


fp1jhm4v70qhm	433
1vxtgfzd26kgw	162
bnd3crmfgrcwy	153

MERGE INTO F_OS_XML_CACHE USING DUAL ON (RECID = :RECID)                                                         
WHEN MATCHED THEN UPDATE SET XMLRECORD=XMLTYPE(:XMLRECORD, NULL, 1, 1)                                                                     
WHEN NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(XMLTYPE(:XMLRECORD, NULL, 1, 1) ,:RECID)

MERGE INTO F_PROTOCOL USING DUAL ON (RECID = :RECID)                                                         
WHEN MATCHED THEN UPDATE SET XMLRECORD=XMLTYPE(:XMLRECORD, NULL, 1, 1)                                                                     
WHEN NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(XMLTYPE(:XMLRECORD, NULL, 1, 1) ,:RECID)

MERGE INTO F_ENQUIRY_LEVEL USING DUAL ON (RECID = :RECID)                                                         
WHEN MATCHED THEN UPDATE SET XMLRECORD=:XMLRECORD                                                                      
NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(:XMLRECORD ,:RECID)
----========enq: TX - contention
SELECT sid,  p1raw,  p2,  p3
FROM gv$session_wait
WHERE wait_time     = 0
AND event        like 'enq: TX%';

-- sessions waiting for a TX lock:
SELECT * FROM gv$lock WHERE type='TX' AND request>0;

-- sessions holding a TX lock:
SELECT * FROM gv$lock WHERE type='TX' AND lmode > 0;

--which segments have undergone the most row lock waits:
SELECT owner, object_name, subobject_name, value
FROM v$segment_statistics
WHERE statistic_name='row lock waits'
AND value > 0
ORDER BY 4 DESC;

----========wait concurency : cursor: pin S wait on X
select inst_id,sql_id,p2raw,to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') sid,count(*)  from gv$session
where event='cursor: pin S wait on X'
group by inst_id,sql_id,p2raw,to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') 
order by 5 desc

select sid,serial#,SQL_ID,BLOCKING_SESSION,BLOCKING_SESSION_STATUS,EVENT 
     from v$session where event ='cursor: pin S wait on X';

select sql_id,loaded_versions,executions,loads,invalidations,parse_calls
from gv$sql 
where inst_id=4 and sql_id='cn7m7t6y5h77g';

SELECT s.sid, t.sql_text
FROM v$session s, v$sql t
WHERE s.event LIKE '%cursor: pin S wait on X%'
AND t.sql_id = s.sql_id

select * --inst_id,sid,seq#,seconds_in_wait,wait_time_micro
from gV$SESSION_WAIT where wait_class='' order by  seconds_in_wait, wait_time_micro desc
===========================
SELECT t.XMLRECORD.getClobVal()
FROM F_OS_TOKEN t
WHERE RECID =:RECID
plan hash value 1690416507

SELECT t.XMLRECORD
FROM VOC t
WHERE RECID =:RECID
=============================
 set echo off 
spool pool_est 
/* 
********************************************************* 
*                                                       * 
* TITLE        : Shared Pool Estimation                 * 
* CATEGORY     : Information, Utility                   * 
* SUBJECT AREA : Shared Pool                            * 
* DESCRIPTION  : Estimates shared pool utilization      * 
*  based on current database usage. This should be      * 
*  run during peak operation, after all stored          * 
*  objects i.e. packages, views have been loaded.       * 
* NOTE:  Modified to work with later versions 4/11/06   * 
*                                                       * 
********************************************************/ 
Rem If running MTS uncomment the mts calculation and output 
Rem commands. 
 
set serveroutput on; 
 
declare 
        object_mem number; 
        shared_sql number; 
        cursor_ovh number;
        cursor_mem number; 
        mts_mem number; 
        used_pool_size number; 
        free_mem number; 
        pool_size varchar2(512); -- same as V$PARAMETER.VALUE 
begin 
 
-- Stored objects (packages, views) 
select sum(sharable_mem) into object_mem from v$db_object_cache
where type <> 'CURSOR';
 
-- Shared SQL -- need to have additional memory if dynamic SQL used 
select sum(sharable_mem) into shared_sql from v$sqlarea; 
 
-- User Cursor Usage -- run this during peak usage. 
--  assumes 250 bytes per open cursor, for each concurrent user. 
select sum(250*users_opening) into cursor_ovh from v$sqlarea; 

select sum(sharable_mem) into cursor_mem from v$db_object_cache
WHERE type='CURSOR';
 
-- For a test system -- get usage for one user, multiply by # users 
-- select (250 * value) bytes_per_user 
-- from v$sesstat s, v$statname n 
-- where s.statistic# = n.statistic# 
-- and n.name = 'opened cursors current' 
-- and s.sid = 25;  -- where 25 is the sid of the process 
 
-- MTS memory needed to hold session information for shared server users 
-- This query computes a total for all currently logged on users (run 
--  during peak period). Alternatively calculate for a single user and 
--  multiply by # users. 
select sum(value) into mts_mem from v$sesstat s, v$statname n 
       where s.statistic#=n.statistic# 
       and n.name='session uga memory max'; 
 
-- Free (unused) memory in the SGA: gives an indication of how much memory 
-- is being wasted out of the total allocated. 
-- For pre-9i issue
-- select bytes into free_mem from v$sgastat 
--        where name = 'free memory';

-- with 9i and newer releases issue
select bytes into free_mem from v$sgastat 
        where name = 'free memory'
        and pool = 'shared pool';

 
-- For non-MTS add up object, shared sql, cursors and 20% overhead.
-- Not including cursor_mem because this is included in shared_sql 
used_pool_size := round(1.2*(object_mem+shared_sql)); 
 
-- For MTS mts contribution needs to be included (comment out previous line) 
-- used_pool_size := round(1.2*(object_mem+shared_sql+mts_mem)); 

-- Pre-9i or if using manual SGA management, issue 
-- select value into pool_size from v$parameter where name='shared_pool_size'; 

-- With 9i and 10g and and automatic SGA management, issue
select  c.ksppstvl into pool_size from x$ksppi a, x$ksppcv b, x$ksppsv c
     where a.indx = b.indx and a.indx = c.indx
       and a.ksppinm = '__shared_pool_size';
 
-- Display results 
dbms_output.put_line ('Obj mem:  '||to_char (object_mem) || ' bytes ' || '('
|| to_char(round(object_mem/1024/1024,2)) || 'MB)'); 
dbms_output.put_line ('Shared sql:  '||to_char (shared_sql) || ' bytes ' || '('
|| to_char(round(shared_sql/1024/1024,2)) || 'MB)'); 
dbms_output.put_line ('Cursors:  '||to_char (cursor_mem+cursor_ovh) || ' bytes '
|| '('|| to_char(round((cursor_mem+cursor_ovh)/1024/1024,2)) || 'MB)'); 
-- dbms_output.put_line ('MTS session: '||to_char (mts_mem) || ' bytes'); 
dbms_output.put_line ('Free memory: '||to_char (free_mem) || ' bytes ' || '(' 
|| to_char(round(free_mem/1024/1024,2)) || 'MB)'); 
dbms_output.put_line ('Shared pool utilization (total):  '|| 
to_char(used_pool_size) || ' bytes ' || '(' || 
to_char(round(used_pool_size/1024/1024,2)) || 'MB)'); 
dbms_output.put_line ('Shared pool allocation (actual):  '|| pool_size ||
'bytes ' || '(' || to_char(round(pool_size/1024/1024,2)) || 'MB)'); 
dbms_output.put_line ('Percentage Utilized:  '||to_char 
(round(((pool_size-free_mem) / pool_size)*100)) || '%'); 
end; 
/ 
 
spool off

Obj mem:  594169752 bytes (566.64MB)
Shared sql:  2148299865 bytes (2048.78MB)
Cursors:  2413308334 bytes (2301.51MB)
Free memory: 1960083608 bytes (1869.28MB)
Shared pool utilization (total):  3290963540 bytes (3138.51MB)
Shared pool allocation (actual):  14763950080bytes (14080MB)
Percentage Utilized:  87%
===========================

