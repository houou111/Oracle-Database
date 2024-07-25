BEGIN 
  FOR r IN (select OWNER,table_name,DEFAULT_TABLESPACE FROM dba_tables a ,dba_users b 
	  WHERE a.owner=b.username  
	  AND a.owner not in ('GSMADMIN_INTERNAL')
	  AND (a.TABLE_NAME like '%\_2014%' escape '\'  
	  OR a.TABLE_NAME like '%\_2015%' escape '\'  
	  OR a.TABLE_NAME like '%\_2016%' escape '\'  
	  OR a.TABLE_NAME like '%\_2017%' escape '\'  
	  OR a.TABLE_NAME like '%\_2018%' escape '\'  
	  OR a.TABLE_NAME like '%\_2019%' escape '\')  
	  AND (COMPRESS_FOR <> 'QUERY HIGH' OR COMPRESS_FOR is null)
	  AND a.partitioned = 'NO' 
	  AND TEMPORARY = 'N' 
	  order by 1 desc ) 
  LOOP 
  BEGIN 
  EXECUTE IMMEDIATE 'ALTER TABLE "'|| r.OWNER||'"."'|| r.table_name|| '" MOVE TABLESPACE '|| r.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4 update indexes'; 
  EXCEPTION 
     WHEN OTHERS THEN 
        /* Your exception handing here. */ 
        NULL; 
     END; 
  END LOOP; 
END; 
/ 



BEGIN 
  FOR r IN (select OWNER,table_name,DEFAULT_TABLESPACE FROM dba_tables a ,dba_users b 
	  WHERE a.owner=b.username  
	  AND a.owner not in ('GSMADMIN_INTERNAL')
	  AND (a.TABLE_NAME like '%2014%'  
	  OR a.TABLE_NAME like '%2015%'
	  OR a.TABLE_NAME like '%2016%'
	  OR a.TABLE_NAME like '%2017%'
	  OR a.TABLE_NAME like '%2018%'  
	  OR a.TABLE_NAME like '%2019%') 
	  AND (COMPRESS_FOR <> 'QUERY HIGH' OR COMPRESS_FOR is null)
	  AND a.partitioned = 'NO' 
	  AND TEMPORARY = 'N' 
	  order by 1 desc ) 
  LOOP 
  BEGIN 
  EXECUTE IMMEDIATE 'ALTER TABLE "'|| r.OWNER||'"."'|| r.table_name|| '" MOVE TABLESPACE '|| r.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4 update indexes'; 
  EXCEPTION 
     WHEN OTHERS THEN 
        /* Your exception handing here. */ 
        NULL; 
     END; 
  END LOOP; 
END; 
/ 
