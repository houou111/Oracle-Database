=================================================== 
--------Corruption Detection Methods
select * from v$database_block_corruption;
538, block# 1936384
select relative_fno, owner,  segment_name,partition_name, segment_type
from dba_extents
where file_id = 538 
and 1936384 between block_id and block_id + blocks - 1;
--DB_VERIFY
  dbv [ USERID=username/password ]
    FILE = filename
  | { START = block_address | END = block_address }
  | BLOCKSIZE = integer
  | LOGFILE = filename
  | FEEDBACK = integer
  | HELP  = { Y | N } 
  | PARFILE = filename
  dbv userid=dbsnmp/PAssw0rd file=+DATA_DG/dwprd/datafile/dwh_vas_tbs.867.950373321 
  
--get segment_id
  SELECT T.TS#,S.RELATIVE_FNO,S.HEADER_BLOCK
  FROM DBA_SEGMENTS S, V$TABLESPACE T
     WHERE S.OWNER='SILVER' AND S.SEGMENT_TYPE='TABLE'
       AND S.SEGMENT_NAME='TEST' AND T.NAME=S.TABLESPACE_NAME;
dbv USERID = username/password 
  | SEGMENT_ID = tsn.segfile.segblock
  | LOGFILE = filename
  | FEEDBACK = integer
  | HELP  = { Y | N }
  | PARFILE = filename  
 
--DBMS_REPAIR
check and report block corruption
CHECK_OBJECT 
--ANALYZE ... VALID STRUCTURE