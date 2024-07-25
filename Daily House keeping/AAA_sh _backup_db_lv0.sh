#!/bin/bash

export ORACLE_SID=$1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export LOG_DIR=/home/oracle/dbscript/log
export RMAN_LOG=$LOG_DIR/backupdb_"$ORACLE_SID"_`date +%Y%m%d`.log

$ORACLE_HOME/bin/rman target / cmdfile=/home/oracle/dbscript/backup_level0.rman log $RMAN_LOG

echo 'Done!'
