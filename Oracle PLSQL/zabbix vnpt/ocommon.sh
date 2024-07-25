#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

THAMSO=$1

case $2 in

'PING')
	sql="select 'alive' from dual;"
	;;

'PDBWC')
	sql="select trim(ceil(SUM(AVERAGE_WAIT))) as col1 from v\$system_event WHERE WAIT_CLASS='$THAMSO';"
	;;

'DBAINVALIDINDEX')
	sql="select trim(count(*)) AS COL1 from dba_indexes where OWNER like '$THAMSO%' AND STATUS <>'VALID';"
	;;

'RESPONSETIMEPERTXN')
	sql="select trim(round($THAMSO)) AS COL1 from SYS.V_\$SYSMETRIC_SUMMARY where METRIC_NAME='Response Time Per Txn';"
	;;
'RECOVERYAREAUSAGE')
	sql="select trim(round(PERCENT_SPACE_USED)) AS COL1 from V\$RECOVERY_AREA_USAGE where FILE_TYPE='$THAMSO';"
	;;
'CONNECTIONCOUNT')
	sql="select trim(count(*)) as col1 from v\$session where username is not null;"
	;;
'CONNECTIONTOTAL')
	sql="select TRIM(COUNT(*)) as COL1 from DBA_HIST_ACTIVE_SESS_HISTORY;"
	;;
'CONNECTIONSTARTTIME')
	sql="select trim((to_date(to_char(MIN(SAMPLE_TIME),'DD-MM-YYYY HH:MI:SS'),'DD-MM-YYYY HH:MI:SS') -  to_date('01-JAN-1970','DD-MON-YYYY'))* (86400)) AS COL1 from DBA_HIST_ACTIVE_SESS_HISTORY;"
	;;
'DBADATAPUMPJOBS')
	sql="select trim(count(*)) from dba_datapump_jobs;"
	;;
'SERVICES')
	sql="select trim(count(*)) from SERVICES WHERE NAME='$THAMSO' AND STATUS=2;"
	;;
*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


if [ a"$sql" != a"" ]; then
#       echo "$sql"
       echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql
fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval
