http://awads.net/wp/2011/02/02/25-unique-ways-to-schedule-a-job-using-the-oracle-scheduler/
---------------------------------------------------------
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_ANALYZE'
      ,start_date      => TO_TIMESTAMP_TZ('2017/04/10 21:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=DAILY'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'begin sys.DBMS_STATS.GATHER_DATABASE_STATS (Granularity=> ''ALL'',Options => ''GATHER'',Estimate_Percent=>dbms_stats.auto_sample_size,Method_Opt=>''FOR ALL COLUMNS SIZE AUTO'',Degree=> 24);end;'
      ,comments        => 'Job to analyze database.'
    );
END;
/	

BEGIN
  DBMS_SCHEDULER.DROP_JOB
    (job_name      => 'SYS.DBA_JOB_ANALYZE_T24LIVE',force        => FALSE);
END;
/
---------------------------------------------------------


BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_ANALYZE_F_IND_HASH_TAB'
      ,start_date      => TO_TIMESTAMP_TZ('2017/04/25 21:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=25'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_ANALYZE_F_IND_HASH_TAB'     
	  ,comments        => 'Job to analyze table partition by hash with index function - T24LIVE.'
    );
	sys.dbms_scheduler.set_attribute
	( 
		 name        => 'SYS.DBA_JOB_ANALYZE_F_IND_HASH_TAB'
		, attribute => 'max_run_duration'
		, value => numtodsinterval(10, 'hour')
		);
		  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_ANALYZE_F_IND_HASH_TAB');
END;
/



--table index function (98 table - 2 day)
create procedure  SYS.DBA_ANALYZE_F_IND_TAB as
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab
   IS
      SELECT DISTINCT t.owner, t.table_name
                  FROM dba_tables t, dba_indexes i
                 WHERE     t.owner = i.table_owner
                       AND t.table_name = I.TABLE_NAME
                       AND t.owner = 'T24LIVE'
                       AND t.partitioned = 'NO'
                       AND i.index_type LIKE 'FUNCTION%'
                       AND t.last_analyzed < SYSDATE - EXTRACT (DAY FROM SYSDATE) + 1
              ORDER BY 2;
BEGIN
   FOR cc IN c_tab
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE );end;';
      DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE  v_tab;
      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE table_name = cc.table_name AND owner = 'T24LIVE' and index_type not like 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE);end;';
         DBMS_OUTPUT.put_line (v_ind);
      EXECUTE IMMEDIATE  v_ind;
      END LOOP;
   END LOOP;
END;
/

--table partition by hash + index function (3 day)
CREATE OR REPLACE procedure SYS.DBA_ANALYZE_F_IND_HASH_TAB as
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab
   IS
      SELECT *
  FROM (SELECT DISTINCT
               t.owner,
               t.table_name,
               CASE
                  WHEN t.table_name IN ('FBNK_ACCOUNT', 'FBNK_INFO_CARD')
                  THEN 'Saturday'
                  WHEN t.table_name IN ('FBNK_CARD_ISSUE','FBNK_CARD_ISSUE#NAU','FBNK_CUSTOMER','FBNK_DEPO_WITHDRA','FBNK_DX_TRANSACTION','FBNK_EB_C005',
                                        'FBNK_FOREX#HIS','FBNK_INFO_CARD#NAU','FBNK_LICH_TPTN_THE_TCB','FBNK_LIMIT','FBNK_MM_M000','FBNK_MM_MONEY_MARKET') THEN 'Sunday'
                  ELSE 'Monday'
               END
                  AS ord
          FROM dba_tables t, dba_indexes i, dba_part_tables p
         WHERE     t.owner = i.table_owner
               AND t.owner = p.owner
               AND t.table_name = I.TABLE_NAME
               AND t.table_name = p.TABLE_NAME
               AND t.owner = 'T24LIVE'
               AND t.partitioned = 'YES'
               AND P.PARTITIONING_TYPE = 'HASH'
               AND i.index_type LIKE 'FUNCTION%')
 WHERE ord = REGEXP_REPLACE (TO_CHAR (SYSDATE, 'Day'), ' ', '')
BEGIN
   FOR cc IN c_tab
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 4 );end;';
      DBMS_OUTPUT.put_line (v_tab);

      EXECUTE IMMEDIATE  v_tab;
      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE table_name = cc.table_name AND owner = 'T24LIVE' and index_type not like 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,Degree => 4 );end;';
         DBMS_OUTPUT.put_line (v_ind);
      EXECUTE IMMEDIATE  v_ind;
      END LOOP;
   END LOOP;
