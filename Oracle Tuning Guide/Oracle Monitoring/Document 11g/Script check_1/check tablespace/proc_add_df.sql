DECLARE
v_datafile varchar2(255);
v_scn varchar2(20);
v_sql varchar2(255);
CURSOR cur_scn
is
select current_scn from v$database;
begin
    open cur_scn;
    loop
    fetch cur_scn into v_scn;
    exit when cur_scn%NOTFOUND;
    end loop;
    close cur_scn;
    v_datafile := '/u02/oracle/oradata/mbf/ggate_data'||v_scn ||'.dbf';
    v_sql := 'ALTER TABLESPACE GGATE_DATA ADD DATAFILE ' || '''' || v_datafile ||''' size 6G';
    dbms_output.put_line(v_sql);
    execute immediate v_sql;
end;
/
exit