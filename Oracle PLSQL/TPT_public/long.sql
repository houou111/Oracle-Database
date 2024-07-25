col long_opname head OPNAME for a40
col long_target head TARGET for a25
col long_units  head UNITS  for a10

select 
	sid, 
	serial#, 
	opname long_opname, 
	target long_target, 
	sofar, 
	totalwork, 
	units long_units, 
	time_remaining, 
	start_time, 
	elapsed_seconds 
/*, target_desc, last_update_time, username, sql_address, sql_hash_value */ 
from 
	v$session_longops
where
	sid in (&1)
and sofar != totalwork
/


