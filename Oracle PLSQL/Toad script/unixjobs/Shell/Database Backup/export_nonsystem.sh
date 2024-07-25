#!/bin/sh

#-------------------------------------------------------
# File: export_nonsystem.sh
# Desc: Perform Export - Non-System Users
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Remove exports older than N days (default 3)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Remove trigger from exclusions
#  1.2  07/12/2002  Added return code checking
#  1.3  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.4  10/03/2002  Fix HPUX lacks rm with -v opt
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  TJS_RM_AFTER=3
else
  TJS_RM_AFTER=$1
fi

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select username
  from dba_users
 where username not in ('SYS','SYSTEM','DBSNMP','OUTLN')
   and exists (select 1 from dba_segments
               where owner = username);
spool off
EOF
TJS_RETURN_CODE=$?

if [ $TJS_RETURN_CODE -eq 0 ]
then
cat $TJS_TMP_FILE | while read line
do
  TJS_PIP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$line.pip.$TJS_TIME_STAMP
  TJS_DMP_FILE=$TJS_DMP/$ORACLE_SID.$TJS_JOB.$line.dmp.$TJS_TIME_STAMP.Z
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo Removing export files older than $TJS_RM_AFTER in directory $TJS_DMP
    find $TJS_DMP -name  '$ORACLE_SID.$TJS_JOB.$line.dmp.*' -ctime +$TJS_RM_AFTER -exec rm -f {} \;
    TJS_RETURN_CODE=$?
  fi
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo Exporting schema $line to compressed file = $TJS_DMP_FILE
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
    $ORACLE_HOME/bin/exp owner=$line file=$TJS_PIP_FILE compress=n grants=n indexes=n rows=y constraints=n direct=y consistent=y statistics=none buffer=1048576 <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
EOF
    TJS_RETURN_CODE=$?
  fi
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    rm -f $TJS_PIP_FILE
    TJS_RETURN_CODE=$?
  fi
done
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh