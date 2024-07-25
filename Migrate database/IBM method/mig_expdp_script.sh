export ORACLE_SID=$1
export EXP_BKP_DIR=/stage/dump
export PARALLEL_THREADS=1

mkdir -p ${EXP_BKP_DIR}/${ORACLE_SID}
export DT=`date +%d%b%y_%H%M`
export CREATE_DIR_LOG=${EXP_BKP_DIR}/${ORACLE_SID}/expdp_${ORACLE_SID}_cr_dir.log

sqlplus -s "/ as sysdba" <<EOF >> ${CREATE_DIR_LOG}
WHENEVER SQLERROR EXIT SQL.SQLCODE
col WRL_PARAMETER for a80
col Dir_Path for a120
set lines 300 pages 50000
select to_char(sysdate,'DD-MON-YY HH24:MI:SS') sdate from dual;
create or replace directory ibmexpdir as '${EXP_BKP_DIR}/${ORACLE_SID}';
select directory_name || ' => ' || directory_path Dir_Path from dba_directories where directory_name='IBMEXPDIR';
select * from v\$encryption_wallet;
exit;
EOF

expdp "'/ as sysdba'" DIRECTORY=ibmexpdir DUMPFILE=expdp_${ORACLE_SID}_%U.dmp \
LOGFILE=expdp_${ORACLE_SID}.log PARALLEL=${PARALLEL_THREADS} CONTENT=ALL CLUSTER=N FULL=Y EXCLUDE=STATISTICS,INDEX_STATISTICS reuse_dumpfiles=true \
EXCLUDE=SCHEMA:\"IN \(\'SYS\', \'SYSTEM\', \'SYSAUX\'\,\'ORDDATA\',\'SYSMAN\',\'APEX_030200\'\,\'OWBSYS_AUDIT\',\'OUTLN\',\'OWBSYS\',\'SCOTT\',\
\'FLOWS_FILES\',\'OE\'\,\'OLAPSYS\',\'MDDATA\',\'SPATIAL_WFS_ADMIN_USR\',\'SPATIAL_CSW_ADMIN_USR\',\'MGMT_VIEW\',\'APEX_PUBLIC_USER\'\)\"

echo "Script execution ended   at : `date`" >> ${CREATE_DIR_LOG}
