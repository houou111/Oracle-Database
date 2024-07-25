set echo off
set feedback off
set linesize 512

prompt
prompt All Object Types in Database
prompt

break on OWNER on TYPE_NAME

SELECT	 OWNER, TYPE_NAME, ATTR_NAME, ATTR_NO, ATTR_TYPE_NAME, LENGTH,
		 PRECISION, SCALE
	FROM DBA_TYPE_ATTRS
   WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
ORDER BY OWNER, TYPE_NAME, ATTR_NO;