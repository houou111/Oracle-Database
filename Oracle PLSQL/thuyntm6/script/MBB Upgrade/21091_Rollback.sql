--1.Stop application
=====================================================

--2.Export tables which do not have any constraints
=====================================================
expdp \"/ as sysdba\" dumpfile=rollback_remain_table_%u.dmp logfile=exp_rollback_remain_table.log directory=UPGR_PUMP_12C schemas=MOBR5 cluster=n parallel=4 include=TABLE:\"IN\(select table_name from dba_tables where owner=\'MOBR5\' and table_name not in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\)  and owner=\'MOBR5\'\) and table_name not    IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\)\" 
"

--get ddl of sequence
set long 100000
select 'ALTER SEQUENCE '||sequence_name||' START  WITH  '||last_number||';' from dba_sequences where sequence_owner='MOBR5';

--3.On old database. Drop table which do not have any constraint. Import tables which do not have any constraints
=====================================================
--drop table
select distinct 'Drop table MOBR5.'||table_name||';' from dba_constraints 
where constraint_type not in ('U', 'P') and owner='MOBR5' and status <> 'ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')
 
--import 
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP dumpfile=rollback_remain_table_%u.dmp logfile=imp_rollback_remain_table.log parallel=4 remap_tablespace=DATA:USERS
"

--Alter sequence 
Alter sequence ...

--4.Check row count between two environment
=====================================================
--run below script [on BOTH database]
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
and table_name  in ('EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS') --and partition_name in ()
) order by table_owner, table_name;
spool off;
@obj_row_count.sql

--5.Config app to connect to new database. Start application and follow CheckList (without customer loging)
=====================================================

--6.Start application for customer
=====================================================