set echo off
set feedback off
set linesize 512

prompt
prompt Primary Keys for Connected User
prompt

select table_name, constraint_name, constraint_type, status
  from user_constraints
  where constraint_type = 'P'
  order by table_name, constraint_name;