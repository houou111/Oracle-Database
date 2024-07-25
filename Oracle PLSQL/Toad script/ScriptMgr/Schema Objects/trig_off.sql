set echo off
set heading off
set feedback off
set linesize 130

prompt
prompt Alter All Triggers Offline
prompt

set term off
spool trig_off.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter trigger '||owner||'.'||trigger_name||' disable;'
from all_triggers
where owner not in ('SYS','SYSTEM')
  and status = 'ENABLED';

spool off
set term on

@trig_off.tmp