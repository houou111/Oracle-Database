set echo off
set feedback off
set linesize 512

prompt
prompt Tablespace Object Breakdown Information
prompt

column count(*) heading '# OBJECTS'
column sum(bytes) heading 'BYTES'

select tablespace_name, owner, segment_type, count(*), sum(bytes)
from sys.dba_extents
group by tablespace_name, owner, segment_type
order by tablespace_name, owner, segment_type;