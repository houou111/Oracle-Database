#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select distinct inst_id as id from gv\$database;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read id
do
	echo "			{\"{#INSTID}\":\"${id}\"},"
done


echo "		{}]"
echo "}"


