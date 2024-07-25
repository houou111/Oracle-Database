set echo off
set feedback off
set linesize 512

prompt
prompt All Directories in Database
prompt

column directory_path format a80

SELECT OWNER, DIRECTORY_NAME, DIRECTORY_PATH
	FROM DBA_DIRECTORIES
	ORDER BY OWNER, DIRECTORY_NAME;