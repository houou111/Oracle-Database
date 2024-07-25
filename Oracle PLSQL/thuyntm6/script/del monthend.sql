
alter session force parallel dml parallel 8;
alter session force parallel query parallel 8;

--FBNK_PM_DLY_POSN_CLASS --> ok
--Ði?u ki?n : WITH …CUR.YYYYMMDD…     CUR: LO?I TI?N + YYYYMMDD: NAM, THÁNG, NGÀY          
ACBSC.1.00.TR.AUD.20131119.1788
ACBSC.1.00.TR.AUD.20131119.6324
ACBSC.1.00.TR.AUD.20131119.7017
ACBSC.1.00.TR.CAD.20131119.4329
ACBSC.1.00.TR.CAD.20131119.6324

delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2010____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2011____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2012____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2013____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2014____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2015____.____%';
commit;
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2016____.____%';
commit;

select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where RECID like '%.___.2016____.____%';
4913478

--F_RE_BC_TRANGTHAI_4711
--Ði?u ki?n : c?n xóa d? li?u < 20160101  WITH …CUR#YYYYMMDDD…        CUR :LO?I TI?N + YYYYMMDD: NAM, THÁNG, NGÀY
0#VN0010001#JPY#20160229
0#VN0010001#JPY#20160830
0#VN0010001#USD#20140331
0#VN0010001#USD#20140424
0#VN0010001#USD#20140521
0#VN0010001#USD#20140606
0#VN0010001#USD#20140628

delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2010____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2011____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2012____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2013____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2014____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2015____';
commit;
delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2016____';
commit;
select count(*) from T24LIVE.F_RE_BC_TRANGTHAI_4711 where RECID like '%#___#2016____';
3385035
FBNK_EB_B005
FBNK_QUAN014


-- T24LIVE.FBNK_FTBULK_TCB#HIS					===> done
---Format	RECID=BC13359xxxxx   BC13 BC14 BC15
--- Delete 2012 
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC12%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC10%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC11%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC13%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC14%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC15%';
commit;
delete T24LIVE.FBNK_FTBULK_TCB#HIS where RECID like 'BC16%';
commit;

-- T24LIVE.F_FTBULK_000    	F.FTBULK.CONTROL.TCB$HIS	===> done
--- Format	RECID=BC12009xxxx	BC12 BC13 BC14 BC15
--- Delete 2012 
delete T24LIVE.F_FTBULK_000 where RECID like 'BC10%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC11%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC12%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC13%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC14%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC15%';
commit;
delete T24LIVE.F_FTBULK_000 where RECID like 'BC16%';
commit;
 ------------------------------------------------------------------------
-- T24LIVE.F_FTBULK_CONTROL_TCB						===> done.
--- Format	RECID=BC10081xxxx	BC10 BC11 BC12 BC13 BC14 BC15
--- Delete 2010 
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC10%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC11%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC12%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC13%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC14%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC15%';
commit;
delete T24LIVE.F_FTBULK_CONTROL_TCB where RECID like 'BC16%';
commit;

-- T24LIVE.FBNK_FTBU000							===> done.
--- Format	RECID=BC10081xxxx	BC10 BC11 BC12 BC13 BC14 BC15
--- Delete 2010 
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC10%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC11%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC12%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC13%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC14%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC15%';
commit;
delete T24LIVE.FBNK_FTBU000 where RECID like 'BC16%';
commit;

--T24LIVE.FBNK_PM_TRAN_ACTIVITY 					=== doing
-- Format RECID = FT13125xxxx  FT/DC/TT + YY + Day_of_Year_365
--- Delete 2016 - giu lai n-1
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT160%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'DC160%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'TT160%';
commit;
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT161%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'DC161%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'TT161%';
commit;
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT162%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'DC162%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'TT162%';
commit;
-----------------SKIP-------------------++++++++++++++++++++++
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT163%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'DC163%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'TT163%';
commit;
-----------------+++++++++++++++++++++++++++++++++++++++++++
--T24LIVE.FBNK_AI_USER_LOG 						===> doing
-- Format RECID = .APPLICATION.YYYY...  
---  	.APPLICATION.YYYY...
---	.CHANGEPASS.YYYY
---	.ENQUIRY.YYYY
---	.LOGOUT.YYYY
---	.LOGIN.YYYY
--- Delete 2012
delete T24LIVE.FBNK_AI_USER_LOG where RECID like '%.APPLICATION.2016%';
delete T24LIVE.FBNK_AI_USER_LOG where RECID like '%.CHANGEPASS.2016%';
delete T24LIVE.FBNK_AI_USER_LOG where RECID like '%.ENQUIRY.2016%';
delete T24LIVE.FBNK_AI_USER_LOG where RECID like '%.LOGOUT.2016%';
delete T24LIVE.FBNK_AI_USER_LOG where RECID like '%.LOGIN.2016%';
commit;



-- T24LIVE.FBNK_RE_CONSOL_PROFIT
-- Format  RECID = ............VN0010002.VND.20130827
-- Format  	%.VN001____.VND.YYYYMMDD
--		%.VN001____.USD.YYYYMMDD		
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where RECID like '%.VN001____.___.2012%';
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where RECID like '%.VN001____.___.2013%';
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where RECID like '%.VN001____.___.2014%';
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where RECID like '%.VN001____.___.2015%';
delete T24LIVE.FBNK_RE_CONSOL_PROFIT where RECID like '%.VN001____.___.2016%';
commit;
----==================SKIP==============
FBNK_AI_CORP_TXN_LOG
-- T24LIVE.FBNK_AI_CORP_TXN_LOG
-- Format RECID = FT13125xxxx  FT + YY + Day_of_Year_365
--- Delete 2012 
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT160%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT161%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT162%';
delete T24LIVE.FBNK_PM_TRAN_ACTIVITY where RECID like 'FT163%';
commit;
-----==============================

-- T24LIVE.F_DE_O_HANDOFF
-- Format RECID = D2012   D+YYYY
--- Delete 2016 
delete T24LIVE.F_DE_O_HANDOFF where RECID like 'D2016%';
commit;

-- T24LIVE.F_DE_O_HEADER
-- Format RECID = D2012   D+YYYY
--- Delete 2016
delete T24LIVE.F_DE_O_HEADER where RECID like 'D2016%';
commit;

-- T24LIVE.F_DE_O_REPAIR
-- Format RECID = D2012   D+YYYY
-- Delete 2016
delete T24LIVE.F_DE_O_REPAIR where RECID like 'D2016%';
commit;

-- T24LIVE.F_DE_O_MSG_ADVICE
-- Format RECID = D2012   D+YYYY
-- Delete 2016
delete T24LIVE.F_DE_O_MSG_ADVICE where RECID like 'D2016%';
commit;

FBNK_TXN_LOG_TCB
FBNK_STMT_PRINTED
F_OS_XML_CACHE
F_ENQUIRY_SELECT


