#!/bin/sh

#-------------------------------------------------------
# File: coalesce_index_nonsystem.sh
# Desc: Perform Index Coalesce - Non-System Users
# Runs: Four Times per Month = 0 0 1,8,15,22 * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select 'alter index '||owner||'.'||index_name||' coalesce;'
from all_indexes
where owner not in ('SYS','SYSTEM','DBSNMP','OUTLN')
  and tablespace_name != 'SYSTEM'
  and index_type <> 'IOT - TOP'
order by owner, table_name, index_name;
spool off
$TJS_SQL_SET2
@$TJS_TMP_FILE
EOF
TJS_RETURN_CODE=$?

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh