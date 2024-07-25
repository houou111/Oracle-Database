SET ECHO OFF
rem ---------------------------------------------------------------------------
rem  Input Parameter..: &1: interval between two samples
rem                     &2: number of samples
rem ---------------------------------------------------------------------------

SET ECHO OFF TERMOUT OFF FEEDBACK OFF SCAN ON VERIFY OFF ARRAYSIZE 1 PAGESIZE 25 LINESIZE 110

CLEAR BREAKS
CLEAR COLUMNS

COLUMN time FORMAT A8 TRUNCATE HEADING "Time"
COLUMN aas FORMAT 999,990.0 HEADING "AvgActSess"
COLUMN time_waited_other FORMAT 990.0 HEADING "Other%"
COLUMN time_waited_queueing FORMAT 990.0 HEADING "Queue%"
COLUMN time_waited_network FORMAT 990.0 HEADING "Net%"
COLUMN time_waited_administrative FORMAT 990.0 HEADING "Adm%"
COLUMN time_waited_configuration FORMAT 990.0 HEADING "Conf%"
COLUMN time_waited_commit FORMAT 990.0 HEADING "Comm%"
COLUMN time_waited_application FORMAT 990.0 HEADING "Appl%"
COLUMN time_waited_concurrency FORMAT 990.0 HEADING "Conc%"
COLUMN time_waited_cluster FORMAT 990.0 HEADING "Clust%"
COLUMN time_waited_system_io FORMAT 990.0 HEADING "SysIO%"
COLUMN time_waited_user_io FORMAT 990.0 HEADING "UsrIO%"
COLUMN time_waited_scheduler FORMAT 990.0 HEADING "Sched%"
COLUMN time_cpu FORMAT 990.0 HEADING "CPU%"

COLUMN global_name NEW_VALUE global_name
COLUMN day NEW_VALUE day

SELECT global_name, to_char(sysdate,'yyyy-mm-dd') AS day
FROM global_name;

TTITLE CENTER '&global_name / &day' SKIP 2

SET TERMOUT ON

SELECT to_char(tstamp,'hh24:mi:ss') AS time, 
       aas, 
       time_waited_other, 
       time_waited_queueing,
       time_waited_network,
       time_waited_administrative,
       time_waited_configuration, 
       time_waited_commit,
       time_waited_application, 
       time_waited_concurrency,
       time_waited_cluster,
       time_waited_system_io,
       time_waited_user_io,
       time_waited_scheduler,
       time_cpu
FROM table(system_activity(&1,&2));

UNDEFINE 1
UNDEFINE 2
UNDEFINE global_name
UNDEFINE day

TTITLE OFF

CLEAR BREAKS
CLEAR COLUMNS
