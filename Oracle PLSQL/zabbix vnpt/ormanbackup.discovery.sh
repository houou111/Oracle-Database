#! /bin/sh

. /etc/zabbix/agentscripts/oraenv

sql="select trim(SESSION_KEY )    from V\$RMAN_BACKUP_JOB_DETAILS where START_TIME>SYSDATE-1 order by session_key;"

echo "{"
echo "	\"data\":["

echo "$sql" | sqlplus -s /nolog @/etc/zabbix/agentscripts/oconn.sql | while read key
do
	echo "			{\"{#SESSIONKEY}\":\"${key}\"},"
done


echo "		{}]"
echo "}"


