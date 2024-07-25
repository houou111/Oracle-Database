#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select distinct tablespace_name as tbs from dba_tablespace_usage_metrics;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read tbs
do
	echo "			{\"{#TBSNAME}\":\"${tbs}\"},"
done


echo "		{}]"
echo "}"


