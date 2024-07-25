=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
-----shrink tempfile directly
use tempdb
GO

DBCC FREEPROCCACHE -- clean cache
DBCC DROPCLEANBUFFERS -- clean buffers
DBCC FREESYSTEMCACHE ('ALL') -- clean system cache
DBCC FREESESSIONCACHE -- clean session cache
DBCC SHRINKDATABASE(tempdb, 10); -- shrink tempdb
dbcc shrinkfile ('tempdev') -- shrink db file
dbcc shrinkfile ('templog') -- shrink log file
GO

-- report the new file sizes
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO

----- option 2: change location and size
=======================================================
--check version
SELECT @@VERSION

=======================================================
--Login Database
Create login yourloginname with password='yourpassword'

=======================================================
--Create Database
Create database <yourdatabasename>

Full Type
Backup database <Your database name> to disk = '<Backup file location + file name>'

Differential Type
Backup database <Your database name> to    disk = '<Backup file location + file name>' with differential

Log Type
Backup log <Your database name> to disk = '<Backup file location + file name>'

Restore database <Your database name> from disk = '<Backup file location + file name>'
ex:
Restore database TestDB from disk = ' D:\TestDB_Full.bak' with replace
RESTORE DATABASE TestDB FROM DISK = 'D:\ TestDB_Full.bak' WITH MOVE 'TestDB' TO 
   'D:\Data\TestDB.mdf', MOVE 'TestDB_Log' TO 'D:\Data\TestDB_Log.ldf'

=======================================================   
--Create user
Create user <username> for login <loginname>

=======================================================
--check file size
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  

--check log file size
SELECT
    RTRIM(instance_name) [database], 
    cntr_value/1024 log_size_kb
FROM 
    sys.dm_os_performance_counters 
WHERE 
    object_name = 'SQLServer:Databases'
    AND counter_name = 'Log File(s) Size (KB)'
    AND instance_name <> '_Total'

=======================================================	
--check defrag index
SELECT  OBJECT_NAME(DMV.object_id) AS TABLE_NAME ,
    SI.NAME AS INDEX_NAME ,
    avg_fragmentation_in_percent AS FRAGMENT_PERCENT ,
    DMV.record_count
FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED')
    AS DMV
    LEFT OUTER JOIN SYS.INDEXES AS SI ON DMV.OBJECT_ID = SI.OBJECT_ID
                                         AND DMV.INDEX_ID = SI.INDEX_ID
WHERE   avg_fragmentation_in_percent > 10
    AND index_type_desc IN ( 'CLUSTERED INDEX', 'NONCLUSTERED INDEX' )
    AND DMV.record_count >= 2000
ORDER BY TABLE_NAME DESC
	

=======================================================	
--Assign Permissions
Use <database name>
Grant <permission name> on <object name> to <username\principle>

Select * from INFORMATION_SCHEMA.TABLE_PRIVILEGES 

select sys.schemas.name 'Schema'
   , sys.objects.name Object
   , sys.database_principals.name username
   , sys.database_permissions.type permissions_type
   ,     sys.database_permissions.permission_name
   ,      sys.database_permissions.state permission_state
   ,     sys.database_permissions.state_desc
   ,     state_desc + ' ' + permission_name + ' on ['+ sys.schemas.name + '].[' + sys.objects.name + '] to [' + sys.database_principals.name + ']' COLLATE LATIN1_General_CI_AS 
from sys.database_permissions join sys.objects 
on sys.database_permissions.major_id =      sys.objects.object_id 
join sys.schemas on sys.objects.schema_id = sys.schemas.schema_id 
join sys.database_principals on sys.database_permissions.grantee_principal_id =      sys.database_principals.principal_id 
order by 1, 2, 3, 5


select sys.schemas.name 'Schema'
, sys.objects.name Object
, sys.database_principals.name username
, sys.database_permissions.type permissions_type
, sys.database_permissions.permission_name
, sys.database_permissions.state permission_state
, sys.database_permissions.state_desc
, state_desc + ' ' + permission_name + ' on ['+ sys.schemas.name + '].[' + sys.objects.name + '] to [' + sys.database_principals.name + ']' COLLATE LATIN1_General_CI_AS
from sys.database_permissions
left outer join sys.objects on sys.database_permissions.major_id = sys.objects.object_id
left outer join sys.schemas on sys.objects.schema_id = sys.schemas.schema_id
left outer join sys.database_principals on sys.database_permissions.grantee_principal_id = sys.database_principals.principal_id
WHERE sys.database_principals.name = 'FGL\RDighe'
order by 1, 2, 3, 5 


=======================================================
--check last data in transaction log
select Log_reuse_wait_desc,name,* from sys.databases

=======================================================
--find index defragment 
How to Find Index Fragmentation for All Database
1. Steps to Find Index Fragmentation for All Database

There is possibility that indexes will not give desired performance due to high fragmentation. Below SQL script will provide you Index fragmentation details for all databases where index fragmentation is greater than 30%. It would be helpful while scheduling or determining maintenance task of reindexing. It helps you to determine whether Indexes should be rebuild or reorganized. Normally Indexes should be rebuild if fragmentation is greater than 30-40%.

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧・

exec master.sys.sp_MSforeachdb ・USE [?]

SELECT db_name() as DatabaseName, OBJECT_NAME (sysst.object_id) as ObjectName,

sysst.index_id, sysind.name as IndexName,

avg_fragmentation_in_percent, index_type_desc

FROM sys.dm_db_index_physical_stats (db_id(), NULL, NULL, NULL, NULL) AS sysst

JOIN sys.indexes AS sysind

ON sysst.object_id = sysind.object_id AND sysst.index_id = sysind.index_id

WHERE b.index_id <> 0 and avg_fragmentation_in_percent >30・
go

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧・
2. Steps to Find Index Fragmentation for Specific Database

Use below query if you want to find Index fragmentation for specific DB. Just replace tempDB by your DB name.

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧-

SELECT db_name(ma.database_id), ma.object_id, ma.index_id, su.name, ma.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(N稚empDB・,NULL, NULL, NULL, NULL) AS ma
JOIN sys.indexes AS su ON ma.object_id = su.object_id AND ma.index_id = su.index_id and su.index_id <> 0

and avg_fragmentation_in_percent >30 order by ma.object_id;
GO

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧・

 
3. Steps to Find Index Fragmentation for Specific Table in Database

Use below query if you want to find Index fragmentation for specific Table in DB. Just replace tempDB by your DB name and replace tempDB.ABC by table name.

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

