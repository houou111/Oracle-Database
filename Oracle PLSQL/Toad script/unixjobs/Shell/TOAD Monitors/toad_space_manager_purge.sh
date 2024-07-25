#!/bin/sh

#-------------------------------------------------------
# File: toad_space_manager_purge.sh
# Desc: Perform Purge of TOAD Space Manager Data
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Keep data up to N days (default 180)
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
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
set verify off
set echo on
DELETE FROM TOAD_TABLESPACES WHERE TRUNC(MON_DATE) < TRUNC(SYSDATE) - $TJS_KEEP;
COMMIT;
EOF

. $TJS_DIR/tjs_stop_log.sh