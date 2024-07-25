SET ECHO OFF
rem ---------------------------------------------------------------------------
rem  Deutsche ORACLE-Anwendergruppe http://www.doag.org/
rem  Hanser Verlag http://www.hanser.de/
rem  Oracle Database 11g Release 2 "Der Oracle DBA" ISBN-13: 978-3-446-42081-6
rem ---------------------------------------------------------------------------
rem
rem  Group/Privilegien: SYSDBA
rem  Script Name......: system_activity_teardown.sql
rem  Author...........: Christian Antognini, Trivadis AG
rem                     christian.antognini@trivadis.com
rem  Date.............: October 2011
rem  Version..........: Oracle Database 10g/11g
rem  Description......: Remove the objects required by the system_activity.sql script.
rem  Usage............:
rem
rem  Input Parameter..:
rem  Output...........:
rem  Called by........:
rem  Requirements.....: The database connection has to be open.
rem  Remarks..........:
rem
rem ---------------------------------------------------------------------------
rem Changes:
rem DD.MM.YYYY Developer Change
rem ---------------------------------------------------------------------------
rem
rem ---------------------------------------------------------------------------

SET ECHO ON

DROP TYPE t_system_activity_tab;
DROP TYPE t_system_activity;
DROP TYPE t_system_wait_class_tab;
DROP TYPE t_system_wait_class;

DROP FUNCTION system_activity;

DROP PUBLIC SYNONYM system_activity;
