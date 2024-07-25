#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select distinct owner || '.' || object_name  from dba_objects where status != 'VALID'and object_type like 'INDEX';"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read owner
do
	echo "			{\"{#INDEXOBJECT}\":\"${owner}\"},"
done


echo "		{}]"
echo "}"


