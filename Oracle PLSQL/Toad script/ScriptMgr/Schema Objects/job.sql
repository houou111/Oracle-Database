set echo off
set feedback off
set linesize 512

prompt
prompt Database Jobs Currently Scheduled
prompt

column interval format a40
column what format a40

SELECT JOB, LOG_USER, PRIV_USER, SCHEMA_USER, LAST_DATE, THIS_DATE, NEXT_DATE, TOTAL_TIME, 
	DECODE (BROKEN, 'Y', 'YES', 'N', 'NO') "JOB_BROKEN", 
	INTERVAL, FAILURES, TRANSLATE(WHAT,chr(10), ' ') WHAT
	FROM DBA_JOBS
	ORDER BY JOB;