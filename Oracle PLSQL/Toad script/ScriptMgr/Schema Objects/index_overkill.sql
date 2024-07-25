set echo off
set feedback off
set linesize 512

prompt
prompt Highly Indexed Tables
prompt

SELECT	 OWNER, TABLE_NAME, COUNT (*) "count"
	FROM ALL_INDEXES
   WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
GROUP BY OWNER, TABLE_NAME
  HAVING COUNT (*) > ('6');