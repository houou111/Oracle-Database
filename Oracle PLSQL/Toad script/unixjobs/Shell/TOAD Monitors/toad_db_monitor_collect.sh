#!/bin/sh

#-------------------------------------------------------
# File: toad_db_monitor_collect.sh
# Desc: Perform Collection of TOAD Database Monitor Data
#       Note that TOADMonitoring.sql must be run in order 
#       to setup the necessary tables.
# Runs: Every Quarter Hour = 0,15,30,45 * * * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/08/2002  Added Added TJS_SQL_SET2
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_TOAD_UID/$ORACLE_TOAD_UPW
WHENEVER SQLERROR EXIT FAILURE
$TJS_SQL_SET2
INSERT INTO TOAD_V\$SESSION
  SELECT SYSDATE,
         SUM(Decode(Type, 'BACKGROUND', 1, 0)) system_sessions,
         SUM(Decode(Type, 'BACKGROUND', 0, Decode(Status, 'ACTIVE', 1, 0))) active_users,
         SUM(Decode(Type, 'BACKGROUND', 0, Decode(Status, 'ACTIVE', 0, 1))) inactive_users
    FROM V\$SESSION;
INSERT INTO TOAD_V\$SYSTEM_EVENT
  SELECT SYSDATE,
         sum(decode(event,'control file sequential read',total_waits,
                          'control file single write',total_waits,
                          'control file parallel write',total_waits,0)) ControlFileIO,
         sum(decode(event,'db file sequential read',total_waits,0)) SingleBlockRead,
         sum(decode(event,'db file scattered read',total_waits,0)) MultiBlockRead,
         sum(decode(event,'direct path read',total_waits,0)) DirectPathRead,
         sum(decode(event,'SQL*Net message to client',total_waits,
                          'SQL*Net message to dblink',total_waits,
                          'SQL*Net more data to client',total_waits,
                          'SQL*Net more data to dblink',total_waits,
                          'SQL*Net break/reset to client',total_waits,
                          'SQL*Net break/reset to dblink',total_waits,0)) SQLNET,
         sum(decode(event,'file identify',total_waits,
                          'file open',total_waits,0)) FileIO,
         sum(decode(event,'log file single write',total_waits,
                          'log file parallel write',total_waits,0)) LogWrite,
         sum(decode(event,'control file sequential read',0,
                          'control file single write',0,
                          'control file parallel write',0,
                          'db file sequential read',0,
                          'db file scattered read',0,
                          'direct path read',0,
                          'file identify',0,
                          'file open',0,
                          'SQL*Net message to client',0,
                          'SQL*Net message to dblink',0,
                          'SQL*Net more data to client',0,
                          'SQL*Net more data to dblink',0,
                          'SQL*Net break/reset to client',0,
                          'SQL*Net break/reset to dblink',0,
                          'log file single write',0,
                          'log file parallel write',0,total_waits)) Other
    FROM V\$SYSTEM_EVENT;
INSERT INTO TOAD_V\$SYSSTAT
  SELECT SYSDATE,
         SUM(DECODE(name,  'table scans (long tables)',  value, 0))/
         (SUM(DECODE(name,  'table scans (long tables)', value, 0))+SUM(DECODE(name, 'table scans (short tables)', value, 0)))*100 non_indexed_sql,
         100-SUM(DECODE(name,'table scans (long tables)',value,0))/
         (SUM(DECODE(name,'table scans (long tables)',value,0))+SUM(DECODE(name,'table scans (short tables)',value,0)))*100 indexed_sql,
         sum(decode(name,'db block changes',value,0)) block_changes,
         sum(decode(name,'db block gets',value,0)) current_reads,
         sum(decode(name,'consistent gets',value,0)) consistent_reads,
         sum(decode(name,'physical reads',value,0)) datafile_reads,
         sum(decode(name,'physical writes',value,0)) datafile_writes,
         sum(decode(name,'redo writes',value,0)) redo_writes,
         sum(decode(name,'parse count (total)',value,0)) parse,
         sum(decode(name,'execute count',value,0)) execute,
         sum(decode(name,'user commits',value,0)) commit,
         sum(decode(name,'user rollbacks',value,0)) rollback
    FROM V\$SYSSTAT
   WHERE NAME IN ('table scans (long tables)','table scans (short tables)',
                  'db block changes','db block gets','consistent gets',
                  'physical reads','physical writes','redo writes',
                  'redo writes','parse count (total)','execute count',
                  'user commits','user rollbacks');
INSERT INTO TOAD_V\$SGASTAT
  SELECT SYSDATE,
         ROUND(SUM(decode(pool,'large pool',(bytes)/(1024*1024),0)),2) sga_lpool,
         ROUND(SUM(decode(pool,NULL,decode(name,'db_block_buffers',(bytes)/(1024*1024),0),0)),2) sga_bufcache,
         ROUND(SUM(decode(pool,NULL,decode(name,'log_buffer',(bytes)/(1024*1024),0),0)),2) sga_lbuffer,
         ROUND(SUM(decode(pool,NULL,decode(name,'fixed_sga',(bytes)/(1024*1024),0),0)),2) sga_fixed,
         ROUND(SUM(decode(pool,'java pool',(bytes)/(1024*1024),0)),2) sga_jpool,
         ROUND(SUM(decode(pool,'shared pool',decode(name,'sql area',(bytes)/(1024*1024),0),0)),2) pool_sql_area,
         ROUND(SUM(decode(pool,'shared pool',decode(name,'free memory',(bytes)/(1024*1024),0),0)),2) pool_free_mem,
         ROUND(SUM(decode(pool,'shared pool',decode(name,'library cache',(bytes)/(1024*1024),0),0)),2) pool_lib_cache,
         ROUND(SUM(decode(pool,'shared pool',decode(name,'dictionary cache',(bytes)/(1024*1024),0),0)),2) pool_dict_cache,
         ROUND(SUM(decode(pool,'shared pool',decode(name,'library cache',0,'dictionary cache',0,'free memory',0,'sql area',0,(bytes)/(1024*1024)),0)),2) pool_misc,
         ROUND(SUM(decode(pool,'shared pool',(bytes)/(1024*1024),0)),2) sga_pool
    FROM V\$SGASTAT;
INSERT INTO TOAD_V\$LIBRARYCACHE
  SELECT SYSDATE,
         gets,
         gethits
    FROM V\$LIBRARYCACHE
   WHERE namespace = 'SQL AREA';
INSERT INTO TOAD_V\$LATCH
  SELECT SYSDATE,
         SUM(gets) LatchGets,
         SUM(misses) LatchMisses
    FROM V\$LATCH;
COMMIT;
EOF
TJS_RETURN_CODE=$?

. $TJS_DIR/tjs_stop_log.sh