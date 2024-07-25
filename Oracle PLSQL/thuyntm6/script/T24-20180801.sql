alter table t24live.FBNK_TXN_JOURNAL move tablespace DATAT24LIVE;
alter table t24live.FBNK_TXN_JOURNAL move LOB (XMLRECORD) STORE AS (TABLESPACE datat24live)
alter index t24live.PK_FBNK_TXN_JOURNAL rebuild tablespace INDEXT24LIVE;

select * from dba_lobs where table_name='FBNK_TXN_JOURNAL'

select sum(bytes/1024/1024/1024),segment_name from dba_segments where segment_name in 
('FBNK_TXN_JOURNAL','PK_FBNK_TXN_JOURNAL','LOB_FBNK_TXN_JOURNAL')
group by segment_name