drop table T24LIVE.F_OS_XML_CACHE cascade constraint;

CREATE TABLE T24LIVE.F_OS_XML_CACHE
(
  RECID      VARCHAR2(255 BYTE),
  XMLRECORD  SYS.XMLTYPE
)
XMLTYPE XMLRECORD STORE AS CLOB (
  TABLESPACE  DATAT24LIVE
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  PCTVERSION  10
  NOCACHE
  NOLOGGING)
NOCOMPRESS 
TABLESPACE DATAT24LIVE
PARTITION BY HASH (RECID)
  PARTITIONS 256
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX T24LIVE.F_OS_XML_CACHE_PAR_PK ON T24LIVE.F_OS_XML_CACHE
(RECID)local  TABLESPACE INDEXT24LIVE
LOGGING;


ALTER TABLE T24LIVE.F_OS_XML_CACHE ADD (
  CONSTRAINT F_OS_XML_CACHE_PAR_PK
  PRIMARY KEY
  (RECID)
  USING INDEX LOCAL
  ENABLE VALIDATE);
