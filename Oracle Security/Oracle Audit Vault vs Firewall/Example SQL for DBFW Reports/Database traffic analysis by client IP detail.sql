SELECT 
  securelog.report_lib.format_timestamp(time) as time, 
  client_ip, 
  user_name, 
  protected_database, 
  TO_CHAR(statement_id) AS statement_id, 
  securelog.report_lib.compact(statement,1024,'...[TRUNCATED]') statement, 
  cluster_type, 
  action_code
FROM (
  SELECT
    tlqr.time,
    tlqr.client_ip, 
    tlqr.user_name, 
    tlqr.protected_database, 
    tlqr.statement_id, 
    tlqr.statement,
    d1.name AS cluster_type, 
    d2.name AS action_code
  FROM  
    securelog.traffic_log_query_results tlqr, securelog.dictionary d1, securelog.dictionary d2
  WHERE 
    d1.value = tlqr.cluster_type
    AND d1.category = 'cluster_type'
    AND d2.value = tlqr.action_code
    AND d2.category = 'log_action' 
    AND tlqr.query_id = {?search_identifier}
    AND ROWNUM <=20000
) stmts
ORDER BY protected_database, securelog.report_lib.sortable_ip_address(client_ip), stmts.time