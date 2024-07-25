set echo off
set heading off
set feedback off
set linesize 130

prompt
prompt Alter All Primary Keys Enabled for Connected User
prompt

set term off
spool pk_on.tmp

select 'set echo on' from dual;
select 'set feedback on' from dual;

select 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||';'
  from user_constraints
  where constraint_type = 'P'
  and status != 'ENABLED';

select 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||';'
  from user_constraints
  where constraint_type = 'R'
  and status != 'ENABLED';

spool off
set term on

@pk_on.tmp