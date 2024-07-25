db#goldengate#123



ANH033127%IM.DOCUMENT.IMAGE,TCB_VN0010020_ANH03.31272

AUTHDEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.101.5.238)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = authdev)
    )
  )

  
select * from dba_tables where partitioned='NO' and owner='T24LIVE' and table_name in (
SELECT   table_name FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner AND   s.segment_type like 'LOB%'
)
where owner='T24LIVE'
GROUP BY owner  ,table_name
having TRUNC(sum(bytes)/1024/1024/1024)>=10
)


T24POC =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = tcp)(HOST = 10.101.4.156)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = t24poc)
    )
  )s

select owner,job_name,repeat_interval from ALL_SCHEDULER_JOBS where repeat_interval like 'FREQ=HOURLY%'
---TAF
srvctl add service -d mbb11gt -s mbb_taf -r "mbb11gt1,mbb11gt2" -P BASIC 

srvctl start service -d mbb11gt -s mbb_taf

srvctl config service -d mbb11gt 

select name,service_id from dba_services ;

select name, failover_method, failover_type, failover_retries,goal, clb_goal,aq_ha_notifications  from dba_services where service_id = 3;

srvctl modify service -d mbb11gt -s mbb_taf -m BASIC -e SELECT -q TRUE -j LONG
srvctl config service -d mbb11gt
select name, failover_method, failover_type, failover_retries,goal, clb_goal,aq_ha_notifications  from dba_services where service_id = 3;

----temp tablespace usage
SELECT A.tablespace_name tablespace,  trunc(SUM(A.used_blocks * D.block_size*100)/ sum(D.mb_total)) pct_used
    FROM v$sort_segment A,
         (  SELECT A.tablespace_name,C.block_size,
     sum(  CASE
          WHEN A.autoextensible = 'YES' THEN A.maxbytes
          ELSE A.bytes
       END)
          AS mb_total
  FROM dba_temp_files A,v$tempfile C
  WHERE A.file_id = C.File#
  group by   A.tablespace_name  ,C.block_size) D
   WHERE A.tablespace_name = D.tablespace_name
   having trunc(SUM(A.used_blocks * D.block_size*100)/ sum(D.mb_total)) >=70
GROUP BY A.tablespace_name, D.mb_total


select event,STATO_PERCENT from(
SELECT     event, RATIO_TO_REPORT(COUNT(1)) OVER() * 100 STATO_PERCENT
from v$active_session_history where sample_time>sysdate-1/(24*60)
and event is not null
group by event 
)where STATO_PERCENT>10


alter table T24LIVE.FBNK_PM_TRAN_ACTIVITY MOVE partition SYS_P10733 TABLESPACE DATAT24LIVE
FBNK_MM_M000' and partition_name='SYS_P10349'

SYS_P36781   

+T24R14_DR/T24R14DR/DATAFILE/homebanking_tbs.376.970456929
FBNK_RE_C017

FBNK_CATEG_ENT_ACTIVITY
'_____.2016____.%'

FBNK_RE_STAT_LINE_BAL
'%-2016____*%'


F_DC_NEW_003
-->truncate?

FBNK_POS_MVMT_HIST
'%*2016____*%'

FBNK_CONT_ACTIVITY
'%*2016__'

F_DE_O_MSG
'D2016%'

select recid from T24LIVE.F_DE_O_MSG where recid not like 'D%'

FBNK_AI_T000
bang ko index function--> check column in xmlrecord

FBNK_BENEFICIARY
'BEN16%'

FBNK_AC_C002
'CHG16%'

FBNK_EBANK_BULK_TCB
'FEB16%' 

FBNK_DYNAMIC_TEXT#NAU
bang ko index function--> check column in xmlrecord

F_ACCT_TODAY_LOG_TCB
bang ko index function--> check column in xmlrecord

FBNK_TRIC000
bang ko index function--> check column in xmlrecord

F_DE_O_REPAIR
'DB16%'

FBNK_AI_CORP_TXN_LOG
'FT16%'

F_OFS_RESPONSE_QUEUE
'174630255239451.01.1'
'175320000000000'--> rule?

FBNK_VISA_OFFUS_TCB
'__16%'

Sat Aug 18 19:10:39 2018
Hex dump of (file 83, block 44074) in trace file /u01/app/oracle/diag/rdbms/cobr14dr/cobr14dr1/trace/cobr14dr1_pr06_45772.trc

Corrupt block relative dba: 0x14c0ac2a (file 83, block 44074)
Bad header found during media recovery
Data in bad block:
 type: 0 format: 0 rdba: 0x00000000
 last change scn: 0x0000.00000000 seq: 0x0 flg: 0x42
 spare1: 0x0 spare2: 0x0 spare3: 0x0
 consistency value in tail: 0x00000000
 check value in block header: 0x0
 block checksum disabled

Reading datafile '+COBR14_DR/T24R14DR/DATAFILE/indext24live.258.970456325' for corruption at rdba: 0x14c0ac2a (file 83, block 44074)
Reread (file 83, block 44074) found same corrupt data (no logical check)
Sat Aug 18 19:10:39 2018
Hex dump of (file 84, block 3841344) in trace file /u01/app/oracle/diag/rdbms/cobr14dr/cobr14dr1/trace/cobr14dr1_pr03_45766.trc

Corrupt block relative dba: 0x153a9d40 (file 84, block 3841344)
Completely zero block found during media recovery

Reading datafile '+COBR14_DR/T24R14DR/DATAFILE/indext24live.416.970456325' for corruption at rdba: 0x153a9d40 (file 84, block 3841344)
Reread (file 84, block 3841344) found same corrupt data (no logical check)
Sat Aug 18 19:10:39 2018
Automatic block media recovery requested for (file# 83, block# 44074)
Sat Aug 18 19:10:39 2018
Automatic block media recovery requested for (file# 84, block# 3841344)
Sat Aug 18 19:10:41 2018
Hex dump of (file 23, block 215492) in trace file /u01/app/oracle/diag/rdbms/cobr14dr/cobr14dr1/trace/cobr14dr1_pr01_45762.trc

Corrupt block relative dba: 0x05c349c4 (file 23, block 215492)
Bad header found during media recovery
Data in bad block:

MERGE INTO FBNK_RE_S008 USING DUAL ON (RECID = :RECID)                                                         WHEN MATCHED THEN UPDATE SET XMLRECORD=:XMLRECORD                                                                     WHEN NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(:XMLRECORD ,:RECID)

DELETE FROM FBNK_RE_S008 WHERE RECID = :RECID 

================get password string for user expire
SELECT 'ALTER USER '|| name ||' IDENTIFIED BY VALUES '''|| spare4 ||';'|| password ||''';' FROM sys.user$ WHERE name='OERTEST'; 

================check resize memory
SELECT COMPONENT ,OPER_TYPE,FINAL_SIZE Final,to_char(start_time,'dd-mon hh24:mi:ss') Started FROM V$SGA_RESIZE_OPS order by to_char(start_time,'dd-mon hh24:mi:ss');
================

--export/import 
expdp tables=T24LIVE.FBNK_RE_C018 DUMPFILE=FBNK_RE_C018%U.dmp FILESIZE=5G LOGFILE=FBNK_RE_C018.log  DIRECTORY=DUMP_ARC  QUERY=T24LIVE.FBNK_RE_C018:\"where recid like '%.201712%'\"
"
impdp directory=dump_arc dumpfile=FBNK_RE_C01801.dmp logfile=imp_FBNK_RE_C01801.log  REMAP_TABLE=T24LIVE.FBNK_RE_C018:TEST_FBNK_RE_C018


-----config sqlplus
vi $ORACLE_HOME/sqlplus/admin/glogin.sql
--add below lines
set linesize 300
set pagesize 4000
set sqlprompt "_user'@'_connect_identifier > "

-----check object change 

SELECT to_char(begin_interval_time,'dd/mm/yyyy hh24:mi') snap_time,
        dhsso.object_name,
        sum(db_block_changes_delta) as maxchages
  FROM dba_hist_seg_stat dhss,
         dba_hist_seg_stat_obj dhsso,
         dba_hist_snapshot dhs
  WHERE dhs.snap_id = dhss.snap_id
    AND dhs.instance_number = dhss.instance_number
    AND dhss.obj# = dhsso.obj#
    AND dhss.dataobj# = dhsso.dataobj#
    AND begin_interval_time BETWEEN to_date('29/03/2018 10','dd/mm/yyyy hh24')
                                           AND to_date('29/03/2017 10','dd/mm/yyyy hh24')
  GROUP BY to_char(begin_interval_time,'dd/mm/yyyy hh24:mi'),
           dhsso.object_name order by maxchages asc;

********************************************************************

SELECT MESSAGE_TEXT, ORIGINATING_TIMESTAMP
       FROM X$DBGALERTEXT
      WHERE     ORIGINATING_TIMESTAMP > TRUNC (SYSDATE) + 19 / 24
            AND MESSAGE_TEXT LIKE 'Error%'
----
10.109.1.62
/dev/mapper/mpath20   788G  697G   51G  94% /stage

10.99.1.62
/dev/mapper/mpath32   197G  113G   75G  61% /backup200

10.99.1.149
/dev/backuplv    299.00    109.82   64%       60     1% /backupdata

10.99.1.149
/dev/linuxonelv    400.00    367.14    9%       28     1% /linuxonedata

10.100.100.94/95
/dev/mapper/vg_backupdata-lv_backupdata  3.5T  801G  2.8T  23% /backupdata

10.100.100.94
/dev/mapper/mpathz           200G   60G  141G  30% /backup_twa

10.109.1.208
/dev/mapper/stagevg-stagelv  249G   45G  205G  18% /stage

-----

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_GATHER'
      ,start_date      => TO_TIMESTAMP_TZ('2017/06/03 23:30:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SAT;'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'begin sys.DBMS_STATS.GATHER_DATABASE_STATS (Estimate_Percent=>dbms_stats.auto_sample_size,Method_Opt=>''FOR ALL COLUMNS SIZE AUTO'',Degree=> 4);end;'
      ,comments        => 'Job to gather database.'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.DBA_JOB_GATHER'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_GATHER');
END;
/


--inode
df -i|grep /u01 | awk '{print $5}' |sed 's/.$//'

[oracle@dc-ora-db01 ~]$ more /etc/resolv.conf 
search techcombank.com.vn
nameserver 10.98.1.90
nameserver 10.98.1.33
nameserver 10.98.1.146
---read high
set lines 200
col Device for a55
select * from
(
select a.DBNAME as "DB Name",
b.PATH as "Device",
a.READS as "Read Request",
a.WRITES as "Write Requests",
a.BYTES_READ/1024/1024 as "Total Read MB",
a.BYTES_WRITTEN/1024/1024 "Total Write MB"
from v$asm_disk_iostat a, v$asm_disk b
where  a.GROUP_NUMBER=b.GROUP_NUMBER 
and a.DISK_NUMBER=b.DISK_NUMBER 
and b.PATH in ('','')
order by 5 desc
)
where rownum <=100;
;


190c190
< OCBUSER.DWH_ACCOUNT                                            29875873
---
> OCBUSER.DWH_ACCOUNT                                            29876038
206c206
< OCBUSER.DWH_SYNC_LOG                                           11819385
---
> OCBUSER.DWH_SYNC_LOG                                           11819475
375,376c375,376
< OCBUSER.TCB_SYNC_JOB_MONITOR                                    1149140
< OCBUSER.TCB_SYNC_LOG                                           49326637
---
> OCBUSER.TCB_SYNC_JOB_MONITOR                                    1149143
> OCBUSER.TCB_SYNC_LOG                                           49326641


t24r14dc2.__db_cache_size=100394860544
t24r14dc1.__db_cache_size=102005473280
t24r14dc2.__java_pool_size=1879048192
t24r14dc1.__java_pool_size=1610612736
t24r14dc1.__large_pool_size=2147483648
t24r14dc2.__large_pool_size=2147483648
t24r14dc1.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
t24r14dc2.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
t24r14dc1.__pga_aggregate_target=26843545600
t24r14dc2.__pga_aggregate_target=26843545600
t24r14dc1.__sga_target=128849018880
t24r14dc2.__sga_target=128849018880
t24r14dc1.__shared_io_pool_size=536870912
t24r14dc2.__shared_io_pool_size=0
t24r14dc2.__shared_pool_size=20132659200
t24r14dc1.__shared_pool_size=19327352832
t24r14dc2.__streams_pool_size=1342177280
t24r14dc1.__streams_pool_size=268435456
*.audit_file_dest='/u01/app/oracle/admin/t24r14dc/adump'
*.audit_sys_operations=TRUE
*.audit_trail='OS'
*.cluster_database=true
*.compatible='11.2.0.4.0'
*.control_files='+T24R14_DC/t24r14dc/controlfile/current.260.899375357'#Restore Controlfile
*.cursor_sharing='EXACT'
*.db_block_checksum='FULL'
*.db_block_size=8192
*.db_create_file_dest='+T24R14_DC'
*.db_domain=''
*.db_file_name_convert='+POSTCOB/t24cob/datafile','+T24R14_DC/t24r14dc/datafile','+T24LIVE/t24live/datafile','+T24R14_DC/t24r14dc/datafile'
*.db_flashback_retention_target=2880
*.db_keep_cache_size=2147483648
*.db_lost_write_protect='TYPICAL'
*.db_name='T24LIVE'
*.db_recovery_file_dest='+FRAT24R14_DC'
*.db_recovery_file_dest_size=2040109465600
*.db_unique_name='t24r14dc'
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=t24r14dcXDB)'
*.enable_goldengate_replication=TRUE
*.event='44951 TRACE NAME CONTEXT FOREVER, LEVEL 1024'
*.fal_client='T24R14DC'
*.fal_server='t24r14dr'
*.fast_start_mttr_target=1800
*.filesystemio_options='SETALL'
t24r14dc1.instance_number=1
t24r14dc2.instance_number=2
2.local_listener='LISTENER_T24DB02'
1.local_listener='LISTENER_T24DB01'
t24r14dc1.local_listener='LISTENER_T24DB01'
t24r14dc2.local_listener='LISTENER_T24DB02'
*.log_archive_config='dg_config=(t24r14dr,t24r14dc,cobr14dr,cobr14dc)'
*.log_archive_dest_1='LOCATION=+FRAT24R14_DC valid_for=(ALL_LOGFILES, ALL_ROLES)'
*.log_archive_dest_10=''
*.log_archive_dest_12='service="cobr14dr" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dr"'
*.log_archive_dest_13='service="cobr14dc" valid_for=(all_logfiles,all_roles) db_unique_name="cobr14dc"'
*.log_archive_dest_7='service="t24r14dr"  LGWR ASYNC NOAFFIRM delay=0 optional compression=disable max_failure=0 max_connections=1 reopen=300 db_unique_name="t24r14dr
" net_timeout=30','valid_for=(all_logfiles,primary_role)'
*.log_archive_dest_state_10='DEFER'
*.log_archive_dest_state_12='ENABLE'
*.log_archive_dest_state_13='ENABLE'
*.log_archive_dest_state_7='ENABLE'
*.log_file_name_convert='+POSTCOB/t24cob/onlinelog','+T24R14_DC/t24r14dc/onlinelog','+FRACOB/t24cob/onlinelog','+RECOT24R14_DC/t24r14dc/onlinelog','+REDOLOG01','+T24R
14_DC','+REDOLOG02','+T24R14_DC','+T24LIVE','+T24R14_DC','+RECO01','+RECOT24R14_DC'
*.open_cursors=5000
*.open_links=10
*.optimizer_index_caching=50
*.optimizer_index_cost_adj=1
*.pga_aggregate_target=26843545600
*.processes=6605
*.query_rewrite_integrity='TRUSTED'
*.recyclebin='OFF'
*.remote_listener='t24db-cluster-scan:1521'
*.remote_login_passwordfile='exclusive'
*.sec_protocol_error_further_action='CONTINUE'
*.sec_protocol_error_trace_action='TRACE'
*.service_names='t24r14dc'
*.session_cached_cursors=1000
*.session_max_open_files=500
*.sga_max_size=128849018880
*.sga_target=128849018880
t24r14dc1.shared_pool_size=3221225472
t24r14dc2.shared_pool_size=3221225472
*.shared_pool_size=10737418240
*.sql92_security=TRUE
*.standby_file_management='AUTO'
t24r14dc2.thread=2
t24r14dc1.thread=1
*.undo_retention=54000
t24r14dc1.undo_tablespace='UNDOTBS1'
t24r14dc2.undo_tablespace='UNDOTBS2'
--------------------
10.101.5.20 : oracle db#Chivas#123   grid: oracle123


select (sysdate - max(next_time))*24 ti from v$archived_log where applied='YES' 

sculkget: failed to lock /u01/app/database/product/11.2.0.4/dbhome_1/dbs/lkT24LIVE exclusive
sculkget: lock held by PID: 38076840
ORA-09968: unable to lock file
IBM AIX RISC System/6000 Error: 13: Permission denied
Additional information: 38076840


Khi sự cố xảy ra cần chạy TFA collect xong rồi mới start lại db, vì sau khi restart hệ thống có 1 số file trace, log bị ghi đè mất thông tin sự cố. Nên chạy lệnh sau:
su - grid
tfactl diagcollect -node t24xxx -- collect last 4h
/u01/app/oracle/tfa/repository/collection_Thu_Oct_19_12_41_29_ICT_2017_node_t24db02/t24db02.tfa_Thu_Oct_19_12_41_29_ICT_2017.zip

[oracle@t24-db01-test OPatch]$ opatch lsinventory -detail -bugs_fixed
Oracle Interim Patch Installer version 11.2.0.3.4
Copyright (c) 2012, Oracle Corporation.  All rights reserved.


-----------------Mount disk sync from CardLinuxDC to CardLinuxOneDR
step1:
Scan new path

$ echo "- - -" > /sys/class/scsi_host/host0/scan
$ echo "- - -" > /sys/class/scsi_host/host1/scan
$ echo "- - -" > /sys/class/scsi_host/host2/scan
$ echo "- - -" > /sys/class/scsi_host/host3/scan

Step2: Get name and size of new path
$ multipath -ll

Step 3:
Show the logical volume

$ pvscan
$ pvdisplay
$ vgscan
$ vgdisplay
$ lvscan
$ lvdisplay

Then get the name of new logical volume group

Step 4:
Create new folder to mount 
$ mkdir -p /stage
Try to mount new partition
mount <path_to_lvdisk> /stage
If error, try:
modeprobe dm-mode
vgchange -ay
xfs_repair -L <path_to_lvdisk>
mount <path_to_lvdisk> /stage

Step 5:
Edit fstab to automatic mount partition after reboot
$ vi /etc/fstab
<path_to_lvdisk>	/stage	xfs	defaults	0 0

------------------------------------------------------------------------------------------------------
----OPatch
srvctl add database -d cob -o $ORACLE_HOME -p $ORACLE_HOME/dbs/spfilecob.ora

 opatch auto /stageaix/setup/20996923 -ocmrf /stageaix/setup/20996923/ocm.res
 
 $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /stageaix/setup/file.rsp
 
 ./opatch auto /stageaix/setup/20996923 -oh /u01/app/grid/product/11.2.0/grid -ocmrf /home/grid/file.rsp
 
 $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /home/grid/file.rsp
 
 opatch auto -oh /u01/app/grid/product/11.2.0/grid -ocmrf /home/grid/file.rsp
---
fdisk /dev/mapper/<lun>
n
p
1
enter
enter
enter
w
thinhnh2	USER\NOC-PC-01	NOC-PC-01
oracle	dc-ora-db02	pts/1
tcblocal	DR-LOYALTY-DB	unknown
pbts	HEADQUARTER\DC-WEBFARM-02	DC-WEBFARM-02  10.97.1.23

ERROR: Invalid response file path, To regenerate an OCM response file run 

ERROR: update the opatch version for the failed homes and retry

----------T24 parameter
alter system set cursor_sharing=EXACT scope=both sid='*';
--alter system set db_keep_cache_size=2G scope=spfile sid='*';
alter system set db_lost_write_protect=TYPICAL scope=both sid='*';
--alter system set db_writer_processes=8 scope=spfile sid='*';
alter system set fast_start_mttr_target=1800 scope=both sid='*';
##alter system set filesystemio_options=SETALL scope=spfile sid='*';
--alter system set gcs_server_processes=4 scope=spfile sid='*';  -- only for RAC
alter system set open_cursors=5000 scope=both sid='*';
alter system set open_links=10 scope=spfile sid='*';
alter system set optimizer_index_caching=50 scope=both sid='*';
alter system set optimizer_index_cost_adj=1 scope=both sid='*';
alter system set processes=6605 scope=spfile sid='*';
alter system set query_rewrite_integrity=trusted scope=both sid='*';
alter system set session_cached_cursors=1000 scope=spfile sid='*';
alter system set session_max_open_files=500 scope=spfile sid='*';
alter system set undo_retention=54000 scope=both sid='*';
alter system set db_block_checksum=FULL scope=both sid='*';
alter system set db_flashback_retention_target=2880 scope=both sid='*';
alter system set recyclebin=off scope=spfile sid='*';
alter system set standby_file_management=AUTO scope=spfile sid='*';

--alter system set compatible='11.2.0.3.0' scope=spfile sid='*';




----lock usser
pam_tally2 --reset -u gguser
pam_tally2 --reset -u oracle

----constraint
SELECT *
  FROM dba_ind_columns c
 WHERE c.table_name || c.column_name IN (SELECT b.table_name || B.COLUMN_NAME
                                       FROM dba_constraints a,
                                            all_cons_columns b
                                            where a.table_name||a.constraint_name=b.table_name||b.constraint_name
and a.table_name||a.constraint_name in (select table_name||constraint_name from dba_constraints where r_constraint_name='PK_TXNS2' )
)

--redo on flash disk
1681266.1
select INST_ID, QUEUE_TABLE_ID, DEQUEUE_INDEX_BLOCKS_FREED,HISTORY_INDEX_BLOCKS_FREED,TIME_INDEX_BLOCKS_FREED, INDEX_CLEANUP_COUNT, INDEX_CLEANUP_ELAPSED_TIME,INDEX_CLEANUP_CPU_TIME,LAST_INDEX_CLEANUP_TIME from GV$PERSISTENT_QMN_CACHE;
LOB_WRITE	T24LIVE	F_ENQUIRY_LEVEL	129704
SEL_LOB_LOCATOR	T24LIVE	F_ENQUIRY_LEVEL	62755
XML DOC WRITE	T24LIVE	FBNK_ACCT_ACTIVITY	60637
XML DOC BEGIN	T24LIVE	FBNK_ACCT_ACTIVITY	60598
XML DOC END	T24LIVE	FBNK_ACCT_ACTIVITY	60598
LOB_WRITE	T24LIVE	F_JOB_LIST_35	60442
UPDATE	T24LIVE	F_PROTOCOL	51309
----------------------reboot APP EM13C
route add -net 10.99.1.44 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.45 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.46 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.48 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.92 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.81 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.82 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.181 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.176 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.109.1.81 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.90 netmask 255.255.255.255 gw 10.97.4.1
route add -net 10.99.1.91 netmask 255.255.255.255 gw 10.97.4.1


Set security parameters
======================================================================================================================================
ALTER SYSTEM SET SEC_RETURN_SERVER_RELEASE_BANNER = FALSE SCOPE = SPFILE;	   
alter system set audit_trail=os scope=spfile;
ALTER SYSTEM SET AUDIT_SYS_OPERATIONS=TRUE SCOPE=SPFILE;	   
Alter system set REMOTE_OS_ROLES=FALSE scope=spfile;	   
Alter system set O7_DICTIONARY_ACCESSIBILITY=FALSE scope=spfile;	   
ALTER SYSTEM SET SEC_MAX_FAILED_LOGIN_ATTEMPTS =10 scope = spfile;	   
ALTER SYSTEM SET SEC_PROTOCOL_ERROR_FURTHER_ACTION = 'DELAY,3' SCOPE = SPFILE; 
ALTER SYSTEM SET SEC_PROTOCOL_ERROR_FURTHER_ACTION = 'DROP,3' SCOPE = SPFILE;	   
ALTER SYSTEM SET SEC_PROTOCOL_ERROR_TRACE_ACTION=LOG SCOPE = SPFILE;	   
ALTER SYSTEM SET SQL92_SECURITY = TRUE SCOPE = SPFILE;	 
ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON = TRUE SCOPE = spfile;


----------------------
SELECT RECID, t.XMLRECORD.GetClobVal() FROM FBNK_STMT_ENTRY t
*** MODULE NAME:(jpqn@t24tcb10 (TNS V1-V3)) 2017-06-30 10:18:58.777
delete  T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.___.2016____.%'  and rownum<1000001
delete  T24LIVE.FBNK_RE_CONSOL_PROFIT where recid like '%.VN001____.___.2002%'  and rownum<1000001

delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.97983.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.29037.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.10590.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.48574.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.32702.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.57668.20170701' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';
delete from "T24LIVE"."FBNK_PM_DLY_POSN_CLASS" a where a."RECID" = 'FTASC.1.00.TR.VND.20170701.74049.' and a.ROWID = 'AAAAAAAAAAAAAAAAAA';

select owner,table_name,column_name,data_type from DBA_TAB_COLUMNS where table_name='FBNK_RE_SPEC_ENT_TODAY'

--close cob
F_TIS_DW_CONTROL
-----add disk to diskgroup

alter diskgroup MONTHEND_DR add disk '/dev/rhdisk70' , '/dev/rhdisk203', '/dev/rhdisk204' REBALANCE power 10;
~47p

alter diskgroup COBR14_DR add disk '/dev/rhdisk61', '/dev/rhdisk64', '/dev/rhdisk69' REBALANCE power 8;
10h24

alter diskgroup T24R14_DR add disk '/dev/rhdisk219', '/dev/rhdisk225', '/dev/rhdisk226'  REBALANCE power 6;

------------------------------
Database

alter diskgroup T24R14_DR add disk 
'/dev/rhdisk252','/dev/rhdisk253','/dev/rhdisk254','/dev/rhdisk255','/dev/rhdisk256','/dev/rhdisk257','/dev/rhdisk258',
'/dev/rhdisk259','/dev/rhdisk260','/dev/rhdisk261','/dev/rhdisk262','/dev/rhdisk263','/dev/rhdisk264','/dev/rhdisk265',
'/dev/rhdisk266'
drop disk 
'/dev/rhdisk10','/dev/rhdisk11','/dev/rhdisk13','/dev/rhdisk14','/dev/rhdisk15','/dev/rhdisk16','/dev/rhdisk17','/dev/rhdisk18','/dev/rhdisk19',
'/dev/rhdisk20','/dev/rhdisk21','/dev/rhdisk22','/dev/rhdisk220','/dev/rhdisk221','/dev/rhdisk222','/dev/rhdisk223','/dev/rhdisk224','/dev/rhdisk23',
'/dev/rhdisk24','/dev/rhdisk25','/dev/rhdisk26','/dev/rhdisk27','/dev/rhdisk28','/dev/rhdisk29','/dev/rhdisk30','/dev/rhdisk31','/dev/rhdisk32','/dev/rhdisk33',
'/dev/rhdisk34','/dev/rhdisk35','/dev/rhdisk36','/dev/rhdisk37','/dev/rhdisk38','/dev/rhdisk39','/dev/rhdisk40','/dev/rhdisk41','/dev/rhdisk42','/dev/rhdisk43',
'/dev/rhdisk44','/dev/rhdisk45','/dev/rhdisk46','/dev/rhdisk47','/dev/rhdisk7','/dev/rhdisk8','/dev/rhdisk9','/dev/rhdisk219','/dev/rhdisk225','/dev/rhdisk226'
REBALANCE power 10;

FRA
alter diskgroup FRAT24R14_DR add disk 
'/dev/rhdisk267','/dev/rhdisk268','/dev/rhdisk269','/dev/rhdisk270','/dev/rhdisk271','/dev/rhdisk272','/dev/rhdisk273',
'/dev/rhdisk274','/dev/rhdisk275','/dev/rhdisk276'
drop disk
'/dev/rhdisk48','/dev/rhdisk49','/dev/rhdisk50','/dev/rhdisk51','/dev/rhdisk52'
REBALANCE power 10;


CRS
alter diskgroup ASM_DR add disk 
'/dev/rhdisk277','/dev/rhdisk278','/dev/rhdisk279'    
drop disk '/dev/rhdisk373'
REBALANCE power 10;

alter diskgroup ASM_DR add disk 
'/dev/rhdisk277','/dev/rhdisk278','/dev/rhdisk279'    
drop disk ASM_DR_0000
REBALANCE power 10;
3j7fcghbb1r4g
select
        SRC.BANKID         C1_BANKID,
        SRC.BANKID         C1_BANKID,
        SRC.CUST_ID        C2_CUST_ID,
        SRC.CUST_NAME      C3_CUST_NAME,
        SRC.CUST_TYPE      C4_CUST_TYPE,
        SRC.ARTICAL_127    C5_ARTICAL_127,
        SRC.RELATED_COM    C6_RELATED_COM,
        SRC.TOTAL_ASSET    C7_TOTAL_ASSET,
        SRC.SIZE_OF_COM    C8_SIZE_OF_COM,
        SRC.ECO_CODE       C9_ECO_CODE,
        SRC.INDTRY_CODE    C10_INDTRY_CODE,
        SRC.INSURED_FLAG           C11_INSURED_FLAG,
        SRC.CITAD_CODE     C12_CITAD_CODE,
        SRC.SHORT_NAME     C13_SHORT_NAME,
        SRC.FOREIGN_NAME           C14_FOREIGN_NAME,
        SRC.SEX    C15_SEX,
        case when SRC.birth_date <= to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
else SRC.birth_date
end        C16_BIRTH_DATE,
        SRC.PHONE          C17_PHONE,
        SRC.FAX    C18_FAX,
        SRC.WEB    C19_WEB,
        SRC.EMAIL          C20_EMAIL,
        SRC.IDNUM          C21_IDNUM,
        case when SRC.id_date <= to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
else SRC.id_date
end        C22_ID_DATE,
        SRC.ORTHERTYPE     C23_ORTHERTYPE,
        SRC.ORTHERNUM      C24_ORTHERNUM,
        case when SRC.ortherdt <= to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
else SRC.ortherdt
end        C25_ORTHERDT,
        SRC.TAXCODE        C26_TAXCODE,
        case when SRC.tax_dt <= to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
else SRC.tax_dt
end        C27_TAX_DT,
        SRC.BR_NO          C28_BR_NO,
        case when SRC.br_date <= to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
else SRC.br_date
end        C29_BR_DATE,
        SRC.CO_NO          C30_CO_NO,
        case when SRC.conum_date < to_date('18000101','yyyymmdd')  then to_date('19000101','yyyymmdd')
 else SRC.conum_date
end        C31_CONUM_DATE,
        SRC.RESIDENT       C32_RESIDENT,
        SRC.NATIONALITY    C33_NATIONALITY,
        SRC.ADDRESS        C34_ADDRESS,
        SRC.PROVINCE       C35_PROVINCE,
        SRC.NAMESPOUSE     C36_NAMESPOUSE,
        SRC.IDSPOUSE       C37_IDSPOUSE,
        SRC.NUMYEAR        C38_NUMYEAR,
        SRC.POSITION       C39_POSITION,
        SRC.NAMEWORK       C40_NAMEWORK,
        SRC.INCOME         C41_INCOME,
        SRC.CAPITAL        C42_CAPITAL,
        SRC.CCYCAPITAL     C43_CCYCAPITAL,
        SRC.DIRECTORS      C44_DIRECTORS,
        SRC.IDDIRECTORS    C45_IDDIRECTORS,
        SRC.CHAIRMAN       C46_CHAIRMAN
from    TCB_DWH_VAS.R_TT35_MD_CUST_INFO   SRC
where   (1=1)
And (SRC.CUST_ID in (select CUSTOMER_CODE from EDW_STG.T_CUS))

host \"$SWITCHLOG\";

Window#123#Tech
sqlplus dbsnmp/PAssw0rd@t24r14dr as sysdba
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
/u01/app/oracle/product/11.2.0.4/dbhome_1/bin/sqlplus -s dbsnmp/PAssw0rd@t24r14dr as sysdba <<EOF
alter system archive log current;
exit
EOF



----read on disk 
set lines 200
col Device for a55
select * from
(
select a.DBNAME as "DB Name",
b.PATH as "Device",
a.READS as "Read Request",
a.WRITES as "Write Requests",
a.BYTES_READ/1024/1024 as "Total Read MB",
a.BYTES_WRITTEN/1024/1024 "Total Write MB"
from v$asm_disk_iostat a, v$asm_disk b
where  a.GROUP_NUMBER=b.GROUP_NUMBER 
and a.DISK_NUMBER=b.DISK_NUMBER  and b.path like '/dev/oracleasm/disks/DATA2%'
order by 3 desc
)
where rownum <=100;
;




-----------DC
Live
11.39:
alter diskgroup T24R14_DC add disk '/dev/rhdisk120','/dev/rhdisk121','/dev/rhdisk122' REBALANCE power 10;
alter diskgroup T24R14_DC add disk '/dev/rhdisk120','/dev/rhdisk121','/dev/rhdisk122' REBALANCE power 10;
11.40
/dev/rhdisk121
/dev/rhdisk122
/dev/rhdisk123

Postcob
11.39     
alter diskgroup COBR14_DC  add disk '/dev/rhdisk117','/dev/rhdisk118','/dev/rhdisk119'  REBALANCE power 10;
11.40
/dev/rhdisk118
/dev/rhdisk119
/dev/rhdisk120


-----archive log size
select blocks*block_size/(1024*1024) sizeInMB,sequence# 
from v$archived_log 
order by sequence# 

---
create user arcsight identified by <password>;
grant connect to arcsight;
alter user arcsight account unlock;
grant select on sys.dba_audit_trail to arcsight;
grant select on sys.v_$instance to arcsight;
grant select on sys.audit$ to arcsight;
grant select any dictionary to arcsight;
grant select on sys.dba_common_audit_trail to arcsight;

<row id='BNK/REPORT.PRINT.REPORTING' xml:space='preserve'><c1>R999</c1><c3>0</c3><c4>F</c4><c6>CLEARE.REPORT.TCB</c6><c6 m='2'>EB.EOD.REPORT.PRINT</c6><c6 m='3'>BATCH.HALT</c6><c7 m='2'>CLEARE.REPORT.TCB</c7><c7 m='3'></c7><c8>D</c8><c8 m='2'>D</c8><c8 m='3'>D</c8><c9 m='3'></c9><c10 m='3'></c10><c11 m='3'></c11><c12>0</c12><c12 m='2'>0</c12><c12 m='3'>0</c12><c13>20170614</c13><c13 m='2'>20170614</c13><c13 m='3'>20170614</c13><c14 m='3'></c14><c15 m='3'></c15><c16 m='3'></c16><c28>71</c28><c29>52683_DUONG01.1071_I_INAU</c29><c30>1705110211</c30><c30 m='2'>1705110211</c30><c31>52683_DUONG01.1071</c31><c32>VN0010001</c32><c33>297</c33></row>

<row id='BNK/REPORT.PRINT.REPORTING' xml:space='preserve'><c1>R999</c1><c3>1</c3><c4>F</c4><c6>CLEARE.REPORT.TCB</c6><c6 m='2'>EB.EOD.REPORT.PRINT</c6><c6 m='3'>BATCH.HALT</c6><c7 m='2'>CLEARE.REPORT.TCB</c7><c7 m='3'></c7><c8>D</c8><c8 m='2'>D</c8><c8 m='3'>D</c8><c9 m='3'></c9><c10 m='3'></c10><c11 m='3'></c11><c12>2</c12><c12 m='2'>2</c12><c12 m='3'>1</c12><c13>20170614</c13><c13 m='2'>20170614</c13><c13 m='3'>20170613</c13><c14 m='3'></c14><c15 m='3'></c15><c16 m='3'></c16><c28>71</c28><c29>52683_DUONG01.1071_I_INAU</c29><c30>1705110211</c30><c30 m='2'>1705110211</c30><c31>52683_DUONG01.1071</c31><c32>VN0010001</c32><c33>297</c33></row>
---

cd /u01/app/oracle/diag/rdbms/esbinfra/esbinfra2/trace
echo > esbinfra2_ora_19923046.trc

--resize datafile
select 'alter database datafile ''' || file_name || ''' resize ' ||
       ceil( (nvl(hwm,1)*8192)/1024/1024 )  || 'm;' cmd
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and ceil( blocks*8192/1024/1024) -
      ceil( (nvl(hwm,1)*8192)/1024/1024 ) > 0
	  
SQL> alter database datafile '+DATA04/pedb/datafile/vw_data_ts_new.342.944672077' resize 30888m;

Database altered.

SQL> alter database datafile '+DATA04/pedb/datafile/vw_index_ts_new.637.948014095' resize 28G;

Database altered.

SQL> alter database datafile '+DATA04/pedb/datafile/vw_index_ts_new.637.948014095' resize 20G;

Database altered.

YEAR12 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = tcp)(HOST = 10.97.8.150)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = year12)
    )
  )
  
  
  select count(*) from 
(
select case 
when owner='SYS' then table_name
when owner<>'SYS' then owner||'.'||table_name
end as privs
from role_tab_privs where 
(table_name  in ('CREATE EXTERNAL JOB','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
or (table_name ='ORD_DICOM' and owner='ORDSYS')
or (table_name ='DRITHSX' and owner='CTXSYS'))
and role in (SELECT granted_role FROM DBA_ROLE_PRIVS where grantee='PUBLIC'
)
union all
select privilege from role_sys_privs
where privilege  ='CREATE EXTERNAL JOB'
and role in (SELECT granted_role FROM DBA_ROLE_PRIVS where grantee='PUBLIC')
union all
select case 
when owner='SYS' then table_name
when owner<>'SYS' then owner||'.'||table_name
end as privs
from dba_tab_privs where
(table_name  in ('CREATE EXTERNAL JOB','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
)

C05076D580000944
C05076D580000CC4
C05076D580000784
C05076D580000B04

declare
   cmd2            VARCHAR2 (4000);
BEGIN
   FOR c_cmd
      IN (SELECT    'alter database datafile '''
                 || file_name
                 || ''' resize '
                 || CEIL ( (NVL (hwm, 1) * 8192) / 1024 / 1024)
                 || 'm'  as command
            FROM dba_data_files a,
                 (  SELECT file_id, MAX (block_id + blocks - 1) hwm
                      FROM dba_extents
                  GROUP BY file_id) b
           WHERE     a.file_id = b.file_id(+)
                 AND   CEIL (blocks * 8192 / 1024 / 1024)
                     - CEIL ( (NVL (hwm, 1) * 8192) / 1024 / 1024) > 0)
   LOOP
      DBMS_OUTPUT.put_line (c_cmd.command);
      EXECUTE IMMEDIATE c_cmd.command;
   END LOOP;
END;
/	  

--log audit -- login fail
select username, os_username, userhost, client_id, to_char(timestamp,'YYYY/MM/DD HH24:MI'), returncode, count(*) logins
from dba_audit_trail
where timestamp>trunc(sysdate)+10/24 and timestamp<trunc(sysdate)+10/24+1/48
--and returncode=1017 --1017=invalid user/password
group by username,os_username,userhost, client_id, to_char(timestamp,'YYYY/MM/DD HH24:MI'), returncode 
order by to_char(timestamp,'YYYY/MM/DD HH24:MI');


select from sys.aud$ where action#=''
select * from AUDIT_ACTIONS --action# information 

--move SYS object to other tbs
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_location(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
    audit_trail_location_value => 'AUDIT_DATA');
END;
/
------run OS script from DB
http://docs.oracle.com/database/121/ADMIN/scheduse.htm#ADMIN12384
First, you need to create a credential, with the OS user and password in whose name the job will run:

begin
  dbms_scheduler.create_credential
  ( credential_name => 'my_credential',
    username        => 'oracle',
    password        => 'Oracle123'  );
end;
/
After that you can use this credential when creating an external job. For example calling your convert script with 2 arguments (input and output file)

begin
  dbms_scheduler.create_job  (
    job_name             => 'convert_job',
    job_type             => 'executable',
    number_of_arguments  => 2,
    job_action           => '/usr/bin/bash/convert.sh',
    auto_drop            => true,
    credential_name      => 'my_credential'  );
  dbms_scheduler.set_job_argument_value('convert_job', 1, '/home/oracle/file.in');
  dbms_scheduler.set_job_argument_value('convert_job', 2, '/home/oracle/file.out');
  dbms_scheduler.enable('convert_job');
end;
/

--schedule job
SELECT CLIENT_NAME,STATUS FROM DBA_AUTOTASK_CLIENT;
SELECT CLIENT_NAME,STATUS FROM DBA_AUTOTASK_TASK;
SELECT * FROM dba_autotask_client_history;
select * from DBA_SCHEDULER_WINDOWS;
select * from DBA_AUTOTASK_JOB_HISTORY

select * from dba_scheduler_job_run_details  where job_name like 'DBA%' and owner='SYS'
select * from dba_scheduler_jobs
--scheduler window
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_WINDOW
    (
       window_name     => 'WEDNESDAY_WINDOW'
      ,start_date      => NULL
      ,repeat_interval => 'freq=daily;byday=WED;byhour=22;byminute=0; bysecond=0'
      ,end_date        => NULL
      ,resource_plan   => 'DEFAULT_MAINTENANCE_PLAN'
      ,duration        => to_dsInterval('+000 06:00:00')
      ,window_priority => 'LOW'
      ,comments        => 'Wednesday window for maintenance tasks'
    );
  SYS.DBMS_SCHEDULER.ENABLE
    (name => 'SYS.WEDNESDAY_WINDOW');

END;
/

BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYS.WEDNESDAY_WINDOW'
     ,attribute => 'REPEAT_INTERVAL'
     ,value     => 'freq=daily;byday=WED;byhour=20;byminute=0; bysecond=0');
END;
/


--log switch frequence
select to_char(first_time,'yyyy-mm-dd hh24'),count(*) from v$archived_log
where first_time> sysdate-2
and name not in ('cobr14dc','cobr14dr','t24r14dr')
group by to_char(first_time,'yyyy-mm-dd hh24')
order by 1
--tang truong archive log
select to_date (FIRST_TIME,'DD-MM-YYYY'),SUM(BLOCKS *BLOCK_SIZE)/1024/1024/1024
from V$ARCHIVED_LOG
where FIRST_TIME> trunc(sysdate – 8)
group by to_date (FIRST_TIME,'DD-MM-YYYY')
order by 1

--DB link
create database link MBBDB connect to dbsnmp identified by PAssw0rd using '(DESCRIPTION =    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.99.1.67)(PORT = 1521))(CONNECT_DATA =  (SERVER = DEDICATED)   (SERVICE_NAME = mbbdb)  ) )'

--Causes of Oracle Buffer Busy Waits
http://www.dba-oracle.com/art_builder_bbw.htm	

--characterSet
SELECT name, value$ FROM sys.props$ WHERE name like '%CHARACTERSET%' ;
SELECT * FROM NLS_DATABASE_PARAMETERS where parameter like '%CHARACTERSET%';

--size of table
SELECT   owner, table_name, TRUNC(sum(bytes)/1024/1024) MB FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%'
UNION ALL SELECT i.table_name, i.owner, s.bytes FROM dba_indexes i, dba_segments s WHERE s.segment_name = i.index_name  AND   s.owner = i.owner AND   s.segment_type like 'INDEX%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner AND   s.segment_type like 'LOB%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.index_name  AND   s.owner = l.owner AND   s.segment_type = 'LOBINDEX'
)
WHERE owner in UPPER('&owner') 
GROUP BY table_name, owner 
HAVING SUM(bytes)/1024/1024 > 10  
ORDER BY SUM(bytes) desc;


SELECT owner,table_name, sum(bytes)/1024/1024/1024
FROM (SELECT s.owner,s.segment_name AS table_name, s.bytes FROM dba_SEGMENTS s WHERE s.segment_type = 'TABLE'
      UNION ALL
      SELECT l.owner,l.table_name AS table_name,s.bytes  FROM dba_SEGMENTS s,dba_lobs l WHERE s.segment_name = l.segment_name AND   s.owner = l.owner
	  )
group by owner,table_name
order by 3 desc;

-------------------------------------------------------------
--statistic
-------------------------------------------------------------
 EXEC DBMS_STATS.GATHER_SCHEMA_STATS('SYS');
 EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME =>'SYS', TABNAME => 'X$KTFBUE',ESTIMATE_PERCENT=>100);
--gather big tab incremental 
SYS.WRI$_OPTSTAT_SYNOPSIS$
https://blogs.oracle.com/optimizer/entry/maintaining_statistics_on_large_partitioned_tables
https://blogs.oracle.com/optimizer/entry/incremental_statistics_maintenance_what_statistics
--auto sample
http://optimizermagic.blogspot.com/2008/01/improvement-of-auto-sampling-statistics.html

https://blogs.oracle.com/optimizer/entry/incremental_statistics_maintenance_what_statistics
 
 --The purpose of this note is to address how to plan for fixed object statistics needs and gathering.
1. Having no statistics (and then using dynamic sampling) is better than bad statistics, but representative statistics are what should be the strategic goal
2. Representative statistics can be gathered in non-peak hours, one simply has to plan for the different volumes involved.
At a high level, there are 3 basic categories of fixed object tables (the X$ tables under the V$ views) to consider when planning for gathering fixed object statistics:
(Relatively) Static Data once the instance is warmed -this is mainly structural data, for example, views covering datafiles, controlfile contents, etc
Data that changes session based on the number of sessions connected, for example: v$session, v$access, etc.
Volatile data, based on workload mix -- v$sql, v$sql_plan, etc
Choose a time of day that will give a representative sampling for as many of the above categories as possible. If gathering under peak load is not possible, then try to gather after the instance has been warmed up / running for some time so that "Static" data is relatively fixed.  If the instance has a high number of sessions under normal workload, attempt to gather the statistics when there are still a large number of sessions connected (even if the sessions are idle).
There are some fixed tables that are simply very volatile by nature and it will be extremely hard to get accurate statistics on. In general though, in the case of these volatile fixed tables, better plans are achieved by gathering statistics on these tables than by not gathering statistics. 
3. Since its not possible to predict the likelihood of individual environments experiencing noticeable performance degradation, testing is strongly encourage. Performance Degradation has not been able to be replicated in Oracle test instances, but potential for such problems is known to exist.
4. Plan for performance degradation while gathering the statistics. It is possible the degradation could appear to be a hang which lasts the length of stats gathering. It is also possible the instance will experience little to no degradation, particularly on smaller or less loaded systems.  Key points to consider are volume of data in the fixed tables and level of concurrency in the system. 
5. If there are severe issues, diagnose what table gathering is 'stuck' on and lock that table's' statistics as a short term workaround. From a long term solution standpoint, it would be preferable to have the statistics but having a running system is likely to be the priority. 
6. If no statistics are gathered, the instance reverts to dynamic sampling to determine statistics for the plan when the query is parsed. Plans may change on re-parse as a result, and the instance may or may not get accurate statistics in this manner.  For volatile tables (see 2.3 above) it may be extremely difficult to generate accurate statistics.
 -- current Statistics can be recorded in a stats table and exported for reload later as follows
--> count after truncate table still have result like in stat
 exec dbms_stats.export_fixed_objects_stats(stattab=>'STATS_TABLE', statown=>'MY_USER');
 
 
------------------------------------------------------------------
--execution plan
------------------------------------------------------------------
explain plan for select * from dual
-->
select * from table (dbms_xplan.display)

------------------------------------------------------------------
--OS
------------------------------------------------------------------
--find file
updatedb --> index 
locate <filename>  --> find

-----------------------------------------------------------------
--check to drop tablespace
-----------------------------------------------------------------
select owner||'.'||table_name from dba_part_tables where def_tablespace_name =''
alter table <tab_name> modify default attributes [for partition <name>] tablespace default  <tbs_name>;

select owner||'.'||index_name from dba_part_indexes where def_tablespace_name=''
alter index <ind_name> modify default attributes [for partition <name>] tablespace default  <tbs_name>; 

select table_owner||'.'||table_name, lob_name from dba_part_lobs where def_tablespace_name=''
alter table <tab_name> modify default attributes lob (<lob_name>) tablespace <tablespace>;
r
-------------------------------------------------------------
--check hiden parameter
-------------------------------------------------------------
SELECT a.ksppinm "Parameter", a.ksppdesc "Description",
b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE a.indx = b.indx
AND a.indx = c.indx
AND a.ksppinm LIKE '/_%' escape '/'  
and a.ksppinm  like '_disable_recoverable_recovery%'
ORDER BY 1;

--backup parameter 

col Parameter for a70 
col "Session Value" for a30
col "Instance Value" for a30
SELECT a.ksppinm "Parameter", 
b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE a.indx = b.indx
AND a.indx = c.indx
AND a.ksppinm LIKE '/_%' escape '/'  
ORDER BY 1;

col name for a50 
col value for a100
select inst_id,name,value from gv$parameter order by name,inst_id

--script backup file
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
FILE_INST_NAME=/home/oracle/detail.txt
ps -ef |grep pmon |grep -v ASM|grep -v grep| awk '{print $8}' > "$FILE_INST_NAME" 

while read -r line; do
    echo "Name read from file - "
inst_name=`echo $line| sed "s/ora_pmon_//g"`
export ORACLE_SID=$inst_name
LOG_FILE=/home/oracle/backup_parameter_$ORACLE_SID.txt

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append

col Parameter for a60 
col "Session Value" for a30
col "Instance Value" for a30
SELECT a.ksppinm "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
FROM x\$ksppi a, x\$ksppcv b, x\$ksppsv c
WHERE a.indx = b.indx  AND a.indx = c.indx AND a.ksppinm LIKE '/_%' escape '/'  
ORDER BY 1;

col name for a50 
col value for a100
select inst_id,name,value from gv\$parameter order by name,inst_id;
spool off
exit
EOF
done < "$FILE_INST_NAME"



SELECT a.ksppinm "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE a.indx = b.indx  AND a.indx = c.indx
and a.ksppinm in ('_lm_sync_timeout','shared_pool_size','_gc_policy_minimum','_lm_tickets','gcs_server_processes','session_cached_cursors','cursor_sharing','optimizer_index_cost_adj','db_files')
ORDER BY 1;s

_swrf_test_action
-----------------------------------------------------------------
--ASH report
-----------------------------------------------------------------
http://www.dba-oracle.com/t_rac_tuning_ash_for_rac.htm
ASH for 1 node
@$ORACLE_HOME/rdbms/admin/ashrpt.sql
ASH for rac
@$ORACLE_HOME/rdbms/admin/ashrpti.sql

-----------------------------------------------------------------
--AWR report
-----------------------------------------------------------------

https://blog.dbi-services.com/show-the-top-10-events-from-latest-awr-snapshot/

with snap as (
  select * from (
    select dbid,lead(snap_id)over(partition by instance_number order by end_interval_time desc) bid,snap_id eid,row_number() over(order by end_interval_time desc) n
    from dba_hist_snapshot where dbid=(select dbid from v$database)
  ) where n=1
),
awr as (
        select rownum line,output
        from table(
                dbms_workload_repository.awr_report_text(l_dbid=>(select dbid from snap),l_inst_num=>(select instance_number from v$instance),l_bid=>(select bid from snap),l_eid=>(select eid from snap),l_options=>1+4+8)
        )
),
awr_sections as (
        select
         last_value(case when regexp_replace(output,' *DB/Inst.*$') in (''
        ,'Database Summary'
        ,'Database Instances Included In Report'
        ,'Top Event P1/P2/P3 Values'
        ,'Top SQL with Top Events'
        ,'Top SQL with Top Row Sources'
        ,'Top Sessions'
        ,'Top Blocking Sessions'
        ,'Top PL/SQL Procedures'
        ,'Top Events'
        ,'Top DB Objects'
        ,'Activity Over Time'
        ,'Wait Event Histogram Detail (64 msec to 2 sec)'
        ,'Wait Event Histogram Detail (4 sec to 2 min)'
        ,'Wait Event Histogram Detail (4 min to 1 hr)'
        ,'SQL ordered by Elapsed Time'
        ,'SQL ordered by CPU Time'
        ,'SQL ordered by User I/O Wait Time'
        ,'SQL ordered by Gets'
        ,'SQL ordered by Reads'
        ,'SQL ordered by Physical Reads (UnOptimized)'
        ,'SQL ordered by Optimized Reads'
        ,'SQL ordered by Executions'
        ,'SQL ordered by Parse Calls'
        ,'SQL ordered by Sharable Memory'
        ,'SQL ordered by Version Count'
        ,'SQL ordered by Cluster Wait Time'
        ,'Key Instance Activity Stats'
        ,'Instance Activity Stats'
        ,'IOStat by Function summary'
        ,'IOStat by Filetype summary'
        ,'IOStat by Function/Filetype summary'
        ,'Tablespace IO Stats'
        ,'File IO Stats'
        ,'Checkpoint Activity'
        ,'MTTR Advisory'
        ,'Segments by Logical Reads'
        ,'Segments by Physical Reads'
        ,'Segments by Direct Physical Reads'
        ,'Segments by Physical Read Requests'
        ,'Segments by UnOptimized Reads'
        ,'Segments by Optimized Reads'
        ,'Segments by Physical Write Requests'
        ,'Segments by Physical Writes'
        ,'Segments by Direct Physical Writes'
        ,'Segments by DB Blocks Changes'
       ,'Segments by Table Scans'
        ,'Segments by Row Lock Waits'
        ,'Segments by ITL Waits'
        ,'Segments by Buffer Busy Waits'
        ,'Segments by Global Cache Buffer Busy'
        ,'Segments by CR Blocks Received'
        ,'Segments by Current Blocks Received'
        ,'In-Memory Segments by Scans'
        ,'In-Memory Segments by DB Block Changes'
        ,'In-Memory Segments by Populate CUs'
        ,'In-Memory Segments by Repopulate CUs'
        ,'Interconnect Device Statistics'
        ,'Dynamic Remastering Stats'
        ,'Resource Manager Plan Statistics'
        ,'Resource Manager Consumer Group Statistics'
        ,'Replication System Resource Usage'
        ,'Replication SGA Usage'
        ,'GoldenGate Capture'
        ,'GoldenGate Capture Rate'
        ,'GoldenGate Apply Reader'
        ,'GoldenGate Apply Coordinator'
        ,'GoldenGate Apply Server'
        ,'GoldenGate Apply Coordinator Rate'
        ,'GoldenGate Apply Reader and Server Rate'
        ,'XStream Capture'
        ,'XStream Capture Rate'
        ,'XStream Apply Reader'
        ,'XStream Apply Coordinator'
        ,'XStream Apply Server'
        ,'XStream Apply Coordinator Rate'
        ,'XStream Apply Reader and Server Rate'
        ,'Table Statistics by DML Operations'
        ,'Table Statistics by Conflict Resolutions'
        ,'Replication Large Transaction Statistics'
        ,'Replication Long Running Transaction Statistics'
        ,'Streams Capture'
        ,'Streams Capture Rate'
        ,'Streams Apply'
        ,'Streams Apply Rate'
        ,'Buffered Queues'
        ,'Buffered Queue Subscribers'
        ,'Persistent Queues'
        ,'Persistent Queues Rate'
        ,'Persistent Queue Subscribers'
        ,'Rule Set'
        ,'Shared Servers Activity'
        ,'Shared Servers Rates'
        ,'Shared Servers Utilization'
        ,'Shared Servers Common Queue'
        ,'Shared Servers Dispatchers'
        ,'init.ora Parameters'
        ,'init.ora Multi-Valued Parameters'
        ,'Cluster Interconnect'
        ,'Wait Classes by Total Wait Time'
        ,'Top 10 Foreground Events by Total Wait Time'
        ,'Top ADDM Findings by Average Active Sessions'
        ,'Cache Sizes'
        ,'Host Configuration Comparison'
        ,'Top Timed Events'
        ,'Top SQL Comparison by Elapsed Time'
        ,'Top SQL Comparison by I/O Time'
        ,'Top SQL Comparison by CPU Time'
        ,'Top SQL Comparison by Buffer Gets'
        ,'Top SQL Comparison by Physical Reads'
        ,'Top SQL Comparison by UnOptimized Read Requests'
        ,'Top SQL Comparison by Optimized Reads'
        ,'Top SQL Comparison by Executions'
        ,'Top SQL Comparison by Parse Calls'
        ,'Top SQL Comparison by Cluster Wait Time'
        ,'Top SQL Comparison by Sharable Memory'
        ,'Top SQL Comparison by Version Count'
        ,'Top Segments Comparison by Logical Reads'
        ,'Top Segments Comparison by Physical Reads'
        ,'Top Segments Comparison by Direct Physical Reads'
        ,'Top Segments Comparison by Physical Read Requests'
        ,'Top Segments Comparison by Optimized Read Requests'
        ,'Top Segments Comparison by Physical Write Requests'
        ,'Top Segments Comparison by Physical Writes'
        ,'Top Segments Comparison by Table Scans'
        ,'Top Segments Comparison by DB Block Changes'
        ,'Top Segments by Buffer Busy Waits'
        ,'Top Segments by Row Lock Waits'
        ,'Top Segments by ITL Waits'
        ,'Top Segments by CR Blocks Received'
        ,'Top Segments by Current Blocks Received'
        ,'Top Segments by GC Buffer Busy Waits'
        ,'Top In-Memory Segments Comparison by Scans'
        ,'Top In-Memory Segments Comparison by DB Block Changes'
        ,'Top In-Memory Segments Comparison by Populate CUs'
        ,'Top In-Memory Segments Comparison by Repopulate CUs'
        ,'Service Statistics'
        ,'Service Statistics (RAC)'
        ,'Global Messaging Statistics'
        ,'Global CR Served Stats'
        ,'Global CURRENT Served Stats'
        ,'Replication System Resource Usage'
        ,'Replication SGA Usage'
        ,'Streams by CPU Time'
        ,'GoldenGate Capture'
        ,'GoldenGate Capture Rate'
        ,'GoldenGate Apply Coordinator'
        ,'GoldenGate Apply Reader'
        ,'GoldenGate Apply Server'
        ,'GoldenGate Apply Coordinator Rate'
        ,'GoldenGate Apply Reader and Server Rate'
        ,'XStream Capture'
        ,'XStream Capture Rate'
        ,'XStream Apply Coordinator'
        ,'XStream Apply Reader'
        ,'XStream Apply Server'
        ,'XStream Apply Coordinator Rate'
        ,'XStream Apply Reader and Server Rate'
        ,'Table Statistics by DML Operations'
        ,'Table Statistics by Conflict Resolutions'
        ,'Replication Large Transaction Statistics'
        ,'Replication Long Running Transaction Statistics'
        ,'Streams by IO Time'
        ,'Streams Capture'
        ,'Streams Capture Rate'
        ,'Streams Apply'
        ,'Streams Apply Rate'
        ,'Buffered Queues'
        ,'Rule Set by Evaluations'
        ,'Rule Set by Elapsed Time'
        ,'Persistent Queues'
        ,'Persistent Queues Rate'
        ,'IOStat by Function - Data Rate per Second'
        ,'IOStat by Function - Requests per Second'
        ,'IOStat by File Type - Data Rate per Second'
        ,'IOStat by File Type - Requests per Second'
        ,'Tablespace IO Stats'
        ,'Top File Comparison by IO'
        ,'Top File Comparison by Read Time'
        ,'Top File Comparison by Buffer Waits'
        ,'Key Instance Activity Stats'
        ,'Other Instance Activity Stats'
        ,'Enqueue Activity'
        ,'Buffer Wait Statistics'
        ,'Dynamic Remastering Stats'
        ,'Library Cache Activity'
        ,'Library Cache Activity (RAC)'
        ,'init.ora Parameters'
        ,'init.ora Multi-Valued Parameters'
        ,'Buffered Subscribers'
        ,'Persistent Queue Subscribers'
        ,'Shared Servers Activity'
        ,'Shared Servers Rates'
        ,'Shared Servers Utilization'
        ,'Shared Servers Common Queue'
        ,'Shared Servers Dispatchers'
        ,'Database Summary'
        ,'Database Instances Included In Report'
        ,'Top ADDM Findings by Average Active Sessions'
        ,'Cache Sizes'
        ,'OS Statistics By Instance'
        ,'Foreground Wait Classes -  % of Total DB time'
        ,'Foreground Wait Classes'
        ,'Foreground Wait Classes -  % of DB time '
        ,'Time Model'
        ,'Time Model - % of DB time'
        ,'System Statistics'
        ,'System Statistics - Per Second'
        ,'System Statistics - Per Transaction'
        ,'Global Cache Efficiency Percentages'
        ,'Global Cache and Enqueue Workload Characteristics'
        ,'Global Cache and Enqueue Messaging Statistics'
        ,'SysStat and Global Messaging  - RAC'
        ,'SysStat and  Global Messaging (per Sec)- RAC'
        ,'SysStat and Global Messaging (per Tx)- RAC'
        ,'CR Blocks Served Statistics'
        ,'Current Blocks Served Statistics'
        ,'Global Cache Transfer Stats'
        ,'Global Cache Transfer (Immediate)'
        ,'Cluster Interconnect'
        ,'Interconnect Client Statistics'
        ,'Interconnect Client Statistics (per Second)'
        ,'Interconnect Device Statistics'
        ,'Interconnect Device Statistics (per Second)'
        ,'Ping Statistics'
        ,'Top Timed Events'
        ,'Top Timed Foreground Events'
        ,'Top Timed Background Events'
        ,'Resource Manager Plan Statistics'
        ,'Resource Manager Consumer Group Statistics'
        ,'SQL ordered by Elapsed Time (Global)'
        ,'SQL ordered by CPU Time (Global)'
        ,'SQL ordered by User I/O Time (Global)'
        ,'SQL ordered by Gets (Global)'
        ,'SQL ordered by Reads (Global)'
        ,'SQL ordered by UnOptimized Read Requests (Global)'
        ,'SQL ordered by Optimized Reads (Global)'
        ,'SQL ordered by Cluster Wait Time (Global)'
        ,'SQL ordered by Executions (Global)'
        ,'IOStat by Function (per Second)'
        ,'IOStat by File Type (per Second)'
        ,'Segment Statistics (Global)'
        ,'Library Cache Activity'
        ,'System Statistics (Global)'
        ,'Global Messaging Statistics (Global)'
        ,'System Statistics (Absolute Values)'
        ,'PGA Aggregate Target Statistics'
        ,'Process Memory Summary'
        ,'init.ora Parameters'
        ,'init.ora Multi-valued Parameters'
        ,'Database Summary'
        ,'Database Instances Included In Report'
        ,'Time Model Statistics'
        ,'Operating System Statistics'
        ,'Host Utilization Percentages'
        ,'Global Cache Load Profile'
        ,'Wait Classes'
        ,'Wait Events'
        ,'Cache Sizes'
        ,'PGA Aggr Target Stats'
        ,'init.ora Parameters'
        ,'init.ora Multi-valued Parameters'
        ,'Global Cache Transfer Stats'
        ,' Exadata Storage Server Model'
        ,' Exadata Storage Server Version'
        ,' Exadata Storage Information'
        ,' Exadata Griddisks'
        ,' Exadata Celldisks'
        ,' ASM Diskgroups'
        ,' Exadata Non-Online Disks'
        ,' Exadata Alerts Summary'
        ,' Exadata Alerts Detail'
        ,'Exadata Statistics'
) then output end ) ignore nulls over(order by line) section
        ,output
        from awr
)
select output AWR_REPORT_TEXT from awr_sections where regexp_like(section,'&1') or regexp_like(output,'&2')
/


AWR Snapshots Not Generating (Doc ID 308003.1)
So, if we have recreated the AWR objects by running catnoawr.sql and catawr.sql, then we need to bounce the database. 
On restart of the database instance the WRM$_DATABASE_INSTANCE will be populated with the required data. 
Then we can take manual snapshots and also MMON process will start collecting the snapshots.


BEGIN
 DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT('TYPICAL');
 END;
 /

 ERROR at line 1:
ORA-13509: error encountered during updates to a SWRF table
ORA-02291: integrity constraint (ORA-02291: integrity constraint (SYS.WRM$_SNAPSHOT_FK) violated - parent key not found .) violated - parent key not found
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 8
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 31
ORA-06512: at line 1

cd /u01/app/oracle/db11g/rdbms/admin
sqlplus / as sysdba
@catnoawr.sql
@catawr.sql

select extract(hour from snap_interval) *60+extract(minute from snap_interval), extract(day from retention )
from dba_hist_wr_control

execute dbms_workload_repository.modify_snapshot_settings (
   interval => 60, --minutes
   retention => 1576800); --minutes

-------------------------------------------------------------
--uppatch
-------------------------------------------------------------
11.2.0.3 --> 11.2.0.4
https://gemsofprogramming.wordpress.com/2014/12/02/upgrade-oracle-rac-grid-database-from-11-2-0-3-0-to-11-2-0-4-0-or-lets-run-the-gauntlet/
https://docs.oracle.com/cd/E11882_01/install.112/e41961/procstop.htm#CWLIN422
--========OS
nmon --> m
topas -->
ps aux |more --> 
find /path/to/files* -mtime +5 -name "" -exec rm {} \;
find . -mtime +3 -name "log_*.xml" -exec rm {} \;
find . -mtime +10 -name "em13cdb_*.aud" -exec rm {} \;
find . -mtime +10 -name "*.trc" -exec rm {} \;
find . -mtime +100 -name "+ASM2_ora_*.aud" -exec rm {} \;
find . -mtime +3 -name "dc0*" -exec rm {} \;

find . -mtime +3 -name "cobr14dr_*.aud" -exec rm {} \;

find /backupdata/ -type d -mtime +3 -name "backup*" -exec rm -rf {} \;
-type d
-------------------------------------------------------------
--RAC
-------------------------------------------------------------
--check date
cluvfy comp clocksync -n all -verbose
cluvfy comp clocksync -noctss -n dr-ora-db01,dr-ora-db02 -verbose

t24db04@grid:/home/grid> ps -ef|grep pmon
  oracle 57999496        1   0   Jan 02      - 39:47 ora_pmon_year15dr
  --  grid 65339450        1   0   Dec 24      - 50:58 ora_pmon_year14dr
  --oracle 14549974        1   0   Dec 24      - 43:32 ora_pmon_year12dr
 --   grid 15270772        1   0   Dec 24      - 25:58 asm_pmon_+ASM
  --oracle  7734526        1   0   Jan 09      - 45:57 ora_pmon_year16dr
   -- grid  2819386        1   0   Apr 01      -  5:55 ora_pmon_monthend
  --oracle  7275976        1   0   Dec 24      - 58:21 ora_pmon_t24r14dr
  --  grid  9831792        1   0   Dec 24      - 21:26 ora_pmon_year13
  --oracle  4720296        1   0 02:54:29      -  0:16 ora_pmon_cobr14dr
    grid  5179186  1509260   0 14:38:44  pts/0  0:00 grep pmon
	
	
	    
t24db04@oracle:/home/oracle/bin> 

cd /u01/app/grid/product/11.2.0.4/grid/bin
./crsctl start res -all
./crsctl start has

--stop asm
grid: ./srvctl stop asm -n t24db02 -f 
crs:   crsctl stop crs [-f] 
    Stop OHAS on this server
	
--
 srvctl add database -d mbsmsdr -o /u01/app/oracle/product/11.2.0.4/dbhome_1
 srvctl add instance -d mbsmsdr -i mbsmsdr1 -n dr-ora-db01
 
 
 #!/bin/sh
# file: /home/oracle/bin/bk_script/bk_scfdr
# -----------------------------------------------------------------
# Set enviroment agrument
# -----------------------------------------------------------------

HOSTNAME=dr-ora-db02
export HOSTNAME
ORACLE_UNQNAME=scfdr
export ORACLE_UNQNAME
ORACLE_SID=scfdr1
export ORACLE_SID
ORACLE_SID_DC=scfdb
export ORACLE_SID_DC
POLICY=Backup-OracleFarm
export POLICY
ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export ORACLE_HOME
TARGET_CONNECT_STR=dbsnmp/PAssw0rd@$ORACLE_SID
export TARGET_CONNECT_STR
RUN_AS_USER=oracle
export RUN_AS_USER
RMAN=$ORACLE_HOME/bin/rman
export RMAN
CUSER=`id | cut -d"(" -f2 | cut -d ")" -f1`
export CUSER


RMAN_LOG_FILE=/tmp/rman_"$ORACLE_UNQNAME"_DAILY_$(date '+%Y%m%d_%H%M').log
export RMAN_LOG_FILE
BK_LOG=/tmp/bk_db_"$ORACLE_UNQNAME"_DAILY_$(date '+%Y%m%d_%H%M').log
export BK_LOG
SWITCHLOG=/home/oracle/bin/bk_script/switchlog_"$ORACLE_SID_DC".sh
export SWITCHLOG

# -----------------------------------------------------------------
# switch log DC.
# -----------------------------------------------------------------

if [ "$CUSER" = "root" ]
then
        su - $RUN_AS_USER -c "echo  " > $SWITCHLOG
        su - $RUN_AS_USER -c "echo export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1" >> $SWITCHLOG
        su - $RUN_AS_USER -c "echo $ORACLE_HOME/bin/sqlplus -s srv_db_backup/Window#123#Tech@$ORACLE_SID_DC as sysdba \<\<E
OF " >> $SWITCHLOG
        su - $RUN_AS_USER -c "echo alter system archive log current\;" >> $SWITCHLOG
        su - $RUN_AS_USER -c "echo exit" >> $SWITCHLOG
        su - $RUN_AS_USER -c "echo EOF" >> $SWITCHLOG
        chmod 775 $SWITCHLOG
fi

# -----------------------------------------------------------------
# Initialize the log file.
# -----------------------------------------------------------------

> $RMAN_LOG_FILE
chmod 666 $RMAN_LOG_FILE

# -----------------------------------------------------------------
# Log the start of this script.
# -----------------------------------------------------------------

echo Script $0 >> $RMAN_LOG_FILE
echo ==== started on `date` ==== >> $RMAN_LOG_FILE
echo >> $RMAN_LOG_FILE


# -----------------------------------------------------------------
# Setup Policy
# -----------------------------------------------------------------

if [ "$NB_ORA_FULL" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=0"
    SCHED_NAME="Full-Application-Backup"
        FILES_PER_SET=4
        TAG_TYPE=DATA_lv0
elif [ "$NB_ORA_INCR" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=1"
    SCHED_NAME="Different-Application-Backup"
        FILES_PER_SET=10
        TAG_TYPE=DATA_lv1
elif [ "$NB_ORA_CINC" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=1 CUMULATIVE"
elif [ "$BACKUP_TYPE" = "" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=0"
fi

# -----------------------------------------------------------------
# rman commands for database pub.
# -----------------------------------------------------------------

CMD="
ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export ORACLE_HOME
$RMAN target $TARGET_CONNECT_STR  nocatalog msglog $RMAN_LOG_FILE append <<EOF

# -----------------------------------------------------------------
# RMAN command section
# -----------------------------------------------------------------

RUN {
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 1 TIMES TO 'SBT_TAPE';

ALLOCATE CHANNEL ch01   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch02   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch03   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch04   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch05   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch06   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch07   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;
ALLOCATE CHANNEL ch08   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=$HOSTNAME)' ;

SEND 'NB_ORA_SCHED=$SCHED_NAME,NB_ORA_POLICY=$POLICY,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';

CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
CROSSCHECK BACKUP;
DELETE NOPROMPT EXPIRED BACKUP;
BACKUP AS COMPRESSED BACKUPSET $BACKUP_TYPE FORMAT 'data_%d_%Y%M%D_%U' DATABASE FILESPERSET $FILES_PER_SET TAG $TAG_TYPE;
host \"$SWITCHLOG\";
BACKUP AS COMPRESSED BACKUPSET NOT BACKED UP FORMAT 'arch_%d_%Y%M%D_%U' ARCHIVELOG ALL FILESPERSET 20 TAG ARCH;
BACKUP AS COMPRESSED BACKUPSET FORMAT 'ctl_%d_%Y%M%D_%U' CURRENT CONTROLFILE TAG CTRL;
DELETE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-3';

RELEASE CHANNEL ch01;
RELEASE CHANNEL ch02;
RELEASE CHANNEL ch03;
RELEASE CHANNEL ch04;
RELEASE CHANNEL ch05;
RELEASE CHANNEL ch06;
RELEASE CHANNEL ch07;
RELEASE CHANNEL ch08;

}
EOF
"

if [ "$CUSER" = "root" ]
then

    su - $RUN_AS_USER -c "$CMD" >> $RMAN_LOG_FILE
    RSTAT=$?
else
    sh -c "$CMD" >> $RMAN_LOG_FILE
    RSTAT=$?
fi


if [ "$RSTAT" = "0" ]
then
    LOGMSG="ended successfully"
else
    LOGMSG="ended in error"
fi

# -----------------------------------------------------------------
# Log the completion of this script.
# -----------------------------------------------------------------

echo >> $RMAN_LOG_FILE
echo Script $0 >> $RMAN_LOG_FILE
echo ==== $LOGMSG on `date` ==== >> $RMAN_LOG_FILE
cp $RMAN_LOG_FILE $BK_LOG

exit $RSTAT

-------------------------------------------------------------
--=========compare two schema
-------------------------------------------------------------
http://www.idevelopment.info/data/Oracle/DBA_scripts/Database_Administration/dba_compare_schemas.sql

-------------------------------------------------------------
--get DDL
-------------------------------------------------------------
select DBMS_METADATA.GET_DDL('INDEX','<index_name>') from DUAL;
select DBMS_METADATA.GET_DDL('TABLE','<table_name>') from DUAL;

-------------------------------------------------------------
--buffer busy segment
-------------------------------------------------------------
http://www.dba-oracle.com/art_builder_bbw.htm
 select P1,P2,P3,count(*) from DBA_HIST_ACTIVE_SESS_HISTORY --where WAIT_CLASS='buffer busy waits'
   where
   event = 'buffer busy waits'
   and sample_time>trunc(sysdate)-30
   group by  P1,P2,P3
   order by 4 desc
      
   select    owner,   segment_name,partition_name,   segment_type
   from    dba_extents
where    file_id = 89
and   123198 between block_id and block_id + blocks -1

-------------------------------------------------------------
--check file in ASM
-------------------------------------------------------------
SELECT
    CONCAT( db_files.disk_group_name, SYS_CONNECT_BY_PATH(db_files.alias_name, '/')) full_path
  , db_files.bytes
  , db_files.space
  , NVL(LPAD(db_files.type, 18), '<DIRECTORY>')  type
  , db_files.creation_date
  , db_files.disk_group_name
  , LPAD(db_files.system_created, 4) system_created
FROM
    ( SELECT
          g.name               disk_group_name
        , a.parent_index       pindex
        , a.name               alias_name
        , a.reference_index    rindex
        , a.system_created     system_created
        , f.bytes              bytes
        , f.space              space
        , f.type               type
        , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
      FROM
          v$asm_file f RIGHT OUTER JOIN v$asm_alias     a USING (group_number, file_number)
                                   JOIN v$asm_diskgroup g USING (group_number)
    ) db_files
WHERE db_files.type IS NOT NULL
and disk_group_name='FRAT24R14_DC'
START WITH (MOD(db_files.pindex, POWER(2, 24))) = 0
    CONNECT BY PRIOR db_files.rindex = db_files.pindex
UNION
SELECT
    '+' || volume_files.disk_group_name ||  ' [' || volume_files.volume_name || '] ' ||  volume_files.volume_device full_path
  , volume_files.bytes
  , volume_files.space
  , NVL(LPAD(volume_files.type, 18), '<DIRECTORY>')  type
  , volume_files.creation_date
  , volume_files.disk_group_name
  , null
FROM
    ( SELECT
          g.name               disk_group_name
        , v.volume_name        volume_name
        , v.volume_device       volume_device
        , f.bytes              bytes
        , f.space              space
        , f.type               type
        , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
      FROM
          v$asm_file f RIGHT OUTER JOIN v$asm_volume    v USING (group_number, file_number)
                                   JOIN v$asm_diskgroup g USING (group_number)
    ) volume_files
WHERE volume_files.type IS NOT NULL   


SELECT dg.name AS diskgroup, a.name, f.permissions, f.user_number, u.os_name,
     f.usergroup_number, ug.NAME FROM V$ASM_DISKGROUP dg, V$ASM_USER u, V$ASM_USERGROUP ug, 
     V$ASM_FILE f, V$ASM_ALIAS a WHERE dg.group_number = f.group_number AND 
     dg.group_number = u.group_number AND dg.group_number = ug.group_number AND 
     dg.name = 'FRA' AND f.usergroup_number = ug.usergroup_number AND f.user_number = u.user_number
     AND f.file_number = a.file_number;

-------------------------------------------------------------
--elapsetime_1month
-------------------------------------------------------------
select AA.sql_id,AA.last_active_time,AA.AVG_ELAPSED_TIME,BB.sql_fulltext
from (
select a.sql_id,c.last_active_time,sum(A.ELAPSED_TIME_TOTAL/60000000)/count(A.ELAPSED_TIME_TOTAL) as AVG_ELAPSED_TIME
from DBA_HIST_SQLSTAT a ,DBA_HIST_SNAPSHOT b,v$sqlarea c
where 
a.snap_id=b.snap_id
and a.sql_id=c.sql_id
and elapsed_time_total/60000000>1
and B.BEGIN_INTERVAL_TIME>sysdate-30 
group by a.sql_id,c.last_active_time
)AA,
(select sql_id,sql_fulltext from v$sqlarea)BB
where AA.sql_id=BB.sql_id
order by 3 desc

-------------------------------------------------------------
--drop temp -undo tbs
-------------------------------------------------------------
CREATE TEMPORARY TABLESPACE TEMP_NEW TEMPFILE 
  '+YEAR15_DR' SIZE 1G AUTOEXTEND ON NEXT 512M MAXSIZE UNLIMITED,
  '+YEAR15_DR' SIZE 1G AUTOEXTEND ON NEXT 512M MAXSIZE UNLIMITED
  
  CREATE TEMPORARY TABLESPACE TEMPTBS TEMPFILE 
  '+DATA01' SIZE 1G AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED,
  '+DATA01' SIZE 1G AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED;

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMPTBS;

select 'alter system kill session '''||a.sid||','||a.serial#||''' immediate;'
from  v$session    a, v$sort_usage b,  v$process    c,  v$parameter  d
where  d.name = 'db_block_size'
and  a.saddr = b.session_addr
and   a.paddr = c.addr
and   b.tablespace='TEMP' -- Your TEMP tablespace name here
order by   b.tablespace, b.segfile#, b.segblk#, b.blocks;  
   
--> drop

alter user T24LIVE temporary tablespace TEMPT24LIVE_NEW;

CREATE UNDO TABLESPACE UNDOTBS1_N DATAFILE SIZE 100M;

CREATE UNDO TABLESPACE UNDOTBS1_N DATAFILE 
  '+DATA01' SIZE 1G AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED,
  '+DATA01' SIZE 1G AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED,
  '+DATA01' SIZE 1G AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED;

-- Set the temp undo tablespace as active
ALTER SYSTEM SET UNDO_TABLESPACE='UNDOTBS1_N' SID='*';

-- Check
SELECT a.name,b.status , d.username , d.sid , d.serial#
FROM   v$rollname a,v$rollstat b, v$transaction c , v$session d
WHERE  a.usn = b.usn
AND    a.usn = c.xidusn
AND    c.ses_addr = d.saddr
AND    a.name IN ( 
          SELECT segment_name
          FROM dba_segments 
          WHERE tablespace_name = 'UNDOTBS1'
         ); 

-- Drop the original tablespace
DROP TABLESPACE UNDOTBS1 INCLUDING CONTENTS AND DATAFILES;		


expdp DIRECTORY=DATA_PUMP_DIR schemas=TCB_ODI_MASTER,TCB_ODI_WORK_KRM dumpfile=20181006.dmp logfile=20181006.log
impdp '"/ as sysdba"' directory=dump dumpfile=20181006.dmp logfile=20181006.log table_exists_action=replace
-------------------------------------------------------------
--data pump with database link  - not support long and long raw type
-------------------------------------------------------------
select data_type from DBA_TAB_COLUMNS where owner= and data_type like 'LONG%'

source DB
create user new_scott identified by tiger;
grant connect, resource to new_scott;
grant read, write on directory MY_DMP_DIR to new_scott;
grant create database link to new_scott;

connect new_scott/tiger
create database link OLD_DB connect to scott identified by tiger  using 'olddb.krenger.ch';
target DB
expdp hr DIRECTORY=MY_DMP_DIR NETWORK_LINK=OLD_DB DUMPFILE=network_export.dmp LOGFILE=network_export.log

-------------------------------------------------------------
--change DB_name with NID
-------------------------------------------------------------
http://www.online-database.eu/index.php/backup-a-recovery/58-nid-change-dbname 
Whereras changing the DBID with nid has a non reversable impact on your backup and recovery possibilities, changing only the database DB_NAME has significantly less consequences since,
1. it does not invalidate previously taken backups
2. it does not invalidate previously generated archivelogs
3. it does not require opening the database with the resetlogs option.
 Let us change the database db_name without changing the database dbid, nevertheless you shuld be aware of the impact as well.

SQL> shutdown immediate;
SQL> startup mount;
SQL> exit

nid target=sys/secret_password dbname=COCONUT SETNAME=YES

cd $ORACLE_HOME/dbs
oracle@myhost:/opt/oracle/ORA_HOME/dbs $ cp spfileMYDB.ora spfileCOCONUT.ora
oracle@myhost:/opt/oracle/ORA_HOME/dbs $ cp orapwMYDB orapwCOCONUT
oracle@myhost:/opt/oracle/ORA_HOME/dbs $ export ORACLE_SID=COCONUT

SQL> startup nomount;
SQL> alter system set db_name=coconut scope=spfile;
SQL> alter system set db_unique_name=coconut scope=spfile;
SQL> shutdown immediate;
SQL> startup;
SQL> select name from v$database;

-------------------------------------------------------------
--HEALTHCHECK
-------------------------------------------------------------
--object grow
select * from
(SELECT o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME , o.OBJECT_TYPE ,
    t.NAME "Tablespace Name",to_char(e.BEGIN_INTERVAL_TIME,'YYYY-MM-DD') "DATE" , round(sum(s.growth)/(1024*1024)) "Growth in MB",
    (SELECT sum(bytes)/(1024*1024)
    FROM dba_segments
    WHERE segment_name=o.object_name) "Total Size(MB)"
FROM DBA_OBJECTS o,
    ( SELECT SNAP_ID,TS#,OBJ#,
        SUM(SPACE_USED_DELTA) growth
    FROM DBA_HIST_SEG_STAT
    GROUP BY SNAP_ID,TS#,OBJ#
    HAVING SUM(SPACE_USED_DELTA) > 0
    ORDER BY 2 DESC ) s,
    v$tablespace t, DBA_HIST_SNAPSHOT e
WHERE s.OBJ# = o.OBJECT_ID
AND s.TS#=t.TS#
AND s.SNAP_ID=e.SNAP_ID
and to_char(e.BEGIN_INTERVAL_TIME,'YYYY-MM-DD') > to_char (sysdate-7,'YYYY-MM-DD')
group by o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME , o.OBJECT_TYPE ,
    t.NAME ,to_char(e.BEGIN_INTERVAL_TIME,'YYYY-MM-DD') 
ORDER BY 7 DESC
)
where rownum < 51

--50 biggest object
select * from (
select owner,segment_name,segment_type, sum(bytes/1024/1024/1024) "TOTAL SIZE (GB)"from dba_segments 
group by owner, segment_name,segment_type
order by 4 desc
)
where rownum < 51
;

select * from (
SELECT   owner, table_name, TRUNC(sum(bytes)/1024/1024/1024) GB FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%'
UNION ALL SELECT i.table_name, i.owner, s.bytes FROM dba_indexes i, dba_segments s WHERE s.segment_name = i.index_name  AND   s.owner = i.owner AND   s.segment_type like 'INDEX%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner AND   s.segment_type like 'LOB%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.index_name  AND   s.owner = l.owner --AND   s.segment_type = 'LOBINDEX'
)
GROUP BY owner  ,table_name
having TRUNC(sum(bytes)/1024/1024/1024)>=1
ORDER BY 3 desc
) where rownum <51


select * from (
SELECT   owner, table_name, TRUNC(sum(bytes)/1024/1024/1024) GB FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner AND   s.segment_type like 'LOB%'
)
GROUP BY owner  ,table_name
having TRUNC(sum(bytes)/1024/1024/1024)>=1
ORDER BY 3 desc
) where rownum <51


--awr, alert log
--last_analyzed
select owner,table_name,last_analyzed
from dba_tables
where owner in (select username from dba_users where account_status ='OPEN' and username not like 'SYS%') and last_analyzed > sysdate-1;

--fragment
select owner,table_name,round((blocks*8)/1024,2) "Fragmented size (mb)", 
round((num_rows*avg_row_len/1024/1024),2) "Actual size (mb)", 
round((blocks*8)/1024,2)-round((num_rows*avg_row_len/1024/1024),2)||'mb',
((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 "reclaimable space % " 
from dba_tables where round((blocks*8/1024),2)>0
and  ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10>30
and round((blocks*8)/1024,2)-round((num_rows*avg_row_len/1024/1024),2)>100

--table can redefinition
select a.tab,mb,"Actual / Fragmented size (mb)","reclaimable space % ",c.compression,d.index_type,e.GG  from 
(select owner||'.'||table_name tab,mb from (
SELECT   owner, table_name, TRUNC(sum(bytes)/1024/1024,2) MB FROM (          
          SELECT segment_name table_name, owner, bytes FROM dba_segments WHERE segment_type like 'TABLE%' and owner like 'T24%'
UNION ALL SELECT l.table_name, l.owner, s.bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner AND   s.segment_type like 'LOB%' and s.owner like 'T24%'
)
GROUP BY owner  ,table_name
)) a
left join
(select owner||'.'||table_name tab,round((num_rows*avg_row_len/1024/1024),2) ||'/'||round((blocks*8)/1024,2) "Actual / Fragmented size (mb)", 
((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 "reclaimable space % " 
from dba_tables where round((blocks*8/1024),2)>0
and  ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10>5
and round((blocks*8)/1024,2)-round((num_rows*avg_row_len/1024/1024),2)>1
and owner like 'T24%'
) b on a.tab=b.tab
left join
(select owner||'.'||table_name tab,compression from dba_lobs where owner like 'T24%'  and compression='HIGH')c on a.tab=c.tab
left join
(select distinct owner||'.'||table_name tab,index_type from dba_indexes  where index_type like 'FUNCTION-BASED%'
and owner like 'T24%') d on a.tab=d.tab
left join
(select owner||'.'||table_name tab,count(*) as GG from dba_log_groups where owner like 'T24%'
group by owner||'.'||table_name) e on a.tab=e.tab

http://www.idevelopment.info/data/Oracle/DBA_scripts/LOBs/lob_fragmentation_user.sql
--index global
select owner||'.'|| index_name
from dba_indexes
where partitioned='YES'
and table_name in ( select DISTINCT table_owner||'.'||table_name from dba_tab_partitions where
table_owner not like 'SYS%')

--index unusable
SELECT owner, index_name
FROM dba_indexes
WHERE status = 'UNUSABLE';

SELECT 'alter index '||index_owner||'.'|| index_name||' rebuild partition '|| partition_name ||' online; '
FROM dba_ind_PARTITIONS
WHERE status = 'UNUSABLE';

SELECT index_owner, index_name, partition_name, subpartition_name
FROM dba_ind_SUBPARTITIONS
WHERE status = 'UNUSABLE';


-------------------------------------------------------------
--dbca
-------------------------------------------------------------
-----RAC one node
dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName t24rptdc \
-databaseConfType RACONENODE \
-RACOneNodeServiceName t24rpt \
-sid t24rptdc \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-datafileDestination +T24RPT_DC \
-redoLogFileSize 500 \
-recoveryAreaDestination +T24RPT_DC \
-storageType ASM \
-nodelist dc-core-db-01,dc-core-db-02 \
-diskGroupName T24RPT_DC \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 32768

dbca \
-silent \
-createDatabase \
-RACONENODE \
-RACONENODESERVICENAME mepdr_srv \
-nodelist dr-oradb2-01,dr-oradb2-02 \
-sid mepdr \
-gdbName mepdr \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-storageType ASM \
-datafileDestination DATA01 \
-diskGroupName DATA01 \
-recoveryGroupName FRA \
-redoLogFileSize 200 \
-emConfiguration NONE \
-totalMemory 8192 \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-asmsnmpPassword PAssw0rd \
-dbsnmpPassword PAssw0rd \
-templateName General_Purpose.dbc \
-sampleSchema false


dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName wicl \
-sid wicl2 \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-redoLogFileSize 100 \
-storageType ASM \
-asmSysPassword db#Chivas#123 \
-diskGroupName DWHTEST1 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 800


dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName witrade \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-redoLogFileSize 100 \
-storageType ASM \
-asmSysPassword db#Chivas#123 \
-diskGroupName DATA02 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 800 \
-nodeinfo dc-ora-db01,dc-ora-db02

dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName mobsms \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-redoLogFileSize 100 \
-storageType ASM \
-asmSysPassword db#Chivas#123 \
-diskGroupName DATA02 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 800 \
-nodeinfo dc-ora-db01,dc-ora-db02

TESTFRASSD/
MOUNTED  EXTERN  N         512   4096  1048576   4915200  4913380                0         4913380              0             N  TESTR14SSD/

dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName ebpay \
-sid ebpay \
-SysPassword db#Chivas#123 \
-SystemPassword db#Chivas#123 \
-emConfiguration NONE \
-redoLogFileSize 200 \
-storageType ASM \
-asmSysPassword db#Chivas#123 \
-diskGroupName DATA03 \
-recoveryAreaDestination FRA \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 1024 \
-nodeinfo dc-ora-db01,dc-ora-db02


dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbName mobotp -sid mobotp -SysPassword PAssw0rd -SystemPassword PAssw0rd -emConfiguration NONE -redoLogFileSize 200 -storageType ASM -asmSysPassword PAssw0rd -diskGroupName DATA02 -recoveryAreaDestination FRA -characterSet AL32UTF8 -nationalCharacterSet AL16UTF16 -totalMemory 1024 -nodeinfo dr-oradb-test01,dr-oradb-test02
======new
dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName mbb \
-databaseType OLTP \
-createAsContainerDatabase false \
-databaseConfType RACONENODE \
-RACOneNodeServiceName mbbdr \
-sid mbbdr \
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
-nodelist dr-mbb-db-01,dr-mbb-db-02 \
-diskGroupName DATA01 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 24576 \
-memoryMgmtType CUSTOM_SGA


dbca -silent -deleteDatabase -sourceDB mbbdr -sysDBAUserName sys -sysDBAPassword PAssw0rd

dbca -silent -deleteDatabase -sourceDB mepdr -sysDBAUserName sys -sysDBAPassword db#Chivas#123

dbca -silent \
-recoveryAreaDestination FRA \
-nodelist viscosityoradb1,viscosityoradb2,viscosityoradb3,viscosityoradb4,viscosityoradb5,viscosityoradb6

--12c
### CMNDEV
export ORACLE_SID=cmndev
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
cd $ORACLE_HOME/bin/

dbca \
-silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName cmndev \
-sid cmndev \
-sysPassword PAssw0rd \
-systemPassword PAssw0rd \
-emConfiguration NONE \
-datafileDestination DATA01 \
-redoLogFileSize 100 \
-storageType ASM \
-asmsnmpPassword PAssw0rd \
-diskGroupName DATA01 \
-recoveryGroupName FRA \
-nodelist dr-oradb2-dev \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-sampleSchema false \
-totalMemory 2048


export ORACLE_SID=pdwtest
export ORACLE_HOME=/u01/app/oracle/product/12.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
cd $ORACLE_HOME/bin/

dbca \
-silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName pdwtest \
-sid pdwtest \
-sysPassword PAssw0rd \
-systemPassword PAssw0rd \
-emConfiguration NONE \
-datafileDestination DATA01 \
-redoLogFileSize 100 \
-storageType ASM \
-asmsnmpPassword PAssw0rd \
-diskGroupName DATA01 \
-recoveryGroupName FRA \
-nodelist dr-oradb2-test01,dr-oradb2-test02 \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-sampleSchema false \
-totalMemory 2048

--rac one node
dbca \
-silent \
-createDatabase \
-RACONENODE \
-RACONENODESERVICENAME dgdbtest_srv \
-nodelist dr-oradb2-test01,dr-oradb2-test02 \
-sid dgdbtest \
-gdbName dgdbtest \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-storageType ASM \
-datafileDestination DATA01 \
-diskGroupName DATA01 \
-recoveryGroupName FRA \
-redoLogFileSize 200 \
-emConfiguration NONE \
-totalMemory 4096 \
-SysPassword PAssw0rd \
-SystemPassword PAssw0rd \
-asmsnmpPassword PAssw0rd \
-templateName General_Purpose.dbc \
-sampleSchema false

--convert RAC to RAC one node
srvctl config database -d ecmdb
srvctl stop instance -d ecmdb -i ecmdb2
srvctl remove instance -d ecmdb -i ecmdb2
srvctl config database -d ecmdb
srvctl add service -d ecmdb -s ecmdb_service -r ecmdb1
srvctl convert database -d ecmdb -c RACONENODE -i ecmdb1
srvctl modify database -d ecmdb -i ecmdb
srvctl config database -d ecmdb -v
srvctl status database -d ecmdb -v

srvctl add service -d mepdr -s mepdr_srv -r mepdr_1
srvctl convert database -d mepdr -c RACONENODE 

srvctl relocate database -d t24rptdr -n dr-core-db-02
srvctl relocate database -d ecmdb -n dc-tcbs-db-01

--transport between platform os
select * from v$transportable_platform;

----------------------------------------
quy trinh sửa lỗi T24 test

1.Patch 
Patch 21307096: USE THE HIGHEST CHECKPOINT_CHANGE# WHEN _ALLOW_RESETLOGS_CORRUPTION=TRUE
Config cluster =no
Config undo_management=MANUAL
Bỏ undo tablespace trong init


2.Copy tablespace System ra OS và Check các segment bị lỗi
asmcmd> cp SYSTEM.357.904579331 /u01/app/backup/SYSTEM.357.904579331

[oracle@t24-db01-test testr142]$ ls -ltr
total 2972512
-rw-r----- 1 grid oinstall 3040878592 Oct 12 14:17 SYSTEM.357.904579331
[oracle@t24-db01-test testr142]$ strings SYSTEM.357.904579331 | grep _SYSSMU | cut -d $ -f 1 | sort -u
        <9    ' and substr(drs.segment_name,1,7) != ''_SYSSMU''');
 and substr(drs.segment_name,1,7) != '_SYSSMU'
 and substr(drs.segment_name,1,7) != '_SYSSMU' 
        c;    ' and substr(drs.segment_name,1,7) != ''_SYSSMU'' ' ||
ORA-01555: snapshot too old: rollback segment number 5 with name "_SYSSMU5_1738828719
_SYSSMU100_3514823131
_SYSSMU10_1197734989
_SYSSMU101_2260291618
_SYSSMU102_1758931210
_SYSSMU103_3699875130
_SYSSMU10_3470984480
_SYSSMU104_3727663289
_SYSSMU105_2757753999
_SYSSMU106_3227467510
_SYSSMU107_1944874478
_SYSSMU107_194487447l
_SYSSMU108_3479901356
_SYSSMU109_346108948
_SYSSMU110_2014196944
_SYSSMU11_1089530429
_SYSSMU111_2026072926
_SYSSMU112_909497051
_SYSSMU113_1098799456
_SYSSMU114_2092186900
_SYSSMU115_2857620402
_SYSSMU116_2192368477
_SYSSMU117_1493632323
_SYSSMU118_1482937893
_SYSSMU11_894599432
_SYSSMU119_1748773653
_SYSSMU120_2035622435
_SYSSMU12_1573055333
_SYSSMU121_992900216
_SYSSMU122_1334740986
_SYSSMU123_3331168671
_SYSSMU124_3626216787
_SYSSMU125_4019397929
_SYSSMU1_2603659607
_SYSSMU126_3424727747
_SYSSMU12_637045716
_SYSSMU127_1252933216
_SYSSMU128_3936730853
_SYSSMU129_234119103
_SYSSMU130_2735090194
_SYSSMU13_1975704605
_SYSSMU131_990281877
_SYSSMU132_1929307064
_SYSSMU133_2388870097
_SYSSMU13_3860906822
_SYSSMU134_3485819387
_SYSSMU135_4019926870
_SYSSMU136_3795808806
_SYSSMU1_3724004606
_SYSSMU137_513044615
_SYSSMU138_3845119117
_SYSSMU139_3405942937
_SYSSMU140_2373395818
_SYSSMU141_4292931474
_SYSSMU142_3127927963
_SYSSMU143_2563939422
_SYSSMU14_3319140121
_SYSSMU144_2072309914
_SYSSMU14_446497159
_SYSSMU145_3174389174
_SYSSMU146_3741590996
_SYSSMU147_568479672
_SYSSMU148_639888712
_SYSSMU149_998307660
_SYSSMU150_3906751752
_SYSSMU151_2941377302
_SYSSMU15_1436577151
_SYSSMU152_1353833594
_SYSSMU153_2411964668
_SYSSMU15_3843222649
_SYSSMU154_3075851184
_SYSSMU155_26212,
_SYSSMU155_2621234498
_SYSSMU156_905862629
_SYSSMU157_238335010
_SYSSMU158_571180754
_SYSSMU159_645488100
_SYSSMU160_477271325
_SYSSMU16_1363878450
_SYSSMU16_1689093467
_SYSSMU161_864106394
_SYSSMU162_837207842
_SYSSMU163_3071193426
_SYSSMU164_1950449603
_SYSSMU17_1049158485
_SYSSMU17_3057184926
_SYSSMU18_1557221903
_SYSSMU18_1759769914
_SYSSMU19_2210786688
_SYSSMU19_2284825117
_SYSSMU20_2312497597
_SYSSMU20_759735227
_SYSSMU21_3574632886
_SYSSMU22_2271854303
_SYSSMU2_2996391332
_SYSSMU23_2087468879
_SYSSMU24_1024379502
_SYSSMU25_3402425122
_SYSSMU26_2086602379
_SYSSMU27_2936932369
_SYSSMU2_73114111
_SYSSMU28_2570639193
_SYSSMU29_569147834
_SYSSMU30_118280200
_SYSSMU31_3074316451
_SYSSMU3_1723003836
_SYSSMU32_718129618
_SYSSMU33_1655053472
_SYSSMU34_1356345290
_SYSSMU35_1558775129
_SYSSMU3_596277271
_SYSSMU36_3361872336
_SYSSMU37_2695825272
_SYSSMU38_1311218347
_SYSSMU39_3957524808
_SYSSMU40_1399755709
_SYSSMU4_1254879796
_SYSSMU41_614759313
_SYSSMU42_1942034377
_SYSSMU4_2523322691
_SYSSMU43_1118833714
_SYSSMU44_2877454161
_SYSSMU45_2644067016
_SYSSMU46_2893549427
_SYSSMU47_2429996228
_SYSSMU48_2016104805
_SYSSMU49_3835028037
_SYSSMU50_3401893900
_SYSSMU51_4046334462
_SYSSMU52_4120931521
_SYSSMU53_2757046176
_SYSSMU5_4008018903
_SYSSMU54_1643202656
_SYSSMU55_3502159409
_SYSSMU56_521634970
_SYSSMU57_4024605259
_SYSSMU58_1732930864
_SYSSMU5_898567397
_SYSSMU59_2237610824
_SYSSMU60_853938181
_SYSSMU6_1263032392
_SYSSMU61_2965707031
_SYSSMU62_257668906
_SYSSMU63_3498739000
_SYSSMU6_4235600416
_SYSSMU64_523161762
_SYSSMU65_4174512756
_SYSSMU66_4196222828
_SYSSMU67_3945767072
_SYSSMU68_90501951
_SYSSMU69_630047313
_SYSSMU70_1821880367
_SYSSMU71_2654561858
_SYSSMU7_2070203016
_SYSSMU7_2271882308
_SYSSMU72_472721342
_SYSSMU73_4190169038
_SYSSMU74_3935850895
_SYSSMU74_3935850895,
_SYSSMU75_1775993304
_SYSSMU76_1781224803
_SYSSMU77_3909087050
_SYSSMU78_121780916
_SYSSMU79_1036774905
_SYSSMU7l
_SYSSMU80_1577273988
_SYSSMU81_4167798266
_SYSSMU82_1643283876
_SYSSMU83_1057037092
_SYSSMU84_113446633
_SYSSMU8_517538920
_SYSSMU85_3587351830
_SYSSMU86_4111222246
_SYSSMU87_1160396824
_SYSSMU88_2843238995
_SYSSMU8_854328387
_SYSSMU89_1264833271
_SYSSMU90_1285425443
_SYSSMU91_4040611579
_SYSSMU9_1650507775
_SYSSMU92_1730653222
_SYSSMU93_4100486948
_SYSSMU94_2160849411
_SYSSMU9_508477954
_SYSSMU95_2235152366
_SYSSMU96_152572452
_SYSSMU97_1397952394
_SYSSMU98_587109466
_SYSSMU99_818616202



3. Start db - file event
scn_causing_errors -> scn làm lỗi db

SQL> startup mount
SQL> undefine scn_causing_errors
select decode(ceil((&&scn_causing_errors - min(CHECKPOINT_CHANGE#))/1000000),0,'Event 21307096 is not needed'
, 'event="21307096 trace name context forever, level '
||ceil((&&scn_causing_errors - min(CHECKPOINT_CHANGE#))/1000000)
||'"') "EVENT TO SET in init.ora:"
from v$datafile_header
where status != 'OFFLINE';

Key: 0-63920-06753-29060-08749
Site: oravn.com

4. Modify init file
[oracle@t24-db01-test tmp]$ more r14.ora
testr1422.__db_cache_size=1090519040
event="21307096 trace name context forever, level 1"
testr1421.__db_cache_size=1023410176
testr1422.__java_pool_size=67108864
testr1421.__java_pool_size=67108864
testr1422.__large_pool_size=234881024
testr1421.__large_pool_size=234881024
testr1422.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
testr1421.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
testr1422.__pga_aggregate_target=1073741824
testr1421.__pga_aggregate_target=1073741824
testr1422.__sga_target=4294967296
testr1421.__sga_target=4294967296
testr1422.__shared_io_pool_size=0
testr1421.__shared_io_pool_size=0
testr1422.__shared_pool_size=721420288
testr1421.__shared_pool_size=788529152
testr1422.__streams_pool_size=0
testr1421.__streams_pool_size=0
*._allow_resetlogs_corruption=TRUE
*.audit_file_dest='/u01/app/oracle/admin/testr142/adump'
*.audit_trail='db'
*.cluster_database=false
job_queue_processes=0
*.compatible='11.2.0.4.0'
*.control_files='+T24CLIMS/testr142/controlfile/current.444.904579461'
*.cursor_sharing='EXACT'
*.db_block_checksum='FULL'
*.db_block_size=8192
*.db_create_file_dest='+T24CLIMS'
*.db_domain=''
*.db_flashback_retention_target=2880
*.db_keep_cache_size=2147483648
*.db_lost_write_protect='NONE'
*.db_name='testr142'
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=testr142XDB)'
*.fast_start_mttr_target=1800
*.filesystemio_options='SETALL'
testr1422.instance_number=2
testr1421.instance_number=1
*.open_cursors=5000
*.open_links=10
*.optimizer_index_caching=50
*.optimizer_index_cost_adj=1
*.pga_aggregate_target=1073741824
*.processes=500
*.query_rewrite_integrity='TRUSTED'
*.recyclebin='OFF'
*.remote_listener='t24-test-scan:1521'
*.remote_login_passwordfile='exclusive'
*.session_cached_cursors=1000
*.session_max_open_files=500
*.sga_max_size=4294967296
*.sga_target=4294967296
*.standby_file_management='AUTO'
testr1422.thread=2
testr1421.thread=1
*.undo_management='MANUAL'
_CORRUPTED_ROLLBACK_SEGMENTS =(_SYSSMU5_1738828719$,_SYSSMU100_3514823131$,_SYSSMU10_1197734989$,_SYSSMU101_2260291618$,_SYSSMU102_1758931210$,_SYSSMU103_36
99875130$,_SYSSMU10_3470984480$,_SYSSMU104_3727663289$,_SYSSMU105_2757753999$,_SYSSMU106_3227467510$,_SYSSMU107_1944874478$,_SYSSMU107_194487447l$,_SYSSMU10
8_3479901356$,_SYSSMU109_346108948$,_SYSSMU110_2014196944$,_SYSSMU11_1089530429$,_SYSSMU111_2026072926$,_SYSSMU112_909497051$,_SYSSMU113_1098799456$,_SYSSMU
114_2092186900$,_SYSSMU115_2857620402$,_SYSSMU116_2192368477$,_SYSSMU117_1493632323$,_SYSSMU118_1482937893$,_SYSSMU11_894599432$,_SYSSMU119_1748773653$,_SYS
SMU120_2035622435$,_SYSSMU12_1573055333$,_SYSSMU121_992900216$,_SYSSMU122_1334740986$,_SYSSMU123_3331168671$,_SYSSMU124_3626216787$,_SYSSMU125_4019397929$,_
SYSSMU1_2603659607$,_SYSSMU126_3424727747$,_SYSSMU12_637045716$,_SYSSMU127_1252933216$,_SYSSMU128_3936730853$,_SYSSMU129_234119103$,_SYSSMU130_2735090194$,_
SYSSMU13_1975704605$,_SYSSMU131_990281877$,_SYSSMU132_1929307064$,_SYSSMU133_2388870097$,_SYSSMU13_3860906822$,_SYSSMU134_3485819387$,_SYSSMU135_4019926870$
,_SYSSMU136_3795808806$,_SYSSMU1_3724004606$,_SYSSMU137_513044615$,_SYSSMU138_3845119117$,_SYSSMU139_3405942937$,_SYSSMU140_2373395818$,_SYSSMU141_429293147
4$,_SYSSMU142_3127927963$,_SYSSMU143_2563939422$,_SYSSMU14_3319140121$,_SYSSMU144_2072309914$,_SYSSMU14_446497159$,_SYSSMU145_3174389174$,_SYSSMU146_3741590
996$,_SYSSMU147_568479672$,_SYSSMU148_639888712$,_SYSSMU149_998307660$,_SYSSMU150_3906751752$,_SYSSMU151_2941377302$,_SYSSMU15_1436577151$,_SYSSMU152_135383
3594$,_SYSSMU153_2411964668$,_SYSSMU15_3843222649$,_SYSSMU154_3075851184$,_SYSSMU155_26212,$,_SYSSMU155_2621234498$,_SYSSMU156_905862629$,_SYSSMU157_2383350
10$,_SYSSMU158_571180754$,_SYSSMU159_645488100$,_SYSSMU160_477271325$,_SYSSMU16_1363878450$,_SYSSMU16_1689093467$,_SYSSMU161_864106394$,_SYSSMU162_837207842
$,_SYSSMU163_3071193426$,_SYSSMU164_1950449603$,_SYSSMU17_1049158485$,_SYSSMU17_3057184926$,_SYSSMU18_1557221903$,_SYSSMU18_1759769914$,_SYSSMU19_2210786688
$,_SYSSMU19_2284825117$,_SYSSMU20_2312497597$,_SYSSMU20_759735227$,_SYSSMU21_3574632886$,_SYSSMU22_2271854303$,_SYSSMU2_2996391332$,_SYSSMU23_2087468879$,_S
YSSMU24_1024379502$,_SYSSMU25_3402425122$,_SYSSMU26_2086602379$,_SYSSMU27_2936932369$,_SYSSMU2_73114111$,_SYSSMU28_2570639193$,_SYSSMU29_569147834$,_SYSSMU3
0_118280200$,_SYSSMU31_3074316451$,_SYSSMU3_1723003836$,_SYSSMU32_718129618$,_SYSSMU33_1655053472$,_SYSSMU34_1356345290$,_SYSSMU35_1558775129$,_SYSSMU3_5962
77271$,_SYSSMU36_3361872336$,_SYSSMU37_2695825272$,_SYSSMU38_1311218347$,_SYSSMU39_3957524808$,_SYSSMU40_1399755709$,_SYSSMU4_1254879796$,_SYSSMU41_61475931
3$,_SYSSMU42_1942034377$,_SYSSMU4_2523322691$,_SYSSMU43_1118833714$,_SYSSMU44_2877454161$,_SYSSMU45_2644067016$,_SYSSMU46_2893549427$,_SYSSMU47_2429996228$,
_SYSSMU48_2016104805$,_SYSSMU49_3835028037$,_SYSSMU50_3401893900$,_SYSSMU51_4046334462$,_SYSSMU52_4120931521$,_SYSSMU53_2757046176$,_SYSSMU5_4008018903$,_SY
SSMU54_1643202656$,_SYSSMU55_3502159409$,_SYSSMU56_521634970$,_SYSSMU57_4024605259$,_SYSSMU58_1732930864$,_SYSSMU5_898567397$,_SYSSMU59_2237610824$,_SYSSMU6
0_853938181$,_SYSSMU6_1263032392$,_SYSSMU61_2965707031$,_SYSSMU62_257668906$,_SYSSMU63_3498739000$,_SYSSMU6_4235600416$,_SYSSMU64_523161762$,_SYSSMU65_41745
12756$,_SYSSMU66_4196222828$,_SYSSMU67_3945767072$,_SYSSMU68_90501951$,_SYSSMU69_630047313$,_SYSSMU70_1821880367$,_SYSSMU71_2654561858$,_SYSSMU7_2070203016$
,_SYSSMU7_2271882308$,_SYSSMU72_472721342$,_SYSSMU73_4190169038$,_SYSSMU74_3935850895$,_SYSSMU74_3935850895,$,_SYSSMU75_1775993304$,_SYSSMU76_1781224803$,_S
YSSMU77_3909087050$,_SYSSMU78_121780916$,_SYSSMU79_1036774905$,_SYSSMU7l$,_SYSSMU80_1577273988$,_SYSSMU81_4167798266$,_SYSSMU82_1643283876$,_SYSSMU83_105703
7092$,_SYSSMU84_113446633$,_SYSSMU8_517538920$,_SYSSMU85_3587351830$,_SYSSMU86_4111222246$,_SYSSMU87_1160396824$,_SYSSMU88_2843238995$,_SYSSMU8_854328387$,_
SYSSMU89_1264833271$,_SYSSMU90_1285425443$,_SYSSMU91_4040611579$,_SYSSMU9_1650507775$,_SYSSMU92_1730653222$,_SYSSMU93_4100486948$,_SYSSMU94_2160849411$,_SYS
SMU9_508477954$,_SYSSMU95_2235152366$,_SYSSMU96_152572452$,_SYSSMU97_1397952394$,_SYSSMU98_587109466$,_SYSSMU99_818616202$)



5. Startup
Copy dữ liệu sang db khác

-----refresh  index function 

alter user t24live grant connect through thuyntm_dba;
login thuyntm_dba[t24live]

set line 200;
set timing on;
exec DBMS_MVIEW.REFRESH ('mv_user_indexes'); 
DECLARE
   CURSOR c IS SELECT column_expression, index_name FROM user_ind_expressions;
   rc   c%ROWTYPE;
BEGIN
   OPEN c;
   DELETE FROM mv_user_ind_expressions;
   LOOP
      FETCH c INTO rc;
      EXIT WHEN c%NOTFOUND;
      INSERT INTO mv_user_ind_expressions (column_expression, index_name)
           VALUES (rc.column_expression, rc.index_name);
   END LOOP;
   COMMIT;
END;
/




-----------deconfigure and remove all traces of an 11.2.0.2 (or later) Grid Infrastructure Oracle Home  (Doc ID 1413787.1)
This will allow successful reinstallation of the same software into the existing Grid Home and oraInventory.
These steps include deletion of the central Inventory and removal of temp files created when oracle is running.

SOLUTION
To deconfigure CRS (across all nodes of the cluster)
As root, execute
/u01/grid/crs/install/rootcrs.pl -deconfig -verbose -force
On the last node of the Grid cluster you should add the –lastnode parameter to the rootcrs.pl command.
/u01/grid/crs/install/rootcrs.pl -deconfig -lastnode -force

To Deconfigure Oracle Restart (SIHA and ASM): As root, execute:-
/u01/grid/crs/install/roothas.pl -deconfig -verbose -force
If deconfiguration fails against either CRS or Oracle Restart, please disable GI, reboot the node and try the same command: As root, execute:-
crsctl disable has

As root, reboot the node; once the node comes backup, execute above deconfigure command again.
- Modify /etc/inittab: (CRS and Oracle Restart)
If the Oracle Grid root.sh script has been run on any of the nodes previously, then the Linux inittab file should be modified to remove the lines that were added.
Deconfig should remove this line but it is best to verify.
tail /etc/inittab
#h1:35:respawn:/etc/init.d/init.ohasd run >/dev/null 2>&1 </dev/null
init q
Clean up files
- The following commands are used to remove all Oracle Grid and database software. You can also use the Oracle de-installer to remove the necessary software components.
#
#WARNING - You should verify this script before running this script as this script will remove everything for all Oracle systems on the Linux system where the script is run.
rm -f /etc/init.d/init.ohasd
rm -f /etc/inittab.crs
rm -rf /etc/oracle
rm -f /usr/tmp/.oracle/*      
rm -f /tmp/.oracle/*
rm -f /var/tmp/.oracle/*
#WARNING: BE VERY CAREFUL - THIS WILL REMOVE THE ORATAB ENTRIES FOR ALL DATABASES RUNNING ON THIS SERVER AND ALSO THE CENTRAL INVENTORY FOR ANY ORACLE HOMES/GRID HOMES WHICH ARE CURRENTLY INSTALLED ON THIS SERVER.
rm -f /etc/oratab
rm -rf /var/opt/oracle

# Remove Oracle software directories *these may change based on your install en
# You need to modify the following to map to your install environment.
rm -rf </u01/base/*> *********this is $ORACLE_BASE
rm -rf </u01/oraInventory> ****this is the central inventory loc pointed to by oraInst.loc
rm -rf </u01/grid/*> **********this is the Grid Home
rm -rf </u01/oracle> **********this is the DB Home#

NOTES:
1) If you wish to reinstall into the same Grid directories, you should ensure the permissions and ownership of the directories are correct.
Usually for Grid Infrastructure the directory ownership will have been changed to root and a subsequent reinstall into the existing directory will fail.
#chmod 755 /u01/grid
#chown oracle:oinstall /u01/grid (use owner:group of Grid Infrastructure OH installation)
2) The rootcrs.pl deconfig removes the cvuqdisk-1.0.9-1.rpm - you will need to reinstall it as root from your <staging area>/clusterware
/Disk1/rpm directory:
# rpm -ivh cvuqdisk-1.0.9-1.rpm
3) You must also zero out the headers for the ocr/voting disks prior to re-installing e.g.
dd if=/dev/zero of=/dev/<device name> bs=1M count=100
