col proc_owner 		head OWNER for a25
col proc_object_name	head OBJECT_NAME for a30
col proc_procedure_name	head PROCEDURE_NAME for a30

select 
	owner		proc_owner
      , object_name	proc_object_name
      , procedure_name	proc_procedure_name
--      ,  subprogram_id
from 
	dba_arguments
where 
	lower(object_name) like lower('%&1%')
and	lower(procedure_name) like lower('%&2%')
/
