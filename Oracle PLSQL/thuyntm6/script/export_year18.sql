#!/bin/bash
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=monthend1 

datetime=`date +%Y%m%d`
ORA_LOG=/testcob/year18/export_yearend_${datetime}.log
echo > $ORA_LOG

###### CHECK FLAG TO EXPORT YEAREND
while [  `date +%H%M%S` -lt "160000" ]; do
DAT=`sqlplus -s  / as sysdba <<EOF
set pagesize 0 linesize 32 feedback off verify off heading off
select substr(EXTRACT(t.XMLRECORD,'/row/c13'),6,8) from t24live.f_batch t 
where  NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='R999';
exit;
EOF`

if [ "$DAT" == "20181231" ]
then 
echo 'Export start time: '`date +%Y%m%d:%R` >>$ORA_LOG
break
else
echo sleep >>$ORA_LOG
sleep 300
fi
done


expdp thuyntm_dba/Minhthuy567 DIRECTORY=YEAREND Schemas=t24live dumpfile=remain%u.dmp logfile=remain.log exclude=statistics,index,CONSTRAINT  parallel=8  exclude=TABLE:\"IN\(\'FBNK_STMT_PRINTED\',\'FBNK_STMT_ENTRY\',\'F_ENQUIRY_SELECT\',\'FBNK_ACCOUNT\',\'FBNK_MM_M000\',\'FBNK_PM_TRAN_ACTIVITY\',\'FBNK_FUNDS_TRANSFER#HIS\',\'FBNK_STMT_ACCT_CR\',\'FBNK_AI_USER_LOG\',\'FBNK_RE_C018\',\'FBNK_EB_C005\',\'FBNK_CATEG_ENTRY\',\'FBNK_ACCT_ACTIVITY\',\'FBNK_DEPO_WITHDRA\',\'FBNK_RE_CONSOL_PROFIT\',\'FBNK_RE_C017\',\'F_ATM_REVERSAL\',\'FBNK_RE_C019\',\'F_DC_NEW_003\',\'F_DE_O_HANDOFF\',\'FBNK_ACCOUNT#HIS\',\'F_ENQUIRY_SELECT_INI\',\'FBNK_INFO_CARD\'\)\"
 
expdp thuyntm_dba/Minhthuy567 DIRECTORY=YEAREND dumpfile=big_table%u.dmp logfile=big_table.log exclude=statistics,index,CONSTRAINT  parallel=8  tables=T24LIVE.FBNK_STMT_PRINTED,T24LIVE.FBNK_STMT_ENTRY,T24LIVE.F_ENQUIRY_SELECT,T24LIVE.FBNK_ACCOUNT,T24LIVE.FBNK_MM_M000,T24LIVE.FBNK_PM_TRAN_ACTIVITY,T24LIVE.FBNK_FUNDS_TRANSFER#HIS,T24LIVE.FBNK_STMT_ACCT_CR,T24LIVE.FBNK_AI_USER_LOG,T24LIVE.FBNK_RE_C018,T24LIVE.FBNK_EB_C005,T24LIVE.FBNK_CATEG_ENTRY,T24LIVE.FBNK_ACCT_ACTIVITY,T24LIVE.FBNK_DEPO_WITHDRA,T24LIVE.FBNK_RE_CONSOL_PROFIT,T24LIVE.FBNK_RE_C017,T24LIVE.F_ATM_REVERSAL,T24LIVE.FBNK_RE_C019,T24LIVE.F_DC_NEW_003,T24LIVE.F_DE_O_HANDOFF,T24LIVE.FBNK_ACCOUNT#HIS,T24LIVE.F_ENQUIRY_SELECT_INI,T24LIVE.FBNK_INFO_CARD

echo 'Export finish time: '`date +%Y%m%d:%R` >>$ORA_LOG