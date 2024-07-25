#!/bin/sh

#-------------------------------------------------------
# File: database_shutdown.sh
# Desc: Perform Database Shutdown - Immediate
# Runs: Noon Every Sunday = 0 12 * * 0
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  09/24/2002  Added svrmgr stop on error
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

if [ "$ORACLE_VERS" = "9.0" -o "$ORACLE_VERS" = "9.2" ]
then
  $ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_SYSDBA_UID/$ORACLE_SYSDBA_UPW as sysdba
WHENEVER SQLERROR EXIT FAILURE
shutdown immediate
EOF
else
  $ORACLE_HOME/bin/svrmgrl <<EOF
connect internal
SET STOPONERROR ON
shutdown immediate
EOF
fi
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh