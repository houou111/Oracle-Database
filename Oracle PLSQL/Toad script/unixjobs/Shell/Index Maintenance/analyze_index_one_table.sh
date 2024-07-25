#!/bin/sh

#-------------------------------------------------------
# File: analyze_index_one_table.sh
# Desc: Perform Analyze Index - Single Table
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Table Owner
# Parm: 2 - Table for which to Analyze Indexes
# Parm: 3 - Sample Percent (default 5)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` SCHEMA TABLE {SAMPLE_PERCENT (default 5)}"
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
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select 'analyze index '||owner||'.'||index_name||' estimate statistics sample $TJS_SAMPLE_PERCENT percent;'
from all_indexes
where owner not in ('SYS','SYSTEM','DBSNMP','OUTLN')
  and tablespace_name != 'SYSTEM'
  and table_owner = upper('$1')
  and table_name = upper('$2')
order by owner, table_name, index_name;
spool off
$TJS_SQL_SET2
@$TJS_TMP_FILE
EOF
TJS_RETURN_CODE=$?

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh