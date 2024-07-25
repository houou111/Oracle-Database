-- incomplete
DECLARE
    TYPE typ IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    t typ;
    h NUMBER;
BEGIN
    WHILE TRUE LOOP        
        t(DBMS_UTILITY.GET_SQL_HASH('SELECT * FROM DUAL WHERE ROWNUM = '||TO_CHAR(i))) := i;    
        EXIT;
    END LOOP;
END;
/
