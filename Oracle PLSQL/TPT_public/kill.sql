select '-- alter system kill session '''||sid||','||serial#||''' -- '
       ||username||'@'||machine||' ('||program||');' commands_to_verify_and_run
from v$session
where &1
/ 