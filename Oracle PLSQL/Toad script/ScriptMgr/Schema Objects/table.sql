set echo off
set feedback off
set linesize 512

prompt
prompt All Tables in Database
prompt

break on OWNER

SELECT	 *
	FROM DBA_TABLES
	WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
ORDER BY OWNER, TABLE_NAME;