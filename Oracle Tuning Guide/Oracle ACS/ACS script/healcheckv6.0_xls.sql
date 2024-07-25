set termout off
column timecol new_value timestamp 
column spool_extension new_value suffix 
select to_char(sysdate,'DD_MON_YYYY_HH24_MI_SS') timecol,'.xls' spool_extension from sys.dual; 
column output new_value dbname 
select value || '_' output from v$parameter where name = 'db_name';
set feed off markup html on spool on 
alter session set nls_date_format='YYYY-MM-DD';
set serveroutput on
set termout off
set echo off
set pagesize 50000
clear column
clear breaks
spool DBHeathcheck_DBUpTime_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == DB UPTIME ==
PROMPT ==============================================================================================
prompt
COLUMN Inst_id                      HEADING "I#"                FORMAT 99
COLUMN instance_name                HEADING "Instance|Name"     FORMAT a10 
COLUMN status                       HEADING "Instance|Status"   FORMAT a10 
COLUMN host_name                    HEADING "Hostname"          FORMAT a15 TRUNCATE
COLUMN startup_time                 HEADING "StartupTime"       FORMAT a18 
COLUMN uptime1                      HEADING "Uptime|(Days)"     FORMAT 9999 JUSTIFY RIGHT
COLUMN uptime2                      HEADING "Uptime"            FORMAT a18 JUSTIFY RIGHT

select inst_id
     , instance_name
     , SUBSTR(host_name,1,DECODE(instr(host_name,'.'),0,LENGTH(host_name),instr(host_name,'.')-1)) host_name
     , to_char(startup_time,'DD-MON-YY HH24:MI:SS') startup_time 
     --, ROUND(sysdate - startup_time, 2) uptime1
     ,    LPAD(FLOOR(sysdate - startup_time) || 'd '
       || LPAD(FLOOR(MOD((sysdate - startup_time) , 1) * 24 ) ,2) || 'h '
       || LPAD(FLOOR(MOD((sysdate - startup_time) * 24 , 1) * 60 ) ,2) || 'm '
       || LPAD(FLOOR(MOD((sysdate - startup_time) * 24 * 60 , 1) * 60 ) ,2) || 's'
       , 18) uptime2
from gv$instance order by 1;
spool off


spool DBHeathcheck_DBInfo_&&dbname&&timestamp&&suffix 

PROMPT ==============================================================================================
PROMPT == DB INFORMATION ==
PROMPT ==============================================================================================

COLUMN name FORMAT a15 HEADING 'Database|Name' 
COLUMN dbid HEADING 'Database|ID' 
COLUMN db_unique_name FORMAT a15 HEADING 'Database|Unique Name'
COLUMN creation_date FORMAT a15  HEADING 'Creation|Date' 
COLUMN platform_name_print FORMAT a15  HEADING 'Platform|Name' 
COLUMN current_scn HEADING 'Current|SCN' 
COLUMN log_mode FORMAT a12 HEADING 'Log|Mode' 
COLUMN open_mode FORMAT a10 HEADING 'Open|Mode'
COLUMN force_logging HEADING 'Force|Logging'
COLUMN flashback_on HEADING 'Flashback|On?'
COLUMN controlfile_type FORMAT a15  HEADING 'Controlfile|Type'
COLUMN last_open_incarnation_number HEADING 'Last Open|Incarnation Num'


SELECT
name
,dbid
,db_unique_name
,TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') creation_date
,platform_name platform_name_print
,current_scn
,log_mode
,open_mode
,force_logging
,flashback_on
,controlfile_type
,last_open_incarnation# last_open_incarnation_number
FROM v$database;

PROMPT ==============================================================================================
PROMPT == INSTANCE VERSION ==
PROMPT ==============================================================================================

clear columns
set linesize 400 
set pagesize 10000
COLUMN instance_name_print       FORMAT a15    HEADING 'Instance|Name'
COLUMN instance_number_print     FORMAT 999    HEADING 'Instance|Num'
COLUMN thread_number_print                     HEADING 'Thread|Num' 
COLUMN host_name_print           FORMAT a20    HEADING 'Host|Name'
COLUMN version                                 HEADING 'Oracle|Version'
COLUMN start_time                FORMAT a20    HEADING 'Start|Time' 
COLUMN uptime                                  HEADING 'Uptime|(in days)' 
COLUMN parallel                  FORMAT 9999    HEADING 'Parallel - (RAC)'
COLUMN instance_status           FORMAT a10   HEADING 'Instance|Status'
COLUMN database_status           FORMAT a10    HEADING 'Database|Status'
COLUMN logins                    FORMAT 9999    HEADING 'Logins'  
COLUMN archiver                  FORMAT a20    HEADING 'Archiver'

SELECT
instance_name instance_name_print,
instance_number                     instance_number_print,
thread#                                           thread_number_print,
host_name                                       host_name_print,
version                                         version,
TO_CHAR(startup_time,'mm/dd/yyyy HH24:MI:SS')          start_time
  , ROUND(TO_CHAR(SYSDATE-startup_time), 2) uptime,
parallel,
status instance_status,
logins,archiver 
FROM gv$instance
ORDER BY instance_number;

PROMPT ==============================================================================================
PROMPT == DATABASE PROPERTIES ==
PROMPT ==============================================================================================
col property_name for a40
col property_value for a50
col description for a60
SELECT * FROM database_properties;

spool off

spool DBHeathcheck_Patches_&&dbname&&timestamp&&suffix 

PROMPT ==============================================================================================
PROMPT == DATABASE PATCH FOR 11G ==
PROMPT ==============================================================================================
SELECT action_time, action, namespace, version, id, comments FROM dba_registry_history;
select substr(comp_name,1,30) comp_name, substr(comp_id,1,10) comp_id,substr(version,1,12) version,status from dba_registry;

PROMPT ==============================================================================================
PROMPT == DATABASE PATCH FOR 12C ==
PROMPT ==============================================================================================
select patch_id,status,action_time from dba_registry_sqlpatch;

spool off

spool DBHeathcheck_DBStorage_ControlFile_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == CONTROL FILE INFO==
PROMPT ==============================================================================================

COLUMN name       FORMAT a85    HEADING "Controlfile Name"
COLUMN status                   HEADING "Status"

SELECT
    name
  , LPAD(status, 7) status
FROM v$controlfile
ORDER BY name
/

PROMPT ==============================================================================================
PROMPT == CONTROL FILE RECORDS==
PROMPT ==============================================================================================

COLUMN type           FORMAT           a30   HEADING "Record Section Type"
COLUMN record_size    FORMAT       999,999   HEADING "Record Size|(in bytes)"
COLUMN records_total  FORMAT       999,999   HEADING "Records Allocated"
COLUMN bytes_alloc    FORMAT   999,999,999   HEADING "Bytes Allocated"
COLUMN records_used   FORMAT       999,999   HEADING "Records Used"
COLUMN bytes_used     FORMAT   999,999,999   HEADING "Bytes Used"
COLUMN pct_used       FORMAT           B999  HEADING "% Used"
COLUMN first_index                           HEADING "First Index"
COLUMN last_index                            HEADING "Last Index"
COLUMN last_recid                            HEADING "Last RecID"

BREAK ON report

COMPUTE sum OF records_total ON report
COMPUTE sum OF bytes_alloc   ON report
COMPUTE sum OF records_used  ON report
COMPUTE sum OF bytes_used    ON report
COMPUTE avg OF pct_used      ON report

SELECT
    type
  , record_size
  , records_total
  , (records_total * record_size) bytes_alloc
  , records_used
  , (records_used * record_size) bytes_used
  , NVL(records_used/records_total * 100, 0) pct_used
  , first_index
  , last_index
  , last_recid
FROM v$controlfile_record_section
ORDER BY type
/

spool off

spool DBHeathcheck_DBStorage_DataFile_&&dbname&&timestamp&&suffix 

set linesize 400

PROMPT ==============================================================================================
PROMPT == NUMBER OF DATAFILES ==
PROMPT ==============================================================================================

col type format a15 head 'File Type'
col asm_dg format a32 head 'ASM Diskgroup path'
col cnt format 9999 head 'Number of files'
set linesize 400
set pagesize 1000
set echo off
select 'Data Files' type,
	substr(name,1,instr(name,'/',1,2)-1) asm_dg,
	count(*) cnt
from 	v$datafile
group by substr(name,1,instr(name,'/',1,2)-1)
union
select 'Temp Files',
	substr(name,1,instr(name,'/',1,2)-1) asm_dg, 
	count(*) cnt
from v$tempfile
group by substr(name,1,instr(name,'/',1,2)-1)
union
select 'Redo Member',
	substr(member,1,instr(member,'/',1,2)-1) asm_dg, 
	count(*) cnt
from v$logfile
group by substr(member,1,instr(member,'/',1,2)-1)
/

PROMPT ==============================================================================================
PROMPT == DATA FILES USAGES ==
PROMPT ==============================================================================================
col file_name for a40
SELECT SUBSTR (df.NAME, 1, 40) file_name, df.bytes / 1024 / 1024 "Allocated Size(MB)",
((df.bytes / 1024 / 1024) - NVL (SUM (dfs.bytes) / 1024 / 1024, 0)) "Used Size (MB)",
NVL (SUM (dfs.bytes) / 1024 / 1024, 0) "Free Size(MB)"
FROM v$datafile df, dba_free_space dfs
WHERE df.file# = dfs.file_id(+)
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes
ORDER BY file_name;

PROMPT ==============================================================================================
PROMPT == DATA FILES ULTILIZATION ==
PROMPT ==============================================================================================
col file_name for a60
col tablespace_name for a20
select file_name,tablespace_name,sum(bytes)/1024/1024 "Current Size (MB)",
sum(maxbytes)/1024/1024 "Max Size (MB)"
from dba_data_files
group by file_name,tablespace_name;


PROMPT ==============================================================================================
PROMPT == DATA FILES HIGH WATERMARK ==
PROMPT ==============================================================================================

col tablespace_name format a15
col file_size format 99999
col file_name format a50
col hwm format 99999
col can_save format 99999

SELECT tablespace_name, file_name, file_size, hwm, file_size-hwm can_save
FROM (
  SELECT /*+ RULE */ ddf.tablespace_name,
    REPLACE(ddf.file_name, 'C:\ORACLE\PRODUCT','$ORACLE_HOME') file_name,
    ddf.bytes/1048576 file_size,
    (ebf.maximum + de.blocks-1)*dbs.db_block_size/1048576 hwm
  FROM dba_data_files ddf,
    (SELECT file_id, MAX(block_id) maximum FROM dba_extents GROUP BY file_id) ebf,
    dba_extents de,
    (SELECT value db_block_size FROM v$parameter WHERE name='db_block_size') dbs
  WHERE ddf.file_id = ebf.file_id
  AND de.file_id = ebf.file_id
  AND de.block_id = ebf.maximum
  ORDER BY 1,2);

spool off

spool DBHeathcheck_DBStorage_Redo_&&dbname&&timestamp&&suffix 
set linesize 400
set pagesize 10000
col member for a60

PROMPT ==============================================================================================
PROMPT == REDO GENERATE BY DAY ==
PROMPT ==============================================================================================

select trunc(completion_time) rundate,count(*) logswitch,round((sum(blocks*block_size)/1024/1024)) "REDO PER DAY (MB)" from v$archived_log group by trunc(completion_time) order by 1;

PROMPT ==============================================================================================
PROMPT == AVERAGE SWITCH LOGFILE ==
PROMPT ==============================================================================================

