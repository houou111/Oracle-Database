set termout off
store set %SQLPATH%/tmp/env_&_CONNECT_IDENTIFIER..sql replace
save %SQLPATH%/tmp/explain_&_CONNECT_IDENTIFIER..sql replace

0 explain plan for
run

set termout on

select * from table(dbms_xplan.display);

set termout off
@%SQLPATH%/tmp/env_&_CONNECT_IDENTIFIER..sql
get %SQLPATH%/tmp/explain_&_CONNECT_IDENTIFIER..sql
set termout on
