set echo off
set feedback off
set linesize 512

prompt
prompt All Operators in Database
prompt

SELECT OWNER, OPERATOR_NAME, NUMBER_OF_BINDS
	FROM DBA_OPERATORS
	ORDER BY OWNER, OPERATOR_NAME;