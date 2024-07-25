set echo off
set feed off
set linesize 512

prompt
prompt Database Sessions Active
prompt

column machine format a20
column osuser format a20
column module format a20

select machine, process, osuser, username,
       schemaname, status, lockwait, sid,
       serial#, module, action
from v$session
where username is not null
  and osuser is not null
order by machine, osuser, username,
         schemaname, status, module;