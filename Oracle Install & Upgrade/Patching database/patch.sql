
1. Patch Installation Prerequisites
1.1.OPATCH
unzip p688... -d $ORACLE_HOME/

./opatch version 
./opatch lsinventory -oh $ORACLE_HOME 

--stop EM agent on both node
<ORACLE_HOME>/bin/emctl stop dbconsole
2. Patching Oracle RAC Database Homes and the GI Home Together
--ACFS File System Is Not Configured and Database Homes Are Not Shared
--root# export PATH=$PATH:$ORACLE_HOME/OPatch
root# $GRID_HOME/OPatch/opatchauto apply  /u01/software/27967747/27967747 -analyze
root# $GRID_HOME/OPatch/opatchauto apply  /u01/software/27923320/27923320 -analyze

--shutdown database
shutdown transactional database

--rollback conflict patch set
[oracle@dr-core-db-test02 ~]$ cd $ORACLE_HOME/OPatch
[oracle@dr-core-db-test02 OPatch]$ ./opatch rollback -id 18377986

--apply patch set
$GRID_HOME/OPatch/opatchauto apply  /u01/software/27967747/27967747 
$GRID_HOME/OPatch/opatchauto apply  /u01/software/27923320/27923320 

--before start database- check privilege of file oracle, oracleO
[oracle@dc-core-db-01 bin]$ ls -lrt oracle* 
-rwsr-s--x. 1 oracle oinstall 285580976 Dec 15  2017 oracleO
-rwsr-s--x. 1 oracle asmadmin 285630624 Dec 15  2017 oracle

cd $ORACLE_HOME/bin
chmod 6751 oracleO
chown oracle:oinstall oracleO
chown oracle:asmadmin oracle


-rwsr-s--x. 1 grid oinstall 257858952 Dec 14  2017 oracleO
-rwsr-s--x. 1 grid oinstall 257858952 Dec 14  2017 oracle

chown grid:oinstall oracleO
chown grid:oinstall  oracle


[oracle@dr-core-db-01 bin]$ ls -lrt oracle*
-rwsr-s--x. 1 oracle oinstall 209923776 Dec 12  2017 oracleO
-rwsr-s--x. 1 oracle oinstall 209923776 Dec 12  2017 oracle


OPatchSession cannot load inventory for the given Oracle Home /u01/app/oracle/product/11.2.0/dbhome_1. Possible causes are:
   No read or write permission to ORACLE_HOME/.patch_storage
   Central Inventory is locked by another OUI instance
   No read permission to Central Inventory
   The lock file exists in ORACLE_HOME/.patch_storage
   The Oracle Home does not exist in Central Inventory



--startup database and run datapatch
startup database
cd $ORACLE_HOME/OPatch
./datapatch –verbose


 /u01/app/12.1.0/grid/bin/crsctl stop crs
 
==========================ERROR=============================================
==========================ERROR no1 -- JAVA
--error
JVMJ9GC019E -Xms too large for -Xmx
JVMJ9VM015W Initialization error for library j9gc24(2): Failed to initialize
Could not create the Java virtual machine.

OPatch failed with error code 1

--error
Error occurred during initialization of VM
Initial heap size set to a larger value than the maximum heap size

OPatch failed with error code 1

-->export _JAVA_OPTIONS=-Xms512m
-->vi file opatch , increase value of xmx
-->http://sunoracleworld.blogspot.com/2017/06/autopatch-analyze-failed-with.html
1. Check and compare the Java version on al node – In my case it was identical.
2. Go to $GRID_HOME/oui
take the backup of oraparam.ini file and remove the # from below line -
JRE_MEMORY_OPTIONS=" -Xms150m -Xmx256m -XX:MaxPermSize=128M"


==========================ERROR no2 when run /u01/app/12.1.0/grid/OPatch/opatchauto apply  /u01/software/27967747 -analyze
 Following patches have conflicts. Please contact Oracle Support and get the merged patch of the patches :
18377986, 27547329

Whole composite patch Conflicts/Supersets are:

Composite Patch : 27547329

        Conflict with 18377986
