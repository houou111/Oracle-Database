-- on 10.2.0.1

set feedback off termout off
alter session set optimizer_mode=first_rows;

select * from dba_lock_internal;

set feedback on termout on
