set echo off
set feedback off
set linesize 512

prompt
prompt All triggers in Database
prompt

column triggering_event format a30

break on OWNER skip 1 on TABLE_NAME skip 1

select owner, table_name, trigger_name, triggering_event, status 
from all_triggers
where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP')
order by owner, table_name, trigger_name, triggering_event;