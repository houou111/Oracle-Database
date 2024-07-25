#!/bin/sh

#-------------------------------------------------------
# File: toad_os_monitor_collect.sh
# Desc: Perform Collection of TOAD OS Monitor Data
#       Note that TOADMonitoring.sql must be run in order 
#       to setup the necessary tables.
# Runs: Every Quarter Hour = 0,15,30,45 * * * *
# Parm: None
#-------------------------------------------------------
#  1.0  07/11/2002  Initial script creation
#  1.1  07/12/2002  Added whenever sqlerror
#  1.2  08/09/2002  Bring up to date with monitor code
#-------------------------------------------------------

. $TJS_DIR/tjs_start_log.sh

if [ $TJS_RETURN_CODE -eq 0 ]
then
  ps -e | wc -l | sed 's/ *//g' | awk '{printf("insert into toad_os_monitor values (SYSDATE,\"ProcessCount\",%d,\"%s\");\n",NR,$0)}' | sed 's/"/'\''/g' > $TJS_TMP_FILE
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  ps -elf | cut -c1-132 | sed '/^$/d;/.*defunct.*/d;s/ *//;s/ [<+] / /;s/ S N / S /;s/\([0-9]\)[KM]/\1/;s/* //;s/\(Jan\) \([0-9]\)/\1-\2/g;s/\(Feb\) \([0-9]\)/\1-\2/g;s/\(Mar\) \([0-9]\)/\1-\2/g;s/\(Apr\) \([0-9]\)/\1-\2/g;s/\(May\) \([0-9]\)/\1-\2/g;s/\(Jun\) \([0-9]\)/\1-\2/g;s/\(Jul\) \([0-9]\)/\1-\2/g;s/\(Aug\) \([0-9]\)/\1-\2/g;s/\(Sep\) \([0-9]\)/\1-\2/g;s/\(Oct\) \([0-9]\) /\1-\2/g;s/\(Nov\) \([0-9]\)/\1-\2/g;s/\(Dec\) \([0-9]\)/\1-\2/g;s/  */,/g;'| awk -F, '{if(NR==1) for(i=1;i<=NF;i++) {if($(i)=="UID")UID=i;else if($(i)=="USER")UID=i;else if($(i)=="PID")PID=i;else if($(i)=="PPID")PPID=i;else if($(i)=="S")S=i;else if($(i)=="C")C=i;else if($(i)=="%CPU")C=i;else if($(i)=="PRI")PRI=i;else if($(i)=="SZ")SZ=i;else if($(i)=="VSZ")SZ=i;else if($(i)=="RSS")SZ=i;else if($(i)=="TIME")TIME=i;else if($(i)=="CMD")CMD=i;else if($(i)=="COMD")CMD=i;else if($(i)=="COMMAND")CMD=i;else if($(i)=="WCHAN")WCHAN=i} else if ($PPID!=0) {os=0;if(index($(WCHAN),":")!=0 || substr($(WCHAN),1,4)=="Jan-" || substr($(WCHAN),1,4)=="Feb-" || substr($(WCHAN),1,4)=="Mar-" || substr($(WCHAN),1,4)=="Apr-" || substr($(WCHAN),1,4)=="May-" || substr($(WCHAN),1,4)=="Jun-" || substr($(WCHAN),1,4)=="Jul-" || substr($(WCHAN),1,4)=="Aug-" || substr($(WCHAN),1,4)=="Sep-" || substr($(WCHAN),1,4)=="Oct-" ||substr($(WCHAN),1,4)=="Nov-" || substr($(WCHAN),1,4)=="Dec-")os--;print $(UID) "," $(PID) "," $(PPID) "," $(S) "," int($(C)) "," $(PRI) "," $(SZ) "," $(TIME+os) "," $(CMD+os);} }' | sort -t , -r -n -k 5,5 -k 7,7 | head -20 | awk '{printf("insert into toad_os_monitor values (SYSDATE,\"ProcessList\",%d,\"%s\");\n",NR,$0)}' | sed 's/"/'\''/g' >> $TJS_TMP_FILE
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  uptime | sed 's/.*[Uu]p *//;s/ *[Uu]ser.*//;s/[s(,)]//g;s/[Dd]ay/D/;s/[Hh]our/H/;s/[Mm]in/M/;s/:/ H /' | awk ' {days=0;hours=0;mins=0;users=0;for(i=2;i<=NF;i=i+2) {if($(i)=="D") {days=$(i-1) } else {if($(i)=="H") {hours=$(i-1) } else {mins=$(i-1) } } } users=$(NF);printf "%s,%s,%s\n%s\n",days,hours,mins,users }' | awk '{printf("insert into toad_os_monitor values (SYSDATE,\"UserAndUptime\",%d,\"%s\");\n",NR,$0)}' | sed 's/"/'\''/g' >> $TJS_TMP_FILE
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  vmstat 1 2 | sed '/^$/d;s/ *//;s/* //;/^[r0-9]/'\!'d' | awk 'BEGIN{memflg=0}memflg==1{runque=$(run);blkque=$(blk);us_pct=$(us);sy_pct=$(sy);id_pct=$(id)}$1~/r/{memflg=1;for(i=1;i<=NF;i++)if($(i)=="r")run=i;else if($(i)=="b")blk=i;else if($(i)=="w")blk=i;else if($(i)=="us")us=i;else if($(i)=="sy")sy=i;else if($(i)=="id")id=i}END{printf "%d\n%d\n%d\n%d\n%d\n",us_pct,sy_pct,id_pct,runque,blkque}' | awk '{printf("insert into toad_os_monitor values (SYSDATE,\"CPUAndProcessQueue\",%d,\"%s\");\n",NR,$0)}' | sed 's/"/'\''/g' >> $TJS_TMP_FILE
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
  SH=`file /bin/sh`;if [ `echo $SH | grep -c 'SPARC'` -eq 1 ];then OPT="-x";else if [ `echo $SH | grep -c 'PA-RISC'` -eq 1 ];then OPT="-t";else if [ `echo $SH | grep -c 'RISC System/6000'` -eq 1 ];then OPT="";else if [ `echo $SH | grep -c 'bash'` -eq 1 ];then OPT="-d";fi;fi;fi;fi;iostat $OPT 1 2 |  sed '/^$/d;s/^  *//;s/  *$//' |awk 'BEGIN {devflg=0; devcnt=0; hdrcnt=0;} $1 ~ /^[Uu]sage]|[Tt]ty|extended/ {devflg=0;}devflg == 1 {os=hdrcnt-NF;dev[++devcnt]=$1;drs[devcnt]=$(rs-os);if (ws > 0) dws[devcnt]=$(ws-os);elsedws[devcnt]=0;}$1 ~ /^[Dd]evice|[Dd]isks/ {devflg=1; devcnt=0; hdrcnt=NF;for (i=2;i<=NF;i++)if ($i == "kr/s") rs=i;else if ($i == "kw/s") ws=i;else if ($i == "Kb_read") rs=i;else if ($i == "Blk_read") rs=i;else if ($i == "Kb_wrtn") ws=i;else if ($i == "Blk_wrtn") ws=i;else if ($i == "r/s") rs=i;else if ($i == "w/s") ws=i;else if ($i == "bps") rs=i;}END {for (i=1;i<=devcnt;i++)print dev[i] "," drs[i] "," dws[i] "," drs[i]+dws[i];}' | sort -t, -k 1,1 -k 4,4 | sort -t, -u -k 1,1 | sort -t, -r -k 4,4 | awk '{printf("insert into toad_os_monitor values (SYSDATE,\"DiskIO\",%d,\"%s\");\n",NR,$0)}' | sed 's/"/'\''/g' >> $TJS_TMP_FILE
  TJS_RETURN_CODE=$?
fi

if [ $TJS_RETURN_CODE -eq 0 ]
then
$ORACLE_HOME/bin/sqlplus -s <<EOF
$ORACLE_TOAD_UID/$ORACLE_TOAD_UPW
WHENEVER SQLERROR EXIT FAILURE
@$TJS_TMP_FILE
EOF
TJS_RETURN_CODE=$?
fi

rm -f $TJS_TMP_FILE

. $TJS_DIR/tjs_stop_log.sh