#!/bin/sh

#-------------------------------------------------------
# File: tjs_stop_log.sh
# Desc: TOAD Job Scheduler Job Log Stop
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added return code logic
#  1.2  07/19/2002  Remove ^ from error scan
#-------------------------------------------------------

## Stop the job log
TJS_JOB_STOP=`date "+%d-%b-%Y %H:%M:%S"`
export TJS_JOB_STOP

if [ $TJS_RETURN_CODE -eq 0 ]
then
## Scan log file for Oracle errors
if [ "`egrep '(ORA|TNS|PLS|IMP|EXP|SP1|SP2)-.*:' $TJS_LOG_FILE`" = "" ]
then
   TJS_RETURN_CODE=0
else
   TJS_RETURN_CODE=1
fi
export TJS_RETURN_CODE
fi

## Log return status to application log and syslog
cat <<EOF
------------------------------------------------------------------------------
Stopping the job log
------------------------------------------------------------------------------
Script Name   : $TJS_JOB
Stop Time     : $TJS_JOB_STOP
Return Code   : $TJS_RETURN_CODE
------------------------------------------------------------------------------
EOF