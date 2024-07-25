#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

RFDNAME=$1

case $2 in

'SPACE_LIMIT')
	sql="SELECT TRIM(ROUND(SPACE_LIMIT/1048576)) FROM V\$RECOVERY_FILE_DEST where NAME='$RFDNAME';"
	;;

'SPACE_USED')
	sql="SELECT TRIM(ROUND(SPACE_USED/1048576)) FROM V\$RECOVERY_FILE_DEST where NAME='$RFDNAME';"
	;;
'PERCENT_USED')
	sql="SELECT trim(ceil((CASE WHEN (SPACE_LIMIT > 0) THEN ROUND(((SPACE_USED / 1048576) * 100) / (SPACE_LIMIT / 1048576), 2) ELSE 0 END)))   FROM V\$RECOVERY_FILE_DEST where NAME='$RFDNAME';"
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
