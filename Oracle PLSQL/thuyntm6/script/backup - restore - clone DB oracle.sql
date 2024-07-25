09:58:23 T24LIVE@t24test31 > BEGIN convert_blob_file('F_DE_O_MSG',4,1000); END;

*
ERROR at line 1:
ORA-01403: no data found
ORA-06512: at "T24LIVE.CONVERT_BLOB_FILE", line 34
ORA-06512: at line 1


Elapsed: 01:59:02.99
11:57:26 T24LIVE@t24test31 > 


#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
datetime=`date +%Y%m%d`
ORA_LOG=/home/oracle/R14SCRIPT/MONTHEND/log/rman_cobr14dr_${datetime}.log
ORA_LOG_T24=/home/oracle/R14SCRIPT/MONTHEND/log/rman_t24r14dr_${datetime}.log
GRID_LOG=/home/grid/R14SCRIPT/MONTHEND/log/rman_cobr14dr_${datetime}.log
DROP_SCRIPT=/home/grid/R14SCRIPT/MONTHEND/log/drop_log_file_cobr14dr_${datetime}.sql
CLEAR_SCRIPT=/home/grid/R14SCRIPT/MONTHEND/log/clear_log_file_${datetime}.sql
echo > $ORA_LOG
rman target DBSNMP/PAssw0rd@t24r14dr1 AUXILIARY DBSNMP/PAssw0rd@cobr14dr1 log /home/oracle/rman_clone_cobr14dr.log append <<EOF

CREATE OR REPLACE procedure SYS.DBA_DROP_PARTITION_YEARLY as
   v_date        DATE;
   v_highvalue   VARCHAR2 (128);
   cmd           VARCHAR2 (128);
   dem           NUMBER;

   CURSOR c_partitions
   IS
        SELECT table_name, partition_name, HIGH_VALUE
          FROM all_tab_partitions
         WHERE     table_name IN ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS','FBNK_STMT_ENTRY', 'FBNK_RE_C017','FBNK_CATEG_ENTRY')
               AND table_name NOT IN (select distinct table_name from dba_indexes
                                        where table_name in ('FBNK_FUNDS_TRANSFER#HIS','FBNK_TELLER#HIS','FBNK_STMT_ENTRY', 'FBNK_RE_C017','FBNK_CATEG_ENTRY')
                                        and partitioned='NO'   )
               AND table_owner = 'T24LIVE'
               AND partition_name NOT LIKE '%MAX%'
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_partitions
   LOOP
      IF cc.table_name IN ('FBNK_FUNDS_TRANSFER#HIS', 'FBNK_TELLER#HIS')
      THEN
         v_highvalue := TO_NUMBER (SUBSTR (cc.HIGH_VALUE, 4, 5));

         --DBMS_OUTPUT.put_line (v_highvalue);
         IF TO_NUMBER (TO_CHAR (SYSDATE, 'MM'))  <= 6
         THEN
            IF v_highvalue <
                  (TO_NUMBER (TO_CHAR (SYSDATE, 'YY')) - 1) * 1000 + 184
            THEN
               cmd :=  'alter table T24LIVE.' || cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
               EXECUTE IMMEDIATE cmd;
            END IF;
         ELSE
            IF v_highvalue < TO_NUMBER (TO_CHAR (SYSDATE, 'YY')) * 1000
            THEN
               cmd :='alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
              EXECUTE IMMEDIATE cmd;
            END IF;
         END IF;
      ELSE
         v_highvalue := TO_NUMBER (SUBSTR (cc.HIGH_VALUE, 2, 5));

         IF TO_NUMBER (TO_CHAR (SYSDATE, 'MM'))  <= 6
         THEN
            IF v_highvalue <= TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'dd/mm/yyyy') - 184
            THEN
               cmd :='alter table T24LIVE.' || cc.table_name || ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
              EXECUTE IMMEDIATE cmd;
            END IF;
         ELSE
            IF v_highvalue <=TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'dd/mm/yyyy')
            THEN
               cmd := 'alter table T24LIVE.'|| cc.table_name|| ' drop partition '|| cc.partition_name;
               DBMS_OUTPUT.put_line (cmd);
              EXECUTE IMMEDIATE cmd;
            END IF;
         END IF;
      END IF;
   END LOOP;
END;
/


DELETE FORCE NOPROMPT archivelog all completed before "to_date('11/05/2019 23:00','dd/mm/yyyy hh24:mi')";


