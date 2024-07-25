set echo off
set feedback off
set linesize 512

prompt
prompt All Roles Granted to Roles in Database
prompt

break on GRANTED_ROLE skip 1

SELECT GRANTED_ROLE, GRANTEE, ADMIN_OPTION, DEFAULT_ROLE
	FROM SYS.DBA_ROLE_PRIVS
	WHERE GRANTEE IN (SELECT ROLE FROM DBA_ROLES)
	ORDER BY GRANTED_ROLE, ADMIN_OPTION;