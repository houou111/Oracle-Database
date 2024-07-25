SET SERVEROUTPUT ON

DECLARE
   archive_year1   NUMBER;
   archive_year2   NUMBER;
   cmd             VARCHAR2 (4000);
   counter         NUMBER;
   timeStart       DATE;
   timeEnd         DATE;
BEGIN
   archive_year1 := EXTRACT (YEAR FROM SYSDATE) - 1;
   DBMS_OUTPUT.put_line (archive_year1);

   archive_year2 :=
      TRUNC (SYSDATE, 'YEAR') - TO_DATE ('31/12/1967', 'DD/MM/YYYY');
   DBMS_OUTPUT.put_line (archive_year2);

---FBNK_PM_DLY_POSN_CLASS
   DBMS_OUTPUT.put_line ('====T24LIVE.FBNK_PM_DLY_POSN_CLASS');

   FOR n IN 2002 .. archive_year1
   LOOP
      cmd :='delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like ''%.___.'|| n|| '____.____%''';
      --DBMS_OUTPUT.put_line (cmd);
      timeStart := SYSDATE;
      --execute immediate cmd ;
      timeEnd := SYSDATE;
      COMMIT;
      --counter := SQL%ROWCOUNT;
      DBMS_OUTPUT.put_line (counter || ' rows deleted(' || n || ')');
      DBMS_OUTPUT.put_line ('Elapsed time :'|| TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND));
   END LOOP;
   DBMS_OUTPUT.put_line (CHR (10));

---F_RE_BC_TRANGTHAI_4711
   DBMS_OUTPUT.put_line ('====T24LIVE.F_RE_BC_TRANGTHAI_4711');
   cmd :='delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where recid like ''%#___#'|| archive_year1|| '____''';
   --DBMS_OUTPUT.put_line (cmd);
   timeStart := SYSDATE;
   --execute immediate cmd ;
   timeEnd := SYSDATE;
   COMMIT;
   --counter := SQL%ROWCOUNT;
   DBMS_OUTPUT.put_line (counter || ' rows deleted(' || archive_year1 || ')');
   DBMS_OUTPUT.put_line ('Elapsed time :' || TO_CHAR ( (timeEnd - timeStart) DAY (0) TO SECOND));
   DBMS_OUTPUT.put_line (CHR (10));
-----FBNK_FTBULK_TCB#HIS

END;
/

--result
2004
17899
delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.___.2004____.____%'
Num of rows deleted from T24LIVE.FBNK_PM_DLY_POSN_CLASS-2004: 0
Elapsed time :+000000000 00:00:15.000000000

----------------------

/* Formatted on 5/24/2017 4:19:22 PM (QP5 v5.252.13127.32867) */
DECLARE
   archive_year1   NUMBER;
   archive_year2   NUMBER;
   cmd             VARCHAR2 (4000);
BEGIN
      archive_year1 :=extract (year from sysdate)-1;
      DBMS_OUTPUT.put_line(archive_year1);
      
      archive_year2:=TRUNC(sysdate,'YEAR')- to_date ('31/12/1967','DD/MM/YYYY');
      DBMS_OUTPUT.put_line(archive_year2);
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like ''%.'||archive_year1||'%''');
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_RE_BC_TRANGTHAI_4711 where recid like ''%#'||archive_year1||'%''');
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.FBNK_EB_B005 where recid < ''FT'||archive_year2||'%''');
      
      --FBNK_QUAN014
      --FBNK_OD_ACCT_ACTIVITY
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.FBNK_FTBULK_TCB#HIS where recid < ''BC'||archive_year2||'%''');
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_000 where recid like ''BC'||substr(to_char(archive_year1),3,4)||'1%''');
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_000 where recid like ''BC'||substr(to_char(archive_year1),3,4)||'2%''');
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_000 where recid like ''BC'||substr(to_char(archive_year1),3,4)||'3%''');
      
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_CONTROL_TCB where recid like ''BC'||substr(to_char(archive_year1),3,4)||'1%''');
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_CONTROL_TCB where recid like ''BC'||substr(to_char(archive_year1),3,4)||'2%''');
      DBMS_OUTPUT.put_line ('delete T24LIVE.F_FTBULK_CONTROL_TCB where recid like ''BC'||substr(to_char(archive_year1),3,4)||'3%''');
      
      --FBNK_FTBU000
      
      DBMS_OUTPUT.put_line (chr(10));

END;
/



--1. FBNK_PM_DLY_POSN_CLASS
SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2016%';
   4942360

SQL>   select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2015%';
3695525

SQL>  select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2014%';
3690957

SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2013%';
455781

SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2012%';
4335

SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2011%';
1915

SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.2010%';
2063

SQL> select count(*) from T24LIVE.FBNK_PM_DLY_POSN_CLASS where recid like '%.200%';
25458


---------------------
delete
---------------------

--2. F_RE_BC_TRANGTHAI_4711
 select count(*) from T24LIVE.F_RE_BC_TRANGTHAI_4711 where recid like '%#2015%';
-3627070

 select count(*) from T24LIVE.F_RE_BC_TRANGTHAI_4711 where recid like '%#2015%';
-0
		 
--3. FBNK_EB_B005
select count(*) from T24LIVE.FBNK_EB_B005 where recid <'FT17899%'  --2016
khong co du lieu 2017? 

--4. FBNK_QUAN014 ?????
select * from T24LIVE.FBNK_QUAN014 where recid >'%-17899%' ???

--5. FBNK_OD_ACCT_ACTIVITY ????????
select * from T24LIVE.FBNK_OD_ACCT_ACTIVITY where recid >'%-2012%' ???

--6. FBNK_FTBULK_TCB#HIS -- phan manh? + dung luong 25G


 select count(*) from T24LIVE.FBNK_FTBULK_TCB#HIS where recid < 'BC17899%'; ?? khong co du lieu 2017
-5155829

--7. F_FTBULK_000 -- phan manh?
select * from t24live.F_FTBULK_000 where recid like 'BC16%'
--0 row?

--8. F_FTBULK_CONTROL_TCB 
select * from t24live.F_FTBULK_CONTROL_TCB where  recid not like 'BC%';
FS         <row id="FS" xml:space="preserve"><c1/></row>
BULID.LIST <row id="BULID.LIST" xml:space="preserve"><c28>4</c28></row>
UPDATE     <row id="UPDATE" xml:space="preserve"><c28>4</c28></row>

select count(*) from t24live.F_FTBULK_CONTROL_TCB where  recid like 'BC16%'
--0 row?

--9. FBNK_FTBU000
select recid from t24live.FBNK_FTBU000 where recid not like 'BC%' and recid not like 'FT%'
-252 row : QT, TT, MM, LD, CHG ....

select recid from t24live.FBNK_FTBU000 where recid like 'BC16%'
-18 , da archive ???

--10. FBNK_PM_TRAN_ACTIVITY

select recid from t24live.FBNK_PM_TRAN_ACTIVITY where recid not like 'TT%' and  recid not like 'DC%'
and recid not like 'FT%' 
and recid not like '1%' and recid not like 'FX%' and recid not like 'LD%'
 and recid not like 'MM%' and recid like 'MS%'and recid like 'SCTRSC%' and recid like 'VC%' and recid like 'VS%'
 
 select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like '1%';
-21837
SQL>  select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'LD%';
-488119
  select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'MM%';
-2941432
    select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'FX%';
-284870
SQL> select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'MS%';
-918
SQL> select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'SCTRSC%';
-3352
SQL> select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'VC%';
-150
SQL> select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'VS%';
-983

--11. FBNK_AI_USER_LOG
  select count (*) from t24live.FBNK_PM_TRAN_ACTIVITY where  recid  like 'MM%';
.APPLICATION.YYYY...
  .CHANGEPASS.YYYY
  .ENQUIRY.YYYY
  .LOGOUT.YYYY

FBNK_RE_C018
FBNK_RE_C019
FBNK_RE_CONSOL_PROFIT
FBNK_AI_CORP_TXN_LOG
F_DE_O_HANDOFF
F_DE_O_HEADER
F_DE_O_REPAIR
F_DE_O_MSG_ADVICE
FBNK_TXN_LOG_TCB

