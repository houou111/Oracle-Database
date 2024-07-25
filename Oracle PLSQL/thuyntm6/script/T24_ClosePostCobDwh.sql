
set time on
set lines 200
prompt ++++++++++++++++++++ CLOSE COBR14-DR REPORT  ++++++++++++++++++++++++++
shutdown immediate;
startup mount;
alter database convert to physical standby;
shutdown immediate;
startup mount;
alter database open read only;
alter database recover managed standby database using current logfile disconnect;
exit

  GRANT CONNECT TO BP8;
  GRANT DBA TO BP8;
  GRANT RESOURCE TO BP8;
  GRANT TCB_PROFILE_ROLE TO BP8 WITH ADMIN OPTION;
  GRANT TCB_SEC_ROLE TO BP8 WITH ADMIN OPTION;
  GRANT TCB_SELECT_ANY_ROLE TO BP8 WITH ADMIN OPTION;
  GRANT TCB_UNIT_ROLE TO BP8 WITH ADMIN OPTION;
  GRANT TCB_USER_ROLE TO BP8 WITH ADMIN OPTION;
  ALTER USER BP8 DEFAULT ROLE ALL;
  -- 2 System Privileges for BP8 
  GRANT CREATE SESSION TO BP8;
  GRANT UNLIMITED TABLESPACE TO BP8;
  
  
  t24db04@oracle:/usr/openv/netbackup/logs> ls -lrt
total 32
-r-xr-xr-x    1 root     bin             985 Jul 07 2014  mklogdir
-r--r--r--    1 root     bin           11391 Jul 07 2014  README.debug
drwxrwxr-x    2 root     bin             256 Nov 17 2014  nbliveup
drwxrwxrwx    5 root     bin             256 Nov 20 2014  user_ops

NOTE: Shutting down MARK background process
Fri Nov 03 22:32:54 2017
Errors in file /u01/app/oracle/diag/rdbms/flex/flex1/trace/flex1_smon_15077.trc:
ORA-21779: duration not active
SMON (ospid: 15077): terminating the instance due to error 21779
Fri Nov 03 22:32:54 2017
System state dump requested by (instance=1, osid=15077 (SMON)), summary=[abnormal instance termination].
System State dumped to trace file /u01/app/oracle/diag/rdbms/flex/flex1/trace/flex1_diag_15027_20171103223254.trc
Dumping diagnostic data in directory=[cdmp_20171103223254], requested by (instance=1, osid=15077 (SMON)), summary=[abnormal instance termination].
Instance terminated by SMON, pid = 15077



