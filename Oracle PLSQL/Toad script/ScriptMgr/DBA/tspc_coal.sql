set echo off
set heading off
set feedback off

prompt
prompt Alter All Tablespaces Coalesce
prompt

set term off
spool tspc_coal.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter tablespace '||tablespace_name||' coalesce;'
  from dba_tablespaces
  where contents not in ('TEMPORARY','UNDO');

spool off
set term on

@tspc_coal.tmp