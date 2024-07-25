set echo off
set feedback off
set linesize 512

prompt
prompt All Snapshots in Database
prompt

column snapshot format a62
column source format a62
column master_link format a32


SELECT	 OWNER,    NAME
		|| '.'
		|| TABLE_NAME "SNAPSHOT",
		 MASTER_VIEW,    MASTER_OWNER
		|| '.'
		|| MASTER "SOURCE",
		 MASTER_LINK, CAN_USE_LOG,
		 UPDATABLE, LAST_REFRESH,
		 REFRESH_GROUP, TYPE,
		 UPDATE_TRIG, UPDATE_LOG, ERROR,
		 MASTER_ROLLBACK_SEG, QUERY
	FROM DBA_SNAPSHOTS
ORDER BY 1, 3, 5;