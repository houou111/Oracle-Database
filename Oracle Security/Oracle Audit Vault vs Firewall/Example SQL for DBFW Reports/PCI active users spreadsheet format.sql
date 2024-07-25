-- PCI Active Users sql query

SELECT DISTINCT 
  pd.name as db_name, 	
  d.name as db_type,
  du.user_name, 
  ss.client,
  MAX(sr.time) as last_login

FROM securelog.summary_records sr, securelog.summary_sessions ss, securelog.database_users du, securelog.protected_databases pd, securelog.dictionary d

WHERE sr.session_id=ss.session_id
  AND ss.user_id=du.user_id
  AND du.database_id=pd.database_id
  AND d.category='dialect' AND d.value=pd.dialect
  AND pd.is_pci_database > 0
  AND sr.time BETWEEN  {?timerange_begin} AND {?timerange_end} 
  AND (pd.name='{?database_name}' OR '{?database_name}'='ALL')

GROUP BY pd.name, d.name, du.user_name, ss.client
ORDER BY pd.name, d.name, UPPER(du.user_name), du.user_name, securelog.report_lib.sortable_ip_address(ss.client) 

