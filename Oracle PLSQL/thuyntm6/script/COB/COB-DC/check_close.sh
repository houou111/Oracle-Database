#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

datetime=`date +%Y%m%d`
LOG_NAME=checkclose_$datetime.log
PATH_NAME=/home/oracle/R14SCRIPT/CLOSECOB
LOG_FILE=$PATH_NAME/log/$LOG_NAME
find $PATH_NAME/log -mtime +10 -name "checkclose_*.log" -exec rm {} \;
CLOSE_LOG=$1

sleep 300
CHECK1=`more $CLOSE_LOG|grep "SHUTDOWN COMPLETED TIME:" |wc -l| sed -e 's/^[[:space:]]*//'`

CHECK2=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
EOF`

if [ "$CHECK1" = "0" -o "$CHECK2" == "SNAPSHOT STANDBY" ]
then
echo 'STOP FORCE AND CONVERT TO STB: '`date +%d/%m/%y:%T`>>$LOG_FILE
sqlplus -s  / as sysdba <<EOF
spool  $LOG_FILE append 
shutdown abort;
startup mount;
alter database convert to physical standby;
shutdown immediate;
startup mount;
alter database open read only;
alter database recover managed standby database using current logfile disconnect;
spool off
exit;
EOF
else
echo 'Already physical standby!'>>$LOG_FILE
break
fi