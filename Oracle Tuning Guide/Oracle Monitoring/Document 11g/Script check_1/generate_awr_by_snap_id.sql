-- ----------------------------------------------------------------------------
-- Script Name	  		: generate_awr_by_snap_id.sql							
-- Script Purpose		: generate all required AWR snapshots by snap_id		
-- Usage		  		: Logon as owner oracle database create folder 'mkdir -p /u01/app/oracle/awr', then running as sysdba,								
-- Call Syntax			: sql>@generate_awr_by_snap_id.sql 		
-- Last Modified		: 12/12/2012			
-- Author				: Hiep.Nguyen@hyperlogy.com
-- ----------------------------------------------------------------------------
set serveroutput on

create or replace directory AWR_DIR as '/u01/app/oracle/awr';
prompt Runing AWR general by snap_id...

declare
	l_file			UTL_FILE.file_type;
	l_min_snap_id 	number;
	l_max_snap_id 	number;
	l_dbid 			number;
	l_instance_name varchar2(50);
	l_awr_name		varchar2(100);
	l_date 			varchar2(20);

 cursor get_cursor(p_snap_id dba_hist_snapshot.snap_id%type) is
     select startup_time,to_char(begin_interval_time,'yyyy_mm_dd_hh24_mi')
       from dba_hist_snapshot
      where snap_id = p_snap_id;
 
 current_startup_time  	dba_hist_snapshot.startup_time%type;
 next_startup_time  	dba_hist_snapshot.startup_time%type;
 l_begin_interval		varchar2(30);

begin

--select min(snap_id) into l_min_snap_id from dba_hist_snapshot where to_char(BEGIN_INTERVAL_TIME,'yyyy_mm_dd')='2013_03_11';
--select max(snap_id) into l_max_snap_id from dba_hist_snapshot where to_char(BEGIN_INTERVAL_TIME,'yyyy_mm_dd')='2013_03_11';

select min(snap_id) into l_min_snap_id from dba_hist_snapshot where to_char(BEGIN_INTERVAL_TIME,'yyyy_mm_dd')=to_char(sysdate,'yyyy_mm_dd');
select max(snap_id) into l_max_snap_id from dba_hist_snapshot where to_char(BEGIN_INTERVAL_TIME,'yyyy_mm_dd')=to_char(sysdate,'yyyy_mm_dd');


for ints in (select gd.dbid,gi.inst_id,gi.instance_name from gv$instance gi,gv$database gd where gi.inst_id=gd.inst_id) loop
 for i in l_min_snap_id..l_max_snap_id-1 loop

	open get_cursor(i);
		fetch get_cursor into current_startup_time,l_begin_interval; 
	close get_cursor;
	open get_cursor(i+1);
		fetch get_cursor into next_startup_time,l_begin_interval; 
	close get_cursor;
 
		 if ( current_startup_time = next_startup_time) then
		 	begin 
		 		
		        	begin
		         		l_awr_name:='awr_'||ints.instance_name||'_'||ints.inst_id||'_'|| i || '_' || (i+1) || '_'||l_begin_interval||'.html';
				 		l_file := UTL_FILE.fopen('AWR_DIR',l_awr_name, 'w', 32767);
		 					for l_awrrpt in (select output from table (DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(ints.dbid,ints.inst_id,i,i+1))) loop
								utl_file.put_line(l_file, l_awrrpt.output);
		 					end loop;
		 				utl_file.fclose(l_file);
		 			end;
		   		
		 	end;
		 end if;
 end loop;
end loop;
Exception
when others then
 RAISE_APPLICATION_ERROR(-20101,'Check date format or no value min/max!');
end;
/