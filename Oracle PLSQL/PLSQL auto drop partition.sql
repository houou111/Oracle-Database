DECLARE
cmd VARCHAR2 (4000);
dem    NUMBER;

CURSOR TB_CALCULATIONRESULTS_cursor
IS
select table_owner,table_name,partition_name,high_value from dba_tab_partitions
where table_owner='FCE'
and table_name='TB_CALCULATIONRESULTS'
and rownum < 2
and partition_name <>'P1'
order by Partition_position;
BEGIN
FOR job_rec IN TB_CALCULATIONRESULTS_cursor
LOOP
SELECT COUNT (*) INTO dem
FROM dba_tab_partitions
WHERE table_owner='FCE'
and table_name='TB_CALCULATIONRESULTS';

EXIT WHEN dem < 10;
cmd :='ALTER TABLE '||job_rec.table_owner||'.'||job_rec.table_name||' DROP PARTITION '||job_rec.partition_name;
execute immediate cmd;

END LOOP;

END;