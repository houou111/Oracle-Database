col trig_triggering_event for a30

select owner, trigger_name, trigger_type, triggering_event trig_triggering_event, table_owner, table_name from dba_triggers where lower (table_name) like lower('%&1%');
