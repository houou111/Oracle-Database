--------------------------------------------------------------------------------
--
-- File name:   demo1.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Depending on the speed of LGWR IO will cause the session to wait
--              for log buffer space and log switch wait events (demo works
--              ok on a single hard disk laptop, probably will not wait so much
--              on a server with write cached storage)
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
--------------------------------------------------------------------------------

prompt Starting Demo1...

set feedback off termout off

drop table t;
create table t as select * from dba_source where 1=0;

alter system switch logfile;
alter system switch logfile;

insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;
insert into t select * from dba_source;

commit;

