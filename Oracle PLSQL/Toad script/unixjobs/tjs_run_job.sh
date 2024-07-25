#!/bin/sh

#-------------------------------------------------------
# File: tjs_run_job.sh
# Desc: TOAD Job Scheduler Run Job
# Parm: 1 - Job to Run
# Parm: 2 - Database SID
# Parm: 3 - Job Parameters
# Note: Based upon user supplied information from
#	the TOAD screen for defining job schedules
#	for a target server, TOAD will copy to the
#	server a customized version of this script.
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Fixed bug where oracle version
#                   was 2.3.3 due to tnsping error
#  1.2  07/12/2002  Set the global return code = 0
#  1.3  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.4  10/08/2002  Korn shell for non-linux platforms
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` TOAD_JOB ORACLE_SID ... parameters ..."
  exit 1
fi

## Parse off command line parameters and shift
TJS_JOB=`echo $1 | cut -d"." -f1`
ORACLE_SID=$2
export TJS_JOB ORACLE_SID
if [ $# -ge 2 ]
then
  shift 2
fi

## Use SID and JOB names to form log file parms
TJS_LOG_LEAD=$ORACLE_SID.$TJS_JOB
TJS_LOG_TRAIL=""
export TJS_LOG_LEAD TJS_LOG_TRAIL

## Common directories (TJS_DIR is critical)
TJS_RUN=`basename $0`
TJS_DIR=`echo $0 | sed 's/\/'$TJS_RUN'//'`
TJS_LOG=$TJS_DIR/log
TJS_SHELL=$TJS_DIR/shell
TJS_TMP=$TJS_DIR/tmp
TJS_DMP=$TJS_DIR/dmp
TJS_SQL_SET1="set echo off term off feedback off verify off trimspool on pagesize 0 linesize 256"
TJS_SQL_SET2="set echo on  term on  feedback on  verify off"
export TJS_RUN TJS_DIR TJS_LOG TJS_SHELL TJS_TMP TJS_DMP TJS_SQL_SET1 TJS_SQL_SET2

## TOAD modified section - db sids - start
## TOAD modified section - db sids - stop

# Export TOAD provided ORACLE environment variables
export ORACLE_HOME ORACLE_TOAD_UID ORACLE_TOAD_UPW ORACLE_DBA_UID ORACLE_DBA_UPW ORACLE_SYSDBA_UID ORACLE_SYSDBA_UPW

## Set Oracle version (necessary for version specific commands and utitily selection)
ORACLE_VERS=`$ORACLE_HOME/bin/tnsping $ORACLE_SID | grep 'Version [0-9]\.' | sed 's/^.*Version //;s/ - .*$//;s/2.3/7.3/' | awk '{print substr($0,1,3)}'`
PATH=$ORACLE_HOME/bin:$PATH
LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export ORACLE_VERS PATH LD_LIBRARY_PATH

## Time stamp for unique file names
TJS_TIME_STAMP=`date +%Y"%m""%d.%H"%M`
export TJS_TIME_STAMP

## Set the global return code
TJS_RETURN_CODE=0
export TJS_RETURN_CODE

## Run the desired job
if [ `file /bin/sh | grep -c bash` -eq 1 ]
then
  SH=/bin/sh
else
  SH=/bin/ksh
fi
$SH $TJS_SHELL/$TJS_JOB.sh $*

## Exit with specified return code
exit $TJS_RETURN_CODE
