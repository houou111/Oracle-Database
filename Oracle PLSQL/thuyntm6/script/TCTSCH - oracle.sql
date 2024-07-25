--EM report
SELECT distinct CASE
          WHEN A.host_name LIKE 'd_-oradb-0_' THEN 'FARMZ'
          WHEN A.host_name LIKE 'd_-ora-db0_' THEN 'FARM_OLD'
          WHEN A.host_name LIKE 'd_-citad-db' THEN 'CITAD'
          WHEN A.host_name LIKE 'dw0_%' THEN 'DWH'
          WHEN A.host_name = 'dc-emv-db.Headquarter.techcombank.com.vn' THEN 'EMV'
          WHEN A.host_name LIKE 'd_-esb-db-0_' THEN 'ESB'
          WHEN A.host_name LIKE 'd_-core-db-0_' THEN 'T24'
          WHEN A.host_name LIKE 'd_-tcbs-db-0_' THEN 'TCBS'
          WHEN A.host_name LIKE 'd_-card-db-0_' THEN 'CARD'
          WHEN A.host_name='dc-em13c-db01.techcombank.com.vn' THEN 'EM13C'
          ELSE             A.host_name
       END host_name,
       Case 
            When A.type_qualifier3='RACINST' then  substr(A.target_name,0,length(A.target_name)-1)
            else A.target_name
       end target_name, 
       Case
            when Db_Audit is null then 'data not collected'
            when Db_Audit <29 and B.target_name in ('t24r14dc1','t24r14dc2','t24rptdc_1','t24rptdc_2','t24rptdr_1','t24rptdr_2','monthend1','year12','year13','year14','year15','year16','year17') 
            then 'NOK - '||Db_Audit||'/29'
            else 'OK'
       end Db_Audit, 
       Case
            when DB_param='false|true|os|false|true|10|drop,3|log|false|true' then 'OK'
            when DB_param is null then 'data not collected'
            else 'NOK'
       end param, 
       Case
            when DB_param='false|true|os|false|true|10|drop,3|log|false|true' then ''
            else DB_param
       end DB_param_detail ,            
       Case 
            when Public_privs=0 then 'OK'
            when Public_privs>0 then 'NOK'
            when Public_privs is null then 'data not collected'
       end Public_privs, 
       Case 
            when user_profile ='MDSYS' then 'OK'
            when user_profile is null then 'data not collected'
            else 'NOK'
       end user_profile, 
       Case 
            when user_profile ='MDSYS' then ''
            when user_profile is null then ''
            else replace(replace (user_profile,'MDSYS|',''),'MDSYS','')
       end  user_profile_detail,
       case 
            when Profile_Enduser like '16.%|%|%|%|5|%|%|%|10|60|1|4|240|%verify_function|%|10' then 'OK'
            when Profile_Enduser is null then 'data not collected'
            when Profile_Enduser like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_Enduser, 
       Case 
            when Profile_Enduser like '16.%|%|%|%|5|%|%|%|10|60|1|4|240|%verify_function|%|10' or Profile_Enduser is null or Profile_Enduser like '0.%'  then ''
            else Profile_Enduser
       end Profile_Enduser_detail,
       Case
            when Profile_Service like '16.%|%|%|%|unlimited|%|%|%|%|unlimited|%|%|%|%verify_function|%|unlimited' then 'OK'
            when Profile_Service is null then 'data not collected'
            when Profile_Service like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_Service, 
       Case 
            when Profile_Service like '16.%|%|%|%|unlimited|%|%|%|%|unlimited|%|%|%|%verify_function|%|unlimited' or Profile_Service is null or Profile_Service like '0.%'  then '' 
            else Profile_Service
       end Profile_Service_detail,
       case 
            when Profile_DBA like '16.%|%|%|%|5|%|%|%|%|unlimited|1|%|%|%verify_function|%|%' then 'OK'
            when Profile_DBA is null then 'data not collected'
            when Profile_DBA like '0.%' then 'dont have this profile'
            else 'NOK'
       end Profile_DBA, 
       case 
            when Profile_DBA like '16.%|%|%|%|5|%|%|%|%|unlimited|1|%|%|%verify_function|%|%' or Profile_DBA is null or Profile_DBA like '0.%' then ''
            else Profile_DBA
       end Profile_DBA_detail
  FROM (SELECT tar.target_name, tar.host_name, tar.type_qualifier3
          FROM mgmt$target tar , mgmt$availability_current  avai
         WHERE     tar.target_type = 'oracle_database'
               AND tar.type_qualifier4 NOT LIKE '%Standby'
               AND avai.AVAILABILITY_STATUS = 'Target Up'
               AND tar.target_name=avai.target_name) A
       LEFT JOIN
       (SELECT target_name, VALUE AS Db_Audit
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_Audit'
               AND collection_timestamp > SYSDATE - 1) B
          ON A.target_name = B.target_name              
       LEFT JOIN
       (SELECT target_name, lower(VALUE) AS DB_param
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_DB_param'
               AND collection_timestamp > SYSDATE - 1) C
          ON A.target_name = C.target_name            
       LEFT JOIN
       (SELECT target_name, VALUE AS Public_privs
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_Public_privs'
               AND collection_timestamp > SYSDATE - 1) D
          ON A.target_name = D.target_name                                                                               
       LEFT JOIN
       (SELECT target_name, VALUE AS user_profile
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_user_profile'
               AND collection_timestamp > SYSDATE - 1) E
          ON A.target_name = E.target_name          
       LEFT JOIN
       (SELECT target_name, lower(VALUE) AS Profile_Enduser
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_Profile_Enduser'
               AND collection_timestamp > SYSDATE - 1) G
          ON A.target_name = G.target_name
       LEFT JOIN          
       (SELECT target_name, lower(VALUE) AS Profile_Service
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_Profile_Service'
               AND collection_timestamp > SYSDATE - 1) H
          ON A.target_name = H.target_name 
       LEFT JOIN
       (SELECT target_name, lower(VALUE) AS Profile_dba
          FROM mgmt$metric_current
         WHERE     metric_name = 'ME$TCTSCH_Profile_dba'
               AND collection_timestamp > SYSDATE - 1) I
          ON A.target_name = I.target_name       
order by host_name,target_name          



1. Listener restrict
vi listener.ora
ADMIN_RESTRICTIONS_LISTENER = ON
ADMIN_RESTRICTIONS_LISTENER_SCAN1 = ON
ADMIN_RESTRICTIONS_LISTENER_SCAN2 = ON
ADMIN_RESTRICTIONS_LISTENER_SCAN3 = ON

lsnrctl reload LISTENER
lsnrctl reload LISTENER_SCAN1
lsnrctl reload LISTENER_SCAN2
lsnrctl reload LISTENER_SCAN3


2. profile
--version 11g
CREATE  FUNCTION "SYS"."ORA_COMPLEXITY_CHECK"
(password varchar2,
 chars integer := null,
 letter integer := null,
 upper integer := null,
 lower integer := null,
 digit integer := null,
 special integer := null)
return boolean is
   digit_array varchar2(10) := '0123456789';
   alpha_array varchar2(26) := 'abcdefghijklmnopqrstuvwxyz';
   cnt_letter integer := 0;
   cnt_upper integer := 0;
   cnt_lower integer := 0;
   cnt_digit integer := 0;
   cnt_special integer := 0;
   delimiter boolean := false;
   len integer := nvl (length(password), 0);
   i integer ;
   ch char(1);
begin
   -- Check that the password length does not exceed 2 * (max DB pwd len)
   -- The maximum length of any DB User password is 128 bytes.
   -- This limit improves the performance of the Edit Distance calculation
   -- between old and new passwords.
   if len > 256 then
      raise_application_error(-20020, 'Password length more than 256 characters'
);
   end if;

   -- Classify each character in the password.
   for i in 1..len loop
      ch := substr(password, i, 1);
      if ch = '"' then
         delimiter := true;
      elsif instr(digit_array, ch) > 0 then
         cnt_digit := cnt_digit + 1;
      elsif instr(alpha_array, nls_lower(ch)) > 0 then
         cnt_letter := cnt_letter + 1;
         if ch = nls_lower(ch) then
            cnt_lower := cnt_lower + 1;
         else
            cnt_upper := cnt_upper + 1;
         end if;
      else
         cnt_special := cnt_special + 1;
      end if;
   end loop;

   if delimiter = true then
      raise_application_error(-20012, 'password must NOT contain a '
                               || 'double-quotation mark which is '
                               || 'reserved as a password delimiter');
   end if;
   if chars is not null and len < chars then
      raise_application_error(-20001, 'Password length less than ' ||
                              chars);
   end if;

   if letter is not null and cnt_letter < letter then
      raise_application_error(-20022, 'Password must contain at least ' ||
                                      letter || ' letter(s)');
   end if;
   if upper is not null and cnt_upper < upper then
      raise_application_error(-20023, 'Password must contain at least ' ||
                                      upper || ' uppercase character(s)');
   end if;
   if lower is not null and cnt_lower < lower then
      raise_application_error(-20024, 'Password must contain at least ' ||
                                      lower || ' lowercase character(s)');
   end if;
   if digit is not null and cnt_digit < digit then
      raise_application_error(-20025, 'Password must contain at least ' ||
                                      digit || ' digit(s)');
   end if;
   if special is not null and cnt_special < special then
      raise_application_error(-20026, 'Password must contain at least ' ||
                                      special || ' special character(s)');
   end if;

   return(true);
