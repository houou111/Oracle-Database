----1.Config standby to new database
--backup primary database

--[PRIMARY]
ALTER DATABASE FORCE LOGGING;
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST valid_for=(ALL_LOGFILES,ALL_ROLES)' scope=both sid='*';
alter system set log_archive_dest_2='service=mbbdr LGWR ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 max_connections=1 reopen=300 db_unique_name=mbbdr net_timeout=30 valid_for=(all_logfiles,primary_role)' sid='*' scope=both;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE;
alter system set fal_client='mbbdb' scope=both sid='*';
alter system set fal_server='mbbdr'  scope=both sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(mbbdb,mbbdr)' scope=both sid='*';

ALTER SYSTEM SET DB_FILE_NAME_CONVERT='mbbdr','mbbdb' SCOPE=SPFILE  sid='*';
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='mbbdr','mbbdb'  SCOPE=SPFILE  sid='*';
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO  sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=30  sid='*';
ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE SCOPE=SPFILE  sid='*';

sho parameter dg_broker
alter system set dg_broker_start=false scope=both sid='*';
alter system set dg_broker_config_file1='+DATA01/MBBDB/broker_mbbdb1.dat' sid='*' scope=both;
alter system set dg_broker_config_file2='+DATA01/MBBDB/broker_mbbdb2.dat' sid='*' scope=both;
alter system set dg_broker_start=true scope=both sid='*';

--compare parameter with current system 
create pfile='/home/oracle/initmbbdr.ora' from spfile;
--[STANDBY]
--modify pfile for standby database - with log_archive_dest_2=''
--copy password file
--startup nomount standby database with pfile
srvctl add database -d mbbdr -oraclehome /u01/app/oracle/product/12.2.0/dbhome_1 -dbtype RACONENODE -server dr-mbb-db-01,dr-mbb-db-02 -instance mbbdr -pwfile +data01/mbbdr/PASSWORD/pwdmbbdr -role PHYSICAL_STANDBY -startoption MOUNT -stopoption IMMEDIATE -dbname mbbdb -diskgroup FRA,DATA01,REDO02,REDO01 
-- shutdown and startup nomount
srvctl start database -d mbbdr -startoption NOMOUNT

--config static listener + tnsnames on DC and DR
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
  
--restore 

 
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


----2.On new DB, create MOBR5 user (in LOCK mode)
CREATE USER "MOBR5" IDENTIFIED BY VALUES 'S:1F2E472D6E6A3D9FFEAFBEBC3476E87C62EC0F1F9EC88A6AEE8EFB8452E2;83331504FD9B3022'  
   DEFAULT TABLESPACE "MOBR5"       
      TEMPORARY TABLESPACE "TEMP"         
      PROFILE "PROFILE_SERVICE_ACCOUNT"
	  account lock; 

  -- 2 Roles for MOBR5 
  GRANT CONNECT TO MOBR5;
  GRANT SY365_OBJOWNER TO MOBR5;
  ALTER USER MOBR5 DEFAULT ROLE ALL;
  -- 2 System Privileges for MOBR5 
  GRANT CREATE EXTERNAL JOB TO MOBR5;
  GRANT CREATE SESSION TO MOBR5;
  -- 1 Tablespace Quota for MOBR5 
  ALTER USER MOBR5 QUOTA UNLIMITED ON MOBR5;
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
    GRANT EXECUTE ON SYS.DBMS_REPCAT_SQL_UTL TO MOBR5;
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
    GRANT EXECUTE ON SYS.UTL_MAIL TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_SMTP TO MOBR5;
    GRANT EXECUTE ON SYS.UTL_TCP TO MOBR5;
	
	grant unlimited tablespace to mobr5;
	
create table ...MOB_TRACEABLE_REQUESTS, MOB_AUDIT_LOGS, EVT_ENTRY_HANDLER --> MOBR5
MOB_AUDIT_LOGS_HIST --> MOB_HIST

===
COMMENT ON TABLE MOBR5.MOB_TRACEABLE_REQUESTS IS 'This table tracks all traceable requests (potentially purged at some intervalls) and is used to track duplicate requests.';

CREATE INDEX MOBR5.IDX_ORIG_TRACE ON MOBR5.MOB_TRACEABLE_REQUESTS
(STR_ORIGIN, STR_TRACE_NO, INT_TIME_SEGMENT)
  TABLESPACE MOBR5
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

ALTER INDEX MOBR5.IDX_ORIG_TRACE  MONITORING USAGE;

CREATE UNIQUE INDEX MOBR5.PK_MOB_TRACEABLE_REQUESTS ON MOBR5.MOB_TRACEABLE_REQUESTS
(ID_ENTITY, DAT_CREATION)
  TABLESPACE MOBR5
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

ALTER INDEX MOBR5.PK_MOB_TRACEABLE_REQUESTS  MONITORING USAGE;

ALTER TABLE MOBR5.MOB_TRACEABLE_REQUESTS ADD (
  CONSTRAINT PK_MOB_TRACEABLE_REQUESTS
  PRIMARY KEY
  (ID_ENTITY, DAT_CREATION)
  USING INDEX LOCAL
  ENABLE VALIDATE);

GRANT SELECT ON MOBR5.MOB_TRACEABLE_REQUESTS TO TCB_MBB_APO;

GRANT SELECT ON MOBR5.MOB_TRACEABLE_REQUESTS TO TCB_MBB_DEVL3;


----4.Export old data of "history table" (which is big)
vi /home/oracle/history_partition.txt
with sersult from below command
select table_name, partition_name, partition_position from dba_tab_partitions 
where table_name in ('MOB_TRACEABLE_REQUESTS','MOB_AUDIT_LOGS','EVT_ENTRY_HANDLER');

vi export_hist_par.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb1 
export HIS_FILE=/home/oracle/history_partition.txt
datetime=`date +%Y%m%d`

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    expdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP  tables=MOBR5.$table_name:$par_name dumpfile=${table_name}_${par_name}.dmp logfile=exp_${table_name}_${par_name}.log  content=data_only cluster=N
done < "$HIS_FILE"

"
nohup sh export_hist_par.sh &
--check if have any error

----5.Mount mountpoint contain export data to new server
--[ON OLD DB]

umount /stage

--[ON NEW DB]
mount /dev/vg_stage/lv_stage /stage
chown -R oracle:oinstall /stage
----6.Import these data into new database

vi import_hist_par.sh
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=mbbdb_1 
export HIS_FILE=/stage/dump/history_partition.txt
datetime=`date +%Y%m%d`

while read line; do
    name="$line"
	table_name=`echo $line| awk '{print $1}' `
	par_name=`echo $line| awk '{print $2}' `
    impdp \"/ as sysdba\" DIRECTORY=UPGR_PUMP_12C  dumpfile=${table_name}_${par_name}.dmp logfile=imp_${table_name}_${par_name}.log  
done < "$HIS_FILE"

"
----7.Compare number of row between 2 evironments
vi  obj_count_main.sql
set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool obj_row_count.sql
prompt spool obj_row_count_output.log
select 'select /*+ parallel (a, 20) */ '|| ' rpad(''' || table_owner ||'.'||table_name ||'.'||partition_name|| ''',80) tab_name, count(1) cnt from ' 
|| table_owner || '."' || table_name || '" partition ('||partition_name||') a;' 
from 
(select table_owner, table_name,partition_name from dba_tab_partitions where table_owner ='MOBR5'
and table_name  in ('MOB_TRACEABLE_REQUESTS','MOB_AUDIT_LOGS','EVT_ENTRY_HANDLER')
) order by table_owner, table_name;
prompt spool off;
spool off;
@obj_row_count.sql