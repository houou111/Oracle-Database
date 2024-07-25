#!/bin/sh

#-------------------------------------------------------
# File: analyze_index_one_index.sh
# Desc: Perform Analyze Index - Single Index
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Index Owner
# Parm: 2 - Index to Analyze
# Parm: 3 - Sample Percent (default 5)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA INDEX {SAMPLE_PERCENT (default 5)}"
  exit 1
fi

if [ $# -lt 3 ]
then
  TJS_SAMPLE_PERCENT=5
else
  TJS_SAMPLE_PERCENT=$3
fi

TJS_LOG_TRAIL="$1.$2"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
analyze index $1.$2 estimate statistics sample $TJS_SAMPLE_PERCENT percent;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh