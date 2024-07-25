#!/bin/sh

#-------------------------------------------------------
# File: compile_invalid_schema.sh
# Desc: Perform Compile Invalid - Single Schema
# Runs: Four Times per Month = 0 0 1,8,15,22 * *
# Parm: 1 - Schema to Compile
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Revised to use package to compile
#                   schema rather than comands due to
#                   compile dependency issues
#  1.2  07/12/2002  Added whenever sqlerror
#  1.3  08/08/2002  Added Added TJS_SQL_SET1 and TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` SCHEMA"
  exit 1
fi

TJS_LOG_TRAIL="$1"
export TJS_LOG_TRAIL
. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select 'exec DBMS_UTILITY.COMPILE_SCHEMA('''||username||''');'
from   all_users
where  username not in ('SYS','SYSTEM','DBSNMP','OUTLN')
  and  username = upper('$1')
  and  exists (select 1
               from   all_objects
               where  owner = username
               and object_type in ('FUNCTION','MATERIALIZED VIEW','PACKAGE','PROCEDURE','SNAPSHOT','TRIGGER','VIEW')
               and status = 'INVALID');
spool off
$TJS_SQL_SET2
@$TJS_TMP_FILE
EOF
TJS_RETURN_CODE=$?

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh