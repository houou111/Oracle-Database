select
    dbms_rowid.ROWID_RELATIVE_FNO(rowid) rfile#
  , dbms_rowid.ROWID_BLOCK_NUMBER(rowid) block#
  , dbms_rowid.ROWID_ROW_NUMBER(rowid)   row#
  , 'alter system dump datafile '||dbms_rowid.ROWID_RELATIVE_FNO(rowid)||' block '||
                                   dbms_rowid.ROWID_BLOCK_NUMBER(rowid)||'; -- @dump '||
                                   dbms_rowid.ROWID_RELATIVE_FNO(rowid)||' '||
                                   dbms_rowid.ROWID_BLOCK_NUMBER(rowid)||' .' dump_command
from
    &1
where
    &2
/
