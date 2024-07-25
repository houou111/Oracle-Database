#!/bin/sh

#-------------------------------------------------------
# File: rebuild_index_one_index.sh
# Desc: Rebuild Indexes - Single Index
# Runs: Noon Every Sunday = 0 12 * * 0
# Parm: 1 - Index Owner
# Parm: 2 - Index to Rebuild
# Parm: 3 - Parallel Degree (default 4)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added check for version 7 syntax
#  1.2  07/12/2002  Added whenever sqlerror
#  1.3  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA INDEX {PARALLEL_DEGREE (default 4)}"
  exit 1
fi

if [ $# -lt 3 ]
then
  TJS_PARALLEL_DEGREE=4
else
  TJS_PARALLEL_DEGREE=$3
fi

TJS_LOG_TRAIL="$1.$2"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

if [ "$ORACLE_VERS" = "7.3" -o "$ORACLE_VERS" = "7.4" ]
then
  TJS_NOLOG=unrecoverable
else
  TJS_NOLOG=nologging
fi

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
alter index $1.$2 rebuild parallel (degree $TJS_PARALLEL_DEGREE) $TJS_NOLOG;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh