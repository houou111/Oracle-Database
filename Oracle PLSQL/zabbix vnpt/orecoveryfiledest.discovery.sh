#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select NAME as RFDNAME from v\$recovery_file_dest;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read rfd
do
	echo "			{\"{#RFDNAME}\":\"${rfd}\"},"
done


echo "		{}]"
echo "}"


