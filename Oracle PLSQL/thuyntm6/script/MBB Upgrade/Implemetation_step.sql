--1	Install goldengate on current and new server
--Download file and install
--
--http://www.oracledistilled.com/golden-gate/installation-of-oracle-goldengate-v11-2-1-0-1-for-oracle-11g-on-linux-x86-64/
useradd –G oinstall gguser
passwd gguser

groups gguser
[root@ggt1 ~]# cd /gg_data
[root@ggt1 oracle]# mkdir goldengate
[root@ggt1 oracle]# chown -R gguser:oinstall goldengate/
-rw-r--r--  1 root   root       86 Sep 15  2018 test.txt
drwxr-xr-x 17 gguser oinstall 4096 Sep 16  2018 goldengate

vi .bash_profile
===
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.s390x/jre

export PATH

export GGATE=/gg_data/goldengate
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$JAVA_HOME/bin:$GGATE/bin
export LIBPATH=$ORACLE_HOME/lib:$GGATE
export LD_LIBRARY_PATH=$ORACLE_HOME/lib

PATH=$PATH:/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:.

export PATH

===
--Create tablespace on BOTH [Source] and [Target]
SOURCE: create tablespace ggate_TBS datafile '+DATA04' size 5g autoextend on next 500m maxsize 10g extent management local segment space management auto;
TARGET: create tablespace ggate_TBS datafile '+DATA01' size 5g autoextend on next 500m maxsize 10g extent management local segment space management auto;

--
alter system set enable_goldengate_replication=true scope=both sid='*';

--Make sure both database is in ARCHIVELOGMODE

--config in tnsname.ora
SOURCE:
mbbdb_taf=
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dr-oradb-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = mbbdb_taf)
    )
  )
  
TARGET: 
mbbdb=
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dr-mbb-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = mbbdb)
    )
  )
  
--Create database user for goldengate on both [Source] and [Target]
create user ggate_user identified by GGateUser#123 default tablespace ggate_TBS profile PROFILE_SERVICE_ACCOUNT;
grant create session, alter session to ggate_user;
grant connect,resource to ggate_user;
grant select any dictionary to ggate_user;
grant flashback any table to ggate_user;
grant select any table to ggate_user;
grant create table to ggate_user;
grant execute on dbms_flashback to ggate_user;
grant select any TRANSACTION to ggate_user;
grant LOCK ANY TABLE to ggate_user;
grant execute on utl_file to ggate_user;
grant alter any table to ggate_user;
GRANT DBA TO GGATE_USER; --target 

--Enable supplemental logging at database level on both [Source] and [Target]
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

--force logging
--alter database force logging;
select force_logging from v$database;

--Check the gg login[SOURCE & TARGET]
GGSCI >  dblogin userid ggate_user@mbbdb, password GGateUser#123
 
--Create checkpoint table on REPLICAT side[ TARGET]
ggsci> add checkpointtable ggate_user.checkpoint_test
 
--Update ./GLOBALS file on REPLICATE side [ TARGET]
EDIT PARAMS ./GLOBALS
GGSCHEMA ggate_user
checkpointtable ggate_user.checkpoint_test

=========================================================================================================================================================
--0. shutdown transactional
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=$1

LOG_NAME=log_shutdown_$ORACLE_SID.log
LOG_FILE=/home/oracle/$LOG_NAME

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown transactional;
spool off
exit
EOF


nohup sh shutdown_transactional.sh ocrdb2 &
nohup sh shutdown_transactional.sh ebpaydb2 &
nohup sh shutdown_transactional.sh odmdb2 &
nohup sh shutdown_transactional.sh tsbddb2 &
nohup sh shutdown_transactional.sh sordb2 &
nohup sh shutdown_transactional.sh ocbdb2 &
nohup sh shutdown_transactional.sh oerepdb2 &
nohup sh shutdown_transactional.sh otacdb2 &
nohup sh shutdown_transactional.sh bamdb2 &
nohup sh shutdown_transactional.sh mbbdb2 &
nohup sh shutdown_transactional.sh mftdb2 &
nohup sh shutdown_transactional.sh scpsdb2 & 
nohup sh shutdown_transactional.sh custdb2 &
nohup sh shutdown_transactional.sh icsdb2 &
nohup sh shutdown_transactional.sh dexxisdb2 &
nohup sh shutdown_transactional.sh obidb2 &
nohup sh shutdown_transactional.sh scfdb2 &
nohup sh shutdown_transactional.sh mobotp2 &
nohup sh shutdown_transactional.sh bpmdb2 &
nohup sh shutdown_transactional.sh bancadb2 &
nohup sh shutdown_transactional.sh hrmdb2 &

--0.5 start

--0. shutdown transactional
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=$1

LOG_NAME=log_startup_$ORACLE_SID.log
LOG_FILE=/home/oracle/$LOG_NAME

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
startup
spool off
exit
EOF


--nohup sh start_db.sh mbbdb2 &
nohup sh start_db.sh ocrdb2 &
nohup sh start_db.sh ebpaydb2 &
nohup sh start_db.sh odmdb2 &
nohup sh start_db.sh tsbddb2 &
nohup sh start_db.sh sordb2 &
nohup sh start_db.sh ocbdb2 &
nohup sh start_db.sh oerepdb2 &
nohup sh start_db.sh otacdb2 &
nohup sh start_db.sh bamdb2 &
nohup sh start_db.sh mftdb2 &
nohup sh start_db.sh scpsdb2 & 
nohup sh start_db.sh custdb2 &
nohup sh start_db.sh icsdb2 &
nohup sh start_db.sh dexxisdb2 &
nohup sh start_db.sh obidb2 &
nohup sh start_db.sh scfdb2 &
nohup sh start_db.sh mobotp2 &
nohup sh start_db.sh bpmdb2 &
nohup sh start_db.sh bancadb2 &
nohup sh start_db.sh hrmdb2 &

--1. edit mgr
edit params mgr   

port 7900
DYNAMICPORTLIST 7910-7949
PURGEOLDEXTRACTS /gg_data/goldengate/dirdat/*, USECHECKPOINTS, MINKEEPFILES 400,FREQUENCYMINUTES 15
AUTORESTART REPLICAT *, RETRIES 3, WAITMINUTES 3, RESETMINUTES 60

*/

[SOURCE]
ggsci> edit params mgr   

port 7900
DYNAMICPORTLIST 7910-7949
PURGEOLDEXTRACTS /gg_data/goldengate/dirdat/ge*, USECHECKPOINTS, MINKEEPFILES 200,FREQUENCYMINUTES 15
PURGEOLDEXTRACTS /gg_data/goldengate/dirdat/gp*, USECHECKPOINTS, MINKEEPFILES 200,FREQUENCYMINUTES 15
AUTORESTART EXTRACT EXT_S1 ,RETRIES 6 ,WAITMINUTES 5
AUTORESTART EXTRACT EXT_P1 ,RETRIES 6 ,WAITMINUTES 5
AUTORESTART EXTRACT * ,RETRIES 6 ,WAITMINUTES 5

[TARGET]

ggsci> edit params mgr   

port 7900
DYNAMICPORTLIST 7910-7949
PURGEOLDEXTRACTS /gg_data/goldengate/dirdat/gp*, USECHECKPOINTS, MINKEEPFILES 200,FREQUENCYMINUTES 15
AUTORESTART REPLICAT REP_S1 ,RETRIES 6 ,WAITMINUTES 5
AUTORESTART REPLICAT * ,RETRIES 6 ,WAITMINUTES 5

--2	Add unique constraint using index on MOB_BENEFICIARIES
alter system set undo_retention=3600 scope=both sid='*';
alter TABLESPACE UNDOTBS2 add DATAFILE   '+DATA04' SIZE 100M AUTOEXTEND ON next 1G MAXSIZE UNLIMITED;
ALTER TABLE MOBR5.MOB_BENEFICIARIES ADD (  CONSTRAINT UK_MOB_BENEFICIARIES  UNIQUE (ID_BENEFICIARY)  USING INDEX MOBR5.MOB_BENEFICIARIES_INDEX2   ENABLE VALIDATE);

--ALTER TABLE dba01.test_gg ADD (  CONSTRAINT uk_test  UNIQUE (table_name)  USING INDEX   ENABLE VALIDATE);

--3	Config goldengate extract & replicate on current and new server
--[ SOURCE ] add supplemental for all tables of a schema 
dblogin userid ggate_user@mbbdb, password GGateUser#123

--add trandata
  select distinct 'add trandata MOBR5.'||table_name from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

GGSCI > --run command generate from above sql

--[ SOURCE ] Prepare extract file 
GGSCI > dblogin userid ggate_user, password GGateUser#123
GGSCI > edit params EXT_S1
EXTRACT EXT_S1
SETENV (ORACLE_SID="mbbdb1")
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
userid ggate_user@mbbdb, password GGateUser#123
TRANLOGOPTIONS DBLOGREADER
FETCHOPTIONS  FETCHPKUPDATECOLS, USESNAPSHOT, USELATESTVERSION
DBOPTIONS ALLOWUNUSEDCOLUMN
CACHEMGR CACHESIZE 500M
DISCARDFILE /gg_data/goldengate/dirrpt/ext_s1.dsc, APPEND, MEGABYTES 100
EXTTRAIL /gg_data/goldengate/dirdat/ge
WARNLONGTRANS 1H, CHECKINTERVAL 1H
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from below sql

 select distinct 'TABLE MOBR5.'||table_name||';' from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

GGSCI > edit params EXT_P1
EXTRACT EXT_P1
userid ggate_user@mbbdb, password GGateUser#123
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
RMTHOST 10.99.1.188, MGRPORT 7900
RMTTRAIL /gg_data/goldengate/dirdat/gp
DBOPTIONS ALLOWUNUSEDCOLUMN
TABLE DBA01.TEST_GG;
TABLE MOBR5.*; --> get result from above sql



--
--https://blog.dbi-services.com/performing-an-initial-load-with-goldengate-2-expdpimpdp/
GGSCI > dblogin userid ggate_user, password GGateUser#123
GGSCI > register extract EXT_S1 database

--
GGSCI (dc-oradb-02) 398> register extract EXT_S1 database
Extract EXT_S1 successfully registered with database at SCN 10846212005219.
--
GGSCI > ADD EXTRACT EXT_S1, integrated tranlog, BEGIN NOW --, THREADS 2
GGSCI > add exttrail /gg_data/goldengate/dirdat/ge,extract EXT_S1, megabytes 500

GGSCI > add extract EXT_P1, exttrailsource /gg_data/goldengate/dirdat/ge
GGSCI > add rmttrail /gg_data/goldengate/dirdat/gp,extract EXT_P1, megabytes 500

GGSCI > start extract *
GGSCI > info all

--Change size of trail file
--GGSCI > INFO EXTTRAIL *
--GGSCI > ALTER EXTTRAIL /u01/gg_data/dirdat/de, EXTRACT EXT_MOB, MEGABYTES 1024
--GGSCI > ALTER EXTTRAIL /u01/gg_data/dirdat/dp, EXTRACT EXTMOB_P, MEGABYTES 1024


--[TARGET]
GGSCI > dblogin userid ggate_user@mbbdb, password GGateUser#123
GGSCI > edit params REP_S1
REPLICAT REP_S1
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_1")
USERID ggate_user@mbbdb, PASSWORD GGateUser#123
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
--DBOPTIONS INTEGRATEDPARAMS(parallelism 8,COMMIT_SERIALIZATION FULL)

ASSUMETARGETDEFS
HANDLECOLLISIONS
DISCARDFILE /gg_data/goldengate/dirrpt/REP_S1.dsc,append
MAP DBA01.TEST_GG,TARGET DBA01.TEST_GG;
MAP MOBR5.*,TARGET MOBR5.*;--> get result from below sql

 select distinct 'MAP MOBR5.'||table_name||',TARGET MOBR5.'||table_name||';' from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')

 
 add REPLICAT   RE_S1  ,parallel
 