18377986
		
		
-->patch in database home		
--rollback patch
[oracle@dr-core-db-test02 ~]$ cd $ORACLE_HOME/OPatch
[oracle@dr-core-db-test02 OPatch]$ ./opatch rollback -id 18377986
--apply new patch
--apply 18377986 patch

==========================ERROR no3
---------------------------Patching Failed--------------------------------- 
Command execution failed during patching in home: /u01/app/12.1.0/grid, host: dr-core-db-test02. 
Command failed: /u01/app/12.1.0/grid/perl/bin/perl -I/u01/app/12.1.0/grid/perl/lib -I/u01/app/12.1.0/grid/OPatch/auto/dbtmp/bootstrap_dr-core-db-test02/patchwork/crs/install /u01/app/12.1.0/grid/OPatch/auto/dbtmp/bootstrap_dr-core-db-test02/patchwork/crs/install/rootcrs.pl -prepatch 
Command failure output: 
Using configuration parameter file: /u01/app/12.1.0/grid/OPatch/auto/dbtmp/bootstrap_dr-core-db-test02/patchwork/crs/install/crsconfig_params 
2018/08/16 17:15:51 CLSRSC-177: Failed to add (property/value):('SOFTWAREPATCH'/'') for checkpoint 'ROOTCRS_PREPATCH' (error code 1) 

Oracle Clusterware active version on the cluster is [12.1.0.2.0]. The cluster upgrade state is [NORMAL]. The cluster active patch level is [602420069]. 
CRS-1158: There was an error setting the cluster to rolling patch mode. 
CRS-4000: Command Start failed, or completed with errors. 
2018/08/16 17:15:51 CLSRSC-430: Failed to start rolling patch mode 

-->
[grid@dr-core-db-test02 ~]$  /u01/app/12.1.0/grid/bin/crsctl query crs softwarepatch
CRS-4467: Error code 8 in retrieving the software patch level for host dr-core-db-test02
CRS-1191: There was an error retrieving the Oracle Clusterware software patch level.
CRS-4000: Command Query failed, or completed with errors
--> on root run
clscfg -patch 

==========================ERROR no4
---------------------------Patching Failed---------------------------------
Command execution failed during patching in home: /u01/app/oracle/product/12.1.0/dbhome_1, host: dr-core-db-test01.
Command failed:  /u01/app/oracle/product/12.1.0/dbhome_1/OPatch/opatchauto  apply /u01/software/27967747 -oh /u01/app/oracle/product/12.1.0/dbhome_1 -target_type rac_database -binary -invPtrLoc /u01/app/12.1.0/grid/oraInst.loc -jre /u01/app/12.1.0/grid/OPatch/jre -persistresult /u01/app/oracle/product/12.1.0/dbhome_1/OPatch/auto/dbsessioninfo/sessionresult_dr-core-db-test01_rac.ser -analyzedresult /u01/app/oracle/product/12.1.0/dbhome_1/OPatch/auto/dbsessioninfo/sessionresult_analyze_dr-core-db-test01_rac.ser
Command failure output:
==Following patches FAILED in apply:

Patch: /u01/software/27967747/27547329
Log: /u01/app/oracle/product/12.1.0/dbhome_1/cfgtoollogs/opatchauto/core/opatch/opatch2018-08-17_15-43-10PM_1.log
Reason: Failed during Patching: oracle.opatch.opatchsdk.OPatchException: Prerequisite check "CheckActiveFilesAndExecutables" failed.

After fixing the cause of failure Run opatchauto resume

]
OPATCHAUTO-68061: The orchestration engine failed.
OPATCHAUTO-68061: The orchestration engine failed with return code 1
OPATCHAUTO-68061: Check the log for more details.
OPatchAuto failed.

OPatchauto session completed at Fri Aug 17 15:43:28 2018
Time taken to complete the session 3 minutes, 11 seconds

 opatchauto failed with error code 42
 
 -->opatch error code 73: Prerequisite check "CheckActiveFilesAndExecutables" failed. (Doc ID 1942237.1)
 check log file --> find out <filename>
1. As 'root' user, identify process using this file/library:
  # fuser <filename>
  # lsof <filename>

2. You may shutdown application or kill process using above file/library before trying opatch again.
  # crsctl stop crs -f
  # fuser <filename>
  # kill -9 <ospid of process identified above>

  
==========================ERROR no5
SELECT t.RECID FROM T24LIVE.FBNK_FUNDS_TRANSFER t 
WHERE (NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='ACIB' 
or NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='ACIA');


alter system set "_fix_control" = '16324844:OFF';  

--> apply newer patch for patch 18377986

==========================ERROR no6

==========================ERROR no7
==========================ERROR no8
  
  =========
  Patch applicability verification failed on home /u01/app/oracle/product/12.1.0/dbhome_1

Execution of [OPatchAutoBinaryAction] patch action failed, check log for more details. Failures:


Patch Target : dr-core-db-test01->/u01/app/oracle/product/12.1.0/dbhome_1 Type[rac]
Details: [OPATCHAUTO-72085: Execution mode invalid.
OPATCHAUTO-72085: Cannot execute in rolling mode, as execution mode is set to non-rolling for patch ID 27923320.
OPATCHAUTO-72085: Execute in non-rolling mode by adding option -nonrolling during execution. e.g. <OracleHome>/OPatch/opatchauto apply <Patch_Location> -nonrolling
After fixing the cause of failure Run opatchauto resume

]
OPATCHAUTO-68061: The orchestration engine failed.
OPATCHAUTO-68061: The orchestration engine failed with return code 1
OPATCHAUTO-68061: Check the log for more details.
OPatchAuto failed.

OPatchauto session completed at Mon Aug 20 13:19:13 2018
Time taken to complete the session 1 minute, 22 seconds


=======================
[oracle@dr-core-db-test02 OPatch]$  ./datapatch -verbose
SQL Patching tool version 12.1.0.2.0 Production on Tue Aug 21 23:27:02 2018
Copyright (c) 2012, 2016, Oracle.  All rights reserved.

Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_14012_2018_08_21_23_27_02/sqlpatch_invocation.log

Connecting to database...OK
Bootstrapping registry and package to current versions...done
Determining current state...done

Current state of SQL patches:
Patch 27923320 (Database PSU 12.1.0.2.180717, Oracle JavaVM Component (JUL2018)):
  Installed in the binary registry only
Bundle series PSU:
  ID 180717 in the binary registry and ID 171017 in the SQL registry

Adding patches to installation queue and performing prereq checks...
Installation queue:
  Nothing to roll back
  The following patches will be applied:
    27923320 (Database PSU 12.1.0.2.180717, Oracle JavaVM Component (JUL2018))
    27547329 (DATABASE PATCH SET UPDATE 12.1.0.2.180717)

Installing patches...
 Patch installation complete.  Total patches installed: 2

Validating logfiles...
Patch 27923320 apply: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/27923320/22234076/27923320_apply_T24LIVE_2018Aug21_23_27_35.log (no errors)
Patch 27547329 apply: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/27547329/22299079/27547329_apply_T24LIVE_2018Aug21_23_28_55.log (no errors)
SQL Patching tool complete on Tue Aug 21 23:29:08 2018
[oracle@dr-core-db-test02 OPatch]$  ./datapatch -skip_upgrade_check -verbose



=====================
SELECT t.RECID FROM T24LIVE.FBNK_FUNDS_TRANSFER t 
WHERE (NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='ACIB' 
or NVL(EXTRACTVALUE(t.XMLRECORD,'/row/c1'),'^A')='ACIA');


alter system set "_fix_control" = '16324844:OFF';

alter system set "_fix_control" = '16324844:ON';

SELECT a.ksppinm "Parameter", a.ksppdesc "Description",
b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE a.indx = b.indx
AND a.indx = c.indx
AND a.ksppinm LIKE '/_%' escape '/'  
and a.ksppinm  like '%_fix_control%'
ORDER BY 1;


select * from v$session_fix_control where  bugno=16324844;

alter system set local_listener=(ADDRESS=(PROTOCOL=TCP)(HOST=10.101.5.134)(PORT=1521)) scope=both sid='*'


alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=10.101.5.134)(PORT=1521))'scope=both sid='*';