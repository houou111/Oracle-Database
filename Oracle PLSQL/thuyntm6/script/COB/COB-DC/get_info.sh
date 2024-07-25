#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=cobr14dc1

datetime=`date +%Y%m%d`
LOG_NAME=getinfo_$datetime.log
PATH_NAME=/home/oracle/R14SCRIPT/OPENCOB
LOG_FILE=$PATH_NAME/$LOG_NAME
find $PATH_NAME -mtime +10 -name "getinfo_*.log" -exec rm {} \;

sqlplus -s "/ as sysdba" <<EOF
set lines 200
spool $LOG_FILE 
prompt ++++++++++++++++++++COBR14 - DR ++++++++++++++++++++
prompt ++++++++++++++++++++Last sequence recieved from MIRROR and applied on COBR14 - DR ++++++++++++++++++++

SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "LAST SEQUENCE RECEIVED_(2)", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#)
 "DIFFERENCE_(3)"
FROM
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\$ARCHIVED_LOG  order by FIRST_TIME desc) 
   WHERE ROWNUM<15    --WHERE ROWNUM<150
  )
 GROUP BY THREAD# 
 ORDER BY 1 DESC) ARCH,
(select MAX(SEQUENCE#) SEQUENCE#, THREAD# 
 from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\$LOG_HISTORY  order by FIRST_TIME desc) 
   WHERE ROWNUM<50    --WHERE ROWNUM<150
  )   
 GROUP BY THREAD# 
 ORDER BY 1 DESC) APPL
WHERE ARCH.THREAD# = APPL.THREAD# ORDER BY 2 desc;

prompt ++++++++++++++++++++Check for gap at standby ++++++++++++++++++++
SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V\$ARCHIVE_GAP;
select open_mode, database_role from v\$database;

prompt ++++++++++++++++++++Sync time at standby ++++++++++++++++++++
select to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "SYNC Time" from v\$recovery_progress
 where start_time=(select max(start_time) from v\$recovery_progress);
spool off
exit
EOF

export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=t24r14dc1
sqlplus -s "/ as sysdba" <<EOF
set lines 200
spool $LOG_FILE append 
prompt ++++++++++++++++++++T24 - DR ++++++++++++++++++++
select to_char(sysdate,'dd-mon-yyyy hh24:mi:ss') as NGAY_HE_THONG from dual;
prompt ++++++++++++++++++++T24LIVE sequence generated ++++++++++++++++++++
select MAX(SEQUENCE#) "LAST SEQUENCE GENERATED_(1)", THREAD# 
from 
  (select distinct SEQUENCE# , THREAD# 
   from (select THREAD#,SEQUENCE# from  V\$ARCHIVED_LOG  order by FIRST_TIME desc) 
    WHERE ROWNUM<50
  )
GROUP BY THREAD# 
ORDER BY 1 DESC;
SELECT 'mirror '||lower(open_mode) as mirror_status from v\$database;
spool off
exit;
EOF

echo 'Check done!' >>$LOG_FILE