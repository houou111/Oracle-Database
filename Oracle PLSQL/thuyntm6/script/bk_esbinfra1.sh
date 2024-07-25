#!/bin/sh
ORACLE_SID_DC=esbinfra1
export ORACLE_SID_DC

SWITCHLOG=/home/oracle/bin/bk_script/switchlog_"$ORACLE_SID_DC".sh
export SWITCHLOG

UCUSER=`id | cut -d"(" -f2 | cut -d ")" -f1`
export UCUSER

RMAN_LOG_FILE=/tmp/rman8083.log
BK_LOG="/tmp/bk_db_esbinf1_full_$(date '+%Y%M%d_%H%M').log"
if [ "$NB_ORA_CLIENT" = "dr-esb-db02-pub" ]
then
        exit 0
fi
# -----------------------------------------------------------------
# Initialize the log file.
# -----------------------------------------------------------------

> $RMAN_LOG_FILE
chmod 666 $RMAN_LOG_FILE
# -----------------------------------------------------------------
# switch log file
# -----------------------------------------------------------------
if [ "$UCUSER" = "root" ]
then
        echo > $SWITCHLOG
        echo "export ORACLE_HOME=/u01/app/oracle/db11" >> $SWITCHLOG
        echo "$ORACLE_HOME/bin/sqlplus -s srv_db_backup/Window#123#Tech@$ORACLE_SID_DC as sysdba <<EOF " >> $SWITCHLOG
        echo "alter system archive log current;" >> $SWITCHLOG
        echo "exit" >> $SWITCHLOG
        echo "EOF" >> $SWITCHLOG
        chmod 775 $SWITCHLOG
fi

# -----------------------------------------------------------------
# Log the start of this script.
# -----------------------------------------------------------------

echo Script $0 >> $RMAN_LOG_FILE
echo ==== started on `date` ==== >> $RMAN_LOG_FILE
echo >> $RMAN_LOG_FILE

ORACLE_HOME=/u01/app/oracle/db11
ORACLE_SID=esbinf11
TARGET_CONNECT_STR=/
RUN_AS_USER=oracle
RMAN=$ORACLE_HOME/bin/rman
CUSER=`id | cut -d"(" -f2 | cut -d ")" -f1`


if [ "$NB_ORA_FULL" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=0"
    SCHED_NAME="Full-Application-Backup"
elif [ "$NB_ORA_INCR" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=1"
    SCHED_NAME="Different-Application-Backup"
elif [ "$NB_ORA_CINC" = "1" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=1 CUMULATIVE"
elif [ "$BACKUP_TYPE" = "" ]
then
    BACKUP_TYPE="INCREMENTAL LEVEL=0"
fi

# -----------------------------------------------------------------
# rman commands for database pub.
# -----------------------------------------------------------------

CMD="
ORACLE_HOME=/u01/app/oracle/db11
export ORACLE_HOME
ORACLE_SID=esbinf11
export ORACLE_SID
$RMAN target $TARGET_CONNECT_STR nocatalog msglog $RMAN_LOG_FILE append <<EOF

# -----------------------------------------------------------------
# RMAN command section
# -----------------------------------------------------------------

RUN {
ALLOCATE CHANNEL ch00   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch01   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch02   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch03   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch04   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch05   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch06   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch07   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';

ALLOCATE CHANNEL ch08   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch09   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch10   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch11   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch12   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch13   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
ALLOCATE CHANNEL ch14   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch15   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';
SEND 'NB_ORA_SCHED=$SCHED_NAME,NB_ORA_POLICY=Backup-Esbinf1,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
CROSSCHECK BACKUP;
DELETE EXPIRED BACKUP;
BACKUP AS COMPRESSED BACKUPSET  $BACKUP_TYPE FORMAT 'bk_esbinf1%u_s%s_p%p_t%t' DATABASE;

CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
host \"$SWITCHLOG\";
BACKUP AS COMPRESSED BACKUPSET  FORMAT 'arch_esbinf1%u_s%s_p%p_t%t'  ARCHIVELOG ALL  DELETE INPUT;

RELEASE CHANNEL ch00;
RELEASE CHANNEL ch01;
RELEASE CHANNEL ch02;
RELEASE CHANNEL ch03;
RELEASE CHANNEL ch04;
RELEASE CHANNEL ch05;
RELEASE CHANNEL ch06;
RELEASE CHANNEL ch07;
RELEASE CHANNEL ch08;
RELEASE CHANNEL ch09;
RELEASE CHANNEL ch10;
RELEASE CHANNEL ch11;
RELEASE CHANNEL ch12;
RELEASE CHANNEL ch13;
RELEASE CHANNEL ch14;
RELEASE CHANNEL ch15;

# Control file backup
ALLOCATE CHANNEL ch00   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db01-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf11';
ALLOCATE CHANNEL ch01   TYPE 'SBT_TAPE' PARMS='ENV=(NB_ORA_CLIENT=dr-esb-db02-pub)' CONNECT='srv_db_backup/Window#123#Tech@esbinf12';

SEND 'NB_ORA_SCHED=$SCHED_NAME,NB_ORA_POLICY=Backup-Esbinf1,NB_ORA_SERV=dr-backup-01.headquarter.techcombank.com.vn';
BACKUP FORMAT 'ctrl_esbinf1%u_s%s_p%p_t%t' CURRENT CONTROLFILE;

RELEASE CHANNEL ch00;
RELEASE CHANNEL ch01;
}
EOF
"

if [ "$CUSER" = "root" ]
then
    su - $RUN_AS_USER -c "$CMD" >> $RMAN_LOG_FILE
    RSTAT=$?
else
    sh -c "$CMD" >> $RMAN_LOG_FILE
    RSTAT=$?
fi


if [ "$RSTAT" = "0" ]
then
    LOGMSG="ended successfully"
else
    LOGMSG="ended in error"
fi

# -----------------------------------------------------------------
# Log the completion of this script.
# -----------------------------------------------------------------

echo >> $RMAN_LOG_FILE
echo Script $0 >> $RMAN_LOG_FILE
echo ==== $LOGMSG on `date` ==== >> $RMAN_LOG_FILE
cp $RMAN_LOG_FILE $BK_LOG

exit $RSTAT



