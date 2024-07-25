#!/bin/sh

#-------------------------------------------------------
# File: cleanup_trace_files.sh
# Desc: Remove and Compress All Trace Files
# Runs: Four Times per Day = 0 0,6,12,18 * * *
# Parm: 1 - Remove files older than N days (default 7)
# Parm: 2 - compress files older than N days (default 3)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.3  10/03/2002  Fix HPUX lacks rm with -v opt
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  TJS_RM_AFTER=7
else
  TJS_RM_AFTER=$1
fi

if [ $# -lt 2 ]
then
  TJS_COMPRESS_AFTER=3
else
  TJS_COMPRESS_AFTER=$2
fi

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select distinct value
  from v\$parameter
 where name in ('user_dump_dest','core_dump_dest','background_dump_dest');
spool off
EOF
TJS_RETURN_CODE=$?

if [ $TJS_RETURN_CODE -eq 0 ]
then
cat $TJS_TMP_FILE | while read line
do
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo Removing trace files older than $TJS_RM_AFTER in directory $line
    find $line -name '*.trc'   -ctime +$TJS_RM_AFTER -exec rm -f {} \;
    TJS_RETURN_CODE=$?
  fi
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo Removing compressed trace files older than $TJS_RM_AFTER in directory $line
    find $line -name '*.trc.Z' -ctime +$TJS_RM_AFTER -exec rm -f {} \;
    TJS_RETURN_CODE=$?
  fi
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo Compressing trace files older than $TJS_COMPRESS_AFTER in directory $line
    find $line -name '*.trc'   -ctime +$TJS_COMPRESS_AFTER -exec compress -v {} \;
    TJS_RETURN_CODE=$?
  fi
done 
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh