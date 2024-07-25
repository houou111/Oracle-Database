set echo off
set heading off
set feedback off

prompt
prompt Alter All Tablespaces Offline
prompt

set term off
spool tspc_off.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter tablespace '||tablespace_name||' offline;'
from dba_tablespaces
where tablespace_name not in ('SYSTEM','OUTLN')
  and status = 'ONLINE';

spool off
set term on

@tspc_off.tmp