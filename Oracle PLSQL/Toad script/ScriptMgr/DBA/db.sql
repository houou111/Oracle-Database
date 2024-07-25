set echo off
set feedback off
set linesize 512

prompt
prompt Database Basic Info
prompt

SELECT NAME, CREATED, LOG_MODE
  FROM V$DATABASE;