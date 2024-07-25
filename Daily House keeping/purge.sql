DECLARE cmd VARCHAR2 (4000); CURSOR c_table IS select owner,object_name FROM dba_recyclebin where can_purge = 'YES' and type = 'TABLE' and to_date(droptime, 'YYYY-MM-DD:HH24:MI:SS') < sysdate - 15; BEGIN FOR r IN c_table LOOP cmd :='purge table || owner || . || object_name || '; DBMS_OUTPUT.put_line (cmd); execute immediate cmd; END LOOP; END;
/
exit
