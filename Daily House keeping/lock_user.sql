BEGIN 
  FOR r IN (select username from dba_users where account_status='OPEN' and ORACLE_MAINTAINED = 'N' AND username not in  ('C##DBA01','C##ERP_SELECT') order by 1 ) 
  LOOP 
  BEGIN 
	EXECUTE IMMEDIATE 'alter user "'|| r.username ||'" account lock'; 
     END; 
  END LOOP; 
END; 
/ 


