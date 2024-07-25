#!/bin/bash
export ORACLE_HOME=/u01/app/grid/product/11.2.0.4/grid
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=+ASM

datetime=`date +%Y%m%d`
ORA_LOG=/home/oracle/DBSCRIPT/monthend/rman_monthend_${datetime}.log
GRID_LOG=/home/grid/DBSCRIPT/monthend/rman_monthend_${datetime}.log
echo >$GRID_LOG


### Wait for DB monthend shutdown completed
while [ "$((`date +%H%M%S`))" -lt "120000" ]; do
FLAG=`tail -1 $ORA_LOG`

if [ "$FLAG" == "Shutdown monthend DB completed!" ]
then 
echo 'DROP FILE TIME: '`date +%d/%m/%y:%T` >>$GRID_LOG
asmcmd rm -rf +MONTHEND_DR/MONTHEND/DATAFILE/*
asmcmd rm -rf +MONTHEND_DR/MONTHEND/TEMPFILE/*
asmcmd rm -rf +MONTHEND_DR/MONTHEND/ONLINELOG/*

CHECK=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select trunc ((free_mb/total_mb)*100) from v\\$asm_diskgroup where name='MONTHEND_DR';
exit;
EOF`
CHECK_SZ=`echo $CHECK | sed -e 's/^[[:space:]]*//'`
if [ $CHECK_SZ -gt 90 ]
then
echo 'Drop asm file done!' >>$GRID_LOG
break
else
echo 'Drop asm file failed!'>>$GRID_LOG
break
fi

else 
sleep 300
fi
done

if [  "$((`date +%H%M%S`))" -ge "120000" ] 
then
break
fi