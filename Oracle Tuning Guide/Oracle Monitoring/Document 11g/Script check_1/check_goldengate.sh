#!/usr/bin/ksh
#set -x

#######################################################################
# alarm san dr                           #
#######################################################################
###################################
### Parameters
###################################
HOSTNAME=""
LOGSDIR=""
SCRIPTNAME="check_goldengate.sh"


#####################################################
### Oracle Instance on production server
#####################################################

export NLS_DATE_FORMAT="yyyy-mm-dd hh24:mi:ss"
export ORACLE_HOME=
export ORACLE_SID=

export ORACLE_BASE=
export ORACLE_DB_NAME=
export ORA_CRS_HOME=

export ORACLE_ADMIN=
export TNS_ADMIN=

export GGATE=

export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$ORA_CRS_HOME/bin:/usr/bin:/usr/ccs/bin:/usr/local/bin:/usr/local/sbin:/usr/X11/bin:/usr
/openwin/bin:$GGATE

###################################
### Commands and files
###################################
SED="/usr/bin/sed"
AWK="/usr/bin/awk"
UMOUNT="/sbin/umount"
MOUNT="/sbin/mount"
PING="/usr/sbin/ping"
WC="/usr/bin/wc"
FSCK="/usr/sbin/fsck"
DF="/usr/sbin/df"
PS="/usr/bin/ps"
SU="/usr/bin/su"

CURDATE=`date +%d%b%y`

OUTF="$LOGSDIR/$SCRIPTNAME.$CURDATE"
EMAIL="$LOGSDIR/email.ora"

########################################
# Using this for send sms immedately or
# send only if database have error
# use this parameter for send every 6h
# to make sure crontab is still running
#########################################
SMS_STATE=0

#------------------------------------------------------------------------------
#                       CHECK STATUS GOLDEN GATE
#------------------------------------------------------------------------------
check_status () {
        echo ""
        echo "------------------------------------------------------------------------"
        echo "check time: `date +%d%b%y-%H:%M`"
        echo "------------------------------------------------------------------------"

        result=`$GGATE/ggsci <<EOF
                info all
                exit
        EOF`
}

#-----------------------------------------------------------------------------
#                       CHECK ERROR
#-----------------------------------------------------------------------------
check_error () {
        #original message
        original_mess=$(echo "$result"|awk '{if (NR>1 && NR<27) {print $0} }')
        echo "$original_mess" >> $OUTF 2>&1
        echo "$original_mess" 

        #save heading for sms
        heading=$(echo "$result"|grep "Program")
        #echo "heading:\n$heading" 

        #cut heading "Program"
        result_noheading=$(echo "$result"|sed '/Program/d')

        #find process HANG or BANDED or STOP
        err_mess=$(echo "$result_noheading"|awk '{if (NR>10 && NR<27) {print $0} }'|/usr/xpg4/bin/grep -E -e "STOP|AB
ENDED")
        #echo "Process bi loi:\n$heading\n$err_mess\n"

        #find delay process receive file
        err_mess_2=$(echo "$result_noheading"|awk '{if (NR>10 && NR<27) {print $0} }'|awk '$5>"03:00:08" {print}')
        #echo "Process nhan file cham >3h:\n$heading\n$err_mess_2\n"

        #find delay process apply
        err_mess_3=$(echo "$result_noheading"|awk '{if (NR>10 && NR<27) {print $0} }'|awk '$4>"03:00:01" {print}')
        #echo "Process apply bi cham >3h:\n$heading\n$err_mess_3\n"


        #final_msg="Process bi loi:\n$err_mess\n"
        #final_msg="$final_msg\nProcess nhan file cham >3h:\n$err_mess_2\n"
        #final_msg="$final_msg\nProcess apply cham >3h:\n$err_mess_3"
        #echo "$final_msg"

        #-----------------------------------------------------
        #       reset email content file
        #-----------------------------------------------------

        cat /dev/null > $EMAIL 2>&1

        #-----------------------------------------------------
        #       make sms & email content        
        #-----------------------------------------------------

        if [ "$err_mess" != "" ]; 
        then
                final_msg="Process bi loi:\n$err_mess\n"
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<font color='#FF0000'><b>Process bi loi:</font></b>" >>$EMAIL 2>&1
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<pre><font color='#0000FF'><b>$heading</font></b>\n$err_mess</pre>" >>$EMAIL 2>&1
        fi

        if [ "$err_mess_2" != "" ]; 
        then
                final_msg="$final_msg""Process nhan file cham >3h:\n$err_mess_2\n"
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<font color='#FF0000'><b>Process nhan file cham >3h:</font></b>" >>$EMAIL 2>&1
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<pre><font color='#0000FF'><b>$heading</font></b>\n$err_mess_2</pre>" >>$EMAIL 2>&1
        fi

        if [ "$err_mess_3" != "" ]; 
        then
                final_msg="$final_msg""Process apply cham >3h:\n$err_mess_3\n"
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<font color='#FF0000'><b>Process apply cham >3h:</font></b>"      >>$EMAIL 2>&1
                echo "---------------------------------------------------------------------" >>$EMAIL 2>&1
                echo "<pre><font color='#0000FF'><b>$heading</font></b>\n$err_mess_3</pre>\n" >>$EMAIL 2>&1
        fi

        #-------------------------------------------
        # just use for debugging
        #-------------------------------------------

        echo "\nFINAL_MESSAGE:\n$final_msg"

        #-------------------------------------------
        #send SMS when error occured
        #-------------------------------------------

        if [ "$final_msg" = "" ]; then
                echo > /dev/null
        else
                echo >/dev/null
                $ORACLE_HOME/bin/send_mail.pl
        fi

        echo "$final_msg" >> $OUTF 2>&1
}
#-----------------------------------------------------------------------------

###############
#   M A I N   #
###############
echo "" >> $OUTF 2>&1
echo "-------------------------------------------------------------------------" >> $OUTF 2>&1
echo " Checking GoldenGate: `date +%d%b%y-%H:%M`" >> $OUTF 2>&1
echo "-------------------------------------------------------------------------" >> $OUTF 2>&1
echo "" >> $OUTF 2>&1
check_status
check_error
