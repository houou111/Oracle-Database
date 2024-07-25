set time on
set lines 200

prompt ++++++++++++++++++++ OPEN POSTCOB-DR REPORT  ++++++++++++++++++++++++++
recover managed standby database cancel;
alter database convert to snapshot standby;
shutdown immediate;
startup mount;
--alter database flashback on; 
alter database open;
alter system set events = '31156 trace name context forever, level 0x400';
select open_mode, database_role from v$database;
set timing on;
set echo on;
set heading on;
create table T24LIVE.COB_STATUS_TCB (id number, status varchar2(255), datetime_created date);
insert into T24LIVE.COB_STATUS_TCB values (1,'open postcob read - write', SYSDATE);
commit;
alter system set events = '31156 trace name context forever, level 0x400';
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_NEW;
grant execute on dbms_crypto to T24_LIVE_DWH;

select open_mode, database_role from v$database;
exit

DELETE FORCE NOPROMPT archivelog all completed before "to_date(to_char(sysdate-1/2,'dd/mm/yyyy')||' 18:00','dd/mm/yyyy hh24:mi')";

<row id='BNK/REPORT.PRINT.REPORTING' xml:space='preserve'><c1>R999</c1><c3>2</c3><c4>F</c4><c6>CLEARE.REPORT.TCB</c6><c6 m='2'>EB.EOD.REPORT.PRINT</c6><c6 m='3'>BATCH.HALT</c6><c7 m='2'>CLEARE.REPORT.TCB</c7><c7 m='3'></c7><c8>D</c8><c8 m='2'>D</c8><c8 m='3'>D</c8><c9 m='3'></c9><c10 m='3'></c10><c11 m='3'></c11><c12>2</c12><c12 m='2'>2</c12><c12 m='3'>2</c12><c13>20170606</c13><c13 m='2'>20170606</c13><c13 m='3'>20170606</c13><c14 m='3'></c14><c15 m='3'></c15><c16 m='3'></c16><c28>71</c28><c29>52683_DUONG01.1071_I_INAU</c29><c30>1705110211</c30><c30 m='2'>1705110211</c30><c31>52683_DUONG01.1071</c31><c32>VN0010001</c32><c33>297</c33></row>
------------------================================================================================
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.___.2016____.%'
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where recid like '%#___#2016____'
delete T24LIVE.FBNK_EB_B005 t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c2'),'^A') <=20161231
delete T24LIVE.FBNK_QUAN014 t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c6'),'^A')<='20161231'
delete T24LIVE.FBNK_OD_ACCT_ACTIVITY where recid like '______________-2016%'
delete T24LIVE.FBNK_FTBULK_TCB#HIS where recid like 'BC16%'
delete T24LIVE.F_FTBULK_000 where recid like 'BC16%'
delete T24LIVE.F_FTBULK_CONTROL_TCB where recid like 'BC16%'
delete T24LIVE.FBNK_FTBU000 where recid like 'BC16%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'FT160%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'DC160%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'TT160%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'TT161%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'DC161%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'FT161%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'FT162%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'TT162%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'DC162%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'DC163%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'TT163%'
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where recid like 'FT163%'
delete T24LIVE.FBNK_AI_USER_LOG where recid like '%.LOGOUT.2016%'
delete T24LIVE.FBNK_AI_USER_LOG where recid like '%.ENQUIRY.2016%'
delete T24LIVE.FBNK_AI_USER_LOG where recid like '%.APPLICATION.2016%'
delete T24LIVE.FBNK_AI_USER_LOG where recid like '%.CHANGEPASS.2016%'
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where recid like '%.VN001____.___.2016%'
delete T24LIVE.FBNK_AI_CORP_TXN_LOG where recid like 'FT160%'
delete T24LIVE.FBNK_AI_CORP_TXN_LOG where recid like 'FT161%'
delete T24LIVE.FBNK_AI_CORP_TXN_LOG where recid like 'FT162%'
delete T24LIVE.FBNK_AI_CORP_TXN_LOG where recid like 'FT163%'
delete T24LIVE.F_DE_O_HANDOFF where recid like 'D2016%'
delete T24LIVE.F_DE_O_HEADER where recid like 'D2016%'
delete T24LIVE.F_DE_O_REPAIR where recid like 'D2016%'
delete T24LIVE.F_DE_O_MSG_ADVICE where recid like 'D2016%'
delete T24LIVE.FBNK_TXN_LOG_TCB where recid like '/2016%'
delete T24LIVE.FBNK_DEPO_WITHDRA t WHERE NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c29'),'')<'20160901'
delete T24LIVE.F_LCR_AUTO_WRK_TCB where recid like '16%'
delete T24LIVE.FBNK_SUM_DENO_TCB t WHERE NVL(T24LIVE.NUMCAST(EXTRACTVALUE(t.XMLRECORD,'/row/c16')),0)<20160901
------------------================================================================================
------------------================================================================================
start_ts=`date +%s`
plus=$start_ts + 20
sleep 10
end_ts=`date +%s`
let "duration = $end_ts - $start_ts"
-----

