--=====T24LIVE.FBNK_QUAN003
-Archive dữ liệu <2016
- Định dạng ID:
   <2013(một phần 2013) :các id theo bút toán MM, AZ
    >=2014(một phần 2013): Theo định dạng QTYYDDD
       YY: YEAR
       DDD: DAYS SEQUENCE
delete T24LIVE.FBNK_QUAN003 where RECID like 'MM%';
commit;
--5042 rows
delete T24LIVE.FBNK_QUAN003 where RECID like 'AZ%';
commit;
--0 row
delete T24LIVE.FBNK_QUAN003 where RECID like 'QT13%';
commit;
--113170
delete T24LIVE.FBNK_QUAN003 where RECID like 'QT14%';
commit;
--78312
delete T24LIVE.FBNK_QUAN003 where RECID like 'QT15%';
commit;
--67568

--=======T24LIVE.FBNK_SUM_DENO_TCB
-Archive dữ liệu <2016
-Tạo lại bảng trên DB
-Theo định dạng …-YYYYMMDD

delete T24LIVE.FBNK_SUM_DENO_TCB where RECID like '%-2015%'; --????

--=======T24LIVE.FBNK_DEPO_WITHDRA
-COUNT FBNK.DEPO.WITHDRA WITH CREATE.DATE LE 20160831
6223078 Records counted 
-Xóa dữ liệu < 09 năm trước đó
-Tạo lại bảng trên DB
-Đưa ra quy luật để archive định kỳ


