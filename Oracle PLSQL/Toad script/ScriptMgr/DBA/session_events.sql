set echo off
set feedback off
set linesize 512

prompt
prompt Session Events
prompt

column event format a32

SELECT	 B.USERNAME, B.SID, B.SERIAL#, A.EVENT, A.TOTAL_WAITS,
		 A.TOTAL_TIMEOUTS, A.TIME_WAITED, A.AVERAGE_WAIT
	FROM V$SESSION_EVENT A, V$SESSION B
   WHERE A.SID = B.SID
ORDER BY 1;