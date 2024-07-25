#!/bin/sh

#-------------------------------------------------------
# File: deallocate_table_one_table.sh
# Desc: Perform Table Deallocate - Single Table
# Runs: Four Times per Month = 0 0 1,8,15,22 * *
# Parm: 1 - Table Owner
# Parm: 2 - Table to Deallocate
# Parm: 3 - Megabytes to Keep (default 4)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA TABLE {MEGS_KEEP (default 4)}"
  exit 1
fi

if [ $# -lt 3 ]
then
  TJS_MEGS_KEEP=4
else
  TJS_MEGS_KEEP=$3
fi

TJS_LOG_TRAIL="$1.$2"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
alter table $1.$2 deallocate unused keep $TJS_MEGS_KEEP M;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh