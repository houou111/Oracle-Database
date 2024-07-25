#!/bin/sh

#-------------------------------------------------------
# File: toad_space_manager_collect.sh
# Desc: Perform Collection of TOAD Space Manager Data
#       Note that TOADMonitoring.sql must be run in order 
#       to set up the necessary tables.
#       Also note that the TOAD Space Manager does not 
#       support the collection of statistics more than 
#       once per day.
# Runs: Midnight of Each Day = 0 0 * * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_TOAD_UID/$ORACLE_TOAD_UPW
set verify off
set echo on
INSERT INTO TOAD_TABLESPACES
           SELECT TABLESPACE_NAME, TRUNC(SYSDATE)
             FROM DBA_TABLESPACES;
INSERT INTO TOAD_DATA_FILES
           SELECT FILE_ID, TRUNC(SYSDATE), TABLESPACE_NAME, FILE_NAME, BYTES
             FROM DBA_DATA_FILES;
INSERT INTO TOAD_FREE_SPACE
           SELECT FILE_ID, TRUNC(SYSDATE), SUM(BYTES)
             FROM DBA_FREE_SPACE
            GROUP BY FILE_ID, TRUNC(SYSDATE);
INSERT INTO TOAD_FILESTAT
           SELECT FILE#, TRUNC(SYSDATE), PHYRDS, PHYWRTS,
                  PHYBLKRD, PHYBLKWRT, READTIM, WRITETIM
             FROM V\$FILESTAT;
COMMIT;
EOF

. $TJS_DIR/tjs_stop_log.sh