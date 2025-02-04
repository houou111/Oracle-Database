#!/bin/bash
# -------------------------------------------------------
# File name:    clean_all_logs.sh
# Purpose:      Shell script to clean database logs
#               Clean ADRCI, OS Audit, RMAN Archivelog
# Last updated on: Jan/30/2018
# Usage:        ./clean_all_logs.sh $ORACLE_SID
# -------------------------------------------------------

# =========================== VARIABLES ===========================
# database variables
export ORACLE_SID=$1
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export DAY_REMAIN=3

# log dir destination
export LOG_DIR=/home/oracle/DBSCRIPT/log
export RMAN_LOG=$LOG_DIR/"$ORACLE_SID"_delete_archivelog_`date +%Y%m%d`.log

# ADR keep time (mins)
export ADR_KEEP_TIME=4320

# OS audit keep time (days)
export AUD_KEEP_TIME=10

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
echo $ORACLE_SID
which sqlplus
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

# -------------------- RMAN DELETE ARCHIVELOG --------------------
# delete archivelog all completed before [SYSDATE-3]
rman target / nocatalog msglog $RMAN_LOG append <<EOF
crosscheck archivelog all;
DELETE FORCE NOPROMPT archivelog until time 'sysdate-$DAY_REMAIN ';
exit;
EOF


echo 'Done!'
