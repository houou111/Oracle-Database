whenever sqlerror exit failure 
set verify off echo off feedback off heading off pagesize 0 trimout on trimspool on termout off 
conn zabbix/zabbix2018@"(DESCRIPTION =    (ADDRESS = (PROTOCOL = TCP)(HOST = exax7q-01-adm)(PORT = 1521))    (CONNECT_DATA =      (SERVER = DEDICATED)      (SERVICE_NAME = HNI)    )  )"

column retvalue format a15
