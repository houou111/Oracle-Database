SELECT 
  tlq.title,
  securelog.report_lib.format_datetime(tlq.time_from) time_from, 
  securelog.report_lib.format_datetime(tlq.time_to) time_to, 
  tlq.records_count
FROM securelog.traffic_log_queries tlq
WHERE tlq.id = {?search_identifier}
