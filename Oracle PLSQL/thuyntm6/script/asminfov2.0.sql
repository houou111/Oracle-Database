--------------------------------------------------------------------------------
--
-- File name:   asminfo.sql v1.8
--
-- Purpose:     Oracle ASM information collection script
--
-- Authors:     Sandeep Redkar and Deepak Kenchappanavara
-- Copyright:   (c) http://www.ibm.com
--              
-- Usage:       Login as sysdba and run asminfo.sql script
--              $sqlplus "/as sysasm" (In case of 11gR2 and above)
--				$sqlplus "/as sysdba" (In case of 10g and above)
--              SQL>@asminfo.sql
--              
--          
-- Other:       This script will collect ASM configuration details.
--
--              Script will generate a html file which will have name as follows:
--              asmreport_<ASM Instance Name>_<Date>.html
--              Share output html file with IBM team for analysis
--------------------------------------------------------------------------------

set lines 300 pages 50000 trims on feed off termout off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col rep_name new_value rep_name
select 'asmreport_' || instance_name || '_' || to_char(sysdate,'DDMONYYYY') || '.html' rep_name from v$instance;

set termout on
prompt
prompt This script will generate &rep_name File.
prompt
prompt Please wait...
set termout off

spool &rep_name

prompt <style type='text/css'>
prompt body {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt p {font:bold 11pt Arial,Helvetica,sans-serif; color:#336699; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt table,tr,td {font:8pt Arial,Helvetica,Geneva,sans-serif;color:black;background:#FFFFCC; vertical-align:top;}
prompt th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:White; background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px}
prompt h1 {font:14pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99;
prompt  margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt </style><title>ASM Report</title>
prompt <BR><BR><H1><center>ASM Information Report</center></H1>
prompt <HR>


set head off pages 0;
select 'Report Generated on : ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') from dual;
select '<p>' from dual;
set head on pages 50000;

set markup HTML on HEAD "<title>ASM Information Report</title>" BODY "BGCOLOR=RED" TABLE "border='1'" SPOOL OFF ENTMAP ON PREFORMAT OFF

Prompt
Prompt Instance Details
Prompt
select instance_number inst_no, instance_name, host_name, startup_time, thread#, database_status from gv$instance;


Prompt
Prompt ASM Version Details
Prompt
select banner "Database Component Details" from v$version;

Prompt
Prompt Diskgroup Details
Prompt
select NAME,STATE,TYPE REDUNDANCY_LEVEL,SECTOR_SIZE,BLOCK_SIZE,ALLOCATION_UNIT_SIZE,COMPATIBILITY,DATABASE_COMPATIBILITY,TOTAL_MB/1024 as DG_TOTAL_SIZE,(TOTAL_MB-FREE_MB)/1024 as DG_USED_SIZE,FREE_MB/1024 as DG_FREE_SIZE from V$ASM_DISKGROUP_STAT order by 1;

Prompt
Prompt ASM Disk Details
Prompt
select a.GROUP_NUMBER as GRP_NUMBER,b.NAME as DG_NAME,a.PATH,a.TOTAL_MB/1024 AS DISK_SIZE_IN_GB,a.FREE_MB/1024 AS FREE_DISK_SPACE 
from v$asm_disk_stat a, v$asm_diskgroup_stat b where a.GROUP_NUMBER=b.GROUP_NUMBER order by GRP_NUMBER;

Prompt
Prompt ASM Client Details
Prompt
select a.GROUP_NUMBER,b.NAME as DG_NAME,a.INSTANCE_NAME as INST_NAME,a.DB_NAME as DB_NAME,a.STATUS from v$asm_client a, v$asm_diskgroup_stat b where a.GROUP_NUMBER=b.GROUP_NUMBER;

Prompt
Prompt Initialization parameters having non-default values
Prompt
select name, value from v$parameter where ISDEFAULT <> 'TRUE' order by name;

Prompt
Prompt Cluster Interconnects
Prompt
select * from gv$CLUSTER_INTERCONNECTS ;

Prompt
spool off;

host echo '<p>Host Name Details' >> &rep_name 
host echo '<pre>' >> &rep_name 
host uname -a >> &rep_name 
host echo '</pre>' >> &rep_name 

host echo '<p>Applied Patches (OPatch)' >> &rep_name 
host echo '<pre>' >> &rep_name 
host $ORACLE_HOME/OPatch/opatch lsinventory >> &rep_name 
host echo '</pre>' >> &rep_name 

host echo '<p>OS Mount point layout' >> &rep_name 
host echo '<pre>' >> &rep_name 
host df -k >> &rep_name 
host echo '</pre>' >> &rep_name 

host echo '<p>Current OS User Details' >> &rep_name 
host echo '<pre>' >> &rep_name 
host id >> &rep_name 
host echo '</pre>' >> &rep_name 

host echo '<p>Configured IP Details' >> &rep_name 
host echo '<pre>' >> &rep_name 
host ifconfig -a >> &rep_name 
host echo '</pre>' >> &rep_name 

set markup html off;
SET PAGES 0 HEAD OFF FEED OFF;
select '<BR><BR>' FROM DUAL;
SET PAGES 50000 HEAD ON FEED ON;

set termout on
prompt Done.
prompt Please check &rep_name file for errors, if any.
prompt 
