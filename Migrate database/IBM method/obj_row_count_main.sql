col spfname new_value spfname
select 'row_count_' || name || '_' || host_name || '.log' spfname from v$database, v$instance;

set lines 300 pages 0 feed off head off verify off time off timi off trims on
spool obj_row_count.sql
prompt spool &&spfname

select 'select '|| case when blocks*8192/1024/1024 > 100 then ' /*+ parallel (a, 20) */ ' end
	|| ' rpad(''' || owner ||'.'||table_name || ''',60) tab_name, count(1) cnt from ' || owner || '."' || table_name || '" a;' 
from 
(select owner, table_name, blocks from dba_tables where owner not in 
('ORDDATA','SYSMAN','APEX_030200','OWBSYS_AUDIT','OUTLN','OWBSYS','SCOTT','FLOWS_FILES','OE',
'OLAPSYS','MDDATA','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER',
'PUBLIC','SYSTEM','APPQOSSYS','XDB','SYS','MDSYS','EXFSYS','SI_INFORMTN_SCHEMA','ORACLE_OCM',
'WMSYS','ORDSYS','CTXSYS','ORDPLUGINS','DBSNMP')) order by owner, table_name;
prompt spool off;
spool off;
@obj_row_count.sql
