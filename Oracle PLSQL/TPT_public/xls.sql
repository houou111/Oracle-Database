set termout off
@@saveset
set termout off

def _kglob_tmp=&1

--@@htmlset nowrap "&_user@&_connect_identifier report on &_date"
@@htmlon

def 1=&_kglob_tmp

define _tptmode=html

spool %SQLPATH%/tmp/output_&_connect_identifier..xls

l
/

spool off

define _tptmode=normal

@@htmloff
@@loadset
set termout on

undef _kglob_tmp

host start %SQLPATH%/tmp/output_&_connect_identifier..xls
