create or replace PACKAGE BODY PKG_PURGE_OS_XML_CACHE AS 

   PROCEDURE prd_purge_os_xml_cache(P_job_name In varchar2,p_rowsnum In NUMBER,p_interval In NUMBER,ret_status out NUMBER, ret_errmsg out varchar2) AS   
 v_maxdelscn  NUMBER;
-- v_rowcnt NUMBER;
 v_job_id number;
 v_sub_job_id number := 1;
 v_from_time varchar2(16);
 v_to_time   varchar2(16) := to_char(sysdate - (1/1440*p_interval),'yyyymmddhh24miss')  ;
 p_date number := to_number(to_char(sysdate,'yyyymmdd'));
 v_err_desc varchar2(4000);
 v_job_name varchar2(16):='JOB_HOUR';
 P_Out_DeletedRows number:= 0;
 v_sub_start_time timestamp;
    EXP_ORA_DEADLOCK exception;
   PRAGMA EXCEPTION_INIT (EXP_ORA_DEADLOCK, -60);
   
 type l_rid_tab is table of   F_OS_XML_CACHE.RECID%type;
 l_del_tab l_rid_tab;
 cursor c_hour is
 select recid
  from f_os_xml_cache  
    where 1=1
    and instr(recid,'USER.PROFILE')=0 
    and ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
    
 cursor c_24hour is
 select recid
  from f_os_xml_cache  
    where 1=1
    and ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
  
  BEGIN
  
 SELECT SEQ_TBL_LOG_PURGE_OS_XML_CACHE.nextval into v_job_id from dual;
INSERT INTO TBL_LOG_PURGE_OS_XML_CACHE( job_id, job_name, Start_TIME, STATUS, from_date, from_hr, to_date_, to_hr, param_)
VALUES(v_job_id,P_job_name, systimestamp,0,to_number(substr(v_to_time,1,8)),v_from_time,p_date,v_to_time,
      'P_job_name = ' || P_job_name || ' p_date = '|| to_char(p_date) || ' p_interval = '||p_interval || ' p_rowsnum = ' || p_rowsnum
      );
commit;  

  if P_job_name = 'JOB_HOUR' then
  --Get max(ORA_ROWSCN) of row older last 1 hour
 select max(ORA_ROWSCN) into v_maxdelscn from F_OS_XML_CACHE 
 where 1=1
 and instr(recid,'USER.PROFILE')=0 
 and ORA_ROWSCN < TIMESTAMP_TO_SCN(systimestamp-numtodsinterval( p_interval, 'minute' ));
 
elsif  P_job_name = 'JOB_24HOUR' then  
  select max(ORA_ROWSCN) into v_maxdelscn from F_OS_XML_CACHE where ORA_ROWSCN < TIMESTAMP_TO_SCN(systimestamp-numtodsinterval( p_interval, 'minute' ));
end if;


 -- loop delete cache
 if P_job_name = 'JOB_HOUR' then
begin 

LOOP
begin
    v_sub_start_time := systimestamp;
    open c_hour;
    exit when c_hour%NOTFOUND;
    fetch c_hour bulk collect into l_del_tab limit 1000;
    exit when l_del_tab.count = 0;
    forall i in l_del_tab.first .. l_del_tab.last    
    delete from f_os_xml_cache where recid =l_del_tab(i);
    P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount; 
    commit;
    close c_hour;   
    
--    
--    delete from f_os_xml_cache  
--    where 1=1
--    and instr(recid,'USER.PROFILE')=0 
--    and ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
--    P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount;    
--    exit when sql%rowcount = 0;
--    --dbms_lock.sleep(15);
--    commit;
    exception WHEN EXP_ORA_DEADLOCK THEN 
        BEGIN
          ret_errmsg := substr(sqlerrm, 1, 4000);
          INSERT INTO TBL_LOG_PURGE_OS_XML_CACHE( job_id, job_name, Start_TIME, end_time ,ERROR_MESSAGE, STATUS, from_date, from_hr, to_date_, to_hr, param_, NO_OF_CACHE)
          select to_number(to_char(v_job_id )|| '.' || to_char(v_sub_job_id)) as job_id,
                  job_name,
                  v_sub_start_time as Start_TIME,
                  systimestamp as END_TIME,
                  ret_errmsg as ERROR_MESSAGE,
                  2 as STATUS,
                  from_date, from_hr, to_date_, to_hr, param_, 
                  P_Out_DeletedRows as NO_OF_CACHE
          from TBL_LOG_PURGE_OS_XML_CACHE
          where job_id = v_job_id;
          commit;

        END;
end;

v_sub_job_id := v_sub_job_id + 1;


END LOOP;

update TBL_LOG_PURGE_OS_XML_CACHE
set END_TIME = systimestamp,
    status = 1,
    NO_OF_CACHE = P_Out_DeletedRows,
    DUR_ = (sysdate - cast (start_time as date)) * 24 * 60 * 60
where JOB_ID = v_job_id;
commit;
end;
elsif P_job_name = 'JOB_24HOUR' then
begin 
/*
WHILE idx <= v_rowcnt
LOOP   
   delete from f_os_xml_cache  where ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
   P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount;    
  dbms_lock.sleep(30);
  commit;
  select idx + p_rowsnum into idx from dual;  
END LOOP;
*/
LOOP
begin

    v_sub_start_time := systimestamp;
    open c_24hour;
    exit when c_24hour%NOTFOUND;
    fetch c_24hour bulk collect into l_del_tab limit 1000;
    exit when l_del_tab.count = 0;
    forall i in l_del_tab.first .. l_del_tab.last    
    delete from f_os_xml_cache where recid =l_del_tab(i);
    P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount; 
    commit;
    close c_24hour;   
    
    exception WHEN EXP_ORA_DEADLOCK THEN 
        BEGIN
          ret_errmsg := substr(sqlerrm, 1, 4000);
          INSERT INTO TBL_LOG_PURGE_OS_XML_CACHE( job_id, job_name, Start_TIME, end_time ,ERROR_MESSAGE, STATUS, from_date, from_hr, to_date_, to_hr, param_, NO_OF_CACHE)
          select to_number(to_char(v_job_id )|| '.' || to_char(v_sub_job_id)) as job_id,
                  job_name, 
                  v_sub_start_time as Start_TIME,
                  systimestamp as END_TIME,
                  ret_errmsg as ERROR_MESSAGE,
                  2 as STATUS,
                  from_date, from_hr, to_date_, to_hr, param_, 
                  P_Out_DeletedRows as NO_OF_CACHE
          from TBL_LOG_PURGE_OS_XML_CACHE
          where job_id = v_job_id;
          commit;
        END;
        
end;
v_sub_job_id := v_sub_job_id + 1;

END LOOP;

update TBL_LOG_PURGE_OS_XML_CACHE
set END_TIME = systimestamp,
    status = 1,
    NO_OF_CACHE = P_Out_DeletedRows,
    DUR_ = (sysdate - cast (start_time as date)) * 24 * 60 * 60
where JOB_ID = v_job_id;
commit;
end;
end if;
ret_status :=1;
exception WHEN others THEN 
        BEGIN
          ret_errmsg := substr(sqlerrm, 1, 4000);
          ret_status :=2;
          ROLLBACK;
          UPDATE TBL_LOG_PURGE_OS_XML_CACHE
            SET end_time = SYSDATE, status = 2, ERROR_MESSAGE = ret_errmsg
          WHERE JOB_ID = v_job_id;
          COMMIT;
        END;
commit;

END prd_purge_os_xml_cache;

 
END PKG_PURGE_OS_XML_CACHE;


ALTER PACKAGE T24LIVE.PKG_PURGE_OS_XML_CACHE COMPILE;
