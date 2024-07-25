-- Alerted policy anomalies by client IP address

SELECT * FROM (
  SELECT 
   te.db_client, 
    db_user AS user_name, 
    db_server AS database_ip, 
    d.name AS event_action, 
    te.cluster_id, 
    securelog.report_lib.compact(statement,1024,'...[TRUNCATED]') statement, 
    count(*) AS count,
    ROW_NUMBER() OVER (ORDER BY securelog.report_lib.sortable_ip_address(te.db_client), count(*) desc, te.statement) AS current_row
  FROM   
    securelog.traffic_events te, 
    securelog.dictionary d
  WHERE d.value=te.action
    AND d.category='event_action'
    AND te.action IN (3, 4)
    AND te.time BETWEEN {?timerange_begin} AND {?timerange_end}
  GROUP BY d.name, te.db_client, db_user, db_server, te.cluster_id, te.statement
  ORDER BY 
    securelog.report_lib.sortable_ip_address(te.db_client),
    count desc,
    te.statement  
) stmts  
WHERE current_row <= 20000