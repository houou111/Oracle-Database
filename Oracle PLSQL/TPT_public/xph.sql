set termout off

spool %SQLPATH%\tmp\xprof_&_connect_identifier..html

@@xprof ALL HTML &1

spool off

host start %SQLPATH%\tmp\xprof_&_connect_identifier..html
set termout on
