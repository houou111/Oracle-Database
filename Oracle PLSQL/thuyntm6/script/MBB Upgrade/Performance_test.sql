--1	Stop sync between 2 database
--[SOURCE]
GGSCI > STOP EXT_MOB
GGSCI > STOP EXTMOB_P
--on [ TARGET ]
GGSCI > STOP REP_S1

--2	Swich over database to DR site
--ON DR site
dgmgrl /
DGMGRL>  switchover to mbbdr

--3	Test performance on new DR to make sure new environment meet the need of performance