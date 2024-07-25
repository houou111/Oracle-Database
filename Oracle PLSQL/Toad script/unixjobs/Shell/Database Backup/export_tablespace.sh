#!/bin/sh

#-------------------------------------------------------
# File: export_tablespace.sh
# Desc: Perform Export - Single Tablespace
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Tablespace to Export
# Parm: 2 - Remove exports older than N days (default 3)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Remove trigger from exclusions
#  1.2  07/12/2002  Added return code checking
#  1.3  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.4  09/27/2002  Corrected export message
#  1.5  10/03/2002  Fix HPUX lacks rm with -v opt
#  1.6  10/08/2002  Fix tables = parenthesis problem
#  1.7  10/08/2002  Remove system IOT overflow tables
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` TABLESPACE {RM_AFTER (default 3)}"
  exit 1
fi

if [ $# -lt 2 ]
then
  TJS_RM_AFTER=3
else
  TJS_RM_AFTER=$2
fi

TJS_LOG_TRAIL="$1"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select owner||'.'||segment_name
  from dba_segments
 where tablespace_name = upper('$1')
   and segment_type like 'TABLE%'
   and segment_name not like 'SYS_IOT_OVER%';
spool off
EOF
TJS_RETURN_CODE=$?

if [ $TJS_RETURN_CODE -eq 0 ]
then
  TJS_TABLES=`cat $TJS_TMP_FILE | awk 'BEGIN{comma="";tables=""}{tables=tables comma $0;comma=","}END{print tables}'`
  TJS_RETURN_CODE=$?
fi

TJS_PIP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$1.pip.$TJS_TIME_STAMP
TJS_DMP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$1.dmp.$TJS_TIME_STAMP.Z

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Removing export files older than $TJS_RM_AFTER in directory $TJS_DMP
  find $TJS_DMP -name  '$ORACLE_SID.$TJS_JOB.$1.dmp.*' -ctime +$TJS_RM_AFTER -exec rm -f {} \;
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  echo Exporting tablespace $1 to compressed file = $TJS_DMP_FILE
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
  $ORACLE_HOME/bin/exp tables=$TJS_TABLES file=$TJS_PIP_FILE compress=n grants=n indexes=n rows=y constraints=n direct=y consistent=y statistics=none buffer=1048576 <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
EOF
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  rm -f $TJS_PIP_FILE
  TJS_RETURN_CODE=$?
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh