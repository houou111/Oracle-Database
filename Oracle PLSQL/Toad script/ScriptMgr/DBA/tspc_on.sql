set echo off
set heading off
set feedback off

prompt
prompt Alter All Tablespaces Online
prompt

set term off
spool tspc_on.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter tablespace '||tablespace_name||' online;'
from dba_tablespaces
where tablespace_name not in ('SYSTEM','OUTLN')
  and status = 'OFFLINE';

spool off
set term on

@tspc_on.tmp