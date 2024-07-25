set echo off
set heading off
set feedback off

prompt
prompt Current Date and Time
prompt

select '*** Time = '||to_char(sysdate,'DD-MON-YY HH:MI:SS')|| ' ***' from dual;