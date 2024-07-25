set echo off
set feedback off
set linesize 512

prompt
prompt Tables with No Indexes
prompt

break on OWNER skip 1

SELECT OWNER, TABLE_NAME
  FROM ALL_TABLES
 WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP')
MINUS
SELECT OWNER, TABLE_NAME
  FROM ALL_INDEXES
 WHERE OWNER NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP');