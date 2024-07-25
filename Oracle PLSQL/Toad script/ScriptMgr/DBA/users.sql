set echo off
set feedback off
set linesize 512

prompt
prompt All Users in Database
prompt

column count(b.object_id) heading '# OBJECTS'

select a.username,
       a.account_status,
       a.default_tablespace,
       a.temporary_tablespace,
	   count(b.object_id)
from dba_users a, dba_objects b
where a.username = b.owner(+)
group by a.username,
         a.account_status, 
         a.default_tablespace,
         a.temporary_tablespace;