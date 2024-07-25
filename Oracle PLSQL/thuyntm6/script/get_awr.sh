#!/bin/ksh
set -vx
## Usage gen_awr.sh <snap_start> <snap_end> <db_id> <inst_id>
sn=$1
sn_end=$2
db_id=$3
inst_id=$4

while [[ ${sn} -lt $2 ]]; do
        sne=`expr ${sn} + 1`;
        echo "sne is $sne "
sqlplus -S "/ as sysdba" << SQL
set feedback off
set lines 200
set serveroutput on size 9999
define  dbid = ${db_id}
        define  inst_num  = ${inst_id}
        define num_days = 0
        define report_type='html'
        define begin_snap = ${sn}
        define end_snap   = ${sne}
      define report_name = 'awrrpt_${inst_id}_${sn}_${sne}.html'
        @$ORACLE_HOME/rdbms/admin/awrrpti.sql
SQL
        sn=`expr ${sn} + 1`;
        echo "value of snap begin is $sn";
done