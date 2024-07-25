set linesize 1000
spool privilege.log
prompt ++++++++++++++++ Users: ++++++++++++++++
select username, account_status, lock_date, expiry_date, default_tablespace, created, profile  from dba_users;

prompt ++++++++++++++++ User_System_Granted: ++++++++++++++++
select grantee, privilege from dba_sys_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username 
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')  
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)')
order by grantee, privilege;

prompt ++++++++++++++++ User_Role_Granted: ++++++++++++++++
select grantee, granted_role from dba_role_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username 
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')  
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)')
order by grantee, granted_role;

prompt ++++++++++++++++ User_Table_Granted: ++++++++++++++++
select grantee, owner, table_name, privilege, username 
from dba_tab_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username 
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')  
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)');

prompt ++++++++++++++++ Roles: ++++++++++++++++
select * from dba_roles;

prompt ++++++++++++++++ Role_Role_Granted: ++++++++++++++++
select tblu.Role,  granted_role 
from ROLE_ROLE_PRIVS tblp inner join dba_roles tblu on tblp.role=tblu.role 
where  tblu.role  like ' %'   
order by role, granted_role;

prompt ++++++++++++++++ Role_System_Granted: ++++++++++++++++
select tblu.Role, privilege 
from ROLE_SYS_PRIVS tblp inner join dba_roles tblu on tblp.role=tblu.role 
where tblu.role  like ' %'   order by role, privilege;

prompt ++++++++++++++++ Role_Table_Granted: ++++++++++++++++
select tblu.Role, owner, table_name, column_Name, privilege 
from ROLE_TAB_PRIVS tblp inner join dba_roles tblu on tblp.role=tblu.role 
where tblu.role  like ' %'  order by role, table_name;

prompt ++++++++++++++++ Columns in all tables: ++++++++++++++++
select *  from all_tab_cols 
where owner not in ('SYS', 'SYSTEM','DBSNMP', 'MGMT_VIEW', 'SYSMAN', 'PA_AWR_USER', 'OUTLN', 'OLAPSYS', 'OWBSYS', 'ORDPLUGINS', 'XDB', 'OWBSYS_AUDIT', 'APEX_030200', 'APPQOSSYS', 'EXFSYS','ORDSYS','SI_INFORMTN_SCHEMA','ANONYMOUS','CTXSYS','ORDDATA','WMSYS','MDSYS','FLOWS_FILES','SPATIAL_WFS_ADMIN_USR','DIP','MDDATA','ORACLE_OCM','SPATIAL_CSW_ADMIN_USR','APEX_PUBLIC_USER','XS$NULL','SCOTT' ) order by owner, table_name, column_name;
spool off