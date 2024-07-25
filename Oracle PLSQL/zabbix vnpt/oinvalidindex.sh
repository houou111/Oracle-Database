#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /etc/zabbix/agentscripts/oraenv

IDXFULLNAME=$1

case $2 in

'STATUS')
	sql="select trim(STATUS) from dba_objects where owner=substr('$IDXFULLNAME',1,instr('$IDXFULLNAME','.')-1) and object_name= substr('$IDXFULLNAME',instr('$IDXFULLNAME','.')+1) and object_type like 'INDEX';"
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
