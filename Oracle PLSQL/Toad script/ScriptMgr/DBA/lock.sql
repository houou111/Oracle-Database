set echo off
set feedback off
set linesize 512

prompt
prompt Database Locks Being Held
prompt

column sid			    format 999     	heading "SID"
column username		    format a10     	heading "User Name"
column machine			format a20    	heading "Machine Name"
column object_name		format a20    	heading "Object Name"
column type				format a4     	heading "Type"
column lmode 		    format a20  	heading "Current Lock Mode"
column request		    format 9999999 	heading "Request Mode"
column block		    format 9999999 	heading "Lock Blocking"

select 
	s.sid		sid,
	s.username	username,
	s.machine	machine,
	l.type		type,
	o.object_name	object_name,
	DECODE(l.lmode,
		0,'None',
		1,'Null',
		2,'Row Share',	
		3,'Row Exlusive',	
		4,'Share',	
		5,'Sh/Row Exlusive',	
		6,'Exclusive') lmode,
	DECODE(l.request,
		0,'None',
		1,'Null',
		2,'Row Share',	
		3,'Row Exlusive',	
		4,'Share',	
		5,'Sh/Row Exlusive',	
		6,'Exclusive') request,
	l.block		block	
from
	v$lock l,
	v$session s,
	dba_objects o
where
	l.sid = s.sid
	and
	username != 'SYSTEM'
	and
	o.object_id(+) = l.id1;