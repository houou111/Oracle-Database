set echo off
set feedback off
set linesize 512

prompt
prompt System Events
prompt

column event format a32

column total_waits     format	999,999,999,999 heading "Total Waits"
column total_timeouts  format	999,999,999,999 heading "Total Timeouts"
column time_waited     format	999,999,999,999 heading "Time Waited"
column average_wait    format	999,999,999,999 heading "Average Wait"

SELECT	 EVENT, TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED, AVERAGE_WAIT
	FROM V$SYSTEM_EVENT
ORDER BY 4 DESC;