#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/11.2.0.4/database/product/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=esbdata1
datetime=`date +%Y%m%d`
LOG_NAME=opencob_$datetime.log
LOG_FILE=/home/oracle/thuyntm/$LOG_NAME
find /home/oracle/thuyntm -mtime +10 -name "opencob_*.log" -exec rm {} \;

################## CHECK FLAG TO OPEN POSTCOB ##################
while [  $((`date +%H%M%S`)) -lt "114000" ]; do
FLAG=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select stat from thuyntm_dba.status;
exit;
EOF`
echo 'Flag:'$FLAG
if [ "$FLAG" == "1" ]
then 
open_time=`date +%d/%m/%y:%T`
echo 'OPEN POSTCOB TIME: '$open_time >$LOG_FILE
break
fi
if [ "$FLAG" == "" ]
then
echo sleep
sleep 60
fi
done
echo $((`date +%H%M%S`))
sh /home/oracle/thuyntm/getstate.sh &
echo $((`date +%H%M%S`))
################## CANCEL SYNC & CONVERT TO SNAPSHOT STB ##################
#recover managed standby database cancel;
STOP_SYNC=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select stat from thuyntm_dba.status;
exit;
EOF`

if [ "$STOP_SYNC" == "1" ]
#"Media recovery complete." ]
then
sh /home/oracle/thuyntm/convert_sequential.sh &
sh /home/oracle/thuyntm/convert_error.sh &
fi

echo 'done'

-------
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/11.2.0.4/database/product/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=esbdata1
datetime=`date +%Y%m%d`
LOG_NAME=opencob_$datetime.log
LOG_FILE=/home/oracle/thuyntm/$LOG_NAME

#alter database convert to snapshot standby;
sqlplus  "/ as sysdba" <<EOF
set time on
set timing on
spool  $LOG_FILE append
select 'Convert to snapshot time: '||sysdate  as time from dual;
alter system archive log current;
spool off
exit
EOF


################## CHECK ROLE OF DATABASE AND OPEN ##################
#shutdown immediate;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
spool off
exit
EOF

#startup mount;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
spool off
exit
EOF

SNAPSHOT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
exit;
EOF`


if [ "$SNAPSHOT" == "PRIMARY" ]
#"SNAPSHOT STANDBY" ]
then 

#alter database convert to snapshot standby;
sqlplus  "/ as sysdba" <<EOF
spool  /home/oracle/thuyntm/convert2snap.log 
select 'Convert to snapshot time: '||sysdate  as time from dual;
alter system archive log current;
spool off
exit
EOF
fi


#alter database open;
#alter system set events = '31156 trace name context forever, level 0x400';
#create table T24LIVE.COB_STATUS_TCB (id number, status varchar2(255), datetime_created date);
#insert into T24LIVE.COB_STATUS_TCB values (1,'open postcob read - write', SYSDATE);
#commit;
#alter system set events = '31156 trace name context forever, level 0x400';
#ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP;
#grant execute on dbms_crypto to T24_LIVE_DWH;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
select sysdate from dual;
spool off
exit
EOF

--------------
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/11.2.0.4/database/product/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=esbdata1
datetime=`date +%Y%m%d`
LOG_NAME=opencob_snaperror_$datetime.log
LOG_FILE=/home/oracle/thuyntm/$LOG_NAME

sleep 240



################## CHECK ROLE OF DATABASE AND OPEN ##################
#shutdown immediate;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
spool off
exit
EOF

#startup mount;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
spool off
exit
EOF

SNAPSHOT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select database_role from v\\$database;
exit;
EOF`


