#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/database/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

datetime=`date +%Y%m%d`
ORA_LOG=/home/oracle/DBSCRIPT/monthend/rman_monthend_${datetime}.log
GRID_LOG=/home/grid/DBSCRIPT/monthend/rman_monthend_${datetime}.log
echo > $ORA_LOG

###### CHECK FLAG TO CLONE MONTHEND
export ORACLE_SID=cobr14dr
while [  "$((`date +%H%M%S`))" -lt "120000" ]; do
STAT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
exit;
EOF`

if [ "$STAT" == "SNAPSHOT STANDBY" ]
then 
echo 'Clone start time: '`date +%Y%m%d:%R` >>$ORA_LOG
break
fi
if [ "$STAT" == "PHYSICAL STANDBY" ]
then
echo sleep >>$ORA_LOG
sleep 300
fi
done

if [ "$((`date +%H%M%S`))" -ge "120000" ]
then
break 
fi 

###### SHUTDOWN DB MONTHEND
export ORACLE_SID=monthend
sqlplus  "/ as sysdba" <<EOF
spool  $ORA_LOG 
shutdown immediate;
spool off
exit
EOF

CHECK=`ps -ef|grep ora_pmon_monthend  |grep -v grep|wc -l| sed -e 's/^[[:space:]]*//'`
if [ "$CHECK" = "0" ]
then
echo 'Shutdown monthend DB completed!' >>$ORA_LOG
### Wait for drop directory in diskgroup
while [  "$((`date +%H%M%S`))" -lt "120000" ]; do
FLAG=`tail -1 $GRID_LOG`

if [ "$FLAG" == "Drop asm file done!" ]
then 
echo 'DROP COMPLETED TIME: '`date +%Y%m%d:%R` >>$ORA_LOG
break
else
sleep 300
fi
done

if [  "$((`date +%H%M%S`))" -ge "120000" ]
then
break
fi

export ORACLE_SID=monthend
sqlplus  "/ as sysdba" <<EOF
spool  $ORA_LOG append
startup nomount;
spool off
exit
EOF

export ORACLE_SID=cobr14dr
rman TARGET / AUXILIARY thuyntm_dba/Minhthuy90@monthend @/home/oracle/DBSCRIPT/monthend/rman_clone.rcv log /home/oracle/DBSCRIPT/monthend/rman_monthend.log append

echo 'Clone finish time: '`date +%Y%m%d:%R` >>$ORA_LOG
fi