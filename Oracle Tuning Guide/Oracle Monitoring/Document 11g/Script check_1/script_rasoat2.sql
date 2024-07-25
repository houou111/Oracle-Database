
1. Check version and platform database
	select version from gv$instance
	union 
	select length(addr)*4 || 'bits Production' word_length
	from v$process where rownum =1;
	
2. Check enable archivelog
	sql>archive log list;	
	
3. Check phan vung mountpoint

 a. Solaris: df_mountpoint.sh
	#!/bin/bash
	#Author:Hiep.nguyen@hyperlogy.com
	THRESHOLD=79
	df -h | while read _mountpoint
	do
		_value=`echo $_mountpoint | awk '{print $5}'|sed 's/%//'`
		p1=`echo $_mountpoint | awk '{print $1}'`
		p2=`echo $_mountpoint | awk '{print $2}'`
		p3=`echo $_mountpoint | awk '{print $3}'`
		p4=`echo $_mountpoint | awk '{print $4}'`
		p5=`echo $_mountpoint | awk '{print $5}'`
		p6=`echo $_mountpoint | awk '{print $6}'`
		p7=`echo $_mountpoint | awk '{print $7}'`
	if [ $_value == "capacity" ] ; then
		 printf "%-20s %-10s %-10s %-10s %-10s %-1s %-1s\n" "$p1" "$p2" "$p3" "$p4" "$p5" "$p6" "$p7"
		 _value=-1
	fi
	if [ $_value -gt $THRESHOLD ] ; then
	 	printf "%-20s %-10s %-10s %-10s %-10s %-1s\n" "$p1" "$p2" "$p3" "$p4" "$p5" "$p6"
	fi
	done

 b. AIX :df_mountpoint.sh
	#!/bin/bash
	THRESHOLD=79
	df -g | while read _mountpoint
	do
	_value=`echo $_mountpoint | awk '{print $4}'|sed 's/%//'`
	_value2=`echo $_mountpoint | awk '{print $5}'|sed 's/%//'`

	p1=`echo $_mountpoint | awk '{print $1}'`
	p2=`echo $_mountpoint | awk '{print $2}'`
	p3=`echo $_mountpoint | awk '{print $3}'`
	p4=`echo $_mountpoint | awk '{print $4}'`
	p5=`echo $_mountpoint | awk '{print $5}'`
	p6=`echo $_mountpoint | awk '{print $6}'`
	p7=`echo $_mountpoint | awk '{print $7}'`
	p8=`echo $_mountpoint | awk '{print $8}'`
	p9=`echo $_mountpoint | awk '{print $9}'`
	if [ $_value2 == "Used" ] ; then
	printf "%-25s %-1s %-10s %-10s %-10s %-10s %-10s %-1s %-1s\n" "$p1" "$p2" "$p3" "$p4" "$p5" "$p6" "$p7" "$p8" "$p9"
	_value=-1
	fi
	if [ $_value == "-" ] ; then
	_value=-1
	fi
	if [ $_value -gt $THRESHOLD ] ; then
	printf "%-25s %-13s %-10s %-10s %-10s %-10s %-1s\n" "$p1" "$p2" "$p3" "$p4" "$p5" "$p6" "$p7"
	fi
	done

4. Check tablespace free<5%
	SELECT /* + RULE */  df.tablespace_name "Tablespace"       
	  FROM dba_free_space fs,
	       (SELECT tablespace_name,SUM(bytes) bytes
	          FROM dba_data_files
	         GROUP BY tablespace_name) df
	 WHERE fs.tablespace_name (+)  = df.tablespace_name
	  GROUP BY df.tablespace_name,df.bytes
	   HAVING  Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1)<5
	    ORDER BY Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1);

5. Check session active
   -select count(1) from gv$session where status='ACTIVE';
   -show parameter session
6. Check dung luong datafile online
   -select sum(bytes/1024/1024/1024) from v$datafile where status='ONLINE';
7. Archive log duoc sinh ra trong tuan
	set lines 200
	set pagesize 1000
	col day format a11
	col 00h format a5
	col 01h format a5
	col 02h format a5
	col 03h format a5
	col 04h format a5
	col 05h format a5
	col 06h format a5
	col 07h format a5
	col 08h format a5
	col 09h format a5
	col 10h format a5
	col 11h format a5
	col 12h format a5
	col 13h format a5
	col 14h format a5
	col 15h format a5
	col 16h format a5
	col 17h format a5
	col 18h format a5
	col 19h format a5
	col 20h format a5
	col 21h format a5
	col 22h format a5
	col 23h format a5
	col Total_MB format a15
	col Total_switch_log format 9999

	select
	to_char(COMPLETION_TIME,'YYYY-MM-DD') day,
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'00',1,0)),'999') "00h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'01',1,0)),'999') "01h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'02',1,0)),'999') "02h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'03',1,0)),'999') "03h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'04',1,0)),'999') "04h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'05',1,0)),'999') "05h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'06',1,0)),'999') "06h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'07',1,0)),'999') "07h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'08',1,0)),'999') "08h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'09',1,0)),'999') "09h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'10',1,0)),'999') "10h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'11',1,0)),'999') "11h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'12',1,0)),'999') "12h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'13',1,0)),'999') "13h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'14',1,0)),'999') "14h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'15',1,0)),'999') "15h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'16',1,0)),'999') "16h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'17',1,0)),'999') "17h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'18',1,0)),'999') "18h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'19',1,0)),'999') "19h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'20',1,0)),'999') "20h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'21',1,0)),'999') "21h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'22',1,0)),'999') "22h",
	to_char(sum(decode(substr(to_char(COMPLETION_TIME,'HH24'),1,2),'23',1,0)),'999') "23h",
	round(sum(BLOCKS*BLOCK_SIZE)/1024/1024,3)||' MB' "Total_MB",  COUNT(*) "Total_switch_log"
	from v$archived_log
	where to_date(COMPLETION_TIME) > sysdate-7
	group by to_char(COMPLETION_TIME,'YYYY-MM-DD')
	order by day;

   
8. Check user co quyen DBA 
   SELECT GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'DBA' and GRANTEE not in ('SYS','SYSTEM','SYSMAN');

9. Check backup
	set lines 200
	col start_time format a25
	col end_time format a25
	col INPUT_BYTES_DISPLAY format a25
	col OUTPUT_BYTES_DISPLAY format a25
	col hrs format 999.99
	SELECT STATUS,
	INPUT_TYPE,
	OUTPUT_DEVICE_TYPE,
	         TO_CHAR (START_TIME, 'MM-DD-YYYY hh24:mi:ss') start_time,
	         TO_CHAR (END_TIME, 'MM-DD-YYYY hh24:mi:ss') end_time,
	         INPUT_BYTES_DISPLAY,
	         OUTPUT_BYTES_DISPLAY,
	         elapsed_seconds / 3600 hrs
	    FROM V$RMAN_BACKUP_JOB_DETAILS
	ORDER BY start_time asc;



