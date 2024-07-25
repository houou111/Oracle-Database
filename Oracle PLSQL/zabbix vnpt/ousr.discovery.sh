#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select USERNAME from all_users where common='NO';"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read usr
do
	echo "			{\"{#USRNAME}\":\"${usr}\"},"
done


echo "		{}]"
echo "}"