SELECT db_name(ma.database_id), ma.object_id, ma.index_id, su.name, ma.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(N稚empDB・,OBJECT_ID(N稚empDB.ABC・, NULL, NULL, NULL) AS ma
JOIN sys.indexes AS su ON ma.object_id = su.object_id AND ma.index_id = su.index_id and su.index_id <> 0

and avg_fragmentation_in_percent >30 order by ma.object_id;
GO

=======================================================
-- Find Missing Index Script
-- Original Author: Pinal Dave 
SELECT TOP 25
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC
GO

=======================================================
--rebuild all index
--/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
--Arguments             Data Type               Description
--------------          ------------            ------------
--@FillFactor           [int]                   Specifies a percentage that indicates how full the Database Engine should make the leaf level
--                                              of each index page during index creation or alteration. The valid inputs for this parameter
--                                              must be an integer value from 1 to 100 The default is 0.
--                                              For more information, see http://technet.microsoft.com/en-us/library/ms177459.aspx.
 
--@PadIndex             [varchar](3)            Specifies index padding. The PAD_INDEX option is useful only when FILLFACTOR is specified,
--                                              because PAD_INDEX uses the percentage specified by FILLFACTOR. If the percentage specified
--                                              for FILLFACTOR is not large enough to allow for one row, the Database Engine internally
--                                              overrides the percentage to allow for the minimum. The number of rows on an intermediate
--                                              index page is never less than two, regardless of how low the value of fillfactor. The valid
--                                              inputs for this parameter are ON or OFF. The default is OFF.
--                                              For more information, see http://technet.microsoft.com/en-us/library/ms188783.aspx.
 
--@SortInTempDB         [varchar](3)            Specifies whether to store temporary sort results in tempdb. The valid inputs for this
--                                              parameter are ON or OFF. The default is OFF.
--                                              For more information, see http://technet.microsoft.com/en-us/library/ms188281.aspx.
 
--@OnlineRebuild        [varchar](3)            Specifies whether underlying tables and associated indexes are available for queries and data
--                                              modification during the index operation. The valid inputs for this parameter are ON or OFF.
--                                              The default is OFF.
--                                              Note: Online index operations are only available in Enterprise edition of Microsoft
--                                                      SQL Server 2005 and above.
--                                              For more information, see http://technet.microsoft.com/en-us/library/ms191261.aspx.
 
--@DataCompression      [varchar](4)            Specifies the data compression option for the specified index, partition number, or range of
--                                              partitions. The options  for this parameter are as follows:
--                                                  > NONE - Index or specified partitions are not compressed.
--                                                  > ROW  - Index or specified partitions are compressed by using row compression.
--                                                  > PAGE - Index or specified partitions are compressed by using page compression.
--                                              The default is NONE.
--                                              Note: Data compression feature is only available in Enterprise edition of Microsoft
--                                                      SQL Server 2005 and above.
--                                              For more information about compression, see http://technet.microsoft.com/en-us/library/cc280449.aspx.
 
--@MaxDOP               [int]                   Overrides the max degree of parallelism configuration option for the duration of the index
--                                              operation. The valid input for this parameter can be between 0 and 64, but should not exceed
--                                              number of processors available to SQL Server.
--                                              For more information, see http://technet.microsoft.com/en-us/library/ms189094.aspx.
--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
 
-- Ensure a USE <databasename> statement has been executed first.
 
SET NOCOUNT ON;
 
DECLARE  @Version                           [numeric] (18, 10)
        ,@SQLStatementID                    [int]
        ,@CurrentTSQLToExecute              [nvarchar](max)
        ,@FillFactor                        [int]        = 100 -- Change if needed
        ,@PadIndex                          [varchar](3) = N'OFF' -- Change if needed
        ,@SortInTempDB                      [varchar](3) = N'OFF' -- Change if needed
        ,@OnlineRebuild                     [varchar](3) = N'ON' -- Change if needed
        ,@LOBCompaction                     [varchar](3) = N'ON' -- Change if needed
        ,@DataCompression                   [varchar](4) = N'NONE' -- Change if needed
        ,@MaxDOP                            [int]        = NULL -- Change if needed
        ,@IncludeDataCompressionArgument    [char](1);
 
IF OBJECT_ID(N'TempDb.dbo.#Work_To_Do') IS NOT NULL
    DROP TABLE #Work_To_Do
CREATE TABLE #Work_To_Do
    (
      [sql_id] [int] IDENTITY(1, 1)
                     PRIMARY KEY ,
      [tsql_text] [varchar](1024) ,
      [completed] [bit]
    )
 
SET @Version = CAST(LEFT(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)), CHARINDEX('.', CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128))) - 1) + N'.' + REPLACE(RIGHT(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)), LEN(CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128))) - CHARINDEX('.', CAST(SERVERPROPERTY(N'ProductVersion') AS [nvarchar](128)))), N'.', N'') AS [numeric](18, 10))
 
IF @DataCompression IN (N'PAGE', N'ROW', N'NONE')
    AND (
        @Version >= 10.0
        AND SERVERPROPERTY(N'EngineEdition') = 3
        )
BEGIN
    SET @IncludeDataCompressionArgument = N'Y'
END
 
IF @IncludeDataCompressionArgument IS NULL
BEGIN
    SET @IncludeDataCompressionArgument = N'N'
END
 
INSERT INTO #Work_To_Do ([tsql_text], [completed])
SELECT 'ALTER INDEX [' + i.[name] + '] ON' + SPACE(1) + QUOTENAME(t2.[TABLE_CATALOG]) + '.' + QUOTENAME(t2.[TABLE_SCHEMA]) + '.' + QUOTENAME(t2.[TABLE_NAME]) + SPACE(1) + 'REBUILD WITH (' + SPACE(1) + + CASE
        WHEN @PadIndex IS NULL
            THEN 'PAD_INDEX =' + SPACE(1) + CASE i.[is_padded]
                    WHEN 1
                        THEN 'ON'
                    WHEN 0
                        THEN 'OFF'
                    END
        ELSE 'PAD_INDEX =' + SPACE(1) + @PadIndex
        END + CASE
        WHEN @FillFactor IS NULL
            THEN ', FILLFACTOR =' + SPACE(1) + CONVERT([varchar](3), REPLACE(i.[fill_factor], 0, 100))
        ELSE ', FILLFACTOR =' + SPACE(1) + CONVERT([varchar](3), @FillFactor)
        END + CASE
        WHEN @SortInTempDB IS NULL
            THEN ''
        ELSE ', SORT_IN_TEMPDB =' + SPACE(1) + @SortInTempDB
        END + CASE
        WHEN @OnlineRebuild IS NULL
            THEN ''
        ELSE ', ONLINE =' + SPACE(1) + @OnlineRebuild
        END + ', STATISTICS_NORECOMPUTE =' + SPACE(1) + CASE st.[no_recompute]
        WHEN 0
            THEN 'OFF'
        WHEN 1
            THEN 'ON'
        END + ', ALLOW_ROW_LOCKS =' + SPACE(1) + CASE i.[allow_row_locks]
        WHEN 0
            THEN 'OFF'
        WHEN 1
            THEN 'ON'
        END + ', ALLOW_PAGE_LOCKS =' + SPACE(1) + CASE i.[allow_page_locks]
        WHEN 0
            THEN 'OFF'
        WHEN 1
            THEN 'ON'
        END + CASE
        WHEN @IncludeDataCompressionArgument = N'Y'
            THEN CASE
                    WHEN @DataCompression IS NULL
                        THEN ''
                    ELSE ', DATA_COMPRESSION =' + SPACE(1) + @DataCompression
                    END
        ELSE ''
        END + CASE
        WHEN @MaxDop IS NULL
            THEN ''
        ELSE ', MAXDOP =' + SPACE(1) + CONVERT([varchar](2), @MaxDOP)
        END + SPACE(1) + ')'
    ,0
FROM [sys].[tables] t1
INNER JOIN [sys].[indexes] i ON t1.[object_id] = i.[object_id]
    AND i.[index_id] > 0
    AND i.[type] IN (1, 2)
INNER JOIN [INFORMATION_SCHEMA].[TABLES] t2 ON t1.[name] = t2.[TABLE_NAME]
    AND t2.[TABLE_TYPE] = 'BASE TABLE'
INNER JOIN [sys].[stats] AS st WITH (NOLOCK) ON st.[object_id] = t1.[object_id]
    AND st.[name] = i.[name]
 
SELECT @SQLStatementID = MIN([sql_id])
FROM #Work_To_Do
WHERE [completed] = 0
 
WHILE @SQLStatementID IS NOT NULL
BEGIN
    SELECT @CurrentTSQLToExecute = [tsql_text]
    FROM #Work_To_Do
    WHERE [sql_id] = @SQLStatementID
 
    PRINT @CurrentTSQLToExecute
 
    EXEC [sys].[sp_executesql] @CurrentTSQLToExecute
 
    UPDATE #Work_To_Do
    SET [completed] = 1
    WHERE [sql_id] = @SQLStatementID
 
    SELECT @SQLStatementID = MIN([sql_id])
    FROM #Work_To_Do
    WHERE [completed] = 0
END

=======================================================
--Shrink database
====  All databases in instance =====
---- shrink log file of all database in instance -----

SELECT 
      'USE [' + d.name + N'] ' + CHAR(13) + CHAR(10)
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE d.name NOT IN ('master','model','msdb','tempdb', 'ReportServer', 'ReportServerTempDB')  
and mf.type_desc = 'LOG';


===== Single database =====
---- shrink log file of single database -----
USE tbank
GO
BACKUP LOG tbank TO DISK='NUL:'
DBCC SHRINKFILE(tbank_Log02, 1000)
GO

--- shrink datafile file of single database  -----
USE tbank
GO
DBCC SHRINKFILE (N'TbankA2013' , 0, TRUNCATEONLY)
GO

--- shrink single database (includes all datafile, logfile)----
USE tbank
GO
DBCC SHRINKDATABASE(N'tbank' )
GO

=======================================================
--shrink temp file
----- option 1: shrink tempfile directly
use tempdb
GO

DBCC FREEPROCCACHE -- clean cache
DBCC DROPCLEANBUFFERS -- clean buffers
DBCC FREESYSTEMCACHE ('ALL') -- clean system cache
DBCC FREESESSIONCACHE -- clean session cache
DBCC SHRINKDATABASE(tempdb, 10); -- shrink tempdb
dbcc shrinkfile ('tempdev') -- shrink db file
dbcc shrinkfile ('templog') -- shrink log file
GO

-- report the new file sizes
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO

----- option 2: change location and size


=======================================================


=======================================================


=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================
=======================================================