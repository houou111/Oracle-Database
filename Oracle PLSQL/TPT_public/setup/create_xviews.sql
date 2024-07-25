--------------------------------------------------------------------------------
--
-- Name:        create_xviews.sql
-- Purpose:     Create views, grants and synonyms for X$ fixed tables 
--              to be accessible for all users
-- Usage:       Run from sqlplus as SYS: @create_xviews.sql
-- 
--
-- Author:      (c) Tanel Poder http://www.tanelpoder.com
-- 
-- Other:       This script will not overwrite any existing X_$% SYS objects as
--              those may be required by other tuning utilities.
--              You may want to remove synonym creation part and restrict
--              the grants in production environment.
--
--------------------------------------------------------------------------------

@saveset

set pagesize 0
set linesize 500
set trimspool on
set feedback off
set termout off 
set echo off 

spool create_xviews.tmp

select 'create view '||replace(name,'X$','X_$')||' as select * from '||name||';' 
from (
    select name from v$fixed_table where name like 'X$%'
    minus
    select replace(object_name,'X_$','X$') from dba_objects where owner = 'SYS' and object_name like 'X\_$%' escape '\' 
);


select 'grant select on SYS.'||replace(name,'X$','X_$')||' to public;'
from (
    select name from v$fixed_table where name like 'X$%'
    minus
    select replace(object_name,'X_$','X$') from dba_objects where owner = 'SYS' and object_name like 'X\_$%' escape '\' 
);

select 'create public synonym '||name||' for SYS.'||replace(name,'X$','X_$')||';' 
from (
    select name from v$fixed_table where name like 'X$%'
    minus
    select replace(object_name,'X_$','X$') from dba_objects where owner = 'SYS' and object_name like 'X\_$%' escape '\' 
);

spool create_xviews.lst

set termout on echo on feedback on

@create_xviews.tmp

host rm create_xviews.tmp
host del create_xviews.tmp

@loadset

prompt Done.