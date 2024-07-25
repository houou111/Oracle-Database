--GRANT EXECUTE ON DBMS_LOCK TO PUBLIC;
DEF conn=tanel/oracle@sol02

GRANT EXECUTE ON dbms_lock TO tanel;

CONNECT &conn

SET SERVEROUT ON SIZE 1000000
SET ECHO ON
CLEAR SCREEN

DROP TABLE t PURGE;
DROP TRIGGER write_consistency;

CLEAR SCREEN

CREATE TABLE t (id INT, name VARCHAR2(100));

INSERT INTO t VALUES ( 1, 'A' );
INSERT INTO t VALUES ( 2, 'B' );
INSERT INTO t VALUES ( 3, 'C' );

COMMIT;

PAUSE
CLEAR SCREEN

CREATE OR REPLACE TRIGGER write_consistency BEFORE UPDATE ON t 
FOR EACH ROW 
BEGIN
    DBMS_OUTPUT.PUT_LINE('Im fired! :old.name='||:old.name);
END;
/

UPDATE t SET name = 'C->Session1' WHERE id = 3;

/*
  Now update that table in another session
*/
PAUSE
HOST START sqlplus &conn @aot/08_write_consistency_2.sql
PAUSE
CLEAR SCREEN

UPDATE t SET name = 'A->Session1' WHERE id = 1;

PAUSE
CLEAR SCREEN

UPDATE t SET name = 'B->Session1' WHERE id = 2;
