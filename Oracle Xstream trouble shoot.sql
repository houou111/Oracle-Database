COL NAME HEADING 'Name'
col platform_name format a30 wrap
col current_scn format 99999999999999999
col parallelism format a11
col sga_size format a12
col max_sga_size format a12
col excludetag format a20
col excludeuser format a20
col getapplops format a10
col getreplicates format a13
col checkpoint_frequency format a20
col session_name Heading 'Capture|Name'
col available_txn Heading 'Available|Chunks'
col delivered_txn Heading 'Delivered|Chunks'
col difference Heading 'Ready to Send|Chunks'
col builder_work_size Heading 'Builder|WorkSize'
col prepared_work_size Heading 'Prepared|WorkSize'
col used_memory_size  Heading 'Used|Memory'
col max_memory_size   Heading 'Max|Memory'
col used_mem_pct Heading 'Used|Memory|Percent'



select  SYSDATE Current_time,
   c.capture_name, 
   c.capture_user,
   c.capture_type, 
   decode(cp.value,'N','NO', 'YES') Real_time_mine,
   c.required_checkpoint_scn,
   c.purpose,
   c.version,
   c.logminer_id,
   c.status,
   DECODE (g.STATE,null,'<b> <a href="#Performance Checks">WAITING FOR CLIENT REQUESTS</a> </b>',
                'WAITING FOR INACTIVE DEQUEUERS','<b><a href="#Notification">'||g.state||'</a></b>',
                g.state) State,
   (SYSDATE- g.capture_message_create_time)*86400 capture_lag,
   g.bytes_of_redo_mined/1024/1024 mined_MB,
   g.startup_time,
   g.inst_id,
   c.source_database
from dba_capture c,
     gv$streams_capture g,
     dba_capture_parameters cp
where
  c.capture_name=g.capture_name
  and c.purpose != 'GoldenGate Capture'
  and c.capture_name=cp.capture_name and cp.parameter='DOWNSTREAM_REAL_TIME_MINE'
  and c.status='ENABLED' 
union all
select SYSDATE Current_time,  
   c.capture_name, 
   c.capture_user, 
   c.capture_type, 
   decode(cp.value, 'N','NO', 'YES') Real_time_mine,
   c.required_checkpoint_scn,
   c.purpose,
   c.version,
   c.logminer_id,
   c.status,
   'Unavailable',
   NULL,
   NULL,
   NULL,
   NULL,
   c.source_database
from dba_capture c,
     dba_capture_parameters cp
where
  c.status in ('DISABLED','ABORTED') and c.purpose != 'GoldenGate Capture'
  and c.capture_name=cp.capture_name and cp.parameter='DOWNSTREAM_REAL_TIME_MINE'
order by capture_name;





select cp.capture_name,
                  max(case when parameter='PARALLELISM' then value end) parallelism
                 ,max(case when parameter='_SGA_SIZE' then value end) sga_size
                 ,max(case when parameter='MAX_SGA_SIZE' then value end) max_sga_size
                 ,max(case when parameter='_CHECKPOINT_FREQUENCY' then value end) checkpoint_frequency                
                 from dba_capture_parameters cp, dba_capture c where c.capture_name=cp.capture_name
                  and c.purpose !='GoldenGate Capture'
                 group by cp.capture_name;
				 
				 


select session_name, available_txn, delivered_txn,
             available_txn-delivered_txn as difference,
             builder_work_size, prepared_work_size,
            used_memory_size , max_memory_size,
             (used_memory_size/max_memory_size)*100 as used_mem_pct
      FROM v$logmnr_session order by session_name; 
	  
	  
select message_type,creation_time,reason, suggested_action,
     module_id,object_type,
     instance_name||' (' ||instance_number||' )' Instance,
     time_suggested
from dba_outstanding_alerts 
   where creation_time >= sysdate -10 and rownum < 11
   order by creation_time desc;
   
   
column Instance Heading 'Instance Name|(Instance Number)'
select message_Type,creation_time, reason,suggested_action,
       module_id,object_type,                    host_id,
       instance_name||'   ( '||instance_number||' )' Instance,      
       resolution,time_suggested
from dba_alert_history where message_group in ('Streams','XStream','GoldenGate') 
      and creation_time >= sysdate -10 and rownum < 11
order by creation_time desc;