GGSCI > dblogin userid ggate_user, password GGateUser#123
GGSCI > add replicat REP_S1, exttrail /gg_data/goldengate/dirdat/gp --checkpointtable gguser.chkpt
-------add replicat replcdd, integrated, exttrail ./dirdat/jj

--4	Export data from current database
--on old DB
create or replace directory UPGR_PUMP as '/stage/dump';
--on new DB
create or replace directory UPGR_PUMP_12C as '/stage/dump';
create or replace directory UPGR_PUMP_12C as '/u01/app/oracle/dump';

--add undo and increase undo_retention

--on old DB
 select to_char(current_scn) from v$database;

TO_CHAR(CURRENT_SCN)
----------------------------------------
10846212069781


 
 --expdp \"/ as sysdba\" dumpfile=initload%u.dmp logfile=initload.log directory=UPGR_PUMP schemas=MOBR5 cluster=n parallel=12 INCLUDE=TABLE:\"IN\(select  table_name from dba_tables where table_name in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\) and table_name not IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\) and owner=\'MOBR5\' \)\)\"  flashback_scn=xxxxxxxxxxxxxx

#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb2
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/export_init_${datetime}.log
echo > $ORA_LOG

 expdp \"/ as sysdba\" DIRECTORY=DATA_PUMP_DIR tables=dba01.test_gg dumpfile=tab_test_gg.dmp logfile=exp_tab_test_gg.log exclude=statistics  cluster=N flashback_scn=10846235596994
 
expdp \"/ as sysdba\" dumpfile=exp_gg_%u.dmp logfile=exp_gg.log directory=UPGR_PUMP schemas=MOBR5 exclude=statistics cluster=n parallel=12 exclude=TABLE:\"IN\(select table_name from dba_tables where owner=\'MOBR5\' and \(table_name not in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\)  and owner=\'MOBR5\'\) or table_name   IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\)\)\"  flashback_scn=10846235596994


expdp \"/ as sysdba\" dumpfile=remain%u.dmp logfile=remain.log directory=DATA_PUMP_DIR schemas=MOBR5 cluster=n parallel=3 include=TABLE:\"IN\(select table_name from dba_tables where owner=\'MOBR5\' and table_name not in \(select distinct table_name from dba_constraints where constraint_type in \(\'U\', \'P\'\)  and owner=\'MOBR5\'\) and table_name not    IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\)\" flashback_scn=10846235596994
"
--expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP tables=dba01.test_gg dumpfile=test_gg.dmp logfile=exp_test_gg.log exclude=statistics  cluster=N 
--expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP schemas=MOBR5 dumpfile=livedata%u.dmp logfile=exp_livedata.log exclude=statistics  cluster=N parallel=20  exclude=TABLE:\"IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\"


--5	Import data into new database
-- TRANSFER THE DUMP TO TARGET SERVER:
[ON OLD DB]
umount /stage

[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage
 
-- IMPORT IN TARGET DATABASE:
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/import_init_${datetime}.log
echo > $ORA_LOG

impdp \"/ as sysdba\" dumpfile=exp_gg_%u.dmp logfile=imp_gg.log directory=UPGR_PUMP_12C parallel=12 remap_tablespace=USERS:MOBR5
impdp \"/ as sysdba\" DIRECTORY= UPGR_PUMP_12C  dumpfile=tab_test_gg.dmp logfile=imp_tab_test_gg.log remap_schema=DBA01:thuyntm_dba
impdp \"/ as sysdba\" DIRECTORY= UPGR_PUMP_12C dumpfile=remain%u.dmp logfile=remain.log   parallel=3 remap_tablespace=USERS:MOBR5
--impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=test_gg.dmp logfile=imp_test_gg.log 
"

--6	Start extract and replicate, check for sync between 2 database
--on [ TARGET ]
--GGSCI > start REP_S1
GGSCI > start replicat REP_S1, aftercsn 10846235596994

--7	Compare number of row between 2 evironments/ Check object consistency between 2 environments
check dependence object differ from user service
select * from ALL_DEPENDENCIES where referenced_owner='MOBR5' and owner <>'MOBR5'

--