end;
/


CREATE  FUNCTION "SYS"."ORA_STRING_DISTANCE"
(s varchar2,
 t varchar2)
return integer is
   s_len    integer := nvl (length(s), 0);
   t_len    integer := nvl (length(t), 0);
   type arr_type is table of number index by binary_integer;
   d_col    arr_type ;
   dist     integer := 0;
begin
   if s_len = 0 then
      dist := t_len;
   elsif t_len = 0 then
      dist := s_len;
   -- Bug 18237713 : If source or target length exceeds max DB password length
   -- that is 128 bytes, then raise exception.
   elsif t_len > 128 or s_len > 128 then
     raise_application_error(-20027,'Password length more than 128 bytes');
   elsif s = t then
     return(0);
   else
      for j in 1 .. (t_len+1) * (s_len+1) - 1 loop
          d_col(j) := 0 ;
      end loop;
      for i in 0 .. s_len loop
          d_col(i) := i;
      end loop;
      for j IN 1 .. t_len loop
          d_col(j * (s_len + 1)) := j;
      end loop;

      for i in 1.. s_len loop
        for j IN 1 .. t_len loop
          if substr(s, i, 1) = substr(t, j, 1)
          then
             d_col(j * (s_len + 1) + i) := d_col((j-1) * (s_len+1) + i-1) ;
          else
             d_col(j * (s_len + 1) + i) := LEAST (
                       d_col( j * (s_len+1) + (i-1)) + 1,      -- Deletion
                       d_col((j-1) * (s_len+1) + i) + 1,       -- Insertion
                       d_col((j-1) * (s_len+1) + i-1) + 1 ) ;  -- Substitution
          end if ;
        end loop;
      end loop;
      dist :=  d_col(t_len * (s_len+1) + s_len);
   end if;

   return (dist);
end;
/
GRANT EXECUTE ON ORA_COMPLEXITY_CHECK TO PUBLIC;
GRANT EXECUTE ON ORA_STRING_DISTANCE TO PUBLIC;

--version 11g + 12
CREATE FUNCTION "SYS"."ORA_VERIFY_FUNCTION"
(username varchar2,
 password varchar2,
 old_password varchar2)
RETURN boolean IS
   differ integer;
   db_name varchar2(40);
   i integer;
BEGIN
   IF NOT ora_complexity_check(password, chars => 12, upper => 1, lower => 1, digit => 1, special => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password contains the server name
   select name into db_name from sys.v$database;
   IF regexp_instr(password, db_name, 1, 1, 0, 'i') > 0 THEN
      raise_application_error(-20004, 'Password contains the server name');
   END IF;

   -- Check if the password contains 'oracle'
   IF regexp_instr(password, 'oracle', 1, 1, 0, 'i') > 0 THEN
        raise_application_error(-20006, 'Password too simple');
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 characters
   IF old_password IS NOT NULL THEN
     differ := ora_string_distance(old_password, password);
     IF differ < 3 THEN
        raise_application_error(-20010, 'Password should differ from the '
                                || 'old password by at least 3 characters');
     END IF;
   END IF ;

   RETURN(TRUE);
END;
/

GRANT EXECUTE ON ORA_VERIFY_FUNCTION TO PUBLIC;


create PROFILE "PROFILE_ENDUSER" LIMIT
  SESSIONS_PER_USER 10
  CPU_PER_SESSION DEFAULT
  CPU_PER_CALL DEFAULT
  IDLE_TIME DEFAULT
  LOGICAL_READS_PER_SESSION DEFAULT
  LOGICAL_READS_PER_CALL DEFAULT
  COMPOSITE_LIMIT DEFAULT
  PRIVATE_SGA DEFAULT
  FAILED_LOGIN_ATTEMPTS 5
  PASSWORD_LIFE_TIME 60
  PASSWORD_REUSE_TIME 240
  PASSWORD_REUSE_MAX 4
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 10
  PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;

CREATE PROFILE "PROFILE_SERVICE_ACCOUNT" LIMIT
PASSWORD_LIFE_TIME UNLIMITED
SESSIONS_PER_USER UNLIMITED
FAILED_LOGIN_ATTEMPTS UNLIMITED
PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;

CREATE PROFILE "DBA_PROFILE" LIMIT
PASSWORD_LIFE_TIME UNLIMITED
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LOCK_TIME 1
PASSWORD_VERIFY_FUNCTION ORA_VERIFY_FUNCTION;


--------

 alter user dbsnmp identified by PAssw0rd;
 grant sysdba to dbsnmp;
 alter user dbsnmp account unlock;
 
alter user sys profile DBA_PROFILE;
alter user system profile DBA_PROFILE;
alter user DBA01 profile DBA_PROFILE;
alter user DBA02 profile DBA_PROFILE;
alter user DBSNMP profile DBA_PROFILE;
alter user ASMSNMP profile DBA_PROFILE;


3. DB's parameter'
alter system set sec_return_server_release_banner = false scope=spfile sid='*';
alter system set audit_trail = os scope=spfile sid='*';
alter system set audit_sys_operations=true scope=spfile sid='*';
alter system set remote_os_roles = false scope=spfile sid='*';
alter system set o7_dictionary_accessibility=false scope=spfile sid='*';
alter system set sec_max_failed_login_attempts = 10 scope = spfile sid='*';
alter system set sec_protocol_error_further_action = 'drop,3' scope = spfile sid='*';
alter system set sec_protocol_error_trace_action=log scope = spfile sid='*';
alter system set sql92_security = true scope = spfile sid='*';
alter system set sec_case_sensitive_logon = true scope = both sid='*';

--t24
alter system set event='44951 TRACE NAME CONTEXT FOREVER, LEVEL 128' scope = spfile sid='*';
alter system set open_cursors=30000 scope = both sid='*';
alter system set processes=6605 scope=spfile sid='*';
alter system set query_rewrite_integrity='TRUSTED' scope=spfile sid='*';
alter system set session_cached_cursors=5000  scope=spfile sid='*';
alter system set session_max_open_files=30  scope=spfile sid='*';
alter system set undo_retention=7200 scope=spfile sid='*';


col name for a50
col value for a10
select name, value from v$parameter where name like 'sec_return_server_release_banner';

col name for a50
col value for a10
select name, value from v$parameter where name in ('audit_trail','audit_sys_operations','remote_os_roles','sec_return_server_release_banner'
,'O7_DICTIONARY_ACCESSIBILITY','remote_os_authent','sec_max_failed_login_attempts','sec_case_sensitive_logon',
'sec_protocol_error_further_action','sec_protocol_error_trace_action','sql92_security');



4. revoke privilege from public
--check
select count(*) from 
(
select case 
when owner='SYS' then table_name
when owner<>'SYS' then owner||'.'||table_name
end as privs
from role_tab_privs where 
(table_name  in ('CREATE EXTERNAL JOB','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
or (table_name ='ORD_DICOM' and owner='ORDSYS')
or (table_name ='DRITHSX' and owner='CTXSYS'))
and role in (SELECT granted_role FROM DBA_ROLE_PRIVS where grantee='PUBLIC'
)
union all
select privilege from role_sys_privs
where privilege  ='CREATE EXTERNAL JOB'
and role in (SELECT granted_role FROM DBA_ROLE_PRIVS where grantee='PUBLIC')
union all
select case 
when owner='SYS' then table_name
when owner<>'SYS' then owner||'.'||table_name
end as privs
from dba_tab_privs where
(table_name  in ('CREATE EXTERNAL JOB','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','DBMS_RANDOM','DBMS_SCHEDULER','DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS','UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
)

--grant
select listagg( USERNAME,''',''') WITHIN GROUP (ORDER BY USERNAME)
 from dba_users where (account_status='OPEN' or account_status like 'LOCK%')
 and username not in ('SYS','SYSTEM','T24LIVE','T24_LIVE_DWH')

DECLARE
   cmd2        VARCHAR2 (4000);
   cmd3        VARCHAR2 (4000);
   cmd4        VARCHAR2 (4000);
   cnt number;

   CURSOR c_tab
   IS
select owner||'.'||table_name as privs from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER'
,'DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS',
'UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;

BEGIN
   FOR v_tab IN c_tab
   LOOP
   for tab in (select username from dba_users where username not in 
   ('DBA01','DBA02','THUYNTM_DBA'))
   --year12 ('DBA01','DBA02','DBSNMP','HANGDT_USER','HOANNT_DBA','SRV_DB_BACKUP','THUYNTM_DBA','TRUNGHX_DBA'))
   --year13 ('DBA01','DBA02','DBSNMP','HOANNT_DBA','SRV_DB_BACKUP','THUYNTM_DBA'))
   --year14 ('ARCSIGHT','DBA01','DBA02','DBSNMP','DUYDX_DBA','HOANNT_DBA','SRV_BMC_T24DB','SRV_DB_BACKUP','THUYNTM_DBA','TRUNGHX_DBA','GG12'))
   --year15 ('ARCSIGHT','DBA01','DBA02','DBSNMP','GG12','HOANNT_DBA','SRV_BMC_T24DB','SRV_DBT24_GUARD','SRV_DB_BACKUP','THINHNH_DBA','THUYNTM_DBA','TRUNGHX_DBA'))    
   --year16 ('ARCSIGHT','DBA01','DBA02','DBSNMP','DUONGPK','GG12','HOANNT_DBA','SRV_DBT24_GUARD','SRV_DB_BACKUP','THUYNTM_DBA'))
   --year17 ('DBA01','DBA02','DBSNMP','DUONGPK','GG12','HOANNT_DBA','SRV_BMC_T24DB','SRV_DBT24_GUARD','SRV_DB_BACKUP','THUYNTM6','THUYNTM_DBA'))
   --t24rptdc ('DBSNMP','THUYNTM_DBA'))
   loop
   cmd3 := 'select count(*)  from dba_tab_privs where grantee='''||tab.username||''' and owner||''.''||table_name='''||v_tab.privs||'''';
   --DBMS_OUTPUT.put_line (cmd3);
   EXECUTE IMMEDIATE cmd3 into cnt;
   --DBMS_OUTPUT.put_line (cnt);
   if cnt =0 then 
      cmd2 :='revoke execute on '|| v_tab.privs ||' from '||tab.username||';';
      cmd2 :='grant execute on '|| v_tab.privs ||' to '||tab.username||';';
   DBMS_OUTPUT.put_line (cmd2); 
   end if;  
end loop;
   END LOOP;
   EXCEPTION
        WHEN OTHERS THEN
            NULL;
END;
/


--revoke
select 
'revoke execute on '||owner||'.'||table_name||' from public;' as privs 
--rollback 'grant execute on '||owner||'.'||table_name||' to public;' as privs 
from dba_tab_privs where
(table_name  in ('UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_HTTP','UTL_INADDR','UTL_FILE','DBMS_SQL','DBMS_AW_XML','KUPP$PRO','CREATE EXTERNAL JOB','DBMS_RANDOM','DBMS_SCHEDULER'
,'DBMS_XMLGEN','DBMS_SYS_SQL','DBMS_JOB','DBMS_BACKUP_RESTORE','DBMS_ADVISOR','DBMS_JAVA','DBMS_JAVA_TEST','DBMS_LDAP','DBMS_OBFUSCATION_TOOLKIT','DBMS_XMLQUERY','UTL_DBWS',
'UTL_ORAMTS','HTTPURITYPE','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS','DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS','DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM',
'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_FILE_TRANSFER')
and grantee='PUBLIC')
or (table_name ='ORD_DICOM' and owner='ORDSYS' and grantee='PUBLIC')
or (table_name ='DRITHSX' and owner='CTXSYS' and grantee='PUBLIC')
;
 


5. audit -Enable các tham số default cần lấy log
--check
 select privilege,success from dba_priv_audit_opts;

audit alter any procedure; 
audit alter any table;   
audit alter database;   
audit alter profile;   
audit alter system;   
audit alter user;  
audit audit system;   
audit create any job;   
audit create any library;   
audit create any procedure;   
audit create any table;  
audit create external job;   
audit create public database link;   
audit create session;   
audit create user;   
audit drop any procedure;    
audit drop any table; 
audit drop profile; 
audit drop user; 
audit exempt access policy; 
audit grant any object privilege; 
audit grant any privilege; 
audit grant any role; 
audit database link;   
audit role;
audit system audit;
audit profile;
audit public synonym;
audit system grant;