
How to add new tables for OGG replication in the current running extract and replicat ? (Doc ID 1332674.1)
https://blog.dbi-services.com/adding-new-tables-to-an-existing-oracle-goldengate-replication/
https://maazanjum.com/2013/12/06/adding-tables-to-an-existing-goldengate-configuration-with-transaction-integrity/

There are two ways to add the new tables for replication 
i)using handlecollision
ii)without using handlecollisions

i)using handlecollisions
----------------------------
1)stop the extract,pump and replicat

once the extract is stopped, wait for the pump to catch up before stopping it.  once the pump is stopped, wait for the replicat to catch up before stopping it.
Note : Check that there are no open DML transactions against the table. If there are open transactions, then you need to give a commit or rollback. Otherwise trandata would fail.
2)Enable Supplemental Logging at Table Level on source side
 GGSCI> dblogin userid xxxxx password xxxxxx
GGSCI> add trandata <schema>.<tablename>

3)include the tables that you need to add into the extract parameter file and save it
4)start the extract
5)include the tables that you need to add into the extract pump parameter file and save it
6)start the pump
7)do the initial load for the the new tables( ie you can take the export and import of the new tables that need to to added for replication from source the target database)
8)Wait for the initial load(export and import) to be completed and then include the tables that you need to add into the replicat parameter file with HANDLECOLLISIONS parameter 
eg: MAP hr.dep, TARGET hr.dep, HANDLECOLLISIONS;
MAP hr.country, TARGET hr.country, HANDLECOLLISIONS;

9) start the replicat
10) once the lag becomes zero remove the HANDLECOLLISIONS from the replicat parameter file and restart the replicat
eg :-
MAP hr.dep, TARGET hr.dep;
MAP hr.country, TARGET hr.country;

note:- 4 and 5th step can be skipped if the pump is not configured.


ii)without using handlecollision
--------------------------------------
1) stop the extract,pump and replicat
once the extract is stopped, wait for the pump to catch up before stopping it.
        once the pump is stopped, wait for the replicat to catch up before stopping it.
2)Enable Supplemental Logging at Table Level on source side
GGSCI> dblogin userid xxxxx password xxxxxx
GGSCI> add trandata <schema>.<tablename>  

3)add the new table in extract parameter file and save it
4)start the extract
5)add the new table in extract pump parameter file and save it
6)start the extract pump
7)get the current SCN from the source database
eg:-
SQL> select current_scn from v$database;

CURRENT_SCN
------------------------
5343407


8)re-sync the the newly added table from source to target(using normal export/import).
Make sure to use FLASHBACK_SCN parameter for the export.

9) Add the table in the replicat parameter file including the below option till 11g ( FILTER ( @GETENV ("TRANSACTION", "CSN") > <scn_number obtained from source db>) ) and for 12c onwards it will be like ( FILTER ( @GETENV ('TRANSACTION', 'CSN') > <scn_number obtained from source db>) )  as shown in the below example
eg:-
till OGG 11g 
MAP source.test1, TARGET target.test1 ,FILTER ( @GETENV ("TRANSACTION", "CSN") > 5343407);
MAP source.test2, TARGET target.test2 ,FILTER ( @GETENV ("TRANSACTION", "CSN") > 5343407);
for OGG 12c  ownward the staement will be like below:
MAP source.test1, TARGET target.test1 ,FILTER ( @GETENV ('TRANSACTION', 'CSN') > 5343407);
MAP source.test2, TARGET target.test2 ,FILTER ( @GETENV ('TRANSACTION', 'CSN') > 5343407);



11)start the replicat

12)verify the tables on source and table and once the lag is zero remove the filter parameter from the replicat parameter file and restart.



----------------------------------------------
6.1 Deleting an Extract Group
----------------------------------------------
To delete an Oracle GoldenGate Extract group, the Extract process must be decoupled from the Teradata replication group.

1. Start GGSCI.
2. While Extract is still running, issue this command:
SEND EXTRACT group, VAMMESSAGE "control:terminate"
3. Stop Extract.
STOP EXTRACT group
4. Delete the Extract group forcefully.
DELETE EXTRACT group !
5. From any Teradata client, issue this command:
DROP REPLICATION GROUP replication_group

----------------------------------------------
6.2 Adding a Table to an Existing Extract Group
----------------------------------------------
1. Suspend activity on the source tables that are linked to Oracle GoldenGate.
2. Start GGSCI.
3. In GGSCI, issue this command:
INFO EXTRACT group
4. On the Checkpoint Lag line, verify whether there is any Extract lag. If needed, continue to issue INFO EXTRACT until lag is zero, which indicates that all of the transaction data so far has been processed.
5. While Extract is still running, issue this command:
SEND EXTRACT group, VAMMESSAGE "control:terminate"
6. Stop the Extract group.
STOP EXTRACT group
7. From any Teradata client, issue this command to add the new table:
ALTER REPLICATION GROUP group ADD database.table
8. From any Teradata client, issue this command to generate a security token.
ALTER REPLICATION GROUP group
9. Edit the TAM initialization file and specify the security token with the SecurityToken parameter.
10. Edit the Extract parameter file to add a TABLE parameter that specifies the new table.
EDIT PARAMS group
11.Save and close the file.
12. In GGSCI, issue this command to start Extract:
START EXTRACT group
13. Allow activity on the source tables that are linked to Oracle GoldenGate.