CREATE OR REPLACE PROCEDURE T24LIVE.clone_POS_MVMT_LWORK_DAY IS
iExistTBL int;
/******************************************************************************
   NAME:       clone_POS_MVMT_LWORK_DAY
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        3/10/2012   hoannt       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     clone_POS_MVMT_LWORK_DAY
      Sysdate:         3/10/2012
      Date and Time:   3/10/2012, 12:42:23 PM, and 3/10/2012 12:42:23 PM
      Username:        hoannt (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
  select count(1) into iExistTBL from user_tables where upper(table_name) = 'FBNK_POS_MVMT_LWORK_DAY_CLONE';
   if iExistTBL > 0 then
       execute immediate 'drop table FBNK_POS_MVMT_LWORK_DAY_CLONE';
   end if;

   execute immediate 'create table FBNK_POS_MVMT_LWORK_DAY_CLONE XMLTYPE XMLRECORD store as CLOB  as select /*+ parallel(FBNK_POS_MVMT_LWORK_DAY, 8) */ * from FBNK_POS_MVMT_LWORK_DAY';
   
   execute immediate 'CREATE SYNONYM  T24_LIVE_DWH.FBNK_POS_MVMT_LWORK_DAY_CLONE  for T24LIVE.FBNK_POS_MVMT_LWORK_DAY_CLONE';
   --execute immediate 'purge recyclebin';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END clone_POS_MVMT_LWORK_DAY;
/



channel t1: restoring control file
released channel: t1
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of restore command at 10/16/2018 14:47:36
ORA-19870: error while restoring backup piece /ctrl_dYEAR14_u11t0lluv_s33_p1_t973789151
ORA-19507: failed to retrieve sequential file, handle="/ctrl_dYEAR14_u11t0lluv_s33_p1_t973789151", parms=""
ORA-27029: skgfrtrv: sbtrestore returned error
ORA-19511: Error received from media manager layer, error text:
   Failed to open backup file for restore.

expdp schemas=HOSTTCBS, BDSTCBS, CASDB compression=all dumpfile=Flex_20180418.dmp logfile=Flex_20180418.log  directory=DUMPDIR

export ORACLE_HOME=/u01/app/database/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export =/datat24/T24DR/year12/backup_year12.log
export ORACLE_SID=year12dr

echo `date +%d/%m/%y:%T` >>$LOG_FILE

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown immediate;
spool off
exit
EOF

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
startup mount;
spool off
exit
EOF

rman target / <<EOF > $LOG_FILE
CONFIGURE DEVICE TYPE DISK PARALLELISM 12 BACKUP TYPE TO BACKUPSET;
backup as backupset database format '/datat24/T24DR/year12/YEAR12_%u' filesperset 6;
backup current controlfile format '/datat24/T24DR/year12/YEAR12_control_%u';
exit;
EOF

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
alter database open;
spool off
exit
EOF

echo 'Done: '`date +%d/%m/%y:%T` >>$LOG_FILE


export ORACLE_SID=year13
rman target / <<EOF > /datat24/T24DR/year12/backup_year13.log
CONFIGURE DEVICE TYPE DISK PARALLELISM 12 BACKUP TYPE TO BACKUPSET;
backup as compressed backupset database format '/datat24/T24DR/year13/YEAR13_%u' filesperset 6;
backup current controlfile format '/datat24/T24DR/year13/YEAR13_control_%u';
exit;
EOF


select recid from T24LIVE.FBNK_CATEG_ENTRY partition (CATEG_ENTRY_PMAX)
where recid not like '18%'

DUMMY.ID1457
DUMMY.ID41758
DUMMY.ID71079
DUMMY.ID91676

RE_CONSOL_SPEC_ENT_PMAX_TMP9

-- in case need linking library
sh /usr/openv/netbackup/bin/oracle_link
 chmod 777 /usr/openv/netbackup/logs/user_ops/dbext/logs
--============
http://surachartopun.com/2012/01/create-2nd-standby-database-from-1st.html

--============check capacity before restore
select name,free_mb/1024, total_mb/1024 from v$asm_diskgroup;

--============check rman progress
select  sid, to_char( start_time,'dd/mm/yyyy hh24'),  totalwork  sofar,  (sofar/totalwork) * 100 pct_done
from    v$session_longops
where    totalwork > sofar
AND    opname NOT LIKE '%aggregate%'
AND    opname like 'RMAN%';


SELECT *
  FROM V$RMAN_STATUS
 WHERE     TRUNC (end_time) = TRUNC (SYSDATE - 1)
       AND operation = 'BACKUP'
       AND status <> 'COMPLETED';

================================================================script backup cobr24dr
export ORACLE_SID=cobr14dr  
export ORACLE_HOME=/u01/app/database/product/11.2.0.4/dbhome_1

BACKUP_DIR=/backupdata/backup_$(date '+%Y%m%d')
LOG_FILE=$BACKUP_DIR/rman_$ORACLE_SID_$(date '+%Y%m%d_%H%M').log

find /backupdata/* -type d -mtime +5 -name "backup_*" -exec rm -rf {} \;
mkdir $BACKUP_DIR

$ORACLE_HOME/bin/rman target srv_db_backup/Window#123#Tech@$ORACLE_SID nocatalog msglog $RMAN_LOG_FILE append <<EOF
RUN {
CONFIGURE CONTROLFILE AUTOBACKUP ON;

ALLOCATE CHANNEL ch1   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch2   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch3   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch4   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch5   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch6   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch7   DEVICE TYPE DISK; 
ALLOCATE CHANNEL ch8   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch9   DEVICE TYPE DISK;
ALLOCATE CHANNEL ch10  DEVICE TYPE DISK;

CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
backup as compressed backupset database FORMAT '$BACKUP_DIR/bk_cobr14dr_%Y%M%D_%U' tag data_lv0;
BACKUP AS COMPRESSED BACKUPSET NOT BACKED UP FORMAT '$BACKUP_DIR/arc_cobr14dr_%Y%M%D_%U' ARCHIVELOG ALL FILESPERSET 20 TAG ARCH;
BACKUP AS COMPRESSED BACKUPSET FORMAT '$BACKUP_DIR/ctl_cobr14dr_%Y%M%D_%U' CURRENT CONTROLFILE TAG CTRL;

RELEASE CHANNEL ch1;
RELEASE CHANNEL ch2;
RELEASE CHANNEL ch3;
RELEASE CHANNEL ch4;
RELEASE CHANNEL ch5;
RELEASE CHANNEL ch6;
RELEASE CHANNEL ch7;
RELEASE CHANNEL ch8;
RELEASE CHANNEL ch9;
RELEASE CHANNEL ch10;
}
EOF

*/
================================================================


--------
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
backup as compressed backupset database FORMAT '/backupdata/backup/bk_cobr14dr_%Y%M%D_%U' tag data_lv0;
BACKUP AS COMPRESSED BACKUPSET NOT BACKED UP FORMAT '/backupdata/backup/arc_cobr14dr_%Y%M%D_%U' ARCHIVELOG ALL FILESPERSET 20 TAG ARCH;
BACKUP AS COMPRESSED BACKUPSET FORMAT '/backupdata/backup/ctl_cobr14dr_%Y%M%D_%U' CURRENT CONTROLFILE TAG CTRL;
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
release channel ch11;
release channel ch12;
release channel ch13;
release channel ch14;
release channel ch21;
release channel ch22;
}

===============backup 
nohup sh /home/oracle/DBSCRIPT/cobclone/cobclone.sh >> /home/oracle/DBSCRIPT/cobclone/cobclone.out 2>&1 &


#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=testcob

rman target / log /testcob/backup_testcob/rman_testcob_${datetime}.log append <<EOF
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
allocate channel ch11 device type disk;
allocate channel ch12 device type disk;
allocate channel ch13 device type disk;
allocate channel ch14 device type disk;
backup as compressed backupset database FORMAT '/testcob/backup_testcob/testcob_%U' tag data_lv0;
BACKUP AS COMPRESSED BACKUPSET NOT BACKED UP FORMAT '/testcob/backup_testcob/testcob_arch_%d_%Y%M%D_%U' ARCHIVELOG ALL FILESPERSET 20 TAG ARCH;
BACKUP AS COMPRESSED BACKUPSET FORMAT '/testcob/backup_testcob/ctl_%d_%Y%M%D_%U' CURRENT CONTROLFILE TAG CTRL;
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
release channel ch11;
release channel ch12;
release channel ch13;
release channel ch14;
}
EXIT;
EOF

============list backup 
--esb
/usr/openv/netbackup/bin/bplist  -C dr-esb-db01-pub -t 4 -S dr-backup-01 -s 11/20/2017 00:00:00 -e 11/21/2017 00:00:00 -l -b -R /
/usr/openv/netbackup/bin/bplist  -C dr-esb-db02-pub -t 4 -S dr-backup-01 -s 03/11/2017 00:00:00 -e 03/12/2017 00:00:00 -l -b -R /

--tcbs
/usr/openv/netbackup/bin/bplist  -C dr-tcbs-db-01 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 10/24/2017 00:00:00 -e 10/25/2017 00:00:00 -l -b -R /

--t24
/usr/openv/netbackup/bin/bplist  -C t24db04 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 02/07/2018 00:00:00 -e 02/09/2018 00:00:00 -l -b -R /
/usr/openv/netbackup/bin/bplist  -C t24db04 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 10/23/2017 00:00:00 -e 10/25/2017 09:00:00 -l -b -R /
/usr/openv/netbackup/bin/bplist  -C t24db04 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 10/25/2017 00:00:00 -e 10/26/2017 09:00:00 -l -b -R /

/usr/openv/netbackup/bin/bplist  -C dr-core-db-01 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 03/09/2019 00:00:00 -e 03/10/2019 00:00:00 -l -b -R -k COBR14-DR /

YEAR1x-DR

/usr/openv/netbackup/bin/bplist  -C dr-core-db-02 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 01/01/2019 00:00:00 -e 18/02/2019 09:00:00 -l -b -R /


/usr/openv/netbackup/bin/bplist  -C dr-core-db-01 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 06/01/2018 00:00:00 -e 06/13/2018 09:00:00 -l -b -R /

--farm
/usr/openv/netbackup/bin/bplist  -C dr-oradb-01 -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 03/09/2019 00:00:00 -e 03/10/2019 00:00:00 -l -b -R -k BANCADB/
/usr/openv/netbackup/bin/bplist  -C dr-oradb-02.techcombank.com.vn -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 03/09/2019 00:00:00 -e 03/13/2019 09:00:00 -l -b -R -k BANCADR/
/usr/openv/netbackup/bin/bplist  -C dr-ora-db02.techcombank.com.vn -t 4 -S dr-backup-01.headquarter.techcombank.com.vn -s 12/17/2017 00:00:00 -e 12/18/2017 00:00:00 -l -b -R /

==============================================================================
================================RESTORE DB ===================================
==============================================================================
--============restore spfile  --> fix pfile or fix pfile 
run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-ora-db02.techcombank.com.vn,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
restore spfile to '/home/oracle/restore_mbb.ora' from '/c-143571866-20171217-02';
release channel t1;
}
create pfile from spfile;
--> fix
-----

startup nomount pfile=''
create spfile from pfile='';
--============restore controlfile
run{
allocate channel t1 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-ora-db02.techcombank.com.vn,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
restore controlfile  from '/stage/T24_12C_COLD_BACKUP/T24_COB_control_3qsmgrus';
release channel t1;
}

--local disk
restore controlfile  from '/testcob/backup/ctl_T24LIVE_20190321_4btt0cso_1_1';

alter system set control_files='' scope=spfile;
startup mount force
--fix pfile
-->create spfile from pfile;
-->startup mount;

--============restore database
select 'set newname for datafile '||file_id ||' to ''+POCT24_DR'';' from dba_data_files order by file_id;
select 'switch datafile '||file_id ||' to copy;' from dba_data_files order by file_id;
 switch datafile 1 to copy; 
set until time "to_date('2017-10-24:22:10:00', 'yyyy-mm-dd:hh24:mi:ss')";

run{
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
allocate channel t3 device type 'sbt_tape' ;
allocate channel t4 device type 'sbt_tape' ;
allocate channel t5 device type 'sbt_tape' ;
allocate channel t6 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-ora-db02.techcombank.com.vn,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set newname for datafile 1 to '+DATA_RESTORE';
set newname for datafile 2 to '+DATA_RESTORE';
set newname for datafile 3 to '+DATA_RESTORE';
set newname for datafile 4 to '+DATA_RESTORE';
restore database;
switch datafile all;
release channel t1;
release channel t2;
release channel t3;
release channel t4;
release channel t5;
release channel t6;
}

run
{
allocate channel t1 device type disk;
allocate channel t2 device type disk;
allocate channel t3 device type disk;
allocate channel t4 device type disk;
restore database;
switch datafile all;
}

---FOR ESB ONLY
run{
set until time "to_date('2017-12-17:22:30:00', 'yyyy-mm-dd:hh24:mi:ss')";

ALLOCATE CHANNEL ch0   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch1   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch2   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch3   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch4   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch5   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch6   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch7   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
SEND 'NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';

set newname for datafile 1 to '+RESTORE15';
set newname for datafile 2 to '+RESTORE15';
set newname for datafile 3 to '+RESTORE15';
set newname for datafile 4 to '+RESTORE15';
set newname for datafile 5 to '+RESTORE15';
set newname for datafile 8 to '+RESTORE15';
set newname for datafile 9 to '+RESTORE15';
set newname for datafile 10 to '+RESTORE15';
set newname for datafile 11 to '+RESTORE15';
set newname for datafile 12 to '+RESTORE15';
set newname for datafile 13 to '+RESTORE15';
set newname for datafile 14 to '+RESTORE15';
set newname for datafile 22 to '+RESTORE15';
set newname for datafile 23 to '+RESTORE15';
set newname for datafile 24 to '+RESTORE15';
set newname for datafile 25 to '+RESTORE15';
set newname for datafile 26 to '+RESTORE15';
set newname for datafile 27 to '+RESTORE15';
set newname for datafile 28 to '+RESTORE15';
set newname for datafile 29 to '+RESTORE15';
set newname for datafile 30 to '+RESTORE15';
set newname for datafile 31 to '+RESTORE15';
set newname for datafile 32 to '+RESTORE15';
set newname for datafile 33 to '+RESTORE15';
set newname for datafile 34 to '+RESTORE15';
set newname for datafile 35 to '+RESTORE15';
restore database;
switch datafile all;

RELEASE CHANNEL ch0;
RELEASE CHANNEL ch1;
RELEASE CHANNEL ch2;
RELEASE CHANNEL ch3;
RELEASE CHANNEL ch4;
RELEASE CHANNEL ch5;
RELEASE CHANNEL ch6;
RELEASE CHANNEL ch7;
}

--============check capacity before restore
select name,free_mb/1024, total_mb/1024 from v$asm_diskgroup;

--turn off flashbask if it's on
select flashback_on from v$database;
alter database flashback off;

--============recover database 
run{
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
allocate channel t3 device type 'sbt_tape' ;
allocate channel t4 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-ora-db02.techcombank.com.vn,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
recover database until time "to_date('2017-12-17:22:30:00', 'yyyy-mm-dd:hh24:mi:ss')";
release channel t1;
release channel t2;
release channel t3;
release channel t4;
}


run{
allocate channel t1 device type 'sbt_tape' ;
allocate channel t2 device type 'sbt_tape' ;
send 'NB_ORA_CLIENT=dr-core-db-01,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
set archivelog destination to '/data/T24DR/backup_cobr14dr/';
restore archivelog from sequence 1 until sequence 9 thread 1;
restore archivelog  sequence 1 thread 1;
release channel t1;
release channel t2;
}s

--Esb only
run{
ALLOCATE CHANNEL ch0   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch1   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch2   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch3   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch4   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch5   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
ALLOCATE CHANNEL ch6   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' ;
ALLOCATE CHANNEL ch7   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' ;
SEND 'NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
recover database until time "to_date('2017-11-20:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";

RELEASE CHANNEL ch0;
RELEASE CHANNEL ch1;
RELEASE CHANNEL ch2;
RELEASE CHANNEL ch3;
RELEASE CHANNEL ch4;
RELEASE CHANNEL ch5;
RELEASE CHANNEL ch6;
RELEASE CHANNEL ch7;
}

--============Neu restore tu ban backup tren standby DB --> tao lai control file or activate standby
alter database activate physical standby database;

--ghi controlfile ra trace file
alter database backup controlfile to trace;

CREATE CONTROLFILE REUSE DATABASE "MBBDB" RESETLOGS FORCE LOGGING ARCHIVELOG
    MAXLOGFILES 192
    MAXLOGMEMBERS 3
    MAXDATAFILES 1024
    MAXINSTANCES 32
    MAXLOGHISTORY 2336
LOGFILE
  GROUP 11 ('+DATA_RESTORE','+DATA_RESTORE') SIZE 200M BLOCKSIZE 512,
  GROUP 12 ('+DATA_RESTORE','+DATA_RESTORE') SIZE 200M BLOCKSIZE 512,
  GROUP 13 ('+DATA_RESTORE','+DATA_RESTORE') SIZE 200M BLOCKSIZE 512,
  GROUP 14 ('+DATA_RESTORE','+DATA_RESTORE') SIZE 200M BLOCKSIZE 512
