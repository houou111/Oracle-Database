select addr, child#, name, gets, misses, immediate_gets ig, immediate_misses im, spin_gets spingets
from v$latch_children
where lower(name) like lower('%&1%')
order by name, child#
/
