#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select distinct name as dsk from v\$asm_diskgroup;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read dsk
do
	echo "			{\"{#DSKNAME}\":\"${dsk}\"},"
done


echo "		{}]"
echo "}"


