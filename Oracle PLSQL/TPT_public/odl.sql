set termout off
spool odl.tmp

oradebug dumplist
spool off

host grep -i &1 odl.tmp
host del odl.tmp

set termout on
