#!/bin/bash
for i in $(ps -ef | grep ora_smon_ | grep -v grep |awk -F' ' '{print $8}' |awk -F'_' '{print $3}'); do

export ORACLE_SID=$i
export ORACLE_HOME=`/usr/sbin/lsof | grep $ORACLE_SID | grep /u01/app/oracle/product| head -1 | awk -F' ' '{print $9}' | awk -F'/dbs' '{print $1}'`
export ORACLE_BASE=/u01/app/oracle
export PATH=$ORACLE_HOME/bin:$PATH
export LOG_DIR=/home/oracle/dbscript/log
export RMAN_LOG=$LOG_DIR/backupdb_"$ORACLE_SID"_`date +%Y%m%d`.log

$ORACLE_HOME/bin/rman target / cmdfile=/home/oracle/dbscript/backup_level1.rman log $RMAN_LOG

echo 'Done!'
done