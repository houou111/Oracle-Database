prompt
prompt Generating the describe commands into describeall_out.sql...

set head off pages 0 lines 200 feed off trimspool on

spool describeall_out.sql

prompt whenever sqlerror exit 1 rollback

select 
    'prompt Describing '||lower(object_type)||' '||owner||'.'||object_name||'...'||chr(10)||
    'describe '||owner||'.'||object_name
from 
    dba_objects 
where 
    object_type in ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION');

spool off

prompt Done.
prompt Now review the describeall_out.sql and execute it.
prompt Press enter to continue...
pause
