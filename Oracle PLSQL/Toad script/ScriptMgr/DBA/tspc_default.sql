set echo off
set feedback off
set linesize 512

prompt
prompt Default Tablespace User Counts
prompt

column count(username) heading '# USERS'

select default_tablespace, count(username)
from dba_users
where username not in ('PUBLIC','_NEXT_USER')
group by default_tablespace;

prompt
prompt Temporary Tablespace User Counts
prompt

select temporary_tablespace, count(username)
from dba_users
where username not in ('PUBLIC','_NEXT_USER')
group by temporary_tablespace;