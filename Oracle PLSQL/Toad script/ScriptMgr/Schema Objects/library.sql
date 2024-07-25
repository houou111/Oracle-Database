set echo off
set feedback off
set linesize 512

prompt
prompt All Libraries in Database
prompt

column file_spec format a60

break on OWNER skip 1

SELECT	 OWNER, LIBRARY_NAME, FILE_SPEC, DECODE (DYNAMIC, 'Y', 'YES', 'N', 'NO') "DEC",
		 STATUS
	FROM DBA_LIBRARIES
	WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
ORDER BY OWNER, LIBRARY_NAME;