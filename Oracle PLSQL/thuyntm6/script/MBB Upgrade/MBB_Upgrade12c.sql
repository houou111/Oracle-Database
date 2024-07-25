MBBDR =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dr-mbb-db-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = mbbdr)
    )
  )

EVT_ENTRY_HANDLER		30
EVT_ENTRY		30
MOB_SESSIONS		30
AMS_BOOKINGS	AMS_BOOKINGS_HIST	365
MOB_FEES	MOB_FEES_HIST	365
MOB_TXN_ATTRIBUTES	MOB_TXN_ATTRIBUTES_HIST	365
AMS_PI_BALANCES	AMS_PI_BALANCES_HIST	365
MOB_INV_TXNS	MOB_INV_TXNS_HIST	365
AMS_DOCS	AMS_DOCS_HIST	365
MOB_AUDIT_LOGS	MOB_AUDIT_LOGS_HIST	30
MOB_TRACEABLE_REQUESTS		30
TCB_PUBLIC_INBOX_CUSTOMER_READ	TCB_PUBLIC_INBOX_CUSTOMER_HIST	365
TCB_PRIVATE_INBOX	TCB_PRIVATE_INBOX_HIST	365
TCB_PUBLIC_INBOX	TCB_PUBLIC_INBOX_HIST	365

AMS_BOOKINGS
MOB_SUB_TXNS
EVT_ENTRY_DATA
TCB_PRIVATE_INBOX
MOB_FEES
MOB_TXN_ATTRIBUTES

--to SNAPSHOT
recover managed standby database cancel;
alter database convert to snapshot standby;
alter database open;
create or replace directory UPGR_PUMP as '/stage/dump';

--to standby
select open_mode,database_role from v$database;
shutdown immediate;
startup mount;
alter database convert to physical standby;
shu immediate 
startup mount
alter database recover managed standby database using current logfile disconnect;


select to_char(timestamp,'DD/MM/YYYY HH24:MI:SS')"SYNC Time" from v$recovery_progress where item='Last Applied Redo'
 and start_time=(select max(start_time) from v$recovery_progress);

1.PREPARE NEW DATABASE 
2. 
--mount mountpoint
 umount /stage/
 
 mount /dev/vg_stage/lv_stage /stage
 chown -R oracle:oinstall /stage


-- create directories
--on old DB
create or replace directory UPGR_PUMP as '/stage/dump';
--on new DB
create or replace directory UPGR_PUMP_12C as '/stage/dump';
create or replace directory UPGR_PUMP_12C as '/u01/app/oracle/dump';
-- local disk map to both old and new server
 mount /dev/vg_stage/lv_stage /stage
 chown -R oracle:oinstall /stage
-- add datafile to tablespace
create tablespace MBB_DATA  datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
alter  tablespace MBB_DATA  add datafile '+DATA01' size 31G ;
 

EXPORT HISTORY DATA
IMPORT HISTORY DATA
CHECK AFTER IMPORT

EXPORT LIVE DATA --> 197G  00:32:58  parallel 4
EXPORT CURRENT HISTORY DATA --> 8G 00:05:30 noparallel
IMPORT LIVE DATA
IMPORT CURRENT HISTORY DATA
CHECK AFTER IMPORT
====================================
AMS_BOOKINGS_HIST
MOB_FEES_HIST
MOB_TXN_ATTRIBUTES_HIST
AMS_PI_BALANCES_HIST
MOB_INV_TXNS_HIST
AMS_DOCS_HIST
TCB_PUBLIC_INBOX_CUSTOMER_HIST
TCB_PRIVATE_INBOX_HIST
TCB_PUBLIC_INBOX_HIST
====================================SCRIPT
vi export_cur_par.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdr1 
export PAR_FILE=/home/oracle/current_partition.txt
export HIS_FILE=/home/oracle/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/export_cur_par_${datetime}.log
echo > $ORA_LOG

--35p - parallel 4
expdp \"/ as sysdba\" DIRECTORY=DATA_PUMP_DIR tables=dba01.test_gg dumpfile=test_gg.dmp logfile=exp_test_gg.log exclude=statistics  cluster=N 
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=test_gg.dmp logfile=imp_test_gg.log 

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP schemas=MOBR5 dumpfile=livedata%u.dmp logfile=exp_livedata.log exclude=statistics  cluster=N parallel=20  exclude=TABLE:\"IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\"
---expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP schemas=MOBR5 dumpfile=livedata%u.dmp logfile=exp_livedata.log exclude=statistics,indexes,constraints  cluster=N parallel=4  exclude=TABLE:\"IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\)\"


while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  content=data_only cluster=N
done < "$PAR_FILE"

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  content=data_only cluster=N
done < "$HIS_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG
====================================prepare before import
CREATE ROLE TCB_MBB_APO NOT IDENTIFIED;
CREATE ROLE TCB_MBB_DEVL3 NOT IDENTIFIED;
CREATE ROLE TCB_MBB_ANTT NOT IDENTIFIED;
GRANT SELECT ON SYS.ALL_COL_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_COL_PRIVS_MADE TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_COL_PRIVS_RECD TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_DEF_AUDIT_OPTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_TAB_COLS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_TAB_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_TAB_PRIVS_MADE TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ALL_TAB_PRIVS_RECD TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.AUDIT_ACTIONS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_EXISTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_OBJECT TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_POLICIES TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_SESSION TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_STATEMENT TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_AUDIT_TRAIL TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_COL_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_COMMON_AUDIT_TRAIL TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_FGA_AUDIT_TRAIL TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_OBJ_AUDIT_OPTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_PRIV_AUDIT_OPTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_ROLES TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_ROLE_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_STMT_AUDIT_OPTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_SYS_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_TAB_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.DBA_USERS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ROLE_ROLE_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ROLE_SYS_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.ROLE_TAB_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.SESSION_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.SESSION_ROLES TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.STMT_AUDIT_OPTION_MAP TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_AUDIT_OBJECT TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_AUDIT_SESSION TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_AUDIT_STATEMENT TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_AUDIT_TRAIL TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_COL_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_COL_PRIVS_MADE TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_COL_PRIVS_RECD TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_OBJ_AUDIT_OPTS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_ROLE_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_SYS_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_TAB_PRIVS TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_TAB_PRIVS_MADE TO TCB_MBB_ANTT;
GRANT SELECT ON SYS.USER_TAB_PRIVS_RECD TO TCB_MBB_ANTT;

CREATE ROLE GDMMONITOR NOT IDENTIFIED;
-- Object privileges granted to GDMMONITOR
GRANT SELECT ON DBA_LIBRARIES TO GDMMONITOR;
GRANT SELECT ON DBA_OBJECTS TO GDMMONITOR;
GRANT SELECT ON DBA_PROFILES TO GDMMONITOR;
GRANT SELECT ON DBA_ROLES TO GDMMONITOR;
GRANT SELECT ON DBA_ROLE_PRIVS TO GDMMONITOR;
GRANT SELECT ON DBA_SYS_PRIVS TO GDMMONITOR;
GRANT SELECT ON DBA_TABLES TO GDMMONITOR;
GRANT SELECT ON DBA_TAB_PRIVS TO GDMMONITOR;
GRANT SELECT ON DBA_USERS TO GDMMONITOR;
GRANT SELECT ON DBA_USERS_WITH_DEFPWD TO GDMMONITOR;
GRANT SELECT ON GV_$CELL_STATE TO GDMMONITOR;
GRANT SELECT ON PROXY_USERS TO GDMMONITOR;
GRANT SELECT ON REGISTRY$HISTORY TO GDMMONITOR;
GRANT SELECT ON USER$ TO GDMMONITOR;
GRANT SELECT ON V_$ARCHIVE_DEST TO GDMMONITOR;
GRANT SELECT ON V_$CONTROLFILE TO GDMMONITOR;
GRANT SELECT ON V_$DATABASE TO GDMMONITOR;
GRANT SELECT ON V_$DATAFILE TO GDMMONITOR;
GRANT SELECT ON V_$INSTANCE TO GDMMONITOR;
GRANT SELECT ON V_$LOGFILE TO GDMMONITOR;
GRANT SELECT ON V_$PARAMETER TO GDMMONITOR;
GRANT SELECT ON V_$SYSTEM_PARAMETER TO GDMMONITOR;
GRANT SELECT ON SQLPLUS_PRODUCT_PROFILE TO GDMMONITOR;
-- Roles granted to GDMMONITOR
GRANT CONNECT TO GDMMONITOR;
-- Grantees of GDMMONITOR
GRANT GDMMONITOR TO SRV_GUARDIUM_MBB;
GRANT GDMMONITOR TO SYS WITH ADMIN OPTION;


---get role script SY365_OBJOWNER
GDMMONITOR

CREATE ROLE SY365_OBJOWNER NOT IDENTIFIED;
GRANT CREATE INDEXTYPE TO SY365_OBJOWNER;
GRANT CREATE PROCEDURE TO SY365_OBJOWNER;
GRANT CREATE SEQUENCE TO SY365_OBJOWNER;
GRANT CREATE SESSION TO SY365_OBJOWNER;
GRANT CREATE SYNONYM TO SY365_OBJOWNER;
GRANT CREATE TABLE TO SY365_OBJOWNER;
GRANT CREATE TRIGGER TO SY365_OBJOWNER;
GRANT CREATE VIEW TO SY365_OBJOWNER;
--GRANT SY365_OBJOWNER TO MOBR5; ###################################
GRANT SY365_OBJOWNER TO SYS WITH ADMIN OPTION;

--- create mobr5 user 

CREATE USER MOBR5  IDENTIFIED BY VALUES 'S:1F2E472D6E6A3D9FFEAFBEBC3476E87C62EC0F1F9EC88A6AEE8EFB8452E2;83331504FD9B3022'
  DEFAULT TABLESPACE MOBR5
  TEMPORARY TABLESPACE TEMP
  PROFILE PROFILE_SERVICE_ACCOUNT
  ACCOUNT LOCK;
  
 -- 2 Roles for MOBR5 
  GRANT CONNECT TO MOBR5;
  GRANT SY365_OBJOWNER TO MOBR5;
  ALTER USER MOBR5 DEFAULT ROLE ALL;
  -- 2 System Privileges for MOBR5 
  GRANT CREATE EXTERNAL JOB TO MOBR5;
  GRANT CREATE SESSION TO MOBR5;
  -- 1 Tablespace Quota for MOBR5 
  ALTER USER MOBR5 QUOTA UNLIMITED ON MOBR5;
  ALTER USER MOBR5 QUOTA UNLIMITED ON MOB_HIST;
  ALTER USER MOBR5 QUOTA UNLIMITED ON USERS;
  -- 32 Object Privileges for MOBR5 
    GRANT EXECUTE ON CTXSYS.DRITHSX TO MOBR5;
    GRANT EXECUTE ON ORDSYS.ORD_DICOM TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_ADVISOR TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_AQADM_SYS TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_AQADM_SYSCALLS TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_AW_XML TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_BACKUP_RESTORE TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_FILE_TRANSFER TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_IJOB TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_JAVA TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_JAVA_TEST TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_JOB TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_LDAP TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_OBFUSCATION_TOOLKIT TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_PRVTAQIM TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_RANDOM TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_REPCAT_SQL_UTL TO MOBR5; --not exist
    GRANT EXECUTE ON SYS.DBMS_SCHEDULER TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_SQL TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_STREAMS_ADM_UTL TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_STREAMS_RPC TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_SYS_SQL TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_XMLGEN TO MOBR5;
    GRANT EXECUTE ON SYS.DBMS_XMLQUERY TO MOBR5;
    GRANT EXECUTE ON SYS.HTTPURITYPE TO MOBR5;
    GRANT EXECUTE ON SYS.INITJVMAUX TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_FILE TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_HTTP TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_INADDR TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_MAIL TO MOBR5;--not exist
    GRANT EXECUTE ON SYS.UTL_SMTP TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_TCP TO MOBR5;



expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP dumpfile=remain_users.dmp logfile=exp_remain_users.dmp cluster=N parallel=4 schemas=ANDD,ANHNV,HUNGNN,HUNGNQ9,HUNGTM3,ITS11,ITS14,ITS15,MINHLV3,PHONGC,SRV_GUARDIUM_MBB,TAMHM2,TUANTV6,TUNGNT17,VANTTT3,MBBUSER,MBBREADONLY
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=remain_users.dmp logfile=imp_remain_users_1.log 
ANDD,ANHNV,HUNGNN,HUNGNQ9,HUNGTM3,ITS11,ITS14,ITS15,MINHLV3,PHONGC,SRV_GUARDIUM_MBB,TAMHM2,TUANTV6,TUNGNT17,VANTTT3,MBBUSER,MBBREADONLY

-- CREATE USER "MBBREADONLY" IDENTIFIED BY VALUES 'S:F357A5870A9523394554258BB167130541E0991812EAFB524EA9F567CC7C;6440EF3B44ABDF24'                                                     
--    DEFAULT TABLESPACE "USERS"                                                                                   
--    TEMPORARY TABLESPACE "TEMP"                                                                               
--    PROFILE "PROFILE_ENDUSER"                                                                                    
--    ACCOUNT LOCK;                                                                                 
-- GRANT "CONNECT" TO "MBBREADONLY";                                                                  
-- GRANT "RESOURCE" TO "MBBREADONLY";       
-- ALTER USER "MBBREADONLY" DEFAULT ROLE ALL;    
-- GRANT UNLIMITED TABLESPACE TO "MBBREADONLY";  
  
 --GRANT SELECT ON "MOBR5"."TCB_PUSH_ACCOUNT" TO "MBBREADONLY";                                    
 --GRANT SELECT ON "MOBR5"."GIFTCARDTRAN" TO "MBBREADONLY";                                                                                 
 
 
 
   CREATE USER "SRV_DWH_MBB" IDENTIFIED BY VALUES 'S:782B7DD4C6FD6E9C8FE10023D948FC47D3C63B399BAC428411C36823DF64;B9FE065DE02B0697'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
      DEFAULT TABLESPACE "USERS"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
      TEMPORARY TABLESPACE "TEMP"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
      PROFILE "PROFILE_SERVICE_ACCOUNT" ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
  GRANT "CONNECT" TO "SRV_DWH_MBB";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  GRANT ALTER USER TO "SRV_DWH_MBB";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  GRANT CREATE SESSION TO "SRV_DWH_MBB";     
  ALTER USER "SRV_DWH_MBB" DEFAULT ROLE ALL;   
  ALTER USER SRV_DWH_MBB QUOTA UNLIMITED ON USERS;
    GRANT EXECUTE ON CTXSYS.DRITHSX TO SRV_DWH_MBB;
    GRANT EXECUTE ON ORDSYS.ORD_DICOM TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_AW_XML TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_JOB TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_LDAP TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_OBFUSCATION_TOOLKIT TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_RANDOM TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_SCHEDULER TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_SQL TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.DBMS_XMLGEN TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.HTTPURITYPE TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.UTL_FILE TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.UTL_HTTP TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.UTL_INADDR TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.UTL_SMTP TO SRV_DWH_MBB;
    GRANT EXECUTE ON SYS.UTL_TCP TO SRV_DWH_MBB; 
	
    GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_BANK_ACCOUNTS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_CREDIT_CARDS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_CUSTOMERS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_CUSTOMERS_ATTRIBUTES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_CUSTOMERS_IDENTIFICATIONS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_FEES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_FEE_TYPES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_INVOICES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_INVOICE_STATUS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_INV_TXNS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_PIS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_SUB_TXNS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_SUB_TXNS_20170530 TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_SUB_TXNS_HIST TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_SVA TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_SVA_BOOKINGS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_TXNS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_TXNS_20170530 TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_TXNS_HIST TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_TXN_ATTRIBUTES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_TXN_STATUS TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_USE_CASES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.MOB_WALLET TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.SEQ_ID_ENTITY TO SRV_DWH_MBB;
    GRANT DELETE, INSERT, SELECT, UPDATE ON MOBR5.TCB_BANKS_247 TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.TCB_CARD_CUSTOMER_REGISTER TO SRV_DWH_MBB;
    GRANT DELETE, INSERT, SELECT, UPDATE ON MOBR5.TCB_CITAD_BANKS TO SRV_DWH_MBB;
    GRANT DELETE, INSERT, SELECT, UPDATE ON MOBR5.TCB_CITAD_BRANCHES TO SRV_DWH_MBB;
    GRANT DELETE, INSERT, SELECT, UPDATE ON MOBR5.TCB_CITAD_PROVINCES TO SRV_DWH_MBB;
    GRANT SELECT ON MOBR5.TCB_PUSH_ACCOUNT TO SRV_DWH_MBB;                                                                           
	
====================================SCRIPT import

#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdr1 
export PAR_FILE=/stage/dump/current_partition.txt
export HIS_FILE=/stage/dump/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/impdp_cur_par_${datetime}.log
echo > $ORA_LOG

--8h52 -->  (4 parallel)
impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=livedata%u.dmp logfile=imp_livedata_20190510.log remap_tablespace=USERS:MOBR5 parallel=8 

exclude=index,constraint 

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  
done < "$PAR_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG
============================
ALTER TABLE MOBR5.MOB_AUDIT_LOGS ADD (
  CONSTRAINT FK_ACT_ACT_TO_CUST 
  FOREIGN KEY (ID_CALLER) 
  REFERENCES MOBR5.MOB_CUSTOMERS (ID_CUSTOMER)
  ENABLE NOVALIDATE);


============================
vi /stage/dump/current_partition.txt
EVT_ENTRY_HANDLER		SYS_P1581
MOB_AUDIT_LOGS			SYS_P981
MOB_TRACEABLE_REQUESTS	SYS_P1881
#MOB_AUDIT_LOGS_HIST		SYS_P1741
====================================
vi /home/oracle/history_partition.txt

====================================
Create role
 TCB_MBB_APO
 TCB_MBB_DEVL3
 SRV_DWH_MBB
 TCB_MBB_ANTT


====================================
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   CREATE USER "MBBREADONLY" IDENTIFIED BY VALUES 'S:F357A5870A9523394554258BB167130541E0991812EAFB524EA9F567CC7C;6440EF3B44ABDF24'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
      DEFAULT TABLESPACE "USERS"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
      TEMPORARY TABLESPACE "TEMP"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
      PROFILE "PROFILE_ENDUSER"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
      ACCOUNT LOCK;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   GRANT "CONNECT" TO "MBBREADONLY";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   GRANT "RESOURCE" TO "MBBREADONLY";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
  GRANT UNLIMITED TABLESPACE TO "MBBREADONLY";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
  GRANT SELECT ON "MOBR5"."TCB_PUSH_ACCOUNT" TO "MBBREADONLY";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
  GRANT SELECT ON "MOBR5"."GIFTCARDTRAN" TO "MBBREADONLY";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   ALTER USER "MBBREADONLY" DEFAULT ROLE ALL;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
'"
=======================================

CREATE TABLE MOBR5.EVT_ENTRY_HANDLER
(
  ID                       NUMBER(18)           NOT NULL,
  HANDLER                  VARCHAR2(100 BYTE),
  STATUS                   CHAR(1 BYTE),
  RUN_DATE                 TIMESTAMP(6),
  EVENT_ID                 NUMBER(18),
  DAT_CREATION             TIMESTAMP(6),
  ID_CUSTOMER_CREATION     NUMBER(18),
  DAT_LAST_UPDATE          TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE  NUMBER(18)
)
NOCOMPRESS 
TABLESPACE MOB_HIST
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING
PARTITION BY RANGE (DAT_CREATION)
INTERVAL( NUMTOYMINTERVAL(1,'MONTH'))
(  
  PARTITION EVT_ENTRY_HANDLER_P1 VALUES LESS THAN (TIMESTAMP' 2018-05-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),   
  PARTITION VALUES LESS THAN (TIMESTAMP' 2018-06-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION VALUES LESS THAN (TIMESTAMP' 2019-06-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
)
NOCACHE
NOPARALLEL
MONITORING;


--
-- IDX_ENTRY_HANDLER_NEW  (Index) 
--
CREATE UNIQUE INDEX MOBR5.IDX_ENTRY_HANDLER_NEW ON MOBR5.EVT_ENTRY_HANDLER
(EVENT_ID, HANDLER)
LOGGING
TABLESPACE MOB_HIST
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL
REVERSE;


--
-- PK_EVT_ENTRY_HANDLER_NEW  (Index) 
--
CREATE UNIQUE INDEX MOBR5.PK_EVT_ENTRY_HANDLER_NEW ON MOBR5.EVT_ENTRY_HANDLER
(ID)
LOGGING
TABLESPACE MOB_HIST
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL
REVERSE;


-- 
-- Non Foreign Key Constraints for Table EVT_ENTRY_HANDLER 
-- 
ALTER TABLE MOBR5.EVT_ENTRY_HANDLER ADD (
  CONSTRAINT PK_EVT_ENTRY_HANDLER_NEW
  PRIMARY KEY
  (ID)
  USING INDEX MOBR5.PK_EVT_ENTRY_HANDLER_NEW
  ENABLE VALIDATE);

GRANT SELECT ON MOBR5.EVT_ENTRY_HANDLER TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.EVT_ENTRY_HANDLER TO TCB_MBB_DEVL3;

====================================
CREATE TABLE MOBR5.MOB_AUDIT_LOGS
(
  ID_ENTITY                  NUMBER(18)         NOT NULL,
  ID_CALLER                  NUMBER(18)         NOT NULL,
  STR_SESSION_ID             VARCHAR2(80 CHAR),
  STR_DEVICE                 VARCHAR2(200 CHAR),
  STR_DEVICE_ID              VARCHAR2(255 CHAR),
  STR_OTHER_DEVICE_ID        VARCHAR2(255 CHAR),
  STR_APPLICATION            VARCHAR2(255 CHAR),
  STR_APPLICATION_VERSION    VARCHAR2(255 CHAR),
  STR_ACTION                 VARCHAR2(80 CHAR)  NOT NULL,
  STR_ACTION_RESULT_CODE     VARCHAR2(80 CHAR),
  INT_DURATION_MILLISECONDS  NUMBER(18),
  STR_ORIGIN                 VARCHAR2(255 CHAR),
  STR_TRACE_NO               VARCHAR2(255 CHAR),
  STR_INSTANCE               VARCHAR2(80 CHAR),
  ID_CATEGORY                VARCHAR2(6 CHAR)   DEFAULT 'SYSTEM'              NOT NULL,
  ID_CUSTOMER                NUMBER(18),
  ID_TXN                     NUMBER(18),
  STR_PARAMETER_1            VARCHAR2(80 CHAR),
  STR_PARAMETER_2            VARCHAR2(80 CHAR),
  STR_PARAMETER_3            VARCHAR2(80 CHAR),
  STR_PARAMETER_4            VARCHAR2(80 CHAR),
  STR_PARAMETER_5            VARCHAR2(80 CHAR),
  STR_PARAMETER_6            VARCHAR2(80 CHAR),
  STR_PARAMETER_7            VARCHAR2(80 CHAR),
  STR_PARAMETER_8            VARCHAR2(80 CHAR),
  STR_PARAMETER_9            VARCHAR2(80 CHAR),
  DAT_CREATION               TIMESTAMP(6),
  ID_CUSTOMER_CREATION       NUMBER(18),
  DAT_LAST_UPDATE            TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE    NUMBER(18)
)
NOCOMPRESS 
TABLESPACE MOB_HIST
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING
PARTITION BY RANGE (DAT_CREATION)
INTERVAL( NUMTODSINTERVAL(1,'DAY'))
(  
  PARTITION AUDIT_P1 VALUES LESS THAN (TIMESTAMP' 2017-05-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION VALUES LESS THAN (TIMESTAMP' 2019-02-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),   
  PARTITION VALUES LESS THAN (TIMESTAMP' 2019-06-14 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
)
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE MOBR5.MOB_AUDIT_LOGS IS 'Audit table that is mainly filled by the Mobiliser Audit aspect.
Stores information from request and response.';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.ID_ENTITY IS 'The primary key (from a sequence)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.ID_CALLER IS 'The customer id of the caller who sent the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_SESSION_ID IS 'The session id of the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_DEVICE IS 'As specified in the AuditData section from the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_DEVICE_ID IS 'As specified in the AuditData section from the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_OTHER_DEVICE_ID IS 'As specified in the AuditData section from the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_APPLICATION IS 'As specified in the AuditData section from the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_APPLICATION_VERSION IS 'As specified in the AuditData section from the request';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_ACTION IS 'The action (service) that was called';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_ACTION_RESULT_CODE IS 'The result of the action(service), usually represents the numeric error code';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.INT_DURATION_MILLISECONDS IS 'The time it took to execute the service';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_ORIGIN IS 'As specified in the MobiliserRequest';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_TRACE_NO IS 'As specified in the MobiliserRequest';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.ID_CUSTOMER IS 'Optional link to a customer';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.ID_TXN IS 'Optional link to a transaction';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_1 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_2 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_3 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_4 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_5 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_6 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_7 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_8 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';

COMMENT ON COLUMN MOBR5.MOB_AUDIT_LOGS.STR_PARAMETER_9 IS 'Addtional data (unstructured, usage depends on STR_ACTION)';



--
-- IDX_AUDIT_LOGS_CUST  (Index) 
--
CREATE INDEX MOBR5.IDX_AUDIT_LOGS_CUST ON MOBR5.MOB_AUDIT_LOGS
(ID_CUSTOMER)
  TABLESPACE MOB_HIST
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              INITIAL          64K
              NEXT             1M
              MAXSIZE          UNLIMITED
              MINEXTENTS       1
              MAXEXTENTS       UNLIMITED
              PCTINCREASE      0
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;


--
-- IDX_AUDIT_LOGS_TXN  (Index) 
--
CREATE INDEX MOBR5.IDX_AUDIT_LOGS_TXN ON MOBR5.MOB_AUDIT_LOGS
(ID_TXN)
  TABLESPACE MOB_HIST
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              INITIAL          64K
              NEXT             1M
              MAXSIZE          UNLIMITED
              MINEXTENTS       1
              MAXEXTENTS       UNLIMITED
              PCTINCREASE      0
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;


--
-- PK_ACTIVITIES  (Index) 
--
CREATE UNIQUE INDEX MOBR5.PK_ACTIVITIES ON MOBR5.MOB_AUDIT_LOGS
(ID_ENTITY, DAT_CREATION)
  TABLESPACE MOB_HIST
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              INITIAL          64K
              NEXT             1M
              MAXSIZE          UNLIMITED
              MINEXTENTS       1
              MAXEXTENTS       UNLIMITED
              PCTINCREASE      0
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;

ALTER INDEX MOBR5.PK_ACTIVITIES
  MONITORING USAGE;


-- 
-- Non Foreign Key Constraints for Table MOB_AUDIT_LOGS 
-- 
ALTER TABLE MOBR5.MOB_AUDIT_LOGS ADD (
  CONSTRAINT PK_ACTIVITIES
  PRIMARY KEY
  (ID_ENTITY, DAT_CREATION)
  USING INDEX LOCAL
  ENABLE VALIDATE);

-- 
-- Foreign Key Constraints for Table MOB_AUDIT_LOGS 
-- 
ALTER TABLE MOBR5.MOB_AUDIT_LOGS ADD (
  CONSTRAINT FK_ACT_ACT_TO_CUST 
  FOREIGN KEY (ID_CALLER) 
  REFERENCES MOBR5.MOB_CUSTOMERS (ID_CUSTOMER)
  ENABLE VALIDATE);

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS TO SRV_DWH_MBB;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS TO TCB_MBB_ANTT;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS TO TCB_MBB_DEVL3;

====================================
CREATE TABLE MOBR5.MOB_AUDIT_LOGS_HIST
(
  ID_ENTITY                  NUMBER(18)         NOT NULL,
  ID_CALLER                  NUMBER(18)         NOT NULL,
  STR_SESSION_ID             VARCHAR2(80 CHAR),
  STR_DEVICE                 VARCHAR2(200 CHAR),
  STR_DEVICE_ID              VARCHAR2(80 CHAR),
  STR_OTHER_DEVICE_ID        VARCHAR2(80 CHAR),
  STR_APPLICATION            VARCHAR2(80 CHAR),
  STR_APPLICATION_VERSION    VARCHAR2(80 CHAR),
  STR_ACTION                 VARCHAR2(80 CHAR)  NOT NULL,
  STR_ACTION_RESULT_CODE     VARCHAR2(80 CHAR),
  INT_DURATION_MILLISECONDS  NUMBER(18),
  STR_ORIGIN                 VARCHAR2(80 CHAR),
  STR_TRACE_NO               VARCHAR2(80 CHAR),
  STR_INSTANCE               VARCHAR2(80 CHAR),
  ID_CATEGORY                VARCHAR2(6 CHAR)   NOT NULL,
  ID_CUSTOMER                NUMBER(18),
  ID_TXN                     NUMBER(18),
  STR_PARAMETER_1            VARCHAR2(80 CHAR),
  STR_PARAMETER_2            VARCHAR2(80 CHAR),
  STR_PARAMETER_3            VARCHAR2(80 CHAR),
  STR_PARAMETER_4            VARCHAR2(80 CHAR),
  STR_PARAMETER_5            VARCHAR2(80 CHAR),
  STR_PARAMETER_6            VARCHAR2(80 CHAR),
  STR_PARAMETER_7            VARCHAR2(80 CHAR),
  STR_PARAMETER_8            VARCHAR2(80 CHAR),
  STR_PARAMETER_9            VARCHAR2(80 CHAR),
  DAT_CREATION               TIMESTAMP(6),
  ID_CUSTOMER_CREATION       NUMBER(18),
  DAT_LAST_UPDATE            TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE    NUMBER(18)
)
NOCOMPRESS 
TABLESPACE MOB_HIST
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING
PARTITION BY RANGE (DAT_CREATION)
INTERVAL( NUMTOYMINTERVAL(1,'MONTH'))
(  
  PARTITION AUDIT_P1 VALUES LESS THAN (TIMESTAMP' 2017-05-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION VALUES LESS THAN (TIMESTAMP' 2018-07-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION VALUES LESS THAN (TIMESTAMP' 2018-08-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
)
NOCACHE
NOPARALLEL
MONITORING;


GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO HUNGNN;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO ITS14;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO TCB_MBB_ANTT;

GRANT SELECT ON MOBR5.MOB_AUDIT_LOGS_HIST TO TUANTV6;
====================================
CREATE TABLE MOBR5.MOB_TRACEABLE_REQUESTS
(
  ID_ENTITY                NUMBER(18)           NOT NULL,
  STR_ORIGIN               VARCHAR2(80 CHAR)    NOT NULL,
  STR_TRACE_NO             VARCHAR2(80 CHAR)    NOT NULL,
  INT_TIME_SEGMENT         NUMBER(18)           NOT NULL,
  BOL_PROCESSING_COMPLETE  CHAR(1 BYTE)         NOT NULL,
  STR_JAXB_CLASS_NAME      VARCHAR2(200 CHAR),
  TXT_RESPONSE             CLOB,
  DAT_CREATION             TIMESTAMP(6),
  ID_CUSTOMER_CREATION     NUMBER(18),
  DAT_LAST_UPDATE          TIMESTAMP(6),
  ID_CUSTOMER_LAST_UPDATE  NUMBER(18)
)
LOB (TXT_RESPONSE) STORE AS SECUREFILE (
  TABLESPACE  MOB_HIST
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  NOCACHE
  LOGGING)
NOCOMPRESS 
TABLESPACE MOB_HIST
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY RANGE (DAT_CREATION)
INTERVAL( NUMTODSINTERVAL(1,'DAY'))
(  
  PARTITION TRACERQS_P1 VALUES LESS THAN (TIMESTAMP' 2016-01-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    LOB (TXT_RESPONSE) STORE AS SECUREFILE (
      TABLESPACE  MOB_HIST
      ENABLE      STORAGE IN ROW
      CHUNK       8192
      RETENTION
      NOCACHE
      LOGGING)
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION VALUES LESS THAN (TIMESTAMP' 2019-02-01 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE MOB_HIST
    LOB (TXT_RESPONSE) STORE AS SECUREFILE (
      TABLESPACE  MOB_HIST
      ENABLE      STORAGE IN ROW
      CHUNK       8192
      RETENTION
      NOCACHE
      LOGGING
          STORAGE    (
                      INITIAL          8M
                      NEXT             1M
                      MINEXTENTS       1
                      MAXEXTENTS       UNLIMITED
                      PCTINCREASE      0
                      BUFFER_POOL      DEFAULT
                      FLASH_CACHE      DEFAULT
                      CELL_FLASH_CACHE DEFAULT
                     ))
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
)
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE MOBR5.MOB_TRACEABLE_REQUESTS IS 'This table tracks all traceable requests (potentially purged at some intervalls) and is used to track duplicate requests.';



--
-- IDX_ORIG_TRACE  (Index) 
--
CREATE INDEX MOBR5.IDX_ORIG_TRACE ON MOBR5.MOB_TRACEABLE_REQUESTS
(STR_ORIGIN, STR_TRACE_NO, INT_TIME_SEGMENT)
  TABLESPACE MOB_HIST
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              INITIAL          64K
              NEXT             1M
              MAXSIZE          UNLIMITED
              MINEXTENTS       1
              MAXEXTENTS       UNLIMITED
              PCTINCREASE      0
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;

ALTER INDEX MOBR5.IDX_ORIG_TRACE
  MONITORING USAGE;


--
-- PK_MOB_TRACEABLE_REQUESTS  (Index) 
--
CREATE UNIQUE INDEX MOBR5.PK_MOB_TRACEABLE_REQUESTS ON MOBR5.MOB_TRACEABLE_REQUESTS
(ID_ENTITY, DAT_CREATION)
  TABLESPACE MOB_HIST
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              INITIAL          64K
              NEXT             1M
              MAXSIZE          UNLIMITED
              MINEXTENTS       1
              MAXEXTENTS       UNLIMITED
              PCTINCREASE      0
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;

ALTER INDEX MOBR5.PK_MOB_TRACEABLE_REQUESTS
  MONITORING USAGE;


-- 
-- Non Foreign Key Constraints for Table MOB_TRACEABLE_REQUESTS 
-- 
ALTER TABLE MOBR5.MOB_TRACEABLE_REQUESTS ADD (
  CONSTRAINT PK_MOB_TRACEABLE_REQUESTS
  PRIMARY KEY
  (ID_ENTITY, DAT_CREATION)
  USING INDEX LOCAL
  ENABLE VALIDATE);

GRANT SELECT ON MOBR5.MOB_TRACEABLE_REQUESTS TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_TRACEABLE_REQUESTS TO TCB_MBB_DEVL3;

====================================
====================================
====================================
1.PREPARE NEW DATABASE 
-- create database
dbca -silent -deleteDatabase -sourceDB mbbdr -sysDBAUserName sys -sysDBAPassword db#Chivas#123
dbca -silent -deleteDatabase -sourceDB mbbdb -sysDBAUserName sys -sysDBAPassword PAssw0rd

dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName mbbdb \
-databaseType OLTP \
-createAsContainerDatabase false \
-databaseConfType RACONENODE \
-RACOneNodeServiceName mbbdb_dc \
-sid mbbdb \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-datafileDestination +DATA01 \
-redoLogFileSize 4096 \
-recoveryAreaDestination +FRA \
-recoveryAreaSize 128300 \
-enableArchive true \
-archiveLogDest +FRA \
-storageType ASM \
-nodelist dc-mbb-db-01,dc-mbb-db-02 \
-diskGroupName DATA01 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 24576 

alter database add logfile thread 1 group 11 ('+DATA01','+FRA') size 4G;
alter database add logfile thread 1 group 12 ('+DATA01','+FRA') size 4G;

alter database add logfile thread 2 group 21 ('+DATA01','+FRA') size 4G;
alter database add logfile thread 2 group 22 ('+DATA01','+FRA') size 4G;

alter database add logfile thread 1 group 13 ('+DATA01','+FRA') size 4G;
alter database add logfile thread 1 group 14 ('+DATA01','+FRA') size 4G;
alter database add logfile thread 1 group 15 ('+DATA01','+FRA') size 4G;
alter database add logfile thread 1 group 16 ('+DATA01','+FRA') size 4G;

--> TCTSCH

revoke execute on SYS.UTL_TCP from public;
revoke execute on SYS.UTL_HTTP from public;
revoke execute on SYS.DBMS_SQL from public;
revoke execute on SYS.UTL_FILE from public;
revoke execute on SYS.HTTPURITYPE from public;
revoke execute on SYS.DBMS_XMLGEN from public;
revoke execute on SYS.DBMS_ADVISOR from public;
revoke execute on SYS.DBMS_SCHEDULER from public;
revoke execute on SYS.UTL_INADDR from public;
revoke execute on SYS.UTL_SMTP from public;
revoke execute on SYS.DBMS_JOB from public;
revoke execute on SYS.DBMS_OBFUSCATION_TOOLKIT from public;
revoke execute on SYS.DBMS_RANDOM from public;
revoke execute on SYS.DBMS_LDAP from public;
revoke execute on SYS.DBMS_JAVA from public;
revoke execute on SYS.DBMS_XMLQUERY from public;
revoke execute on SYS.DBMS_AW_XML from public;
revoke execute on CTXSYS.DRITHSX from public;
revoke execute on ORDSYS.ORD_DICOM from public;



--environment variables 
--vi mbbdb 
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export ORACLE_SID=mbbdb_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
env|grep ORA
alias alert="tail -300f /u01/app/oracle/diag/rdbms/mbbdb/$ORACLE_SID/trace/alert_$ORACLE_SID.log"

--on primary
ALTER DATABASE FORCE LOGGING;
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST valid_for=(ALL_LOGFILES,ALL_ROLES)' scope=both sid='*';
alter system set log_archive_dest_2='service=mbbdr LGWR ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 max_connections=1 reopen=300 
db_unique_name=mbbdr net_timeout=30 valid_for=(all_logfiles,primary_role)' sid='*' scope=both;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;
alter system set fal_client='mbbdb' scope=both sid='*';
alter system set fal_server='mbbdr'  scope=both sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(mbbdb,mbbdr)' scope=both sid='*';

ALTER SYSTEM SET DB_FILE_NAME_CONVERT='mbbdr','mbbdb' SCOPE=SPFILE  sid='*';
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='mbbdr','mbbdb'  SCOPE=SPFILE  sid='*';
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO  sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.arc' SCOPE=SPFILE  sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=30  sid='*';
ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE SCOPE=SPFILE  sid='*';

sho parameter dg_broker
alter system set dg_broker_start=false scope=both sid='*';
alter system set dg_broker_config_file1='+DATA01/MBBDB/broker_mbbdb1.dat' sid='*' scope=both;
alter system set dg_broker_config_file2='+DATA01/MBBDB/broker_mbbdb2.dat' sid='*' scope=both;
alter system set dg_broker_start=true scope=both sid='*';

--compare parameter with current system 
create pfile='/home/oracle/initmbbdr.ora' from spfile;
--modify pfile for standby database - with log_archive_dest_2=''
--copy password file
--startup nomount standby database with pfile
srvctl add database -d mbbdr -oraclehome /u01/app/oracle/product/12.2.0/dbhome_1 -dbtype RACONENODE -server dr-mbb-db-01,dr-mbb-db-02 -instance mbbdr -spfile +DATA01/MBBDR/PARAMETERFILE/spfilembbdr.ora -pwfile +data01/mbbdr/PASSWORD/pwdmbbdr -role PHYSICAL_STANDBY -startoption MOUNT -stopoption IMMEDIATE -dbname mbbdb -diskgroup FRA,DATA01,REDO02,REDO01 

srvctl remove database -db mbbdr  

srvctl add database -db mbbdr      -oraclehome /u01/app/oracle/product/12.2.0/dbhome_1    -spfile +DATA01/MBBDR/PARAMETERFILE/spfilembbdr.ora -pwfile +data01/mbbdr/PASSWORD/pwdmbbdr     -dbtype  RACONENODE        -role PHYSICAL_STANDBY     -startoption mount -stopoption IMMEDIATE -dbname mbbdb           -serverpool "dr-mbb-db-01,dr-mbb-db-02"     -diskgroup "DATA01,REDO01,REDO02,FRA"

-- shutdown and startup nomount
srvctl start database -d mbbdr -startoption NOMOUNT

--config static listener + tnsnames on DC and DR
SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbbdb)
   (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
   (SID_NAME = mbbdb_1)
  )
) 

MBBDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.99.1.187)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = mbbdb)
      (SID = mbbdb_1)
      (UR=A)
    )
  )
  
--duplicate 
rman target DBSNMP/PAssw0rd@mbbdb1 AUXILIARY DBSNMP/PAssw0rd@mbbdr1
duplicate target database for standby from active database nofilenamecheck;
 
--modify controlfile of standby database 
*.control_files='+DATA01/MBBDR/CONTROLFILE/current.266.1002816451','+FRA/MBBDR/CONTROLFILE/current.257.1002816455'
--create spfile from pfile 
create spfile='+DATA01/MBBDR/PARAMETERFILE/spfilembbdr.ora' from spfile;
srvctl modify database -d mbbdr -spfile +DATA01/MBBDR/PARAMETERFILE/spfilembbdr.ora
--startup with spfile

--config in both DC and DR
SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbbdb_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = mbbdb_1)
  )
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbbdb_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = mbbdb_2)
  )  
)  

SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbbdr_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = mbbdr_1)
  )
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbbdr_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = mbbdr_2)
  )  
)  

--Configure the Data Guard Configuration 
-- on DC
dgmgrl /
show configuration;
create configuration mbbdb_broker as primary database is mbbdb connect identifier is mbbdb;
add database mbbdr as connect identifier is mbbdr maintained as physical; 
ENABLE CONFIGURATION;
show configuration

--on DR
show configuration

--View the Primary and Standby database properties 
show database verbose mobsms
show database verbose mbsmsdr

-------
---ORA-01017
 mikedietrichde.com/2017/04/24/having-some-fun-with-sec_case_sensitive_logon-and-ora-1017/


========GGSCI > edit params ETEST
EXTRACT ETEST
SETENV (ORACLE_SID="mbbdb1")
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
userid ggate_user@mbbdb, password GGateUser#123
TRANLOGOPTIONS DBLOGREADER
FETCHOPTIONS  FETCHPKUPDATECOLS, USESNAPSHOT, USELATESTVERSION
DBOPTIONS ALLOWUNUSEDCOLUMN
CACHEMGR CACHESIZE 500M
DISCARDFILE /gg_data/goldengate/dirrpt/ext_mob.dsc, APPEND, MEGABYTES 100
EXTTRAIL /gg_data/goldengate/dirdat/dc
WARNLONGTRANS 1H, CHECKINTERVAL 1H
TABLE DBA01.TEST_GG;

 select distinct 'TABLE MOBR5.'||table_name||';' from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED'

GGSCI > edit params PTEST
EXTRACT PTEST
userid ggate_user@mbbdb, password GGateUser#123
SETENV (ORACLE_HOME="/u01/app/oracle/product/11.2.0/dbhome_1")
RMTHOST 10.99.1.187, MGRPORT 7900
RMTTRAIL /gg_data/goldengate/dirdat/dp
DBOPTIONS ALLOWUNUSEDCOLUMN
TABLE DBA01.TEST_GG;