END;
/



--scheduler 
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYS.DBA_JOB_ANALYZE_RANGE_TAB'
      ,start_date      => TO_TIMESTAMP_TZ('2017/05/08 21:00:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY; BYDAY=SUN'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SYS.DBA_ANALYZE_PAR_RANGE'
      ,comments        => 'Job to analyze table partition by range - T24LIVE.'
    );
  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'SYS.DBA_JOB_ANALYZE_RANGE_TAB');
END;
/
-- table partition by range  + index function
/* Formatted on 4/20/2017 10:27:36 AM (QP5 v5.252.13127.32867) */
DECLARE
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab
   IS
        SELECT DISTINCT t.owner, t.object_name,t.subobject_name
    FROM dba_objects t, dba_indexes i, dba_part_tables p, DBA_HIST_SEG_STAT se
   WHERE     t.owner = i.table_owner
         AND t.owner = p.owner
         AND t.object_name = I.TABLE_NAME
         AND t.object_name = p.TABLE_NAME
         AND t.owner = 'T24LIVE'
         AND t.object_type='TABLE PARTITION'
         AND P.PARTITIONING_TYPE = 'RANGE'
         --AND i.index_type LIKE 'FUNCTION%'
         and t.object_id=se.obj#
         and se.SPACE_USED_DELTA <>0
         and se.snap_id > (select min(SNAP_ID) from DBA_HIST_SNAPSHOT where BEGIN_INTERVAL_TIME > sysdate - extract(day from sysdate))
ORDER BY 2;
BEGIN
   FOR cc IN c_tab
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.object_name
         || ''',Partname=>'''
         || cc.subobject_name
         ||''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE);end;';
      DBMS_OUTPUT.put_line (v_tab);

      --EXECUTE IMMEDIATE  v_tab;
      FOR c_index_go
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE table_name = cc.object_name AND owner = 'T24LIVE' and partitioned='NO' and index_type not like 'LOB%' )
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index_go.owner
            || ''',IndName=>'''
            || c_index_go.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE );end;';
         DBMS_OUTPUT.put_line (v_ind);
      --EXECUTE IMMEDIATE  v_ind;
      END LOOP;
      
      FOR c_index_lo
         IN ( SELECT i.index_owner, i.index_name, i.partition_name
               FROM dba_ind_partitions i, dba_tab_partitions t, dba_indexes idx
              WHERE i.index_owner=idx.owner  and i.index_name=idx.index_name
              AND t.table_owner=idx.table_owner   and idx.table_name = t.table_name
              AND i.index_owner = 'T24LIVE' and t.table_owner='T24LIVE'
              and idx.table_name=cc.object_name
              and t.partition_position=i.partition_position
              and t.partition_name=cc.subobject_name
			  and idx.index_type not like 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index_lo.index_owner
            || ''',IndName=>'''
            || c_index_lo.index_name
            || ''',Partname=>'''
            || c_index_lo.partition_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE );end;';
         DBMS_OUTPUT.put_line (v_ind);
      --EXECUTE IMMEDIATE  v_ind;
      END LOOP;
   END LOOP;
END;
/

-- remain table
DECLARE
create procedure SYS.DBA_ANALYZE_REMAIN_TAB as
   v_tab   VARCHAR2 (500);
   v_ind   VARCHAR2 (500);

   CURSOR c_tab
   IS
      SELECT *
        FROM (  SELECT DISTINCT t.owner, t.table_name
                  FROM dba_tables t
                 WHERE     t.owner = 'T24LIVE'
                       AND t.last_analyzed > NEXT_DAY(sysdate,'FRIDAY' ) -7
              ORDER BY 2)
       WHERE ROWNUM < 890;
BEGIN
   FOR cc IN c_tab
   LOOP
      v_tab :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.table_name
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE );end;';
      DBMS_OUTPUT.put_line (v_tab);

      --EXECUTE IMMEDIATE  v_tab;
      FOR c_index
         IN (SELECT owner, index_name
               FROM dba_indexes
              WHERE table_name = cc.table_name AND owner = 'T24LIVE' and index_type not like 'LOB%')
      LOOP
         v_ind :=
               'begin DBMS_STATS.gather_index_stats(OwnName =>'''
            || c_index.owner
            || ''',IndName=>'''
            || c_index.index_name
            || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE );end;';
         DBMS_OUTPUT.put_line (v_ind);
      --EXECUTE IMMEDIATE  v_ind;
      END LOOP;
   END LOOP;
END;
/

===================================================================================================
--partition by range
SELECT o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME  ,round(sum(s.growth)/(1024*1024)) "Growth in MB"
FROM (select OBJECT_ID,OWNER , OBJECT_NAME , SUBOBJECT_NAME   from DBA_OBJECTS  
where object_name in ('FBNK_FUNDS_TRANSFER#HIS','FBNK_CATEG_ENTRY','FBNK_RE_C017','FBNK_STMT_ENTRY','FBNK_TELLER#HIS')
and owner='T24LIVE')o,
    ( SELECT SNAP_ID,OBJ#,
        SUM(SPACE_USED_DELTA) growth
    FROM DBA_HIST_SEG_STAT where TS#=6
    GROUP BY SNAP_ID,OBJ#
    HAVING SUM(SPACE_USED_DELTA) > 0
    ORDER BY 2 DESC ) s,
    (select SNAP_ID from DBA_HIST_SNAPSHOT where to_char(BEGIN_INTERVAL_TIME,'YYYY-MM-DD') > to_char (trunc(sysdate)-1,'YYYY-MM-DD')) e
WHERE s.OBJ# = o.OBJECT_ID
AND s.SNAP_ID=e.SNAP_ID
group by o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME  
ORDER BY 4 DESC


--partition by hash
SELECT o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME  ,sum(s.growth) "Growth in MB"
FROM (select OBJECT_ID,OWNER , OBJECT_NAME , SUBOBJECT_NAME   from DBA_OBJECTS  
where object_name not in ('FBNK_FUNDS_TRANSFER#HIS','FBNK_CATEG_ENTRY','FBNK_RE_C017','FBNK_STMT_ENTRY','FBNK_TELLER#HIS')
and object_type ='TABLE PARTITION'
and owner='T24LIVE')o,
    ( SELECT SNAP_ID,OBJ#,
        SUM(SPACE_USED_DELTA) growth
    FROM DBA_HIST_SEG_STAT where TS#=6
    GROUP BY SNAP_ID,OBJ#
    HAVING SUM(SPACE_USED_DELTA) > 0
    ORDER BY 2 DESC ) s,
    (select SNAP_ID from DBA_HIST_SNAPSHOT where to_char(BEGIN_INTERVAL_TIME,'YYYY-MM-DD') > to_char (trunc(sysdate)-1,'YYYY-MM-DD')) e
WHERE s.OBJ# = o.OBJECT_ID
AND s.SNAP_ID=e.SNAP_ID
group by o.OWNER , o.OBJECT_NAME , o.SUBOBJECT_NAME  
ORDER BY 4 DESC


BEGIN
  SYS.DBMS_STATS.GATHER_SCHEMA_STATS (
     OwnName           => 'T24LIVE'
    ,Granularity       => 'ALL'
    ,Options           => 'GATHER'
    ,Estimate_Percent  => dbms_stats.auto_sample_size
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE AUTO'
    ,Degree            => 24);
END;
/
------procedure
CREATE OR REPLACE PROCEDURE SYS.GATHER_T24LIVE_CHANGE as
   v_ddl   VARCHAR2 (2000);

   CURSOR c_tab
   IS
        SELECT o.OWNER,o.OBJECT_NAME,o.OBJECT_TYPE,SUM (s.SPACE_USED_DELTA)
          FROM sys.DBA_OBJECTS o,
               (SELECT OBJ#, SPACE_USED_DELTA
                  FROM sys.DBA_HIST_SEG_STAT
                 WHERE SNAP_ID BETWEEN 58684 AND 58923) s
         WHERE     s.OBJ# = o.OBJECT_ID
               AND o.owner = 'T24LIVE'
               AND object_type LIKE 'TABLE%'
        HAVING SUM (s.SPACE_USED_DELTA) <> 0
      GROUP BY o.OWNER, o.OBJECT_NAME, o.OBJECT_TYPE
      ORDER BY 1, 2 DESC;
BEGIN
   FOR cc IN c_tab
   LOOP
      v_ddl :=
            'begin DBMS_STATS.gather_table_stats(OwnName =>'''
         || cc.owner
         || ''',TabName=>'''
         || cc.OBJECT_NAME
         || ''', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,CASCADE => TRUE,Degree => 4 );end;';
      DBMS_OUTPUT.put_line (v_ddl);
   EXECUTE IMMEDIATE  v_ddl;
   END LOOP;
END;
/
