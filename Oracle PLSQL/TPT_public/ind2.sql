set feedback off

column ind_table_name1 heading TABLE_NAME
column ind_index_name1 heading INDEX_NAME
column ind_table_owner1 heading TABLE_OWNER format a20
column ind_column_name1 heading COLUMN_NAME format a30
column ind_dsc1 heading DSC format a4
column ind_column_position1 heading POS# format 999

break on ind_table_owner1 skip 1 on ind_table_name1 on ind_index_name1


select 
    c.table_owner ind_table_owner1,
    c.table_name ind_table_name1, 
    c.index_name ind_index_name1, 
    c.column_position ind_column_position1, 
    c.column_name ind_column_name1, 
    decode(c.descend,'DESC','DESC',null) ind_dsc1
from 
    dba_ind_columns c
where 
    upper(c.table_name) like upper('&1')
order by
    c.table_owner,
    c.table_name,
    c.index_name,
    c.column_position
;

column ind_owner heading INDEX_OWNER format a20
column ind_index_type heading IDXTYPE format a7
column ind_uniq heading UNIQ format a4
column ind_part heading PART format a4
column ind_temp heading TEMP format a4
column ind_blevel heading H format 9
column ind_leaf_blocks heading LFBLKS format 9999999
column ind_distinct_keys heading NDK format 9999999999

break on ind_owner on table_name

select 
    owner ind_owner, 
    table_name, 
    index_name, 
    index_type ind_index_type, 
    decode(uniqueness,'UNIQUE', 'YES', 'NONUNIQUE', 'NO', 'N/A') ind_uniq, 
    status, 
    partitioned ind_part, 
    temporary ind_temp,
    last_analyzed,
    blevel+1 ind_blevel              ,
    leaf_blocks ind_leaf_blocks,
    distinct_keys ind_distinct_keys,
    clustering_factor cluf
from 
    dba_indexes
where
    upper(table_name) like upper('&1')
order by
    owner,
    table_name,
    index_name,
    ind_uniq
;


set feedback on
