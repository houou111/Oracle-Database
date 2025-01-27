column	tab_owner	heading OWNER		format a20
column	tab_table_name	heading TABLE_NAME	format a30
column	tab_type	heading TYPE		format a4
column	tab_num_rows	heading NUM_ROWS	format 99999999999
column	tab_blocks heading BLOCKS		format 999999999
column	tab_empty_blocks heading EMPTY		format 99999999
column	tab_avg_space	heading AVGSPC		format 99999
column	tab_avg_row_len	heading ROWLEN		format 99999


select
	owner				tab_owner,
	table_name			tab_table_name,
	case 
		when cluster_name is not null then 'CLU'
		when partitioned = 'NO'  and iot_name is not null then 'IOT'
		when partitioned = 'YES' and iot_name is not null then 'PIOT'
		when partitioned = 'NO' and iot_name is null then 'TAB'
		when partitioned = 'YES' and iot_name is null then 'PTAB'
		when temporary = 'Y' then 'TEMP'
		else 'OTHR'
	end 				tab_type,
	num_rows			tab_num_rows,
	blocks				tab_blocks,
	empty_blocks			tab_empty_blocks,
	avg_space			tab_avg_space,
--	chain_cnt			tab_chain_cnt,
	avg_row_len			tab_avg_row_len,
--	avg_space_freelist_blocks 	tab_avg_space_freelist_blocks,
--	num_freelist_blocks		tab_num_freelist_blocks,
--	sample_size			tab_sample_size,
	last_analyzed			tab_last_analyzed
from
	dba_tables
where
	lower(table_name) like lower('&1')
/
