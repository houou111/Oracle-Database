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
      SELECT owner, table_name
      FROM dba_tables
      WHERE owner IN ('&1') AND partitioned = 'YES';
BEGIN
   FOR v_tab IN c_table
   LOOP
      FOR c_partition
         IN (SELECT *
             FROM ( SELECT partition_name, default_tablespace
                                        FROM dba_tab_partitions a,dba_users b,
                                        (SELECT a.TABLE_OWNER,a.TABLE_NAME,avg(num_rows/blocks) abc
                                        FROM dba_tab_partitions a, dba_users b, dba_part_tables c
                                        WHERE     compression = 'ENABLED'
                                        AND a.TABLE_OWNER = b.USERNAME
                                        AND a.TABLE_OWNER = c.OWNER
                                        AND a.TABLE_OWNER = v_tab.owner
                                        AND a.TABLE_NAME = v_tab.table_name
                                        AND a.TABLE_NAME = c.TABLE_NAME
                                        AND a.partition_name LIKE 'SYS_%'
                                        AND c.PARTITIONING_TYPE = 'RANGE'
                                        AND a.blocks  >0
                                        GROUP by a.TABLE_OWNER,a.TABLE_NAME
                                        ) d
                                        where a.TABLE_OWNER = d.TABLE_OWNER
                                        AND a.TABLE_OWNER = b.USERNAME
                                        AND a.TABLE_NAME = d.TABLE_NAME
                                        AND ((a.num_rows/a.blocks) < (d.abc/2) OR a.num_rows=0)
                                        AND a.blocks  >0
                                        )
                        ) 
      LOOP

         cmd :='ALTER TABLE '|| v_tab.OWNER|| '.'|| v_tab.table_name|| ' MOVE PARTITION '
            || c_partition.PARTITION_NAME|| ' TABLESPACE '|| c_partition.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4';
                 DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
                 DBMS_OUTPUT.put_line (cmd);
         execute immediate cmd;

         FOR c_index
            IN (SELECT INDEX_OWNER, index_name, PARTITION_NAME
                  FROM dba_ind_partitions
                 WHERE     index_owner || '.' || index_name IN 
                 (SELECT DISTINCT  owner || '.' || index_name
                    FROM dba_indexes
                  WHERE     table_owner = v_tab.owner
                        AND table_name = v_tab.table_name)
                  AND status = 'UNUSABLE')
         LOOP
            cmd1 := 'alter index '|| c_index.INDEX_OWNER|| '.'|| c_index.index_name
               || ' rebuild partition '|| c_index.PARTITION_NAME|| ' TABLESPACE '|| c_partition.DEFAULT_TABLESPACE|| ' online PARALLEL 4';
            DBMS_OUTPUT.put_line (cmd1);
                        execute immediate cmd1;

         END LOOP;
                 
                FOR c_index
            IN (SELECT OWNER, index_name
                  FROM dba_indexes
                 WHERE     OWNER || '.' || index_name IN 
                 (SELECT DISTINCT  owner || '.' || index_name
                    FROM dba_indexes
                  WHERE     table_owner = v_tab.owner
                        AND table_name = v_tab.table_name)
                  AND status = 'UNUSABLE')
         LOOP
            cmd1 := 'alter index '|| c_index.OWNER|| '.'|| c_index.index_name
               || ' rebuild TABLESPACE '|| c_partition.DEFAULT_TABLESPACE|| ' online PARALLEL 4';
                 DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
            DBMS_OUTPUT.put_line (cmd1);
                        execute immediate cmd1;

         END LOOP;

      END LOOP;
   END LOOP;
END;
/