if [ "$SNAPSHOT" == "PRIMARY" ]
#"SNAPSHOT STANDBY" ]
then 
#alter database convert to snapshot standby;
sqlplus  "/ as sysdba" <<EOF
spool  /home/oracle/thuyntm/convert2snap.log 
select 'Convert to snapshot time: '||sysdate  as time from dual;
alter system archive log current;
spool off
exit
EOF
fi


#alter database open;
#alter system set events = '31156 trace name context forever, level 0x400';
#create table T24LIVE.COB_STATUS_TCB (id number, status varchar2(255), datetime_created date);
#insert into T24LIVE.COB_STATUS_TCB values (1,'open postcob read - write', SYSDATE);
#commit;
#alter system set events = '31156 trace name context forever, level 0x400';
#ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP;
#grant execute on dbms_crypto to T24_LIVE_DWH;
sqlplus  "/ as sysdba" <<EOF
spool  $LOG_FILE append
select sysdate from dual;
select sysdate from dual;
spool off
exit
EOF

------------------================================================================================
------------------================================================================================
------------------================================================================================
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/11.2.0.4/database/product/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=esbdata1
datetime=`date +%Y%m%d`
LOG_NAME=check_$datetime.txt
LOG_FILE=/home/oracle/thuyntm/$LOG_NAME

sqlplus "/ as sysdba" <<EOF
spool $LOG_FILE 
prompt ++++++++++++++++++++COBR14 - DR ++++++++++++++++++++
prompt ++++++++++++++++++++Last sequence recieved from MIRROR and applied on COBR14 - DR ++++++++++++++++++++

SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "LAST SEQUENCE RECEIVED_(2)", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#) "DIFFERENCE_(3)"
FROM
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$ARCHIVED_LOG  order by FIRST_TIME desc) 
   WHERE ROWNUM<15    --WHERE ROWNUM<150
  )
 GROUP BY THREAD# 
 ORDER BY 1 DESC) ARCH,
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$LOG_HISTORY  order by FIRST_TIME desc) 
   WHERE ROWNUM<50    --WHERE ROWNUM<150
  )   
 GROUP BY THREAD# 
 ORDER BY 1 DESC) APPL
WHERE ARCH.THREAD# = APPL.THREAD# ORDER BY 2 desc;

prompt ++++++++++++++++++++Check for gap at standby ++++++++++++++++++++
SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;
select open_mode, database_role from v$database;

prompt ++++++++++++++++++++Sync time at standby ++++++++++++++++++++
select to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "SYNC Time" from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress);
spool off
exit
EOF

export ORACLE_SID=esbinf31
sqlplus "/ as sysdba" <<EOF
spool $LOG_FILE 
prompt ++++++++++++++++++++T24 - DR ++++++++++++++++++++
select to_char(sysdate,'dd-mon-yyyy hh24:mi:ss') as NGAY_HE_THONG from dual;
prompt ++++++++++++++++++++T24LIVE sequence generated ++++++++++++++++++++
select MAX(SEQUENCE#) "LAST SEQUENCE GENERATED_(1)", THREAD# 
from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$ARCHIVED_LOG  order by FIRST_TIME desc) 
    WHERE ROWNUM<50
  )
GROUP BY THREAD# 
ORDER BY 1 DESC;
SELECT 'mirror '||lower(open_mode) as mirror_status from v$database;
--SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;
spool off
exit;
EOF

echo 'done'

------------------================================================================================
------------------================================================================================
------------------================================================================================

hour=`date +%H%M%S` 
 
#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/11.2.0.4/database/product/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=esbdata1
LOG_FILE=/home/oracle/thuyntm/log.txt

