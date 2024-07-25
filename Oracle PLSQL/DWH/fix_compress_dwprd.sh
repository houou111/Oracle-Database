date
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export ORACLE_SID=dwprd1
export PATH=$ORACLE_HOME/bin:$PATH:$ORACLE_HOME/OPatch

sqlplus / as sysdba @/home/oracle/dbscript/fix_compress_dwprd.sql $1
