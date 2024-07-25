set echo off
set feedback off
set linesize 512

prompt
prompt All Roles in Database
prompt

SELECT ROLE, PASSWORD_REQUIRED
	FROM DBA_ROLES;