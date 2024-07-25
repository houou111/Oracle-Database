#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

LOG_FILE=$1

CHK=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
EOF`

if [ "$CHK" == "SNAPSHOT STANDBY" ]
then

sqlplus -s "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown immediate;
spool off
exit
EOF

STOP_CK=`sed '$!d' < $LOG_FILE`
if [ "$STOP_CK" == "ORACLE instance shut down." ]
then 
echo 'SHUTDOWN COMPLETED TIME: '`date +%d/%m/%y:%T`>>$LOG_FILE

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
Startup mount;
spool off
exit
EOF
echo 'MOUNT COMPLETED TIME: '`date +%d/%m/%y:%T`>>$LOG_FILE

###### Convert to physical standby
sqlplus -s  / as sysdba <<EOF
spool  $LOG_FILE append 
alter database convert to physical standby;
spool off
exit;
EOF
TO_STB=`sed 'x;$!d' < $LOG_FILE`

if [ "$TO_STB" == "Database altered." ]
then
echo 'CONVERT TO PHYSICAL STB TIME: '`date +%d/%m/%y:%T`>>$LOG_FILE
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown immediate;
startup mount;
alter database open read only;
alter database recover managed standby database using current logfile disconnect;
spool off
exit
EOF
echo 'CLOSE COB DONE TIME: '`date +%d/%m/%y:%T`>>$LOG_FILE
fi

fi

fi