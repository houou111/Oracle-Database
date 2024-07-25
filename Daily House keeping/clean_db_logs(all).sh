#!/bin/bash
# -------------------------------------------------------
# File name:    clean_db_logs.sh
# Purpose:      Shell script to clean database logs
#               Clean ADRCI, OS Audit, RMAN Archivelog
# Last updated on: 01/01/2020
# Usage:        ./clean_db_logs.sh -> config the cut
# -------------------------------------------------------

# =========================== VARIABLES ===========================
# database variables

for i in $(ps -ef | grep ora_smon_ | grep -v grep |awk -F' ' '{print $8}' |awk -F'_' '{print $3}'); do

export ORACLE_SID=$i
export ORACLE_HOME=`/usr/sbin/lsof | grep $ORACLE_SID | grep /u01/app/oracle/product| head -1 | awk -F' ' '{print $9}' | awk -F'/dbs' '{print $1}'`
export ORACLE_BASE=/u01/app/oracle
export PATH=$ORACLE_HOME/bin:$PATH



# log dir destination
mkdir -p /home/oracle/dbscript/log
export LOG_DIR=/home/oracle/dbscript/log
export RMAN_LOG=$LOG_DIR/"$ORACLE_SID"_delete_archivelog_`date +%Y%m%d`.log
find $LOG_DIR/*.log -mtime +14 -exec rm -f {} \;

# ADR keep time (mins)
export ADR_KEEP_TIME=4320

# OS audit keep time (days)
export AUD_KEEP_TIME=3

# create log file directory
mkdir -p $LOG_DIR

# =========================== MAIN ===========================
echo "------------------------------------------------------------"
echo " CLEAN DATE: `date '+%m/%d/%y %A %X'`"
echo "------------------------------------------------------------"

# -------------------- PURGE ADR CONTENTS --------------------
echo "INFO: ADRCI purge started at `date '+%m/%d/%y %A %X'`"
HOME_PATH=`adrci exec="show homes"|grep $ORACLE_SID`
echo "INFO: ADRCI purging diagnostic destination " $HOME_PATH
echo "INFO: purge ALERT"
adrci exec="set homepath $HOME_PATH;purge -age $ADR_KEEP_TIME -type ALERT"
echo "INFO: purge INCIDENT"
adrci exec="set homepath $HOME_PATH;purge -age $ADR_KEEP_TIME -type INCIDENT"
echo "INFO: purge TRACE"
adrci exec="set homepath $HOME_PATH;purge -age $ADR_KEEP_TIME -type TRACE"
echo "INFO: purge CDUMP"
adrci exec="set homepath $HOME_PATH;purge -age $ADR_KEEP_TIME -type CDUMP"
echo "INFO: purge HM"
adrci exec="set homepath $HOME_PATH;purge -age $ADR_KEEP_TIME -type HM"
echo "INFO: ADRCI purge finished at `date`"
echo ""

# -------------------- CLEAN OS AUDIT FILES --------------------
echo "INFO: Clean OS audit files started at `date '+%m/%d/%y %A %X'`"
# get OS audit file destination
ADUMP_DIR=`sqlplus -s / as sysdba <<EOF
set pages 0
set head off
set feed off
select value from v\\$parameter where name='audit_file_dest';
exit
EOF`
# locate to adump
cd $ADUMP_DIR
echo "INFO: Audit file destination: $ADUMP_DIR"
echo "INFO: Total number of files: `ls -la| wc -l`"
echo "INFO: Total number of files to be deleted: `find . -type f -mtime +$AUD_KEEP_TIME -name '*.aud' | wc -l`"
# delete OS audit files
find . -type f -mtime +$AUD_KEEP_TIME -name '*.aud' -exec rm -f {} \;
echo "INFO: Total number of files remaining: `ls -la | wc -l`"
echo "INFO: Clean OS audit files finished at `date '+%m/%d/%y %A %X'`"
echo ""

# cut logfile
export TODAY=`/bin/date +%d`
export TOMORROW=`/bin/date +%d -d "1 day" -d "-0 month -$(($(date +%d)-1)) days"`

export TRACE_DIR=`sqlplus -s / as sysdba <<EOF
set pages 0
set head off
set feed off
select value from v\\$diag_info where name='Diag Trace';
exit
EOF`

if [ $TOMORROW -eq $TODAY ]
then
  mv $TRACE_DIR/alert_$ORACLE_SID.log $TRACE_DIR/alert_$ORACLE_SID_`date '+%Y%m%d'`.log
fi


# -------------------- RMAN DELETE ARCHIVELOG --------------------
# delete archivelog all completed before [SYSDATE-2]
rman target / nocatalog msglog $RMAN_LOG append <<EOF
crosscheck archivelog all;
DELETE FORCE NOPROMPT archivelog until time 'sysdate-1';
exit;
EOF

# -------------------- SHRINK TEMPFILE : reduce 10% and purge recyclebin 15 day --------------------
SHRINK_SQL="DECLARE
   cmd   VARCHAR2 (4000);
   CURSOR c_table
   IS
select TABLESPACE_NAME,trunc(TABLESPACE_SIZE*98/100/1024/1024/1024,0) Keep_size
FROM   dba_temp_free_space;
BEGIN
   FOR r IN c_table
   LOOP
    cmd :='alter tablespace '||r.TABLESPACE_NAME||' shrink space keep '||r.Keep_size||'G';
    DBMS_OUTPUT.put_line (cmd);
    execute immediate cmd;
    END LOOP;
END;"

PURGE_SQL="DECLARE
   cmd   VARCHAR2 (4000);
   CURSOR c_table
   IS
select owner,object_name
FROM   dba_recyclebin
where can_purge = 'YES'
and type = 'TABLE'
and to_date(droptime, 'YYYY-MM-DD:HH24:MI:SS') < sysdate - 15;
BEGIN
   FOR r IN c_table
   LOOP
    cmd :='purge table "' || owner || '"."' || object_name || '"';
    DBMS_OUTPUT.put_line (cmd);
    execute immediate cmd;
    END LOOP;
END;"


echo $SHRINK_SQL > /home/oracle/dbscript/shrink_tempfile.sql
echo "/" >> /home/oracle/dbscript/shrink_tempfile.sql
echo "exit" >> /home/oracle/dbscript/shrink_tempfile.sql
echo $PURGE_SQL > /home/oracle/dbscript/purge.sql
echo "/" >> /home/oracle/dbscript/purge.sql
echo "exit" >> /home/oracle/dbscript/purge.sql

CDB=`sqlplus -s / as sysdba <<EOF
SET HEADING OFF
select CDB from v\\$database;
exit
EOF`

if [ $CDB == "YES" ];
then
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -d /home/oracle/dbscript -l /tmp -s -b shrinktemp -f -S shrink_tempfile.sql
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -d /home/oracle/dbscript -l /tmp -s -b purge -f -S purge.sql
else
$ORACLE_HOME/bin/sqlplus / as sysdba @/home/oracle/dbscript/shrink_tempfile.sql
$ORACLE_HOME/bin/sqlplus / as sysdba @/home/oracle/dbscript/purge.sql
fi


echo 'Done!'
done
