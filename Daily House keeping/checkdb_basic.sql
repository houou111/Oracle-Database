set lines 200 
set pages 200
prompt ****Check v$database
select name, DATABASE_ROLE, OPEN_MODE from v$database;
	
prompt ****Check FRA - Archivelog
archive log list;	
show parameter recover	
select * from v$flash_recovery_area_usage;

prompt ****Allocated size
select sum(bytes/1024/1024/1024) from v$datafile;

prompt ****Using size
select sum(bytes/1024/1024/1024) from  dba_segments; 

prompt ****Check ASM Diskgroup
COLUMN group_name             FORMAT a25           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
BREAK ON report ON disk_group_name SKIP 1
COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report
SELECT
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
FROM
    v$asm_diskgroup
WHERE
    total_mb != 0
ORDER BY
    name;

prompt ****Check temporary tablespace
select TABLESPACE_NAME, TRUNC(TABLESPACE_SIZE/1024/1024/1024,2) SIZE_GB, 
TRUNC(ALLOCATED_SPACE/1024/1024/1024,2) ALLOCATED_GB, 
TRUNC(FREE_SPACE/1024/1024/1024,2) FREE_GB,
TRUNC(((ALLOCATED_SPACE - FREE_SPACE)/ALLOCATED_SPACE*100),2) "% USED"  
from dba_temp_free_space;

prompt ****Check tablespace
column "TOTAL ALLOC (MB)" for 999,999,999,990.00	
column "TOTAL PHYS ALLOC (MB)" for 9,999,990.00	
column "USED (MB)" for 9,999,990.00	
column "FREE (MB)" for 9,999,990.00	
column "% USED" for 990.00	
select 
   a.tablespace_name,	
   a.bytes_alloc/(1024*1024) "TOTAL ALLOC (MB)",	
   a.physical_bytes/(1024*1024) "TOTAL PHYS ALLOC (MB)",	
   nvl(b.tot_used,0)/(1024*1024) "USED (MB)",	
   (nvl(b.tot_used,0)/a.bytes_alloc)*100 "% USED" 	
from 	
   (select 	
      tablespace_name, 	
	  sum(bytes) physical_bytes, 
      sum(decode(autoextensible,'NO',bytes,'YES',maxbytes)) bytes_alloc 
    from 
      dba_data_files 
    group by 
      tablespace_name ) a,
   (select 
      tablespace_name, 
      sum(bytes) tot_used 
    from 
      dba_segments 
    group by 
      tablespace_name ) b
where 
   a.tablespace_name = b.tablespace_name (+) 
order by 1;



