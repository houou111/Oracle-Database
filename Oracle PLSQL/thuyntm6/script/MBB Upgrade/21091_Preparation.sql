===============================================================================================================
Migrate history tables (which will change only one time per week)										
===============================================================================================================
--1.Export history tables from current DR prod 
=====================================================
--[ON NEW DB]
umount /stage

--[ON CURRENT DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

--[ON CURRENT DB]create directory 
create or replace directory UPGR_PUMP as '/stage/dump';

--[ON CURRENT DB]get list of partition need to export 
select table_name,partition_name,high_value
from dba_tab_partitions where table_name in  ('EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_AUDIT_LOGS_HIST','MOB_TRACEABLE_REQUESTS')
and table_owner='MOBR5'
order by 1,2

--[ON CURRENT DB]export
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb2
export HIS_FILE=/home/oracle/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/export_hist_partition.log
echo > $ORA_LOG

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP dumpfile=remain_users.dmp logfile=exp_remain_users.dmp cluster=N parallel=4 schemas=ANDD,ANHNV,HUNGNN,HUNGNQ9,HUNGTM3,ITS11,ITS14,ITS15,MINHLV3,PHONGC,SRV_DWH_MBB,SRV_GUARDIUM_MBB,TAMHM2,TUANTV6,TUNGNT17,VANTTT3,MBBUSER,MBBREADONLY

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP dumpfile=hist_data%u.dmp logfile=exp_hist_data.log exclude=statistics cluster=N parallel=8  tables=MOBR5.AMS_BOOKINGS_HIST,MOBR5.AMS_DOCS_20170530,MOBR5.AMS_DOCS_HIST,MOBR5.AMS_PI_BALANCES_20170530,MOBR5.AMS_PI_BALANCES_HIST,MOBR5.EVT_ENTRY_DATA_OLD,MOBR5.EVT_ENTRY_HANDLER_HIST2,MOBR5.EVT_ENTRY_HANDLER_OLD,MOBR5.EVT_ENTRY_HIST2,MOBR5.EVT_ENTRY_OLD,MOBR5.MOB_BENEFICIARIES_201810,MOBR5.MOB_CUS_BK20181115,MOBR5.MOB_CUSTOMERS_IDEN_BK,MOBR5.MOB_FEES_20170530,MOBR5.MOB_FEES_HIST,MOBR5.MOB_INV_TXNS_20170530,MOBR5.MOB_INV_TXNS_HIST,MOBR5.MOB_SESSIONS_HIST,MOBR5.MOB_SUB_TXNS_20170530,MOBR5.MOB_SUB_TXNS_HIST,MOBR5.MOB_TXN_ATTRIBUTES_20170530,MOBR5.MOB_TXN_ATTRIBUTES_HIST,MOBR5.MOB_TXNS_20170530,MOBR5.MOB_TXNS_HIST,MOBR5.MOB_USE_CASE_PRIVILEGES_BK,MOBR5.TCB_CITAD_BANKS_BK,MOBR5.TCB_PIC_READ_20170116,MOBR5.TCB_PRIVATE_INBOX_20170116,MOBR5.TCB_PRIVATE_INBOX_HIST,MOBR5.TCB_PUBLIC_INBOX_20170116,MOBR5.TCB_PUBLIC_INBOX_CUSTOMER_HIST,MOBR5.TCB_PUBLIC_INBOX_HIST  

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log content=data_only  cluster=N
done < "$HIS_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG

"

--2.Import data into new database
=====================================================
--[ON CURRENT DB]
umount /stage

--[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

--[ON NEW DB]create directory 
create or replace directory UPGR_PUMP_12C as '/stage/dump';

--create MOBR5 user (in LOCK mode) and create history table
--grant quota unlimit on tablespace to MOBR5
  ALTER USER MOBR5 QUOTA UNLIMITED ON MOBR5;
  ALTER USER MOBR5 QUOTA UNLIMITED ON MOB_HIST;
  ALTER USER MOBR5 QUOTA UNLIMITED ON USERS;
--create role (empty role)

--[ON NEW DB]import and gather statistics after import
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1
export HIS_FILE=/stage/dump/import/import_list.txt
export AU_FILE=/stage/dump/import/import_list.txt

impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=remain_users.dmp logfile=imp_remain_users_1.log 

impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=hist_data%u.dmp logfile=imp_hist_data.log parallel=6 remap_tablespace=USERS:MOB_HIST

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=${table_name}_${par_name}.dmp logfile=imp_${table_name}_${par_name}.log cluster=N
done < "$HIS_FILE"


while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C remap_table=MOBR5.MOB_AUDIT_LOGS:MOBR5.MOB_AUDIT_LOGS_HIST dumpfile=${table_name}_${par_name}.dmp logfile=imp_${table_name}_${par_name}.log cluster=N
done < "$AU_FILE"
 
sqlplus  "/ as sysdba" <<EOF
spool  /home/oracle/gather_statistic.log append
EXECUTE DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'MOBR5', estimate_percent => NULL);
spool off
exit
EOF

"


--3.Check row count between two environment
=====================================================
vi  obj_count_main_hist_table.sql
set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool histtable_obj_row_count.sql
prompt spool obj_row_count_output_histtable.log
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 8) */ ' end
        || ' rpad(''' || owner ||'.'||table_name || ''',60) tab_name, count(1) cnt from ' || owner || '."' || table_name || '" a;' 
from 
(select owner, table_name, blocks from dba_tables where owner ='MOBR5'
and table_name in ('AMS_BOOKINGS_HIST','AMS_DOCS_20170530','AMS_DOCS_HIST','AMS_PI_BALANCES_20170530','AMS_PI_BALANCES_HIST','EVT_ENTRY_DATA_OLD',
'EVT_ENTRY_HANDLER_HIST2','EVT_ENTRY_HANDLER_OLD','EVT_ENTRY_HIST2','EVT_ENTRY_OLD','MOB_BENEFICIARIES_201810',
'MOB_CUS_BK20181115','MOB_CUSTOMERS_IDEN_BK','MOB_FEES_20170530','MOB_FEES_HIST','MOB_INV_TXNS_20170530','MOB_INV_TXNS_HIST','MOB_SESSIONS_HIST',
'MOB_SUB_TXNS_20170530','MOB_SUB_TXNS_HIST','MOB_TXN_ATTRIBUTES_20170530','MOB_TXN_ATTRIBUTES_HIST','MOB_TXNS_20170530','MOB_TXNS_HIST',
'MOB_USE_CASE_PRIVILEGES_BK','TCB_CITAD_BANKS_BK','TCB_PIC_READ_20170116','TCB_PRIVATE_INBOX_20170116','TCB_PRIVATE_INBOX_HIST','TCB_PUBLIC_INBOX_20170116',
'TCB_PUBLIC_INBOX_CUSTOMER_HIST','TCB_PUBLIC_INBOX_HIST')
) order by owner, table_name;
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 8) */ ' end
        || ' rpad(''' || table_owner ||'.'||table_name||'.'||partition_name || ''',80) tab_name, count(1) cnt from ' || table_owner || '.' || table_name || '  partition ('||partition_name||') a;' 
from 
(select table_owner,table_name,partition_name,blocks from dba_tab_partitions where table_name in  ('EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_AUDIT_LOGS_HIST','MOB_TRACEABLE_REQUESTS')
) order by table_owner, table_name;
prompt spool off;
spool off;
@histtable_obj_row_count.sql

--copy file to new server and compare by "diff file1.txt file2.txt"

===============================================================================================================
Sync tables meet requirement by GoldenGate									
===============================================================================================================
--1.Config goldengate extract & replicate on current and new server
=====================================================
--[on SOURCE] Prepare extract file 
GGSCI > dblogin userid ggate_user@mbbdb, password GGateUser#123
GGSCI > edit params EX_S1
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
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from below sql

select distinct 'TABLE MOBR5.'||table_name||';' from dba_constraints 
where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

GGSCI > edit params EX_P1
EXTRACT EX_P1
userid ggate_user@mbbdb, password GGateUser#123
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
RMTHOST 10.99.1.188, MGRPORT 7900
RMTTRAIL /gg_data/goldengate/dirdat/dp
DBOPTIONS ALLOWUNUSEDCOLUMN
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from above sql

GGSCI > remove replicat  EX_S1
GGSCI > remove replicat  EX_P1
--Extract EX_S1 successfully registered with database at SCN 10855967036250.
GGSCI > register extract EX_S1 database
GGSCI > ADD EXTRACT EX_S1, integrated tranlog, BEGIN NOW 
GGSCI > add exttrail /gg_data/goldengate/dirdat/de,extract EX_S1, megabytes 500
GGSCI > add extract EX_P1, exttrailsource /gg_data/goldengate/dirdat/de
GGSCI > add rmttrail /gg_data/goldengate/dirdat/dp,extract EX_P1, megabytes 500
GGSCI > start extract EX_S1
GGSCI > start extract EX_P1
GGSCI > info all

--[on TARGET]
GGSCI > dblogin userid ggate_user@mbbdb, password GGateUser#123
GGSCI > edit params RE_S1
REPLICAT RE_S1
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_2")
USERID ggate_user, PASSWORD GGateUser#123
DBOPTIONS INTEGRATEDPARAMS(parallelism 8)
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
ASSUMETARGETDEFS
DISCARDFILE /gg_data/goldengate/dirrpt/RE_S1.dsc,append
MAP DBA01.TEST_GG,TARGET DBA01.TEST_GG;
MAP MOBR5.*,TARGET MOBR5.*;--> get result from below sql

select distinct 'MAP MOBR5.'||table_name||',TARGET MOBR5.'||table_name||';' from dba_constraints 
where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

--GGSCI > delete replicat  RE_S1
GGSCI > add replicat RE_S1,integrated, exttrail /gg_data/goldengate/dirdat/dp 


GGSCI > edit params REP1
REPLICAT REP1
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_2")
USERID ggate_user, PASSWORD GGateUser#123
DBOPTIONS INTEGRATEDPARAMS(parallelism 8)
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
ASSUMETARGETDEFS
DISCARDFILE /gg_data/goldengate/dirrpt/REP1.dsc,append
MAP MOBR5.MOB_TRACEABLE_REQUESTS,TARGET MOBR5.MOB_TRACEABLE_REQUESTS;

GGSCI > add replicat REP1,integrated, exttrail /gg_data/goldengate/dirdat/dp 

--2.Export data from current database [ON CURRENT DB]
=====================================================
--[ON NEW DB]
umount /stage

--[ON CURRENT DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

--switch log file
alter system archive log current;

--get SCN
select to_char(current_scn) from v$database; --> flashback_scn



#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb2

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP tables=dba01.test_gg dumpfile=tab_test_gg.dmp logfile=exp_tab_test_gg.log exclude=statistics  cluster=N flashback_scn=10856442986264
 
expdp \"/ as sysdba\" dumpfile=exp_gg_%u.dmp logfile=exp_gg.log directory=UPGR_PUMP schemas=MOBR5 exclude=statistics cluster=n parallel=12 exclude=TABLE:\"IN\(select table_name from dba_tables where owner=\'MOBR5\' and \(table_name not in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\)  and owner=\'MOBR5\'\) or table_name   IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\)\)\"  flashback_scn=10856442986264

par_name=SYS_P4704
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.EVT_ENTRY_HANDLER:$par_name dumpfile=EVT_ENTRY_HANDLER_${par_name}.dmp logfile=exp_EVT_ENTRY_HANDLER_${par_name}.log  content=data_only cluster=n  flashback_scn=10856442986264

par_name1=SYS_P4901
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_AUDIT_LOGS:$par_name1 dumpfile=MOB_AUDIT_LOGS_${par_name1}.dmp logfile=exp_MOB_AUDIT_LOGS_${par_name1}.log  content=data_only cluster=n  flashback_scn=10856442986264

par_name2=SYS_P4889
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_TRACEABLE_REQUESTS:$par_name2 dumpfile=MOB_TRACEABLE_REQUESTS_${par_name2}.dmp logfile=exp_MOB_TRACEABLE_REQUESTS_${par_name2}.log  content=data_only cluster=n  flashback_scn=10856442986264
"

---export remain history partition
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb2
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_AUDIT_LOGS:SYS_P4884 dumpfile=MOB_AUDIT_LOGS_SYS_P4884.dmp logfile=exp_MOB_AUDIT_LOGS_SYS_P4884.log  content=data_only cluster=n
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_AUDIT_LOGS:SYS_P4888 dumpfile=MOB_AUDIT_LOGS_SYS_P4888.dmp logfile=exp_MOB_AUDIT_LOGS_SYS_P4888.log  content=data_only cluster=n
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_TRACEABLE_REQUESTS:SYS_P4881 dumpfile=MOB_TRACEABLE_REQUESTS_SYS_P4885.dmp logfile=exp_MOB_TRACEABLE_REQUESTS_SYS_P4881.log  content=data_only cluster=n
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_TRACEABLE_REQUESTS:SYS_P4881 dumpfile=MOB_TRACEABLE_REQUESTS_SYS_P4885.dmp logfile=exp_MOB_TRACEABLE_REQUESTS_SYS_P4881.log  content=data_only cluster=n

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_TRACEABLE_REQUESTS:SYS_P4881 dumpfile=MOB_TRACEABLE_REQUESTS_SYS_P4881.dmp logfile=exp_MOB_TRACEABLE_REQUES
TS_SYS_P4881.log  content=data_only cluster=n
expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.MOB_TRACEABLE_REQUESTS:SYS_P4885 dumpfile=MOB_TRACEABLE_REQUESTS_SYS_P4885.dmp logfile=exp_MOB_TRACEABLE_REQUESTS_SYS_P4885.log  content=data_only cluster=n


"
--3.Import data into new database
=====================================================
--[ON OLD DB]
umount /stage

--[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage
 
--import data:
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1

impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=tab_test_gg.dmp logfile=imp_tab_test_gg.log
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=exp_gg_%u.dmp logfile=imp_gg.log parallel=12 remap_tablespace=USERS:MOBR5

par_name=SYS_P4704
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=EVT_ENTRY_HANDLER_${par_name}.dmp logfile=imp_EVT_ENTRY_HANDLER_${par_name}.log  

par_name1=SYS_P4901
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=MOB_AUDIT_LOGS_${par_name1}.dmp logfile=imp_MOB_AUDIT_LOGS_${par_name1}.log  

par_name2=SYS_P4889
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=MOB_TRACEABLE_REQUESTS_SYS_P4889.dmp logfile=imp_MOB_TRACEABLE_REQUESTS_SYS_P4889.log  

"

--add constraint to table
ALTER TABLE MOBR5.MOB_AUDIT_LOGS ADD (
  CONSTRAINT FK_ACT_ACT_TO_CUST 
  FOREIGN KEY (ID_CALLER) 
  REFERENCES MOBR5.MOB_CUSTOMERS (ID_CUSTOMER)
  ENABLE NOVALIDATE);
  
--disable trigger and constraint
  
--4.Start extract and replicate, check for sync between 2 database
=====================================================
--[on TARGET ]
--GGSCI > alter replicat RE_S1, extseqno 80 << only when start extract from trail file <> 0
GGSCI > start replicat RE_S1, aftercsn 10856442986264
GGSCI > start replicat REP1, aftercsn  10856470531956
GGSCI > info all

--5.Check if new data inserted into new database. Monitor GoldenGate sync status
=====================================================
select max(dat_creation)from MOBR5.MOB_TRACEABLE_REQUESTS partition (SYS_P4137); --> result increase by time
select max(dat_creation) from MOBR5.MOB_AUDIT_LOGS partition (SYS_P4143); --> result increase by time


gather stat schema MOBR5

--6.config gg monitor
=====================================================
[gguser@dc-core-db-02 ~]$ crontab -l
####GG info all
*/10 * * * * /home/gguser/SCRIPTS/run_ggsci.sh > /home/gguser/SCRIPTS/run_ggsci.out 2>&1
[gguser@dc-core-db-02 ~]$ more  /home/gguser/SCRIPTS/run_ggsci.sh
export GGATE=/gg_data/goldengate
echo -e '\033[1mCREATE_TIME :\033[0m'`date +%d/%m/%y:%T` > /tmp/info_gg.txt

$GGATE/ggsci >> /tmp/info_gg.txt << EOF
info all
EOF

chmod 777 /tmp/info_gg.txt
[gguser@dc-core-db-02 ~]$ ls -lrt /home/gguser/SCRIPTS/run_ggsci.sh
-rwxr-xr-x 1 gguser oinstall 192 Jun 12 10:03 /home/gguser/SCRIPTS/run_ggsci.sh
