#!/bin/sh

#-------------------------------------------------------
# File: flush_shared_pool.sh
# Desc: Perform Flush of Shared Pool Memory
# Runs: Four Times per Day = 0 0,6,12,18 * * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
ALTER SYSTEM FLUSH SHARED_POOL;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh