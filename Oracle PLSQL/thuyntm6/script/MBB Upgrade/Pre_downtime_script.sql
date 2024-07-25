----1.[ON NEW SERVER] Create database, configure parameter standard
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

--create dump directory
create or replace directory UPGR_PUMP_12C as '/stage/dump';

--add redolog files
alter database add logfile thread 1 group 11 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 12 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 13 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 14 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 15 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 16 ('+REDO01','+REDO02') size 4G;

alter database add logfile thread 1 group 21 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 22 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 23 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 24 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 25 ('+REDO01','+REDO02') size 4G;
alter database add logfile thread 1 group 26 ('+REDO01','+REDO02') size 4G;

--drop old redolog files

--create tablespace + add datafile to temp tablespace
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

alter  tablespace TEMP  add tempfile '+DATA01' size 31G ;
alter  tablespace TEMP  add tempfile '+DATA01' size 31G ;
alter  tablespace TEMP  add tempfile '+DATA01' size 31G ;

--TCTSCH
CREATE FUNCTION "SYS"."ORA_VERIFY_FUNCTION"
(username varchar2,
 password varchar2,
 old_password varchar2)
RETURN boolean IS
   differ integer;
   db_name varchar2(40);
   i integer;
BEGIN
   IF NOT ora_complexity_check(password, chars => 12, upper => 1, lower => 1, digit => 1, special => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password contains the server name
   select name into db_name from sys.v$database;
   IF regexp_instr(password, db_name, 1, 1, 0, 'i') > 0 THEN
      raise_application_error(-20004, 'Password contains the server name');
   END IF;

   -- Check if the password contains 'oracle'
   IF regexp_instr(password, 'oracle', 1, 1, 0, 'i') > 0 THEN
        raise_application_error(-20006, 'Password too simple');
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 characters
   IF old_password IS NOT NULL THEN
     differ := ora_string_distance(old_password, password);
     IF differ < 3 THEN
        raise_application_error(-20010, 'Password should differ from the '
                                || 'old password by at least 3 characters');
     END IF;
   END IF ;

   RETURN(TRUE);
END;
/

GRANT EXECUTE ON ORA_VERIFY_FUNCTION TO PUBLIC;

create PROFILE "PROFILE_ENDUSER" LIMIT
  SESSIONS_PER_USER 10
  CPU_PER_SESSION DEFAULT
  CPU_PER_CALL DEFAULT
  IDLE_TIME DEFAULT
  LOGICAL_READS_PER_SESSION DEFAULT
  LOGICAL_READS_PER_CALL DEFAULT
  COMPOSITE_LIMIT DEFAULT
  PRIVATE_SGA DEFAULT
  FAILED_LOGIN_ATTEMPTS 5
  PASSWORD_LIFE_TIME 60
  PASSWORD_REUSE_TIME 240
  PASSWORD_REUSE_MAX 4
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 0
  PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;

CREATE PROFILE "PROFILE_SERVICE_ACCOUNT" LIMIT
PASSWORD_LIFE_TIME UNLIMITED
SESSIONS_PER_USER UNLIMITED
FAILED_LOGIN_ATTEMPTS UNLIMITED
PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;

CREATE PROFILE "DBA_PROFILE" LIMIT
PASSWORD_LIFE_TIME UNLIMITED
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LOCK_TIME 1
PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;

alter user dbsnmp identified by PAssw0rd;
grant sysdba to dbsnmp;
alter user dbsnmp account unlock;

Create user dba01 identified by Qwerty#12345;
grant sysdba to dba01;
Create user dba02 identified by Qwerty#12345;
grant sysdba to dba02;

alter user sys profile DBA_PROFILE;
alter user system profile DBA_PROFILE;
alter user DBA01 profile DBA_PROFILE;
alter user DBA02 profile DBA_PROFILE;
alter user DBSNMP profile DBA_PROFILE;

alter system set sec_return_server_release_banner = false scope=spfile sid='*';
alter system set audit_trail = os scope=spfile sid='*';
alter system set audit_sys_operations=true scope=spfile sid='*';
alter system set remote_os_roles = false scope=spfile sid='*';
alter system set o7_dictionary_accessibility=false scope=spfile sid='*';
alter system set sec_max_failed_login_attempts = 10 scope = spfile sid='*';
alter system set sec_protocol_error_further_action = 'drop,3' scope = spfile sid='*';
alter system set sec_protocol_error_trace_action=log scope = spfile sid='*';
alter system set sql92_security = true scope = spfile sid='*';
alter system set sec_case_sensitive_logon = true scope = both sid='*';

alter system set db_recovery_file_dest_size=1000G scope=both sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.arc' SCOPE=SPFILE  sid='*';

spool grant.sql
DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);
   cnt number;

   CURSOR c_tab
   IS
select owner||'.'||table_name as privs from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER'
,'DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS',
'UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;

BEGIN
   FOR v_tab IN c_tab
   LOOP
   for tab in (select username from dba_users where username not in 
   ('DBA01','DBA02','THUYNTM_DBA'))
   --year12 ('DBA01','DBA02','DBSNMP','HANGDT_USER','HOANNT_DBA','SRV_DB_BACKUP','THUYNTM_DBA','TRUNGHX_DBA'))
   --year13 ('DBA01','DBA02','DBSNMP','HOANNT_DBA','SRV_DB_BACKUP','THUYNTM_DBA'))
   --year14 ('ARCSIGHT','DBA01','DBA02','DBSNMP','DUYDX_DBA','HOANNT_DBA','SRV_BMC_T24DB','SRV_DB_BACKUP','THUYNTM_DBA','TRUNGHX_DBA','GG12'))
   --year15 ('ARCSIGHT','DBA01','DBA02','DBSNMP','GG12','HOANNT_DBA','SRV_BMC_T24DB','SRV_DBT24_GUARD','SRV_DB_BACKUP','THINHNH_DBA','THUYNTM_DBA','TRUNGHX_DBA'))    
   --year16 ('ARCSIGHT','DBA01','DBA02','DBSNMP','DUONGPK','GG12','HOANNT_DBA','SRV_DBT24_GUARD','SRV_DB_BACKUP','THUYNTM_DBA'))
   --year17 ('DBA01','DBA02','DBSNMP','DUONGPK','GG12','HOANNT_DBA','SRV_BMC_T24DB','SRV_DBT24_GUARD','SRV_DB_BACKUP','THUYNTM6','THUYNTM_DBA'))
   --t24rptdc ('DBSNMP','THUYNTM_DBA'))
   loop
   cmd3 := 'select count(*)  from dba_tab_privs where grantee='''||tab.username||''' and owner||''.''||table_name='''||v_tab.privs||'''';
   --DBMS_OUTPUT.put_line (cmd3);
   EXECUTE IMMEDIATE cmd3 into cnt;
   --DBMS_OUTPUT.put_line (cnt);
   if cnt =0 then 
      cmd2 :='revoke execute on '|| v_tab.privs ||' from '||tab.username||';';
      cmd2 :='grant execute on '|| v_tab.privs ||' to '||tab.username||';';
   DBMS_OUTPUT.put_line (cmd2); 
   end if;  
end loop;
   END LOOP;
   EXCEPTION
        WHEN OTHERS THEN
            NULL;
END;
/
spool off

--revoke
select 
'revoke execute on '||owner||'.'||table_name||' from public;' as privs 
--rollback 'grant execute on '||owner||'.'||table_name||' to public;' as privs 
from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER'
,'DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS',
'UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;

--change database to noarchivelog mode
shutdown immediate;
startup mount;
alter database noarchivelog;
alter database open;

----2.[ON NEW DB] create MOBR5 user (in LOCK mode) and create history table
--create user

alter user MOBR5 account lock;

--create history tables (32 tables)


----3.Export old data of "history table" (which is big) [ON OLD DB]
create or replace directory UPGR_PUMP as '/stage/dump';

vi export_hist_par.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdr1 
export PAR_FILE=/home/oracle/current_partition.txt
export HIS_FILE=/home/oracle/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/export_hist_par_${datetime}.log
echo > $ORA_LOG

expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP tables=MOBR5.AMS_BOOKINGS_HIST,MOBR5.AMS_DOCS_20170530,MOBR5.AMS_DOCS_HIST,MOBR5.AMS_PI_BALANCES_20170530,MOBR5.AMS_PI_BALANCES_HIST,MOBR5.EVT_ENTRY_DATA_OLD,MOBR5.EVT_ENTRY_HANDLER_HIST2,MOBR5.EVT_ENTRY_HANDLER_OLD,MOBR5.EVT_ENTRY_HIST2,MOBR5.EVT_ENTRY_OLD,MOBR5.MOB_AUDIT_LOGS_HIST,MOBR5.MOB_BENEFICIARIES_201810,MOBR5.MOB_CUS_BK20181115,MOBR5.MOB_CUSTOMERS_IDEN_BK,MOBR5.MOB_FEES_20170530,MOBR5.MOB_FEES_HIST,MOBR5.MOB_INV_TXNS_20170530,MOBR5.MOB_INV_TXNS_HIST,MOBR5.MOB_SESSIONS_HIST,MOBR5.MOB_SUB_TXNS_20170530,MOBR5.MOB_SUB_TXNS_HIST,MOBR5.MOB_TXN_ATTRIBUTES_20170530,MOBR5.MOB_TXN_ATTRIBUTES_HIST,MOBR5.MOB_TXNS_20170530,MOBR5.MOB_TXNS_HIST,MOBR5.MOB_USE_CASE_PRIVILEGES_BK,MOBR5.TCB_CITAD_BANKS_BK,MOBR5.TCB_PIC_READ_20170116,MOBR5.TCB_PRIVATE_INBOX_20170116,MOBR5.TCB_PRIVATE_INBOX_HIST,MOBR5.TCB_PUBLIC_INBOX_20170116,MOBR5.TCB_PUBLIC_INBOX_CUSTOMER_HIST,MOBR5.TCB_PUBLIC_INBOX_HIST dumpfile=backup_data%u.dmp logfile=exp_backup_data.log exclude=statistics cluster=N parallel=8  


while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  content=data_only cluster=N
done < "$HIS_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG

"
----4.Mount mountpoint contain export data to new server
--[ON OLD DB]
umount /stage

--[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage

----5.Import these data into new database
vi import_hist_par.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1 
export PAR_FILE=/stage/dump/current_partition.txt
export HIS_FILE=/stage/dump/history_partition.txt
datetime=`date +%Y%m%d`
ORA_LOG=/stage/dump/impdp_hist_par_${datetime}.log
echo > $ORA_LOG

impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C dumpfile=backup_data%u.dmp logfile=imp_backup_data.log cluster=N parallel=8 

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  
done < "$HIS_FILE"

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG

"
----6.Compare number of row between 2 evironments
vi  obj_count_main_bktable.sql
set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool bktable_obj_row_count.sql
prompt spool obj_row_count_output_bktable.log
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 20) */ ' end
        || ' rpad(''' || owner ||'.'||table_name || ''',60) tab_name, count(1) cnt from ' || owner || '."' || table_name || '" a;' 
from 
(select owner, table_name, blocks from dba_tables where owner not in 
('ORDDATA','SYSMAN','APEX_030200','OWBSYS_AUDIT','OUTLN','OWBSYS','SCOTT','FLOWS_FILES','OE',
'OLAPSYS','MDDATA','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'PUBLIC','SYSTEM','APPQOSSYS','XDB','SYS','MDSYS','EXFSYS','SI_INFORMTN_SCHEMA','ORACLE_OCM',
'WMSYS','ORDSYS','CTXSYS','ORDPLUGINS','DBSNMP'
,'AUDSYS','DBSFWUSER','DVF','DVSYS','LBACSYS','OJVMSYS','REMOTE_SCHEDULER_AGENT','GSMADMIN_INTERNAL')
and table_name in ('AMS_BOOKINGS_HIST','AMS_DOCS_20170530','AMS_DOCS_HIST','AMS_PI_BALANCES_20170530','AMS_PI_BALANCES_HIST','EVT_ENTRY_DATA_OLD',
'EVT_ENTRY_HANDLER_HIST2','EVT_ENTRY_HANDLER_OLD','EVT_ENTRY_HIST2','EVT_ENTRY_OLD','MOB_AUDIT_LOGS_HIST','MOB_BENEFICIARIES_201810',
'MOB_CUS_BK20181115','MOB_CUSTOMERS_IDEN_BK','MOB_FEES_20170530','MOB_FEES_HIST','MOB_INV_TXNS_20170530','MOB_INV_TXNS_HIST','MOB_SESSIONS_HIST',
'MOB_SUB_TXNS_20170530','MOB_SUB_TXNS_HIST','MOB_TXN_ATTRIBUTES_20170530','MOB_TXN_ATTRIBUTES_HIST','MOB_TXNS_20170530','MOB_TXNS_HIST',
'MOB_USE_CASE_PRIVILEGES_BK','TCB_CITAD_BANKS_BK','TCB_PIC_READ_20170116','TCB_PRIVATE_INBOX_20170116','TCB_PRIVATE_INBOX_HIST','TCB_PUBLIC_INBOX_20170116',
'TCB_PUBLIC_INBOX_CUSTOMER_HIST','TCB_PUBLIC_INBOX_HIST')
) order by owner, table_name;
select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 20) */ ' end
        || ' rpad(''' || table_owner ||'.'||table_name||'.'||partition_name || ''',80) tab_name, count(1) cnt from ' || table_owner || '."' || table_name || '" a;' 
from 
(select table_owner,table_name,partition_name,blocks from dba_tab_partitions where table_name in  ('EVT_ENTRY_HANDLER','MOB_AUDIT_LOGS','MOB_TRACEABLE_REQUESTS')
) order by table_owner, table_name;
prompt spool off;
spool off;
@bktable_obj_row_count.sql

