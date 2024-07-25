--Failed statements by user - detail main query

SELECT 
  securelog.report_lib.format_timestamp(time) as time, 
  client_ip, 
  user_name, 
  protected_database, 
  response_code,
  response_text, 
  response_detailed_status, 
  transaction_time,
  statement
FROM (
  SELECT
    tlqr.time,
    tlqr.client_ip, 
    tlqr.user_name, 
    tlqr.protected_database,
    tlqr.response_code,
    tlqr.response_text,
    tlqr.response_detailed_status,
    tlqr.transaction_time,
    tlqr.statement
  FROM  
    securelog.traffic_log_query_results tlqr 
  WHERE  tlqr.response_status = 5
    AND tlqr.query_id = {?search_identifier}
    AND (UPPER(tlqr.protected_database) = UPPER('{?database_name}') OR UPPER('{?database_name}')='ALL')
    AND (UPPER(tlqr.user_name) = UPPER('{?database_user}') OR UPPER('{?database_user}')='ALL')
    AND (ROWNUM <= {?row_limit} OR {?row_limit} = 0)
  ) stmts
ORDER BY protected_database,UPPER(user_name), user_name, time
