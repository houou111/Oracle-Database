#!/bin/sh

#-------------------------------------------------------
# File: coalesce_tablespace.sh
# Desc: Perform Coalesce of All Tablesapaces
# Runs: Four Times per Day = 0 0,6,12,18 * * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET1 and TJS_SQL_SET2
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
select 'alter tablespace '||tablespace_name||' coalesce;'
  from dba_tablespaces
 where status = 'ONLINE'
   and contents not in ('TEMPORARY','UNDO');
$TJS_SQL_SET2
@$TJS_TMP_FILE
EOF
TJS_RETURN_CODE=$?

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh