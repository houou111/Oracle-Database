set echo off
set feedback off
set linesize 512

prompt
prompt Foreign Keys for Connected User
prompt

select table_name, constraint_name, r_owner, r_constraint_name, delete_rule, status
  from user_constraints
  where constraint_type = 'R'
  order by table_name, constraint_name;