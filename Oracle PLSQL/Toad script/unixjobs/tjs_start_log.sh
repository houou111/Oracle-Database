#!/bin/sh

#-------------------------------------------------------
# File: tjs_start_log.sh
# Desc: TOAD Job Scheduler Job Log Start
# Parm: 1 - optional job log descriminator
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/30/2002  Fixed empty log error message
#  1.2  10/03/2002  Fix HPUX lacks rm with -v opt
#-------------------------------------------------------

## Application log and temporary file names
if [ "$TJS_LOG_TRAIL" = "" ]
then
  TJS_FILENAME=$TJS_LOG_LEAD
else
  TJS_FILENAME=$TJS_LOG_LEAD.$TJS_LOG_TRAIL
fi
TJS_LOG_FILE=$TJS_LOG/$TJS_FILENAME.log.$TJS_TIME_STAMP
TJS_TMP_FILE=$TJS_TMP/$TJS_FILENAME.tmp.$TJS_TIME_STAMP
export TJS_FILENAME TJS_LOG_FILE TJS_TMP_FILE

## Clean up log and temp files (keep week's/day's worth at most)
find $TJS_LOG -name '$TJS_FILENAME.log.*' -ctime +7 -exec rm -f {} \;
find $TJS_TMP -name '$TJS_FILENAME.tmp.*' -ctime +1 -exec rm -f {} \;

## Clean up log files for highly scheduled jobs (keep ten copies at most)
xxx=`ls -l $TJS_LOG/$TJS_FILENAME.log.* 2>/dev/null | wc -l`
if [ $xxx -gt 10 ]
then
  yyy=`expr $xxx - 10`
  for i in `ls $TJS_LOG/$TJS_FILENAME.log.* | head -$yyy`
  do
    rm -f $i
  done
fi

## Redirect all output to application log
exec 2>$TJS_LOG_FILE 1>&2

## Start the job log
TJS_JOB_START=`date "+%d-%b-%Y %H:%M:%S"`
export TJS_JOB_START

## Log start message to application log
cat <<EOF
------------------------------------------------------------------------------
Starting the job log
------------------------------------------------------------------------------
Script Name   : $TJS_JOB
Start Time    : $TJS_JOB_START
Arguments     : $*
Env Variables :
EOF

## List TJS environment variables (do not list any oracle passwords)
id
echo pid=$$ ppid=$PPID
env | egrep '^(TJS|ORACLE)_' | egrep -v '^ORACLE_(TOAD|DBA|SYSDBA)_UPW' | sort 

## Start message for application
cat <<EOF
------------------------------------------------------------------------------
Starting the job ....
------------------------------------------------------------------------------
EOF