-----------------------------------------------------------
--========performance report
-----------------------------------------------------------
--disk device busy - host
SELECT TO_CHAR (md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP,
       md.target_name key,
       key_value,
       ROUND (md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
 WHERE     md.metric_label = 'Disk Activity'
       AND md.column_label = 'Disk Device Busy (%)'
       AND md.target_name IN (:HOST1,:HOST2)  --param_target_name
       AND md.rollup_timestamp >= TRUNC (SYSDATE) - 31

-----------------------------------------------------------
--biggest table
SELECT /* Largest segments */ NVL(t.table_name,s.segment_name) table_name ,s.owner, s.segment_name, s.segment_type, ROUND(SUM(s.bytes)/1024/1024/1024, 1) AS "GB" 
FROM DBA_SEGMENTS s LEFT join dba_lobs T
ON upper(s.SEGMENT_NAME)=upper(t.SEGMENT_NAME)
GROUP BY NVL(t.table_name,s.segment_name),s.owner, s.segment_name, s.segment_type HAVING ROUND (SUM (s.bytes) / 1024 / 1024, 1) >= 1000 ORDER BY ROUND(SUM(s.bytes)/1024/1024/1024, 1) DESC;
 
select * from (
SELECT   owner, table_name, sum(bytes)/1024/1024/1024 GB FROM (          
          SELECT owner,segment_name as table_name, b.bytes FROM dba_segments b WHERE segment_type like 'TABLE%' 
union all SELECT l.owner,L.TABLE_NAME,s.bytes as bytes FROM dba_lobs l, dba_segments s WHERE s.segment_name = l.segment_name  AND   s.owner = l.owner   
)
GROUP BY owner  ,table_name
having TRUNC(sum(bytes)/1024/1024/1024)>=1
ORDER BY 3 desc
) where rownum <51
 
 --performance IO
 
with iostat_file as 
  (select filetype_name,sum(large_read_reqs) large_read_reqs,
          sum(large_read_servicetime) large_read_servicetime,
          sum(large_write_reqs) large_write_reqs,
          sum(large_write_servicetime) large_write_servicetime,
          sum(small_read_reqs) small_read_reqs,
          sum(small_read_servicetime) small_read_servicetime,
          sum(small_sync_read_latency) small_sync_read_latency,
          sum(small_sync_read_reqs) small_sync_read_reqs,
          sum(small_write_reqs) small_write_reqs,
          sum(small_write_servicetime) small_write_servicetime
   from sys.v_$iostat_file
    group by filetype_name)
select filetype_name, small_read_reqs + large_read_reqs reads,
       large_write_reqs + small_write_reqs writes,
       round((small_read_servicetime + large_read_servicetime)/1000) 
          read_time_sec,
       round((small_write_servicetime + large_write_servicetime)/1000) 
          write_time_sec,
       case when small_sync_read_reqs > 0 then 
          round(small_sync_read_latency / small_sync_read_reqs, 2) 
       end avg_sync_read_ms,
       round((  small_read_servicetime+large_read_servicetime
              + small_write_servicetime + large_write_servicetime)
             / 1000, 2)  total_io_seconds
 from iostat_file
 order by 7 desc;
 
 --performance statistic
 select owner,table_name,num_rows,sample_size,last_analyzed,tablespace_name
from dba_tables where owner='' order by last_analyzed;

select index_name,table_name,num_rows,sample_size,distinct_keys,last_analyzed,status 
from dba_indexes where table_owner=' ' order by last_analyzed;

SET SERVEROUTPUT ON
  DECLARE
ObjList dbms_stats.ObjectTab;
BEGIN
dbms_stats.gather_database_stats(objlist=>ObjList, options=>'LIST STALE');
FOR i in ObjList.FIRST..ObjList.LAST
LOOP
dbms_output.put_line(ObjList(i).ownname || '.' || ObjList(i).ObjName || ' ' || ObjList(i).ObjType || ' ' || ObjList(i).partname);
END LOOP;
END;
/


-----------------------------------------------------------
--db_info
select  o.database_name "DATABASE_NAME",
        o.log_mode "LOG_MODE",  
        o.banner "BANNER"      
        from mgmt$db_dbninstanceinfo o
 where o.target_name  = :DBNAME_N
 
 --info1
 select o.host_name,o.instance_name,t.os_summary,t.logical_cpu_count,round(t.mem/1024) as "MEM",t.SYSTEM_CONFIG || ' ' || t.ma  as "HW_SNAPSHOT_COMPONENT_NAME"  
 from  mgmt$os_hw_summary t, mgmt$db_dbninstanceinfo o
 where o.target_name = :INSTANCE_N1
 and t.host_name=o.host_name
--target_availability
SELECT a.AVAILABILITY_STATUS,
       SUM(a.VALUE ) as availability  FROM(
    (select 'Down' AVAILABILITY_STATUS, 0 VALUE, 2 ORDER_COL 
        from dual 
    union all 
    select 'Up' AVAILABILITY_STATUS, 0 VALUE, 1 ORDER_COL 
        from dual 
    union all 
    select 'System Error' AVAILABILITY_STATUS, 0 VALUE, 5 ORDER_COL 
        from dual 
    union all 
    select 'Agent Down' AVAILABILITY_STATUS, 0 VALUE, 4 ORDER_COL
        from dual 
    union all 
    select 'Blackout' AVAILABILITY_STATUS, 0 VALUE, 3 ORDER_COL 
        from dual 
    union all 
    select 'Status Pending' AVAILABILITY_STATUS, 0 VALUE, 6 ORDER_COL 
        from dual )
    UNION ALL
    SELECT decode(LOWER(AVAILABILITY_STATUS),
                 'target down','Down',
                 'target up','Up',
                 'metric error','System Error',
                 'agent down','Agent Down',
                 'unreachable','Unreachable',
                 'blackout','Blackout',
                 'pending/unknown','Status Pending'
       )AVAILABILITY_STATUS,
    round(SUM(
    least(
       nvl(end_timestamp,sysdate),  sysdate  ) -  greatest(start_timestamp,sysdate-7)  )*24,8 ) as VALUE,  
    decode(LOWER(AVAILABILITY_STATUS),
          'target down',2,
          'target up',1,
          'metric error',5,
          'agent down',4,
          'unreachable',7
          ,'blackout',3,
          'pending/unknown',6
       )ORDER_COL
    from mgmt$availability_history b, MGMT$TARGET T
    WHERE b.TARGET_GUID=(select target_guid from  MGMT$TARGET where target_name=:INSTANCE_N1)--:INSTANCE_N1
    and b.target_guid=T.TARGET_GUID 
    and LOWER(AVAILABILITY_STATUS)!='unreachable'
        and b.start_timestamp<= sysdate
    and (b.end_timestamp>= sysdate-31
         OR b.end_timestamp is NULL) 
    group by LOWER(AVAILABILITY_STATUS),
     decode(LOWER(AVAILABILITY_STATUS),
            'target down',2,
            'target up',1,
            'metric error',5,
            'agent down',4,
            'unreachable',7,
            'blackout',3,
            'pending/unknown',6
         )
    ) a
    GROUP BY a.AVAILABILITY_STATUS,a.ORDER_COL ORDER BY a.ORDER_COL

--target_incident_inst1
select  b.severity as "SEVERITY",
       sum(severity_count) as "COUNT OF SEVERITY"
from
(
   select 'Fatal' severity ,0 severity_count from dual
   union
   select 'Critical' , 0 from dual
   union
   select 'Warning' , 0  from dual
   union
   select 'Clear' , 0 from dual
union
select a.severity ,
       count(*) as SEVERIY_COUNT
         from mgmt$incidents a,
              mgmt$target b
        where a.severity in ('Fatal','Critical','Warning', 'Clear') and
              a.target_guid = b.target_guid and
              -- a.adr_related = 0 and
              ( a.closed_date is NULL 
                or
                a.closed_date > sysdate
              )
--and a.creation_date >= trunc(sysdate)-31              
and a.target_guid = (select target_guid from  MGMT$TARGET where target_name=:INSTANCE_N1)--:INSTANCE_N1
       group by
         a.severity 
) b
where b.severity != 'Clear'
group by 
  b.severity

--incident 
select * from 
(select a.severity , a. summary_msg
         from mgmt$incidents a
        where a.severity in 'Critical' and
              ( a.closed_date is NULL 
                or
                a.closed_date > sysdate
              )
              and a.target_guid IN (select target_guid from  MGMT$TARGET where target_name In (:INSTANCE_N2,:INSTANCE_N1))
              and severity != 'Clear'
             -- and a.creation_date >= trunc(sysdate)-31
order by a.creation_date desc)
              where rownum <11

--cpuactivesession
select     "GC$METRIC_VALUES"."VALUE" as "ActiveSessions",
     "GC$METRIC_VALUES"."KEY_PART_1" as "WaitClassName",
     to_char (cast ("GC$METRIC_VALUES"."COLLECTION_TIME" as timestamp), 'YYYY-MM-DD HH24') as "Time" 
 from    "SYSMAN"."GC$METRIC_VALUES" "GC$METRIC_VALUES" 
 where      "GC$METRIC_VALUES"."COLLECTION_TIME" >= (trunc(sysdate) - 30) 
   and     "GC$METRIC_VALUES"."ENTITY_NAME" = :DBNAME_N --dbname
   and     "GC$METRIC_VALUES"."ENTITY_TYPE" ='rac_database'
   and     "GC$METRIC_VALUES"."METRIC_COLUMN_NAME" ='active_sessions' 
   and     "GC$METRIC_VALUES"."METRIC_GROUP_NAME" ='wait_cpu_sess'
   and "GC$METRIC_VALUES"."KEY_PART_1" != 'Idle'
ORDER BY 2,"GC$METRIC_VALUES"."COLLECTION_TIME" ASC

--space hist
SELECT  DECODE(m.metric_column,'ALLOCATED_GB',
'ALLOCATED (GB)','USED_GB','USED (GB)') AS SIZE_GB, 
          to_char(m.rollup_timestamp, 'YYYY-MM-DD') AS TIME, ROUND(SUM(m.average),2) AS value
          FROM    mgmt$metric_daily m
          WHERE   m.target_guid=(select TARGET_GUID
 from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
            AND   m.metric_name = 'DATABASE_SIZE' 
            AND (m.metric_column='ALLOCATED_GB' OR m.metric_column='USED_GB')
            AND m.rollup_timestamp >= trunc(sysdate)-91
            and mod( extract(day from rollup_timestamp),2)=0
GROUP BY m.metric_column, m.rollup_timestamp
          ORDER BY m.rollup_timestamp asc, m.metric_column desc

--current_space_usage
SELECT ROUND (curr.curr_alloc_size_gb, 3) AS CURR_SIZE_GB,
       ROUND (curr.curr_alloc_used_gb, 3) AS CURR_USED_GB,
       ROUND (curr.curr_alloc_used_pct, 3) AS CURR_USED_PCT,
       ROUND (GREATEST (tsize.max_alloc_size_gb, curr.curr_alloc_size_gb), 3)
          AS MAX_SIZE_GB,
       ROUND (GREATEST (usize.max_alloc_used_gb, curr.curr_alloc_used_gb), 3)
          AS MAX_USED_GB,
       ROUND (GREATEST (fsize.max_alloc_used_pct, curr.curr_alloc_used_pct),3)       AS MAX_USED_PCT
  FROM 
  (
  SELECT ROUND (alloc.ALLOC_GB, 3) AS curr_alloc_size_gb,
               ROUND (used.USED_GB, 3) AS curr_alloc_used_gb,
               (ROUND (used.USED_GB, 3) * 100) / ROUND (alloc.ALLOC_GB, 3) AS curr_alloc_used_pct
          FROM (SELECT SUM (VALUE) AS ALLOC_GB
                  FROM mgmt$metric_current md
                 WHERE     md.target_guid = (select TARGET_GUID
 from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                       AND md.metric_name = 'DATABASE_SIZE'
                       AND md.metric_column = 'ALLOCATED_GB') alloc,
               (SELECT SUM (VALUE) AS USED_GB
                  FROM mgmt$metric_current md
                 WHERE     md.target_guid = (select TARGET_GUID
 from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                       AND md.metric_name = 'DATABASE_SIZE'
                       AND md.metric_column = 'USED_GB') used) curr,
       (SELECT MAX (max_alloc_size_gb) AS max_alloc_size_gb
          FROM (  SELECT MAX (md.maximum) AS max_alloc_size_gb
                    FROM mgmt$metric_daily md
                   WHERE     md.target_guid = (select TARGET_GUID  from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                         AND md.metric_name = 'DATABASE_SIZE'
                         AND md.metric_column = 'ALLOCATED_GB'
                         AND md.rollup_timestamp >= trunc(sysdate)-121
                         GROUP BY md.rollup_timestamp)) tsize,
       (SELECT MAX (max_alloc_size_gb) AS max_alloc_used_gb
          FROM (  SELECT SUM (md.average) AS sum_avg_alloc_size_gb,
                         MAX (md.maximum) AS max_alloc_size_gb
                    FROM mgmt$metric_daily md
                   WHERE     md.target_guid = (select TARGET_GUID  from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                         AND md.metric_name = 'DATABASE_SIZE'
                         AND md.metric_column = 'USED_GB'
                         AND md.rollup_timestamp >= trunc(sysdate)-121
                GROUP BY md.rollup_timestamp)) usize,
       (SELECT MAX ( (used.USED_GB * 100) / alloc.ALLOC_GB)          AS max_alloc_used_pct
          FROM (SELECT md.maximum AS ALLOC_GB, rollup_timestamp
                  FROM mgmt$metric_daily md
                 WHERE     md.target_guid = (select TARGET_GUID
 from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                       AND md.metric_name = 'DATABASE_SIZE'
                       AND md.metric_column = 'ALLOCATED_GB'
                       AND md.rollup_timestamp >= trunc(sysdate)-121) alloc,
               (SELECT md.maximum AS USED_GB, rollup_timestamp
                  FROM mgmt$metric_daily md
                 WHERE     md.target_guid = (select TARGET_GUID
 from    MGMT$TARGET where target_name=:DBNAME_N) --list_of_db_param
                       AND md.metric_name = 'DATABASE_SIZE'
                       AND md.metric_column = 'USED_GB'
                       AND md.rollup_timestamp >= trunc(sysdate)-121) used
         WHERE alloc.rollup_timestamp = used.rollup_timestamp) fsize

--tablespace usage
SELECT  free_extend.tablespace AS TABLESPACE,  
        round(used.avg_used_gb,0) AS "USED_GB",
        round(used.avg_used_gb+free_extend.avg_size_gb,0) AS "SIZE_GB",    
        round((used.avg_used_gb*100)/ (used.avg_used_gb+free_extend.avg_size_gb)) AS "USED PERCENT"
        FROM  
 (SELECT  
            m.key_value as tablespace,  
            m.rollup_timestamp AS timestamp,  
            m.average/1024 AS avg_size_gb
            FROM  
               mgmt$metric_daily m,  
               mgmt$target_type t
            WHERE   
              m.target_guid=t.target_guid AND  
              m.metric_guid=t.metric_guid AND  
              m.target_name = :DBNAME_N and
              T.METRIC_NAME  in ('problemTbsp','problemTbspUndo','problemTbspTemp') and t.metric_column='bytesFree' and
              m.rollup_timestamp =(select max (rollup_timestamp) from mgmt$metric_daily where metric_name='tbspAllocation' AND  
              target_name = :DBNAME_N)
              ) free_extend,  
  (SELECT  
            m.key_value as tablespace,  
            m.rollup_timestamp AS timestamp,  
            m.average/1024 AS avg_used_gb 
          FROM  
            mgmt$metric_daily m,  
            mgmt$target_type t
            WHERE   
              m.target_guid=t.target_guid AND  
              m.metric_guid=t.metric_guid AND  
              m.target_name = :DBNAME_N 
              and  t.metric_name='tbspAllocation' AND  
              (t.metric_column='spaceUsed') AND  
              m.rollup_timestamp = (select max (rollup_timestamp) from mgmt$metric_daily where metric_name='tbspAllocation' AND  
              target_name = :DBNAME_N)
              ) used  
     WHERE  
         free_extend.timestamp=used.timestamp AND  
        free_extend.tablespace=used.tablespace  
        order by 1

--growth_use_size
select  last30.value - last60.value as "growth 2 month ago",now.value-last30.value as "growth 1 month ago" 
from 
(SELECT   m.average AS value
          FROM    mgmt$metric_daily m
          WHERE   m.target_guid=(select TARGET_GUID from    MGMT$TARGET where target_name=:DBNAME_N) 
            AND   m.metric_name = 'DATABASE_SIZE' 
            AND  m.metric_column='USED_GB'
            AND m.rollup_timestamp = trunc(LAST_DAY(ADD_MONTHS(SYSDATE,-1))+2) ) now,
(SELECT   m.average AS value
          FROM    mgmt$metric_daily m
          WHERE   m.target_guid=(select TARGET_GUID from    MGMT$TARGET where target_name=:DBNAME_N) 
            AND   m.metric_name = 'DATABASE_SIZE' 
            AND  m.metric_column='USED_GB'
            AND m.rollup_timestamp = trunc(LAST_DAY(ADD_MONTHS(SYSDATE,-2))+2) ) last30,
(SELECT  m.average AS value
          FROM    mgmt$metric_daily m
          WHERE   m.target_guid=(select TARGET_GUID from    MGMT$TARGET where target_name=:DBNAME_N) 
            AND   m.metric_name = 'DATABASE_SIZE' 
            AND  m.metric_column='USED_GB'
            AND m.rollup_timestamp = trunc(LAST_DAY(ADD_MONTHS(SYSDATE,-3))+2) ) last60

--change size
SELECT TO_DATE (m.rollup_timestamp, 'DD/MM/YYYY') as CREATE_DATE, m.average AS VALUE
  FROM mgmt$metric_daily m
 WHERE     m.target_guid = (SELECT TARGET_GUID
                              FROM MGMT$TARGET
                             WHERE target_name = :DBNAME_N)
       AND m.metric_name = 'DATABASE_SIZE'
       AND m.metric_column = 'USED_GB'
       AND (   m.rollup_timestamp = TRUNC (LAST_DAY (ADD_MONTHS (SYSDATE, -3)) + 2)
            OR m.rollup_timestamp = TRUNC (LAST_DAY (ADD_MONTHS (SYSDATE, -2)) + 2)
            OR m.rollup_timestamp = TRUNC (LAST_DAY (ADD_MONTHS (SYSDATE, -1)) + 2))

--interconnect
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP, 
      md.KEY_VALUE ||
      DECODE(md.KEY_VALUE2,' ','',';'||md.KEY_VALUE2)||
      DECODE(md.KEY_VALUE3,' ','',';'||md.KEY_VALUE3)||
      DECODE(md.KEY_VALUE4,' ','',';'||md.KEY_VALUE4)||
      DECODE(md.KEY_VALUE5,' ','',';'||md.KEY_VALUE5)||
      DECODE(md.KEY_VALUE6,' ','',';'||md.KEY_VALUE6)||
      DECODE(md.KEY_VALUE7,' ','',';'||md.KEY_VALUE7) key
      ,ROUND(md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Interconnect Traffic'
  and upper(md.target_name) IN (upper(:INSTANCE_N1),upper(:INSTANCE_N2)) --param_target_name
    and  md.rollup_timestamp >= trunc(sysdate)-31
	
--CPU
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP_mem, 
      md.target_name key_mem
      ,ROUND(md.AVERAGE, 2) AVERAGE_mem
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Load' and column_label ='CPU Utilization (%)'
  and upper(md.target_name) IN (upper(:INSTANCE_N1),upper(:INSTANCE_N2))  
    and  md.rollup_timestamp  >= trunc(sysdate)-31	
	
	
--memory
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP_mem, 
      md.target_name key_mem
      ,ROUND(md.AVERAGE, 2) AVERAGE_mem
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Memory Usage'
  and upper(md.target_name) IN (upper(:INSTANCE_N1),upper(:INSTANCE_N2))  
    and  md.rollup_timestamp  >= trunc(sysdate)-31

--inst1_mem
(SELECT TO_CHAR (ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP,
        -- md.target_name key,
        column_label,
        ROUND (AVERAGE, 2) AVERAGE
   FROM MGMT$METRIC_DAILY
  WHERE     metric_label = 'SGA and PGA usage'
        AND column_label = 'SGA Size(MB)'
        AND target_name = :INSTANCE_N1                     --param_target_name
        AND rollup_timestamp >= TRUNC (SYSDATE) - 31 )  
union
(SELECT TO_CHAR (ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP,
        --md.target_name key,
        'Total Memory(MB)' as column_label,
        ROUND (sum(AVERAGE), 2) AVERAGE
   FROM MGMT$METRIC_DAILY
  WHERE     metric_label = 'SGA and PGA usage'
        AND column_label in ( 'PGA Total(MB)','SGA Size(MB)')
        AND target_name = :INSTANCE_N1                     --param_target_name
        AND rollup_timestamp >= TRUNC (SYSDATE) - 31
        group by ROLLUP_TIMESTAMP  )  
union
(SELECT TO_CHAR (ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP,
        --md.target_name key,
        'PGA Total (MB)' as column_label,
        ROUND (AVERAGE, 2) AVERAGE
   FROM MGMT$METRIC_DAILY
  WHERE     metric_label = 'SGA and PGA usage'
        AND column_label = 'PGA Total(MB)'
        AND target_name = :INSTANCE_N1                     --param_target_name
        AND rollup_timestamp >= TRUNC (SYSDATE) - 31  )          
ORDER BY 2 desc

--iops_on_disk
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP, 
      md.target_name key
      ,ROUND(md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Throughput'
  and  md.column_label = 'I/O Requests (per second)'
  and md.target_name IN (:INSTANCE_N1,:INSTANCE_N2)  --param_target_name
    and  md.rollup_timestamp  >= trunc(sysdate)-31

--throughput network
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP, 
      md.target_name key
      ,ROUND(md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Throughput'
  and  md.column_label = 'Network Bytes (per second)'
  and md.target_name IN (:INSTANCE_N1,:INSTANCE_N2)  --param_target_name
    and  md.rollup_timestamp  >= trunc(sysdate)-31

--average_read_latency
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP, 
      md.target_name key
      ,ROUND(md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Throughput'
  and  md.column_label = 'Average Synchronous Single-Block Read Latency (ms)'
  and md.target_name IN (:INSTANCE_N1,:INSTANCE_N2)  --param_target_name
    and  md.rollup_timestamp  >= trunc(sysdate)-31

--avg_active_session
SELECT TO_CHAR(md.ROLLUP_TIMESTAMP, 'YYYY-MM-DD') ROLLUP_TIMESTAMP, 
      md.target_name key
      ,ROUND(md.AVERAGE, 2) AVERAGE
  FROM MGMT$METRIC_DAILY md
  WHERE md.metric_label = 'Throughput'
  and  md.column_label = 'Average Active Sessions'
  and md.target_name IN (:INSTANCE_N1,:INSTANCE_N2)  --param_target_name
    and  md.rollup_timestamp  >= trunc(sysdate)-31	
	
--ADDM
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=1
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=2
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=3
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=4
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=5
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=6
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=7
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=8
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=9
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=10
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=11
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=12
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=13
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=14
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=15
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1
union all
SELECT REGEXP_SUBSTR (REGEXP_REPLACE (str_value, CHR (10), '\'),'[^\]+', 1,level) as ADDM
      FROM (  SELECT str_value
                FROM sysman.gc$metric_latest
               WHERE     metric_group_name = 'addm_report_database'
                     AND entity_name = :DBNAME_N
                     and str_value is not null
                     and column_index=16
            )                  
CONNECT BY LEVEL <= REGEXP_count(str_value, CHR (10) )+1

'	