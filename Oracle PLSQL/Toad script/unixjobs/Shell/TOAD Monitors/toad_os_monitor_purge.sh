#!/bin/sh

#-------------------------------------------------------
# File: toad_os_monitor_purge.sh
# Desc: Perform Purge of TOAD OS Monitor Data
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Keep data up to N days (default 180)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  TJS_KEEP=180
else
  TJS_KEEP=$1
fi

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_TOAD_UID/$ORACLE_TOAD_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
DELETE FROM TOAD_OS_MONITOR WHERE MON_DATE < SYSDATE - $TJS_KEEP;
COMMIT;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh