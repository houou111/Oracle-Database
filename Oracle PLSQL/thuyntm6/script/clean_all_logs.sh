sfgdghdf243
###Delete log
15 3 * * * /home/oracle/DBSCRIPT/clean_all_logs.sh cobr14dc cobr14dc1 > /home/oracle/DBSCRIPT/log/clean_all_logs_cobr14dc1.out 2>&1
30 3 * * * /home/oracle/DBSCRIPT/clean_all_logs.sh t24r14dc t24r14dc1 > /home/oracle/DBSCRIPT/log/clean_all_logs_t24r14dc1.out 2>&1
###Oen postcob (except sunday)
01 22 * * 1,2,3,4,5,6 sh /home/oracle/R14SCRIPT/OPENCOB/OpenCob.sh > /home/oracle/R14SCRIPT/OPENCOB/log/OpenCob.out 2>&1
###Close postcob (except sunday)
01 19 * * 1,2,3,4,5,6 sh /home/oracle/R14SCRIPT/CLOSECOB/CloseCob.sh > /home/oracle/R14SCRIPT/CLOSECOB/log/CloseCob.out 2>&1

sh get_awr.sh 74341 74389 2153479117 1

# clone monthend (1st day of month)
40 07 1 * * sh /home/oracle/DBSCRIPT/monthend/CloneMonthend.sh > /home/oracle/DBSCRIPT/monthend/log/CloneMonthend.out 2>&1


###Delete log
15 3 * * * /home/oracle/DBSCRIPT/clean_all_logs.sh t24r14dc t24r14dc2 > /home/oracle/DBSCRIPT/log/clean_all_logs_t24r14dc2.out 2>&1

============clean_all_logs.sh

#!/bin/bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export DB_NAME=$1
export ORACLE_SID=$2
export SCRIPT_DIR=/home/oracle/DBSCRIPT
export PATH=$ORACLE_HOME/bin:$PATH
export RMAN_LOG_FILE=$SCRIPT_DIR/log/delete_archivelog_"$ORACLE_SID"_`date +%Y%m%d`.log
export DAY_AFTER=10
export OUTF=$SCRIPT_DIR/log/cleanup_audit_files_"$ORACLE_SID"_`date +%Y%m%d`.log

find $SCRIPT_DIR/log -mtime +10 -name "clear_all_logs_*.log" -exec rm {} \;
find $SCRIPT_DIR/log -mtime +10 -name "cleanup_audit_files_*.log" -exec rm {} \;
find $SCRIPT_DIR/log -mtime +10 -name "delete_archivelog_*.log" -exec rm {} \;

# Clean trace file by ADRCI - manual modify base on Homepaths of server
CMD="set base /u01/app/oracle;
set homepath diag/rdbms/$DB_NAME/$ORACLE_SID;
show homes;
PURGE -age 4320 -type ALERT;
purge -age 4320 -type INCIDENT;
purge -age 4320 -type TRACE;
purge -age 4320 -type CDUMP;
purge -age 4320 -type HM;
purge -age 4320 -type UTSCDMP;
echo 'Clean';"
echo $CMD > $SCRIPT_DIR/clean_"$ORACLE_SID".adi
chmod +x $SCRIPT_DIR/clean_"$ORACLE_SID".adi
adrci script=$SCRIPT_DIR/clean_"$ORACLE_SID".adi

# Clean audit file by OS
sh $SCRIPT_DIR/clean_audit_file.sh

# Delete archivelog all completed before sysdate - 3
rman target / nocatalog msglog $RMAN_LOG_FILE append <<EOF
crosscheck archivelog all;
DELETE FORCE NOPROMPT archivelog until time 'sysdate-3';
crosscheck archivelog all;
EXIT;
EOF

echo 'Done!'


======================clean_audit_file.sh

#!/bin/sh
echo `date '+%m/%d/%y %A %X'` > ${OUTF}
echo >> ${OUTF}
echo "SCRIPT NAME:   $0" >> ${OUTF}
echo "SERVER:        "`uname -n` >> ${OUTF}
echo "KEEP DURATION: $DAY_AFTER days" >> ${OUTF}
echo >> ${OUTF}
echo >> ${OUTF}
#
echo "Delete audit files owned by oracle..." >> ${OUTF}
echo >> ${OUTF}
echo >> ${OUTF}

# change directory to the audit file directory
ADUMP_DIR=`sqlplus -s / as sysdba <<EOF
set pages 0
set head off
set feed off
select value from v\\$parameter where value like '%adump%';
exit
EOF`

cd $ADUMP_DIR

echo >> ${OUTF}
echo "Deleting from directory:" >> ${OUTF}
echo "[$ADUMP_DIR]" >> ${OUTF}
echo >> ${OUTF}
echo "The total number of files in directory is:" >> ${OUTF}

# output the total count of audit files to outfile
ls -al | wc -l >> ${OUTF}
echo >> ${OUTF}
echo "Total number of files to be deleted is:" >> ${OUTF}

# output the total number of audit files that will be deleted
find . -type f -mtime +$DAY_AFTER -name "*.aud" | wc -l >> ${OUTF}
echo >> ${OUTF}

# delete the audit files
find . -type f -mtime +$DAY_AFTER -name "*.aud" | xargs rm
echo "Files successfully deleted." >> ${OUTF}
echo "Total number of files remaining:" >> ${OUTF}

# output the remaining count of audit files in the adump directory
ls -al | wc -l >> ${OUTF}
echo >> ${OUTF}
echo "Complete with delete." >> ${OUTF}
#
# Now email results
echo >> $OUTF
echo `date '+%m/%d/%y %A %X'` >> $OUTF
cat $OUTF | /bin/mailx -s "`uname -n` : delete old Oracle audit files" hoannt.it@techcombank.com.vn
exit