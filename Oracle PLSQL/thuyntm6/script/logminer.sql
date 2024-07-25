================================================
Steps to implement Logminer
================================================

--1 : Enable Archive Log
--2 : Enable Supplemental logging.
alter database add supplemental log data;
select supplemental_log_data_min from v$database;

--3 : Create a user with role, which will be given all the privileges to use log miner.
create role logmnr_admin;
grant create session to logmnr_admin;
grant select on v_$logmnr_contents to logmnr_admin;
grant select on v_$logmnr_parameters to logmnr_admin;
grant select on v_$logmnr_logs to logmnr_admin;
grant select on v_$archived_log to logmnr_admin;
grant  execute_catalog_role, select any dictionary, select any transaction, select any table, create tablespace, drop tablespace to logmnr_admin;
create user miner identified by miner;
grant logmnr_admin to miner;
alter user miner quota unlimited on users;

--4 : Specify a LogMiner dictionary. 3 options :
a) Using the Online Catalog
b) Extracting LogMiner dictionary to Redo Log files.
c) Extracting LogMiner dictionary to a Flat file.

--5 : Find the archive log (created in step 4 of Section 2) that you want to use to mine.
SELECT name, TO_CHAR(first_time, ‘DD-MON-YYYY HH24:MI:SS’) first_time
FROM v$archived_log
WHERE name IS NOT NULL AND first_time BETWEEN TO_DATE('20-MAR-2013 08:00:00', 'DD-MON-YYYY HH24:MI:SS')
AND TO_DATE('20-MAR-2013 10:59:00', 'DD-MON-YYYY HH24:MI:SS')
ORDER BY sequence#;

--6 : Add log files to the logminer for mining [OPTION]
Execute dbms_logmnr.add_logfile	(LogFileName=>'/u01/oradata/MYSID/archive/arch_803914076_1_22_.arc', Options=>dbms_logmnr.NEW); 
Execute dbms_logmnr.add_logfile	(LogFileName=>'/u01/oradata/MYSID/archive/arch_803914076_1_23.arc',	Options=>dbms_logmnr.ADDFILE); .

--6 : Start LogMiner.
--If Online catalog is used ( Section 2 : Step 8 : Scenario (a))
Execute DBMS_LOGMNR.START_LOGMNR(OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG); --uses the added log file for mining.

--Using CONTINUOUS_MINE
Alter session set NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
Execute DBMS_LOGMNR.START_LOGMNR(
STARTTIME => '19-MAR-2013 14:02:14', 
ENDTIME => SYSDATE, 
OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.CONTINUOUS_MINE ); --uses the log files between specified times and performs continuous mine.

--7 : Request the Redo data of interest.Query the V$LOGMNR_CONTENTS view. (You must have the SELECT ANY TRANSACTION privilege to query this view.)
SELECT username, operation,
DBMS_LOGMNR.MINE_VALUE(REDO_VALUE,’SCHEMA.TABLENAME.COLNAME’) REDO VALUE,
DBMS_LOGMNR.MINE_VALUE(UNDO_VALUE,’SCHEMA.TABLENAME.COLNAME’) UNDO VALUE,
sql_redo,sql_undo,
TO_CHAR(timestamp, ‘DD-MON-YYYY HH24:MI:SS’) timestamp,scn
FROM v$logmnr_contents
WHERE username = ‘SCOTT’ AND operation = ‘INSERT’ AND seg_owner = ‘SCOTT’;

--8 : Stop the miner
DBMS_LOGMNR.END_LOGMNR();