WITH redo_log_switch_times AS (SELECT   sequence#, first_time,LAG (first_time, 1) OVER (ORDER BY first_time) AS LAG,first_time- LAG (first_time, 1) OVER (ORDER BY first_time) lag_time,1440* (first_time - LAG (first_time, 1) OVER (ORDER BY first_time)) lag_time_pct_mins FROM v$log_history ORDER BY sequence#) SELECT round(AVG (lag_time_pct_mins),1) avg_log_switch_min  FROM redo_log_switch_times;

PROMPT ==============================================================================================
PROMPT == STANDBY ONLINE REDOLOG FILE ==
PROMPT ==============================================================================================
COLUMN type            HEADING "Redo|Log|Type"               FORMAT a7
COLUMN group#          HEADING "Group#"                      FORMAT 9999
COLUMN thread#         HEADING "Thread#"                     FORMAT 9999
COLUMN status          HEADING "Status"                      FORMAT a10
COLUMN archived        HEADING "Archived"                    FORMAT a10
COLUMN members         HEADING "Members"                     FORMAT 99999
COLUMN sequence#       HEADING "Seq#"                        FORMAT 9999999
COLUMN Size_MB         HEADING "Size|(MB)"                   FORMAT 99999
COLUMN used_MB         HEADING "Used|(MB)"                   FORMAT 99999
COLUMN first_time      HEADING "FirstTime"                   FORMAT a20
COLUMN next_time       HEADING "NextTime"                    FORMAT a20
COLUMN last_time       HEADING "LastTime"                    FORMAT a20

SELECT 'Online' type
    , thread#
    , group#
    , status
    , archived
    , members
    , sequence#
    , (bytes/power(1024,2)) Size_MB
    , NULL used_MB
    , TO_CHAR(first_time,'DD-MON-YY HH24:MI:SS') first_time
    , TO_CHAR(next_time,'DD-MON-YY HH24:MI:SS') next_time  
    , NULL last_time  
  FROM v$log
UNION ALL  
SELECT 'Standby' type
    , thread#
    , group#
    , status
    , archived
    , (select count(1) from v$logfile f where f.group# = l.group#)  members
    , sequence#
    , (bytes/power(1024,2)) Size_MB
    , (used/power(1024,2)) used_MB
    , TO_CHAR(first_time,'DD-MON-YY HH24:MI:SS') first_time
    , TO_CHAR(next_time,'DD-MON-YY HH24:MI:SS') next_time  
    , TO_CHAR(last_time,'DD-MON-YY HH24:MI:SS') last_time  
  FROM v$standby_log l
ORDER BY type, thread# , group#
;

set linesize 400
set pagesize 1000

PROMPT ==============================================================================================
PROMPT == IO STATE LWGR FUNCTION  ==
PROMPT ==============================================================================================
clear columns
SELECT (small_write_megabytes + large_write_megabytes) total_mb,(small_write_reqs + large_write_reqs) total_requests, ROUND((small_write_megabytes + large_write_megabytes)* 1024 / (small_write_reqs + large_write_reqs),2) avg_write_kb FROM v$iostat_function WHERE function_name = 'LGWR';

PROMPT ==============================================================================================
PROMPT == REDO HIT RATIO ==
PROMPT ==============================================================================================
col runtime for a20

select TO_CHAR (sysdate, 'MM/DD/YY HH:MI:SS') runtime, a.value "Redo Entries", b.value "Redo Log Request", ROUND (c.value / 100) "Redo Log Wait in Secs", ROUND ((5000 * b.value) / a.value) "Redo Log Hit Ratio" from v$sysstat a, v$sysstat b, v$sysstat c where a.name = 'redo entries' and b.name = 'redo log space requests' and c.name = 'redo log space wait time';

COMPUTE SUM OF gets             ON report
COMPUTE SUM OF misses           ON report
COMPUTE SUM OF sleeps           ON report
COMPUTE SUM OF immediate_gets   ON report
COMPUTE SUM OF immediate_misses ON report


clear columns
PROMPT ==============================================================================================
PROMPT == REDO CONTENTION  ==
PROMPT ==============================================================================================

col name for a20
SELECT 
    INITCAP(name) name
  , gets
  , misses
  , sleeps
  , immediate_gets
  , immediate_misses
FROM  sys.v_$latch
WHERE name LIKE 'redo%'
ORDER BY 1;

spool off

spool DBHeathcheck_DBStorage_DBSize_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == DATABASE TOTAL SIZE ==
PROMPT ==============================================================================================
select round(sum(bytes)/1024/1024/1024,1) "DatabaseTotalSize(Gb)"  from sys.v_$datafile;


col 	initalloc 	format 99999990.90 head 'Start |Alloc (GB)'
col 	initused 	format 99999990.90 head 'Start |Used (GB)'
col 	curralloc 	format 99999990.90 head 'Curr |Alloc (GB)'
col 	currused 	format 99999990.90 head 'Curr |Used (GB)'
col 	pctused 	format 999.99 head '% Used'
col 	alloc_gbpd	format 99999.99 head 'Alloc Growth|GB/day'
col 	used_gbpd	format 99999.99 head 'Used Growth|GB/day'

prompt
PROMPT ==============================================================================================
PROMPT == DATABASE GROWTH SUMMARY ==
PROMPT ==============================================================================================
prompt
SELECT 
       ROUND (sum(curr_alloc_gb), 2) curralloc,
       ROUND (sum(curr_used_gb), 2) currused,
       ROUND (100 * (sum(curr_used_gb) / sum(curr_alloc_gb)), 2) PCTUSED,
       ROUND (sum(alloc_gbperday), 2) alloc_gbpd,
       ROUND (sum(used_gbperday), 2) used_gbpd
  FROM (SELECT tsmin.tsname tbs, tsmin.tablespace_size init_alloc_gb,
               tsmin.tablespace_usedsize init_used_gb,
               tsmax.tablespace_size curr_alloc_gb,
               tsmax.tablespace_usedsize curr_used_gb,
                 (tsmax.tablespace_size - tsmin.tablespace_size) / (tsmax.snaptime - tsmin.snaptime) alloc_gbperday,
                 (tsmax.tablespace_usedsize - tsmin.tablespace_usedsize)
               / (tsmax.snaptime - tsmin.snaptime) used_gbperday          
        FROM   (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname, (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024 / 1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id ASC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i,v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
                           AND s.dbid=d.dbid and s.dbid=t.dbid and s.dbid=u.dbid
			   AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND ts.ts# = t.ts#
                           AND t.snap_id = u.snap_id
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmin,
               (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname,
                                 (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024/  1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id DESC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i, v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
			   AND s.dbid=d.dbid and s.dbid=t.dbid and s.dbid=u.dbid
                           AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND t.snap_id = u.snap_id
                           AND ts.ts# = t.ts#
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmax
  WHERE tsmin.tsname = tsmax.tsname and tsmax.snaptime > tsmin.snaptime)
/

prompt
PROMPT ==============================================================================================
PROMPT == TABLESPACE GROWTH REPORT ==
PROMPT ==============================================================================================
prompt

col 	initalloc 	format 99999990.90 head 'Start |Alloc (GB)'
col 	initused 	format 99999990.90 head 'Start |Used (GB)'
col 	curralloc 	format 99999990.90 head 'Curr |Alloc (GB)'
col 	currused 	format 99999990.90 head 'Curr |Used (GB)'
col 	pctused 	format 999.99 head '% Used'
col 	alloc_gbpd	format 99999.99 head 'Alloc Growth|GB/day'
col tbs format a20 head 'Tablespace'
col 	used_gbpd	format 99999.99 head 'Used Growth|GB/day'
set lines 180
set pages 80
set trimspool on
break on report
compute sum of initalloc initused curralloc currused alloc_gbpd used_gbpd on report
SELECT tbs tbs, ROUND (init_alloc_gb, 2) initalloc,
       ROUND (init_used_gb, 2) initused, ROUND (curr_alloc_gb, 2) curralloc,
       ROUND (curr_used_gb, 2) currused,
       ROUND (100 * (curr_used_gb / curr_alloc_gb), 2) PCTUSED,
       ROUND (alloc_gbperday, 2) alloc_gbpd,
       ROUND (used_gbperday, 2) used_gbpd
  FROM (SELECT tsmin.tsname tbs, tsmin.tablespace_size init_alloc_gb,
               tsmin.tablespace_usedsize init_used_gb,
               tsmax.tablespace_size curr_alloc_gb,
               tsmax.tablespace_usedsize curr_used_gb,
                 (tsmax.tablespace_size - tsmin.tablespace_size) / (tsmax.snaptime - tsmin.snaptime) alloc_gbperday,
                 (tsmax.tablespace_usedsize - tsmin.tablespace_usedsize)
               / (tsmax.snaptime - tsmin.snaptime) used_gbperday          
        FROM   (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname, (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024 / 1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id ASC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i, v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
			   AND s.dbid=d.dbid
			   AND s.dbid=t.dbid
			   AND s.dbid=u.dbid
                           AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND ts.ts# = t.ts#
                           AND t.snap_id = u.snap_id
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmin,
               (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname,
                                 (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024 / 1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id DESC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i,v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
			   AND s.dbid=d.dbid
			   AND s.dbid=t.dbid
			   AND s.dbid=u.dbid
                           AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND t.snap_id = u.snap_id
                           AND ts.ts# = t.ts#
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmax
  WHERE tsmin.tsname = tsmax.tsname and tsmax.snaptime > tsmin.snaptime)
/

spool off

spool DBHeathcheck_DBStorage_Tablesppace_&&dbname&&timestamp&&suffix 
set linesize 400
set pagesize 1000

PROMPT ==============================================================================================
PROMPT == DEFAULT TABLESPACE ==
PROMPT ==============================================================================================
SELECT * FROM database_properties WHERE property_name in ('DEFAULT_TEMP_TABLESPACE','DEFAULT_PERMANENT_TABLESPACE');

PROMPT ==============================================================================================
PROMPT == TABLESPACE INFORMATION ==
PROMPT ==============================================================================================
select tablespace_name,block_size,status,segment_space_management ASSM,logging,force_logging,min_extlen EXTSZ from dba_tablespaces order by 1;

PROMPT ==============================================================================================
PROMPT == TABLESPACE DEFINITION ==
PROMPT ==============================================================================================
SELECT tablespace_name tablespace ,initial_extent ,next_extent ,max_extents ,pct_increase ,status ,contents ,logging ,extent_management,allocation_type  ,segment_space_management ,plugged_in ,def_tab_compression FROM dba_tablespaces  ORDER BY tablespace_name;

PROMPT ==============================================================================================
PROMPT == TABLESPACE WITH DATAFILE USAGE  ==
PROMPT ==============================================================================================

COMPUTE SUM OF a_byt t_byt f_byt ON REPORT
BREAK ON REPORT ON tablespace_name ON pf
COL tablespace_name FOR A17   TRU HEAD 'Tablespace|Name'
COL file_name       FOR A40   TRU HEAD 'Filename'
COL a_byt           FOR 9,990.999 HEAD 'Allocated|GB'
COL t_byt           FOR 9,990.999 HEAD 'Current|Used GB'
COL f_byt           FOR 9,990.999 HEAD 'Current|Free GB'
COL pct_free        FOR 990.0     HEAD 'File %|Free'
COL pf              FOR 990.0     HEAD 'Tbsp %|Free'
COL seq NOPRINT
DEFINE b_div=1073741824
set verify off
--
SELECT 1 seq, b.tablespace_name, nvl(x.fs,0)/y.ap*100 pf, b.file_name file_name,
  b.bytes/&&b_div a_byt, NVL((b.bytes-SUM(f.bytes))/&&b_div,b.bytes/&&b_div) t_byt,
  NVL(SUM(f.bytes)/&&b_div,0) f_byt, NVL(SUM(f.bytes)/b.bytes*100,0) pct_free
FROM dba_free_space f, dba_data_files b
 ,(SELECT y.tablespace_name, SUM(y.bytes) fs
   FROM dba_free_space y GROUP BY y.tablespace_name) x
 ,(SELECT x.tablespace_name, SUM(x.bytes) ap
   FROM dba_data_files x GROUP BY x.tablespace_name) y
WHERE f.file_id(+) = b.file_id
AND   x.tablespace_name(+) = y.tablespace_name
and   y.tablespace_name =  b.tablespace_name
AND   f.tablespace_name(+) = b.tablespace_name
GROUP BY b.tablespace_name, nvl(x.fs,0)/y.ap*100, b.file_name, b.bytes
UNION
SELECT 2 seq, tablespace_name,
  j.bf/k.bb*100 pf, b.name file_name, b.bytes/&&b_div a_byt,
  a.bytes_used/&&b_div t_byt, a.bytes_free/&&b_div f_byt,
  a.bytes_free/b.bytes*100 pct_free
FROM v$temp_space_header a, v$tempfile b
  ,(SELECT SUM(bytes_free) bf FROM v$temp_space_header) j
  ,(SELECT SUM(bytes) bb FROM v$tempfile) k
WHERE a.file_id = b.file#
ORDER BY 1,2,4,3;


PROMPT ==============================================================================================
PROMPT == TABLESPACE USAGE  ==
PROMPT ==============================================================================================

col PerUsed for a20
col Used for a25
select t.tablespace_name, t.mb "TotalMB", t.mb - nvl(f.mb,0) "UsedMB", nvl(f.mb,0) "FreeMB"
       ,lpad(ceil((1-nvl(f.mb,0)/decode(t.mb,0,1,t.mb))*100)||'%', 6) PerUsed, t.ext "Ext", 
       '|'||rpad(lpad('#',ceil((1-nvl(f.mb,0)/decode(t.mb,0,1,t.mb))*20),'#'),20,' ')||'|' Used
from (
  select tablespace_name, trunc(sum(bytes)/1048576) MB
  from dba_free_space
  group by tablespace_name
 union all
  select tablespace_name, trunc(sum(bytes_free)/1048576) MB
  from v$temp_space_header
  group by tablespace_name
) f, (
  select tablespace_name, trunc(sum(bytes)/1048576) MB, max(autoextensible) ext
  from dba_data_files
  group by tablespace_name
 union all
  select tablespace_name, trunc(sum(bytes)/1048576) MB, max(autoextensible) ext
  from dba_temp_files
  group by tablespace_name
) t
where t.tablespace_name = f.tablespace_name (+)
order by t.tablespace_name;

PROMPT ==============================================================================================
PROMPT == AUTO EXTEND TABLESPACE  ==
PROMPT ==============================================================================================

select
a.tablespace_name tablespace,
SUM(a.bytes)/1024/1024 "CurMb",
SUM(decode(b.maxextend, null, A.BYTES/1024/1024, b.maxextend*8192/1024/1024)) "MaxMb",
(SUM(a.bytes)/1024/1024 - round(c."Free"/1024/1024)) "TotalUsed",
(SUM(decode(b.maxextend, null, A.BYTES/1024/1024, b.maxextend*8192/1024/1024)) - (SUM(a.bytes)/1024/1024 - round(c."Free"/1024/1024))) "TotalFree",
round(100*(SUM(a.bytes)/1024/1024 - round(c."Free"/1024/1024))/(SUM(decode(b.maxextend, null, A.BYTES/1024/1024, b.maxextend*8192/1024/1024)))) "UPercent"
from
dba_data_files a,
sys.filext$ b,
(SELECT d.tablespace_name , sum(nvl(c.bytes,0)) "Free" FROM dba_tablespaces d,DBA_FREE_SPACE c where d.tablespace_name = c.tablespace_name(+) group by d.tablespace_name) c
where a.file_id = b.file#(+)
and a.tablespace_name = c.tablespace_name
GROUP by a.tablespace_name, c."Free"/1024
order by round(100*(SUM(a.bytes)/1024/1024 - round(c."Free"/1024/1024))/(SUM(decode(b.maxextend, null, A.BYTES/1024/1024, b.maxextend*8192/1024/1024)))) desc;



PROMPT ==============================================================================================
PROMPT == TABLESPACE TEMP INFORMATION  ==
PROMPT ==============================================================================================

SELECT t.name filename ,t.bytes /1024 /1024 "Size of Temp File (mb)" ,NVL(su.bytes /1024 /1024, 0) "Used Space (mb)" ,(t.bytes - NVL(su.bytes, 0)) /1024 /1024 "Free Space (mb)"  FROM (SELECT s.inst_id,(SUM(blocks) * p.value) bytes,segrfno#,ts.ts# FROM gv$sort_usage s,gv$parameter p,v$tablespace ts        WHERE p.name = 'db_block_size' AND s.tablespace = ts.name AND s.inst_id = p.inst_id GROUP BY s.inst_id,segrfno#,ts.ts#,p.value ) su ,(SELECT ts#,rfile#,name,bytes FROM v$tempfile ) t  WHERE t.rfile# = su.segrfno# (+) AND t.ts# = su.ts# (+)  ORDER BY t.name;

spool off

spool DBHeathcheck_DBStorage_Undo_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == UNDO SEGMENT INFORMATION ==
PROMPT ==============================================================================================
prompt
COLUMN instance_name  FORMAT a9               HEADING 'Instance'
COLUMN undo_name      FORMAT a30              HEADING 'Undo Name'
COLUMN tablespace     FORMAT a11              HEADING 'Tablspace'
COLUMN in_extents     FORMAT a23              HEADING 'Init / Next Extents'
COLUMN m_extents      FORMAT a23              HEADING 'Min / Max Extents'
COLUMN status         FORMAT a8               HEADING 'Status'
COLUMN wraps          FORMAT 99,999           HEADING 'Wraps' 
COLUMN shrinks        FORMAT 99,999           HEADING 'Shrinks'
COLUMN opt            FORMAT 999,999,999,999  HEADING 'Opt. Size'
COLUMN bytes          FORMAT 999,999,999,999  HEADING 'Bytes'
COLUMN extents        FORMAT 999              HEADING 'Extents'
set linesize 400
set pagesize 10000
set verify off
BREAK ON instance_name SKIP 2

COMPUTE SUM LABEL 'Total: ' OF bytes ON instance_name

SELECT
    i.instance_name                           instance_name
  , a.owner || '.' || a.segment_name          undo_name
  , a.tablespace_name                         tablespace
  , TRIM(TO_CHAR(a.initial_extent, '999,999,999,999')) || ' / ' ||
    TRIM(TO_CHAR(a.next_extent, '999,999,999,999'))                    in_extents
  , TRIM(TO_CHAR(a.min_extents, '999,999,999,999'))    || ' / ' ||
    TRIM(TO_CHAR(a.max_extents, '999,999,999,999'))                    m_extents
  , a.status                                  status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
                gv$instance       i
    INNER JOIN  gv$rollstat       d   ON (i.inst_id      = d.inst_id)
    INNER JOIN  sys.undo$         c   ON (d.usn          = c.us#)
    INNER JOIN  dba_rollback_segs a   ON (a.segment_name = c.name)
    INNER JOIN  dba_segments      b   ON (a.segment_name = b.segment_name)
ORDER BY
    i.instance_name
  , a.segment_name;
  
PROMPT ==============================================================================================
PROMPT == UNDO STATISTIC ==
PROMPT ==============================================================================================
prompt


set linesize 400
set pagesize 1000
select
inst_id,to_char(begin_time,'MM-DD-YYYY HH24:MI') begin_time
,ssolderrcnt ORA_01555_cnt
,nospaceerrcnt no_space_cnt
,txncount max_num_txns
,maxquerylen max_query_len
,expiredblks blck_in_expired
from gv$undostat
where begin_time > sysdate - 30
order by inst_id,begin_time;


DEFINE BYTES_DIVIDER="1024/1024"
select a.INST_ID,
      to_char(a.BEGIN_TIME, 'DD-MON HH:MI:SS') "Hour"
     , t.tablespace_name
     , ROUND(SUM(A.ACTIVEBLKS    * t.block_size ) / &BYTES_DIVIDER ) "ActiveSize"
     , ROUND(SUM(A.UNDOBLKS      * t.block_size ) / &BYTES_DIVIDER ) "UndoSize"
     , ROUND(SUM(A.EXPIREDBLKS   * t.block_size ) / &BYTES_DIVIDER ) "EXPIREDSize"
     , ROUND(SUM(A.UNEXPIREDBLKS * t.block_size ) / &BYTES_DIVIDER ) "UNEXPIREDSize"
     , ROUND(SUM(A.EXPBLKRELCNT  * t.block_size ) / &BYTES_DIVIDER ) "EXPIREDRelSize"
     , max(MAXCONCURRENCY)                                           MAXCONCURRENCY 
     , sum(TXNCOUNT)                                                 TXNCOUNT 
     , max(MAXQUERYLEN)                                              MAXQUERYLEN 
     , DECODE(sum(NOSPACEERRCNT),0,'')                               NOSPACEERRCNT 
     , DECODE(sum(SSOLDERRCNT),0,'')                                 SSOLDERRCNT 
from gv$undostat a
   , dba_tablespaces t
   , v$tablespace t2
where a.undotsn = t2.ts#
  AND t2.name = t.tablespace_name
group by a.BEGIN_TIME
       , a.INST_ID
       , t.tablespace_name
order by 1,2
/

SET SERVEROUTPUT ON

DECLARE
    v_analyse_start_time    DATE := SYSDATE - 7;
    v_analyse_end_time      DATE := SYSDATE;
    v_cur_dt                DATE;
    v_undo_info_ret         BOOLEAN;
    v_cur_undo_mb           NUMBER;
    v_undo_tbs_name         VARCHAR2(100);
    v_undo_tbs_size         NUMBER;
    v_undo_autoext          BOOLEAN;
    v_undo_retention        NUMBER(5);
    v_undo_guarantee        BOOLEAN;
    v_instance_number       NUMBER;
    v_undo_advisor_advice   VARCHAR2(100);
    v_undo_health_ret       NUMBER;
    v_problem               VARCHAR2(1000);
    v_recommendation        VARCHAR2(1000);
    v_rationale             VARCHAR2(1000);
    v_retention             NUMBER;
    v_utbsize               NUMBER;
    v_best_retention        NUMBER;
    v_longest_query         NUMBER;
    v_required_retention    NUMBER;
BEGIN
    select sysdate into v_cur_dt from dual;
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('- Undo Analysis started at : ' || v_cur_dt || ' -');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

    v_undo_info_ret := DBMS_UNDO_ADV.UNDO_INFO(v_undo_tbs_name, v_undo_tbs_size, v_undo_autoext, v_undo_retention, v_undo_guarantee);
    select sum(bytes)/1024/1024 into v_cur_undo_mb from dba_data_files where tablespace_name = v_undo_tbs_name;

    DBMS_OUTPUT.PUT_LINE('NOTE:The following analysis is based upon the database workload during the period -');
    DBMS_OUTPUT.PUT_LINE('Begin Time : ' || v_analyse_start_time);
    DBMS_OUTPUT.PUT_LINE('End Time   : ' || v_analyse_end_time);
    
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Current Undo Configuration');
    DBMS_OUTPUT.PUT_LINE('--------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('Current undo tablespace',55) || ' : ' || v_undo_tbs_name);
    DBMS_OUTPUT.PUT_LINE(RPAD('Current undo tablespace size (datafile size now) ',55) || ' : ' || v_cur_undo_mb || 'M');
    DBMS_OUTPUT.PUT_LINE(RPAD('Current undo tablespace size (consider autoextend) ',55) || ' : ' || v_undo_tbs_size || 'M');
    IF V_UNDO_AUTOEXT THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('AUTOEXTEND for undo tablespace is',55) || ' : ON');  
    ELSE
        DBMS_OUTPUT.PUT_LINE(RPAD('AUTOEXTEND for undo tablespace is',55) || ' : OFF');  
    END IF;
    DBMS_OUTPUT.PUT_LINE(RPAD('Current undo retention',55) || ' : ' || v_undo_retention);

    IF v_undo_guarantee THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('UNDO GUARANTEE is set to',55) || ' : TRUE');
    ELSE
        dbms_output.put_line(RPAD('UNDO GUARANTEE is set to',55) || ' : FALSE');
    END IF;
    DBMS_OUTPUT.PUT_LINE(CHR(9));

    SELECT instance_number INTO v_instance_number FROM V$INSTANCE;

    DBMS_OUTPUT.PUT_LINE('Undo Advisor Summary');
    DBMS_OUTPUT.PUT_LINE('---------------------------');

    v_undo_advisor_advice := dbms_undo_adv.undo_advisor(v_analyse_start_time, v_analyse_end_time, v_instance_number);
    DBMS_OUTPUT.PUT_LINE(v_undo_advisor_advice);

    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Undo Space Recommendation');
    DBMS_OUTPUT.PUT_LINE('-------------------------');

    v_undo_health_ret := dbms_undo_adv.undo_health(v_analyse_start_time, v_analyse_end_time, v_problem, v_recommendation, v_rationale, v_retention, v_utbsize);
    IF v_undo_health_ret > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Minimum Recommendation           : ' || v_recommendation);
        DBMS_OUTPUT.PUT_LINE('Rationale                        : ' || v_rationale);
        DBMS_OUTPUT.PUT_LINE('Recommended Undo Tablespace Size : ' || v_utbsize || 'M');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Allocated undo space is sufficient for the current workload.');
    END IF;
    
    SELECT dbms_undo_adv.best_possible_retention(v_analyse_start_time, v_analyse_end_time) into v_best_retention FROM dual;
    SELECT dbms_undo_adv.longest_query(v_analyse_start_time, v_analyse_end_time) into v_longest_query FROM dual;
    SELECT dbms_undo_adv.required_retention(v_analyse_start_time, v_analyse_end_time) into v_required_retention FROM dual;

    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Retention Recommendation');
    DBMS_OUTPUT.PUT_LINE('------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('The best possible retention with current configuration is ',60) || ' : ' || v_best_retention || ' Seconds');
    DBMS_OUTPUT.PUT_LINE(RPAD('The longest running query ran for ',60) || ' : ' || v_longest_query || ' Seconds');
    DBMS_OUTPUT.PUT_LINE(RPAD('The undo retention required to avoid errors is ',60) || ' : ' || v_required_retention || ' Seconds');

END;
/
spool off


spool DBHeathcheck_DBStorage_SegmentAdvRpt_&&dbname&&timestamp&&suffix 
set linesize 400
set pagesize 10000
col segment_name for a20
compute sum of reclaim_mb on report
compute sum of alloc_mb on report
compute sum of used_mb on report
break on report
col recommendations for a60
SELECT segment_name,
round(allocated_space/1024/1024,1) alloc_mb,
round( used_space/1024/1024, 1 ) used_mb,
round( reclaimable_space/1024/1024) reclaim_mb,
round(reclaimable_space/allocated_space*100,0) pctsave,
recommendations
FROM TABLE(dbms_space.asa_recommendations())
where recommendations like '%shrink%' order by reclaim_mb;

spool off

spool DBHeathcheck_DBGrowth_Years_&&dbname&&timestamp&&suffix 

col 	curralloc 	format 99999990.90 head 'Curr |Alloc (GB)'
col 	grate 		format 99999.99 head 'Growth Rate|GB/day'
col 	year1		format 99999990.90 head '1-year|Size (GB)'
col 	year2		format 99999990.90 head '2-year|Size (GB)'
col 	year3		format 99999990.90 head '3-year|Size (GB)'
col 	year5		format 99999990.90 head '5-year|Size (GB)'

set lines 180
set pages 80
set trimspool on
SELECT 
       ROUND (sum(curr_alloc_gb), 2) curralloc,
       greatest(sum(alloc_gbperday),sum(used_gbperday)) grate,
       (sum(curr_alloc_gb) + 
		365*(greatest(sum(alloc_gbperday),sum(used_gbperday))))
			-(sum(curr_alloc_gb)-sum(curr_used_gb)) year1,
       (sum(curr_alloc_gb) + 
		2*365*(greatest(sum(alloc_gbperday),sum(used_gbperday))))
			-(sum(curr_alloc_gb)-sum(curr_used_gb)) year2,
       (sum(curr_alloc_gb) + 
		3*365*(greatest(sum(alloc_gbperday),sum(used_gbperday))))
			-(sum(curr_alloc_gb)-sum(curr_used_gb)) year3,
       (sum(curr_alloc_gb) + 
		5*365*(greatest(sum(alloc_gbperday),sum(used_gbperday))))
			-(sum(curr_alloc_gb)-sum(curr_used_gb)) year5
  FROM (SELECT tsmin.tsname tbs, tsmin.tablespace_size init_alloc_gb,
               tsmin.tablespace_usedsize init_used_gb,
               tsmax.tablespace_size curr_alloc_gb,
               tsmax.tablespace_usedsize curr_used_gb,
                 (tsmax.tablespace_size - tsmin.tablespace_size) / (tsmax.snaptime - tsmin.snaptime) alloc_gbperday,
                 (tsmax.tablespace_usedsize - tsmin.tablespace_usedsize)
               / (tsmax.snaptime - tsmin.snaptime) used_gbperday          
        FROM   (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname, (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024 / 1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id ASC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i, v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
                           AND s.dbid=d.dbid and s.dbid=t.dbid and s.dbid=u.dbid
			   AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND ts.ts# = t.ts#
                           AND t.snap_id = u.snap_id
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmin,
               (SELECT *
                  FROM (SELECT TRUNC (s.begin_interval_time) snaptime,
                               t.tsname,
                                 (ts.BLOCKSIZE * u.tablespace_size) / 1024 / 1024/  1024 tablespace_size,
                                 (ts.BLOCKSIZE * u.tablespace_usedsize) / 1024 / 1024 / 1024 tablespace_usedsize,
                               (RANK () OVER (PARTITION BY t.tsname ORDER BY s.snap_id DESC)
                               ) latest,
                               s.end_interval_time endtime
                          FROM dba_hist_snapshot s,
                               v$instance i, v$database d,
                               dba_hist_tablespace_stat t,
                               dba_hist_tbspc_space_usage u,
                               SYS.ts$ ts
                         WHERE s.snap_id = t.snap_id
    			   AND s.dbid=d.dbid and s.dbid=t.dbid and s.dbid=u.dbid
                           AND i.instance_number = s.instance_number
                           AND s.instance_number = t.instance_number
                           AND t.snap_id = u.snap_id
                           AND ts.ts# = t.ts#
                           AND t.ts# = u.tablespace_id)
                 WHERE latest = 1) tsmax
  WHERE tsmin.tsname = tsmax.tsname and tsmax.snaptime > tsmin.snaptime)
/
spool off



spool DBHeathcheck_DBMem_SGA_&&dbname&&timestamp&&suffix 
set linesize 400
set pagesize 10000
col inst_id for 9999 heading 'INST'
col name for a35
PROMPT ==============================================================================================
PROMPT == SGA INFORMATION==
PROMPT ==============================================================================================
select inst_id,name,round(bytes/(1024*1024),2) Mb, resizeable from gv$sgainfo order by 1,2;

PROMPT ==============================================================================================
PROMPT == SGA COMPONENT SIZE==
PROMPT ==============================================================================================
SELECT inst_id,1 dummy, 'Buffer Cache' area, name, round(sum(bytes)/1024/1024,2) Mb
FROM gv$sgastat WHERE pool is null and name = 'buffer_cache'
group by inst_id,name
union all
SELECT inst_id,2, 'Shared Pool', pool, round(sum(bytes)/1024/1024,2) Mb
FROM gv$sgastat WHERE pool = 'shared pool'
group by inst_id,pool
union all
SELECT inst_id,3, 'Large Pool', pool, round(sum(bytes)/1024/1024,2) Mb
FROM gv$sgastat WHERE pool = 'large pool'
group by inst_id,pool
union all
SELECT inst_id,4, 'Java Pool', pool, round(sum(bytes)/1024/1024,2) Mb
FROM gv$sgastat WHERE pool = 'java pool'
group by inst_id,pool
union all
SELECT inst_id,5, 'Redo Log Buffer', name, round(sum(bytes)/1024/1024,3) Mb
FROM gv$sgastat WHERE pool is null and name = 'log_buffer' group by inst_id,name
union all
SELECT inst_id,6, 'Fixed SGA', name, round(sum(bytes)/1024/1024,2) Mb
FROM gv$sgastat WHERE pool is null and name = 'fixed_sga'
group by inst_id,name ORDER BY 1,2;

PROMPT ==============================================================================================
PROMPT == SGA FREE MEMORY REPORT==
PROMPT ==============================================================================================
select inst_id,round(current_size/(1024*1024),2) "Free Mb for dynamic SGA" from GV$SGA_DYNAMIC_FREE_MEMORY;
SELECT f.pool, f.name, round(s.sgasize/1024/1024,1) SGASIZE, round(f.bytes/1024/1024,1) FREE, ROUND(f.bytes/s.sgasize*100, 2) "% Free" FROM (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s   , v$sgastat f WHERE f.name = 'free memory' AND f.pool = s.pool;


PROMPT ==============================================================================================
PROMPT == BUFFER POOL STATISTIC  ==
PROMPT ==============================================================================================
column name format a7
column block_size_kb format 99 heading "Block|Size K"
column free_buffer_wait format 99,999,999 heading "Free Buff|Wait"
column buffer_busy_wait format 99,999,999 heading "Buff Busy|Wait"
column db_change format 999,999,999 heading "DB Block|Chg /1000"
column db_gets format 99,999,999 heading "DB Block|Gets /1000"
column con_gets format 99,999,999,9999 heading "Consistent|gets /1000"
column phys_rds format 99,999,999 heading "Physical|Reads /1000"
column current_size format 99,999,999 heading "Current|MB"
column prev_size format 99,999,999 heading "Prev|MB"
col inst for 999
SELECT b.inst_id inst,b.name, b.block_size / 1024 block_size_kb, 
       current_size, prev_size,
       ROUND(db_block_gets / 1000) db_gets,
       ROUND(consistent_gets / 1000) con_gets,
       ROUND(physical_reads / 1000) phys_rds
  FROM gv$buffer_pool_statistics s
  JOIN gv$buffer_pool b
   ON (b.name = s.name AND b.block_size = s.block_size and b.inst_id=s.inst_id);

   
PROMPT ==============================================================================================
PROMPT == LARGE POOL DIAGNOSTIC ==
PROMPT ==============================================================================================

/* Current instance parameter values */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current instance parameter values:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT n.ksppinm name, v.KSPPSTVL value
FROM x$ksppi n, x$ksppsv v
WHERE n.indx = v.indx and (n.ksppinm like '%large_pool%' or n.ksppinm like 'parallel%' or n.ksppinm = '_kghdsidx_count')
ORDER BY 1;

/* Current memory settings */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current memory settings:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT component, current_size FROM v$sga_dynamic_components;

/* Memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM v$sga_resize_ops
ORDER BY 1, 2;

/* Historical memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Historical memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM dba_hist_memory_resize_ops
ORDER BY 1, 2;

/* Large Pool memory usage */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Large Pool memory usage:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT SUM(bytes) "Total Large Pool Usage" FROM v$sgastat WHERE pool = 'large pool' AND name != 'free memory';
SELECT name, bytes FROM v$sgastat WHERE pool = 'large pool' ORDER BY bytes DESC;

/* Total UGA from session statistics */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Total UGA from session statistics:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT SUM(value) "Total UGA" FROM v$sesstat s, v$statname n WHERE n.statistic# = s.statistic# AND name = 'session uga memory';

SET SERVEROUTPUT ON FORMAT WRAP

DECLARE
    TYPE ptype IS RECORD(nam VARCHAR2(512), val VARCHAR2(512));
    TYPE paramstype IS TABLE OF ptype;
    commonparams       paramstype;
    banner             VARCHAR2(80);
    db_name            VARCHAR2(9);
    cpus               NUMBER;
    cpusers            NUMBER;
    def_servers_max    NUMBER;
    def_servers_target NUMBER;
    granule_size       NUMBER;
    large_pool         NUMBER;
    large_pool_abs     NUMBER;
    large_pool_asmm    NUMBER;
    large_pool_smax    NUMBER;
    large_pool_smin    NUMBER;
    large_pool_strgt   NUMBER;
    lp_servers         NUMBER;
    mem_tgt            NUMBER;
    min_msg_pool       NUMBER;
    msg_size           NUMBER;
    parbuf_hwm         NUMBER;
    parbuf_hwm_mem     NUMBER;
    parsvr_hwm         NUMBER;
    pga_agg            NUMBER;
    ptpcpu             NUMBER;
    servers_max        NUMBER;
    servers_min        NUMBER;
    servers_target     NUMBER;
    sga_tgt            NUMBER;
    subpools           NUMBER;
    use_lp             VARCHAR2(5);
    mfactor            NUMBER;
    nam                VARCHAR2(512);
    val                VARCHAR2(512);
    vsnmajor           NUMBER;
    vsnminor           NUMBER;
    params_sql         VARCHAR2(32767);

    FUNCTION getnumber(str IN VARCHAR2, cnt IN NUMBER) RETURN NUMBER
    IS
        dp NUMBER;
        s VARCHAR2(512);
    BEGIN
       s := str;
        FOR i IN 1..cnt-1
        LOOP
            s := SUBSTR(s, INSTR(s, '.', 1, 1)+1);
        END LOOP;
       RETURN SUBSTR(s, 1, INSTR(s, '.', 1, 1)-1);
    END;
   FUNCTION find_param_value(nam IN VARCHAR2) RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1..commonparams.COUNT() LOOP
          IF commonparams(i).nam = nam
          THEN
              RETURN commonparams(i).val;
          END IF;
      END LOOP;
       RETURN '';
   END;
   FUNCTION find_param_value_num(nam IN VARCHAR2) RETURN NUMBER
   IS
   BEGIN
      FOR i IN 1..commonparams.COUNT() LOOP
          IF commonparams(i).nam = nam
          THEN
              RETURN TO_NUMBER(commonparams(i).val);
          END IF;
      END LOOP;
       RETURN 0;
   END;
   FUNCTION execcur(stmt IN VARCHAR2) RETURN VARCHAR2
   IS
        TYPE curtype IS REF CURSOR;
        stmtcur curtype;
   BEGIN
       OPEN stmtcur FOR stmt;
       FETCH stmtcur INTO val;
       CLOSE stmtcur;
       RETURN val;
   END;
BEGIN
    /* Get db ID */
    SELECT DISTINCT name INTO db_name FROM v$database;
    SELECT DISTINCT banner INTO banner FROM v$version WHERE banner LIKE 'Oracle Database%';
    vsnmajor := getnumber(SUBSTR(banner, INSTR(banner, 'Release') + 8), 1);
    vsnminor := getnumber(SUBSTR(banner, INSTR(banner, 'Release') + 8), 2);

    params_sql := 'SELECT n.ksppinm name, v.ksppstvl value ' ||
        'FROM x$ksppi n, x$ksppsv v ' ||
        'WHERE n.indx = v.indx ' ||
        'AND n.ksppinm IN (''_PX_use_large_pool'', ''_kghdsidx_count'', ''_ksmg_granule_size'', ''_parallel_min_message_pool'', ' ||
            '''cpu_count'',''large_pool_size'', ''parallel_execution_message_size'', ''parallel_max_servers'', ' ||
            '''parallel_min_servers'', ''parallel_threads_per_cpu'', ''pga_aggregate_target'', ''sga_target'', ' ||
            '''memory_target'', ''parallel_servers_target'') ORDER BY 1';
    EXECUTE IMMEDIATE params_sql BULK COLLECT INTO commonparams;
    use_lp := find_param_value('_PX_use_large_pool');
    subpools := find_param_value_num('_kghdsidx_count');
    granule_size := find_param_value_num('_ksmg_granule_size');
    min_msg_pool := find_param_value_num('_parallel_min_message_pool');
    cpus := find_param_value_num('cpu_count');
    large_pool := find_param_value_num('large_pool_size');
    mem_tgt := find_param_value_num('memory_target');
    msg_size := find_param_value_num('parallel_execution_message_size');
    servers_max := find_param_value_num('parallel_max_servers');
    servers_min := find_param_value_num('parallel_min_servers');
    servers_target := find_param_value_num('parallel_servers_target');
    ptpcpu := find_param_value_num('parallel_threads_per_cpu');

    IF (vsnmajor <= 10)
    THEN
        pga_agg := find_param_value('pga_aggregate_target');
        sga_tgt := find_param_value('sga_target');
        large_pool_asmm := execcur('select current_size from v$sga_dynamic_components where component = ''large pool''');
    ELSE
        pga_agg := execcur('SELECT current_size FROM v$sga_dynamic_components WHERE component = ''PGA Target''');
        sga_tgt := execcur('SELECT current_size FROM v$sga_dynamic_components WHERE component = ''SGA Target''');
        large_pool_asmm := execcur('SELECT current_size FROM v$sga_dynamic_components WHERE component = ''large pool''');
    END IF;
    parsvr_hwm := execcur('SELECT value FROM v$pq_sysstat WHERE statistic LIKE ''Servers Highwater%''');
    parbuf_hwm := execcur('SELECT value FROM v$px_process_sysstat WHERE statistic LIKE ''Buffers HWM%''');

    DBMS_OUTPUT.PUT_LINE('<pre>');

    /* Perform calculations and display results */
    DBMS_OUTPUT.PUT_LINE(vsnmajor || 'R' || vsnminor || ': CALCULATIONS for the LARGE_POOL_SIZE with parallel processing.');
    DBMS_OUTPUT.PUT_LINE('Version 2.0, 2014.');
    DBMS_OUTPUT.PUT_LINE('Database Identification:');
    DBMS_OUTPUT.PUT_LINE('The database name is ' || db_name || '.');
    DBMS_OUTPUT.PUT_LINE('Version: ' || banner);
    DBMS_OUTPUT.PUT_LINE('LARGE_POOL_SIZE:');
    large_pool := large_pool/1024/1024;
    DBMS_OUTPUT.PUT_LINE('The initial setting is ' || large_pool || 'Mb.');
    IF large_pool = 0
    THEN
        DBMS_OUTPUT.PUT('If set, the ');
    ELSE
        DBMS_OUTPUT.PUT('The ');
    END IF;
    large_pool_abs := (granule_size * subpools)/1024/1024;
    dbms_output.put_line('absolute minimum is ' || large_pool_abs || 'Mb (a lower non-0 value is over-ridden).');
    large_pool_asmm := large_pool_asmm/1024/1024;
    IF sga_tgt > 0
    THEN
        DBMS_OUTPUT.PUT_LINE('The current dynamic size is ' || large_pool_asmm || 'Mb.');
    END IF;
    /* Parallel processing */
    DBMS_OUTPUT.PUT_LINE('Parallel Processing:');
    IF servers_min > 0
    THEN
        large_pool_smin := (granule_size * (servers_min + 2))/1024/1024; /* From unpublished Bug 13096841 */
        DBMS_OUTPUT.PUT_LINE('For parallel_min_servers=' || servers_min || ', the minimum Large Pool is ' ||
            large_pool_smin || 'Mb.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The parallel_min_servers setting is 0.');
    END IF;
    IF vsnmajor >= 11
    THEN
        /* Calculate Concurrent Parallel Users */
        cpusers := 1;
        IF pga_agg > 0
        THEN
            cpusers := 2;
            IF sga_tgt > 0
            THEN
                cpusers := 4;
            END IF;
        END IF;
        IF mem_tgt > 0
        THEN
           cpusers := 4;
        END IF;
        IF (vsnmajor > 11 OR vsnminor >= 2)
        THEN
            IF servers_target > 0
            THEN
                large_pool_strgt := (granule_size * servers_target)/1024/1024/2; /* assume 2 servers use 1 granule */
                DBMS_OUTPUT.PUT_LINE('For parallel_servers_target=' || servers_target || ', the Large Pool may grow to ' ||
                    large_pool_strgt || 'Mb.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('The parallel_servers_target setting is 0');
            END IF;
        END IF;
    END IF;
    /* Calculate the default for parallel_max_servers */
    IF (vsnmajor <= 10)
    THEN
        /* 10.2 Data Warehousing formula: (CPU_COUNT x PARALLEL_THREADS_PER_CPU x (2 if PGA_AGGREGATE_TARGET > 0; otherwise 1) x 5) */
        IF pga_agg > 0
        THEN
            mfactor := 10;
        ELSE
            mfactor := 5;
        END IF;
        def_servers_max := cpus * ptpcpu * mfactor;
    ELSE
        /* 11.2 PARALLEL_THREADS_PER_CPU x CPU_COUNT x concurrent_parallel_users x 5 */
        def_servers_max := ptpcpu * cpus * cpusers * 5;
    END IF;
    /* Calculate Large Pool usage (theoretical) */
    IF servers_max > 0
    THEN
        lp_servers := servers_max;
    ELSE
        lp_servers := def_servers_max;
    END IF;
    large_pool_smax := (granule_size * lp_servers)/1024/1024/2; /* assume 2 servers use 1 granule */
    IF servers_max > 0
    THEN
        DBMS_OUTPUT.PUT('For parallel_max_servers=' || servers_max );
    ELSE
        DBMS_OUTPUT.PUT_LINE('No Parallelism because parallel_max_servers=0.');
        IF (vsnmajor <= 10)
        THEN
            DBMS_OUTPUT.PUT('If enabled');
        ELSE
            DBMS_OUTPUT.PUT('If enabled with the parallel_max_servers DEFAULT');
        END IF;
    END IF;
    DBMS_OUTPUT.PUT_LINE(', the Large Pool may grow to ' || large_pool_smax || 'Mb.');
    IF (vsnmajor > 11 OR (vsnmajor = 11 AND vsnminor >= 2))
    THEN
        /* Calculate the default for parallel_servers_target */
        /* 11.2 PARALLEL_THREADS_PER_CPU * CPU_COUNT * concurrent_parallel_users * 2 */
        def_servers_target := ptpcpu * cpus * cpusers * 2;
        DBMS_OUTPUT.PUT_LINE('The DEFAULT for parallel_servers_target is ' || def_servers_target || ' (over-rides 0 setting).');
    END IF;
    DBMS_OUTPUT.PUT_LINE('The DEFAULT for parallel_max_servers is ' || def_servers_max || '.');
    /* Additional PX information */
    DBMS_OUTPUT.PUT_LINE('Additional:');
    DBMS_OUTPUT.PUT('The Parallel Servers High Water Mark is ');
    IF parsvr_hwm > 0
    THEN
        DBMS_OUTPUT.PUT_LINE(parsvr_hwm || '.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('currently 0 (yet to be set).');
    END IF;
    DBMS_OUTPUT.PUT('This instance will put the "PX msg pool" allocation in the ');
    IF sga_tgt = 0 AND use_lp != 'TRUE'
    THEN
        DBMS_OUTPUT.PUT_LINE('Shared Pool.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Large Pool.');
    END IF;
    DBMS_OUTPUT.PUT('The initial size of the "PX msg pool" allocation ');
    IF min_msg_pool > 0
    THEN
        DBMS_OUTPUT.PUT_LINE('is ' || min_msg_pool || ' bytes.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('has been manually set to 0.');
    END IF;
    DBMS_OUTPUT.PUT('The Parallel Buffers High Water Mark is ');
    IF parbuf_hwm > 0
    THEN
        DBMS_OUTPUT.PUT_LINE(parbuf_hwm || ' buffers,');
        parbuf_hwm_mem := parbuf_hwm * msg_size;
        DBMS_OUTPUT.PUT_LINE('that required ' || parbuf_hwm_mem || ' bytes of memory.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('currently 0.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('</pre>');
END;
/


PROMPT ==============================================================================================
PROMPT == JAVA POOL DIAGNOSTIC ==
PROMPT ==============================================================================================

/* Current instance parameter values */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current instance parameter values:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT n.ksppinm name, v.KSPPSTVL value
FROM x$ksppi n, x$ksppsv v
WHERE n.indx = v.indx AND (n.ksppinm like '%_pool%'  OR n.ksppinm like 'java%' OR n.ksppinm IN ('_kghdsidx_count','_ksmg_granule_size','aq_tm_processes'))
ORDER BY 1;

/* Current memory settings */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current memory settings:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT component, current_size FROM v$sga_dynamic_components;

/* Memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM v$sga_resize_ops
ORDER BY 1, 2;

/* Historical memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Historical memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM dba_hist_memory_resize_ops
ORDER BY 1, 2;

/* Java and Streams pool memory allocations by size */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Java and Streams pool memory allocations by size:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT name, bytes FROM v$sgastat WHERE (pool = 'java pool' OR pool = 'streams pool') AND (bytes > 999999 OR name = 'free memory') ORDER BY bytes DESC;

/* Total pool usage */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Total pool usage:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT pool, SUM(bytes) "Total Pool Usage" FROM v$sgastat WHERE (pool = 'java pool' OR pool = 'streams pool') AND name != 'free memory' GROUP BY pool;
spool off


spool DBHeathcheck_DBMem_BufferCache_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == BUFFER CACHE ADVISOR==
PROMPT ==============================================================================================
SELECT * from gv$db_cache_advice ORDER BY 1,7;


PROMPT ==============================================================================================
PROMPT == TABLESPACE IN BUFFER CACHED ==
PROMPT ==============================================================================================
set linesize 400
set pagesize 10000
col buffercache_pct for a15
break on report
compute sum of MB  on report
SELECT * FROM (
    SELECT
        inst_id,TO_CHAR(ROUND(RATIO_TO_REPORT( ROUND(SUM(ts.block_size) / 1048576) ) OVER (partition by inst_id) * 100, 1), '999.9')||' %'  buffercache_pct
      , ROUND(SUM(ts.block_size) / 1048576) MB
      , ts.tablespace_name
      , bh.status
    FROM
        gv$bh bh
      , (SELECT data_object_id
              , MIN(owner) owner
              , MIN(object_name) object_name
              , MIN(subobject_name) subobject_name
              , MIN(object_type) object_type
              , COUNT(*) num_duplicates 
        FROM dba_objects GROUP BY data_object_id) o
      , v$tablespace vts
      , dba_tablespaces ts
    WHERE 
        bh.objd = o.data_object_id (+)
    AND bh.ts#  = vts.ts#
    AND vts.name = ts.tablespace_name
    GROUP BY
        bh.inst_id,ts.tablespace_name
      , bh.status
    ORDER BY 
        mb DESC
)
WHERE ROWNUM <=30
order by inst_id,mb
/


PROMPT ==============================================================================================
PROMPT == TOP OBJ IN BUFFER CACHE ==
PROMPT ==============================================================================================
set linesize 400
set pagesize 1000
COLUMN owner   		FORMAT a15
COLUMN object_name	FORMAT a30
set verify off
DEFINE b_div=1048576
break on report
compute sum of totalmb on report 
select * from (
SELECT /*+ choose */ o.OWNER
      , o.object_name
	  , round(SUM(DECODE(bitand(flag,1),1,0,a.blksize))/&&b_div,2) "Not Dirty (Mb)" 
      , round(SUM(DECODE(bitand(flag,1),1,a.blksize,0))/&&b_div,2) "Dirty (Mb)"
	  , round(SUM(dirty_queue* a.blksize)/&&b_div,2) "On Dirty (Mb)"
	  , round(SUM(a.blksize)/&&b_div,2) totalmb    
FROM x$bh x
   , DBA_OBJECTS o
   , (SELECT VALUE blksize FROM v$system_parameter WHERE NAME = 'db_block_size') a
WHERE x.obj = o.OBJECT_ID
GROUP BY o.OWNER, o.object_name) where rownum <=30
order by 6,3,4 
/

undefine b_div

spool off

spool DBHeathcheck_DBMem_SharedPool_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == SHARED POOL UTILIZATION ==
PROMPT ==============================================================================================

set serveroutput on
DECLARE
   object_mem       NUMBER;
   shared_sql       NUMBER;
   cursor_mem       NUMBER;
   mts_mem          NUMBER;
   used_pool_size   NUMBER;
   free_mem         NUMBER;
   pool_size        VARCHAR2 (512);                     -- Now from V$SGASTAT
BEGIN
   -- Stored objects (packages, views)
   SELECT SUM (sharable_mem)
     INTO object_mem
     FROM v$db_object_cache;

   -- Shared SQL -- need to have additional memory if dynamic SQL used
   SELECT SUM (sharable_mem)
     INTO shared_sql
     FROM v$sqlarea;

   -- User Cursor Usage -- run this during peak usage.
   --  assumes 250 bytes per open cursor, for each concurrent user.
   SELECT SUM (250 * users_opening)
     INTO cursor_mem
     FROM v$sqlarea;

   -- For a test system -- get usage for one user, multiply by # users
   -- select (250 * value) bytes_per_user
   -- from v$sesstat s, v$statname n
   -- where s.statistic# = n.statistic#
   -- and n.name = 'opened cursors current'
   -- and s.sid = 25;  -- where 25 is the sid of the process
   -- MTS memory needed to hold session information for shared server users
   -- This query computes a total for all currently logged on users (run
   --  multiply by # users.
   SELECT SUM (VALUE)
     INTO mts_mem
     FROM v$sesstat s, v$statname n
    WHERE s.statistic# = n.statistic# AND n.NAME = 'session uga memory max';

   -- Free (unused) memory in the SGA: gives an indication of how much memory
   -- is being wasted out of the total allocated.
   SELECT BYTES
     INTO free_mem
     FROM v$sgastat
    WHERE NAME = 'free memory' AND pool = 'shared pool';

   -- For non-MTS add up object, shared sql, cursors and 20% overhead.
   used_pool_size := ROUND (1.2 * (object_mem + shared_sql + cursor_mem));

   -- For MTS mts contribution needs to be included (comment out previous line)
   -- used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem+mts_mem));
   SELECT SUM (BYTES)
     INTO pool_size
     FROM v$sgastat
    WHERE pool = 'shared pool';

   -- Display results
   DBMS_OUTPUT.put_line ('Shared Pool Memory Utilization Report');
   DBMS_OUTPUT.put_line ('Obj mem:  ' || TO_CHAR (object_mem) || ' bytes');
   DBMS_OUTPUT.put_line ('Shared sql:  ' || TO_CHAR (shared_sql) || ' bytes');
   DBMS_OUTPUT.put_line ('Cursors:  ' || TO_CHAR (cursor_mem) || ' bytes');
   -- dbms_output.put_line ('MTS session: '||to_char (mts_mem) || ' bytes');
   DBMS_OUTPUT.put_line (   'Free memory: '
                         || TO_CHAR (free_mem)
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (free_mem / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Shared pool utilization (total):  '
                         || TO_CHAR (used_pool_size)
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (used_pool_size / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Shared pool allocation (actual):  '
                         || pool_size
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (pool_size / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Percentage Utilized:  '
                         || TO_CHAR (ROUND (used_pool_size / pool_size * 100))
                        );
END;
/

PROMPT ==============================================================================================
PROMPT == SHARED POOL ADVISOR ==
PROMPT ==============================================================================================

SELECT * from gv$shared_pool_advice order by 1;

PROMPT ==============================================================================================
PROMPT == SHARED POOL SIZING OPERATION ==
PROMPT ==============================================================================================


column initial_size format 999999999999999
column target_size format 999999999999999
column final_size format 999999999999999
 
select to_char(end_time, 'dd-Mon-yyyy hh24:mi') end, oper_type, initial_size,
 target_size, final_size from V$SGA_RESIZE_OPS
 where component='shared pool'
 order by end;
 
PROMPT ==============================================================================================
PROMPT == MIN SHARED POOL SIZE ==
PROMPT ==============================================================================================

 column cr_shared_pool_size format 9999999999999
column sum_obj_size format 99999999
column sum_sql_size format 99999999
column sum_user_size format 99999999
column min_shared_pool format 99999999999999999
 
 
select cr_shared_pool_size,
sum_obj_size, sum_sql_size,
sum_user_size,
(sum_obj_size + sum_sql_size+sum_user_size)* 1.3 min_shared_pool
from (select sum(sharable_mem) sum_obj_size
from v$db_object_cache where type<> 'CURSOR'),
(select sum(sharable_mem) sum_sql_size from v$sqlarea),
(select sum(250*users_opening) sum_user_size from v$sqlarea),
(select to_Number(b.ksppstvl) cr_shared_pool_size
 from x$ksppi a, x$ksppcv b, x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
 and a.ksppinm ='__shared_pool_size' );

 

/* Current instance parameter values */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current instance parameter values:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT n.ksppinm name, v.KSPPSTVL value
FROM x$ksppi n, x$ksppsv v
WHERE n.indx = v.indx
AND (n.ksppinm LIKE '%shared_pool%' OR n.ksppinm IN ('_kghdsidx_count', '_ksmg_granule_size', '_memory_imm_mode_without_autosga'))
ORDER BY 1;


/* Shared pool 4031 information */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool 4031 information:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT request_failures, last_failure_size FROM v$shared_pool_reserved;

/* Shared pool reserved 4031 information */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool reserved 4031 information:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT requests, request_misses, free_space, avg_free_size, free_count, max_free_size FROM v$shared_pool_reserved;

/* Shared pool memory allocations by size */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool memory allocations by size:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT name, bytes FROM v$sgastat WHERE pool = 'shared pool' AND (bytes > 999999 OR name = 'free memory') ORDER BY bytes DESC;

/* Total shared pool usage */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Total shared pool usage:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT SUM(bytes) "Total Shared Pool Usage" FROM v$sgastat WHERE pool = 'shared pool' AND name != 'free memory';
spool off


spool DBHeathcheck_DBMem_PGA_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == PGA PARAMETER==
PROMPT ==============================================================================================

set linesize 400
set pagesize 10000
col parameter head NAME for a40
col value head VALUE(Mb) for 999999
column description heading DESCRIPTION format a50 word_wrap
SELECT
  a.ksppinm AS parameter,
  round(c.ksppstvl/1024/1024,0) AS VALUE,
  a.ksppdesc AS description,
  b.ksppstdf AS "Default?"
FROM
  x$ksppi a,
  x$ksppcv b,
  x$ksppsv c
WHERE a.indx = b.indx
AND a.indx = c.indx
AND a.ksppinm IN ('pga_aggregate_target','_pga_max_size')
union all
SELECT
  a.ksppinm AS parameter,
  round(c.ksppstvl/1024,0) AS VALUE,
  a.ksppdesc AS description,
  b.ksppstdf AS "Default?"
FROM
  x$ksppi a,
  x$ksppcv b,
  x$ksppsv c
WHERE a.indx = b.indx
AND a.indx = c.indx
AND a.ksppinm IN ('_smm_max_size','_smm_px_max_size','_smm_px_max_size_static','_smm_max_size_static')
ORDER BY 1;
set linesize 400
set pagesize 1000
col name for a40
col description for a70


PROMPT ==============================================================================================
PROMPT == PGA STATISTIC ==
PROMPT ==============================================================================================
select * from gv$pgastat order by 1,2;

PROMPT ==============================================================================================
PROMPT == PGA ADVISOR ==
PROMPT ==============================================================================================
SELECT inst_id,PGA_TARGET_FACTOR,round(PGA_TARGET_FOR_ESTIMATE/1024/1024) target_mb,
      ESTD_PGA_CACHE_HIT_PERCENTAGE cache_hit_perc,
      ESTD_OVERALLOC_COUNT
FROM   gv$pga_target_advice; 

PROMPT ==============================================================================================
PROMPT == PGA TOP MEMORY==
PROMPT ==============================================================================================

 SELECT
     operation_type
   , policy
   , ROUND(SUM(actual_mem_used)/1048576) actual_pga_mb
   , ROUND(SUM(work_area_size)/1048576)  allowed_pga_mb
   , ROUND(SUM(tempseg_size)/1048576)    temp_mb
   , MAX(number_passes)                  num_passes
   , COUNT(DISTINCT qcinst_id||','||qcsid)   num_qc
   , COUNT(DISTINCT inst_id||','||sid)   num_sessions
 FROM
     gv$sql_workarea_active
 GROUP BY 
     operation_type
   , policy
 ORDER BY 
     actual_pga_mb DESC NULLS LAST
/
spool off


spool DBHeathcheck_DBObj_&&dbname&&timestamp&&suffix 

PROMPT ==============================================================================================
PROMPT == INVALID OBJECTS ==
PROMPT ==============================================================================================
prompt
SELECT owner,object_type,object_name,status FROM dba_objects WHERE  status = 'INVALID' ORDER BY owner, object_type, object_name;


PROMPT ==============================================================================================
PROMPT == UNUSABLE INDEXES ==
PROMPT ==============================================================================================
prompt

COLUMN table_owner          HEADING "Table Owner"            FORMAT a20
COLUMN table_name           HEADING "Table Name"             FORMAT a45
COLUMN index_owner          HEADING "Index Owner"            FORMAT a20
COLUMN index_name           HEADING "Index Name"             FORMAT a45
COLUMN partition_name       HEADING "Partition Name"         FORMAT a25
COLUMN subpartition_name    HEADING "SubPartition Name"      FORMAT a25
COLUMN tablespace_name      HEADING "Tablespace Name"        FORMAT a20
COLUMN status               HEADING "Status"                 FORMAT a10
COLUMN uniqueness           HEADING "Uniqness"               FORMAT a10
COLUMN rebuild_sql          HEADING "Rebuild SQL Statement"  FORMAT a200


SELECT i.table_owner || '.' || i.table_name table_name
     , i.owner || '.' || i.index_name       index_name  
     , ip.partition_name 
     , isp.subpartition_name 
     , NVL(NVL(isp.tablespace_name,ip.tablespace_name),i.tablespace_name) tablespace_name
     , NVL(NVL(isp.status,ip.status),i.status) status
     , i.uniqueness
FROM   dba_indexes i
       LEFT OUTER JOIN dba_ind_partitions ip ON i.owner = ip.index_owner AND i.index_name = ip.index_name
       LEFT OUTER JOIN dba_ind_subpartitions isp ON ip.index_owner = isp.index_owner AND ip.index_name = isp.index_name AND ip.partition_name = isp.partition_name
WHERE  NVL(NVL(isp.status,ip.status),i.status) NOT IN ('VALID','N/A','USABLE')
ORDER BY 1,2,3,4,5,6
;

SELECT 'ALTER INDEX ' || i.owner || '.' || i.index_name || ' REBUILD' 
        || NVL2(isp.subpartition_name,' SUBPARTITION '  || isp.subpartition_name,  NVL2(ip.partition_name,' PARTITION '  || ip.partition_name, ' '))
        || ' PARALLEL 4; ' 
        || NVL2(isp.subpartition_name,' '  ,NVL2( ip.partition_name, ' ', chr(10) || 'ALTER INDEX ' || i.owner || '.' || i.index_name || ' NOPARALLEL;') )
        rebuild_sql
FROM   dba_indexes i
       LEFT OUTER JOIN dba_ind_partitions ip ON i.owner = ip.index_owner AND i.index_name = ip.index_name
       LEFT OUTER JOIN dba_ind_subpartitions isp ON ip.index_owner = isp.index_owner AND ip.index_name = isp.index_name AND ip.partition_name = isp.partition_name
WHERE  NVL(NVL(isp.status,ip.status),i.status) NOT IN ('VALID','N/A','USABLE')
ORDER BY 1
;

PROMPT ==============================================================================================
PROMPT == TABLE FRAGMENT ==
PROMPT ==============================================================================================
set pages 200
set lines 200
col OWNER format a20
col TABLE_NAME format a30
select owner,table_name,round((blocks*8),2)/1024/1024 "size (Gb)" , 
round((num_rows*avg_row_len/1024),2)/1024/1024 "actual_data (Gb)",
(round((blocks*8),2) - round((num_rows*avg_row_len/1024),2))/1024/1024 "wasted_space (Gb)"
from dba_tables
where 
(round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
and 
table_name in 
(select segment_name from (select owner, segment_name, bytes/1024/1024 meg from dba_segments
where 
segment_type = 'TABLE' 
and
owner != 'SYS' and owner != 'SYSTEM' and owner != 'OLAPSYS' and owner != 'SYSMAN' and owner != 'ODM' and owner != 'RMAN' and owner != 'ORACLE_OCM' and owner != 'EXFSYS' and owner != 'OUTLN' and owner != 'DBSNMP' and owner != 'OPS' and owner != 'DIP' and owner != 'ORDSYS' and owner != 'WMSYS' and owner != 'XDB' and owner != 'CTXSYS' and owner != 'DMSYS' and owner != 'SCOTT' and owner != 'TSMSYS' and owner != 'MDSYS' and owner != 'WKSYS' and owner != 'ORDDATA' and owner != 'OWBSYS' and owner != 'ORDPLUGINS' and owner != 'SI_INFORMTN_SCHEMA' and owner != 'PUBLIC' and owner != 'OWBSYS_AUDIT' and owner != 'APPQOSSYS' and owner != 'APEX_030200' and owner != 'FLOWS_030000' and owner != 'WK_TEST' and owner != 'SWBAPPS' and owner != 'WEBDB' and owner != 'OAS_PUBLIC' and owner != 'FLOWS_FILES' and owner != 'QMS'
order by bytes/1024/1024 desc) 
where rownum <= 20)
order by 5 desc;

PROMPT ==============================================================================================
PROMPT == CHAIN ROWS ==
PROMPT ==============================================================================================
select table_name,chain_cnt,owner from dba_tables where chain_cnt > 0 order by 2;

PROMPT ==============================================================================================
PROMPT == LOB SEGMENT RETENTION ==
PROMPT ==============================================================================================
select table_name,chain_cnt,owner from dba_tables where chain_cnt > 0 order by 2;
col column_name form a30
col owner form a20
select owner,TABLE_NAME,COLUMN_NAME,SEGMENT_NAME,PCTVERSION,RETENTION,CACHE from dbA_lobs where owner not in ('SYS','SYSTEM','SYSAUX','XDB') order by 1,7,2;

PROMPT ==============================================================================================
PROMPT == INDEX DISTINCT KEY ==
PROMPT ==============================================================================================
select index_name,table_name,owner,distinct_keys,last_analyzed from dbA_indexes where DISTINCT_KEYS <=2 and distinct_keys > 0 order by 4;

spool off


spool DBHeathcheck_DBSTATISTIC_&&dbname&&timestamp&&suffix 
PROMPT ==============================================================================================
PROMPT == MAINTENANCE TASK ==
PROMPT ==============================================================================================
prompt

set linesize 400
set pagesize 10000
col client_name for a35
col operation_name for a30
SELECT client_name,operation_name,status FROM dba_autotask_operation;


PROMPT ==============================================================================================
PROMPT == MAINTENANCE TASK SCHEDULE ==
PROMPT ==============================================================================================
prompt

col start_time for a50
col duration for a30
SELECT * FROM dba_autotask_schedule;

PROMPT ==============================================================================================
PROMPT == JOBS RELATED TO GATHERING STATISTIC ==
PROMPT ==============================================================================================
prompt

SELECT owner, JOB_NAME, start_date, last_start_date, next_run_date FROM dba_scheduler_jobs where job_name like '%GATHER%';


PROMPT ==============================================================================================
PROMPT == SCHEMA WITH NO STATISTIC ==
PROMPT ==============================================================================================
prompt

SET SERVEROUTPUT ON

DECLARE
-- Variables declared
P_OTAB DBMS_STATS.OBJECTTAB;
MCOUNT NUMBER := 0;
P_VERSION VARCHAR2(10);
-- Cursor defined
CURSOR c1
IS
SELECT distinct schema
FROM dba_registry
ORDER by 1;

-- Beginning of the anonymous block
BEGIN
-- Verifying version from v$instance
SELECT version INTO p_version FROM v$instance;
DBMS_OUTPUT.PUT_LINE(chr(13));
-- Defining Loop 1 for listing schema which have stale stats
FOR x in c1 
  LOOP
	DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>x.schema,OPTIONS=>'LIST STALE',OBJLIST=>p_otab);

-- Defining Loop 2 to find number of objects containing stale stats
	FOR i in 1 .. p_otab.count
	  LOOP
		IF p_otab(i).objname NOT LIKE 'SYS_%' 
			AND p_otab(i).objname NOT IN ('CLU$','COL_USAGE$','FET$','INDPART$',
										  'MON_MODS$','TABPART$','HISTGRM$',
										  'MON_MODS_ALL$',
										  'HIST_HEAD$','IN $','TAB$',
										  'WRI$_OPTSTAT_OPR','PUIU$DATA',
										  'XDB$NLOCKS_CHILD_NAME_IDX',
										  'XDB$NLOCKS_PARENT_OID_IDX',
										  'XDB$NLOCKS_RAWTOKEN_IDX', 'XDB$SCHEMA_URL',
										  'XDBHI_IDX', 'XDB_PK_H_LINK')
		THEN
-- Incrementing count for  each object found with statle stats
			mcount := mcount + 1;
		END IF;
-- End of Loop 2
	  END LOOP;

-- Displays no stale statistics, if coun  is 0
		IF mcount!=0 
			THEN
-- Displays Schema with stale stats if count is greater than 0
				DBMS_OUTPUT.PUT_LINE(chr(13));
				DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
				DBMS_OUTPUT.PUT_LINE('-- '|| x.schema || ' schema contains stale statistics use the following to gather the statistics '||'--');
				DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
				
-- Displays Command to be executed if schema with stale statistics is found depending on the version.
		  IF SUBSTR(p_version,1,5) in ('8.1.7','9.0.1','9.2.0') 
			THEN
				DBMS_OUTPUT.PUT_LINE(chr(13));
				DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.GATHER_SCHEMA_STATS('''||x.schema||''',OPTIONS=>'''||'GATHER STALE'||''', ESTIMATE_PERCENT  => DBMS_STATS.AUTO_SAMPLE_SIZE, METHOD_OPT => '''||'FOR ALL COLUMNS SIZE AUTO'||''', CASCADE => TRUE);');
		  ELSIF SUBSTR(p_version,1,6) in ('10.1.0','10.2.0','11.1.0','11.2.0','12.1.0') 
			THEN
				DBMS_OUTPUT.PUT_LINE(chr(13));
				DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.GATHER_DICTIONARY_STATS('''||x.schema||''',OPTIONS=>'''||'GATHER STALE'||''', ESTIMATE_PERCENT  => DBMS_STATS.AUTO_SAMPLE_SIZE, METHOD_OPT => '''||'FOR ALL COLUMNS SIZE AUTO'||''', CASCADE => TRUE);');
		  ELSE
				DBMS_OUTPUT.PUT_LINE(chr(13));
				DBMS_OUTPUT.PUT_LINE('Version is '||p_version);
		  END IF;
		ELSE
				DBMS_OUTPUT.PUT_LINE('-- There are no stale statistics in '|| x.schema || ' schema.');
				DBMS_OUTPUT.PUT_LINE(chr(13));
		END IF;
-- Reset count to 0.
			mcount := 0;
-- End of Loop 1
  END LOOP;
END;
/

prompt
PROMPT ==============================================================================================
PROMPT == TABLE NEVER ANALYZED  ==
PROMPT ==============================================================================================
prompt
select owner, table_name, to_char(last_analyzed,'RRRRMMDD'),num_rows
  from dba_tables
  where to_char(last_analyzed,'RRRRMMDD') is null
order by to_char(last_analyzed,'RRRRMMDD'),num_rows desc, owner, table_name desc ;

prompt
PROMPT ==============================================================================================
PROMPT == TABLE ANALYZED OVER 2 DAYS  ==
PROMPT ==============================================================================================
prompt
select owner, table_name, to_char(last_analyzed,'RRRRMMDD'), NUM_ROWS
  from dba_tables
  where to_number(to_char(last_analyzed,'RRRRMMDD')) <= to_number(to_char(sysdate,'RRRRMMDD'))-2
  and NUM_ROWS > 10
order by to_char(last_analyzed,'RRRRMMDD'), num_rows desc, owner, table_name desc;

prompt
PROMPT ==============================================================================================
PROMPT == TABLE AND INDEXES STALE STATISTIC ==
PROMPT ==============================================================================================
prompt

SELECT 'TABLE' object_type,owner, table_name object_name, last_analyzed, stattype_locked, stale_stats
FROM all_tab_statistics
WHERE (last_analyzed IS NULL OR stale_stats = 'YES') and stattype_locked IS NULL
and owner NOT IN ('ANONYMOUS', 'CTXSYS', 'DBSNMP', 'EXFSYS','LBACSYS','MDSYS','MGMT_VIEW','OLAPSYS','OWBSYS','ORDPLUGINS','ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SYS', 'SYSMAN','SYSTEM','TSMSYS','WK_TEST','WKSYS','WKPROXY','WMSYS','XDB' )
AND owner NOT LIKE 'FLOW%'
UNION ALL
SELECT 'INDEX' object_type,owner, index_name object_name,  last_analyzed, stattype_locked, stale_stats
FROM all_ind_statistics
WHERE (last_analyzed IS NULL OR stale_stats = 'YES') and stattype_locked IS NULL
AND owner NOT IN ('ANONYMOUS', 'CTXSYS', 'DBSNMP', 'EXFSYS','LBACSYS','MDSYS','MGMT_VIEW','OLAPSYS','OWBSYS','ORDPLUGINS','ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SYS', 'SYSMAN','SYSTEM','TSMSYS','WK_TEST','WKSYS','WKPROXY','WMSYS','XDB' )
AND owner NOT LIKE 'FLOW%'
ORDER BY object_type desc, owner, object_name
/
spool off


spool DBHeathcheck_DBIO_&&dbname&&timestamp&&suffix 
prompt
PROMPT ==============================================================================================
PROMPT == DATABASE OBJECT IO STATISTIC  ==
PROMPT ==============================================================================================
prompt
col segment_name for a35
col tablespace for a15
col statistic for a26
col inst_id for 9999

with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('gc current blocks received') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) 
SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('gc buffer busy') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) 
SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('buffer busy waits') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('optimized physical reads') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('row lock waits') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) 
SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical reads') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) 
SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical reads direct') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical writes') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical write requests') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('logical reads') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical read requests') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('physical writes direct') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('ITL waits') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;
with topgcbkc as
(SELECT inst_id,owner || '.' || object_name segment_name,object_type objecttype,tablespace_name tablespace,statistic_name statistic,SUM(VALUE) "Total",ROUND(  SUM(VALUE)* 100/ SUM(SUM(VALUE)) OVER (), 2) pct FROM gv$segment_statistics  WHERE statistic_name in ('segment scans') AND VALUE > 0 GROUP BY inst_id,owner || '.' || object_name,object_type,tablespace_name,statistic_name order by 1,5,7 desc) SELECT * FROM topgcbkc WHERE pct > 1;

prompt
PROMPT ==============================================================================================
PROMPT == IO STATISTIC SUMMARY  ==
PROMPT ==============================================================================================
prompt

select * from
( select  inst_id,owner,object_name,object_type,tablespace_name,
sum(case when a.statistic_name = 'row lock waits' then a.value else null end) "RowLock Waits",
sum(case when a.statistic_name = 'ITL waits' then a.value else null end) "ITL Waits",
sum(case when a.statistic_name = 'buffer busy waits' then a.value else null end) "BufferBusy Waits",
sum(case when a.statistic_name = 'db block changes' then a.value else null end) "DB Block Change",
sum(case when a.statistic_name = 'physical reads' then a.value else null end) "Physical Reads",
sum(case when a.statistic_name = 'physical reads direct' then a.value else null end) "Physical Reads Direct",
sum(case when a.statistic_name = 'physical writes' then a.value else null end) "Physical Writes",
sum(case when a.statistic_name = 'physical write requests' then a.value else null end) "Physical Write Request",
sum(case when a.statistic_name = 'physical read requests' then a.value else null end) "Physical Read Request",
sum(case when a.statistic_name = 'physical writes direct' then a.value else null end) "Physical Write Direct",
sum(case when a.statistic_name = 'optimized physical reads' then a.value else null end) "Optimized Physical Read",
sum(case when a.statistic_name = 'gc cr blocks received' then a.value else null end) "Gc CR Blks Rec",
sum(case when a.statistic_name = 'gc current blocks received' then a.value else null end) "Gc Current Blks Rec",
sum(case when a.statistic_name = 'gc buffer busy' then a.value else null end) "Gc Buffer Busy",
sum(case when a.statistic_name = 'space allocated' then a.value else null end) "Space Allocated",
sum(case when a.statistic_name = 'space used' then a.value else null end) "Space Used",
sum(case when a.statistic_name = 'segment scans' then a.value else null end) "Segment Scan"
from gv$segment_statistics a
where a.owner not in ('SYS','SYSMAN','DBSNMP')
group by inst_id,owner,object_type,tablespace_name,rollup(a.object_name))
/


prompt
PROMPT ==============================================================================================
PROMPT == TABLESPACE IO STATISTIC  ==
PROMPT ==============================================================================================
prompt
SELECT inst_id,to_char(end_time,'dd/mm/yy hh24:mi:ss'),tablespace_name,
       ROUND(AVG(average_read_time) * 10, 2) avg_read_time_ms,
       ROUND(AVG(average_write_time) * 10, 2) avg_write_time_ms,
       SUM(physical_reads) physical_reads,    SUM(physical_writes) physical_writes,
       ROUND((SUM(physical_reads) + SUM(physical_writes)) * 100 /  SUM(SUM(physical_reads) + SUM(physical_writes)) OVER (partition by inst_id), 2) pct_io,
       CASE
          WHEN SUM(physical_reads) > 0 THEN
             ROUND(SUM(physical_block_reads) / SUM(physical_reads), 2)
       END  blks_per_read
  FROM gv$filemetric JOIN dba_data_files
       USING (file_id)
GROUP BY inst_id,to_char(end_time,'dd/mm/yy hh24:mi:ss'),tablespace_name, file_id
ORDER BY 1;

prompt
PROMPT ==============================================================================================
PROMPT == EVENT WAIT IO STATISTIC  ==
PROMPT ==============================================================================================
prompt

WITH system_event AS(SELECT CASE WHEN wait_class IN ('User I/O', 'System I/O') THEN event ELSE wait_class END  wait_type, e.* FROM v$system_event e) SELECT wait_type, SUM(total_waits) / 1000 waits_1000, ROUND(SUM(time_waited_micro) / 1000000 / 3600, 2)       time_waited_hours, ROUND(SUM(time_waited_micro) / SUM(total_waits) / 1000, 2) avg_wait_ms,ROUND(  SUM(time_waited_micro)* 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct FROM (SELECT wait_type, event, total_waits, time_waited_micro FROM system_event e UNION SELECT 'CPU', stat_name, NULL, VALUE       FROM v$sys_time_model       WHERE stat_name IN ('background cpu time', 'DB CPU')) l WHERE wait_type <> 'Idle' GROUP BY wait_type ORDER BY SUM(time_waited_micro) DESC;


PROMPT ==============================================================================================
PROMPT == IO READ AND WRITE INFORMATION  ==
PROMPT ==============================================================================================
COLUMN ts_name    FORMAT a15          HEAD 'Tablespace'
COLUMN fname      FORMAT a60          HEAD 'File Name'
COLUMN phyrds     FORMAT 999,999,999  HEAD 'Physical Reads'
COLUMN phywrts    FORMAT 999,999,999  HEAD 'Physical Writes'
COLUMN read_pct   FORMAT 999.99       HEAD 'Read Pct.'
COLUMN write_pct  FORMAT 999.99       HEAD 'Write Pct.'

BREAK ON report
COMPUTE SUM OF phyrds     ON report
COMPUTE SUM OF phywrts    ON report
COMPUTE AVG OF read_pct   ON report
COMPUTE AVG OF write_pct  ON report

SELECT
    df.tablespace_name                       ts_name
  , df.file_name                             fname
  , fs.phyrds                                phyrds
  , (fs.phyrds * 100) / (fst.pr + tst.pr)    read_pct
  , fs.phywrts                               phywrts
  , (fs.phywrts * 100) / (fst.pw + tst.pw)   write_pct
FROM
    sys.dba_data_files df
  , v$filestat         fs
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    df.file_id = fs.file#
UNION
SELECT
    tf.tablespace_name                     ts_name
  , tf.file_name                           fname
  , ts.phyrds                              phyrds
  , (ts.phyrds * 100) / (fst.pr + tst.pr)  read_pct
  , ts.phywrts                             phywrts
  , (ts.phywrts * 100) / (fst.pw + tst.pw) write_pct
FROM
    sys.dba_temp_files  tf
  , v$tempstat          ts
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    tf.file_id = ts.file#
ORDER BY phyrds DESC
/

PROMPT ==============================================================================================
PROMPT == IO FUNCTION  ==
PROMPT ==============================================================================================

col function_name format a25 heading "File Type"
col reads format 99,999,999,999 heading "Reads"
col writes format 99,999,999,999 heading "Writes"
col number_of_waits format 99,999,999,999 heading "Waits" 
col wait_time_sec format 99,999,999,999 heading "Wait Time|Sec"
col avg_wait_ms format 99,999,999,999.99 heading "Avg|Wait ms"

SELECT function_name, small_read_reqs + large_read_reqs reads,
       small_write_reqs + large_write_reqs writes, 
       wait_time/1000 wait_time_sec,
       CASE WHEN number_of_waits > 0 THEN 
          ROUND(wait_time / number_of_waits, 2)
       END avg_wait_ms
  FROM v$iostat_function
 ORDER BY wait_time DESC;
 
 
 PROMPT ==============================================================================================
PROMPT == IO FILETYPE  ==
PROMPT ==============================================================================================

col filetype_name format a20 heading "File Type"
col reads format 9,999,999,999 heading "Reads"
col writes format 9,999,999,999 heading "Writes"
col read_time_sec format  99,999,999 heading "Read Time|sec"
col write_time_sec format  99,999,999 heading "Write Time|sec"
col avg_sync_read_ms format 999.99 heading "Avg Sync|Read ms"
col total_io_seconds format 999,999,999 heading "Total IO|sec"

WITH iostat_file AS 
  (SELECT filetype_name,SUM(large_read_reqs) large_read_reqs,
          SUM(large_read_servicetime) large_read_servicetime,
          SUM(large_write_reqs) large_write_reqs,
          SUM(large_write_servicetime) large_write_servicetime,
          SUM(small_read_reqs) small_read_reqs,
          SUM(small_read_servicetime) small_read_servicetime,
          SUM(small_sync_read_latency) small_sync_read_latency,
          SUM(small_sync_read_reqs) small_sync_read_reqs,
          SUM(small_write_reqs) small_write_reqs,
          SUM(small_write_servicetime) small_write_servicetime
     FROM sys.v_$iostat_file
    GROUP BY filetype_name)
SELECT filetype_name, small_read_reqs + large_read_reqs reads,
       large_write_reqs + small_write_reqs writes,
       ROUND((small_read_servicetime + large_read_servicetime)/1000) 
          read_time_sec,
       ROUND((small_write_servicetime + large_write_servicetime)/1000) 
          write_time_sec,
       CASE WHEN small_sync_read_reqs > 0 THEN 
          ROUND(small_sync_read_latency / small_sync_read_reqs, 2) 
       END avg_sync_read_ms,
       ROUND((  small_read_servicetime+large_read_servicetime
              + small_write_servicetime + large_write_servicetime)
             / 1000, 2)  total_io_seconds
  FROM iostat_file
 ORDER BY 7 DESC; 
 
clear columns
clear breaks

PROMPT ==============================================================================================
PROMPT == IO TIME  ==
PROMPT ==============================================================================================

col file_name format a60 heading "DataFile Name"
col phyrds_1000 format 999,999 heading "Reads|\1000"
col avg_blk_reads format 99.99 heading "Avg Blks|per rd" noprint
col iotime_hrs format 9,999,999 heading "IO Time|(hrs)"
col pct_io format 99.99 heading "Pct|IO Time"
col phywrts_1000 format 999,999 heading "Writes|\1000"
col writetime_sec format 99,999,999 heading "Write Time|(s)"
col singleblkrds_1000 format  999,999 heading "Single blk|Reads\1000"
col single_rd_avg_time format 999.99 heading "Single Blk|Rd Avg (ms)"


with filestat as 
    (SELECT file_name, phyrds, phywrts, phyblkrd, phyblkwrt, 
            singleblkrds, readtim, writetim, singleblkrdtim
       FROM v$tempstat JOIN dba_temp_files
         ON (file# = file_id)
      UNION
     SELECT file_name, phyrds, phywrts, phyblkrd, phyblkwrt, 
            singleblkrds, readtim, writetim, singleblkrdtim
       FROM v$filestat  JOIN dba_data_files
         ON (file# = file_id)) 
SELECT file_name, ROUND(SUM(phyrds) / 1000) phyrds_1000,
       ROUND(SUM(phyblkrd) / SUM(phyrds), 2) avg_blk_reads,
       ROUND((SUM(readtim) + SUM(writetim)) / 100 / 3600, 2) iotime_hrs,
       ROUND(SUM(phyrds + phywrts) * 100 / SUM(SUM(phyrds + phywrts)) 
            OVER (), 2) pct_io, ROUND(SUM(phywrts) / 1000) phywrts_1000,
       ROUND(SUM(singleblkrdtim) * 10 / SUM(singleblkrds), 2)
          single_rd_avg_time
 FROM filestat 
GROUP BY file_name
ORDER BY (SUM(readtim) + SUM(writetim)) DESC;

PROMPT ==============================================================================================
PROMPT == IO EFFICIENT  ==
PROMPT ==============================================================================================


clear columns
clear breaks

COLUMN ts        FORMAT a15     HEADING 'Tablespace'
COLUMN fn        FORMAT a47     HEADING 'Filename'
COLUMN rds                      HEADING 'Reads'
COLUMN blk_rds                  HEADING 'Block Reads'
COLUMN wrts                     HEADING 'Writes'
COLUMN blk_wrts                 HEADING 'Block Writes'
COLUMN rw                       HEADING 'Reads+Writes'
COLUMN blk_rw                   HEADING 'Block Reads+Writes'
COLUMN eff      FORMAT a10  HEADING 'Effeciency'

SELECT
    f.tablespace_name          ts
  , f.file_name                fn
  , v.phyrds                   rds
  , v.phyblkrd                 blk_rds
  , v.phywrts                  wrts
  , v.phyblkwrt                blk_wrts
  , v.phyrds + v.phywrts       rw
  , v.phyblkrd + v.phyblkwrt   blk_rw
  , DECODE(v.phyblkrd, 0, null, ROUND(100*(v.phyrds + v.phywrts)/(v.phyblkrd + v.phyblkwrt), 2)) eff
FROM
    dba_data_files  f
  , v$filestat      v
WHERE
  f.file_id = v.file#
ORDER BY
  rds
/


PROMPT ==============================================================================================
PROMPT == IO WAIT  ==
PROMPT ==============================================================================================


clear columns
clear breaks
COLUMN filename  FORMAT a58           HEAD "File Name"
COLUMN file#     FORMAT 999           HEAD "File #"
COLUMN ct        FORMAT 999,999,999   HEAD "Waits (count)"
COLUMN time      FORMAT 999,999,999   HEAD "Time (cs)"
COLUMN avg       FORMAT 999.999       HEAD "Avg Time"


SELECT
    a.indx + 1  file#
  , b.name      filename
  , a.count     ct
  , a.time      time
  , a.time/(DECODE(a.count,0,1,a.count)) avg
FROM
    x$kcbfwait   a
  , v$datafile   b
WHERE
      indx < (SELECT count(*) FROM v$datafile)
  AND a.indx+1 = b.file#
ORDER BY a.time
/

spool off

spool DBHeathcheck_AllCureMetric_&&dbname&&timestamp&&suffix 
set serveroutput on
set pagesize 50000

PROMPT ==============================================================================================
PROMPT == AAS WAIT CLASS ==
PROMPT ==============================================================================================
prompt

select to_char(to_date(ts*300,'SSSSS'),'HH24:MI') sample_time, AAS,
nvl("'ON CPU'",0) "CPU",
nvl("'Scheduler'",0) Scheduler ,
nvl("'User I/O'",0) "USER I/O" ,
nvl("'System I/O'",0) "SYSTEM I/O" ,
nvl("'Concurrency'",0) Concurrency ,
nvl("'Application'",0) Application ,
nvl("'Commit'",0) Commit,
nvl("'Configuration'",0) Configuration,
nvl("'Administrative'",0) Administrative ,
nvl("'Network'",0) Network ,
nvl("'Queueing'",0) Queueing ,
nvl("'Cluster'",0) "CLUSTER",
nvl("'Other'",0) Other
from (
 select trunc(to_char(sample_time, 'SSSSS')/300) ts,
 decode(session_state,'WAITING',wait_class,'ON CPU') wait_class,
 count(*) cnt,
 sum(count(*)) over (partition by trunc(to_char(sample_time, 'SSSSS')/300)) sum,
 sum(count(*)) over (partition by trunc(to_char(sample_time, 'SSSSS')/300))/300 AAS
 from v$active_session_history
 group by trunc(to_char(sample_time, 'SSSSS')/300),
          decode(session_state,'WAITING',wait_class,'ON CPU')
 order by 1
)
pivot (
   sum(round(cnt/sum*100,2))
   for (wait_class) in   
   ('Administrative','Application','Cluster','Commit','Concurrency',
    'Configuration','Network','Other','Queueing','Scheduler','System I/O',
    'User I/O','ON CPU'
   )
) order by 1;


PROMPT ==============================================================================================
PROMPT == REAL TIME OS STATISTIC ==
PROMPT ==============================================================================================
prompt

select inst_id,
round((ut/(ut+it+st+io+nt))*100)  "User Time Pct",
round((bt/(ut+it+st+io+nt))*100)  "Busy Time Pct",
round((it/(ut+it+st+io+nt))*100)  "Idle Time Pct",
round((st/(ut+it+st+io+nt))*100)  "System Time Pct",
round((io/(ut+it+st+io+nt))*100)  "I/O Wait Pct",
round((nt/(ut+it+st+io+nt))*100)  "Nice Time Pct",
(100-( round((ut/(ut+it+st+io+nt))*100)+
 round((nt/(ut+it+st+io+nt))*100)+
 round((st/(ut+it+st+io+nt))*100)+
 round((io/(ut+it+st+io+nt))*100)
)) itpct,vin "VM IN Bytes",vout "VM Out Bytes"
from
(
select inst_id,sum(decode(oss.stat_name,'USER_TIME',value,0)) ut,
	 sum(decode(oss.stat_name,'BUSY_TIME',value,0)) bt,
	 sum(decode(oss.stat_name,'IDLE_TIME',value,0)) it,
	 sum(decode(oss.stat_name,'SYS_TIME',value,0)) st,
	 sum(decode(oss.stat_name,'IOWAIT_TIME',value,0)) io,
	 sum(decode(oss.stat_name,'NICE_TIME',value,0)) nt,
	 sum(decode(oss.stat_name,'VM_IN_BYTES',value,0)) vin,
	 sum(decode(oss.stat_name,'VM_OUT_BYTES',value,0)) vout
from gv$osstat oss
where oss.stat_name in ('USER_TIME','BUSY_TIME','IDLE_TIME','SYS_TIME','IOWAIT_TIME','NICE_TIME','VM_IN_BYTES','VM_OUT_BYTES')
group by inst_id
)
order by 1,2
/

PROMPT ==============================================================================================
PROMPT == REAL TIME DB LOAD METRIC ==
PROMPT ==============================================================================================
prompt
select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'SQL Service Response Time' then 'SQL Service Response Time'
		when 'Session Count' then 'Session Count'
		when 'Average Active Sessions' then 'Average Active Sessions'
		when 'Background CPU Usage Per Sec' then 'Background CPU Usage Per Sec'
		when 'Background Time Per Sec' then 'Background Time Per Sec'
		when 'Host CPU Usage Per Sec' then 'Host CPU Usage Per Sec'
		when 'Database Time Per Sec' then 'Database Time Per Sec'
		when 'Total PGA Allocated' then 'Total PGA Allocated'
		when 'Total PGA Used by SQL Workareas' then 'Total PGA Used by SQL Workareas'
		when 'Current OS Load' then 'Current OS Load'
		when 'Process Limit %' then 'Process Limit %'
		when 'Session Limit %' then 'Session Limit %'
		when 'User Limit %' then 'User Limit %'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'SQL Service Response Time' then ROUND((MINVAL / 100),1)
		when 'Session Count' then round(MINVAL,1)
		when 'Average Active Sessions' then round(MINVAL,1)
		when 'Background CPU Usage Per Sec' then ROUND((MINVAL),1)
		when 'Background Time Per Sec' then ROUND((MINVAL),1)
		when 'Host CPU Usage Per Sec' then ROUND((MINVAL),1)
		when 'Database Time Per Sec' then ROUND((MINVAL),1)
		when 'Total PGA Allocated' then ROUND((MINVAL/1024/1024),1)
		when 'Total PGA Used by SQL Workareas' then ROUND((MINVAL/1024/1024),1)
		when 'Current OS Load' then ROUND((MINVAL),1)
		when 'Process Limit %' then ROUND((MINVAL),1)
		when 'Session Limit %' then ROUND((MINVAL),1)
		when 'User Limit %' then ROUND((MINVAL),1)				
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'SQL Service Response Time' then ROUND((AVERAGE / 100),1)
		when 'Session Count' then round(AVERAGE,1)
		when 'Average Active Sessions' then round(AVERAGE,1)
		when 'Background CPU Usage Per Sec' then ROUND((AVERAGE),1)
		when 'Background Time Per Sec' then ROUND((AVERAGE),1)
		when 'Host CPU Usage Per Sec' then ROUND((AVERAGE),1)
		when 'Database Time Per Sec' then ROUND((AVERAGE),1)
		when 'Total PGA Allocated' then ROUND((AVERAGE/1024/1024),1)
		when 'Total PGA Used by SQL Workareas' then ROUND((AVERAGE/1024/1024),1)
		when 'Current OS Load' then ROUND((AVERAGE),1)
		when 'Process Limit %' then ROUND((AVERAGE),1)
		when 'Session Limit %' then ROUND((AVERAGE),1)
		when 'User Limit %' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'SQL Service Response Time' then ROUND((MAXVAL / 100),1)
		when 'Session Count' then round(MAXVAL,1)
		when 'Average Active Sessions' then round(MAXVAL,1)
		when 'Background CPU Usage Per Sec' then ROUND((MAXVAL),1)
		when 'Background Time Per Sec' then ROUND((MAXVAL),1)
		when 'Host CPU Usage Per Sec' then ROUND((MAXVAL),1)
		when 'Database Time Per Sec' then ROUND((MAXVAL),1)
		when 'Total PGA Allocated' then ROUND((MAXVAL/1024/1024),1)
		when 'Total PGA Used by SQL Workareas' then ROUND((MAXVAL/1024/1024),1)
		when 'Current OS Load' then ROUND((MAXVAL),1)
		when 'Process Limit %' then ROUND((MAXVAL),1)
		when 'Session Limit %' then ROUND((MAXVAL),1)
		when 'User Limit %' then ROUND((MAXVAL),1)
ELSE MAXVAL
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY 		
where   METRIC_NAME in ('SQL Service Response Time',
 'Session Count',
'Average Active Sessions',
'Background CPU Usage Per Sec',
'Background CPU Usage Per Sec',
 'Host CPU Usage Per Sec',
'Database Time Per Sec',
'Total PGA Allocated',
'Total PGA Used by SQL Workareas',
'Current OS Load',
'Process Limit %',
'Session Limit %',
'User Limit %')
ORDER BY 1;

PROMPT ==============================================================================================
PROMPT == REAL TIME DATABASE HIT RATIO ==
PROMPT ==============================================================================================
prompt

select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'Database Wait Time Ratio' then 'Database Wait Time Ratio'
		when 'Database CPU Time Ratio' then 'Database CPU Time Ratio'
		when 'Buffer Cache Hit Ratio' then 'Buffer Cache Hit Ratio'
		when 'Memory Sorts Ratio' then 'Memory Sorts Ratio'
		when 'Redo Allocation Hit Ratio' then 'Redo Allocation Hit Ratio'
		when 'Cursor Cache Hit Ratio' then 'Cursor Cache Hit Ratio'
		when 'Soft Parse Ratio' then 'Soft Parse Ratio'
		when 'User Calls Ratio' then 'User Calls Ratio'
		when 'Row Cache Hit Ratio' then 'Row Cache Hit Ratio'
		when 'Row Cache Miss Ratio' then 'Row Cache Miss Ratio'
		when 'Execute Without Parse Ratio' then 'Execute Without Parse Ratio'
		when 'Library Cache Hit Ratio' then 'Library Cache Hit Ratio'
		when 'Library Cache Miss Ratio' then 'Library Cache Miss Ratio'
		when 'PGA Cache Hit %' then 'PGA Cache Hit %'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'Database Wait Time Ratio' then ROUND((MINVAL / 100),1)
		when 'Database CPU Time Ratio' then round(MINVAL,1)
		when 'Buffer Cache Hit Ratio' then round(MINVAL,1)
		when 'Memory Sorts Ratio' then ROUND((MINVAL),1)
		when 'Redo Allocation Hit Ratio' then ROUND((MINVAL),1)
		when 'Cursor Cache Hit Ratio' then ROUND((MINVAL),1)
		when 'Soft Parse Ratio' then ROUND((MINVAL),1)
		when 'User Calls Ratio' then ROUND((MINVAL),1)
		when 'Row Cache Hit Ratio' then ROUND((MINVAL),1)
		when 'Row Cache Miss Ratio' then ROUND((MINVAL),1)
		when 'Execute Without Parse Ratio' then ROUND((MINVAL),1)
		when 'Library Cache Hit Ratio' then ROUND((MINVAL),1)
		when 'Library Cache Miss Ratio' then ROUND((MINVAL),1)
		when 'PGA Cache Hit %' then ROUND((MINVAL),1)		
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'Database Wait Time Ratio' then ROUND((AVERAGE / 100),1)
		when 'Database CPU Time Ratio' then round(AVERAGE,1)
		when 'Buffer Cache Hit Ratio' then round(AVERAGE,1)
		when 'Memory Sorts Ratio' then ROUND((AVERAGE),1)
		when 'Redo Allocation Hit Ratio' then ROUND((AVERAGE),1)
		when 'Cursor Cache Hit Ratio' then ROUND((AVERAGE),1)
		when 'Soft Parse Ratio' then ROUND((AVERAGE),1)
		when 'User Calls Ratio' then ROUND((AVERAGE),1)
		when 'Row Cache Hit Ratio' then ROUND((AVERAGE),1)
		when 'Row Cache Miss Ratio' then ROUND((AVERAGE),1)
		when 'Execute Without Parse Ratio' then ROUND((AVERAGE),1)
		when 'Library Cache Hit Ratio' then ROUND((AVERAGE),1)
		when 'Library Cache Miss Ratio' then ROUND((AVERAGE),1)
		when 'PGA Cache Hit %' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'Database Wait Time Ratio' then ROUND((MAXVAL / 100),1)
		when 'Database CPU Time Ratio' then round(MAXVAL,1)
		when 'Buffer Cache Hit Ratio' then round(MAXVAL,1)
		when 'Memory Sorts Ratio' then ROUND((MAXVAL),1)
		when 'Redo Allocation Hit Ratio' then ROUND((MAXVAL),1)
		when 'Cursor Cache Hit Ratio' then ROUND((MAXVAL),1)
		when 'Soft Parse Ratio' then ROUND((MAXVAL),1)
		when 'User Calls Ratio' then ROUND((MAXVAL),1)
		when 'Row Cache Hit Ratio' then ROUND((MAXVAL),1)
		when 'Row Cache Miss Ratio' then ROUND((MAXVAL),1)
		when 'Execute Without Parse Ratio' then ROUND((MAXVAL),1)
		when 'Library Cache Hit Ratio' then ROUND((MAXVAL),1)
		when 'Library Cache Miss Ratio' then ROUND((MAXVAL),1)
		when 'PGA Cache Hit %' then ROUND((MAXVAL),1)
ELSE MAXVAL
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY 		
where   METRIC_NAME in ('Database Wait Time Ratio',
                      'Database CPU Time Ratio',
                      'Buffer Cache Hit Ratio',
                      'Memory Sorts Ratio',
                      'Redo Allocation Hit Ratio',
                      'Cursor Cache Hit Ratio',
                      'Soft Parse Ratio',
                      'User Calls Ratio',
					  'Row Cache Hit Ratio',
					  'Row Cache Miss Ratio',
					  'Execute Without Parse Ratio',
					  'Library Cache Hit Ratio',
					  'Library Cache Miss Ratio',
					  'PGA Cache Hit %')
ORDER BY 1;


PROMPT ==============================================================================================
PROMPT == SHARED POOL STATISTIC ==
PROMPT ==============================================================================================
prompt

select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'Logons Per Sec' then 'Logons Per Sec'
		when 'Shared Pool Free %' then 'Shared Pool Free %'
		when 'Open Cursors Per Sec' then 'Open Cursors Per Sec'
		when 'Hard Parse Count Per Sec' then 'Hard Parse Count Per Sec'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'Logons Per Sec' then ROUND((MINVAL / 100),1)
		when 'Shared Pool Free %' then round(MINVAL,1)
		when 'Open Cursors Per Sec' then round(MINVAL,1)
		when 'Hard Parse Count Per Sec' then ROUND((MINVAL),1)
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'Logons Per Sec' then ROUND((AVERAGE / 100),1)
		when 'Shared Pool Free %' then round(AVERAGE,1)
		when 'Open Cursors Per Sec' then round(AVERAGE,1)
		when 'Hard Parse Count Per Sec' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'Logons Per Sec' then ROUND((MAXVAL / 100),1)
		when 'Shared Pool Free %' then round(MAXVAL,1)
		when 'Open Cursors Per Sec' then round(MAXVAL,1)
		when 'Hard Parse Count Per Sec' then ROUND((MAXVAL),1)
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY  		
where   METRIC_NAME in ('Logons Per Sec',
                      'Shared Pool Free %',
                      'Open Cursors Per Sec',
                      'Physical Writes Direct Per Sec',
                      'Hard Parse Count Per Sec'
)
ORDER BY 1;

PROMPT ==============================================================================================
PROMPT == REAL TIME DB ACTIVITY ==
PROMPT ==============================================================================================
prompt

select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'User Transaction Per Sec' then 'User Transaction Per Sec'
		when 'Redo Generated Per Sec' then 'Redo Generated Per Sec'
		when 'User Commits Per Sec' then 'User Commits Per Sec'
		when 'User Calls Per Sec' then 'User Calls Per Sec'
		when 'Redo Writes Per Sec' then 'Redo Writes Per Sec'
		when 'DB Block Changes Per Sec' then 'DB Block Changes Per Sec'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'User Transaction Per Sec' then ROUND((MINVAL / 100),1)
		when 'Redo Generated Per Sec' then round(MINVAL,1)
		when 'User Commits Per Sec' then round(MINVAL,1)
		when 'User Calls Per Sec' then ROUND((MINVAL),1)
		when 'Redo Writes Per Sec' then ROUND((MINVAL),1)
		when 'DB Block Changes Per Sec' then ROUND((MINVAL),1)
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'User Transaction Per Sec' then ROUND((AVERAGE / 100),1)
		when 'Redo Generated Per Sec' then round(AVERAGE,1)
		when 'User Commits Per Sec' then round(AVERAGE,1)
		when 'User Calls Per Sec' then ROUND((AVERAGE),1)
		when 'Redo Writes Per Sec' then ROUND((AVERAGE),1)
		when 'DB Block Changes Per Sec' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'User Transaction Per Sec' then ROUND((MAXVAL / 100),1)
		when 'Redo Generated Per Sec' then round(MAXVAL,1)
		when 'User Commits Per Sec' then round(MAXVAL,1)
		when 'User Calls Per Sec' then ROUND((MAXVAL),1)
		when 'Redo Writes Per Sec' then ROUND((MAXVAL),1)
		when 'DB Block Changes Per Sec' then ROUND((MAXVAL),1)
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY   		
where   METRIC_NAME in ('User Transaction Per Sec',
                      'Redo Generated Per Sec',
                      'User Commits Per Sec',
                      'User Calls Per Sec',
                      'Redo Writes Per Sec',
					  'DB Block Changes Per Sec'
) order by 1;



PROMPT ==============================================================================================
PROMPT == REAL TIME IO STATISTIC ==
PROMPT ==============================================================================================
prompt
select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'Physical Reads Per Sec' then 'Physical Reads Per Sec'
		when 'Physical Writes Per Sec' then 'Physical Writes Per Sec'
		when 'Physical Reads Direct Per Sec' then 'Physical Reads Direct Per Sec'
		when 'Physical Writes Direct Per Sec' then 'Physical Writes Direct Per Sec'
		when 'Logical Reads Per Sec' then 'Logical Reads Per Sec'
		when 'I/O Megabytes per Second' then 'I/O Megabytes per Second'
		when 'I/O Requests per Second' then 'I/O Requests per Second'
		when 'Total Table Scans Per Sec' then 'Total Table Scans Per Sec'
		when 'Full Index Scans Per Sec' then 'Full Index Scans Per Sec'
		when 'Physical Read Total IO Requests Per Sec' then 'Physical Read Total IO Requests Per Sec'
		when 'Physical Read Total Bytes Per Sec' then 'Physical Read Total Bytes Per Sec'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'Physical Reads Per Sec' then ROUND((MINVAL / 100),1)
		when 'Physical Writes Per Sec' then round(MINVAL,1)
		when 'Physical Reads Direct Per Sec' then round(MINVAL,1)
		when 'Physical Writes Direct Per Sec' then ROUND((MINVAL),1)
		when 'Logical Reads Per Sec' then ROUND((MINVAL),1)
		when 'I/O Megabytes per Second' then ROUND((MINVAL),1)
		when 'I/O Requests per Second' then ROUND((MINVAL),1)
		when 'Total Table Scans Per Sec' then ROUND((MINVAL),1)
		when 'Full Index Scans Per Sec' then ROUND((MINVAL),1)
		when 'Physical Read Total IO Requests Per Sec' then ROUND((MINVAL),1)
		when 'Physical Read Total Bytes Per Sec' then ROUND((MINVAL),1)
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'Physical Reads Per Sec' then ROUND((AVERAGE / 100),1)
		when 'Physical Writes Per Sec' then round(AVERAGE,1)
		when 'Physical Reads Direct Per Sec' then round(AVERAGE,1)
		when 'Physical Writes Direct Per Sec' then ROUND((AVERAGE),1)
		when 'Logical Reads Per Sec' then ROUND((AVERAGE),1)
		when 'I/O Megabytes per Second' then ROUND((AVERAGE),1)
		when 'I/O Requests per Second' then ROUND((AVERAGE),1)
		when 'Total Table Scans Per Sec' then ROUND((AVERAGE),1)
		when 'Full Index Scans Per Sec' then ROUND((AVERAGE),1)
		when 'Physical Read Total IO Requests Per Sec' then ROUND((AVERAGE),1)
		when 'Physical Read Total Bytes Per Sec' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'Physical Reads Per Sec' then ROUND((MAXVAL / 100),1)
		when 'Physical Writes Per Sec' then round(MAXVAL,1)
		when 'Physical Reads Direct Per Sec' then round(MAXVAL,1)
		when 'Physical Writes Direct Per Sec' then ROUND((MAXVAL),1)
		when 'Logical Reads Per Sec' then ROUND((MAXVAL),1)
		when 'I/O Megabytes per Second' then ROUND((MAXVAL),1)
		when 'I/O Requests per Second' then ROUND((MAXVAL),1)
		when 'Total Table Scans Per Sec' then ROUND((MAXVAL),1)
		when 'Full Index Scans Per Sec' then ROUND((MAXVAL),1)
		when 'Physical Read Total IO Requests Per Sec' then ROUND((MAXVAL),1)
		when 'Physical Read Total Bytes Per Sec' then ROUND((MAXVAL),1)
ELSE MAXVAL
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY  		
where   METRIC_NAME in ('Physical Reads Per Sec',
                      'Physical Writes Per Sec',
                      'Physical Reads Direct Per Sec',
                      'Physical Writes Direct Per Sec',
                      'Logical Reads Per Sec',
                      'I/O Megabytes per Second',
                      'I/O Requests per Second',
                      'Total Table Scans Per Sec',
					  'Full Index Scans Per Sec',
					  'Physical Read Total IO Requests Per Sec',
					  'Physical Read Total Bytes Per Sec'
)
ORDER BY 1;


PROMPT ==============================================================================================
PROMPT == REAL TIME RAC STATISTIC ==
PROMPT ==============================================================================================
prompt

select inst_id,to_char(begin_time,'dd/mm/yy hh24:mi') "Begin Time", to_char(end_time,'dd/mm/yy hh24:mi') "End Time",
CASE METRIC_NAME
		when 'GC CR Block Received Per Second' then 'GC CR Block Received Per Second'
		when 'GC CR Block Received Per Txn' then 'GC CR Block Received Per Txn'
		when 'GC Current Block Received Per Second' then 'GC Current Block Received Per Second'
		when 'GC Current Block Received Per Txn' then 'GC Current Block Received Per Txn '
		when 'Global Cache Average CR Get Time' then 'Global Cache Average CR Get Time'
		when 'Global Cache Average Current Get Time' then 'Global Cache Average Current Get Time'
		when 'Global Cache Blocks Corrupted' then 'Global Cache Blocks Corrupted '
		when 'Global Cache Blocks Lost' then 'Global Cache Blocks Lost'
ELSE METRIC_NAME
	END METRIC_NAME,
		CASE METRIC_NAME
		when 'GC CR Block Received Per Second' then ROUND((MINVAL / 100),1)
		when 'GC CR Block Received Per Txn' then round(MINVAL,1)
		when 'GC Current Block Received Per Second' then round(MINVAL,1)
		when 'GC Current Block Received Per Txn' then ROUND((MINVAL),1)
		when 'Global Cache Average CR Get Time' then ROUND((MINVAL),1)
		when 'Global Cache Average Current Get Time' then ROUND((MINVAL),1)
		when 'Global Cache Blocks Corrupted' then ROUND((MINVAL),1)
		when 'Global Cache Blocks Lost' then ROUND((MINVAL),1)		
ELSE MINVAL
    END MININUM,
        CASE METRIC_NAME
		when 'GC CR Block Received Per Second' then ROUND(AVERAGE,1)
		when 'GC CR Block Received Per Txn' then round(AVERAGE,1)
		when 'GC Current Block Received Per Second' then round(AVERAGE,1)
		when 'GC Current Block Received Per Txn' then ROUND((AVERAGE),1)
		when 'Global Cache Average CR Get Time' then ROUND((AVERAGE),1)
		when 'Global Cache Average Current Get Time' then ROUND((AVERAGE),1)
		when 'Global Cache Blocks Corrupted' then ROUND((AVERAGE),1)
		when 'Global Cache Blocks Lost' then ROUND((AVERAGE),1)
ELSE AVERAGE
    END AVERAGE,
		CASE METRIC_NAME
		when 'GC CR Block Received Per Second' then ROUND((MAXVAL),1)
		when 'GC CR Block Received Per Txn' then round(MAXVAL,1)
		when 'GC Current Block Received Per Second' then round(MAXVAL,1)
		when 'GC Current Block Received Per Txn' then ROUND((MAXVAL),1)
		when 'Global Cache Average CR Get Time' then ROUND((MAXVAL),1)
		when 'Global Cache Average Current Get Time' then ROUND((MAXVAL),1)
		when 'Global Cache Blocks Corrupted' then ROUND((MAXVAL),1)
		when 'Global Cache Blocks Lost' then ROUND((MAXVAL),1)
END MAXIMUM
from    GV_$SYSMETRIC_SUMMARY  		
where   METRIC_NAME in ('GC CR Block Received Per Second','GC CR Block Received Per Txn','GC Current Block Received Per Second','GC Current Block Received Per Txn','Global Cache Average CR Get Time','Global Cache Average Current Get Time','Global Cache Blocks Corrupted','Global Cache Blocks Lost') and trunc(begin_time) > sysdate-2
order by 1;

PROMPT ==============================================================================================
PROMPT == REAL TIME NETWORK METRIC ==
PROMPT ==============================================================================================
prompt
select inst_id,metric_name, round(minval/1024/1024,3) "Min Value",  round(average/1024/1024,3) "Average Value", round(maxval/1024/1024,3) "Max Value", round(standard_deviation/1024/1024,3) "Standard Devi"
from GV_$SYSMETRIC_SUMMARY 
where metric_name = 'Network Traffic Volume Per Sec'
/

prompt
PROMPT ==============================================================================================
PROMPT == REAL TIME LOAD PROFILE ==
PROMPT ==============================================================================================
prompt
set pagesize 1000
set linesize 400
col short_name heading "System Metric Name" for a50 justify left
col "Time+Delta" for a20
col per_sec heading "Per/Secs" for a15
col per_tx heading "Per/Tx" for a15
col begintime for a20
select inst_id,begintime,short_name
     ,case when per_sec >10000000 then '* '||round(per_sec/1024/1024,0)||' M' 
            when per_sec between 10000 and 10000000 then '+ '||round(per_sec/1024,0)||' K'
            when per_sec between 10 and 1024 then '  '||to_char(round(per_sec,0))
            else '  '||to_char(per_sec) 
       end per_sec
     , case when per_tx >10000000 then '* '||round(per_tx/1024/1024,0)||' M' 
            when per_tx between 10000 and 10000000 then '+ '||round(per_tx/1024,0)||' K'
            when per_tx between 10 and 1024 then '  '||to_char(round(per_tx,0))
            else '  '||to_char(per_tx) 
       end per_tx from
    (select inst_id,to_char(min(begin_time),'hh24:mi:ss')||' /'||round(avg(intsize_csec/100),0)||'s' begintime,short_name,intsize_csec
          , max(decode(typ, 1, value)) per_sec
          , max(decode(typ, 2, value)) per_tx
          , max(m_rank) m_rank 
       from
        (select /*+ use_hash(s) */ inst_id,begin_time,
                m.short_name,s.intsize_csec
              , round(s.value * coeff,1) value
              , typ
              , m_rank
           from gv_$sysmetric s,
               (select 'Consistent Read Changes Per Sec' metric_name, 'Consistent Read Changes' short_name, 1 coeff, 1 typ,1 m_rank from dual union all
				select 'Consistent Read Gets Per Sec' metric_name, 'Consistent Read Gets' short_name, 1 coeff, 1 typ,2 m_rank from dual union all
				select 'CPU Usage Per Sec' metric_name, 'CPU Usage' short_name, .01 coeff, 1 typ,3 m_rank from dual union all
				select 'CR Blocks Created Per Sec' metric_name, 'CR Blocks Created' short_name, 1 coeff, 1 typ,4 m_rank from dual union all
				select 'CR Undo Records Applied Per Sec' metric_name, 'CR Undo Records Applied' short_name, 1 coeff, 1 typ,5 m_rank from dual union all
				select 'DB Block Changes Per Sec' metric_name, 'DB Block Changes' short_name, 1 coeff, 1 typ,6 m_rank from dual union all
				select 'DB Block Gets Per Sec' metric_name, 'DB Block Gets' short_name, 1 coeff, 1 typ,7 m_rank from dual union all
				select 'Disk Sort Per Sec' metric_name, 'Disk Sort' short_name, 1 coeff, 1 typ,8 m_rank from dual union all
				select 'Enqueue Deadlocks Per Sec' metric_name, 'Enqueue Deadlocks' short_name, 1 coeff, 1 typ,9 m_rank from dual union all
				select 'Enqueue Requests Per Sec' metric_name, 'Enqueue Requests' short_name, 1 coeff, 1 typ,10 m_rank from dual union all
				select 'Enqueue Timeouts Per Sec' metric_name, 'Enqueue Timeouts' short_name, 1 coeff, 1 typ,11 m_rank from dual union all
				select 'Enqueue Waits Per Sec' metric_name, 'Enqueue Waits' short_name, 1 coeff, 1 typ,12 m_rank from dual union all
				select 'Executions Per Sec' metric_name, 'Executions' short_name, 1 coeff, 1 typ,13 m_rank from dual union all
				select 'Full Index Scans Per Sec' metric_name, 'Full Index Scans' short_name, 1 coeff, 1 typ,14 m_rank from dual union all
				select 'GC CR Block Received Per Second' metric_name, 'GC CR Block Received' short_name, 1 coeff, 1 typ,15 m_rank from dual union all
				select 'GC Current Block Received Per Second' metric_name, 'GC Current Block Received' short_name, 1 coeff, 1 typ,16 m_rank from dual union all
				select 'Hard Parse Count Per Sec' metric_name, 'Hard Parse Count' short_name, 1 coeff, 1 typ,17 m_rank from dual union all
				select 'Leaf Node Splits Per Sec' metric_name, 'Leaf Node Splits' short_name, 1 coeff, 1 typ,18 m_rank from dual union all
				select 'Logical Reads Per Sec' metric_name, 'Logical Reads' short_name, 1 coeff, 1 typ,19 m_rank from dual union all
				select 'Logons Per Sec' metric_name, 'Logons' short_name, 1 coeff, 1 typ,20 m_rank from dual union all
				select 'Long Table Scans Per Sec' metric_name, 'Long Table Scans' short_name, 1 coeff, 1 typ,21 m_rank from dual union all
				select 'Open Cursors Per Sec' metric_name, 'Open Cursors' short_name, 1 coeff, 1 typ,22 m_rank from dual union all
				select 'Parse Failure Count Per Sec' metric_name, 'Parse Failure Count' short_name, 1 coeff, 1 typ,23 m_rank from dual union all
				select 'Physical Reads Per Sec' metric_name, 'Physical Reads' short_name, 1 coeff, 1 typ,24 m_rank from dual union all
				select 'Physical Reads Direct Per Sec' metric_name, 'Physical Reads Direct' short_name, 1 coeff, 1 typ,25 m_rank from dual union all
				select 'Physical Reads Direct Lobs Per Sec' metric_name, 'Physical Reads Direct Lobs' short_name, 1 coeff, 1 typ,26 m_rank from dual union all
				select 'Physical Writes Direct Lobs Per Sec' metric_name, 'Physical Writes Direct' short_name, 1 coeff, 1 typ,27 m_rank from dual union all
				select 'Physical Writes Direct Per Sec' metric_name, 'Physical Writes Direct Lobs' short_name, 1 coeff, 1 typ,28 m_rank from dual union all
				select 'Physical Write Per Sec' metric_name, 'Physical Write Total IO Requests' short_name, 1 coeff, 1 typ,29 m_rank from dual union all
				select 'Recursive Calls Per Sec' metric_name, 'Recursive Calls' short_name, 1 coeff, 1 typ,30 m_rank from dual union all
				select 'Redo Generated Per Sec' metric_name, 'Redo Generated' short_name, 1 coeff, 1 typ,31 m_rank from dual union all
				select 'Redo Writes Per Sec' metric_name, 'Redo Writes' short_name, 1 coeff, 1 typ,32 m_rank from dual union all
				select 'Response Time Per Sec' metric_name, 'Response Time' short_name, 1 coeff, 1 typ,33 m_rank from dual union all
				select 'Total Index Scans Per Sec' metric_name, 'Total Index Scans' short_name, 1 coeff, 1 typ,34 m_rank from dual union all
				select 'Total Parse Count Per Sec' metric_name, 'Total Parse Count' short_name, 1 coeff, 1 typ,35 m_rank from dual union all
				select 'Total Table Scans Per Sec' metric_name, 'Total Table Scans' short_name, 1 coeff, 1 typ,36 m_rank from dual union all
				select 'User Calls Per Sec' metric_name, 'User Calls' short_name, 1 coeff, 1 typ,37 m_rank from dual union all
				select 'User Rollback Undo Records Applied Per Sec' metric_name, 'User Rollback Undo Records Applied' short_name, 1 coeff, 1 typ,38 m_rank from dual union all
				select 'Background CPU Usage Per Sec' metric_name, 'Background CPU Usage' short_name, 1 coeff, 1 typ,39 m_rank from dual union all
				select 'Background Checkpoints Per Sec' metric_name, 'Background Checkpoints' short_name, 1 coeff, 1 typ,40 m_rank from dual union all
				select 'Background Time Per Sec' metric_name, 'Background Time' short_name, 1 coeff, 1 typ,41 m_rank from dual union all
				select 'Branch Node Splits Per Sec' metric_name, 'Branch Node Splits' short_name, 1 coeff, 1 typ,42 m_rank from dual union all
				select 'DBWR Checkpoints Per Sec' metric_name, 'DBWR Checkpoints' short_name, 1 coeff, 1 typ,43 m_rank from dual union all
				select 'DDL statements parallelized Per Sec' metric_name, 'DDL statements parallelized' short_name, 1 coeff, 1 typ,44 m_rank from dual union all
				select 'DML statements parallelized Per Sec' metric_name, 'DML statements parallelized' short_name, 1 coeff, 1 typ,45 m_rank from dual union all
				select 'Database Time Per Sec' metric_name, 'Database Time' short_name, .01 coeff, 1 typ,46 m_rank from dual union all
				select 'Host CPU Usage Per Sec' metric_name, 'Host CPU Usage' short_name, 1 coeff, 1 typ,47 m_rank from dual union all
				select 'Network Traffic Volume Per Sec' metric_name, 'Network Traffic Volume' short_name, 1 coeff, 1 typ,48 m_rank from dual union all
				select 'Physical Read Bytes Per Sec' metric_name, 'Physical Read Bytes' short_name, 1 coeff, 1 typ,49 m_rank from dual union all
				select 'Physical Read IO Requests Per Sec' metric_name, 'Physical Read IO Requests' short_name, 1 coeff, 1 typ,50 m_rank from dual union all
				select 'Physical Read Total Bytes Per Sec' metric_name, 'Physical Read Total Bytes' short_name, 1 coeff, 1 typ,51 m_rank from dual union all
				select 'Physical Read Total IO Requests Per Sec' metric_name, 'Physical Read Total IO Requests' short_name, 1 coeff, 1 typ,52 m_rank from dual union all
				select 'Physical Write Bytes Per Sec' metric_name, 'Physical Write Bytes' short_name, 1 coeff, 1 typ,53 m_rank from dual union all
				select 'Physical Write IO Requests Per Sec' metric_name, 'Physical Write IO Requests' short_name, 1 coeff, 1 typ,54 m_rank from dual union all
				select 'Physical Write Total Bytes Per Sec' metric_name, 'Physical Write Total Bytes' short_name, 1 coeff, 1 typ,55 m_rank from dual union all
				select 'Physical Writes Per Sec' metric_name, 'Physical Writes' short_name, 1 coeff, 1 typ,56 m_rank from dual union all
				select 'Queries parallelized Per Sec' metric_name, 'Queries parallelized' short_name, 1 coeff, 1 typ,57 m_rank from dual union all
				select 'Redo Writes Per Sec' metric_name, 'Redo Writes' short_name, 1 coeff, 1 typ,58 m_rank from dual union all
				select 'Total Index Scans Per Sec' metric_name, 'Total Index Scans' short_name, 1 coeff, 1 typ,59 m_rank from dual union all
				select 'Total Parse Count Per Sec' metric_name, 'Total Parse Count' short_name, 1 coeff, 1 typ,60 m_rank from dual union all
				select 'Total Table Scans Per Sec' metric_name, 'Total Table Scans' short_name, 1 coeff, 1 typ,61 m_rank from dual union all
				select 'User Commits Per Sec' metric_name, 'User Commits' short_name, 1 coeff, 1 typ,62 m_rank from dual union all
				select 'User Rollbacks Per Sec' metric_name, 'User Rollbacks' short_name, 1 coeff, 1 typ,63 m_rank from dual union all
				select 'User Transaction Per Sec' metric_name, 'User Transaction' short_name, 1 coeff, 1 typ,64 m_rank from dual union all
				select 'Active Parallel Sessions' metric_name, 'Active Parallel Sessions' short_name, 1 coeff, 1 typ,66 m_rank from dual union all
				select 'Active Serial Sessions' metric_name, 'Active Serial Sessions' short_name, 1 coeff, 1 typ,67 m_rank from dual union all
				select 'Average Active Sessions' metric_name, 'Average Active Sessions' short_name, 1 coeff, 1 typ,68 m_rank from dual union all
				select 'Average Synchronous Single-Block Read Latency' metric_name, 'Average Synchronous Single-Block Read Latency' short_name, 1 coeff, 1 typ,69 m_rank from dual union all
				select 'Buffer Cache Hit Ratio' metric_name, 'Buffer Cache Hit Ratio' short_name, 1 coeff, 1 typ,70 m_rank from dual union all
				select 'Captured user calls' metric_name, 'Captured user calls' short_name, 1 coeff, 1 typ,71 m_rank from dual union all
				select 'Cell Physical IO Interconnect Bytes' metric_name, 'Cell Physical IO Interconnect Bytes' short_name, 1 coeff, 1 typ,72 m_rank from dual union all
				select 'Current Logons Count' metric_name, 'Current Logons Count' short_name, 1 coeff, 1 typ,73 m_rank from dual union all
				select 'Current OS Load' metric_name, 'Current OS Load' short_name, 1 coeff, 1 typ,74 m_rank from dual union all
				select 'Current Open Cursors Count' metric_name, 'Current Open Cursors Count' short_name, 1 coeff, 1 typ,75 m_rank from dual union all
				select 'Cursor Cache Hit Ratio' metric_name, 'Cursor Cache Hit Ratio' short_name, 1 coeff, 1 typ,76 m_rank from dual union all
				select 'Database CPU Time Ratio' metric_name, 'Database CPU Time Ratio' short_name, 1 coeff, 1 typ,77 m_rank from dual union all
				select 'Database Wait Time Ratio' metric_name, 'Database Wait Time Ratio' short_name, 1 coeff, 1 typ,78 m_rank from dual union all
			  select 'Execute Without Parse Ratio' metric_name, 'Execute Without Parse Ratio' short_name, 1 coeff, 1 typ,79 m_rank from dual union all
			  select 'Global Cache Average CR Get Time' metric_name, 'Global Cache Average CR Get Time' short_name, 1 coeff, 1 typ,80 m_rank from dual union all
			  select 'Global Cache Average Current Get Time' metric_name, 'Global Cache Average Current Get Time' short_name, 1 coeff, 1 typ,81 m_rank from dual union all
			  select 'Global Cache Blocks Corrupted' metric_name, 'Global Cache Blocks Corrupted' short_name, 1 coeff, 1 typ,82 m_rank from dual union all
				select 'Global Cache Blocks Lost' metric_name, 'Global Cache Blocks Lost' short_name, 1 coeff, 1 typ,83 m_rank from dual union all
				select 'Host CPU Utilization (%)' metric_name, 'Host CPU Utilization (%)' short_name, 1 coeff, 1 typ,84 m_rank from dual union all
				select 'I/O Megabytes per Second' metric_name, 'I/O Megabytes per Second' short_name, 1 coeff, 1 typ,85 m_rank from dual union all
				select 'I/O Requests per Second' metric_name, 'I/O Requests per Second' short_name, 1 coeff, 1 typ,86 m_rank from dual union all
				select 'Library Cache Hit Ratio' metric_name, 'Library Cache Hit Ratio' short_name, 1 coeff, 1 typ,87 m_rank from dual union all
				select 'Library Cache Miss Ratio' metric_name, 'Library Cache Miss Ratio' short_name, 1 coeff, 1 typ,88 m_rank from dual union all
				select 'Memory Sorts Ratio' metric_name, 'Memory Sorts Ratio' short_name, 1 coeff, 1 typ,89 m_rank from dual union all
				select 'PGA Cache Hit %' metric_name, 'PGA Cache Hit %' short_name, 1 coeff, 1 typ,90 m_rank from dual union all
				select 'PQ QC Session Count' metric_name, 'PQ QC Session Count' short_name, 1 coeff, 1 typ,91 m_rank from dual union all
				select 'PQ Slave Session Count' metric_name, 'PQ Slave Session Count' short_name, 1 coeff, 1 typ,92 m_rank from dual union all
				select 'Process Limit %' metric_name, 'Process Limit %' short_name, 1 coeff, 1 typ,93 m_rank from dual union all
				select 'Redo Allocation Hit Ratio' metric_name, 'Redo Allocation Hit Ratio' short_name, 1 coeff, 1 typ,94 m_rank from dual union all
				select 'Replayed user calls' metric_name, 'Replayed user calls' short_name, 1 coeff, 1 typ,95 m_rank from dual union all
				select 'Row Cache Hit Ratio' metric_name, 'Row Cache Hit Ratio' short_name, 1 coeff, 1 typ,96 m_rank from dual union all
				select 'Row Cache Miss Ratio' metric_name, 'Row Cache Miss Ratio' short_name, 1 coeff, 1 typ,97 m_rank from dual union all
				select 'SQL Service Response Time' metric_name, 'SQL Service Response Time' short_name, 1 coeff, 1 typ,98 m_rank from dual union all
				select 'Session Count' metric_name, 'Session Count' short_name, 1 coeff, 1 typ,99 m_rank from dual union all
				select 'Session Limit %' metric_name, 'Session Limit %' short_name, 1 coeff, 1 typ,100 m_rank from dual union all
				select 'Shared Pool Free %' metric_name, 'Shared Pool Free %' short_name, 1 coeff, 1 typ,101 m_rank from dual union all
				select 'Soft Parse Ratio' metric_name, 'Soft Parse Ratio' short_name, 1 coeff, 1 typ,102 m_rank from dual union all
				select 'Temp Space Used' metric_name, 'Temp Space Used' short_name, 1 coeff, 1 typ,103 m_rank from dual union all
				select 'Total PGA Allocated' metric_name, 'Total PGA Allocated' short_name, 1 coeff, 1 typ,104 m_rank from dual union all
				select 'Total PGA Used by SQL Workareas' metric_name, 'Total PGA Used by SQL Workareas' short_name, 1 coeff, 1 typ,105 m_rank from dual union all
				select 'User Calls Ratio' metric_name, 'User Calls Ratio' short_name, 1 coeff, 1 typ,106 m_rank from dual union all
				select 'User Limit %' metric_name, 'User Limit %' short_name, 1 coeff, 1 typ,107 m_rank from dual union all
				select 'Workload Capture and Replay status' metric_name, 'Workload Capture and Replay status' short_name, 1 coeff, 1 typ,108 m_rank from dual union all
				select 'Consistent Read Changes Per Txn' metric_name, 'Consistent Read Changes' short_name, 1 coeff, 2 typ,1 m_rank from dual union all
				select 'Consistent Read Gets Per Txn' metric_name, 'Consistent Read Gets' short_name, 1 coeff, 2 typ,2 m_rank from dual union all
				select 'CPU Usage Per Txn' metric_name, 'CPU Usage' short_name, 1 coeff, 2 typ,3 m_rank from dual union all
				select 'CR Blocks Created Per Txn' metric_name, 'CR Blocks Created' short_name, 1 coeff, 2 typ,4 m_rank from dual union all
				select 'CR Undo Records Applied Per Txn' metric_name, 'CR Undo Records Applied' short_name, 1 coeff, 2 typ,5 m_rank from dual union all
				select 'DB Block Changes Per Txn' metric_name, 'DB Block Changes' short_name, 1 coeff, 2 typ,6 m_rank from dual union all
				select 'DB Block Gets Per Txn' metric_name, 'DB Block Gets' short_name, 1 coeff, 2 typ,7 m_rank from dual union all
				select 'Disk Sort Per Txn' metric_name, 'Disk Sort' short_name, 1 coeff, 2 typ,8 m_rank from dual union all
				select 'Enqueue Deadlocks Per Txn' metric_name, 'Enqueue Deadlocks' short_name, 1 coeff, 2 typ,9 m_rank from dual union all
				select 'Enqueue Requests Per Txn' metric_name, 'Enqueue Requests' short_name, 1 coeff, 2 typ,10 m_rank from dual union all
				select 'Enqueue Timeouts Per Txn' metric_name, 'Enqueue Timeouts' short_name, 1 coeff, 2 typ,11 m_rank from dual union all
				select 'Enqueue Waits Per Txn' metric_name, 'Enqueue Waits' short_name, 1 coeff, 2 typ,12 m_rank from dual union all
				select 'Executions Per Txn' metric_name, 'Executions' short_name, 1 coeff, 2 typ,13 m_rank from dual union all
				select 'Full Index Scans Per Txn' metric_name, 'Full Index Scans' short_name, 1 coeff, 2 typ,14 m_rank from dual union all
				select 'GC CR Block Received Per Txn' metric_name, 'GC CR Block Received' short_name, 1 coeff, 2 typ,15 m_rank from dual union all
				select 'GC Current Block Received Per Txn' metric_name, 'GC Current Block Received' short_name, 1 coeff, 2 typ,16 m_rank from dual union all
				select 'Hard Parse Count Per Txn' metric_name, 'Hard Parse Count' short_name, 1 coeff, 2 typ,17 m_rank from dual union all
				select 'Leaf Node Splits Per Txn' metric_name, 'Leaf Node Splits' short_name, 1 coeff, 2 typ,18 m_rank from dual union all
				select 'Logical Reads Per Txn' metric_name, 'Logical Reads' short_name, 1 coeff, 2 typ,19 m_rank from dual union all
				select 'Logons Per Txn' metric_name, 'Logons' short_name, 1 coeff, 2 typ,20 m_rank from dual union all
				select 'Long Table Scans Per Txn' metric_name, 'Long Table Scans' short_name, 1 coeff, 2 typ,21 m_rank from dual union all
				select 'Open Cursors Per Txn' metric_name, 'Open Cursors' short_name, 1 coeff, 2 typ,22 m_rank from dual union all
				select 'Parse Failure Count Per Txn' metric_name, 'Parse Failure Count' short_name, 1 coeff, 2 typ,23 m_rank from dual union all
				select 'Physical Reads Per Txn' metric_name, 'Physical Reads Direct Lobs' short_name, 1 coeff, 2 typ,24 m_rank from dual union all
				select 'Physical Reads Direct Per Txn' metric_name, 'Physical Reads Direct' short_name, 1 coeff, 2 typ,25 m_rank from dual union all
				select 'Physical Reads Direct Lobs Per Txn' metric_name, 'Physical Reads' short_name, 1 coeff, 2 typ,26 m_rank from dual union all
				select 'Physical Writes Direct Lobs  Per Txn' metric_name, 'Physical Writes Direct Lobs' short_name, 1 coeff, 2 typ,27 m_rank from dual union all
				select 'Physical Writes Direct Per Txn' metric_name, 'Physical Writes Direct' short_name, 1 coeff, 2 typ,28 m_rank from dual union all
				select 'Physical Writes Per Txn' metric_name, 'Physical Writes' short_name, 1 coeff, 2 typ,29 m_rank from dual union all
				select 'Recursive Calls Per Txn' metric_name, 'Recursive Calls' short_name, 1 coeff, 2 typ,30 m_rank from dual union all
				select 'Redo Generated Per Txn' metric_name, 'Redo Generated' short_name, 1 coeff, 2 typ,31 m_rank from dual union all
				select 'Redo Writes Per Txn' metric_name, 'Redo Writes' short_name, 1 coeff, 2 typ,32 m_rank from dual union all
				select 'Response Time Per Txn' metric_name, 'Response Time' short_name, 1 coeff, 2 typ,33 m_rank from dual union all
				select 'Total Index Scans Per Txn' metric_name, 'Total Index Scans' short_name, 1 coeff, 2 typ,34 m_rank from dual union all
				select 'Total Parse Count Per Txn' metric_name, 'Total Parse Count' short_name, 1 coeff, 2 typ,35 m_rank from dual union all
				select 'Total Table Scans Per Txn' metric_name, 'Total Table Scans' short_name, 1 coeff, 2 typ,36 m_rank from dual union all
				select 'User Calls Per Txn' metric_name, 'User Calls' short_name, 1 coeff, 2 typ,37 m_rank from dual union all
				select 'User Rollback Undo Records Applied Per Txn' metric_name, 'User Rollback Undo Records Applied' short_name, 1 coeff, 2 typ,38 m_rank from dual
				) m
          where m.metric_name = s.metric_name)
      group by inst_id,begin_time,short_name,intsize_csec)
      group by inst_id,begintime,short_name,intsize_csec,per_sec,per_tx,m_rank
 order by inst_id,short_name,m_rank;
 

spool DBHeathcheck_RMANRpt_&&dbname&&timestamp&&suffix 
set lines 220
set pages 1000
col cf for 9,999
col df for 9,999
col elapsed_seconds heading "ELAPSED|SECONDS"
col i0 for 9,999
col i1 for 9,999
col l for 9,999
col start_time for a20
col end_time for a20
col dow for a10
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col session_recid for 999999 heading "SESSION|RECID"
col session_stamp for 99999999999 heading "SESSION|STAMP"
col status for a10 trunc
col time_taken_display for a10 heading "TIME|TAKEN"
col instance for 9999 heading "INST"
col HRS for 999

PROMPT ==============================================================================================
PROMPT == BACKUP DETAILS==
PROMPT ==============================================================================================

select
  to_char(j.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(j.end_time, 'yyyy-mm-dd hh24:mi:ss') end_time,
  (j.output_bytes/1024/1024) output_mbytes, j.status, j.input_type,
  decode(to_char(j.start_time, 'd'), 1, 'Sunday', 2, 'Monday',
                                     3, 'Tuesday', 4, 'Wednesday',
                                     5, 'Thursday', 6, 'Friday',
                                     7, 'Saturday') dow,
  round(j.elapsed_seconds/3600,1) HRS, j.time_taken_display,
  x.cf, x.df, x.i0, x.i1, x.l,
  ro.inst_id instance
from V$RMAN_BACKUP_JOB_DETAILS j
  left outer join (select
                     d.session_recid, d.session_stamp,
                     sum(case when d.controlfile_included = 'YES' then d.pieces else 0 end) CF,
                     sum(case when d.controlfile_included = 'NO'
                               and d.backup_type||d.incremental_level = 'D' then d.pieces else 0 end) DF,
                     sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                     sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1,
                     sum(case when d.backup_type = 'L' then d.pieces else 0 end) L
                   from
                     V$BACKUP_SET_DETAILS d
                     join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
                   where s.input_file_scan_only = 'NO'
                   group by d.session_recid, d.session_stamp) x
    on x.session_recid = j.session_recid and x.session_stamp = j.session_stamp
  left outer join (select o.session_recid, o.session_stamp, min(inst_id) inst_id
                   from GV$RMAN_OUTPUT o
                   group by o.session_recid, o.session_stamp)
    ro on ro.session_recid = j.session_recid and ro.session_stamp = j.session_stamp
where j.start_time > trunc(sysdate)-30
order by j.start_time;

PROMPT ==============================================================================================
PROMPT == BACKUP WITH OUTPUT AND INPUT SIZE==
PROMPT ==============================================================================================


col BeginTime for a20
column status format a10
column COMMAND_ID for a20
column time_taken_display format a10;
column input_bytes_display format a12;
column output_bytes_display format a12;
column output_bytes_per_sec_display format a10;
column ses_key format 9999999
column ses_recid format 9999999
column device_type format a10
column OutBytesPerSec for a13

SELECT to_char(b.start_time,'DD-MM-YY HH24:MI:SS') BeginTime,b.session_key ses_key,
b.session_recid ses_recid,
b.session_stamp,
b.command_id,
b.input_type,
b.status,
b.time_taken_display,
b.output_device_type device_type,
b.input_bytes_display,
b.output_bytes_display,
b.output_bytes_per_sec_display "OutBytesPerSec"
FROM v$rman_backup_job_details b
WHERE b.start_time > (SYSDATE - 30)
ORDER BY b.start_time;

PROMPT ==============================================================================================
PROMPT == BACKUP SIZE SET INFORMATION==
PROMPT ==============================================================================================

BREAK ON REPORT ON bs_key ON completion_time ON bp_name ON file_name
COL bs_key    FORM 99999 HEAD "BS Key"
COL bp_name   FORM a60   HEAD "BP Name"
COL file_name FORM a50   HEAD "Datafile"
--
SELECT
 s.recid                  bs_key
,TRUNC(s.completion_time) completion_time
,p.handle                 bp_name
,f.name                   file_name
FROM v$backup_set      s
    ,v$backup_piece    p
    ,v$backup_datafile d
    ,v$datafile        f
WHERE p.set_stamp = s.set_stamp
AND   p.set_count = s.set_count
AND   d.set_stamp = s.set_stamp
AND   d.set_count = s.set_count
AND   d.file#     = f.file#
ORDER BY
 s.recid
,p.handle
,f.name;

spool off

spool DBHeathcheck_DBAlert_&&dbname&&timestamp&&suffix 
select * from dbA_alert_history;
spool off

spool DBHeathcheck_Parameter_&&dbname&&timestamp&&suffix 
select substr(name, 0, 512) "Name", nvl(substr(value, 0, 512), '') "Value", isdefault "Default", ismodified "Modified" from v$parameter order by name;
spool off

spool DBHeathcheck_Degree_&&dbname&&timestamp&&suffix 
select distinct degree from dba_tables;
select distinct degree from dbA_indexes;
select degree,table_name ,owner from dbA_tables where degree <> '1' order by owner,degree,table_name;
spool off

spool DBHeathcheck_ResourceLimit_&&dbname&&timestamp&&suffix 
select * from v$resource_limit;
spool off

set markup html off spool off
host zip -m DBHeathcheck&&dbname&&timestamp DBHeathcheck*.xls 
host rm DBHeathcheck*.xls