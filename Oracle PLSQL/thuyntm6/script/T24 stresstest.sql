CREATE TABLE T24LIVE.XML_TEST
(
  RECID      VARCHAR2(255 BYTE),
  XMLRECORD  SYS.XMLTYPE
)
XMLTYPE XMLRECORD STORE AS SECUREFILE BINARY XML (
  TABLESPACE  USERS
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  PCTVERSION  10
  NOCACHE
  NOLOGGING)
NOCOMPRESS 
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    20
INITRANS   120
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
PARTITION BY HASH (RECID)
  PARTITIONS 256
NOCACHE
NOPARALLEL
MONITORING;

CREATE UNIQUE INDEX T24LIVE.XML_TEST_PAR_PK ON T24LIVE.XML_TEST
(RECID)
  TABLESPACE USERS
  PCTFREE    10
  INITRANS   2
  MAXTRANS   255
  STORAGE    (
              BUFFER_POOL      DEFAULT
              FLASH_CACHE      DEFAULT
              CELL_FLASH_CACHE DEFAULT
             )
LOGGING
LOCAL 
NOPARALLEL;


ALTER TABLE T24LIVE.XML_TEST ADD (
  CONSTRAINT XML_TEST_PAR_PK
  PRIMARY KEY
  (RECID)
  USING INDEX LOCAL
  ENABLE VALIDATE);
  
  
 
  
  
  

  
---merge
declare
x number;
y number;
cmd varchar2(4000);
BEGIN  
FOR loop_counter IN 1..10000000
LOOP 
x := round(dbms_random.value(1,1000));
y := dbms_random.value(1,100000);
cmd :='MERGE INTO T24LIVE.XML_TEST USING DUAL ON (RECID like '''||x||'.%'') '||                                                     
'WHEN MATCHED THEN UPDATE SET XMLRECORD=XMLTYPE(''<row id="'||y||'COMPOSITE.SCREEN_'||y||'_823480617001" xml:space="preserve"><c2>AI.USER.RSA.DATE.NULL</c2><c3>ARCUSER</c3><c4>COMPOSITE.SCREEN_0968563075_823480617001</c4><c5/><c6>'||x||'</c6></row>'', NULL, 1, 1)                                                                     
WHEN NOT MATCHED THEN INSERT (XMLRECORD ,RECID) VALUES(XMLTYPE(''<row id="'||y||'COMPOSITE.SCREEN_'||y||'_823480617001" xml:space="preserve"><c2>AI.USER.RSA.DATE.NULL</c2><c3>ARCUSER</c3><c4>COMPOSITE.SCREEN_0968563075_823480617001</c4><c5/><c6>'||x||'</c6></row>'', NULL, 1, 1) ,'''
||x||'.INSERT.'||round(DBMS_RANDOM.VALUE(100,10000),10)||''')';
execute immediate (cmd);
--DBMS_OUTPUT.put_line (cmd);
COMMIT;
END LOOP;  
END;
/

--delete 
declare 
x number;
y number;
cmd varchar2(1000);
BEGIN  
FOR loop_counter IN 1..10000000
LOOP 
x := round(dbms_random.value(1,1000));
y := dbms_random.value(1,100000);
cmd := 'delete from T24LIVE.XML_TEST where NVL("T24LIVE"."NUMCAST"(EXTRACTVALUE(SYS_MAKEXML("SYS_NC00003$"),''/row/c6'')),0) = '||x;
execute immediate (cmd);
--DBMS_OUTPUT.put_line (cmd);
COMMIT; 
END LOOP; 
END;
/


--select count
declare 
x number;
cmd varchar2(1000);
BEGIN  
FOR loop_counter IN 1..10
LOOP 
x := round(dbms_random.value(1,1000));
--DBMS_OUTPUT.put_line (x);
cmd := 'select count(*) from T24LIVE.XML_TEST where NVL("T24LIVE"."NUMCAST"(EXTRACTVALUE(SYS_MAKEXML("SYS_NC00003$"),''/row/c6'')),0) = '||x;
execute immediate (cmd) into x;
--DBMS_OUTPUT.put_line (cmd);
END LOOP; 
END;
/


--update
declare
cmd varchar2(1000);
BEGIN  
FOR loop_counter IN 1..100000
LOOP 
cmd :='UPDATE T24LIVE.XML_TEST SET XMLRECORD=XMLTYPE(''<row id="'||
round(dbms_random.value(1,1000))||
'.UPDATE.COMPOSITE.SCREEN_0968563075_823480617001" xml:space="preserve"><c2>AI.USER.RSA.DATE.NULL</c2><c3>ARCUSER</c3><c4>COMPOSITE.SCREEN_0968563075_823480617001</c4><c5/></row>'', NULL, 1, 1) where NVL(EXTRACTVALUE(SYS_MAKEXML("SYS_NC00003$"),''/row/c6''),''^A'') like '''
||round(dbms_random.value(1,1000))||'.%''';
--DBMS_OUTPUT.put_line (cmd);
execute immediate (cmd);
END LOOP; 
COMMIT; 
END;
/ 
