ORA-00700: soft internal error, arguments: [kskvmstatact: excessive swapping observed],

ORA-00600: internal error code, arguments: [qmxBitCheck:overflow]
ORA-00600: internal error code, arguments: [qmr_hdl_copy:1]

SELECT RECID FROM "FBNK_ACCT_STMT_PRINT"  7/17/2019 9:51:45 AM --> 7/17/2019 10:18:21.663 AM
SELECT RECID FROM "FBNK_RE_STAT_LINE_MVMT" 7/17/2019 10:29:24 AM-->  7/17/2019 12:19:06.079 PM

PRCD-1133 : failed to start services mbbdb_dr for database mbbdr
PRCR-1095 : Failed to start resources using filter ((NAME == ora.mbbdr.mbbdb_dr.svc) AND (TYPE == ora.service.type))
CRS-2800: Cannot start resource 'ora.mbbdr.db' as it is already in the INTERMEDIATE state on server 'dr-mbb-db-01'
CRS-2527: Unable to start 'ora.mbbdr.mbbdb_dr.svc' because it has a 'hard' dependency on 'ora.mbbdr.db'
CRS-2525: All instances of the resource 'ora.mbbdr.db' are already running; relocate is not allowed because the force option was not specified


Procedure created.

T24LIVE@t24test31 > set time on timi on
16:29:32 T24LIVE@t24test31 > exec db_conversion_check;

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.15
16:29:49 T24LIVE@t24test31 > select count(*) from blob_conversion_fail;

  COUNT(*)
----------
         0

Elapsed: 00:00:00.00
16:30:09 T24LIVE@t24test31 > select count(*) from t24live.BLOB_CONVERSION_FAIL;

  COUNT(*)
----------
         0

Elapsed: 00:00:00.00
16:30:43 T24LIVE@t24test31 >  SELECT /*+PARALLEL(4)  */ ORCLFILENAME,RECID FROM TAFJ_VOC WHERE ORCLFILENAME LIKE 'F_%' AND ORCLDICTNAME LIKE 'D_%' AND ISBLOB ='B';

no rows selected

Elapsed: 00:00:00.03
16:31:46 T24LIVE@t24test31 > 


ARNING: too many parse errors, count=200 SQL hash=0x750004bb
PARSE ERROR: ospid=13510, error=933 for statement: 
2019-06-27T10:48:46.426832+07:00
DELETE FROM wri$_adv_sqlt_rtn_planWHERE task_id = :tid AND exec_name = :execution_name
Additional information: hd=0x16d14b178 phd=0x16d14c8d0 flg=0x28 cisid=0 sid=0 ciuid=0 uid=0 
2019-06-27T10:48:46.426971+07:00
----- PL/SQL Call Stack -----

IDX_ID_REF_TNX	6.103515625E-5	6.103515625E-5
IDX_TXNS_ERROR_LOCKED	4.67108154296875	2.2490234375
IDX_TXNS_PAYEE	5.0074462890625	2.068359375
IDX_TXNS_PAYER	3.927001953125	2.58123779296875					1q58jzc9ych5g
IDX_TXNS_MERCHANTID	8.4058837890625	3.4398193359375
IDX_TXNS_STATUS_ERROR	5.0584716796875  4.67108154296875
PK_TXNS2	8.3221435546875  2.46710205078125

SYS_C0015819	5.916015625	2.15625
IDX_MESSAGE_ACTIVE	3.8037109375	2.587890625
1000000
069hh79mv6cud

Sun May 19 06:06:07 2019
Archived Log entry 108361 added for thread 1 sequence 52667 ID 0xffffffff885d11c7 dest 1:
Sun May 19 06:08:38 2019


Mon May 20 23:29:42 2019
Archived Log entry 108862 added for thread 1 sequence 52666 rlc 970448607 ID 0x885d11c7 dest 12:
RFS[4]: Opened log for thread 1 sequence 52667 dbid 2153479117 branch 970448607
Mon May 20 23:29:46 2019


Mon May 20 23:31:42 2019
Media Recovery Waiting for thread 1 sequence 52667 (in transit)
Mon May 20 23:32:00 2019

Mon May 20 23:34:33 2019
Archived Log entry 108868 added for thread 1 sequence 52667 rlc 970448607 ID 0x885d11c7 dest 12:
Mon May 20 23:34:33 2019
Media Recovery Log +FRACOBR14_DR/COBR14DR/ARCHIVELOG/2019_05_20/thread_1_seq_52667.462.1008804583



select thread#, max(sequence#) "Last Primary Seq Generated" 
from v$archived_log val, v$database vdb 
where val.resetlogs_change# = vdb.resetlogs_change# 
group by thread# order by 1; 

   THREAD# Last Primary Seq Generated
---------- -------------------------
	1		41409
	2		39411


select inst_id, dest_id, status, error from gv$archive_dest where dest_id = 11; 

INST_ID	DEST_ID	STATUS	ERROR
1		11		VALID	
2		11		VALID	







SYS@t24r14dr2 > select thread#, max(sequence#) "Last Standby Seq Received" 
  2  from v$archived_log val, v$database vdb 
  3  where val.resetlogs_change# = vdb.resetlogs_change# 
  4  group by thread# order by 1; 

   THREAD# Last Standby Seq Received
---------- -------------------------
         1                     41409
         2                     39411

SYS@t24r14dr2 > select thread#, max(sequence#) "Last Standby Seq Applied" 
  2  from v$archived_log val, v$database vdb 
  3  where val.resetlogs_change# = vdb.resetlogs_change# 
  4  and val.applied in ('YES','IN-MEMORY') 
  5  group by thread# order by 1; 

   THREAD# Last Standby Seq Applied
---------- ------------------------
         1                    41389
         2                    39391

SYS@t24r14dr2 > select process,thread#,sequence#,status from gv$managed_standby; 

PROCESS      THREAD#  SEQUENCE# STATUS
--------- ---------- ---------- ------------
ARCH               2      39410 CLOSING
ARCH               2      39411 CLOSING
ARCH               0          0 CONNECTED
ARCH               1      41409 CLOSING
RFS                0          0 IDLE
RFS                0          0 IDLE
RFS                0          0 IDLE
RFS                1      41410 RECEIVING
RFS                0          0 IDLE
RFS                2      39412 RECEIVING
RFS                0          0 IDLE
MRP0               1      41393 APPLYING_LOG
ARCH               2      39378 CLOSING
ARCH               2      39372 CLOSING
ARCH               2      39352 CLOSING
ARCH               0          0 CONNECTED
RFS                0          0 IDLE

17 rows selected.


===============================================================================
--=========DATAGUARD
===============================================================================
SELECT to_char(current_scn) FROM V$DATABASE;
select scn_to_timestamp(10544384045892) as timestamp from dual; 

select * from v$archive_gap; 
alter database register logfile '+FRAT24R14_DR/T24R14DR/ARCHIVELOG/2019_03_19/thread_1_seq_43815.2044.1003282791'

select 'alter database register logfile '''||name||''';'
from v$archived_log
where thread#=2 and sequence#>=62247
##########
--check last receive and last apply
SELECT ARCH.THREAD# "Thread",
         ARCH.SEQUENCE# "Last Sequence Received",
         APPL.SEQUENCE# "Last Sequence Applied",
         (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
    FROM (SELECT THREAD#, SEQUENCE#
            FROM V$ARCHIVED_LOG
           WHERE (THREAD#, FIRST_TIME) IN (  SELECT THREAD#, MAX (FIRST_TIME)
                                               FROM V$ARCHIVED_LOG
                                           GROUP BY THREAD#)) ARCH,
         (SELECT THREAD#, SEQUENCE#
            FROM V$LOG_HISTORY
           WHERE (THREAD#, FIRST_TIME) IN (  SELECT THREAD#, MAX (FIRST_TIME)
                                               FROM V$LOG_HISTORY
                                           GROUP BY THREAD#)) APPL
   WHERE ARCH.THREAD# = APPL.THREAD#
ORDER BY 1;

##########
--
alter system set log_archive_config='dg_config=(t24r14dr,t24r14dc,cobr14dr,cobr14dc)' scope=both sid='*';

log_archive_dest_12                  string      service="cobr14dr" valid_for=(
                                                 all_logfiles,all_roles) db_uni
                                                 que_name="cobr14dr"


alter system set log_archive_dest_state_12=DEFER;
alter system set log_archive_dest_state_12=enable;

alter system set log_archive_dest_state_13=DEFER;
alter system set log_archive_dest_state_13=enable;
--all
dg_config=(t24r14dr,t24r14dc,cobr14dr,cobr14dc)
alter system set log_archive_dest_12='service="cobr14dr" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dr"' scope=both sid='*';
log_archive_dest_12 set   service="cobr14dr" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dr"

alter system set log_archive_dest_13 ='service="cobr14dc" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dc"' scope=both sid='*';

--t24r14dc
alter system set log_archive_config='dg_config=(t24r14dr,t24r14dc)' scope=both sid='*';
--t24r14dr
alter system set log_archive_config='dg_config=(t24r14dc,t24r14dr)' scope=both sid='*';
--cobr14dr--> done
alter system set log_archive_config='dg_config=(t24r14dr,cobr14dr)' scope=both sid='*';
--cobr14dc--> done
alter system set log_archive_config='dg_config=(t24r14dr,cobr14dc)' scope=both sid='*';
##########

select to_number(substr(value,2,3))*24*60+ to_number(substr(value,5,6))*60+to_number(substr(value,8,9))+to_number(substr(value,11,12))/60,
to_number(substr(value,2,3)),to_number(substr(value,5,6),to_number(substr(value,8,9)),to_number(substr(value,11,12))/60
 from v$dataguard_stats where name ='apply lag';
 select * from v$dataguard_stats where name ='apply lag';

--
select to_char(START_TIME,'dd.mm.yyyy hh24:mi:ss') "Recover_start",to_char(item)||' = '||to_char(sofar)||' '||to_char(units)||' '|| to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "Values" 
from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress);
select to_char(timestamp,'DD/MM/YYYY HH24:MI:SS') from v$recovery_progress where item='Last Applied Redo'

select PROCESS,STATUS,BLOCK#,BLOCKS,SEQUENCE#,THREAD#   from v$managed_standby;
select name, value from v$dataguard_stats;


select to_char(timestamp,'DD/MM/YYYY HH24:MI:SS')"SYNC Time" from v$recovery_progress where item='Last Applied Redo'
 and start_time=(select max(start_time) from v$recovery_progress);
--mount
ALTER DATABASE CONVERT TO SNAPSHOT STANDBY;
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

DROP VIEW DWHTWR.V_MESSAGE;

/* Formatted on 1/4/2018 4:59:51 PM (QP5 v5.252.13127.32867) */
CREATE OR REPLACE FORCE VIEW DWHTWR.V_MESSAGE
(
   BATCHID,
   ID,
   PROCESSEDTIME,
   DATA
)
AS
   SELECT batchid,
          id,
          PROCESSEDTIME,
          data
     FROM (SELECT a.batchid,
                  a.id,
                  b.PROCESSEDTIME,
                  a.data
             FROM twi.MESSAGE a, twi.batch b
            WHERE b.id = a.batchid AND b.direction = 1 AND b.instid = 2);

-----
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
alter DATABASE RECOVER MANAGED STANDBY DATABASE PARALLEL 8 USING CURRENT LOGFILE DISCONNECT FROM SESSION; 
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
alter DATABASE RECOVER MANAGED STANDBY DATABASE NOPARALLEL USING CURRENT LOGFILE DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
--; PARALLEL 4;
alter DATABASE RECOVER MANAGED STANDBY DATABASE NOPARALLEL USING CURRENT LOGFILE DISCONNECT FROM SESSION; 
alter database recover managed standby database using current logfile disconnect;
ALTER DATABASE RECOVER managed standby database until time '2018-11-13 04:40:00';

alter system set  control_files =   '+DATA02/witradr/controlfile/current.536.950969433' scope=spfile sid='*';

--ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

RECOVER DATABASE UNTIL TIME "to_date('2017-05-04:04:54:00', 'yyyy-mm-dd:hh24:mi:ss')";
--FIX
10544332427564
db#Chivas#123
select min(to_char(checkpoint_change#)) from v$datafile_header;


select file#,to_char(checkpoint_change#) from v$datafile_header;
select current_scn from v$database;

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
BACKUP  as compressed backupset INCREMENTAL  FROM SCN 10861018913596 DATABASE FORMAT '/u01/app/backup/bk_%U' tag 'FORSTANDBY';
release channel ch1 ;
release channel ch2 ;
release channel ch3 ;
release channel ch4 ;
}

--BACKUP  as compressed backupset datafile 1 FORMAT '/acfs_gg/backup/backup_%U' tag 'FORSTANDBY';

---------------restore a datafile on stb
BACKUP  as compressed backupset datafile 1 FORMAT '/u01/app/backup/backup_%U' tag 'FORSTANDBY';
alter database create standby controlfile as '/tmp/cob.ctl';
scp * 192.168.11.131:/u01/app/oracle/backup
scp /home/oracle/corbdr_new.ctl 192.168.11.131:/home/oracle/

--standby
shutdown immediate;
startup nomount;
restore standby controlfile from '/tmp/cob.ctl';
alter database mount;
catalog start with '/home/oracle/bak';
select name from v$datafile;
catalog start with '+T24R14_DR/T24R14DR/DATAFILE/';
restore datafile 1;
switch database to copy;

--switch datafile 1 to copy;
--switch datafile 2 to copy;
--switch datafile 3 to copy;
--switch datafile 4 to copy;
--switch datafile 15 to copy;

list incarnation --> current
reset database to incarnation 1;

--



run {
set  UNTIL TIME "to_date('2017-06-02:08:00:00', 'yyyy-mm-dd:hh24:mi:ss')"
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
RECOVER DATABASE NOREDO;
release channel ch1 ;
release channel ch2 ;
release channel ch3 ;
release channel ch4 ;
}


ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
alter database recover managed standby database using current logfile disconnect;

recover managed standby database disconnect parallel 4;
--
list incardination
select to_char(resetlogs_time,'YYYY/MM/DD HH24:MI:SS') from v$database_incarnation;

select status, to_char (checkpoint_change#) SCN,to_char(checkpoint_time,'YYYY/MM/DD HH24:MI:SS') as checkpoint_time , count(*) from v$datafile_header 
group by status, checkpoint_change#,checkpoint_time
order by status,checkpoint_change#,checkpoint_time;

SELECT OPNAME, CONTEXT, SOFAR, TOTALWORK,          ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"       FROM gV$SESSION_LONGOPS         
WHERE OPNAME LIKE 'RMAN%'       AND OPNAME NOT LIKE '%aggregate%'       AND TOTALWORK != 0      AND SOFAR <> TOTALWORK; 

-----------

run{
set until time "to_date('2017-03-14:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
allocate channel t3 device type 'sbt_tape' ;
allocate channel t4 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-tcbs-db-01,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set newname for datafile 5 to '+DATANEW';
set newname for datafile 4 to '+DATANEW';
set newname for datafile 3 to '+DATANEW';
set newname for datafile 2 to '+DATANEW';
set newname for datafile 1 to '+DATANEW';
restore database;
switch datafile all;
release channel t1;
release channel t2;
release channel t3;
release channel t4;
}


run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-tcbs-db-01,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set archivelog destination to '/u01/app/oracle/backup/';
restore archivelog from sequence 6084 until sequence 6095 thread 1;
release channel t1;
}

run{
allocate channel t1 device type 'sbt_tape' ;
set archivelog destination to '/u01/app/oracle/backup/';
recover database;
release channel t1;
}


FLASHBACK DATABASE TO TIME         "TO_DATE('09/20/00','MM/DD/YY')";

####################control file
On the primary
alter database create standby controlfile as '/backup/for_standby.ctl';

-> standby controlfile to STANDBY and bring up the standby instance in nomount status with standby controlfile:
startup nomount
alter database mount standby database;

catalog start with '/backup';
recover database;

===============================================================================
--===========SWITCH OVER --DRP
===============================================================================
###primary
SELECT SWITCHOVER_STATUS FROM V$DATABASE;  -- TO STANDBY 
--If listener of standby is notstarted, the switchover status: "FAILED DESTINATION" --> start the standby's listener , the status change to "TO STANDBY".
select open_mode,database_role from v$database;
select username,status,count(*) from gv$session group by username,status;

alter system archive log current;

ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN; --from 11.2.0.4, after this step don't need shutdown DB
SHUTDOWN abort;
STARTUP MOUNT;

###standby
SELECT SWITCHOVER_STATUS FROM V$DATABASE; -- TO_PRIMARY / SESSIONS ACTIVE 
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
ALTER DATABASE OPEN ;
shu immediate
startup

alter system set log_archive_dest_state_2=enable sid='*';



###cobr14dr
alter system set log_archive_config ='dg_config=(t24r14dc,cobr14dr)' scope=both sid='*';
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
alter database recover managed standby database using current logfile disconnect;

###cobr14dc
alter system set log_archive_config ='dg_config=(t24r14dc,cobr14dc)' scope=both sid='*';
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
alter database recover managed standby database using current logfile disconnect;

###primary
alter system set log_archive_dest_state_7=enable sid='*';
alter system set log_archive_dest_state_12 =enable scope=both sid='*';
alter system set log_archive_dest_state_13 =enable scope=both sid='*';
alter system set log_archive_config ='dg_config=(t24r14dr,t24r14dc,cobr14dc,cobr14dr)' scope=both sid='*';
alter system set log_archive_dest_12='service="cobr14dr" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dr"' scope=both sid='*';
alter system set log_archive_dest_13='service="cobr14dc" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dc"' scope=both sid='*';

select flashback_on from v$database;
alter database flashback on;

##standby  
 alter system set log_archive_dest_state_12 =DEFER scope=both sid='*';
 alter system set log_archive_dest_state_13 =DEFER scope=both sid='*';
alter system set log_archive_dest_state_11=defer sid='*';
alter system set log_archive_config ='dg_config=(t24r14dr,t24r14dc)' scope=both sid='*';


midify script OpenCob
----------------------
SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "LAST SEQUENCE RECEIVED_(2)", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#)  "DIFFERENCE_(3)"
FROM
(select MAX(SEQUENCE#) SEQUENCE#, THREAD#  from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\$ARCHIVED_LOG  order by FIRST_TIME desc) 
   WHERE ROWNUM<15   )
 GROUP BY THREAD# 
 ORDER BY 1 DESC) ARCH,
(select MAX(SEQUENCE#) SEQUENCE#, THREAD#  from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\$LOG_HISTORY  order by FIRST_TIME desc) 
   WHERE ROWNUM<50   )   
 GROUP BY THREAD# 
 ORDER BY 1 DESC) APPL
WHERE ARCH.THREAD# = APPL.THREAD# ORDER BY 2 desc;

 alter system set log_archive_config ='dg_config=(t24r14dr,t24r14dc)' scope=both sid='*';
 alter system set log_archive_dest_state_12 =DEFER scope=both sid='*';
 alter system set log_archive_dest_state_13 =DEFER scope=both sid='*';
 
alter system set  log_archive_dest_11 ='service="t24r14dr" valid_for=(all_logfiles,all_roles) db_unique_name="t24r14dr"' scope=both sid='*'
 
  alter system set log_archive_dest_state_12 =ENABLE scope=both sid='*';
 alter system set log_archive_dest_state_13 =ENABLE scope=both sid='*';
 
 
 alter system set log_archive_dest_12='service="cobr14dr"  valid_for=(ALL_LOGFILES,all_roles) db_unique_name="cobr14dr"' scope=both sid='*'
log_archive_dest_13                  string      service=cobr14dc valid_for=(all_logfiles,all_roles) db_unique_name=cobr14dc


#Using broker
switchover to 'TESTDG';

run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-tcbs-db-01,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set archivelog destination to '/u01/app/oracle/backup/';
restore archivelog from sequence 6748 until sequence 6762  thread 2;
release channel t1;
}

6747-6762

---------------------switch over by broker

dgmgrl
DGMGRL> connect SYS
DGMGRL> switchover to mepdr

DGMGRL> switchover to mbbdr
Performing switchover NOW, please wait...
New primary database "mbbdr" is opening...
Oracle Clusterware is restarting database "mbbdb" ...
 ORA-01017: invalid username/password; logon denied

Warning: You are no longer connected to ORACLE.

        shut down instance "mbbdb_1" of database "mbbdb"
        start up instance "mbbdb_1" of database "mbbdb"

DGMGRL>   

=========================================================================
Create DG for RAC
=========================================================================
--1: on DC
--add standby parameters 
ALTER DATABASE FORCE LOGGING;
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST valid_for=(ALL_LOGFILES,ALL_ROLES)' scope=both sid='*';
alter system set log_archive_dest_2='service=einvdr LGWR ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 max_connections=1 reopen=300 
db_unique_name=einvdr net_timeout=30 valid_for=(all_logfiles,primary_role)' sid='*' scope=both;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE scope=both sid='*';
alter system set fal_client='einvdb' scope=both sid='*';
alter system set fal_server='einvdr'  scope=both sid='*';
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(einvdb,einvdr)' scope=both sid='*';

ALTER SYSTEM SET DB_FILE_NAME_CONVERT='einvdr','einvdb' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_FILE_NAME_CONVERT='einvdr','einvdb'  SCOPE=SPFILE;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;
 
--ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.arc' SCOPE=SPFILE;
--ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=30;
--ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE SCOPE=SPFILE;

--add stb log
alter system set standby_file_management=manual scope=both sid='*';
alter database add logfile thread 1 group 11 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 1 group 12 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 1 group 13 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 1 group 14 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 2 group 21 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 2 group 22 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 2 group 23 ('+REDO01','+REDO02') size 200M;
alter database add logfile thread 2 group 24 ('+REDO01','+REDO02') size 200M;

alter database add standby logfile thread 1 group 31 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 1 group 32 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 1 group 33 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 1 group 34 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 1 group 35 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 2 group 41 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 2 group 42 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 2 group 43 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 2 group 44 ('+REDO01','+REDO02') size 200M;
alter database add standby logfile thread 2 group 45 ('+REDO01','+REDO02') size 200M;

 alter database drop  logfile group 21;

alter system set standby_file_management=auto scope=both sid='*';
 
--copy password file $ORACLE_HOME/dbs
 
--Create a pfile of DC --> sua thanh pfile cho DR 
create pfile='/home/oracle/initeinvdr1.ora' from spfile;

*.audit_file_dest='/u01/app/oracle/admin/mbsmsdr/adump'
*.audit_trail='db'
*.cluster_database=false
*.compatible='11.2.0.4.0'
*.control_files='+DATA02/mobsms/controlfile/current.547.950887257','+DATA02/mobsms/controlfile/current.548.950887257'
*.db_block_size=8192
*.db_create_file_dest='+DATA02'
*.db_domain=''
*.db_name='mobsms'
*.db_recovery_file_dest='+FRA'
*.db_recovery_file_dest_size=10737418240
*.db_unique_name='mbsmsdr'
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=mbsmsdrXDB)'
*.fal_client='mbsmsdr'
*.fal_server='mobsms'
mbsmsdr2.local_listener=
*.log_archive_config='DG_CONFIG=(mobsms,mbsmsdr)'
*.log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST valid_for=(ALL_LOGFILES,ALL_ROLES)'
*.log_archive_dest_2='service=mobsms LGWR ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 max_connections=1 reopen=300 db_unique_name=mobsms net_timeout=30 valid_for=(all_logfiles,primary_role)'
*.log_archive_dest_state_2='ENABLE'
*.open_cursors=300
*.pga_aggregate_target=314572800
*.processes=1500
*.remote_listener='dr-ora-scan:1521'
*.remote_login_passwordfile='exclusive'
*.sga_target=943718400
*.standby_file_management='AUTO'

##them sau
*.cluster_database=true
wicldr.local_listener=
wicldr1.undo_tablespace='UNDOTBS1'
wicldr2.undo_tablespace='UNDOTBS2'
wicldr1.instance_number=1
wicldr2.instance_number=2
wicldr1.thread=1
wicldr2.thread=2

--start nomount DR
startup nomount pfile='/u01/app/oracle/product/11.2.0.4/dbhome_1/dbs/initmbsmsdr1.ora'

--3. listener on DC & DR  -  
SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mobsms)
   (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
   (SID_NAME = mobsms1)
  )
)  


  (SID_DESC =
   (GLOBAL_DBNAME = einvdb)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = einvdb_1)
  )


SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = einvdr)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = einvdr_1)
  )
) 

--4. tnsnames.ora on both  -$ORACLE_HOME/network/admin/tnsnames.ora 

EINVDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.99.1.194)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = einvdb)
    )
  )


EINVDR1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.109.1.135)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = einvdr)
      (UR = A)
    )
  )


MOBSMS =
  (DESCRIPTION =
    (ADDRESS_LIST =  (ADDRESS = (PROTOCOL = TCP)(HOST = dc-ora-scan)(PORT = 1521))    )
    (CONNECT_DATA =  (SERVICE_NAME = mobsms)     )
  )

MOBSMS1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dc-ora-db02-vip)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = mobsms)
      (SID = mobsms1)
      (UR=A)
    )
  )

MBSMSDR =
  (DESCRIPTION =
    (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = dr-ora-scan)(PORT = 1521)) )
    (CONNECT_DATA = (SERVICE_NAME = mbsmsdr) )
  )

MBSMSDR1 =
  (DESCRIPTION =
    (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = dr-ora-db01-vip)(PORT = 1521))    )
    (CONNECT_DATA =
      (SERVICE_NAME = mbsmsdr)
      (UR=A)
    )
  )  
PING[ARC2]: Heartbeat failed to connect to standby 'flex'. Error is 12154.
ORA-12012: error on auto execute of job "HOSTTCBS"."PCK_BLG#PROCESS_MSG"
ORA-04067: not executed, package body "HOSTTCBS.PCK_BLG" does not exist

-- add DB DR to srvctl

--duplicate
rman target sys/PAssw0rd@einvdb1 auxiliary sys/PAssw0rd@einvdr1
duplicate target database for standby from active database nofilenamecheck;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;

--
+DATA04/wicldr/controlfile/current.354.954674487, +DATA04/wicldr/controlfile/current.454.954674487
'+DATA04/wicldr/controlfile/current.354.954674487', '+DATA04/wicldr/controlfile/current.454.954674487'
alter system set  control_files = '+DATA04/wicldr/controlfile/current.354.954674487', '+DATA04/wicldr/controlfile/current.454.954674487' scope=spfile sid='*';
create spfile='+data02/mbsmsdr/spfilembsmsdr.ora' from pfile='/u01/app/oracle/product/11.2.0.4/dbhome_1/dbs/initmbsmsdr1.ora_old'; 
rm sfile trong $ORACLE_HOME/dbs

fix pfile --> add parameter 
shutdown immediate
startup mount;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

=============================================
config broker
--on DC
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;
ALTER DATABASE FORCE LOGGING;
sho parameter dg_broker

alter system set dg_broker_config_file1='+DATA01/EINVDB/broker_einvdb1.dat' sid='*' scope=both;
alter system set dg_broker_config_file2='+DATA01/EINVDB/broker_einvdb2.dat' sid='*' scope=both;
alter system set dg_broker_start=true scope=both sid='*';

alter system set standby_file_management=manual scope=both sid='*';
alter database add standby logfile thread 1 group 31 ('+DATA01','+FRA') size 200M;
alter database add standby logfile thread 1 group 32 ('+DATA01','+FRA') size 200M;
alter database add standby logfile thread 1 group 33 ('+DATA01','+FRA') size 200M;
alter database add standby logfile thread 1 group 34 ('+DATA01','+FRA') size 200M;

alter system set standby_file_management=auto scope=both sid='*';
 --ALTER SYSTEM SET DG_BROKER_START=FALSE scope=both sid='*';
--on DR
sho parameter dg_broker
alter system set dg_broker_config_file1='+DATA01/EINVDR/broker_einvdr1.dat' sid='*' scope=both;
alter system set dg_broker_config_file2='+DATA01/EINVDR/broker_einvdr2.dat' sid='*' scope=both;
alter system set dg_broker_start=true scope=both sid='*';

--Edit the listener.ora file - both
GLOBAL_DBNAME=db_unique_name_DGMGRL.db_domain 

show parameter db_domain
NAME                              TYPE               VALUE
--------------                  -----------         --------------
db_domain                      string

->GLOBAL_DBNAME = MOBSMS_DGMGRL 
->GLOBAL_DBNAME = MBSMSDR_DGMGRL 

SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mepdb_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/12.2.0/dbhome_1)
   (SID_NAME = mepdb)
  )
)  

SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (GLOBAL_DBNAME = mbsmsdr_dgmgrl)
   (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
   (SID_NAME = mbsmsdr1)
  )
) 

--Configure the Data Guard Configuration 
-- on DC
dgmgrl /
show configuration;
create configuration einvdb_broker as primary database is einvdb connect identifier is einvdb;
add database einvdr as connect identifier is einvdr maintained as physical;  -->> alter system set log_Archive_dest_2=''; on both DC and DR
ENABLE CONFIGURATION;
show configuration

--on DR

show configuration
-- on DC
enable configuration
show configuration

--View the Primary and Standby database properties 
show database verbose mobsms
show database verbose mbsmsdr

-------
EDIT DATABASE 'DR_Sales' SET PROPERTY 'LogArchiveFormat'='log_%t_%s_%r_%d.arc';
 EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;
 SHOW FAST_START FAILOVER;
 
 

=============================================
by broker
-- on DC
alter system set dg_broker_start=false sid='*' ;
alter system set dg_broker_config_file1='+DATA02/mobsms/brokermobsms1.dat' sid='*' scope=both;
alter system set dg_broker_config_file2='+DATA04/mobsms/brokermobsms1.dat' sid='*' scope=both ;
alter system set dg_broker_start=true sid='*' scope=both;

Configure Broker
dgmgrl /
show configuration;
--remove database bpfdr;
tnsnames.ora --> cedr

create configuration mobsms_broker as primary database is mobsms connect identifier is mobsms;
add database mobsmsdr as connect identifier is mobsmsdr maintained as physical; 
show configuration

--
run {
allocate channel ch1 device type disk;
backup as compressed backupset archivelog all filesperset 5 format '\\backupserver001\export00$\standby-silverdb001\SILVER\AL_%d_%u' skip inaccessible delete all input;
backup current controlfile for standby format '\\backupserver001\export00$\standby-silverdb001\SILVER\CT_STANDBY%d_%U';
}


--======================================================================
-- clone COB from t24r14dr 
--======================================================================
-- stop sync on t24r14dr
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;

-- create stb controlfile on t24r14dc
alter database create standby controlfile as '/home/oralce/testcob.ctl';
scp /acfs_gg/backup/cob_New.ctl 192.168.11.131:/home/oracle/

-- restore on cobr14dr
shutdown immediate;

asmcmd>
rm -rf +COBR14_DR/COBR14DR/CONTROLFILE/
rm -rf +COBR14_DR/COBR14DR/DATAFILE/
rm -rf +COBR14_DR/COBR14DR/ONLINELOG/
rm -rf +COBR14_DR/COBR14DR/TEMPFILE/
rm -rf +FRACOBR14_DR/COBR14DR/ARCHIVELOG/
rm -rf +FRACOBR14_DR/COBR14DR/AUTOBACKUP/
rm -rf +FRACOBR14_DR/COBR14DR/FLASHBACK/
rm -rf +FRACOBR14_DR/COBR14DR/ONLINELOG/

startup nomount;
restore standby controlfile from '/home/oralce/testcob.ctl';
alter database mount;
catalog start with '+T24R14_DR/T24R14DR/DATAFILE/';

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
allocate channel ch11 device type disk;
allocate channel ch12 device type disk;
allocate channel ch13 device type disk;
allocate channel ch14 device type disk;
allocate channel ch21 device type disk;
allocate channel ch22 device type disk;
allocate channel ch23 device type disk;
allocate channel ch24 device type disk;
allocate channel ch31 device type disk;
allocate channel ch32 device type disk;
allocate channel ch33 device type disk;
allocate channel ch34 device type disk;
allocate channel ch41 device type disk;
allocate channel ch42 device type disk;
allocate channel ch43 device type disk;
allocate channel ch44 device type disk;
allocate channel ch51 device type disk;
allocate channel ch52 device type disk;
allocate channel ch53 device type disk;
allocate channel ch54 device type disk;
allocate channel ch111 device type disk;
allocate channel ch112 device type disk;
allocate channel ch113 device type disk;
allocate channel ch114 device type disk;
allocate channel ch121 device type disk;
allocate channel ch122 device type disk;
allocate channel ch123 device type disk;
allocate channel ch124 device type disk;
allocate channel ch131 device type disk;
allocate channel ch132 device type disk;
allocate channel ch133 device type disk;
allocate channel ch134 device type disk;
allocate channel ch141 device type disk;
allocate channel ch142 device type disk;
allocate channel ch143 device type disk;
allocate channel ch144 device type disk;
allocate channel ch151 device type disk;
allocate channel ch152 device type disk;
allocate channel ch153 device type disk;
allocate channel ch154 device type disk;
set newname for datafile 1 to '+COBR14_DR';
set newname for datafile 2 to '+COBR14_DR';
set newname for datafile 3 to '+COBR14_DR';
set newname for datafile 4 to '+COBR14_DR';
set newname for datafile 5 to '+COBR14_DR';
set newname for datafile 6 to '+COBR14_DR';
set newname for datafile 7 to '+COBR14_DR';
set newname for datafile 8 to '+COBR14_DR';
set newname for datafile 9 to '+COBR14_DR';
set newname for datafile 10 to '+COBR14_DR';
set newname for datafile 11 to '+COBR14_DR';
set newname for datafile 12 to '+COBR14_DR';
set newname for datafile 13 to '+COBR14_DR';
set newname for datafile 14 to '+COBR14_DR';
set newname for datafile 15 to '+COBR14_DR';
set newname for datafile 16 to '+COBR14_DR';
set newname for datafile 17 to '+COBR14_DR';
set newname for datafile 18 to '+COBR14_DR';
set newname for datafile 19 to '+COBR14_DR';
set newname for datafile 20 to '+COBR14_DR';
set newname for datafile 21 to '+COBR14_DR';
set newname for datafile 22 to '+COBR14_DR';
set newname for datafile 23 to '+COBR14_DR';
set newname for datafile 24 to '+COBR14_DR';
set newname for datafile 25 to '+COBR14_DR';
set newname for datafile 26 to '+COBR14_DR';
set newname for datafile 27 to '+COBR14_DR';
set newname for datafile 28 to '+COBR14_DR';
set newname for datafile 29 to '+COBR14_DR';
set newname for datafile 30 to '+COBR14_DR';
set newname for datafile 31 to '+COBR14_DR';
set newname for datafile 32 to '+COBR14_DR';
set newname for datafile 33 to '+COBR14_DR';
set newname for datafile 34 to '+COBR14_DR';
set newname for datafile 35 to '+COBR14_DR';
set newname for datafile 36 to '+COBR14_DR';
set newname for datafile 37 to '+COBR14_DR';
set newname for datafile 38 to '+COBR14_DR';
set newname for datafile 39 to '+COBR14_DR';
set newname for datafile 40 to '+COBR14_DR';
set newname for datafile 41 to '+COBR14_DR';
set newname for datafile 42 to '+COBR14_DR';
set newname for datafile 43 to '+COBR14_DR';
set newname for datafile 44 to '+COBR14_DR';
set newname for datafile 45 to '+COBR14_DR';
set newname for datafile 46 to '+COBR14_DR';
set newname for datafile 47 to '+COBR14_DR';
set newname for datafile 48 to '+COBR14_DR';
set newname for datafile 49 to '+COBR14_DR';
set newname for datafile 50 to '+COBR14_DR';
set newname for datafile 51 to '+COBR14_DR';
set newname for datafile 52 to '+COBR14_DR';
set newname for datafile 53 to '+COBR14_DR';
set newname for datafile 54 to '+COBR14_DR';
set newname for datafile 55 to '+COBR14_DR';
set newname for datafile 56 to '+COBR14_DR';
set newname for datafile 57 to '+COBR14_DR';
set newname for datafile 58 to '+COBR14_DR';
set newname for datafile 59 to '+COBR14_DR';
set newname for datafile 60 to '+COBR14_DR';
set newname for datafile 61 to '+COBR14_DR';
set newname for datafile 62 to '+COBR14_DR';
set newname for datafile 63 to '+COBR14_DR';
set newname for datafile 64 to '+COBR14_DR';
set newname for datafile 65 to '+COBR14_DR';
set newname for datafile 66 to '+COBR14_DR';
set newname for datafile 67 to '+COBR14_DR';
set newname for datafile 68 to '+COBR14_DR';
set newname for datafile 69 to '+COBR14_DR';
set newname for datafile 70 to '+COBR14_DR';
set newname for datafile 71 to '+COBR14_DR';
set newname for datafile 72 to '+COBR14_DR';
set newname for datafile 73 to '+COBR14_DR';
set newname for datafile 74 to '+COBR14_DR';
set newname for datafile 75 to '+COBR14_DR';
set newname for datafile 76 to '+COBR14_DR';
set newname for datafile 77 to '+COBR14_DR';
set newname for datafile 78 to '+COBR14_DR';
set newname for datafile 79 to '+COBR14_DR';
set newname for datafile 80 to '+COBR14_DR';
set newname for datafile 81 to '+COBR14_DR';
set newname for datafile 82 to '+COBR14_DR';
set newname for datafile 83 to '+COBR14_DR';
set newname for datafile 84 to '+COBR14_DR';
set newname for datafile 85 to '+COBR14_DR';
set newname for datafile 86 to '+COBR14_DR';
set newname for datafile 87 to '+COBR14_DR';
set newname for datafile 88 to '+COBR14_DR';
set newname for datafile 89 to '+COBR14_DR';
set newname for datafile 90 to '+COBR14_DR';
set newname for datafile 91 to '+COBR14_DR';
set newname for datafile 92 to '+COBR14_DR';
set newname for datafile 93 to '+COBR14_DR';
set newname for datafile 94 to '+COBR14_DR';
set newname for datafile 95 to '+COBR14_DR';
set newname for datafile 96 to '+COBR14_DR';
set newname for datafile 97 to '+COBR14_DR';
set newname for datafile 98 to '+COBR14_DR';
set newname for datafile 99 to '+COBR14_DR';
set newname for datafile 100 to '+COBR14_DR';
set newname for datafile 101 to '+COBR14_DR';
set newname for datafile 102 to '+COBR14_DR';
set newname for datafile 103 to '+COBR14_DR';
set newname for datafile 104 to '+COBR14_DR';
set newname for datafile 105 to '+COBR14_DR';
set newname for datafile 106 to '+COBR14_DR';
set newname for datafile 107 to '+COBR14_DR';
set newname for datafile 108 to '+COBR14_DR';
set newname for datafile 109 to '+COBR14_DR';
set newname for datafile 110 to '+COBR14_DR';
set newname for datafile 111 to '+COBR14_DR';
set newname for datafile 112 to '+COBR14_DR';
set newname for datafile 113 to '+COBR14_DR';
set newname for datafile 114 to '+COBR14_DR';
set newname for datafile 115 to '+COBR14_DR';
set newname for datafile 116 to '+COBR14_DR';
set newname for datafile 117 to '+COBR14_DR';
set newname for datafile 118 to '+COBR14_DR';
set newname for datafile 119 to '+COBR14_DR';
set newname for datafile 120 to '+COBR14_DR';
set newname for datafile 121 to '+COBR14_DR';
set newname for datafile 122 to '+COBR14_DR';
set newname for datafile 123 to '+COBR14_DR';
set newname for datafile 124 to '+COBR14_DR';
set newname for datafile 125 to '+COBR14_DR';
set newname for datafile 126 to '+COBR14_DR';
set newname for datafile 127 to '+COBR14_DR';
set newname for datafile 128 to '+COBR14_DR';
set newname for datafile 129 to '+COBR14_DR';
set newname for datafile 130 to '+COBR14_DR';
set newname for datafile 131 to '+COBR14_DR';
set newname for datafile 132 to '+COBR14_DR';
set newname for datafile 133 to '+COBR14_DR';
set newname for datafile 134 to '+COBR14_DR';
set newname for datafile 135 to '+COBR14_DR';
set newname for datafile 136 to '+COBR14_DR';
set newname for datafile 137 to '+COBR14_DR';
set newname for datafile 138 to '+COBR14_DR';
set newname for datafile 139 to '+COBR14_DR';
set newname for datafile 140 to '+COBR14_DR';
set newname for datafile 141 to '+COBR14_DR';
set newname for datafile 142 to '+COBR14_DR';
set newname for datafile 143 to '+COBR14_DR';
set newname for datafile 144 to '+COBR14_DR';
set newname for datafile 145 to '+COBR14_DR';
set newname for datafile 146 to '+COBR14_DR';
set newname for datafile 147 to '+COBR14_DR';
set newname for datafile 148 to '+COBR14_DR';
set newname for datafile 149 to '+COBR14_DR';
set newname for datafile 150 to '+COBR14_DR';
set newname for datafile 151 to '+COBR14_DR';
set newname for datafile 152 to '+COBR14_DR';
set newname for datafile 153 to '+COBR14_DR';
set newname for datafile 154 to '+COBR14_DR';
set newname for datafile 155 to '+COBR14_DR';
restore database;
release channel ch1 ;
release channel ch2 ;
release channel ch3 ;
release channel ch4 ;
release channel ch11 ;
release channel ch12 ;
release channel ch13 ;
release channel ch14 ;
release channel ch21 ;
release channel ch22 ;
release channel ch23 ;
release channel ch24 ;
release channel ch31 ;
release channel ch32 ;
release channel ch33 ;
release channel ch34 ;
release channel ch41 ;
release channel ch42 ;
release channel ch43 ;
release channel ch44 ;
release channel ch51 ;
release channel ch52 ;
release channel ch53 ;
release channel ch54 ;
release channel ch111 ;
release channel ch112 ;
release channel ch113 ;
release channel ch114 ;
release channel ch121 ;
release channel ch122 ;
release channel ch123 ;
release channel ch124 ;
release channel ch131 ;
release channel ch132 ;
release channel ch133 ;
release channel ch134 ;
release channel ch141 ;
release channel ch142 ;
release channel ch143 ;
release channel ch144 ;
release channel ch151 ;
release channel ch152 ;
release channel ch153 ;
release channel ch154 ;
}

switch database to copy;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

alter database open read only;
--======================================================================
