rem ************************************************************************************
rem	  File name: sqlinfo.sql 
rem	  Purpose:   To collect complete details of a particular SQL ID
rem   
rem	  Authors:   Sandeep Redkar and Deepak Kenchappanavara
rem   Copyright: (c) http://www.ibm.com
rem 
rem   Warning:   Requires licence for Diagnostic Pack
rem
rem	  Usage:     Login as sysdba and run sqlinfo_main.sql script
rem              SQL>@sqlinfo_main.sql
rem ************************************************************************************


set lines 1000 pages 0 trims on feed off head off termout off time off timi off long 90000000;
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'STORAGE', false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);

undefine sqlid;
define sqlid='&1';

col min_snap_id new_value min_snap_id
select min(snap_id) min_snap_id from dba_hist_snapshot where begin_interval_time > trunc(sysdate-8);

col dbid new_value dbid
select dbid from v$database;

set lines 300 pages 50000 trims on feed off termout off verify off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col rep_name new_value rep_name
select 'sqlid_' || '&sqlid' || '_' || to_char(sysdate,'DDMONYYYY') || '.html' rep_name from v$instance;

spool &rep_name

prompt <style type='text/css'>
prompt body {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt p {font:11pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt table,tr,td {font:8pt Arial,Helvetica,Geneva,sans-serif;color:black;background:#FFFFCC; vertical-align:top;}
prompt th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:White; background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px}
prompt h1 {font:14pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99;
prompt  margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt </style><title>SQLID &sqlid</title>
prompt <BR><BR><H1><center>SQLID &sqlid Report</center></H1>
prompt <HR>


set head off pages 0;
select 'Report Generated on : ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') from dual;
select '<p>' from dual;
set head on pages 50000;

set markup HTML on HEAD "<title>SQL*Plus Report</title>" BODY "BGCOLOR=RED" TABLE "border='1'" SPOOL OFF ENTMAP ON PREFORMAT OFF

Prompt
prompt SQLID Details
Prompt

select inst_id, sql_id, child_number, plan_hash_value, parsing_schema_name, executions, buffer_gets, rows_processed, round(elapsed_time/1000000) elap, module, optimizer_mode
from    gv$sql where sql_id = '&sqlid';


Prompt
prompt SQL History Details
Prompt

select  a.instance_number, to_char(begin_interval_time, 'DD-MON-YY HH24:MI:SS') snap_time, a.snap_id, module, plan_hash_value, version_count, parsing_schema_name,
        executions_delta, buffer_gets_delta, rows_processed_delta, elapsed_time_delta/1000000 elap, cpu_time_delta
from    dba_hist_snapshot a,
        dba_hist_sqlstat b
where   a.instance_number = b.instance_number
and     a.dbid = b.dbid
and     a.snap_id = b.snap_id
and     b.sql_id = '&sqlid'
and		a.begin_interval_time > trunc(sysdate-30) 
order by a.snap_id;


Prompt
prompt Table Information
Prompt

with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
)
select owner, table_name, tablespace_name, num_rows, blocks, last_analyzed, sample_size, temporary, partitioned, iot_type
from    dba_tables a,
        table_data b
where   a.owner = b.object_owner
and     a.table_name = b.object_name;


Prompt
prompt Segment Statistics
Prompt

with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
),
all_objs as 
(
select owner, table_name, partitioned, 'TABLE' obj_type
from    dba_tables a,
        table_data b
where   a.owner = b.object_owner
and     a.table_name = b.object_name
union all
select owner, index_name, partitioned, 'INDEX' obj_type
from    dba_indexes i,
        table_data t
where   t.object_owner = i.table_owner
and     t.object_name = i.table_name
)
select t.owner, t.table_name segment_name, partition_name, nvl(segment_type,t.obj_type) segment_type, tablespace_name, bytes/1024/1024 seg_size_mb, 
	case when partitioned = 'YES' then 
	case when t.obj_type = 'TABLE' then
	(select count(1) from dba_tab_partitions p where p.table_owner = t.owner and p.table_name = t.table_name) || ' Partitions, ' ||
	(select count(1) from dba_tab_subpartitions p where p.table_owner = t.owner and p.table_name = t.table_name) || ' Sub-partitions, ' 
	when t.obj_type = 'INDEX' then
	(select count(1) from dba_ind_partitions p where p.index_owner = t.owner and p.index_name = t.table_name) || ' Partitions, ' ||
	(select count(1) from dba_ind_subpartitions p where p.index_owner = t.owner and p.index_name = t.table_name) || ' Sub-partitions, ' end || 
	nvl(to_char(sum(bytes/1024/1024) over (partition by s.owner, segment_name), '999999990.0'), 0) || ' MB Total Size' end total_seg_size