DATAFILE
  '+DATA_RESTORE/mbbres/datafile/system.287.963219849',
  '+DATA_RESTORE/mbbres/datafile/sysaux.284.963219813',
  '+DATA_RESTORE/mbbres/datafile/undotbs1.289.963219859',
  '+DATA_RESTORE/mbbres/datafile/users.285.963219815',
  '+DATA_RESTORE/mbbres/datafile/undotbs2.297.963234477',
  '+DATA_RESTORE/mbbres/datafile/users.276.963219767',
  '+DATA_RESTORE/mbbres/datafile/users.280.963219787',
  '+DATA_RESTORE/mbbres/datafile/users.292.963232349',
  '+DATA_RESTORE/mbbres/datafile/users.295.963234457',
  '+DATA_RESTORE/mbbres/datafile/users.283.963219797',
  '+DATA_RESTORE/mbbres/datafile/users.277.963219769',
  '+DATA_RESTORE/mbbres/datafile/users.279.963219775',
  '+DATA_RESTORE/mbbres/datafile/users.278.963219773',
  '+DATA_RESTORE/mbbres/datafile/users.282.963219793',
  '+DATA_RESTORE/mbbres/datafile/users.286.963219839',
  '+DATA_RESTORE/mbbres/datafile/users.293.963232357',
  '+DATA_RESTORE/mbbres/datafile/users.296.963234467',
  '+DATA_RESTORE/mbbres/datafile/users.288.963219855',
  '+DATA_RESTORE/mbbres/datafile/users.291.963219877',
  '+DATA_RESTORE/mbbres/datafile/users.294.963232367',
  '+DATA_RESTORE/mbbres/datafile/users.281.963219793',
  '+DATA_RESTORE/mbbres/datafile/users.290.963219867'
CHARACTER SET AL32UTF8
;

--============open reset log
alter database open resetlogs;

--chuyen ve noarchivelog mode
alter database noarchivelog;

ALTER TABLESPACE TEMPT24LIVE ADD TEMPFILE '+T24DEV' size 10G autoextend on next 1G;
ALTER TABLESPACE TEMP_NEW ADD TEMPFILE '+T24DEV' size 10G autoextend on next 1G;

=================================================================================
=============================convert from single to rac==========================
=================================================================================

alter database add logfile thread 2 group 21 '+T24TEST4_TEST','+T24TEST4_TEST' size 4G;
alter database add logfile thread 2 group 22 '+T24TEST4_TEST','+T24TEST4_TEST' size 4G;
alter database add logfile thread 2 group 23 '+T24TEST4_TEST','+T24TEST4_TEST' size 4G;
alter database add logfile thread 2 group 24 '+T24TEST4_TEST','+T24TEST4_TEST' size 4G;
alter database add logfile thread 2 group 25 '+T24TEST4_TEST','+T24TEST4_TEST' size 4G;
alter database enable public thread 2;

create undo tablespace UNDOTBS2 datafile  '+T24TEST4_TEST' size 1G autoextend on next 1G;


*.cluster_database_instances=2
*.cluster_database=true
*.remote_listener='LISTENERS_TESTCOB'
ORADB1.instance_number=1
ORADB2.instance_number=2
ORADB1.thread=1
ORADB2.thread=2
ORADB1.undo_tablespace='UNDOTBS1'
ORADB2.undo_tablespace='UNDOTBS2'
#update the actual controlfile path
*.control_files='+DATA/ORADB/controlfile/current.256.666342941','+FLASH/ORADB/controlfile/current.256.662312941'

SYS@testcob1 > alter system set instance_number=2 scope=spfile sid='testcob2';
SYS@testcob1 > alter system set thread=1 scope=spfile sid='testcob1';
SYS@testcob1 > alter system set thread=2 scope=spfile sid='testcob2';
SYS@testcob1 > alter system set undo_tablespace='UNDOTBS1' scope=spfile sid='testcob1';
SYS@testcob1 > alter system set undo_tablespace='UNDOTBS2'  scope=spfile sid='testcob2';

[oracle@orarac1]$ srvctl add database -d year18 -o /u01/app/oracle/product/12.1.0/dbhome_1
[oracle@orarac1]$ srvctl add instance -d testcob -i testcob1 -n dr-core-db-dev
[oracle@orarac1]$ srvctl add instance -d t24test1 -i t24test12 -n dr-core-db-test02
srvctl add database -d year18 -o /u01/app/oracle/product/12.1.0/dbhome_1 -p +YEAREND_DR/YEAR18/spfileyear18.ora -s OPEN -y AUTOMATIC -c SINGLE -x dr-core-db-02
srvctl add database -d year13 -o /u01/app/oracle/product/11.2.0/dbhome_1 -p +YEAREND_DR/year13/spfileyear13.ora -s OPEN -y AUTOMATIC -c SINGLE -x dr-core-db-02


srvctl add database -d testcob -o /u01/app/oracle/product/12.1.0/dbhome_1 -dbtype RAC -spfile +TESTCOB_DR/TESTCOB/spfiletestcob.ora -role PRIMARY -startoption OPEN -policy AUTOMATIC  -diskgroup TESTCOB_DR,FRATESTCOB_DR
srvctl add instance -d testcob -i testcob1 -n dr-core-db-01
srvctl add instance -d testcob -i testcob2 -n dr-core-db-02
srvctl status database -d testcob 
srvctl stop database -d testcob 
srvctl start database -d testcob 

