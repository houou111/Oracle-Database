select addr, name, gets, misses, immediate_gets ig, immediate_misses im, spin_gets spingets, wait_time
from v$latch
where lower(name) like lower('%&1%');
