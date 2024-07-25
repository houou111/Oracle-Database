set echo off
set feedback off
set linesize 512

prompt
prompt All Contexts in Database
prompt

SELECT NAMESPACE, SCHEMA, PACKAGE
	FROM DBA_CONTEXT
	ORDER BY NAMESPACE;