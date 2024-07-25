set lines 300 pages 50000 trims on feed off termout off time off timi off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
col rep_start_time new_value rep_start_time
select sysdate rep_start_time from dual;

col rep_name new_value rep_name
col file_name new_value file_name
select 'FAIL JOB in DB: ' || db_unique_name || '_' || pdb  rep_name from v$database,v$services;
select 'db_DHSXKD_failjob_X7_' ||to_char(sysdate,'DDMONYYYY') || '.html' file_name from dual;


spool /tmp/&file_name append

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
Prompt &rep_name:
Prompt

set lines 200
set pages 200
set long 999999
select sql_text,sql_id
from dba_hist_sqltext
where upper(sql_text) like '%CMS_TRANSACTION%'



set markup HTML off
spool OFF



