select 
	n.name, 
	s.value
from
	v$statname n,
	v$mystat s
where
	n.statistic# = s.statistic#
and	lower(name) like lower('%&1%')
/


