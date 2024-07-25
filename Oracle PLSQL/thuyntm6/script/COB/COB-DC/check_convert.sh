#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

datetime=`date +%Y%m%d`
LOG_NAME=checkconvert_$datetime.log
PATH_NAME=/home/oracle/R14SCRIPT/OPENCOB
LOG_FILE=$PATH_NAME/$LOG_NAME
find $PATH_NAME -mtime +10 -name "checkconvert_*.log" -exec rm {} \;

start_time=`cat $PATH_NAME/time.txt`
let "end_time = $start_time + 600"

sleep 600

CHECK=`ps -ef|grep ora_pmon_cobr14dc1  |grep -v grep|wc -l| sed -e 's/^[[:space:]]*//'`

if [ "$CHECK" = "0" ]
then
sleep 300
CHECK2=`ps -ef|grep ora_pmon_cobr14dc1  |grep -v grep|wc -l| sed -e 's/^[[:space:]]*//'`

if [ "$CHECK2" == "0" ]
then
sh $PATH_NAME/start_db.sh $LOG_FILE
else
break
fi

else
SNAPSHOT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
exit;
EOF`

if [ "$SNAPSHOT" == "PHYSICAL STANDBY" ]
then 
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown immediate;
spool off
exit
EOF

sh $PATH_NAME/start_db.sh $LOG_FILE
fi
if [ "$SNAPSHOT" == "SNAPSHOT STANDBY" ]
then
echo 'Already in snapshot standby!'
break
fi 
fi

