col spfname new_value spfname
select 'data_consistency_' || name || '_' || host_name || '.log' spfname from v$database, v$instance;

set lines 200 pagesize 1000 trims on
spool &&spfname

select to_char(sysdate,'DD-MON-YY HH24:MI:SS') sdate, name, open_mode, host_name from v$database, v$instance;

prompt owner and object_type wise valid invalid count:
col owner for a20
set lines 300 pages 5000
select owner,object_type, count(case when status='VALID' THEN 1 end) valid, count(case when status<>'VALID' THEN 1 end) invalid, count(*) total
from dba_objects where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER')
group by owner,object_type order by owner,object_type;

prompt owner wise object count
select owner, count(case when status='VALID' THEN 1 end) valid, count(case when status<>'VALID' THEN 1 end) invalid, count(*) total
from dba_objects where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER')
group by owner;

prompt Constraint Status :
select constraint_type, status, count(*) from dba_constraints
where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER')
 group by constraint_type,status order by constraint_type,status;

prompt Triger Status :
select status,count(*) from dba_triggers where owner not IN (
'SYSTEM','SYS','OUTLN','DBSNMP','WMSYS','XDB','SYSMAN','ORDSYS','OWBSYS','OLAPSYS','MDSYS','CTXSYS','EXFSYS',
'FLOWS_FILES','ORDDATA','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','ORACLE_OCM','ORDPLUGINS','SI_INFORMTN_SCHEMA','OWBSYS_AUDIT','OWBSYS',
'SCOTT','OE','MDDATA','SPATIAL_WFS_ADMIN_USR','APPQOSSYS','SPATIAL_CSW_ADMIN_USR','MGMT_VIEW','APEX_PUBLIC_USER')
group by status;

select to_char(sysdate,'DD-MON-YY HH24:MI:SS') from dual;

spool off

