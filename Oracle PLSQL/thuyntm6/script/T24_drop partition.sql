Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1607 ;
Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1608 ;
Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1609 ;
Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1610 ;
Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1611 ;
Alter table T24LIVE.FBNK_CATEG_ENTRY drop partition CATEG_ENTRY_P1612 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1607 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1608 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1609 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1610 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1611 ;
Alter table T24LIVE.FBNK_FUNDS_TRANSFER#HIS drop partition FT_HIS_P1612 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1607 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1608 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1609 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1610 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1611 ;
Alter table T24LIVE.FBNK_RE_C017 drop partition RE_CONSOL_SPEC_ENT_P1612 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1607 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1608 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1609 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1610 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1611 ;
Alter table T24LIVE.FBNK_STMT_ENTRY drop partition STMT_ENTRY_P1612 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1607 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1608 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1609 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1610 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1611 ;
Alter table T24LIVE.FBNK_TELLER#HIS drop partition TT_HIS_P1612 ;

--shared_pool
spool offObj mem:  510318064 bytes (486.68MB)
Shared sql:  2014789138 bytes (1921.45MB)
Cursors:  2263379720 bytes (2158.53MB)
Free memory: 1947195032 bytes (1856.99MB)
Shared pool utilization (total):  3030128642 bytes (2889.76MB)
Shared pool allocation (actual):  14763950080bytes (14080MB)
Percentage Utilized:  87%

Obj mem:  594169752 bytes (566.64MB)
Shared sql:  2148299865 bytes (2048.78MB)
Cursors:  2413308334 bytes (2301.51MB)
Free memory: 1960083608 bytes (1869.28MB)
Shared pool utilization (total):  3290963540 bytes (3138.51MB)
Shared pool allocation (actual):  14763950080bytes (14080MB)
Percentage Utilized:  87%


sho parameter SHARED_POOL_SIZE

alter system set SHARED_POOL_SIZE =3072MB scope=both sid='*';