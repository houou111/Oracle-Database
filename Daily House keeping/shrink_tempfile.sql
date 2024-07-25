DECLARE cmd VARCHAR2 (4000); CURSOR c_table IS select TABLESPACE_NAME,trunc(TABLESPACE_SIZE*98/100/1024/1024/1024,0) Keep_size FROM dba_temp_free_space; BEGIN FOR r IN c_table LOOP cmd :='alter tablespace '||r.TABLESPACE_NAME||' shrink space keep '||r.Keep_size||'G'; DBMS_OUTPUT.put_line (cmd); execute immediate cmd; END LOOP; END;
/
exit
