select  
	c.ts#, t.tablespace_name, t.block_size blksz, status, contents, 
	logging, forcE_logging forclog, extent_management, allocation_type, 
	segment_space_management ASSM, min_extlen EXTSZ
from 
	v$tablespace c, 
	dba_tablespaces t
where c.name = t.tablespace_name
and   upper(tablespace_name) like upper('%&1%');




