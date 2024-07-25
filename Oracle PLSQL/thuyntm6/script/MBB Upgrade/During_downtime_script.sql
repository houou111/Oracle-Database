----1. Stop application
----2. [ON OLD DB] Lock account MOBR5 on current DB. Purge recyclebin. Read only tablespace USERS (contain MOBR5 data)
alter user MOBR5 account lock;
alter user SRV_DWH_MBB account lock;
purge recyclebin;
alter tablespace USERS read only;
----4. [ON OLD DB] Export data: Small table (config table) and Current data of history table
vi export_current_data.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1 
export PAR_FILE=/home/oracle/current_partition.txt
export HIS_FILE=/home/oracle/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/export_cur_par_${datetime}.log
echo > $ORA_LOG

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP dumpfile=remain_users.dmp logfile=exp_remain_users.dmp cluster=N parallel=4 schemas=ANDD,HIEPVT,HUNGNN,HUNGNQ9,HUNGTM3,ITS11,PHONGC,SRV_DWH_MBB,SRV_GUARDIUM_MBB,TUNGNT17,VANTTT3,ANHNV,ITS14,ITS15,TAMHM2,TUANTV6

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP schemas=MOBR5 dumpfile=livedata%u.dmp logfile=exp_livedata.log exclude=statistics  cluster=N parallel=4  exclude=TABLE:\"IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\"

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  content=data_only cluster=N
done < "$PAR_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG

"
----5.Mount mountpoint contain export data to new server
--[ON OLD DB]
umount /stage

--[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage
----6.[ON NEW DB] Import data into new database

#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1 
export PAR_FILE=/stage/dump/current_partition.txt
export HIS_FILE=/stage/dump/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/impdp_cur_par_${datetime}.log
echo > $ORA_LOG


impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=remain_users.dmp logfile=imp_remain_users.log 

impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=livedata%u.dmp logfile=imp_livedata.log remap_tablespace=USERS:MBB_DATA parallel=8

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  
done < "$PAR_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG

"

ALTER TABLE MOBR5.MOB_AUDIT_LOGS ADD (
  CONSTRAINT FK_ACT_ACT_TO_CUST 
  FOREIGN KEY (ID_CALLER) 
  REFERENCES MOBR5.MOB_CUSTOMERS (ID_CUSTOMER)
  ENABLE NOVALIDATE);

  
----7. Compare number of row between 2 evironments. Check object consistency between 2 environments
--check row count
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
and table_name  in ('EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS')
--and partition_name in ()
) order by table_owner, table_name;
spool off;
@obj_row_count.sql

--check object consistency between 2 environments
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

----8	Config application to connect to new database
----9	Unlock account MOBR5 on new database
alter user MOBR5 account unlock;
alter user SRV_DWH_MBB account unlock;
--change DB to archivelog mode
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;

----10	Start application and check
