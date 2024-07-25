-- for the table text
SELECT 
  db_name,
  cluster_id, 
  cluster_type,
  MIN(cluster_example_short) AS cluster_example,
  (CASE 
    WHEN count(DISTINCT user_name)=1 THEN MIN(user_name)
    WHEN count(DISTINCT user_name)>1 THEN 'Multiple users'
    ELSE 'unknown'
  END) AS user_name,
  cluster_type_str,
  session_date,
  SUM (statement_count) AS count
FROM (SELECT  
    db_name,
    cluster_id, 
    cluster_type,
    cluster_example_short, 
    user_name,
    d.category AS cluster_type_str,
    TRUNC(ts.time, 'DDD') AS session_date,
    statement_count
  FROM securelog.dictionary d, securelog.traffic_summaries ts
   WHERE (cluster_type=2 or cluster_type=3) 
    AND ts.time BETWEEN {?timerange_begin} AND {?timerange_end} 
    AND (ts.db_name='{?database_name}' OR '{?database_name}'='ALL')
    AND d.category='cluster_type' and d.value = ts.cluster_type
) stmts
GROUP BY 
  db_name, 
  session_date, 
  cluster_type, 
  cluster_type_str, 
  cluster_id
ORDER BY
  db_name, 
  session_date, 
  cluster_type, 
  cluster_type_str, 
  count desc

-- for the chart
SELECT db_name, 
  TRUNC(ts.time, 'DDD') AS slot, 
  SUM (statement_count) AS count
FROM securelog.traffic_summaries  ts
WHERE (cluster_type=2 or cluster_type=3)
  AND time BETWEEN {?timerange_begin} AND {?timerange_end} 
  AND ts.db_name='{?database_name}'
GROUP BY 
  TRUNC(ts.time, 'DDD'), 
  db_name
ORDER BY 
  TRUNC(ts.time, 'DDD'), 
  db_name



