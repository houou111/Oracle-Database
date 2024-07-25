set echo off
set feedback off
set linesize 512

prompt
prompt All Dimensions in Database
prompt

break on OWNER

SELECT OWNER, DIMENSION_NAME, DECODE (INVALID, 'Y', 'YES', 'N', 'NO') "DEC", REVISION
	FROM DBA_DIMENSIONS
	ORDER BY OWNER, DIMENSION_NAME;