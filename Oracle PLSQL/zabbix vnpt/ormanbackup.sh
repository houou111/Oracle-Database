#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

SESSION_KEY=$1

case $2 in

'INPUT_TYPE')
	sql="select TRIM(INPUT_TYPE)  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;
'STATUS')
	sql="select TRIM(STATUS)  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;
'START_TIME')
	sql="select TRIM(START_TIME)  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;
'END_TIME')
	sql="select TRIM(END_TIME)  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;
'HRS')
	sql="select TRIM(round(elapsed_seconds/3600,3))  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;
'INFO')
	sql="select TRIM(INPUT_TYPE) || '; ' || TRIM(STATUS) || '; ' ||  TRIM(round(elapsed_seconds))  from V\$RMAN_BACKUP_JOB_DETAILS where SESSION_KEY='$SESSION_KEY';"
	;;


*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


if [ a"$sql" != a"" ]; then
       echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql
fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval
