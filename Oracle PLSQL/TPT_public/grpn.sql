select 
    &3,
    count(&1),
    count(distinct &1) DISTCNT,
    sum(&1),
    avg(&1),
    min(&1),
    max(&1)
from
    &2
group by
    &3
/

