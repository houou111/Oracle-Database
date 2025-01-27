-- report broken kgl locks for an object this can be used for identifying which sessions
-- would get ORA-04068 "existing state of packages has been discarded" errors due a change
-- in some object definition (such pl/sql package recompilation)


select decode(substr(banner, instr(banner, 'Release ')+8,1), '1', 256,  1) kglbroken_flg 
from v$version 
where rownum = 1

select 
   sid,serial#,username,program 
from 
   v$session 
where 
   saddr in (select /*+ no_unnest */ kgllkuse 
             from x$kgllk 
             where 
                 kglnahsh in (select /*+ no_unnest */ kglnahsh 
                              from x$kglob 
                              where 
                                   upper(kglnaown) like upper('&owner') 
                              and  upper(kglnaobj) like upper('&object_name')
                             ) 
             and bitand(kgllkflg,256)=256
   )
/
