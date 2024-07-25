#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

LOG_FILE=$1

sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
startup mount;
spool off
exit
EOF

CHECK=`ps -ef|grep ora_pmon_cobr14dc1  |grep -v grep|wc -l| sed -e 's/^[[:space:]]*//'`
if [ "$CHECK" = "0" ] 
then
sleep 180
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
startup mount;
spool off
exit
EOF
fi

SNAPSHOT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
exit;
EOF`

if [ "$SNAPSHOT" == "PHYSICAL STANDBY" ]
then 
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
alter database convert to snapshot standby;
spool off
exit
EOF
fi


sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
alter database open;
alter system set events = '31156 trace name context forever, level 0x400';
create table T24LIVE.COB_STATUS_TCB (id number, status varchar2(255), datetime_created date);
insert into T24LIVE.COB_STATUS_TCB values (1,'open postcob read - write', SYSDATE);
commit;
alter system set events = '31156 trace name context forever, level 0x400';
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP;
grant execute on dbms_crypto to T24_LIVE_DWH;
spool off
exit
EOF

echo 'Start done!' >>$LOG_FILE