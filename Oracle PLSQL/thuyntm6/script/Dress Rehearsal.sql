1. Make sure DC AIX and DR AIX (NFS /datat24) databases are in sync

On Primary
------------------------------------------------
alter system archive log current;
select max(SEQUENCE#) from v$archived_log;


On Standby
------------------------------------------------
column NAME format a50
select NAME,SEQUENCE#,APPLIED from v$archived_log order by sequence#;


put DC AIX tablespace in read only
alter tablespace DATAT24LIVE       read only;
alter tablespace HOMEBANKING_TBS   read only;
alter tablespace INDEXT24LIVE      read only;
alter tablespace USERS             read only;
alter tablespace USERS2            read only;

--> run rowcount script
. t24r14dc
cd /home/oracle/bin/row_count
nohup sh table_row_count_main.sh &

alter tablespace DATAT24LIVE       read write;
alter tablespace HOMEBANKING_TBS   read write;
alter tablespace INDEXT24LIVE      read write;
alter tablespace USERS             read write;
alter tablespace USERS2            read write;

alter system archive log current;
alter system archive log current;

On Primary
------------------------------------------------
alter system archive log current;
select max(SEQUENCE#) from v$archived_log;


On Standby
------------------------------------------------
column NAME format a50
select NAME,SEQUENCE#,APPLIED from v$archived_log order by sequence#;


2. Activate NFS mount point database

alter system archive log current;
alter system archive log current;
alter system set job_queue_processes=0;
show parameter job_
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
--From Fri Mar 02 22:28:34 2018
--TO Fri Mar 02 22:31:35 2018


Run row-count on DC AIX  continue COB progress

ALTER DATABASE ACTIVATE STANDBY DATABASE;
alter database open;
select name, open_mode from v$database;

--Run row-count on source database - DR AIX
. t24drodg
cd /home/oracle/bin/row_count
nohup sh table_row_count_main.sh &

3. Note down SYSTEM and UNDO datafile path

select file_name from dba_data_files where tablespace_name in (select tablespace_name from dba_rollback_segs);

SQL> select file_name from dba_data_files where tablespace_name in (select tablespace_name from dba_rollback_segs);

FILE_NAME
--------------------------------------------------------------------------------
/datat24/T24DR/datafile/undotbs1.409.916231191
/datat24/T24DR/datafile/system.403.916231021
/datat24/T24DR/datafile/undotbs2.415.916231305
/datat24/T24DR/datafile/undotbs1.287.916225949
/datat24/T24DR/datafile/undotbs2.288.916225949
/datat24/T24DR/datafile/system.413.916231255
/datat24/T24DR/datafile/undotbs1.466.932050095
/datat24/T24DR/datafile/undotbs2.467.932050107


4. Take backup of controlfile and create its copy

alter database backup controlfile to trace as '/datat24/T24DR/LinuxOne/controlfile/cont_backup.sql' resetlogs;
cp /datat24/T24DR/LinuxOne/controlfile/cont_backup.sql /datat24/T24DR/LinuxOne/controlfile/cont_backup_LinuxOne.sql

5. Shutdown and Unmount /datat24 mount point

shutdown immediate;
Unmount NFS mount point on AIX server  may be I have to skip this to tomorrow morning (certificate to logon by root become effective from 7h30 AM. tomorrow)
