-- Failed logins by user detail main query

SELECT 
  securelog.report_lib.format_timestamp(time) as time, 
  client_ip,
  (CASE
    WHEN user_name='unknown_username' AND database_dialect=1 AND UPPER(TO_CHAR(SUBSTR(response_text,1,23))) = 'LOGIN FAILED FOR USER '''
      THEN TRIM(TRAILING '''' FROM TRIM(TRAILING '.' FROM TO_CHAR(SUBSTR(response_text,24))))
    ELSE TO_CHAR(user_name)
  END) AS user_name, 
  protected_database, 
  os_user_name,
  response_code,
  response_text,
  response_detailed_status,
  transaction_time
FROM (
  SELECT
    time,
    tlqr.client_ip, 
    tlqr.user_name, 
    tlqr.protected_database,
    tlqr.database_dialect, 
    tlqr.response_code,
    tlqr.response_text,
    tlqr.response_detailed_status,
    tlqr.os_user_name,
    tlqr.transaction_time,
    tlqr.statement
  FROM 
    securelog.traffic_log_query_results tlqr
  WHERE
    tlqr.response_status=3
    AND tlqr.query_id = {?search_identifier}
    AND (UPPER(tlqr.protected_database) = UPPER('{?database_name}') OR UPPER('{?database_name}')='ALL')
    AND (UPPER(tlqr.user_name) = UPPER('{?database_user}') OR UPPER('{?database_user}')='ALL')
    AND (ROWNUM <= {?row_limit} OR {?row_limit} = 0)
) stmts
ORDER BY protected_database, UPPER(user_name), time
