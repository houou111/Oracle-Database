set echo off
set heading off
set feedback off
set linesize 130

prompt
prompt Alter All Triggers Online
prompt

set term off
spool trig_on.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter trigger '||owner||'.'||trigger_name||' enable;'
from all_triggers
where owner not in ('SYS','SYSTEM')
  and status = 'DISABLED';

spool off
set term on

@trig_on.tmp