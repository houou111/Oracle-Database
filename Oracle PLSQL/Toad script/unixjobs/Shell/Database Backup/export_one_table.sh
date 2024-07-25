#!/bin/sh

#-------------------------------------------------------
# File: export_one_table.sh
# Desc: Perform Export - Single Table
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Table Owner
# Parm: 2 - Table to Export
# Parm: 3 - Remove exports older than N days (default 3)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Remove trigger from exclusions
#  1.2  07/12/2002  Added return code checking
#  1.3  09/27/2002  Corrected export message
#  1.4  10/03/2002  Fix HPUX lacks rm with -v opt
#  1.5  10/08/2002  Fix tables = parenthesis problem
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA TABLE {RM_AFTER (default 3)}"
  exit 1
fi

if [ $# -lt 3 ]
then
  TJS_RM_AFTER=3
else
  TJS_RM_AFTER=$3
fi

TJS_LOG_TRAIL="$1.$2"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

TJS_PIP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$1.$2.pip.$TJS_TIME_STAMP
TJS_DMP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$1.$2.dmp.$TJS_TIME_STAMP.Z

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Removing export files older than $TJS_RM_AFTER in directory $TJS_DMP
  find $TJS_DMP -name  '$ORACLE_SID.$TJS_JOB.$1.$2.dmp.*' -ctime +$TJS_RM_AFTER -exec rm -f {} \;
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Exporting table $1.$2 to compressed file = $TJS_DMP_FILE
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
  $ORACLE_HOME/bin/exp tables=$1.$2 file=$TJS_PIP_FILE compress=n grants=n indexes=n rows=y constraints=n direct=y consistent=y statistics=none buffer=1048576 <<EOF
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