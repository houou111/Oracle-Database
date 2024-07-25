ORA-00700: soft internal error, arguments: [kskvmstatact: excessive swapping observed]

===============================================================================
--=========FLASHBACK
===============================================================================
--Check Earliest Flashback Database Time and SCN
COLUMN oldest_flash_scn FOR 999,999,999
SELECT oldest_flashback_scn,to_char(oldest_flashback_time,'yyyymmdd hh24:mi')
FROM  v$flashback_database_log

--Check recovery file dest size
SELECT
  ROUND((A.SPACE_LIMIT / 1024 / 1024 / 1024), 2) AS FLASH_IN_GB, 
  ROUND((A.SPACE_USED / 1024 / 1024 / 1024), 2) AS FLASH_USED_IN_GB, 
  ROUND((A.SPACE_RECLAIMABLE / 1024 / 1024 / 1024), 2) AS FLASH_RECLAIMABLE_GB,
  SUM(B.PERCENT_SPACE_USED)  AS PERCENT_OF_SPACE_USED
FROM  V$RECOVERY_FILE_DEST A,  V$FLASH_RECOVERY_AREA_USAGE B
GROUP BY  SPACE_LIMIT,   SPACE_USED ,   SPACE_RECLAIMABLE ;
 
select    name,
   floor(space_limit / 1024 / 1024) "Size MB",
   ceil(space_used / 1024 / 1024)   "Used MB"
from    v$recovery_file_dest
 order by     name;

--Create a guaranteed restore point:
1. select log_mode from v$database;  -- archivelog need to be enabled-- If ARCHIVELOG is not enabled then continue else skip to step 7.
2. shutdown immediate;
3. startup mount;
4. alter database archivelog;
5. alter database open;
6. create restore point F20190628 guarantee flashback database;
7. select * from v$restore_point;

--Flashback to the guaranteed restore point
1. select current_scn from v$database;
2. shutdown immediate;
3. startup mount;
4. select * from v$restore_point;
5. flashback database to restore point F20190506;
6. alter database open resetlogs;
exec dbms_scheduler.disable('T24LIVE.GATHERSTATS');
exec dbms_scheduler.disable('SYS.DBA_JOB_GATHER_NODE1');
exec dbms_scheduler.disable('SYS.DBA_JOB_GATHER_NODE2');
exec dbms_scheduler.disable('SYS.DBA_JOB_GATHER');
srvctl start database -d testcob

7. select to_char(current_scn) from v$database;

--Drop restorepoint
DROP RESTORE POINT F20190503;

--To recover the database to the restore point
RECOVER DATABASE UNTIL RESTORE POINT Before_upgrade;