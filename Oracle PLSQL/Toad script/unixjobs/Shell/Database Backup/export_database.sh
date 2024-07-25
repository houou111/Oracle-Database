#!/bin/sh

#-------------------------------------------------------
# File: export_database.sh
# Desc: Perform Export - Full Database
# Runs: Midnight Every Sunday = 0 0 * * 0
# Parm: 1 - Remove exports older than N days (default 3)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Remove trigger from exclusions
#  1.2  07/12/2002  Added return code checking
#  1.3  10/03/2002  Fix HPUX lacks rm with -v opt
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  TJS_RM_AFTER=3
else
  TJS_RM_AFTER=$1
fi

. $TJS_DIR/tjs_start_log.sh

TJS_PIP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.pip.$TJS_TIME_STAMP
TJS_DMP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.dmp.$TJS_TIME_STAMP.Z

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Removing export files older than $TJS_RM_AFTER in directory $TJS_DMP
  find $TJS_DMP -name  '$ORACLE_SID.$TJS_JOB.dmp.*' -ctime +$TJS_RM_AFTER -exec rm -f {} \;
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Exporting entire database $ORACLE_SID to compressed file = $TJS_DMP_FILE
  mkfifo $TJS_PIP_FILE
  TJS_RETURN_CODE=$?
fi
if [ $TJS_RETURN_CODE -eq 0 ]
then
  compress < $TJS_PIP_FILE > $TJS_DMP_FILE &
  TJS_RETURN_CODE=$?
fi
if [ $TJS_RETURN_CODE -eq 0 ]
then
  $ORACLE_HOME/bin/exp full=y file=$TJS_PIP_FILE compress=n grants=n indexes=n rows=y constraints=n direct=y consistent=y statistics=none buffer=1048576 <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
EOF
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  rm -f $TJS_PIP_FILE
  TJS_RETURN_CODE=$?
fi

. $TJS_DIR/tjs_stop_log.sh