while [  $((`date +%H%M%S`)) -lt "163000" ]; do
now=`date +%T`
echo $now

sqlplus -s  "/ as sysdba" <<EOF
spool $LOG_FILE
select stat from thuyntm_dba.status;
spool off
exit
EOF

CHECK=`tail -2 /home/oracle/thuyntm/log.txt|head -1`




if [ $CHECK == 1 ]
then 
prompt ++++++++++++++++++++++++++++++++ CHECK MEET THE NEED TO OPEN POSTCOB_DR +++++++++++++++++++++++++++++++++++++
echo 'Time: ' `date +%H%M%S`
break
fi
sleep 60 
done



echo '+++++++++++++++++++++++++++++++CHECK SYNC +++++++++++++++++++++++++++++++++++++++++++'
DIFF=`sqlplus -s "/ as sysdba " <<EOF
SELECT count(*)
    FROM (  SELECT MAX (SEQUENCE#) SEQUENCE#, THREAD#
              FROM (SELECT DISTINCT SEQUENCE#, THREAD#
                      FROM (  SELECT THREAD#, SEQUENCE#  FROM V\$ARCHIVED_LOG  ORDER BY FIRST_TIME DESC)
                     WHERE ROWNUM < 15)
          GROUP BY THREAD#
          ORDER BY 1 DESC) ARCH,
         (  SELECT MAX (SEQUENCE#) SEQUENCE#, THREAD#
              FROM (SELECT DISTINCT SEQUENCE#, THREAD#  FROM (  SELECT THREAD#, SEQUENCE#  FROM V\$LOG_HISTORY ORDER BY FIRST_TIME DESC)
                     WHERE ROWNUM < 50)
          GROUP BY THREAD#
          ORDER BY 1 DESC) APPL
   WHERE ARCH.THREAD# = APPL.THREAD#
   AND ARCH.SEQUENCE# - APPL.SEQUENCE# <>0;
exit
EOF`


export ORACLE_SID=t24r14dr
sqlplus "/ as sysdba"  <<EOF
set time on
set lines 50
spool /home/oracle/R14SCRIPT/R14POSTCOB/DG_KETQUA.out

select to_char(sysdate,'dd-mon-yyyy hh24:mi:ss') as NGAY_HE_THONG from dual;
prompt ++- T24 R14 2016 -  LIVE SEQUENCE GENERATED++++++++++++++++++
select MAX(SEQUENCE#) "LAST SEQUENCE GENERATED_(1)", THREAD# 
from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$ARCHIVED_LOG  order by FIRST_TIME desc) 
    WHERE ROWNUM<50
  )
GROUP BY THREAD# 
ORDER BY 1 DESC;
SELECT 'mirror '||lower(open_mode) as mirror_status from v$database;
spool off
exit
EOF

export ORACLE_SID=cobr14dr
sqlplus "/ as sysdba"  <<EOF
set time on
set lines 200

prompt ++++++++++++++++++++LAST SEQUENCE RECIEVED from MIRROR and applied on COBR14 - DR +++++++++++++++++++++++++

SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "LAST SEQUENCE RECEIVED_(2)", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#)
 "DIFFERENCE_(3)"
FROM
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$ARCHIVED_LOG  order by FIRST_TIME desc) 
   --WHERE ROWNUM<150
   WHERE ROWNUM<15
  )
 GROUP BY THREAD# 
 ORDER BY 1 DESC) ARCH,
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V$LOG_HISTORY  order by FIRST_TIME desc) 
   --WHERE ROWNUM<150
   WHERE ROWNUM<50
  )   
 GROUP BY THREAD# 
 ORDER BY 1 DESC) APPL
WHERE ARCH.THREAD# = APPL.THREAD# ORDER BY 2 desc;

prompt ++++++++++++++++++++CHECK FOR GAP AT STANDBY+++++++++++++++++++++++++

SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;
select open_mode, database_role from v$database;
prompt ++++++++++++++++++++SYNC TIME AT STANDBY+++++++++++++++++++++++++
select to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "SYNC Time" from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress);
exit
EOF