from dba_segments s, all_objs t where s.owner(+) = t.owner and s.segment_name(+) = t.table_name;

Prompt
prompt Indexes Details
Prompt

with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
)
select owner, index_name, table_name, tablespace_name, index_type, uniqueness, blevel, leaf_blocks, distinct_keys, clustering_factor, status, num_rows, last_analyzed, partitioned
from    dba_indexes i,
        table_data t
where   t.object_owner = i.table_owner
and     t.object_name = i.table_name;


Prompt
prompt Index and Column Statistics
Prompt

with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
)
select  c.INDEX_OWNER, c.TABLE_NAME, c.index_name,
        c.column_name "COLUMN_NAME", c.column_position,
        a.column_expression
from    dba_ind_columns c,
        dba_ind_expressions a,
        table_data t
where   c.table_owner = t.object_owner
and     c.table_name = t.object_name
and     a.index_name(+) = c.index_name
and     a.table_owner(+) = c.table_owner
and     a.index_owner(+) = c.index_owner
and     a.table_name(+) = c.table_name
and     a.column_position(+) = c.column_position
order by 1, 2, 3, 5
/



Prompt
prompt Column Statistics
Prompt

col nullable for a30
with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
)
select  owner, table_name, column_name, data_type || '(' || data_length || ')' data_type, NULLABLE, num_distinct, num_nulls, density, histogram, last_analyzed
from    dba_tab_columns c,
        table_data t
where   owner = t.object_owner
and     table_name = t.object_name
order by table_name, column_name
/


Prompt
prompt Object DDLs
Prompt

with TABLE_DATA as
(
select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%TABLE%'
union
select table_owner, table_name from dba_indexes where (owner, index_name) in (select object_owner, object_name from v$sql_plan where sql_id='&sqlid' and object_type like '%INDEX%')
union
select object_owner, object_name from dba_hist_sql_plan where sql_id = '&sqlid' and object_type like '%TABLE%' and dbid = &dbid
union
select table_owner, table_name from dba_indexes where (owner, index_name) in 
	(select object_owner, object_name from dba_hist_sql_plan where sql_id='&sqlid' and object_type like '%INDEX%' and dbid = &dbid)
),
all_objs as 
(
select owner, table_name
from    dba_tables a,
        table_data b
where   a.owner = b.object_owner
and     a.table_name = b.object_name
union all
select owner, index_name
from    dba_indexes i,
        table_data t
where   t.object_owner = i.table_owner
and     t.object_name = i.table_name
)
select owner, object_name, object_type "TYPE", 
	dbms_metadata.get_ddl(object_type, object_name , owner) ddl_text 
from (select distinct a.owner, a.object_name, case when object_type like '%TABLE%' then 'TABLE' when object_type like '%INDEX%' then 'INDEX' else object_type end object_type
	from dba_objects a, all_objs b 
where a.owner(+) = b.owner and a.object_name(+) = b.table_name);

Prompt
prompt SQL Plans from Memory
Prompt

set markup html off;

prompt <pre>
select plan_table_output from v$sql s, table(dbms_xplan.display_cursor(s.sql_id, s.child_number)) t where s.sql_id in ('&sqlid');
prompt </pre>

Prompt
prompt SQL Plans from AWR
Prompt
prompt <pre>

select * from table(dbms_xplan.display_awr('&sqlid'));


prompt </pre>


SET PAGES 0 HEAD OFF FEED OFF;
select '<BR><BR>' FROM DUAL;
SET PAGES 50000 HEAD ON FEED ON;

spool off;

set termout on
prompt Done.
prompt Please check &rep_name file for errors, if any.
prompt

undefine sqlid;