----------------------------------------------
6.3 Moving a Table to a New Extract Group
----------------------------------------------
1. Suspend activity on the source database for all tables that are linked to Oracle GoldenGate.
2. Edit the current Teradata Create Group Statement file to remove the table from the CREATE REPLICATION GROUP statement.
3. Start GGSCI.
4. In GGSCI, issue this command for the current Extract group:
INFO EXTRACT group
5. On the Checkpoint Lag line, verify whether there is any Extract lag. If needed, continue to issue INFO EXTRACT until lag is zero, which indicates that all of the transaction data so far has been processed.
6. In GGSCI, issue this command:
SEND EXTRACT group, VAMMESSAGE "control:terminate"
7. Stop the current Extract group.
STOP EXTRACT group
8. Edit the current Extract parameter file.
EDIT PARAMS group
9. Remove the TABLE parameter that contains the table.
10. From any Teradata client, issue this command to drop the replication group that contains the table that is being moved:
ALTER REPLICATION GROUP group DROP table
11. In GGSCI, issue this command to start the current Extract group, so that it can continue processing its assigned tables, minus the one that was moved:
START EXTRACT group
12. Add a new Extract group that contains a TABLE statement for the moved table, and then add the other processes, trails, and parameter files that are appropriate for the capture method that you are using. See "Configuring Oracle GoldenGate" for instructions.
13. Create a new tam.ini file and a new Teradata Create Group Statement file that contains the table. See "Configuring the TAM Initialization File" and "Creating a Teradata Replication Group".
14. Start the new Extract group and any associated processes.
START EXTRACT new_group
15. Allow user activity to resume on all of the source tables that are linked to Oracle GoldenGate.

----------------------------------------------
6.4 Modifying Columns of a Table
----------------------------------------------

1.Suspend activity on the source database for all tables that are linked to Oracle GoldenGate.
2. Start GGSCI.
3. In GGSCI, issue this command for the Extract group:
INFO EXTRACT group
4. On the Checkpoint Lag line, verify whether there is any Extract lag. If needed, continue to issue INFO EXTRACT until lag is zero, which indicates that all of the transaction data so far has been processed.
5. While Extract is still running, issue this command:
SEND EXTRACT group, VAMMESSAGE "control:terminate"
6. Stop the Extract group.
STOP EXTRACT group
7. In GGSCI, issue this command for the Replicat group:
INFO REPLICAT group
8. On the Checkpoint Lag line, verify whether there is any Replicat lag. If needed, continue to issue INFO REPLICAT until lag is zero, which indicates that all of the data in the trail has been processed.
9. Stop the Replicat group.
STOP REPLICAT group
10. Perform the table modifications on the source and target databases.
11. Start the Extract and Replicat processes.
START EXTRACT group
START REPLICAT group
11. Allow user activity to resume on all of the source tables that are linked to Oracle GoldenGate.



---==GOLDEN GATE==---
***Extract
- Initial loads: Extract extracts (captures) a current, static set of data directly from their source objects.
- Change synchronization: To keep source data synchronized with another set of data, Extract captures DML and DDL operations after the initial synchronization has taken place. 
Extract stores these operations until it receives commit records or rollbacks for the transactions that contain them.
	.When a rollback is received, Extract discards the operations for that transaction. 
	.When a commit is received, Extract persists the transaction to disk in a series of files called a trail, where it is queued for propagation to the target system. 
	.All of the operations in each transaction are written to the trail as a sequentially organized transaction unit.  
	
***data pump 
- is a secondary Extract group 
- If a data pump is not used, Extract must send the captured data operations to a remote trail on the target. In a typical configuration with a data pump, however, the primary Extract group writes to a trail on the source system. The data pump reads this trail and sends the data operations over the network to a remote trail on the target. 
- In general, it can perform data filtering, mapping, and conversion, or it can be configured in pass-through mode, where data is passively transferred as-is, without manipulation. 
Pass-through mode increases the throughput of the data pump, because all of the functionality that looks up object definitions is bypassed.	

***Replicat
- runs on the target system, reads the trail on that system, and then reconstructs the DML or DDL operations and applies them to the target database. 
- uses dynamic SQL to compile a SQL statement once, and then execute it many times with different bind variables.

* Initial loads: Replicat can apply a static data copy to target objects or route it to a high-speed bulk-load utility.
* Change synchronization: When configured for change synchronization, Replicat applies the replicated source operations to the target objects using a native database interface or ODBC, depending on the database type.

multiple Replicat processes/ coordinated / integrated mode.

- Coordinated mode is supported on all databases that Oracle GoldenGate supports. 
Replicat is threaded. 
One coordinator thread spawns and coordinates one or more threads that execute replicated SQL operations in parallel. 
A coordinated Replicat uses one parameter file and is monitored and managed as one unit. 

- Integrated mode (11.2.0.4 or later) Replicat leverages the apply processing functionality that is available within the Oracle database. 
Within a single Replicat configuration, multiple inbound server child processes known as apply servers apply transactions in parallel while preserving the original transaction atomicity. 

You can delay Replicat so that it waits a specific amount of time before applying the replicated operations to the target database. 
The length of the delay is controlled by the DEFERAPPLYINTERVAL parameter.

Various parameters control the way that Replicat converts source transactions to target transactions. These parameters include BATCHSQL, GROUPTRANSOPS, and MAXTRANSOPS. 

***Trails
Oracle GoldenGate stores records of the captured changes temporarily on disk in a series of files called a trail. 
A trail can exist on the source system, an intermediary system, the target system, or any combination of those systems, depending on how you configure Oracle GoldenGate. On the local system it is known as an extract trail (or local trail). On a remote system it is known as a remote trail.

By using a trail for storage, Oracle GoldenGate supports data accuracy and fault tolerance. 
The use of a trail also allows extraction and replication activities to occur independently of each other. With these processes separated, you have more choices for how data is processed and delivered. For example, instead of extracting and replicating changes continuously, you could extract changes continuously but store them in the trail for replication to the target later, whenever the target application needs them.