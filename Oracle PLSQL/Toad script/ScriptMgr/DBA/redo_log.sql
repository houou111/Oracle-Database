set echo off
set feedback off
set linesize 512

prompt
prompt All Redo Logs in Database
prompt

column member format a60

SELECT	 A.GROUP#, B.MEMBER, A.THREAD#, A.SEQUENCE#, A.BYTES, A.MEMBERS,
		 A.ARCHIVED, A.STATUS, A.FIRST_CHANGE#, A.FIRST_TIME
	FROM V$LOG A, V$LOGFILE B
   WHERE A.GROUP# = B.GROUP#
ORDER BY A.GROUP#;