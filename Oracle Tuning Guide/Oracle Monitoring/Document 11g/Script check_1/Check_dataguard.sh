#!/bin/bash
ORACLE_HOME=/u01/app/oracle/product/11.2.0.2/dbhome_1; export ORACLE_HOME
LOG_DIR=/home/oracle/binhtv/check_dr/log; export LOG_DIR
dataguard_stats="\$dataguard_stats"; export dataguard_stats
info_mess="DR dang tam dung apply de move datafile - DuongHN.Hyperlogy"
time=`/bin/date +%d-%b-%y-%Hh-%Mm`
get_infomation ()
{
result=`$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
connect sys/sysbilling12@$1 as sysdba;
set lines 150
select name, value from v$dataguard_stats where name='apply lag';
exit;
EOF`
}
check_information ()
{
#original_mess=$(echo "$result"|awk '{if (NR>1 && NR<38) {print $0} }')
#echo "$original_mess"

err_mess=$(echo "$result"|grep "ORA")
warn_mess=$(echo "$result"|grep "apply lag" |awk '$4 > "02:30:00" {print} ')
if [ "$err_mess" != "" ];
then
        /usr/binhtv/cmdsql.sh "$time#$1-ERROR:  #$err_mess  #Please check database instance"
        echo "$time#$1-ERROR:  #$err_mess  #Please check database instance" >> $LOG_DIR/check_$1_$time.log
fi
if [ "$warn_mess" != "" ];
then
        /usr/binhtv/cmdsql.sh "$time#$1-WARNING:  #$warn_mess"
        echo "$time  #$1 WARNING  #$warn_mess" >> $LOG_DIR/check_$1_$time.log
fi
warn_mess=$(echo "$result"|grep "apply lag" |awk '{print $4}')
echo $warn_mess
if [ "$warn_mess" = "" ];
then
        #/usr/binhtv/cmdsql.sh "$time#$1-WARNING:  #Apply lag is NULL.Please check apply & archive process"
        #echo "$time-#$1-WARNING:  #Apply lag is NULL.Please check apply & archive process " >> $LOG_DIR/check_$1_$time.log
        /usr/binhtv/cmdsql.sh "$time#$1-INFOMATION: $info_mess"
        echo "$time#$1-INFOMATION: $info_mess" >> $LOG_DIR/check_$1_$time.log
fi
}

get_infomation "BILLHN"
check_information "BILLHN"
get_infomation "MOBICARDHN"
check_information "MOBICARDHN"
