export ORACLE_SID=$1
export EXP_BKP_DIR=/stage/dump

mkdir -p ${EXP_BKP_DIR}/${ORACLE_SID}
export DT=`date +%d%b%y_%H%M`

sqlplus -s "/ as sysdba" <<EOF >> ${EXP_BKP_DIR}/${ORACLE_SID}/pre_migration_stats.log
set echo on time on timi on
col WRL_PARAMETER for a80
col Dir_Path for a120
set lines 300 pages 50000
select to_char(sysdate,'DD-MON-YY HH24:MI:SS') sdate from dual;

set timi on serveroutput on

drop table SYS.IBM_MIG_SRC_OBJECTS purge;
drop table SYS.IBM_MIG_SRC_TRIGGERS purge;
drop table SYS.IBM_MIG_SRC_CONSTR purge;
drop table SYS.IBM_MIG_STATS_BKP purge;

create table SYS.IBM_MIG_SRC_OBJECTS as select * from dba_objects;
create table SYS.IBM_MIG_SRC_TRIGGERS as select owner, trigger_name, trigger_type, triggering_event, table_owner, table_name from dba_triggers;
create table SYS.IBM_MIG_SRC_CONSTR as select OWNER,CONSTRAINT_NAME,CONSTRAINT_TYPE,TABLE_NAME,R_OWNER,R_CONSTRAINT_NAME,DELETE_RULE,
	STATUS,DEFERRABLE,DEFERRED,VALIDATED,GENERATED,BAD,RELY,LAST_CHANGE,INDEX_OWNER,INDEX_NAME,INVALID,VIEW_RELATED,
	to_lob(SEARCH_CONDITION) search_condition from dba_constraints;

begin
        begin
                dbms_stats.create_stat_table('SYS','IBM_MIG_STATS_BKP');
        exception when others then 
                dbms_output.put_line(sqlerrm);
        end;
        dbms_output.put_line('Start of export database statistics at ' || to_char(sysdate,'DD-MON-YY HH24:MI:SS'));
        dbms_stats.export_database_stats(statown=>'SYS', stattab=>'IBM_MIG_STATS_BKP', STATID=>'STAT_${DT}');
end;
/
exit;
EOF

exp "'/ as sysdba'" file=${EXP_BKP_DIR}/${ORACLE_SID}/exp_statsbkp_${ORACLE_SID}.dmp \
LOG=${EXP_BKP_DIR}/${ORACLE_SID}/exp_statsbkp_${ORACLE_SID}.log statistics=none \
tables=IBM_MIG_STATS_BKP,IBM_MIG_SRC_OBJECTS,IBM_MIG_SRC_TRIGGERS,IBM_MIG_SRC_CONSTR
