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
      SELECT a.owner, a.table_name,b.default_tablespace
      FROM dba_tables a ,dba_users b
      WHERE a.owner=b.username 
	  AND ((a.owner IN ('KRM_APP','KRM_RPT','TCB_DWH_TCKH')
			AND a.TABLE_NAME like '%\_20%' escape '\' ) 
			OR b.PROFILE ='PROFILE_ENDUSER')
	  AND COMPRESSION <> 'ENABLED'
	  AND a.partitioned = 'NO'
	  AND TEMPORARY = 'N';;
	  
BEGIN
	FOR v_tab IN c_table
	LOOP
		cmd :='ALTER TABLE "'|| v_tab.OWNER|| '".'|| v_tab.table_name|| ' :x!MOVE TABLESPACE '|| v_tab.DEFAULT_TABLESPACE|| ' COMPRESS FOR QUERY HIGH PARALLEL 4';
		DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
		DBMS_OUTPUT.put_line (cmd);
        execute immediate cmd;
		
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
            cmd1 := 'alter index '|| c_index.OWNER|| '.'|| c_index.index_name || ' rebuild TABLESPACE '|| v_tab.DEFAULT_TABLESPACE|| ' online PARALLEL 4';
            DBMS_OUTPUT.put_line ('-------------------------------------------------------------------');
            DBMS_OUTPUT.put_line (cmd1);
            execute immediate cmd1;

        END LOOP;

    END LOOP;
END;
/