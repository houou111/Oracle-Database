set echo off
set heading off
set feedback off

prompt
prompt Alter All Rollback Segments Offline
prompt

set term off
spool rbs_off.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter rollback segment '||segment_name||' offline;'
  from dba_rollback_segs
  where segment_name != 'SYSTEM'
    and status = 'ONLINE';

spool off
set term on

@rbs_off.tmp