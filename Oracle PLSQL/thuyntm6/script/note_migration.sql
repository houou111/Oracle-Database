ORA-39127: unexpected error from call to status := SYS.DBMS_EXPORT_EXTENSION.GET_V2_DOMAIN_INDEX_TABLES('XDB$ACL_XIDX','XDB','XMLINDEXMETHODS','XDB',0,'11.02.00.04.00',1,128) 
ORA-04063: package body "XDB.XIMETADATA_PKG" has errors
ORA-06508: PL/SQL: could not find program unit being called: "XDB.XIMETADATA_PKG"
ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 503
ORA-06512: at line 1
ORA-06512: at "SYS.DBMS_METADATA", line 9280s

grant execute on dbms_lob to xdb;
grant execute on dbms_sql to xdb;
grant execute on utl_file to xdb;
alter  package  XDB.XIMETADATA_PKG compile body;
alter package XDB.DBMS_XDBZ0 compile body;
=======================================

ORA-06512: at "SYS.DBMS_METADATA", line 10256
select * from sys.exppkgact$ where package='DBMS_CUBE_EXP' order by 1,2;
 
PACKAGE                        SCHEMA                                CLASS       LEVEL#
------------------------------ ------------------------------ ------------ ------------
DBMS_CUBE_EXP                  SYS                                       2         1050
DBMS_CUBE_EXP                  SYS                                       4         1050
DBMS_CUBE_EXP                  SYS                                       6         1050
 -- create a backup of the table SYS.EXPPKGACT$
create table sys.exppkgact$_bkup as select * from sys.exppkgact$;
 -- remove the references to DBMS_CUBE_EXP
delete from sys.exppkgact$ where package='DBMS_CUBE_EXP' and schema='SYS';
commit;

========================================
WMSYS.LTADM
grant execute on dbms_sql to WMSYS;
alter package WMSYS.LTADM compile body;

========================================
select object_name from sys.IBM_MIG_SRC_OBJECTS where owner='PUBLIC'
minus
select object_name from dba_objects where owner='PUBLIC'
SCHEMA_VERSION_REGISTRY
CREATE OR REPLACE PUBLIC SYNONYM SCHEMA_VERSION_REGISTRY FOR SYSTEM.SCHEMA_VERSION_REGISTRY;
table SYSTEM.SCHEMA_VERSION_REGISTRY
========================================
select table_name,count(*) from dba_indexes where table_owner='BIEE12CLSN_BIPLATFORM' 
group by table_name order by 1

========================================


purge dba_recyclebin;

select 'alter tablespace '||tablespace_name|| ' read only;' from dba_tablespaces where tablespace_name not in ('SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS2');

nohup sh mig_export_script.sh obimeta2 &
nohup sh mig_pre_stats.sh obimeta2 &

sqlplus / as sysdba @data_consistency.sql
sqlplus / as sysdba @obj_row_count_main.sql

FRONT||PKG_HNX
FRONT||PKG_BATCH



