exec dbms_metadata.set_transform_param( dbms_metadata.session_transform,'SQLTERMINATOR', TRUE);

select dbms_metadata.get_ddl( object_type, object_name, owner ) from all_objects where upper(object_name) like upper('&1');

