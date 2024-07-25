set echo off
set heading off
set feedback off
set linesize 512

prompt
prompt Count Rows for All Current User Tables
prompt

SET TERM OFF 

spool count_all.tmp

select 'select '''||table_name||' = ''||count(*) from '||
        table_name||' having count(*) > 0;'
  from user_tables where table_name not like 'SYS_IOT_OVER_%' 
  order by table_name;

spool off

SET TERM ON 

@count_all.tmp