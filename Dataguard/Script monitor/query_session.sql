select failover_type, failover_method, failed_over
from v$session
where username = 'DGTEST'
/
