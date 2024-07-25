set echo off
set heading off
set feedback off

prompt
prompt Alter All Rollback Segments Online
prompt

set term off
spool rbs_on.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter rollback segment '||segment_name||' online;'
  from dba_rollback_segs
  where segment_name != 'SYSTEM'
    and status = 'OFFLINE';

spool off
set term on

@rbs_on.tmp