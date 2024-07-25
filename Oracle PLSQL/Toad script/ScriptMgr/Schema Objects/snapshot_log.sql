set echo off
set feedback off
set linesize 512

prompt
prompt All Snapshot Logs in Database
prompt

break on LOG_OWNER skip 1

SELECT	 LOG_OWNER, MASTER, LOG_TABLE, LOG_TRIGGER, ROWIDS, PRIMARY_KEY,
		 FILTER_COLUMNS, CURRENT_SNAPSHOTS
	FROM DBA_SNAPSHOT_LOGS
ORDER BY 1, 2;