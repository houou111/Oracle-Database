col topseg_segment_name head SEGMENT_NAME for a30

select * from (
	select 
		tablespace_name, 
		owner, 
		segment_name topseg_segment_name, 
		partition_name,
		segment_type, 
		round(bytes/1048576) MB 
	from dba_segments
	where upper(tablespace_name) like upper('%&1%')
	order by MB desc
)
where rownum <= 50;

