set echo off
set feedback off
set linesize 512

prompt
prompt All Control Files in Database
prompt

column name format a60

SELECT NAME, DECODE (STATUS, '', 'VALID', 'INVALID') "DEC"
	FROM V$CONTROLFILE
	ORDER BY NAME;