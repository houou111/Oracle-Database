set lines 200
set pages 200
set serveroutput on
set timing on


DECLARE
   cmd    VARCHAR2 (4000);
   cmd1   VARCHAR2 (4000);
   dem    NUMBER;

   CURSOR c_table
   IS
      SELECT owner , table_name,default_tablespace 
      FROM dba_tables a, dba_users b
      WHERE owner IN ('&1') AND partitioned = 'YES' and a.OWNER = b.USERNAME;
BEGIN
   FOR v_tab IN c_table
   LOOP
      FOR c_partition
         IN (SELECT *
             FROM ( SELECT partition_name
                                        FROM dba_tab_partitions a,  dba_part_tables c
                                        WHERE     compression = 'DISABLED'
                                        AND a.TABLE_OWNER||'.'||a.TABLE_NAME = c.OWNER||'.'||c.TABLE_NAME
                                        AND a.TABLE_OWNER||'.'||a.TABLE_NAME = v_tab.OWNER||'.'||v_tab.TABLE_NAME
                                        AND ( partition_name LIKE 'SYS_%' OR partition_name LIKE 'P20%') --only for date_time parition
                                        AND c.PARTITIONING_TYPE = 'RANGE'     --only for range parition
                                        ORDER BY a.table_owner, a.table_name, partition_position )
            WHERE ROWNUM <= 10000) --number of compress partition
      LOOP
        SELECT COUNT (*) INTO dem
        FROM dba_tab_partitions
        WHERE compression = 'DISABLED'
        AND table_owner||'.'||table_name = v_tab.owner||'.'||v_tab.table_name;

      EXIT WHEN dem < 2;

         cmd :='ALTER TABLE '|| v_tab.OWNER|| '.'|| v_tab.table_name|| ' MOVE PARTITION '
            || c_partition.PARTITION_NAME|| ' TABLESPACE '|| v_tab.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4';
                 DBMS_OUTPUT.put_line (cmd);
         execute immediate cmd;


        cmd :='BEGIN DBMS_STATS.gather_table_stats(OwnName =>'''||v_tab.OWNER||''',TabName =>'''||v_tab.table_name||''',PartName =>'''|| c_partition.PARTITION_NAME||''',GRANULARITY => ''AUTO'',estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE,degree =>4,CASCADE => TRUE ); END;';
                 DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
                 DBMS_OUTPUT.put_line (cmd);
         execute immediate cmd;

     END LOOP;
     
     FOR c_index
            IN (SELECT INDEX_OWNER, index_name, PARTITION_NAME
                  FROM dba_ind_partitions
                 WHERE     index_owner || '.' || index_name IN
                 (SELECT DISTINCT  owner || '.' || index_name
                    FROM dba_indexes
                  WHERE     table_owner||'.'||table_name = v_tab.owner||'.'||v_tab.table_name)
                  AND status = 'UNUSABLE')
         LOOP
            cmd1 := 'alter index '|| c_index.INDEX_OWNER|| '.'|| c_index.index_name
               || ' rebuild partition '|| c_index.PARTITION_NAME|| ' TABLESPACE '|| v_tab.DEFAULT_TABLESPACE|| ' PARALLEL 4';
            DBMS_OUTPUT.put_line (cmd1);
                        execute immediate cmd1;

         END LOOP;

      FOR c_index
            IN (SELECT OWNER, index_name
                  FROM dba_indexes
                 WHERE      table_owner||'.'||table_name = v_tab.owner||'.'||v_tab.table_name 
                  AND status = 'UNUSABLE')
         LOOP
            cmd1 := 'alter index '|| c_index.OWNER|| '.'|| c_index.index_name
               || ' rebuild TABLESPACE '|| v_tab.DEFAULT_TABLESPACE|| ' PARALLEL 4';
                 DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
            DBMS_OUTPUT.put_line (cmd1);
                        execute immediate cmd1;

         END LOOP;
   END LOOP;
END;
/

exit
