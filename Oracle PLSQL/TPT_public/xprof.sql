SELECT
	DBMS_SQLTUNE.REPORT_SQL_MONITOR(   
	   session_id=>&3,   
	   report_level=>'&1',
	   type => '&2') as report   
FROM dual
/
