BEGIN 
  FOR r IN (select username FROM dba_users
	  where username not in ('XS$NULL'))
  LOOP 
  BEGIN
  EXECUTE IMMEDIATE 'ALTER user "'|| r.username||'" LOCAL TEMPORARY TABLESPACE TEMP_TBS'; 
  EXCEPTION 
     WHEN OTHERS THEN 
        /* Your exception handing here. */ 
        NULL; 
     END; 
  END LOOP; 
END; 
/ 
