1.Enabling Minimum Database-level Supplemental Logging
sqlplus / as sysdba
SELECT supplemental_log_data_min, force_logging FROM v$database;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE FORCE LOGGING;
4. Issue the following command to verify that these properties are now enabled.
SELECT supplemental_log_data_min, force_logging FROM v$database;
The output of the query must be YES for both properties.
5. Switch the log files.
SQL> ALTER SYSTEM SWITCH LOGFILE;
