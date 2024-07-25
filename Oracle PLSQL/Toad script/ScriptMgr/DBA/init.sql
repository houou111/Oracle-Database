set echo off
set feedback off
set linesize 512

prompt
prompt Database INIT.ORA Info
prompt

column value format a80

SELECT	 NAME, 
	 DECODE (TYPE, 1, 'Boolean', 2, 'String', 3, 'INTEGER', 4, 'FILE', 5, 'RESERVED', 6, 'BIG INTEGER') TYPE, 
		 VALUE, DESCRIPTION, ISSES_MODIFIABLE, ISSYS_MODIFIABLE, ISDEFAULT,
		 ISMODIFIED, ISADJUSTED
	FROM V$PARAMETER
ORDER BY NAME;