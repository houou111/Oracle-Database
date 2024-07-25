--1.Make decision that new environment work well
=====================================================


--2.Stop GoldenGate. Drop goldengate user, uninstall goldengate, remove iptables role for GoldenGate.
=====================================================
--Stop GoldenGate
GGSCI> info all
GGSCI> stop EXT_P2
GGSCI> stop EXT_S2

GGSCI> stop REP_S2

  select distinct 'delete trandata MOBR5.'||table_name from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' 

--Drop GoldenGate user
Drop user ggate_user ;

--Uninstall GoldenGate
[on NEW DB]
GGSCI> stop mgr

select distinct 'DELETE trandata MOBR5.'||table_name from dba_constraints 
 where constraint_type  in ('U', 'P') and owner='MOBR5' and status='ENABLED' and table_name not in ('MOB_TXNS_HIST','MOB_SUB_TXNS_HIST')
GGSCI > --run command generate from above sql

GGSCI> DELETE EXTRACT EXT_S2
GGSCI> DELETE EXTRACT EXT_P2
GGSCI> DELETE EXTRACT REP_S1
GGSCI> UNREGISTER EXTRACT EXT_S2 DATABASE

exec dbms_goldengate_auth.revoke_admin_privilege('GGATE_USER');

$GGATE/deinstall/deinstall.sh

[on OLD DB]
GGSCI> stop mgr


GGSCI> DELETE EXTRACT EXT_S1
GGSCI> DELETE EXTRACT EXT_P1
GGSCI> DELETE EXTRACT REP_S2
GGSCI> UNREGISTER EXTRACT EXT_S1 DATABASE

dbms_goldengate_auth.revoke_admin_privilege('GGATE_USER');

$GGATE/deinstall/deinstall.sh

--[On BOTH] remove iptables role for GoldenGate

--3.Take back old database, and storage
=====================================================
--[On OLD server]
dbca -silent -deleteDatabase -sourceDB mbbdb -sysDBAUserName sys
dbca -silent -deleteDatabase -sourceDB mbbdr -sysDBAUserName sys

orapwd file=$ORACLE_HOME/dbs/orapwmbbdr2 password=oracle123

dbca -silent -deleteDatabase -sourceDB mbbdr -sysDBAUserName sys -sysDBAPassword oracle123

--4.Take back Memory allocated for migration
=====================================================

- Uninstall GoldenGate.
- Take back storage, RAM allocated for migration
