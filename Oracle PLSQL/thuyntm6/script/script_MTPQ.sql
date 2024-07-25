set lines 300 pages 50000 trims on feed off termout off time off timi off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
col rep_start_time new_value rep_start_time
select sysdate rep_start_time from dual;

col rep_name new_value rep_name
select 'dbrole_' || instance_name || '_' || to_char(sysdate,'DDMONYYYY') || '.html' rep_name from v$instance;

set termout on
prompt
prompt This script will generate &rep_name File.
prompt
prompt Please wait...
set termout off

spool &rep_name

prompt <style type='text/css'>
prompt div#left  {width:20%; height: 87%;  position: absolute; outline: 0px solid; overflow:auto; top: 90px}
prompt div#right {width:78%; height: 87%;  position: absolute; outline: 0px solid; overflow:auto; top: 90px; right: 0; }
prompt div#top   {width:100%;height: 90px; position: absolute; outline: 0px solid; top:0px;left:0px; top: 0px;}

prompt body {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt p {font:bold 11pt Arial,Helvetica,sans-serif; color:#336699; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt table,tr,td {font:8pt Arial,Helvetica,Geneva,sans-serif;color:black;background:#FFFFCC; vertical-align:top;}
prompt th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:White; background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px}
prompt h1 {font:14pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99;
prompt  margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h2 {font:bold 11pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt h3 {font:10pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt h4 {font:bold 6pt Arial,Helvetica,sans-serif;color:#663300; vertical-align:top;margin-top:0pt; margin-bottom:0pt;}
prompt h5 {font:italic bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
prompt a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt </style><title>DB Info Report</title>


Prompt <a name="sec00"></a><p>
select '<p>' from dual;
set head on pages 50000;
set markup HTML on HEAD "<title>SQL*Plus Report</title>" TABLE "border='1'" SPOOL OFF ENTMAP ON PREFORMAT OFF

Prompt
prompt User:
Prompt
select username, account_status, lock_date, expiry_date, default_tablespace, created, profile  from dba_users
order by 1;

Prompt
Prompt User system granted:
Prompt
select grantee, privilege from dba_sys_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)')
order by grantee, privilege;

Prompt
Prompt User role granted:
Prompt
select grantee, granted_role from dba_role_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)')
order by grantee, granted_role;

Prompt
Prompt User table granted:
Prompt
select grantee, owner, table_name, privilege
from dba_tab_privs tblp inner join dba_users tblu on tblp.grantee=tblu.username
where grantee not in ( 'SYSTEM','SYS','MGMT_VIEW','DBSNMP','SYSMAN','HOANNT_DBA','TRUNGHX_DBA','THINHNH_DBA','DUYDX_DBA')
and tblu.account_status  in ('OPEN', 'EXPIRED(GRACE)')
order by 1,2,3,4;


Prompt
Prompt Role:
Prompt
select * from dba_roles order by role;

Prompt
Prompt Role role grant:
Prompt
select Role,  granted_role
from ROLE_ROLE_PRIVS
order by role, granted_role;

Prompt
Prompt Role System Granted:
Prompt
select Role, privilege
from ROLE_SYS_PRIVS
order by role, privilege;

Prompt
Prompt Role Table Granted:
Prompt
select Role, owner, table_name, column_Name, privilege
from ROLE_TAB_PRIVS
order by role,owner, table_name;

set markup HTML off
prompt Please check &rep_name file for errors, if any.
