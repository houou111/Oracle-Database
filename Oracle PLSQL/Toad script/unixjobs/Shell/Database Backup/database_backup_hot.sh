#!/bin/sh

#-------------------------------------------------------
# File: database_backup_hot.sh
# Desc: Perform Database Backup - Hot
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: 1 - Destination Directory
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added \ for $ table refs
#  1.2  07/12/2002  Added whenever sqlerror
#  1.3  08/08/2002  Fixed bug for cp failures
#  1.4  08/08/2002  Added redirect to /dev/null
#  1.5  08/08/2002  Added Added TJS_SQL_SET1 and TJS_SQL_SET2
#  1.6  08/09/2002  Fixed bug where cp -v not supported
#  1.7  08/24/2002  Fixed bug where missing quoted filename
#  1.8  08/27/2002  Fixed bug export return code in loop
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
COLUMN sep NOPRINT new_value sep
SELECT decode(instr(file_name,'\'),0,'/','\') sep
 from dba_data_files
 where tablespace_name='SYSTEM'
   and rownum=1;
column dummy1 noprint
column dummy2 noprint
COLUMN cur_log NOPRINT new_value cur_log
spool $TJS_TMP_FILE
-- Backup the tablespace data files
select 1 dummy1, tablespace_name dummy2, 'alter tablespace '||tablespace_name||' begin backup;'
  from dba_tablespaces
where status = 'ONLINE'
  and contents = 'PERMANENT'
union
select 2 dummy1, tablespace_name dummy2, 'cp -f '||file_name||' $1'
from dba_data_files
union
select 3 dummy1, tablespace_name dummy2, 'alter tablespace '||tablespace_name||' end backup;'
  from dba_tablespaces
where status = 'ONLINE'
  and contents = 'PERMANENT'
order by dummy2, dummy1;
-- Backup the database redo log files
select group# cur_log
from v\$log
where status = 'CURRENT';
select 'cp -f '||member||' $1'
from v\$logfile
where group# != &cur_log;
select 'alter system switch logfile;'
from dual;
select 'cp -f '||member||' $1'
from v\$logfile
where group# = &cur_log;
-- Backup the database control files
select 'alter database backup controlfile to '''||'$1/'||substr(name,instr(name,'&sep',-1,1)+1)||''' reuse;'
from v\$controlfile;
spool off
EOF
TJS_RETURN_CODE=$?

if [ $TJS_RETURN_CODE -eq 0 ]
then
# Run the generated hot backup script
cat $TJS_TMP_FILE | while read line
do
  if [ $TJS_RETURN_CODE -eq 0 ]
  then
    cmd=`echo $line | cut -d' ' -f1`
    if [ "$cmd" = "cp" ]
    then
      echo "$line"
      $line
    elif [ "$cmd" = "alter" ]
    then
$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_DBA_UID/$ORACLE_DBA_UPW
WHENEVER SQLERROR EXIT FAILURE
$line
EOF
    fi
    TJS_RETURN_CODE=$?
    export TJS_RETURN_CODE
  fi
done
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh