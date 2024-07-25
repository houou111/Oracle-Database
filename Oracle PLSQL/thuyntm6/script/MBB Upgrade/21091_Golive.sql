--1.Stop application
=====================================================

--2.Purge recycle bin. Lock service user on both old and new database. Read only tablespace on old database, stop all job in old database. 
=====================================================
--pack base line to export to new database
--[OLD DB]
BEGIN
 DBMS_SPM.CREATE_STGTAB_BASELINE(
 table_name => 'SPM_STAGE_TABLE',
 table_owner => 'DBA01',
 tablespace_name => 'USERS');
END;
/


SET SERVEROUTPUT ON
DECLARE
 l_plans_packed PLS_INTEGER;
BEGIN
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_d549c654f1b56c91', plan_name => 'SQL_PLAN_dakf6amsvav4j178e9a0f');
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_163fff2b7b9a972e', plan_name => 'SQL_PLAN_1cgzz5dxtp5tf3ec7070b');
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_e97df57e8a51097c', plan_name => 'SQL_PLAN_fkzgpgu5522bwf2470ba2');
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_53146ee95a49c844', plan_name => 'SQL_PLAN_5653fx5d4mk24178e9a0f');
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_6a458c639c67f065', plan_name => 'SQL_PLAN_6njcccff6gw35f57bea6d');
l_plans_packed := DBMS_SPM.pack_stgtab_baseline( 'SPM_STAGE_TABLE', 'DBA01', sql_handle => 'SQL_c82c2522138fb8ed', plan_name => 'SQL_PLAN_chb15489szf7df2470ba2');
END;
/

set linesize 1000
set pagesize 10
SELECT  'l_plans_packed := DBMS_SPM.pack_stgtab_baseline( ''SPM_STAGE_TABLE'', ''DBA01'', sql_handle => '''||sql_handle||''', plan_name => '''||plan_name||''');' 
from dba_sql_plan_baselines;


expdp \"/ as sysdba\" dumpfile=SPM_STAGE_TABLE.dmp logfile=SPM_STAGE_TABLE.log directory=DATA_PUMP_DIR tables=DBA01.SPM_STAGE_TABLE

--[NEW DB]
impdp \"/ as sysdba\" dumpfile=SPM_STAGE_TABLE.dmp logfile=imp_SPM_STAGE_TABLE.log directory=UPGR_PUMP_12C 
"

DECLARE
 l_plans_unpacked PLS_INTEGER;
BEGIN
 l_plans_unpacked := DBMS_SPM.unpack_stgtab_baseline(
 table_name => 'SPM_STAGE_TABLE',
 table_owner => 'DBA01');
END;
/

SELECT  sql_handle,plan_name,enabled,accepted,fixed from dba_sql_plan_baselines;

=================================
--[OLD database]
purge recyclebin;
alter user MOBR5 account lock;
alter user SRV_DWH_MBB account lock;
alter tablespace USERS read only;
alter system set JOB_QUEUE_PROCESSES=0 scope=both sid='*';

--get ddl of sequence
set long 100000
select 'ALTER SEQUENCE '||sequence_name||' START  WITH  '||last_number||';' from dba_sequences where sequence_owner='MOBR5';

--3.Export tables which do not have any constraints
=====================================================
--[ON NEW DB]
umount /stage

--[ON CURRENT DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

--export
expdp \"/ as sysdba\" dumpfile=SPM_STAGE_TABLE.dmp logfile=SPM_STAGE_TABLE.log directory=UPGR_PUMP tables=DBA01.SPM_STAGE_TABLE

expdp \"/ as sysdba\" dumpfile=remain_table_%u.dmp logfile=exp_remain_table.log directory=UPGR_PUMP schemas=MOBR5 cluster=n parallel=4 include=TABLE:\"IN\(select table_name from dba_tables where owner=\'MOBR5\' and table_name not in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\)  and owner=\'MOBR5\'\) and table_name not    IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\)\" 

"
--4.Decrease vCpu on old database and increase vCPU on new database
=====================================================

--5.Check GoldenGate sync status. And stop sync.
=====================================================
--switchlog
alter system archive log current;

--check sync
GGSCI> info all
GGSCI> stop EX_P1
GGSCI> stop EX_S1
--on target
GGSCI> stop RE_S1
GGSCI> stop REP1

--enable trigger and constraint

--6.Import tables which do not have any constraints
=====================================================
--[ON NEW DB]
umount /stage

--[ON CURRENT DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

--import 
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=remain_table_%u.dmp logfile=imp_remain_table.log parallel=4 remap_tablespace=USERS:MOBR5
impdp \"/ as sysdba\" dumpfile=SPM_STAGE_TABLE.dmp logfile=imp_SPM_STAGE_TABLE.log directory=UPGR_PUMP_12C 
"

--unpack baseline
DECLARE
 l_plans_unpacked PLS_INTEGER;
BEGIN
 l_plans_unpacked := DBMS_SPM.unpack_stgtab_baseline(
 table_name => 'SPM_STAGE_TABLE',
 table_owner => 'DBA01');
END;
/

SELECT  sql_handle,plan_name,enabled,accepted,fixed from dba_sql_plan_baselines;

--recreate sequence 
CREATE SEQUENCE MOBR5.SEQ_EVENT
  START WITH 84732958
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
CREATE SEQUENCE MOBR5.SEQ_ID_AUTHORISATION_CODE
  START WITH 200
  MAXVALUE 200
  MINVALUE 0
  CYCLE
  CACHE 100
  NOORDER;
  CREATE SEQUENCE MOBR5.SEQ_ID_ENTITY
  START WITH 175301121
  MAXVALUE 9999999999999999999999999999
  MINVALUE 10000001
  NOCYCLE
  CACHE 50
  NOORDER;
GRANT SELECT ON MOBR5.SEQ_ID_ENTITY TO SRV_DWH_MBB;
CREATE SEQUENCE MOBR5.SEQ_TCB_TRACE_NO
  START WITH 266782256
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


--7.Check row count between two environment
=====================================================
--run below script [on OLD database]
vi  obj_count_main.sql
set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool obj_row_count.sql
prompt spool obj_row_count_output.log
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 20) */ ' end
        || ' rpad(''' || owner ||'.'||table_name || ''',60) tab_name, count(1) cnt from ' || owner || '."' || table_name || '" a;' 
from 
(select owner, table_name, blocks from dba_tables where owner not in 
('ORDDATA','SYSMAN','APEX_030200','OWBSYS_AUDIT','OUTLN','OWBSYS','SCOTT','FLOWS_FILES','OE',
'OLAPSYS','MDDATA','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'PUBLIC','SYSTEM','APPQOSSYS','XDB','SYS','MDSYS','EXFSYS','SI_INFORMTN_SCHEMA','ORACLE_OCM',
'WMSYS','ORDSYS','CTXSYS','ORDPLUGINS','DBSNMP'
,'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT','GSMADMIN_INTERNAL')
and table_name not in ('AMS_BOOKINGS_HIST','AMS_DOCS_20170530','AMS_DOCS_HIST','AMS_PI_BALANCES_20170530','AMS_PI_BALANCES_HIST','EVT_ENTRY_DATA_OLD',
'EVT_ENTRY_HANDLER_HIST2','EVT_ENTRY_HANDLER_OLD','EVT_ENTRY_HIST2','EVT_ENTRY_OLD','MOB_AUDIT_LOGS_HIST','MOB_BENEFICIARIES_201810',
'MOB_CUS_BK20181115','MOB_CUSTOMERS_IDEN_BK','MOB_FEES_20170530','MOB_FEES_HIST','MOB_INV_TXNS_20170530','MOB_INV_TXNS_HIST','MOB_SESSIONS_HIST',
'MOB_SUB_TXNS_20170530','MOB_SUB_TXNS_HIST','MOB_TXN_ATTRIBUTES_20170530','MOB_TXN_ATTRIBUTES_HIST','MOB_TXNS_20170530','MOB_TXNS_HIST',
'MOB_USE_CASE_PRIVILEGES_BK','TCB_CITAD_BANKS_BK','TCB_PIC_READ_20170116','TCB_PRIVATE_INBOX_20170116','TCB_PRIVATE_INBOX_HIST','TCB_PUBLIC_INBOX_20170116',
'TCB_PUBLIC_INBOX_CUSTOMER_HIST','TCB_PUBLIC_INBOX_HIST','EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS')
) order by owner, table_name;
prompt spool off;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('EVT_ENTRY_HANDLER') and partition_name in ('SYS_P4704') 
) order by table_owner, table_name;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('MOB_AUDIT_LOGS') and partition_name in ('SYS_P4901','SYS_P4941') 
) order by table_owner, table_name;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('MOB_TRACEABLE_REQUESTS') and partition_name in ('SYS_P4889','SYS_P4921') 
) order by table_owner, table_name;
spool off;
@obj_row_count.sql


--run below script [on NEW database]
vi  obj_count_main.sql
set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool obj_row_count.sql
prompt spool obj_row_count_output.log
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 20) */ ' end
        || ' rpad(''' || owner ||'.'||table_name || ''',60) tab_name, count(1) cnt from ' || owner || '."' || table_name || '" a;' 
from 
(select owner, table_name, blocks from dba_tables where owner not in 
('ORDDATA','SYSMAN','APEX_030200','OWBSYS_AUDIT','OUTLN','OWBSYS','SCOTT','FLOWS_FILES','OE',
'OLAPSYS','MDDATA','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'PUBLIC','SYSTEM','APPQOSSYS','XDB','SYS','MDSYS','EXFSYS','SI_INFORMTN_SCHEMA','ORACLE_OCM',
'WMSYS','ORDSYS','CTXSYS','ORDPLUGINS','DBSNMP'
,'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT','GSMADMIN_INTERNAL')
and table_name not in ('AMS_BOOKINGS_HIST','AMS_DOCS_20170530','AMS_DOCS_HIST','AMS_PI_BALANCES_20170530','AMS_PI_BALANCES_HIST','EVT_ENTRY_DATA_OLD',
'EVT_ENTRY_HANDLER_HIST2','EVT_ENTRY_HANDLER_OLD','EVT_ENTRY_HIST2','EVT_ENTRY_OLD','MOB_AUDIT_LOGS_HIST','MOB_BENEFICIARIES_201810',
'MOB_CUS_BK20181115','MOB_CUSTOMERS_IDEN_BK','MOB_FEES_20170530','MOB_FEES_HIST','MOB_INV_TXNS_20170530','MOB_INV_TXNS_HIST','MOB_SESSIONS_HIST',
'MOB_SUB_TXNS_20170530','MOB_SUB_TXNS_HIST','MOB_TXN_ATTRIBUTES_20170530','MOB_TXN_ATTRIBUTES_HIST','MOB_TXNS_20170530','MOB_TXNS_HIST',
'MOB_USE_CASE_PRIVILEGES_BK','TCB_CITAD_BANKS_BK','TCB_PIC_READ_20170116','TCB_PRIVATE_INBOX_20170116','TCB_PRIVATE_INBOX_HIST','TCB_PUBLIC_INBOX_20170116',
'TCB_PUBLIC_INBOX_CUSTOMER_HIST','TCB_PUBLIC_INBOX_HIST','EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS')
) order by owner, table_name;
prompt spool off;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('EVT_ENTRY_HANDLER') and partition_name in ('SYS_P4142') 
) order by table_owner, table_name;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('MOB_AUDIT_LOGS') and partition_name in ('SYS_P4143','SYS_P4151') 
) order by table_owner, table_name;
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('MOB_TRACEABLE_REQUESTS') and partition_name in ('SYS_P4137','SYS_P4148') 
) order by table_owner, table_name;
spool off;
@obj_row_count.sql

--> check by diff command

--8.Check object consistency beween two environment
=====================================================
--run below script [on BOTH database]
vi check_consistency.sql

col spfname new_value spfname
select 'data_consistency_' || name || '_' || host_name || '.log' spfname from v$database, v$instance;

set lines 200 pagesize 1000 trims on
spool &&spfname

select to_char(sysdate,'DD-MON-YY HH24:MI:SS') sdate, name, open_mode, host_name from v$database, v$instance;

prompt owner and object_type wise valid invalid count:
col owner for a20
set lines 300 pages 5000

select owner,object_type, count(case when status='VALID' THEN 1 end) valid, count(case when status<>'VALID' THEN 1 end) invalid, count(*) total
from dba_objects where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT')
group by owner,object_type order by owner,object_type;

prompt owner wise object count

select owner, count(case when status='VALID' THEN 1 end) valid, count(case when status<>'VALID' THEN 1 end) invalid, count(*) total
from dba_objects where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT')
group by owner
order by owner

prompt Constraint Status : 

select owner,constraint_type,count(*) from dba_constraints 
where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT')
group by owner,constraint_type
order by 1,2;

prompt Triger Status :

select status,count(*) from dba_triggers where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT')
group by status;

select to_char(sysdate,'DD-MON-YY HH24:MI:SS') from dual;

spool off


--> check by diff command
--9.Config app to connect to new database. Start application and check (without customer loging)
=====================================================

--10.Config to sync data from new database to old database. Ready to rollback if needed
=====================================================
--[on OLD database]
alter tablespace USERS read write;

--[on NEW DB] Prepare extract file 
GGSCI > dblogin userid ggate_user@mbbdb, password GGateUser#123

EXTRACT EX_S1
SETENV (ORACLE_SID="mbbdb1")
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
userid ggate_user@mbbdb, password GGateUser#123
TRANLOGOPTIONS DBLOGREADER
FETCHOPTIONS  FETCHPKUPDATECOLS, USESNAPSHOT, USELATESTVERSION
DBOPTIONS ALLOWUNUSEDCOLUMN
CACHEMGR CACHESIZE 500M
DISCARDFILE /gg_data/goldengate/dirrpt/ex_s1.dsc, APPEND, MEGABYTES 100
EXTTRAIL /gg_data/goldengate/dirdat/de
WARNLONGTRANS 1H, CHECKINTERVAL 1H

GGSCI > edit params EXT_S2
EXTRACT EXT_S2
SETENV (ORACLE_SID="mbbdb1")
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
userid ggate_user@mbbdb, password GGateUser#123
TRANLOGOPTIONS DBLOGREADER
FETCHOPTIONS  FETCHPKUPDATECOLS, USESNAPSHOT, USELATESTVERSION
DBOPTIONS ALLOWUNUSEDCOLUMN
CACHEMGR CACHESIZE 500M
DISCARDFILE /gg_data/goldengate/dirrpt/ext_s2.dsc, APPEND, MEGABYTES 100
EXTTRAIL /gg_data/goldengate/dirdat/be
WARNLONGTRANS 1H, CHECKINTERVAL 1H
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from below sql

select distinct 'TABLE MOBR5.'||table_name||';' from dba_constraints 
where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

GGSCI > edit params EXT_P2
EXTRACT EXT_P2
userid ggate_user@mbbdb, password GGateUser#123
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
RMTHOST 10.99.1.188, MGRPORT 7900
RMTTRAIL /gg_data/goldengate/dirdat/bp
DBOPTIONS ALLOWUNUSEDCOLUMN
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from above sql

GGSCI > register extract EXT_S2 database
GGSCI > ADD EXTRACT EXT_S2, integrated tranlog, BEGIN NOW 
GGSCI > add exttrail /gg_data/goldengate/dirdat/be,extract EXT_S2, megabytes 500
GGSCI > add extract EXT_P2, exttrailsource /gg_data/goldengate/dirdat/be
GGSCI > add rmttrail /gg_data/goldengate/dirdat/bp,extract EXT_P2, megabytes 500
GGSCI > start extract EXT_S2
GGSCI > start extract EXT_P2
GGSCI > info all

SYS@mbbdb_1 >    select to_char(current_scn) from v$database;

TO_CHAR(CURRENT_SCN)
----------------------------------------
10856596749071

--[on OLD DB]
GGSCI > dblogin userid ggate_user@mbbdb, password GGateUser#123

REPLICAT RE_S1
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_2")
USERID ggate_user@mbbdb, PASSWORD GGateUser#123
DBOPTIONS INTEGRATEDPARAMS(parallelism 8)
--DBOPTIONS INTEGRATEDPARAMS(parallelism 8,COMMIT_SERIALIZATION FULL)
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
--DBOPTIONS INTEGRATEDPARAMS(COMMIT_SERIALIZATION FULL)
ASSUMETARGETDEFS
--HANDLECOLLISIONS

GGSCI > edit params REP_S2
REPLICAT REP_S2
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_1")
USERID ggate_user@mbbdb, PASSWORD GGateUser#123
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
ASSUMETARGETDEFS
HANDLECOLLISIONS
DISCARDFILE /gg_data/goldengate/dirrpt/REP_S2.dsc,append
MAP DBA01.TEST_GG,TARGET DBA01.TEST_GG;
MAP MOBR5.*,TARGET MOBR5.*;--> get result from below sql

select distinct 'MAP MOBR5.'||table_name||',TARGET MOBR5.'||table_name||';' from dba_constraints 
where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

GGSCI > add replicat REP_S2, exttrail /gg_data/goldengate/dirdat/bp 

--[On NEW DB] get scn
select to_char(current_scn) from v$database; --> flashback_scn

--[on OLD DB]
GGSCI > start replicat REP_S2, aftercsn XXXXXXXXXXXX
GGSCI > info all


--11.Start application for customer
=====================================================

--12.Monitor after golive.
=====================================================
