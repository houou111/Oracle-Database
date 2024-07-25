
=================================================== 
--------DBMS_REDEFINITION
http://docs.oracle.com/cd/B28359_01/server.111/b28310/tables007.htm#ADMIN11678
--1. Verify that the table is a candidate for online redefinition.  
BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE('T24LIVE','F_VERSION_LINK_DEFAULTS',DBMS_REDEFINITION.CONS_USE_PK);
END;
/
--move single partition of table
BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE(
   uname        => 'STEVE',
   tname        => 'SALESTABLE',
   options_flag => DBMS_REDEFINITION.CONS_USE_ROWID,
   part_name    => 'sal03q1');
END;
/
--2. Create an interim table (with the attribute which u want)
--parallel if table is too large
alter session force parallel dml parallel 4;
alter session force parallel query parallel 4;
--3. Start the redefinition process
   orderby_cols   IN VARCHAR2 := NULL,
   
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE('T24LIVE','F_VERSION_LINK_DEFAULTS','F_VERSION_LINK_DEFAULTS_INI',
null,dbms_redefinition.cons_use_pk);
END;
/
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE(
   uname       => 'STEVE',
   orig_table  => 'CUSTOMER',
   int_table   => 'INT_CUSTOMER',
   col_mapping => 'cid cid,  name name, addr_t(street, city, state, zip) addr');
END;
/

BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE(
   uname        => 'STEVE',
   orig_table   => 'salestable',
   int_table    => 'int_salestable',
   col_mapping  => NULL,
   options_flag => DBMS_REDEFINITION.CONS_USE_ROWID,
   part_name    => 'sal03q1');
END;
/
--4. Copy dependent objects. (Automatically create any triggers, indexes, materialized view logs, grants, and constraints
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
   uname                    IN  VARCHAR2,  
   orig_table               IN  VARCHAR2,  
   int_table                IN  VARCHAR2,
   copy_indexes             IN  PLS_INTEGER := 1,
   copy_triggers            IN  BOOLEAN     := TRUE,
   copy_constraints         IN  BOOLEAN     := TRUE,
   copy_privileges          IN  BOOLEAN     := TRUE,
   ignore_errors            IN  BOOLEAN     := FALSE,
   num_errors               OUT PLS_INTEGER,
   copy_statistics          IN  BOOLEAN     := FALSE);

DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('T24LIVE','F_VERSION_LINK_DEFAULTS','F_VERSION_LINK_DEFAULTS_INI',
   DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/

DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
   'STEVE','CUSTOMER','INT_CUSTOMER',DBMS_REDEFINITION.CONS_ORIG_PARAMS,
    TRUE, TRUE, TRUE, FALSE, num_errors, TRUE);
END;
/
--Manually create any local indexes on the interim table(partition table)
CREATE INDEX int_sales_index ON int_salestable 
(s_saledate, s_productid, s_custid)
TABLESPACE tbs_low_freq; 
--Register dependent object 
Register the original (Index1) and interim (Int_Index1) dependent objects.
DBMS_REDEFINITION.REGISTER_DEPENDENT_OBJECT(
   uname         => 'STEVE',
   orig_table    => 'T1',
   int_table     => 'INT_T1',
   dep_type      => DBMS_REDEFINITION.CONS_INDEX,
   dep_owner     => 'STEVE',
   dep_orig_name => 'Index1',
   dep_int_name  => 'Int_Index1');
END;
/
--5. Query the DBA_REDEFINITION_ERRORS view to check for errors.
select object_name, base_table_name, ddl_txt from       DBA_REDEFINITION_ERRORS;
--6. Synchronize the interim table 
BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE('T24LIVE','F_VERSION_LINK_DEFAULTS','F_VERSION_LINK_DEFAULTS_INI');
END;
/

BEGIN 
DBMS_REDEFINITION.SYNC_INTERIM_TABLE(
   uname      => 'STEVE', 
   orig_table => 'salestable', 
   int_table  => 'int_salestable',
   part_name  => 'sal03q1');
END;
/
--7. Complete the redefinition
BEGIN
DBMS_REDEFINITION.FINISH_REDEF_TABLE('T24LIVE','F_VERSION_LINK_DEFAULTS','F_VERSION_LINK_DEFAULTS_INI');
END;
/

BEGIN 
DBMS_REDEFINITION.FINISH_REDEF_TABLE(
   uname      => 'STEVE', 
   orig_table => 'salestable', 
   int_table  => 'int_salestable',
   part_name  => 'sal03q1');
END;
/
=================================================== 