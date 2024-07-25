
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
   
7. Check user co quyen DBA 
   SELECT GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'DBA' and GRANTEE not in ('SYS','SYSTEM','SYSMAN');

8. Check backup
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



