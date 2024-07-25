#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

DSKNAME=$1

case $2 in

'STATE')
	sql="SELECT STATE FROM V\$ASM_DISKGROUP where name='$DSKNAME';"
	;;

'TYPE')
	sql="SELECT TYPE FROM V\$ASM_DISKGROUP where name='$DSKNAME';"
	;;

'TOTAL_MB')
	sql="SELECT TRIM(TOTAL_MB) FROM V\$ASM_DISKGROUP where name='$DSKNAME';"
	;;
'FREE_MB')
	sql="SELECT TRIM(FREE_MB) FROM V\$ASM_DISKGROUP where name='$DSKNAME';"
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
