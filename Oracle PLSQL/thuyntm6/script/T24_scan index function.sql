-----User and privileges
alter user t24live grant connect through thuyntm_dba;

-----login 
sqlplus thuyntm_dba[t24live]

-----scan index function 
set line 200;
set timing on;
exec DBMS_MVIEW.REFRESH ('mv_user_indexes'); 
DECLARE
   CURSOR c IS SELECT column_expression, index_name FROM user_ind_expressions;
   rc   c%ROWTYPE;
BEGIN
   OPEN c;
   DELETE FROM mv_user_ind_expressions;
   LOOP
      FETCH c INTO rc;
      EXIT WHEN c%NOTFOUND;
      INSERT INTO mv_user_ind_expressions (column_expression, index_name)
           VALUES (rc.column_expression, rc.index_name);
   END LOOP;
   COMMIT;
END;
/