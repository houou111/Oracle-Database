-- Query for Database Traffic Analysis by User DDL Detail
SELECT 
  securelog.report_lib.format_timestamp(time) as time, 
  client_ip, 
  user_name, 
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
    tlqr.protected_database, 
    tlqr.statement_id, 
    tlqr.statement,
    tlqr.cluster_type, 
    tlqr.action_code 
  FROM  
    securelog.traffic_log_query_results tlqr 
    LEFT JOIN ( 
      SELECT DISTINCT 
        cluster_id, grammar_version, dialect 
      FROM 
        securelog.cluster_components
      WHERE component_type='cluster_set'
        AND component_value='definition'
    ) cc ON (tlqr.cluster_id = cc.cluster_id AND tlqr.grammar_version = cc.grammar_version AND tlqr.database_dialect = cc.dialect)
  WHERE  tlqr.response_status NOT IN (3,5)
    AND ( tlqr.cluster_type = 2
          OR ( tlqr.cluster_type IN (0,7) AND cc.cluster_id IS NOT NULL)
        )
    AND tlqr.query_id = {?search_identifier}
    AND (UPPER(tlqr.protected_database) = UPPER('{?database_name}') OR UPPER('{?database_name}')='ALL')
    AND (UPPER(tlqr.user_name) = UPPER('{?database_user}') OR UPPER('{?database_user}')='ALL')
    AND (ROWNUM <= {?row_limit} OR {?row_limit} = 0)
  ) stmts,
  securelog.dictionary d1, securelog.dictionary d2
WHERE d1.value = stmts.cluster_type
  AND d1.category = 'cluster_type'
  AND d2.value = stmts.action_code
  AND d2.category = 'log_action' 
ORDER BY protected_database,UPPER(user_name), user_name, time
