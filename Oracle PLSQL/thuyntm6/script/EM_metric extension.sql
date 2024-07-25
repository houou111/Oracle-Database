---statistic index & table
select * from 
( select owner||'.'||index_name,last_analyzed
from dba_indexes where owner in (select username from dba_users where account_status='OPEN' and username not in ('DBSNMP','SQLTXPLAIN','SYSTEM','GG12')
and username not like '%_DBA')
 order by last_analyzed)
 where rownum <21;
 
 select * from 
( select owner||'.'||table_name,last_analyzed
from dba_tables where owner in (select username from dba_users where account_status='OPEN' and username not in ('DBSNMP','SQLTXPLAIN','SYSTEM','GG12')
and username not like '%_DBA')
 order by last_analyzed)
 where rownum <21;

---active session per CPU core
SELECT a.so || ' / ' || b.VALUE || ' cpu'
  FROM (SELECT COUNT (*) so, 1 numb
          FROM v$session  WHERE status = 'ACTIVE' AND TYPE <> 'BACKGROUND'
        HAVING COUNT (*) > (SELECT TO_NUMBER (VALUE) * 2 FROM v$parameter WHERE name = 'cpu_count')) a,
       (SELECT VALUE FROM v$parameter WHERE name = 'cpu_count') b
	   
	   --ver 2
SELECT a.so || ' / ' || b.VALUE || ' cpu'
  FROM (SELECT COUNT (*) so, 1 numb
          FROM v$SESSION_WAIT  WHERE  wait_class <> 'Idle'
        HAVING COUNT (*) > (select value from V$OSSTAT where stat_name='NUM_CPU_CORES')*2
        ) a,
       (select value from V$OSSTAT where stat_name='NUM_CPU_CORES') b	   

---long elapsed time 
select '[sid|serial#: '||sid||'|'||session_serial#||' - '||sql_text||']' as mes, trunc(elapsed_time/3600000000,1)  as elapsed 
from v$sql_monitor
where status ='EXECUTING'
and username not like 'SYS%'
and username <>'DBSNMP'
and elapsed_time>86400000000
and sql_plan_hash_value <> 0

---session longops
select substr(message,0,40) ||'...('||'User '|| username||' - '|| substr(lower(regexp_replace(sql_text,'\  ',' ')),0,200)||')' as Message,round(time_remaining/3600,2) as remain_by_hour 
from V$SESSION_LONGOPS a, v$sqlarea b
where a.sql_id=b.sql_id 
and time_remaining/3600>4
and last_update_time > SYSDATE - 1 / 48
and username <> 'SYS'

---Top Sql I/O Read (Bytes)

select ' Sql statement '||sql_id||' (run by '|| USERname||', program: '||program||', module: '||module||', machine: '||machine||')',read_bytes
  from
  (
  SELECT sql_id, USERname, program, module, machine, MAX (DELTA_READ_IO_BYTES) read_bytes
    FROM DBA_HIST_ACTIVE_SESS_HISTORY s, dba_users u
   WHERE     s.user_id = u.user_id
         AND DELTA_READ_IO_BYTES > 10000000
         AND SAMPLE_TIME > TRUNC (SYSDATE) - 1
         AND username NOT LIKE 'SYS%'
         AND  sql_id is not null
GROUP BY sql_id, USERname, program, module, machine
ORDER BY 6 DESC
) 
where rownum< 11


--------------sql has run for too long 
select '[sid|serial#: '||sid||'|'||session_serial#||' - '||sql_text||']', trunc(elapsed_time/3600000000,1)  --select * 
from v$sql_monitor
where status ='EXECUTING'
and username not like 'SYS%'
and username <>'DBSNMP'
and elapsed_time>3600000000
and sql_plan_hash_value <> 0

--------------read io for dwh
select sql_id,USERname,program,module,machine, max(DELTA_READ_IO_BYTES) 
from DBA_HIST_ACTIVE_SESS_HISTORY s, dba_users u
where s.user_id=u.user_id 
and DELTA_READ_IO_BYTES>10000000 and SAMPLE_TIME > trunc(sysdate)-1
and username not like  'SYS%'
group by sql_id,USERname,program,module,machine
order by 6 desc

-------------------------------------------------------------
--=========Metric extension
-------------------------------------------------------------
--backup
select NVL(object_type,'Unidentified')object_type, 
    NVL(status,'Unidentified')status, 
    NVL(round(OUTPUT_GB,3),0) OUTPUT_GB ,
    NVL(round(b.time,3),0) "time(s)",
    NVL(round(b.MBPS,3),0) "MBPS",
    NVL(to_char(end_time, 'mm/dd/yyyy hh24:mi:ss'),'Unidentified') end_time
from (SELECT a2.OBJECT_TYPE,a2.end_time,a2.status,round(a2.OUTPUT_BYTES/1024/1024/1024,3)OUTPUT_GB,(a2.end_time-a2.start_time)*86400 time,
OUTPUT_BYTES/(a2.end_time-a2.start_time)/1024/1024/86400 MBPS
                    FROM (select OBJECT_TYPE,max(end_time) bk_datetime
                          from V$RMAN_STATUS
                          where trunc(end_time)= trunc(sysdate-1)and operation = 'BACKUP'
                          group by OBJECT_TYPE) a1,
                          (select * 
                          from V$RMAN_STATUS 
                          where trunc(end_time)= trunc(sysdate-1) and operation = 'BACKUP' ) a2
WHERE a1.OBJECT_TYPE= a2.OBJECT_TYPE
AND a1.bk_datetime=a2.end_time) b

--biggest table
select tab, gb from (
SELECT   owner||'.'||table_name tab, trunc(sum(bytes)/1024/1024/1024) GB FROM (          
          SELECT owner,segment_name as table_name, b.bytes FROM dba_segments b WHERE segment_type like 'TABLE%' 
union all SELECT l.owner,L.TABLE_NAME,s.bytes as bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner   
)
GROUP BY owner  ,table_name
having TRUNC(sum(bytes)/1024/1024/1024)>=1
ORDER BY 2 desc
) where rownum <51

--index unusable
select a.IND+b.IND+c.IND as num from 
(SELECT count(*) IND
FROM   dba_indexes
WHERE  status = 'UNUSABLE')a,
(SELECT count(*)IND
FROM   dba_ind_PARTITIONS
WHERE  status = 'UNUSABLE')b,
(SELECT count(*)IND
FROM   dba_ind_SUBPARTITIONS
WHERE  status = 'UNUSABLE')c
where a.IND+b.IND+c.IND>0

--LOng ops
select substr(message,0,30) ||'...('||'User '|| username||' - '|| sql_text||')' as Message,round(time_remaining/3600,2) as remain_by_hour 
from V$SESSION_LONGOPS a, v$sqlarea b
where a.sql_id=b.sql_id 
and time_remaining/3600>4
and last_update_time > SYSDATE - 1 / 48
and username <> 'SYS'
and username not like '%_DBA'
and username not like '%_DBA'

--session
select count(*) from v$session where status='ACTIVE' and type <> 'BACKGROUND'
having count(*) >(select value*2 from V$OSSTAT where stat_name = 'NUM_CPU_CORES')

SELECT a.so || ' / ' || b.VALUE || ' cpu'
  FROM (SELECT COUNT (*) so, 1 numb
          FROM v$session  WHERE status = 'ACTIVE' AND TYPE <> 'BACKGROUND'
        HAVING COUNT (*) > (SELECT TO_NUMBER (VALUE) * 2 FROM v$parameter WHERE name = 'cpu_count')) a,
       (SELECT VALUE FROM v$parameter WHERE name = 'cpu_count') b
	   
--check longops
select username ,sql_id, substr(message,0,30)as Message,round(time_remaining/3600,2) as remain_by_hour from V$SESSION_LONGOPS 
where time_remaining/3600>4
and last_update_time > SYSDATE - 1 / 48

--recovery_file_dest full 
https://blogs.oracle.com/oem/entry/fast_recovery_area_for_archive
https://blogs.oracle.com/oem/entry/fast_recovery_area_for_archive


https://docs.oracle.com/cd/B16240_01/doc/doc.102/e16282/oracle_database_help/oracle_database_archfull_archusedpercent.html