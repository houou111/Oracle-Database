PROCEDURE trunc_tbl_partition (v_month number) as
    cur_ref       sys_refcursor;
    cur_fk        sys_refcursor;
    v_fk          VARCHAR2 (30);
    v_owner       VARCHAR2 (30);
    v_partition   VARCHAR2 (30);
    v_table       VARCHAR2 (30);
    v_type        VARCHAR2 (10);
    v_par1        DATE := ADD_MONTHS (TRUNC (SYSDATE, 'month'), -v_month);
    v_par2        DATE := ADD_MONTHS (TRUNC (SYSDATE, 'month'), -v_month+1);
    v_sql         VARCHAR2 (150);
    CURSOR cur_table
    IS
        SELECT   owner, table_name, partitioned_type FROM ggate.ggate_tbl_config;
BEGIN

    OPEN cur_table;
    LOOP
        FETCH cur_table
        INTO   v_owner, v_table, v_type;

        EXIT WHEN cur_table%NOTFOUND;
        -- Disable Foreign Key
        OPEN cur_fk FOR
            'select CONSTRAINT_NAME from dba_constraints where OWNER='''
            || v_owner
            || ''''
            || ' and table_name='''
            || v_table
            || ''''
            || ' and CONSTRAINT_TYPE=''R''';

        LOOP

            FETCH cur_fk INTO v_fk;
            EXIT WHEN cur_fk%NOTFOUND;
            v_sql := 'ALTER TABLE ' || v_owner || '.' || v_table || ' disable CONSTRAINT ' || v_fk;
            dbms_output.put_line(v_sql);
            EXECUTE IMMEDIATE v_sql;
        END LOOP;

        OPEN cur_ref FOR
            'select partition_name from dba_tab_partitions where table_name='''
            || v_table
            || ''''
            || ' and table_owner='''
            || v_owner
            || '''';

        LOOP
            FETCH cur_ref INTO v_partition;

            EXIT WHEN cur_ref%NOTFOUND;

            -- Truncate table which partitioning
            IF v_type = 'MONTH'
            THEN
                IF TO_NUMBER (SUBSTR (v_partition, 5)) <=
                       TO_NUMBER (TO_CHAR (v_par1, 'YYYYMM'))
                THEN
                    v_sql :=
                           'ALTER TABLE '
                        || v_owner
                        || '.'
                        || v_table
                        || ' TRUNCATE PARTITION '
                        || v_partition;

                    DBMS_OUTPUT.put_line (v_sql);
                    EXECUTE IMMEDIATE v_sql;
                END IF;
            END IF;

            -- Truncate table which partitioning daily
            IF v_type = 'DAY'
            THEN
                IF TO_NUMBER (SUBSTR (v_partition, 5)) <=
                       TO_NUMBER (TO_CHAR (v_par2-1, 'YYYYMMDD'))
                THEN
                    v_sql :=
                           'ALTER TABLE '
                        || v_owner
                        || '.'
                        || v_table
                        || ' TRUNCATE PARTITION '
                        || v_partition;

                    DBMS_OUTPUT.put_line (v_sql);
                    EXECUTE IMMEDIATE v_sql;
                END IF;
            END IF;
        END LOOP;
        CLOSE cur_ref;
--        DBMS_OUTPUT.put_line ('Table ' || v_owner || '.' || v_table || ' truncated!');


    -- Enable Foreign Key
        OPEN cur_fk FOR
            'select CONSTRAINT_NAME from dba_constraints where OWNER='''
            || v_owner
            || ''''
            || ' and table_name='''
            || v_table
            || ''''
            || ' and CONSTRAINT_TYPE=''R''';

        LOOP
            FETCH cur_fk INTO v_fk;
            EXIT WHEN cur_fk%NOTFOUND;
            v_sql := 'ALTER TABLE ' || v_owner || '.' || v_table || ' enable novalidate CONSTRAINT ' || v_fk;
            DBMS_OUTPUT.put_line (v_sql);
            EXECUTE IMMEDIATE v_sql;
        END LOOP;

    END LOOP;

    CLOSE cur_table;
END;