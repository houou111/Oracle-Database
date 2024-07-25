#!/bin/sh

#-------------------------------------------------------
# File: database_backup_cold.sh
# Desc: Perform Database Backup - Cold
# Runs: Midnight Every Sunday = 0 0 * * 0
# Parm: 1 - Destination Directory
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added \ for $ table refs
#  1.2  07/12/2002  Removed calls to startup/shutdown
#                   scripts and instead included them
#  1.3  07/12/2002  Added whenever sqlerror
#  1.4  08/08/2002  Fixed bug for cp failures
#  1.5  08/08/2002  Added redirect to /dev/null
#  1.6  08/08/2002  Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.7  08/09/2002  Fixed bug where cp -v not supported
#  1.8  08/27/2002  Fixed bug export return code in loop
#  1.9  09/24/2002  Fixed bug handle svrmgr return code
#-------------------------------------------------------

if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` DESTINATION_DIRECTORY"
  exit 1
fi

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s > /dev/null <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET1
spool $TJS_TMP_FILE
-- Backup the tablespace data files
select 'cp -f '||file_name||' $1'
from dba_data_files;
-- Backup the database redo log files
select 'cp -f '||member||' $1'
from v\$logfile;
-- Backup the database control files
select 'cp -f '||name||' $1'
from v\$controlfile;
spool off
EOF
TJS_RETURN_CODE=$?

if [ $TJS_RETURN_CODE -eq 0 ]
then
# Shutdown the database
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
fi

# Run the generated cold backup script
if [ $TJS_RETURN_CODE -eq 0 ]
then
echo
echo "Copying Database Files to Backup Directory ..."
echo "=============================================="
cat $TJS_TMP_FILE | while read line
do
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    echo "$line"
    $line
    TJS_RETURN_CODE=$?
    export TJS_RETURN_CODE
  fi
done
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
# Startup the database
if [ "$ORACLE_VERS" = "9.0" -o "$ORACLE_VERS" = "9.2" ]
then
  $ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_SYSDBA_UID/$ORACLE_SYSDBA_UPW as sysdba
WHENEVER SQLERROR EXIT FAILURE
startup
EOF
else
  $ORACLE_HOME/bin/svrmgrl <<EOF
connect internal
SET STOPONERROR ON
startup
EOF
fi
TJS_RETURN_CODE=$?
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh