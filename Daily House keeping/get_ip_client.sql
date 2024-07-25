set colsep ,
set pagesize 0   
set trimspool on 
set headsep off  
set linesize 1000
SET HEADING OFF
SPOOL /tmp/ip_client.csv append

select distinct b.name db_name,USERNAME,OSUSER,MACHINE,MODULE,CLIENT_INFO
from gv$session a,v$containers b
where USERNAME not in ('SYS','DBSNMP','DBA01','C##DBA01','ZABBIX')
--AND CLIENT_INFO is not null
AND OSUSER not in ('grid')
AND a.con_id=b.con_id
order by CLIENT_INFO;

SPOOL OFF;
SET DEFINE ON
SET SERVEROUTPUT OFF

