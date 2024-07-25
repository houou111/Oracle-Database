#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select NAME FROM V\$ASM_DISKGROUP;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read name
do
	echo "			{\"{#NAME}\":\"${name}\"},"
done


echo "		{}]"
echo "}"


