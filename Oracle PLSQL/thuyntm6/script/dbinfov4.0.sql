--------------------------------------------------------------------------------
--
-- File name:   dbinfo.sql v3.2
--
-- Purpose:     Oracle Database information collection script
--
-- Authors:     Sandeep Redkar and Deepak Kenchappanavara
-- Copyright:   (c) http://www.ibm.com
--              
-- Usage:       Login as sysdba and run dbinfo.sql script
--              $sqlplus "/as sysdba"
--              SQL>@dbinfo.sql
--              
--          
-- Other:       This script will collect database and ASM configuration details.
--              Script will also collect schema details which is required for  
--              database performance analysis.
--
--              Script will generate a html file which will have name as follows:
--              dbreport_<DB Name>_<Date>.html
--              Share output html file with IBM team for analysis
--------------------------------------------------------------------------------

set lines 300 pages 50000 trims on feed off termout off time off timi off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
col rep_start_time new_value rep_start_time
select sysdate rep_start_time from dual;

col rep_name new_value rep_name
select 'dbreport_' || instance_name || '_' || to_char(sysdate,'DDMONYYYY') || '.html' rep_name from v$instance;

set termout on
prompt
prompt This script will generate &rep_name File.
prompt
prompt Please wait...
set termout off

spool &rep_name

prompt <style type='text/css'>
prompt div#left  {width:20%; height: 87%;  position: absolute; outline: 0px solid; overflow:auto; top: 90px}
prompt div#right {width:78%; height: 87%;  position: absolute; outline: 0px solid; overflow:auto; top: 90px; right: 0; }
prompt div#top   {width:100%;height: 90px; position: absolute; outline: 0px solid; top:0px;left:0px; top: 0px;}
prompt div#wrapper {top:80px;left:0px;right:0px;bottom:0px;}

prompt body {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt p {font:bold 11pt Arial,Helvetica,sans-serif; color:#336699; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt table,tr,td {font:8pt Arial,Helvetica,Geneva,sans-serif;color:black;background:#FFFFCC; vertical-align:top;}
prompt th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:White; background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px}
prompt h1 {font:14pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99;
prompt  margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h2 {font:bold 11pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt h3 {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt h4 {font:bold 6pt Arial,Helvetica,sans-serif;color:#663300; vertical-align:top;margin-top:0pt; margin-bottom:0pt;}
prompt h5 {font:italic bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt </style><title>DB Info Report</title>

prompt <div id="top">
prompt <BR><H1><center>Database Information Report</center></H1>
prompt <HR>
set head off pages 0;
select 'Report Generated on : ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || ' with version v4.0' from dual;
prompt </div>

prompt <div id="wrapper">

prompt <div id="left">
prompt <Br><a name="topsec"></a>
prompt <H2>Features Covered in Report</H2>

prompt <ul>
prompt <h5><li><a href="#sec00"><h5>Server Details</h5></a></h5>
prompt <h5><li>Database Configuration</h5>
prompt <ul>
prompt <li><a href="#sec01">Database Details</a>
prompt <li><a href="#sec02">Database Properties</a> 
prompt <li><a href="#sec07">Control File Details</a>
prompt <li><a href="#sec08">Redo Log File Locations</a>
prompt <li><a href="#sec11">Redo Generation per Day</a>
prompt <li><a href="#sec09">Data Files Details</a>
prompt <li><a href="#sec10">Tablespace Usage</a>
prompt <li><a href="#sec15">Resource Utilization</a>
prompt <li><a href="#sec18">Non-Default Init parameters</a>
prompt <li><a href="#sec20">DB Links Information</a>
prompt <li><a href="#sec25">Scheduled Jobs</a>
prompt <li><a href="#sec25a">Database Services</a>
prompt </ul>
prompt <h5><li>Object / Segment level information</h5>
prompt <ul>
prompt <li><a href="#sec06">Object Count by Schema, Object Type</a>
prompt <li><a href="#sec04">Foreign Key Constraints in All Schemas</a>
prompt <li><a href="#sec16">Tables having LOB Columns</a>
prompt <li><a href="#sec17">Table Details of LOBs</a>
prompt <li><a href="#sec26">Table Fragmentation</a>
prompt <li><a href="#sec14">Object Statistics</a>
prompt <li><a href="#sec12">Debug Enabled Objects</a>
prompt <li><a href="#sec13">Compression Usage</a>
prompt </ul>
prompt <h5><li>Database memory statistics</h5>
prompt <ul>
prompt <li><a href="#sec19">SGA Resize Details</a>
prompt <li><a href="#sec23">Shared pool information</a>
prompt </ul>
prompt <h5><li>Database features, options and patch details</h5>
prompt <ul>
prompt <li><a href="#sec03">Database Features Used</a>
prompt <li><a href="#sec05">Database Options Installed</a>
prompt <li><a href="#sec05a">Database Registry</a>
prompt <li><a href="#sec05b">Database Applied PSUs</a>
prompt <li><a href="#sec29">Applied Patches (OPatch)</a>
prompt </ul>
prompt <h5><li>Database backup and Corruption details
prompt <ul>
prompt <li><a href="#sec22">RMAN backup information</a>
prompt <li><a href="#sec21">DB Corruption</a>
prompt <li><a href="#sec21a">Block Change Tracking</a>
prompt </ul>
prompt <h5><li>ASM and OS information</h5>
prompt <ul>
prompt <li><a href="#sec27">ASM Diskgroup Details</a>
prompt <li><a href="#sec28">ASM Disk Details</a>
prompt <li><a href="#sec30">Filesystem Information</a>
prompt <li><a href="#sec31">OS Environment Details</a>
prompt <li><a href="#sec32">Database OS ID</a>
prompt <li><a href="#sec33">Server /etc/hosts File</a>
prompt <li><a href="#sec34">PMON running processes</a>
prompt </ul>
prompt </ul>
prompt </div>

Prompt <div id="right">

Prompt <a name="sec00"></a><p>
select '<p>' from dual;
set head on pages 50000;
set markup HTML on HEAD "<title>SQL*Plus Report</title>" TABLE "border='1'" SPOOL OFF ENTMAP ON PREFORMAT OFF

Prompt
prompt Server Details
Prompt
select HOST_NAME "Host Name",(select value from v$osstat where STAT_NAME like 'NUM_CPU_CORES') "Cores",
(select value from v$osstat where STAT_NAME like 'NUM_CPUS') "CPUs",
(select round(value/1024/1024/1024,2) from v$osstat where STAT_NAME like 'PHYSICAL_MEMORY_BYTES') "Memory(GB)" from v$instance;

Prompt
Prompt Instance Details
Prompt
select instance_number inst_no, instance_name, host_name, startup_time, thread#, database_status, parallel as "RAC" from gv$instance;

Prompt
Prompt Database Version Details
Prompt
select banner "Database Component Details" from v$version;

Prompt
Prompt Database Allocated Size
Prompt
select round(sum(bytes)/1024/1024/1024,2) "DB Size(GB)" from v$datafile;

set markup HTML off
set markup HTML on

Prompt
set markup HTML off
Prompt </a><a name="sec01"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Details
Prompt
select name db_name, log_mode, database_role, LPAD(force_logging,10) force_logging, 
	LPAD(supplemental_log_data_min,10) SupLog_Min, 
	lpad(supplemental_log_data_pk,10) SUPLOG_PK,
	LPAD(supplemental_log_data_ui,10) SUPLOG_UI, 
	LPAD(supplemental_log_data_fk,10) SUPLOG_FK, 
	LPAD(supplemental_log_data_all,10) "SUPLOG_ALL",
	to_char(created, 'MM-DD-YYYY HH24:MI:SS') Created,
	PLATFORM_NAME, FLASHBACK_ON
from v$database;

set markup HTML off
Prompt <a name="sec02"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Properties
Prompt 
SELECT property_name,
       property_value
FROM   database_properties
ORDER BY property_name;

set markup HTML off
Prompt <a name="sec07"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Control File Details
Prompt
select * from v$controlfile;


set markup HTML off
Prompt <a name="sec08"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Redo Log File Locations
Prompt
select a.group#,b.thread#,a.member,b.bytes/1024/1024 as size_mb, (select block_size from v$archived_log where rownum<=1) block_size_bytes
from   	v$logfile a,
		(select group#, thread#, bytes from v$log union all select group#, thread#, bytes from v$standby_log) b
where a.group#=b.group#
order by b.thread#, a.group#;

set markup HTML off
Prompt <a name="sec11"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Redo Generation per Day
Prompt
select trunc(completion_time) rundate, THREAD# "Instance", count(*) logswitches, round((sum(blocks*block_size)/1024/1024/1024)) "Redo/day (GB)"
from   v$archived_log
where trunc(completion_time) >= trunc(sysdate-15)
and   dest_id = 1
group by trunc(completion_time), THREAD#
order by 1;
prompt
SELECT instance "Instance#",
       log_date "DATE" ,
       lpad(to_char(NVL( COUNT( * ) , 0 )),6,' ') Total,
       lpad(to_char(NVL( SUM( decode( log_hour , '00' , 1 ) ) , 0 )),3,' ') h00 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '01' , 1 ) ) , 0 )),3,' ') h01 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '02' , 1 ) ) , 0 )),3,' ') h02 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '03' , 1 ) ) , 0 )),3,' ') h03 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '04' , 1 ) ) , 0 )),3,' ') h04 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '05' , 1 ) ) , 0 )),3,' ') h05 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '06' , 1 ) ) , 0 )),3,' ') h06 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '07' , 1 ) ) , 0 )),3,' ') h07 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '08' , 1 ) ) , 0 )),3,' ') h08 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '09' , 1 ) ) , 0 )),3,' ') h09 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '10' , 1 ) ) , 0 )),3,' ') h10 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '11' , 1 ) ) , 0 )),3,' ') h11 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '12' , 1 ) ) , 0 )),3,' ') h12 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '13' , 1 ) ) , 0 )),3,' ') h13 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '14' , 1 ) ) , 0 )),3,' ') h14 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '15' , 1 ) ) , 0 )),3,' ') h15 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '16' , 1 ) ) , 0 )),3,' ') h16 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '17' , 1 ) ) , 0 )),3,' ') h17 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '18' , 1 ) ) , 0 )),3,' ') h18 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '19' , 1 ) ) , 0 )),3,' ') h19 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '20' , 1 ) ) , 0 )),3,' ') h20 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '21' , 1 ) ) , 0 )),3,' ') h21 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '22' , 1 ) ) , 0 )),3,' ') h22 ,
       lpad(to_char(NVL( SUM( decode( log_hour , '23' , 1 ) ) , 0 )),3,' ') h23  
FROM   (
        SELECT thread# INSTANCE ,
               TO_CHAR( first_time , 'DD-MON-YY' ) log_date ,
               TO_CHAR( first_time , 'hh24' ) log_hour 
        FROM   v$log_history 
		where  trunc(first_time) >= trunc(sysdate-32)
       ) 
GROUP  BY INSTANCE ,
       log_date 
ORDER  BY INSTANCE ,
       to_date(log_date,'DD-MON-YY'); 

	   

set markup HTML off
Prompt <a name="sec09"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Data Files Details
Prompt
select F.file_id "FILE#",
       F.tablespace_name tablespace,       
       F.file_name,
       F.bytes/(1024*1024) size_mb,
       decode(F.status,'AVAILABLE','OK',F.status) status, AUTOEXTENSIBLE, MAXBYTES/1024/1024/1024 "Max bytes (GB)"
from   sys.dba_data_files F
order by tablespace_name, FILE#;

set markup HTML off
Prompt <a name="sec10"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Tablespace Usage
Prompt
column segment_space_management heading "Segment|Space|Management"
column FORCE_LOGGING  heading "Force|Logging"
column compress_for heading "Compress|For"
column ENCRYPTED for a11 heading 'Encryption|Enabled'
column EXTENT_MANAGEMENT for a11 heading "Extent|Mgmt"
column bigfile for a10 heading "BigFile|TBS"
select a.tablespace_name,
        round(nvl(a.asize,0)) "TOTAL (GB)",
        round(nvl(a.asize-nvl(f.free,0),0)) "USED (GB)",
        round(nvl(f.free,0)) "FREE (GB)", 
        round(((nvl(a.asize-f.free,0))/a.asize)*100) "USED %",
        round((nvl(f.free,0)/a.asize)*100) "FREE %",
		t.block_size, t.status, t.contents, t.EXTENT_MANAGEMENT, t.FORCE_LOGGING, t.BIGFILE, t.SEGMENT_SPACE_MANAGEMENT, t.ENCRYPTED, t.COMPRESS_FOR
from    (select tablespace_name, sum(bytes)/1024/1024/1024 "ASIZE"
        from    dba_data_files group by tablespace_name
		union all
		select tablespace_name, sum(bytes)/1024/1024/1024 "ASIZE"
        from    dba_temp_files group by tablespace_name) a,
        (select tablespace_name, round(sum(bytes/(1024*1024*1024))) free,round(max(bytes)/1024/1024/1024) maxfree
        from    dba_free_space
        group by tablespace_name) f,
		dba_tablespaces t
WHERE      a.tablespace_name = f.tablespace_name(+)
and 	a.tablespace_name = t.tablespace_name
order by 1;

set markup HTML off
Prompt <a name="sec15"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Resource Utilization
Prompt
select * from gv$resource_limit;

set markup HTML off
Prompt <a name="sec18"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Non-Default Init parameters
Prompt
select name "Parameter Name", value "Value" from v$parameter where ISDEFAULT <> 'TRUE' order by name;

set markup HTML off
Prompt <a name="sec20"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt DB Links Information
Prompt
select * from dba_db_links;

set markup HTML off
Prompt <a name="sec25"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Scheduled Jobs
Prompt
col  NLS_ENV  noprint
select * from dba_scheduler_jobs;   
Prompt
select * from dba_jobs;   

set markup HTML off
Prompt <a name="sec25a"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Services
Prompt
select service_id, name, network_name, creation_date,  FAILOVER_METHOD ,  FAILOVER_TYPE , GOAL, CLB_GOAL from dba_services;
	   
set markup HTML off
Prompt <a name="sec06"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Object Count by Schema, Object Type
Prompt
select owner, tables, indexes, part_tables, part_indexes, triggers, views, lobs, pl_sqls, 
	   total_objects - (tables + indexes + part_tables + part_indexes + triggers + views + lobs + pl_sqls) other_objects,
	   total_objects
from
(	   
select o.owner, 
    count(case when object_type='TABLE' then 1 end) tables,
	count(case when object_type='INDEX' then 1 end) indexes,
	count(case when object_type LIKE 'TABLE%PARTITION%' then 1 end) part_tables,
	count(case when object_type LIKE 'INDEX%PARTITION%' then 1 end) part_indexes,
	count(case when object_type = 'TRIGGER' then 1 end) triggers,
	count(case when object_type = 'VIEW' then 1 end) views,
	count(case when object_type = 'LOB' then 1 end) lobs,
	count(case when object_type in ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY') then 1 end) pl_sqls,
	count(1) total_objects
from dba_objects o
WHERE o.OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM') 
group by o.owner
)
order by owner;

set markup HTML off
Prompt <a name="sec04"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Foreign Key Constraints in All Schemas 
Prompt
SELECT OWNER, table_name, constraint_name, CONSTRAINT_TYPE, INDEX_NAME, R_OWNER, R_CONSTRAINT_NAME
FROM dba_constraints
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM','PUBLIC') 
and constraint_type = 'R'
order by owner; 

set markup HTML off
Prompt <a name="sec16"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Tables having LOB Columns

col lob_cnt new_value lob_cnt
col lob_cnt noprint
select count(1) || case when count(1) > 100 then ' (output truncated to 100 rows)' end lob_cnt 
FROM all_tab_columns
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','OJVMSYS',
	'DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC','GSMADMIN_INTERNAL','ORDDATA',
	'SQLTXPLAIN','SQLTXADMIN','APEX_040200','FLOWS_FILES','AUDSYS','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM')
AND data_type in ('CLOB', 'BLOB', 'LONG', 'LONG RAW', 'NCLOB', 'LOB');

set markup HTML off
prompt <pre> Total Lob Objects : &&lob_cnt </pre>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF

SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM all_tab_columns
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','OJVMSYS',
	'DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC','GSMADMIN_INTERNAL','ORDDATA',
	'SQLTXPLAIN','SQLTXADMIN','APEX_040200','FLOWS_FILES','AUDSYS','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM')
AND data_type in ('CLOB', 'BLOB', 'LONG', 'LONG RAW', 'NCLOB', 'LOB')
and rownum<=100
ORDER BY OWNER;

set markup HTML off
Prompt <a name="sec17"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Table Details of LOBs
Prompt
column format noprint
select * from dba_lobs 
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','OJVMSYS',
	'DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC','GSMADMIN_INTERNAL','ORDDATA',
	'APEX_040200','FLOWS_FILES','AUDSYS')
and rownum<=100
ORDER BY OWNER;

set markup HTML off
Prompt <a name="sec26"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Table Fragmentation
Prompt
select owner, table_name, tbl_size "Table Size(GB)", used_size "Used Size (GB)", frag_size "Fragmented Size (GB)", last_analyzed,
	round(frag_size/decode(tbl_size, 0, null, tbl_size)*100,1) "Fragmented %"
from
(
select table_name, owner, round(((blocks*(select value from v$parameter where name='db_block_size'))/1024/1024/1024),2) tbl_size, round((num_rows*avg_row_len/1024/1024/1024),2) used_size, 
(round(((blocks*(select value from v$parameter where name='db_block_size')/1024/1024/1024)),2)-round((num_rows*avg_row_len/1024/1024/1024),2)) frag_size, last_analyzed 
from dba_tables where 
owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','LBACSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC','GSMADMIN_INTERNAL','OJVMSYS','ORDDATA','DVSYS',
	'AUDSYS','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM')
and last_analyzed is not null 
and num_rows > 0 
and blocks >0 
)
where frag_size/decode(tbl_size, 0, null, tbl_size)*100 > 10
and tbl_size > 1
order by owner, 5 desc;


set markup HTML off
Prompt <a name="sec14"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Object Statistics
Prompt
SELECT owner, last_analyzed, sum(case when type='Table' then cnt end) tables, sum(case when type='Index' then cnt end) indexes
from
( 
select 'Table' Type, owner, to_char(trunc(last_analyzed),'DD-MON-YY') last_analyzed, count(1) cnt from dba_tables 
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM') 
group by owner, trunc(last_analyzed)
union
select 'Index' Type, owner, to_char(trunc(last_analyzed),'DD-MON-YY'), count(1) cnt from dba_indexes 
WHERE OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM') 
group by owner, trunc(last_analyzed)
)
group by owner, last_analyzed
order by owner;

set markup HTML off
Prompt <a name="sec12"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Debug Enabled Objects
Prompt
select OWNER,OBJECT_NAME,OBJECT_TYPE,LAST_DDL_TIME from sys.ALL_PROBE_OBJECTS where debuginfo='T' 
	and owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM'); 

set markup HTML off
Prompt <a name="sec13"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Compression Usage

col compress_cnt new_value compress_cnt
col compress_cnt noprint
select cnt1 + cnt2 || case when cnt1 + cnt2  > 100 then ' (output truncated to 100 rows)' end compress_cnt
FROM 
(select count(1) cnt1 from dba_tables where compression = 'ENABLED' and
owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM')), 
(select count(1) cnt2 from dba_indexes where compression = 'ENABLED' and
owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM'));

set markup HTML off
prompt <pre>Total Compressed Objects : &&compress_cnt  </pre>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF

select * from
(
select owner, 'TABLE' Type, table_name object_name, last_analyzed, compression, compress_for, blocks total_blocks from dba_tables where compression='ENABLED'
union all
select owner, 'INDEX' Type, index_name || ' (Table : ' || table_name || ')' object_name, last_analyzed, compression, 'N/A', leaf_blocks from dba_indexes where compression = 'ENABLED'
)
where owner not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','OJVMSYS','AUDSYS',
	'CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC', 'DVSYS', 'GSMADMIN_INTERNAL','LBACSYS','ORDDATA',
	'APEX_040200','AUDSYS','FLOWS_FILES','SCOTT','SI_INFORMTN_SCHEMA','APPQOSSYS','ORACLE_OCM')
and rownum <= 100
order by type, owner;

set markup HTML off
Prompt <a name="sec19"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt SGA Resize Details
Prompt
select component, oper_type, oper_mode, parameter, initial_size/1024/1024 "Initial (MB)", 
		target_size/1024/1024 "Target (MB)", final_size/1024/1024 "Final Size (GB)", status, start_time, end_time 
from v$sga_resize_ops;

set markup HTML off
Prompt <a name="sec23"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Shared pool information
Prompt
select * from x$kghlu;
Prompt
select * from v$shared_pool_reserved;

set markup HTML off
Prompt <a name="sec03"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Features Used
Prompt
column CURRENTLY_USED heading "Currently|Used"
SELECT NAME "Database Feature", DETECTED_USAGES, CURRENTLY_USED || '     ' CURRENTLY_USED, FIRST_USAGE_DATE, LAST_USAGE_DATE
FROM DBA_FEATURE_USAGE_STATISTICS
WHERE VERSION = (SELECT VERSION FROM V$INSTANCE) AND
(DETECTED_USAGES > 0 OR CURRENTLY_USED != 'FALSE');

set markup HTML off
Prompt <a name="sec05"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Options Installed
Prompt
column PARAMETER heading "Database|Option"
select * from v$option order by 1;

set markup HTML off
Prompt <a name="sec05a"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database Options Installed
Prompt
select comp_name, version, status, modified from dba_registry order by 1;

set markup HTML off
Prompt <a name="sec05b"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Database applied PSUs 
Prompt
select * from registry$history;

set markup HTML off
Prompt <a name="sec22"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt RMAN backup information
Prompt
select DISTINCT c.name, decode(BACKUP_TYPE,'D','DB INCR BACKUP LEVEL 0','I','DB INCR BACKUP LEVEL 1','L','ARCHIVELOG BACKUP',backup_type) backup1,
		decode(b.status,'COMPLETED','SUCCESSFUL','FAILED','FAILED','RUNNING','RUNNING','COMPLETED WITH WARNINGS') status,a.DEVICE_TYPE DEVICE_TYPE,
		B.START_TIME, B.end_time, b.TIME_TAKEN_DISPLAY elapse_time, (case WHEN backup_type = 'L' then round((sum(original_input_bytes) over(Partition by a.session_stamp,b.start_time,
		command_id,a.session_recid order by (b.start_time)))/1024/1024,1) ELSE NULL END) al_INPUT_BYTES_mb,
		(case WHEN backup_type in('D','I') then round((sum(original_input_bytes) over(Partition by a.session_stamp,b.start_time,command_id,
		a.session_recid order by (b.start_time)))/1024/1024,1) ELSE NULL END)  db_INPUT_BYTES_mb, round((sum(a.output_bytes) over(partition by 
		a.session_stamp,b.start_time,command_id,a.session_recid order by (b.start_time)))/1024/1024,2) output_bytes_mb
from 	V$BACKUP_SET_DETAILS a,
	V$rman_backup_job_details b,
	V$database c
where 	a.session_recid=b.session_recid
and 	a.session_stamp=b.session_stamp
and 	b.start_time >= trunc(sysdate-32)
order by B.start_time  desc;
	   
set markup HTML off
Prompt <a name="sec21"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt DB Corruption
Prompt
select * from v$database_block_corruption;

Prompt Backup Corruption
Prompt
select * from v$backup_corruption;

set markup HTML off
Prompt <a name="sec21a"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt Block Change Tracking
Prompt
select * from v$block_change_tracking;

set markup HTML off
Prompt <a name="sec27"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt ASM Diskgroup Details
Prompt
column DG_TOTAL_SIZE heading "DG Total Size | (in GB)"
column DG_USED_SIZE heading "DG Used Size | (in GB)"
column DG_FREE_SIZE heading "DG Free Size | (in GB)"
column DGNAME heading "Diskgroup Name"
select NAME DGNAME,STATE,TYPE REDUNDANCY_LEVEL,SECTOR_SIZE,BLOCK_SIZE,ALLOCATION_UNIT_SIZE,COMPATIBILITY,DATABASE_COMPATIBILITY,
TOTAL_MB/1024 as DG_TOTAL_SIZE, (TOTAL_MB-FREE_MB)/1024 as DG_USED_SIZE, FREE_MB/1024 as DG_FREE_SIZE from V$ASM_DISKGROUP_STAT order by 1;

set markup HTML off
Prompt <a name="sec28"></a><br><p>
set markup HTML on SPOOL OFF ENTMAP ON PREFORMAT OFF
Prompt ASM Disk Details
Prompt
col DG_NAME format a40
col PATH format a30
select a.GROUP_NUMBER as GRP_NUMBER,b.NAME as DG_NAME,a.PATH,a.TOTAL_MB/1024 AS DISK_SIZE_IN_GB,a.FREE_MB/1024 AS FREE_DISK_SPACE from v$asm_disk_stat a, v$asm_diskgroup_stat b where a.GROUP_NUMBER=b.GROUP_NUMBER order by GRP_NUMBER;

set markup html off;

SET PAGES 0 HEAD OFF FEED OFF;
select '<BR><BR>' FROM DUAL;
SET PAGES 50000 HEAD ON FEED ON;

spool off;

host echo '<a name="sec30"></a><br><p>' >> &rep_name 
host echo 'Filesystem Details' >> &rep_name 
host echo '<pre>' >> &rep_name 
host df -k >> &rep_name 

host echo '<a name="sec29"></a><br><p>' >> &rep_name 
host echo 'Applied Patches (OPatch)' >> &rep_name 
host echo '<pre>' >> &rep_name 
host $ORACLE_HOME/OPatch/opatch lsinventory >> &rep_name 
host echo '</pre>' >> &rep_name 

host echo '<a name="sec31"></a><br><p>' >> &rep_name 
host echo 'OS Environment Details' >> &rep_name 
host echo '<pre>' >> &rep_name 
host env >> &rep_name 

host echo '<a name="sec32"></a><br><p>' >> &rep_name 
host echo 'Database OS ID' >> &rep_name 
host echo '<pre>' >> &rep_name 
host id >> &rep_name 

host echo '<a name="sec33"></a><br><p>' >> &rep_name 
host echo 'Server /etc/hosts File' >> &rep_name 
host echo '<pre>' >> &rep_name 
host cat /etc/hosts >> &rep_name 

host echo '<a name="sec34"></a><br><p>' >> &rep_name 
host echo 'PMON running processes' >> &rep_name 
host echo '<pre>' >> &rep_name 
host ps -ef | grep pmon | grep -v grep >> &rep_name 

col time_taken new_value time_taken
select  'Report Genration took : ' || trunc( (sysdate - to_date('&&rep_start_time','DD-MON-YY HH24:MI:SS'))*24 ) || ' Hrs, ' || 
	    trunc(mod((sysdate - to_date('&&rep_start_time','DD-MON-YY HH24:MI:SS'))*24*60, 60)) ||' Mins, '||
	    trunc(mod((sysdate - to_date('&&rep_start_time','DD-MON-YY HH24:MI:SS'))*24*60*60, 60)) || ' Secs.' time_taken from dual;

host echo '<pre>' >> &rep_name 
host echo '<pre>' >> &rep_name 
host echo &&time_taken >> &rep_name 
		
host echo '</div>' >> &rep_name
host echo '</div>' >> &rep_name
		
set termout on
prompt Done.
prompt Please check &rep_name file for errors, if any.
prompt 