GGSCI > ADD EXTRACT ETEST, TRANLOG, BEGIN NOW, THREADS 2
GGSCI > add exttrail /gg_data/goldengate/dirdat/dc,extract ETEST

GGSCI > add extract PTEST, exttrailsource /gg_data/goldengate/dirdat/dc
GGSCI > add rmttrail /gg_data/goldengate/dirdat/dp,extract PTEST

GGSCI > INFO EXTTRAIL *
GGSCI > ALTER EXTTRAIL /gg_data/goldengate/dirdat/dc, EXTRACT ETEST, MEGABYTES 1024
GGSCI > ALTER EXTTRAIL /gg_data/goldengate/dirdat/dp, EXTRACT PTEST, MEGABYTES 1

--[TARGET]
GGSCI > dblogin userid ggate_user, password ggate_user
GGSCI > edit params RTEST
REPLICAT RTEST
SETENV (ORACLE_HOME = "/u01/app/oracle/product/12.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbbdb_2")
USERID ggate_user, PASSWORD GGateUser#123
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
ASSUMETARGETDEFS
HANDLECOLLISIONS
DISCARDFILE /gg_data/goldengate/dirrpt/REP_S1.dsc,append
MAP DBA01.TEST_GG,TARGET THUYNTM_DBA.TEST_GG;--> get result from below sql

 select distinct 'MAP MOBR5.'||table_name||',TARGET MOBR5'||table_name||';' from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED'

GGSCI > stop mgr
GGSCI > start mgr

GGSCI > add replicat RTEST, exttrail /gg_data/goldengate/dirdat/dp --checkpointtable gguser.chkpt

--[SOURCE]
GGSCI > START EXT_MOB
GGSCI > START EXTMOB_P

--4	Export data from current database
expdp \"/ as sysdba\" dumpfile=initload.dmp logfile=initload.log directory=DATA_PUMP_DIR schemas=MOBR5 cluster=n  INCLUDE=TABLE:\"IN\(select  table_name from dba_tables where table_name not in \(select distinct table_name from dba_constraints where constraint_type  in \(\'U\', \'P\'\) and table_name not IN\(\'EVT_ENTRY_HANDLER\',\'MOB_AUDIT_LOGS\',\'MOB_AUDIT_LOGS_HIST\',\'MOB_TRACEABLE_REQUESTS\',\'AMS_BOOKINGS_HIST\',\'MOB_FEES_HIST\',\'MOB_TXN_ATTRIBUTES_HIST\',\'AMS_PI_BALANCES_HIST\',\'MOB_INV_TXNS_HIST\',\'AMS_DOCS_HIST\',\'TCB_PUBLIC_INBOX_CUSTOMER_HIST\',\'TCB_PRIVATE_INBOX_HIST\',\'TCB_PUBLIC_INBOX_HIST\'   ,\'AMS_DOCS_20170530\',\'AMS_PI_BALANCES_20170530\',\'EVT_ENTRY_DATA_OLD\',\'EVT_ENTRY_HANDLER_HIST2\',\'EVT_ENTRY_HANDLER_OLD\',\'EVT_ENTRY_HIST2\',\'EVT_ENTRY_OLD\',\'MOB_BENEFICIARIES_201810\',\'MOB_CUS_BK20181115\',\'MOB_CUSTOMERS_IDEN_BK\',\'MOB_FEES_20170530\',\'MOB_INV_TXNS_20170530\',\'MOB_SESSIONS_HIST\',\'MOB_SUB_TXNS_20170530\',\'MOB_SUB_TXNS_HIST\',\'MOB_TXN_ATTRIBUTES_20170530\',\'MOB_TXNS_20170530\',\'MOB_TXNS_HIST\',\'MOB_USE_CASE_PRIVILEGES_BK\',\'TCB_CITAD_BANKS_BK\',\'TCB_PIC_READ_20170116\',\'TCB_PRIVATE_INBOX_20170116\',\'TCB_PUBLIC_INBOX_20170116\'\) and owner=\'MOBR5\' \)\)\" 

"
--5	Import data into new database
-- TRANSFER THE DUMP TO TARGET SERVER:
[ON OLD DB]
umount /stage

[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage
 
-- IMPORT IN TARGET DATABASE:
impdp \"/ as sysdba\" dumpfile=initload.dmp logfile=imp_initialload.log directory=DUMP
"

--6	Start extract and replicate, check for sync between 2 database
--on [ TARGET ]
GGSCI > start REP_S1

--7	Compare number of row between 2 evironments/ Check object consistency between 2 environments


====EXTRACT ext_test
SETENV (ORACLE_SID="mbbtest_2")
SETENV (ORACLE_HOME="/u01/app/oracle/product/12.2.0/dbhome_1")
userid ggate_user@mbbtest, password ggate_user
TRANLOGOPTIONS DBLOGREADER
FETCHOPTIONS  FETCHPKUPDATECOLS, USESNAPSHOT, USELATESTVERSION
DBOPTIONS ALLOWUNUSEDCOLUMN
THREADOPTIONS PROCESSTHREADS EXCEPT 2
CACHEMGR CACHESIZE 500M
DISCARDFILE /u01/gg_data/dirrpt/ext_test.dsc, APPEND, MEGABYTES 100
EXTTRAIL /u01/gg_data/dirdat/et
WARNLONGTRANS 1H, CHECKINTERVAL 1H
TABLE MOBR5.TEST_GG;


EXTRACT dumptest
userid ggate_user@mbbtest, password ggate_user
SETENV (ORACLE_HOME="/u01/app/oracle/product/12.2.0/dbhome_1")
RMTHOST 10.101.5.129, MGRPORT 7809
RMTTRAIL /u01/gg_data/dirdat/etp
DBOPTIONS ALLOWUNUSEDCOLUMN
TABLE MOBR5.TEST_GG;

REPLICAT rep_test
SETENV (ORACLE_HOME = "/u01/app/oracle/product/11.2.0/dbhome_1")
SETENV (ORACLE_SID = "mbb11gt2")
USERID ggate_user@mbb11gt, PASSWORD ggate_user
DBOPTIONS SUPPRESSTRIGGERS,DEFERREFCONST
ASSUMETARGETDEFS
HANDLECOLLISIONS
DISCARDFILE /u01/gg_data/dirrpt/rep_test.dsc,append 
MAP MOBR5.TEST_GG,TARGET MOBR5.TEST_GG;

ADD EXTRACT ext_test, TRANLOG, BEGIN NOW, THREADS 2
add exttrail /u01/gg_data/dirdat/et,extract ext_test

add extract dumptest, exttrailsource /u01/gg_data/dirdat/et
add rmttrail /u01/gg_data/dirdat/etp,extract dumptest

INFO EXTTRAIL *
ALTER EXTTRAIL /u01/gg_data/dirdat/et, EXTRACT ext_test, MEGABYTES 1
ALTER EXTTRAIL /u01/gg_data/dirdat/ep, EXTRACT dumptest, MEGABYTES 1


add replicat rep_test, exttrail /u01/gg_data/dirdat/ep
