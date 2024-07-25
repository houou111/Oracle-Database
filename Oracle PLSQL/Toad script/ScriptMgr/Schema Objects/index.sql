set echo off
set feedback off
set linesize 512

prompt
prompt All Indexes in Database
prompt

break on OWNER skip 1

SELECT	 *
	FROM DBA_INDEXES
	WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
ORDER BY OWNER, TABLE_OWNER, TABLE_NAME;