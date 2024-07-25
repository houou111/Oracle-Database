set echo off
set feedback off
set linesize 512

prompt
prompt Top IO Waits in Database
prompt

column event  format a30
column segment_type format a10
column segment_name format a20

select event,segment_type,segment_name,file_id,block_id,blocks
from dba_extents, v$session_wait
where p1text='file#'
  and p2text='block#'
  and p1=file_id and
      p2 between block_id and block_id+blocks
order by segment_type,segment_name;
