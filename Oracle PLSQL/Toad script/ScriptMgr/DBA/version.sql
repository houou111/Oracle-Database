set echo off
set feedback off
set heading off

prompt
prompt Database Instance and Version Info
prompt

select 'Database Instance   = '||name from v$database;
select 'Database Version    = '||banner from v$version where rownum = 1;
select 'Database Block Size = '||value from v$parameter where name = 'db_block_size';