select file_name from dba_temp_files order by 1;
ALTER TABLESPACE TEMP_NEW DROP DATAFILE '+DGROUP1/example_df3.f';
ALTER TABLESPACE TEMPT24LIVE DROP DATAFILE '+DGROUP1/example_df3.f';

alter user T24LIVE identified by  t24live#123;

[oracle@orarac1]$ srvctl stop database -d t24test1
[oracle@orarac1]$ srvctl start database -d t24test1
[oracle@orarac1]$ srvctl status database -d t24test1

SQL> select * from v$active_instances;


[oracle@orarac1]$ crs_stat -t
 

=================================================================================
====================restore archive log==========================================
=================================================================================
run {
backup archivelog thread 1  sequence 4438 format '/restore_temp/restore/201703/backup_arc/%U';
}

catalog start with '/u01/app/oracle/diag/rdbms/esbdata2/esbdata21/trace/backup_arc_new';

run {
SET ARCHIVELOG DESTINATION TO '+FRA01_DR/esbdata2/archivelog/res/';
RESTORE ARCHIVELOG sequence 4438 thread 1;
RESTORE ARCHIVELOG FROM TIME = "to_date('2014-01-19 19:20:00','YYYY-DD-MM HH24:MI:SS')"  
                    UNTIL TIME = "to_date('2014-01-19 20:00:00','YYYY-DD-MM HH24:MI:SS')";
}

=================================================================================
=============================Dataguard===========================================
=================================================================================
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
BACKUP INCREMENTAL  FROM SCN 13243534264 DATABASE FORMAT '/u01/app/oracle/backup/backup_%U' tag 'FORSTANDBY';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}


catalog start with '/u01/app/oracle/backup/';
--catalog start with '+T24R14_DR';
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
backup as compressed backupset datafile 1,2,3,4,5 FORMAT '/u01/app/oracle/backup/new_%U' tag 'FOR_STANDBY';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}


ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

select file#, min(to_char(checkpoint_change#)) from v$datafile_header group by file#;

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
restore datafile 1,2,3,4,5 ;
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}


=================================================================================
=========================Clone database==========================================
=================================================================================
=====rename diskgroup 
https://community.toadworld.com/platforms/oracle/w/wiki/11717.how-to-rename-an-asm-diskgroup

asmcmd umount ORA_DATA 
renamedg phase=bot  dgname=ORA_DATA newdgname=NEW_DATA verbose=true check=TRUE --> check fisrt
renamedg phase=both dgname=ORA_DATA newdgname=NEW_DATA verbose=true confirm=TRUE
asmcmd mount NEW_DATA
=====create clone database [Optional]
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
-diskGroupName DATA04 \
-recoveryAreaDestination FRA \
-characterSet AL32UTF8 \
-nationalCharacterSet AL16UTF16 \
-totalMemory 600 \
-nodeinfo dc-ora-db01,dc-ora-db02 

shutdown 1 node
alter system set cluster_database=FALSE scope=spfile sid='*';
startup nomount;
alter system archive log;

-- rm datafile, onlinelog, tempfile

=====
--insert into listener.ora --> restart listener
vi /u01/app/grid/product/11.2.0.4/grid/network/admin/listener.ora
SID_LIST_LISTENER =
(SID_LIST =
        (SID_DESC =
        (GLOBAL_DBNAME = t24dev1)
        (ORACLE_HOME = /u01/app/oracle/product/12.1.0/dbhome_1)
        (SID_NAME = t24dev1)

    )
      (SID_DESC =
        (GLOBAL_DBNAME = t24dev2)
        (ORACLE_HOME = /u01/app/oracle/product/12.1.0/dbhome_1)
        (SID_NAME = t24dev2)
    )
)
		
lsnrctl stop		
lsnrctl start

vi tnsnames.ora
COBR14DR2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = tcp)(HOST = 192.168.11.192)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cobr14dr)
    )
  )

=====Copy password file
Create the password file for the axuilary instance in this case the new Standby. 
orapwd file=$ORACLE_HOME/dbs/orapwcobr14dr password=oracle123
cp $ORACLE_HOME/dbs/orapwt24r14dr  $ORACLE_HOME/dbs/orapwt24drodg

=====on T24r14dr [Optional]
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;

=====

--clone to new primary DB
. cobr14dr
rman TARGET / AUXILIARY dbsnmp/PAssw0rd@t24drodg 

rman target DBSNMP/PAssw0rd@t24r14dr1 AUXILIARY DBSNMP/PAssw0rd@monthend  ######12C
rman target DBSNMP/PAssw0rd@t24r14dr1 AUXILIARY DBSNMP/PAssw0rd@refresh 

rman target DBSNMP/PAssw0rd@t24r14dr1 AUXILIARY DBSNMP/PAssw0rd@testcob1

run{
allocate channel d01 device type disk;          
allocate channel d02 device type disk;
allocate auxiliary channel da01 device type disk;               
allocate auxiliary channel da02 device type disk;
DUPLICATE TARGET DATABASE TO t24dev1 FROM ACTIVE DATABASE NOFILENAMECHECK;
}  

export ORACLE_SID=t24test21
rman target DBSNMP/PAssw0rd@t24dev1 AUXILIARY DBSNMP/PAssw0rd@t24t2
--clone standby to new standby DB
. t24r14dr
rman  auxiliary  sys/oracle#123@cobr14dr  target sys/oracle#123@t24r14dr
rman TARGET / AUXILIARY dbsnmp/PAssw0rd@t24drodg

. t24r14dr
rman target DBSNMP/PAssw0rd@t24r14dr1 AUXILIARY DBSNMP/PAssw0rd@testcob1 
run {
ALLOCATE CHANNEL tgt10 TYPE DISK;
ALLOCATE CHANNEL tgt20 TYPE DISK;
ALLOCATE CHANNEL tgt30 TYPE DISK;
ALLOCATE CHANNEL tgt40 TYPE DISK;
ALLOCATE CHANNEL tgt50 TYPE DISK;
ALLOCATE CHANNEL tgt60 TYPE DISK;
ALLOCATE CHANNEL tgt70 TYPE DISK;
ALLOCATE CHANNEL tgt80 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup1 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup2 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup3 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup4 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup5 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup6 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup7 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup8 TYPE DISK;
duplicate target database for standby from active database nofilenamecheck;
}

run {
ALLOCATE CHANNEL tgt10 TYPE DISK;
ALLOCATE CHANNEL tgt20 TYPE DISK;
ALLOCATE CHANNEL tgt30 TYPE DISK;
ALLOCATE CHANNEL tgt40 TYPE DISK;
ALLOCATE CHANNEL tgt50 TYPE DISK;
ALLOCATE CHANNEL tgt60 TYPE DISK;
ALLOCATE CHANNEL tgt70 TYPE DISK;
ALLOCATE CHANNEL tgt80 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup1 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup2 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup3 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup4 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup5 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup6 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup7 TYPE DISK;
ALLOCATE AUXILIARY CHANNEL dup8 TYPE DISK;
duplicate target database for standby from active database 
spfile
PARAMETER_VALUE_CONVERT 't24r14dr','testcob'
set db_unique_name='testcob'
set instance_name='testcob1'
set control_files='+FRATESTCOB_DR','+TESTCOB_DR'
set db_create_file_dest='+TESTCOB_DR'
set db_create_online_log_dest_1='+FRATESTCOB_DR'
set db_recovery_file_dest='+FRATESTCOB_DR'
set db_recovery_file_dest_size='3000G'
SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(t24r14dr,testcob)'
SET DB_FILE_NAME_CONVERT='+T24R14_DR','+TESTCOB_DR'
SET LOG_FILE_NAME_CONVERT='+FRAT24R14_DR','+FRATESTCOB_DR','+T24R14_DR','+TESTCOB_DR'
set cluster_database='FALSE'
set instance_number='1'
nofilenamecheck;
}

=====ERROR
RMAN-06136: ORACLE error from auxiliary database: ORA-07202: sltln: invalid parameter to sltln.  --> spfile is created . 2 controlfile value recieved
if hang in copy controlfile --> add "DISABLE_OOB=on" to sqlnet.ora


=====on clone DB  [Optional - standby]
alter system set cluster_database=TRUE scope=spfile sid='*';
restart

=====add logfile group + drop old logfile group
--both target and auxilary
select distinct 'alter database clear logfile group  '||group#||';' from v$logfile
order by 1

--on target (TESTCOB)
select distinct 'alter database drop logfile group '||group#||';' from v$logfile
order by 1


alter database add  logfile THREAD 1 group 11 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 1 group 12 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 1 group 13 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 1 group 14 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 2 group 25 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 2 group 26 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 2 group 27 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add  logfile THREAD 2 group 28 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;

alter database add standby logfile THREAD 1 group 31 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 1 group 32 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 1 group 33 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 1 group 34 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 1 group 35 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 2 group 41 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 2 group 42 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 2 group 43 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 2 group 44 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;
alter database add standby logfile THREAD 2 group 45 ('+TESTCOB_DR','+FRATESTCOB_DR') SIZE 4G;

=====cobr14dr [Optional]
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;