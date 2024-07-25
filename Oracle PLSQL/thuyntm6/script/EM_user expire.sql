-------------------------------------------------------------
--========EM
-------------------------------------------------------------
--user expire
SELECT DISTINCT REGEXP_REPLACE (target_name, '[0-9]', '') as datatabse, username, profile, TO_char(expiry_date,'DD/MM/YY HH24:MI:SS') as expiry_date,
TO_CHAR(TRUNC(SYSDATE+2),'DD/MM/YYYY HH24:MI:SS') AS HIGHLIGHT
  FROM mgmt$db_users
 WHERE     collection_timestamp > TRUNC (SYSDATE) - 2
       AND expiry_date >= TRUNC(SYSDATE)
       AND expiry_date < TRUNC (SYSDATE + 15)
       order by 1,2,3     

SELECT DISTINCT REGEXP_REPLACE (target_name, '[0-9]', ''), username, profile, expiry_date
  FROM mgmt$db_users
 WHERE     collection_timestamp > TRUNC (SYSDATE) - 2
       AND expiry_date > TRUNC (SYSDATE - 7)
       AND expiry_date < TRUNC (SYSDATE + 7)
       order by 1,2,3
	   