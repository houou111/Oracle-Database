set echo off
set feedback off
set linesize 512

prompt
prompt All Outlines in Database
prompt

column version format a10

SELECT OWNER, NAME, CATEGORY, USED, TIMESTAMP, VERSION, SQL_TEXT
	FROM DBA_OUTLINES
	ORDER BY OWNER, NAME;