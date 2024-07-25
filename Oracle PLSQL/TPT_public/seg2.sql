col seg_owner head OWNER for a20
col seg_segment_name head SEGMENT_NAME for a30
col seg_segment_type head SEGMENT_TYPE for a20
col seg_partition_name head SEG_PART_NAME for a20

select 
	owner seg_owner, 
	segment_name seg_segment_name, 
	partition_name seg_partition_name,
	segment_type seg_segment_type, 
	tablespace_name seg_tablespace_name, 
	round(bytes/1048576,2) seg_MB,
	header_file hdrfil,
	HEADER_BLOCK hdrblk
from 
	dba_segments 
where 
	lower(segment_name) like lower('&1')
/

