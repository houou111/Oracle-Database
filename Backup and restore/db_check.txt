SET Serveroutput on
SET FEEDBACK OFF
SPOOL F:\test.csv append 
  
DECLARE 
        db_name varchar2(20);
        day date;
        db_size_GB number(20);
        arch_size_GB number(20);
        db_status varchar2(20);
        size_backup_GB varchar2(20);
BEGIN

        select sys_context('userenv','db_name')
        INTO db_name 
        from dual;
        
        select (sysdate-1)
        INTO day
        from dual;
        
        Select round(sum(bytes/1024/1024/1024),2)
        INTO db_size_GB
        from dba_segments;
        
        select round((count(1)*(Select bytes/1024/1024/1024 from v$log where rownum=1)),2)
        INTO arch_size_GB
        from v$log_history 
        where to_char(trunc(first_time))=(select to_char(sysdate-1) from dual)
        group by trunc(first_time);
        
        select round((sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024),2) 
        INTO size_backup_GB
        from V$BACKUP_DATAFILE
        where to_char(trunc(completion_time))=(select to_char(sysdate-1) from dual)
        group by trunc(completion_time);

        IF arch_size_GB <= 5*db_size_GB THEN
      db_status := 'normal';
        ELSIF arch_size_GB > 5*db_size_GB and arch_size_GB <= 7*db_size_GB THEN
      db_status := 'warning';
        ELSE
      db_status := 'critical';
        END IF;
        
        dbms_output.put_line(db_name ||','|| day ||','|| db_size_GB ||','|| arch_size_GB ||','|| db_status ||','|| size_backup_GB );

                
EXCEPTION
        WHEN NO_DATA_FOUND THEN
dbms_output.put_line('Error'); 
END;
/
spool off;
exit;