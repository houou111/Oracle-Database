-- Database Traffic Analysis by OS user detail main query
SELECT 
  securelog.report_lib.format_timestamp(time) as time, 
  client_ip, 
  user_name, 
  os_user_name,
  protected_database, 
  securelog.report_lib.compact(statement,1024,'...[TRUNCATED]') statement, 
  TO_CHAR(statement_id) statement_id, 
  d1.name AS cluster_type, 
  d2.name AS action_code 
FROM (
  SELECT
    tlqr.time,
    tlqr.client_ip, 
    tlqr.user_name, 
    tlqr.os_user_name,
    tlqr.protected_database, 
    tlqr.statement_id, 
    tlqr.statement,
    tlqr.cluster_type, 
    tlqr.action_code 
  FROM  
    securelog.traffic_log_query_results tlqr
  WHERE tlqr.query_id = {?search_identifier}
    AND (UPPER(tlqr.protected_database) = UPPER('{?database_name}') OR UPPER('{?database_name}')='ALL')
    AND (UPPER(tlqr.user_name) = UPPER('{?database_user}') OR UPPER('{?database_user}')='ALL')
    AND (ROWNUM <= {?row_limit} OR {?row_limit} = 0)
  ) stmts,
  securelog.dictionary d1, securelog.dictionary d2
WHERE d1.value = stmts.cluster_type
  AND d1.category = 'cluster_type'
  AND d2.value = stmts.action_code
  AND d2.category = 'log_action' 
ORDER BY protected_database, UPPER(os_user_name), os_user_name, time
