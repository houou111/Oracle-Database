#!/bin/sh

#-------------------------------------------------------
# File: coalesce_index_one_index.sh
# Desc: Perform Index Coalesce - Single Index
# Runs: Four Times per Month = 0 0 1,8,15,22 * *
# Parm: 1 - Index Owner
# Parm: 2 - Index to Coalesce
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA INDEX"
  exit 1
fi

TJS_LOG_TRAIL="$1.$2"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
alter index $1.$2 coalesce;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh