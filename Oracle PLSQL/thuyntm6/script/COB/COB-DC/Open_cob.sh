#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

datetime=`date +%Y%m%d`
LOG_NAME=opencob_$datetime.log
PATH_NAME=/home/oracle/R14SCRIPT/OPENCOB
LOG_FILE=$PATH_NAME/$LOG_NAME
find $PATH_NAME -mtime +10 -name "opencob_*.log" -exec rm {} \;

###### CHECK FLAG TO OPEN POSTCOB
while [  "$((`date +%H%M%S`))" -lt "090000" ]; do
FLAG1=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select count(1) from t24live.f_batch t 
where  NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='R999'
and NVL (t24live.NUMCAST (EXTRACTVALUE (t.XMLRECORD, '/row/c3')), 0) =1;
exit;
EOF`
FLAG=`echo $FLAG1 | sed -e 's/^[[:space:]]*//'`
if [ "$FLAG" == "1" ]
then 
open_time=`date +%d/%m/%y:%T`
echo 'OPEN POSTCOB TIME: '$open_time >>$LOG_FILE
break
fi
if [ "$FLAG" == "0" ]
then
echo sleep to wait open condition>>$LOG_FILE
sleep 60
fi
done

if [  "$((`date +%H%M%S`))" -gt "093000"]
then
break
fi

###### GET INFO
nohup sh $PATH_NAME/get_info.sh 2>&1 &

###### CHECK SYNC BEFORE OPEN COB
while [  "$((`date +%H%M%S`))" -lt "090000" ]; do
SYNC1=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
SELECT count(*)
FROM
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\\$ARCHIVED_LOG  order by FIRST_TIME desc) 
   WHERE ROWNUM<15    --WHERE ROWNUM<150
  )
 GROUP BY THREAD# 
 ORDER BY 1 DESC) ARCH,
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\\$LOG_HISTORY  order by FIRST_TIME desc) 
   WHERE ROWNUM<50    --WHERE ROWNUM<150
  )   
 GROUP BY THREAD# 
 ORDER BY 1 DESC) APPL
WHERE ARCH.THREAD# = APPL.THREAD# 
and ARCH.SEQUENCE# =APPL.SEQUENCE#;
exit;
EOF`
SYNC2=`echo $SYNC1 | sed -e 's/^[[:space:]]*//'`

if [ "$SYNC2" == "2" ]
then 
open_time=`date +%d/%m/%y:%T`
echo 'OPEN POSTCOB TIME: '$open_time >>$LOG_FILE
break
else
echo sleep to wait sync >>$LOG_FILE
sleep 60
fi
done

###### CANCEL SYNC & CONVERT TO SNAPSHOT STB
sqlplus -s  / as sysdba <<EOF
spool  $LOG_FILE append 
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
spool off
exit;
EOF

STOP_SYNC=`sed 'x;$!d' < $LOG_FILE`

if [ "$STOP_SYNC" == "Database altered." ]
then

start_time=`date +%s`
echo $start_time > $PATH_NAME/time.txt
nohup sh $PATH_NAME/check_convert.sh 2>&1 &

sqlplus -s  / as sysdba <<EOF
spool  $LOG_FILE append 
alter database convert to snapshot standby;
spool off
exit;
EOF

CONVERT=`sed 'x;$!d' < $LOG_FILE`

###### CHECK ROLE OF DATABASE AND OPEN
if [ "$CONVERT" = "Database altered." ] 
then 

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
shutdown immediate;
spool off
exit
EOF

sh $PATH_NAME/start_db.sh  $LOG_FILE 
fi

else
break
fi
echo 'End of OpenCOB.'