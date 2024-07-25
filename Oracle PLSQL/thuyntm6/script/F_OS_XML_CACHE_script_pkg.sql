
  CREATE TABLE "T24LIVE"."TBL_LOG_PURGE_OS_XML_CACHE" 
   (	"JOB_ID" NUMBER, 
	"JOB_NAME" VARCHAR2(25 BYTE), 
	"START_TIME" TIMESTAMP (6), 
	"END_TIME" TIMESTAMP (6), 
	"FROM_DATE" NUMBER, 
	"FROM_HR" NUMBER, 
	"TO_DATE_" NUMBER, 
	"TO_HR" NUMBER, 
	"STATUS" NUMBER, 
	"ERROR_MESSAGE" VARCHAR2(4000 BYTE), 
	"PARAM_" VARCHAR2(255 BYTE), 
	"DUR_" NUMBER, 
	"NO_OF_USER" NUMBER, 
	"NO_OF_CACHE" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATAT24LIVE" ;
  
  
CREATE SEQUENCE  "T24LIVE"."SEQ_TBL_LOG_PURGE_OS_XML_CACHE"  MINVALUE 1 MAXVALUE 9999999999999999 INCREMENT BY 1 START WITH 789 NOCACHE  NOORDER  NOCYCLE ;


create package  T24LIVE.PKG_PURGE_OS_XML_CACHE IS 

  PROCEDURE prd_purge_os_xml_cache(P_job_name In varchar2,p_rowsnum In NUMBER,p_interval In NUMBER,ret_status out NUMBER, ret_errmsg out varchar2);
  
end PKG_PURGE_OS_XML_CACHE;
/

 
create  PACKAGE BODY T24LIVE.PKG_PURGE_OS_XML_CACHE AS 

   PROCEDURE prd_purge_os_xml_cache(P_job_name In varchar2,p_rowsnum In NUMBER,p_interval In NUMBER,ret_status out NUMBER, ret_errmsg out varchar2) AS   
 v_maxdelscn  NUMBER;
-- v_rowcnt NUMBER;
 v_job_id number;
  v_from_time varchar2(16);
  v_to_time   varchar2(16) := to_char(sysdate - (1/1440*p_interval),'yyyymmddhh24miss')  ;
  p_date number := to_number(to_char(sysdate,'yyyymmdd'));
  v_err_desc varchar2(4000);
  v_job_name varchar2(16):='JOB_HOUR';
   P_Out_DeletedRows number:= 0;
  
  BEGIN
  
 SELECT SEQ_TBL_LOG_PURGE_OS_XML_CACHE.nextval into v_job_id from dual;
INSERT INTO TBL_LOG_PURGE_OS_XML_CACHE( job_id, job_name, Start_TIME, STATUS, from_date, from_hr, to_date_, to_hr, param_)
VALUES(v_job_id,P_job_name, systimestamp,0,to_number(substr(v_to_time,1,8)),v_from_time,p_date,v_to_time,'P_job_name = ' || P_job_name || ' p_date = '|| to_char(p_date) || ' p_interval = '||p_interval);
commit;  

  if P_job_name = 'JOB_HOUR' then
  --Get max(ORA_ROWSCN) of row older last 1 hour
 select max(ORA_ROWSCN) into v_maxdelscn from F_OS_XML_CACHE where instr(recid,'USER.PROFILE')=0 and ORA_ROWSCN < TIMESTAMP_TO_SCN(systimestamp-numtodsinterval( p_interval, 'minute' ));
 
elsif  P_job_name = 'JOB_24HOUR' then  
  select max(ORA_ROWSCN) into v_maxdelscn from F_OS_XML_CACHE where ORA_ROWSCN < TIMESTAMP_TO_SCN(systimestamp-numtodsinterval( p_interval, 'minute' ));
end if;


 -- loop delete cache
 if P_job_name = 'JOB_HOUR' then
begin 
LOOP
delete from f_os_xml_cache  where instr(recid,'USER.PROFILE')=0 and ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount;    
exit when sql%rowcount = 0;
--dbms_lock.sleep(15);
commit;
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
delete from f_os_xml_cache  where  ORA_ROWSCN<= v_maxdelscn and Rownum<= p_rowsnum ;
P_Out_DeletedRows := P_Out_DeletedRows + SQL%rowcount;   
exit when sql%rowcount = 0;
--dbms_lock.sleep(15);
commit;
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
/

ALTER PACKAGE T24LIVE.PKG_PURGE_OS_XML_CACHE COMPILE;