set termout off
@@saveset
set termout off

set markup html on spool on

spool %SQLPATH%/tmp/output_&_connect_identifier..html

list
/

spool off

set markup html off spool off

@@loadset
set termout on

host start %SQLPATH%/tmp/output_&_connect_identifier..html

