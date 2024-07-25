#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/database/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

datetime=`date +%Y%m%d`
LOG_NAME=closecob_$datetime.log
PATH_NAME=/home/oracle/R14SCRIPT/CLOSECOB
LOG_FILE=$PATH_NAME/log/$LOG_NAME
find $PATH_NAME/log -mtime +10 -name "closecob_*.log" -exec rm {} \;

###### CHECK FLAG TO CLOSE POSTCOB
while [  "$((`date +%H%M%S`))" -lt "235900"  -a "$((`date +%H%M%S`))" -gt "180000" ]; do
export ORACLE_SID=t24r14dr
FLAG1=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select count(*) from T24LIVE.F_TIS_DW_CONTROL t where recid='CLOSE.POSTCOB'
and to_date(NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c4'),'^A'),'yyyymmdd')=trunc(sysdate);
exit;
EOF`
FLAG=`echo $FLAG1 | sed -e 's/^[[:space:]]*//'`

if [ "$FLAG" == "1" ]
then 
echo 'MEET THE NEED TO CLOSE POSTCOB TIME: '`date +%d/%m/%y:%T`>>$LOG_FILE
break
fi
if [ "$FLAG" == "0" ]
then
echo 'Sleep to wait close flag'>>$LOG_FILE
sleep 60
fi
done

if [  "$((`date +%H%M%S`))" -lt "180000" ]
then
exit 1
fi

###### Shutdown and startup mount
nohup sh $PATH_NAME/check_close.sh $LOG_FILE 2>&1 &

echo 'SHUTDOWN 1st TIME' >>$LOG_FILE
nohup sh $PATH_NAME/close.sh $LOG_FILE 2>&1 &