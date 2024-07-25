set echo off
set feedback off
set linesize 512

prompt
prompt All DB Links in Database
prompt

column host format a32
column db_link format a32

break on OWNER skip 1

SELECT	 A.OWNER, A.HOST, A.DB_LINK, A.USERNAME, A.CREATED,
		 DECODE (B.FLAG, 0, 'NO', 1, 'YES') "DEC", B.AUTHUSR, C.STATUS
	FROM DBA_DB_LINKS A, SYS.USER$ U, SYS.LINK$ B, DBA_OBJECTS C
   WHERE A.DB_LINK = B.NAME AND
         A.OWNER   = U.NAME AND
         B.OWNER#  = U.USER# AND
         A.DB_LINK = C.OBJECT_NAME AND
         A.OWNER   = C.OWNER AND
         C.OBJECT_TYPE = 'DATABASE LINK'
ORDER BY 1, 2, 3;