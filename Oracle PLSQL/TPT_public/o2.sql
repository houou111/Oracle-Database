col o_owner heading owner for a25
col o_object_name heading object_name for a30
col o_object_type heading object_type for a18
col o_status heading status for a9

select 
    owner o_owner,
    object_name o_object_name, 
    object_type o_object_type,
    status o_status,
    object_id oid,
    data_object_id d_oid,
    created, 
    last_ddl_time
from 
    dba_objects 
where 
    lower(object_name) like lower('&1')
order by 
    o_object_name,
    o_owner,
    o_object_type
/
