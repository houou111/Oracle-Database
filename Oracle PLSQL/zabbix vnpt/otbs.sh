#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

TBSNAME=$1

case $2 in

'used')
	sql="select trim(used_space) from dba_tablespace_usage_metrics where tablespace_name='$TBSNAME';"
	;;

'total')
	sql="select trim(tablespace_size) from dba_tablespace_usage_metrics where tablespace_name='$TBSNAME';"
	;;

'pused')
	sql="select trim(ceil(used_percent)) from dba_tablespace_usage_metrics where tablespace_name='$TBSNAME';"
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
