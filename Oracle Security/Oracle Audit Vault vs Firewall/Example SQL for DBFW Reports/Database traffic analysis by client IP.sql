-- Database traffic analysis by client IP main query

SELECT
 protected_database,
 client_ip,
 cluster_id,
 cluster_example,
 cluster_type, 
 SUM(count) AS count,
 securelog.LimitedListAgg(securelog.LimitedListAgg_T(user_name,',',500,'..[TRUNCATED]')) AS user_name
FROM (
SELECT 
    db_name AS protected_database,
    client AS client_ip,
    cluster_id,
    min(cluster_example_short) cluster_example, 
    d.name AS cluster_type,
    sum(statement_count) AS count,
    user_name
  FROM
    securelog.traffic_summaries ts, securelog.dictionary d
  WHERE d.category='cluster_type' 
    AND d.value = ts.cluster_type
    AND ts.time BETWEEN {?timerange_begin} AND {?timerange_end} 
    AND (ts.db_name='{?database_name}'  OR '{?database_name}'='ALL')
  GROUP BY db_name, client, cluster_id, d.name,user_name
) subquery
GROUP BY protected_database, client_ip, cluster_id, cluster_example, cluster_type
ORDER BY protected_database, securelog.report_lib.sortable_ip_address(client_ip), cluster_type, count desc

