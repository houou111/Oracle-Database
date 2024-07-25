#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

NAME=$1

case $2 in

'used')
	sql="select trim(TOTAL_MB-FREE_MB) from v\$asm_diskgroup where name='$NAME';"
	;;

'free')
	sql="select trim(FREE_MB) from v\$asm_diskgroup where name='$NAME';"
	;;

'pused')
	sql="select trim(trunc(((TOTAL_MB-FREE_MB)/TOTAL_MB)*100,2)) from v\$asm_diskgroup where name='$NAME';"
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
