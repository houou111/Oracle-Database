-- Expressions & conditions (can be seen as functions)
/*FMT!*****************************************************
 *  11.1.0
 *********************************************************/
-- direct access to a sequence (11g)

DECLARE
   seq_value      NUMBER;
BEGIN
   seq_value        := employees_seq.NEXTVAL;
END;
/


/*FMT!*****************************************************
 *  10.1.0
 *********************************************************/
-- interval expr extention

SELECT     col1 DAY ( 3 ) TO SECOND,
           col2 DAY TO SECOND ( 5 ),
           col3 DAY ( 2 ) TO SECOND ( 8 ),
           col4 YEAR ( 1 ) TO MONTH
FROM       tab1;


-- conditions

SELECT     a,
           b,
           c,
           d,
           e,
           f,
           g
FROM       tab
WHERE      a IS NAN
       AND b IS NOT INFINITE
       AND c IS A SET
       AND d IS NOT A SET
       AND a MEMBER g
       AND b NOT MEMBER OF f
       AND e SUBMULTISET OF f
       AND e NOT SUBMULTISET g;


SELECT     product_id, TO_CHAR (ad_finaltext)
FROM       print_media
WHERE      ad_textdocs_ntab IS NOT EMPTY;


SELECT     * 
FROM       t
WHERE      tt IS EMPTY;


SELECT     first_name
FROM       employees
WHERE      REGEXP_LIKE (first_name, '^Ste(v|ph)en$');


-- operators

SELECT     CONNECT_BY_ROOT last_name "Manager"
-- CONNECT_BY_ROOT operator
FROM       employees
WHERE      LEVEL > 1 AND department_id = 110
CONNECT BY PRIOR employee_id = manager_id;


SELECT     customer_id,
           cust_address_ntab MULTISET EXCEPT DISTINCT cust_address2_ntab
              multiset_except
FROM       customers_demo;


SELECT     cust_address_ntab MULTISET INTERSECT ALL cust_address2_ntab
              multiset_intersect
FROM       customers_demo;


SELECT     cust_address_ntab MULTISET UNION cust_address2_ntab multiset_union
FROM       customers_demo;


SELECT     customer_id,
           cust_address_ntab MULTISET EXCEPT DISTINCT cust_address2_ntab
              multiset_except
FROM       customers_demo;


-- pseudocolumns

SELECT     last_name "Employee",
           CONNECT_BY_ISLEAF "IsLeaf",
           CONNECT_BY_ISCYCLE,
           LEVEL ORA_ROWSCN,
           SYS_CONNECT_BY_PATH (last_name, '/') "Path"
FROM       employees
WHERE      level <= 3 AND department_id = 80
START WITH last_name = 'King'
CONNECT BY PRIOR employee_id = manager_id AND LEVEL <= 4;


-- could also be 9i or lower

BEGIN
   a                := (col_a - col_b) AT LOCAL;
   a                := (col_a - col_b) AT TIME ZONE 'my_timezone';
   a                := (col_a - col_b) AT TIME ZONE DBTIMEZONE;
   a                := (col_a - col_b) AT TIME ZONE SESSIONTIMEZONE;
   a                := (col_a - col_b) AT TIME ZONE obj_timezone;
   a                := (col_a - col_b) DAY TO SECOND;
   a                := (col_a - col_b) YEAR TO MONTH;
   a                := (col_a - col_b) DAY ( 3 ) TO SECOND;
   a                := (col_a - col_b) DAY TO SECOND ( 3 );
   a                := (col_a - col_b) DAY ( 3 ) TO SECOND ( 3 );
   a                := (col_a - col_b) YEAR ( 3 ) TO MONTH;
END;
/


-- bugfix:

SELECT     ( (1)) one
FROM       DUAL;


/*FMT!*****************************************************
 *  9.2.0
 *********************************************************/
-- NEW

INSERT INTO building_blocks
VALUES     (NEW shape ('my_shape', 4));


SELECT     NEW type_name ()
FROM       DUAL;


-- parens in SQL necessary

DECLARE
   s1             shape := NEW shape ('void');
   s2             shape := NEW my_schema.shape;
-- parens in PL/SQL not necessary
BEGIN
   NULL;
END;
/


INSERT INTO rectangle_table
   SELECT     NEW rectangle (s.NAME, s.LENGTH, s.breadth)
   FROM       square_table s;


UPDATE     rectangle_table
SET        rec               = NEW rectangle ('Quad', 12, 5)
WHERE      rec IS NULL;


BEGIN
   a                := NEW abcde;

-- a                          := :NEW.filename;   -- is not valid, except in CREATE TRIGGER
   a                := NEW.filename;
   NEW              := NEW || 'x';
   RETURN NEW;
END;


UPDATE     rectangle_table
SET        rec               = NEW rectangle ('Quad', 12, 5)
/


CREATE TRIGGER scott.salary_check
   BEFORE INSERT OR UPDATE OF sal, job
   ON scott.emp
   REFERENCING OLD AS OLD NEW AS NEW
   FOR EACH ROW
   WHEN (NEW.job <> 'PRESIDENT')
BEGIN
   NULL;
END;
/


-- Pseudo columns

SELECT     ROWID
FROM       dual
WHERE      ROWNUM < 11;


-- EQUALS_PATH

SELECT     any_path
FROM       resource_view
WHERE      EQUALS_PATH (res, '/sys/schemas/OE/www.oracle.com') = 1;


-- UNDER_PATH

SELECT     any_path
FROM       resource_view
WHERE      UNDER_PATH (res, '/sys/schemas/OE/www.oracle.com') = 1;


-- expression_list in group comparision & membership condition (5-7 & 5-10)

SELECT     a, b, c
FROM       my_table
WHERE      a >= ALL (1, 2, 3);


SELECT     a, b, c
FROM       my_table
WHERE      (a, b) >= SOME ( (1, 2), (1, 3));


SELECT     * 
FROM       employees
WHERE      (first_name, last_name, email) NOT IN ( ('Guy',
                                                    'Himuro',
                                                    'GHIMURO'),
                                                  ('Karen',
                                                   'Colmenares',
                                                   'KCOLMENA'));


--------------------
-- bug-fixes
--------------------

SELECT     (TREAT (VALUE (p) AS empl_t)).empid
--T920      -- new syntax:  '(' expression ')' '.' method
FROM       persons_view p;


SELECT     (TREAT (VALUE (p) AS empl_t)).empid.text (1)
FROM       persons_view p;


CREATE OR REPLACE VIEW exu8tne
   (
   tsno,
   fileno,
   blockno,
   LENGTH
   )
AS
   SELECT     e.tsno,
              e.fileno,
              e.blockno,
              CEIL
              (e.LENGTH
             * ( (SELECT     t1$.BLOCKSIZE
                  FROM       SYS.ts$ t1$
                  WHERE      t1$.ts# = e.tsno)
              /  -- was a problem in this espression
                (SELECT     t0$.BLOCKSIZE
                 FROM       SYS.ts$ t0$
                 WHERE      t0$.ts# = 0))
              )
   FROM       SYS.exu9tne e
/


CREATE OR REPLACE FUNCTION new
   --T920
   RETURN NUMBER
-- in here new is used as a variable
IS
   new            NUMBER := 2;
BEGIN
   new              := 3 * new;
   -- was bug in 4.8.x
   RETURN new;
-- was also bug in 4.8.x
END;
/


SELECT     sql,
           -- bug on SQL, expected always '%'
           sql.sql sql,
           ff (sql),
           gg (sql => sql)
FROM       sql sql;


-------------------------
-- undocumented features
-------------------------

SELECT     * 
--T920
FROM       dual
WHERE      'X' = ANY decode (dummy, 'x', 'X', dummy);


-- should probably not be accepted; what are the semantics???

SELECT     * 
--T920
FROM       dual
WHERE      'X' = ANY 'X' || ' ' -- should probably not be accepted; what are the semantics???
/


SELECT     * 
FROM       tab
WHERE      a = ANY a;


SELECT     a
FROM       nummers
WHERE      a IN 1.5 * 2 + 1 --T920   -- undocumented
/


/*FMT!*****************************************************
 *  9.0.1
 *********************************************************/
-- CASE (4-5)  [simple case]

SELECT     1, CASE 1
                 WHEN 1 THEN 'One'
                 WHEN 5000 THEN 'High'
              END
FROM       dual;


SELECT     cust_last_name, CASE credit_limit
                              -- simple CASE expression
                           WHEN 100 THEN 'Low'
                              WHEN 5000 THEN 'High'
                              ELSE 'Medium'
                           END
FROM       customers;


DECLARE
   grade          CHAR (1);
   appraisal      VARCHAR2 (20);
BEGIN
   appraisal        := CASE grade
                          -- simple CASE
                       WHEN 'A' THEN 'Excellent'
                          WHEN 'B' THEN 'Very Good'
                          WHEN 'C' THEN 'Good'
                          WHEN 'D' THEN 'Fair'
                          WHEN 'F' THEN 'Poor'
                          ELSE 'No such grade'
                       END;
   appraisal        := CASE
                          -- searched CASE (is 8i)
                       WHEN grade = 'A' THEN 'Excellent'
                          WHEN grade = 'B' THEN 'Very Good'
                          WHEN grade = 'C' THEN 'Good'
                          WHEN grade = 'D' THEN 'Fair'
                          WHEN grade = 'F' THEN 'Poor'
                          ELSE 'No such grade'
                       END;
END;
/


-- Cursor expressions (4-7)

SELECT     title, CURSOR
                  (SELECT     * 
                   FROM       dual
                  ), work
FROM       dep d;


SELECT     name
FROM       emp e
WHERE      fun
           (CURSOR
            (SELECT     * 
             FROM       dual
            ),
            name
           ) = 1;


-- Datetime & Interval expressions (4-10)

SELECT     (date2 - date1) DAY TO SECOND
-- T920
FROM       dt;


-- SELECT (date2 - date1) DAY   -- does not work in 9.2.0
--   FROM dt;

SELECT     (date2 - date1) AS DAY
-- T920
FROM       dt;


DECLARE
   -- T920
   lifetime       INTERVAL YEAR ( 3 ) TO MONTH;
   a_date         DATE;
   interv         INTERVAL DAY TO SECOND;
BEGIN
   lifetime         := INTERVAL '101-3' YEAR TO MONTH;
   lifetime         := '101-3';
   lifetime         := INTERVAL '101' YEAR;
   lifetime         := INTERVAL '3' MONTH;
   a_date           := DATE '2003-10-10';
   a_date           := TIMESTAMP '2003-02-20 10:31:00';
   interv           := INTERVAL '30.12345' SECOND;
   interv           := INTERVAL '120' HOUR;
END;
/


DECLARE
   interv         INTERVAL DAY TO SECOND;
BEGIN
   interv           := INTERVAL '30.12345' SECOND ( 2 , 4 );
   -- does not work in Ora-DB 9.2, but why?
   interv           := INTERVAL '120' HOUR ( 3 );
-- does not work in Ora-DB 9.2, but why?
END;
/


SELECT     INTERVAL '120' HOUR ( 3 )
--T920
FROM       dual;


SELECT     start_time + INTERVAL '1-2' YEAR TO MONTH
FROM       schedule;


SELECT     (SYSTIMESTAMP - order_date) DAY TO SECOND
FROM       orders;


SELECT     AVG(x) OVER (
                     ORDER /*SIBLINGS*/ BY z
                     RANGE INTERVAL '40' MINUTE PRECEDING)
FROM       t;


SELECT     AVG
              (x) OVER (ORDER BY z RANGE INTERVAL '120' HOUR ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER /*SIBLINGS*/ BY z
                     RANGE INTERVAL '30.12345' SECOND ( 2 , 4 ) PRECEDING)
FROM       t;


SELECT     level,
           XMLElement ("employees", XMLElement ("enumber", employee_id))
FROM       hr.employees
START WITH last_name = 'De Haan'
CONNECT BY PRIOR employee_id = manager_id
ORDER      SIBLINGS BY hire_date;


SELECT     * 
FROM       tab
WHERE      INTERVAL '20' DAY - INTERVAL '240' HOUR =
              INTERVAL '10-0' DAY TO SECOND;


SELECT     * 
FROM       tab
WHERE      INTERVAL '5-3' YEAR TO MONTH + INTERVAL '20' MONTH =
              INTERVAL '6-11' YEAR TO MONTH;


DECLARE
   d1             DATE := DATE '1998-12-25';
   t1             TIMESTAMP := TIMESTAMP '1997-10-22 13:01:01';
   t2             TIMESTAMP WITH TIME ZONE
         := TIMESTAMP '1997-01-31 09:26:56.66 +02:00' ;
   i1             INTERVAL YEAR TO MONTH := INTERVAL '3-2' YEAR TO MONTH;
   i2             INTERVAL DAY TO SECOND
         := INTERVAL '5 04:03:02.01' DAY TO SECOND ;
BEGIN
   NULL;
END;


DECLARE
   lag_time       INTERVAL DAY ( 3 ) TO SECOND ( 3 );
BEGIN

   IF lag_time > INTERVAL '6' DAY
   THEN
      NULL;
   END IF;

END;


-- EXTRACT


SELECT     EXTRACT (DAY FROM DATE '1998-03-07')
FROM       dual;


SELECT     EXTRACT (MONTH FROM DATE '1998-03-07')
FROM       dual;


SELECT     EXTRACT (HOUR FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT (MINUTE FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT (SECOND FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT (YEAR FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT
              (TIMEZONE_ABBR FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT
              (TIMEZONE_HOUR FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT
              (TIMEZONE_MINUTE FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     EXTRACT
              (TIMEZONE_REGION FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')
FROM       DUAL;


SELECT     timestamp, interval, date
-- the use of timestamp, date and interval as column_names
FROM       tab;


SELECT     TIMESTAMP '1999-01-01 01:01:01' AT TIME ZONE 'US/Pacific'
FROM       dual;


SELECT     TIMESTAMP '1999-01-01 01:01:01' AT TIME ZONE TZ_OFFSET ('GMT')
FROM       DUAL;


SELECT     TIMESTAMP '1997-01-01 01:00:00' AT TIME ZONE myzone
FROM       dual;


SELECT     SYSTIMESTAMP - INTERVAL '1' DAY
--T920  -- caused a GPF in XMLTree()
FROM       dual
/


-- Like variants (5-12)

SELECT     last_name
FROM       employees
WHERE      last_name LIKEC '%A\_B%' ESCAPE '\';


SELECT     ROWID
FROM       offices
WHERE      ROWIDTOCHAR (ROWID) LIKE4 '%Br1AAB%';


-- IS OF (5-16)

SELECT     REF (p)
FROM       Person_v P
WHERE      VALUE (p) IS OF (Employee_typ, Student_typ);


SELECT     REF (p)
FROM       Person_v P
WHERE      VALUE (p) IS NOT OF (Employee_typ, Student_typ);


SELECT     REF (p)
FROM       Person_v P
WHERE      VALUE (p) IS OF TYPE (Employee_typ, Student_typ);


SELECT     REF (p)
FROM       Person_v P
WHERE      VALUE (p) IS NOT OF TYPE (Employee_typ, Student_typ);


SELECT     REF (p)
FROM       Person_v P
WHERE      VALUE (p) IS NOT OF TYPE (ONLY Employee_typ, ONLY Student_typ);


-- IN object_name  in boolean_expressions  (is PL/SQL)

DECLARE

   TYPE NumList IS TABLE OF NUMBER;

   depts          NumList := NumList (10, 30, 70);
BEGIN

   FOR i IN 1 .. 3
   LOOP

      UPDATE     emp
      SET        empno             = empno
      WHERE      empno IN depts (i);

   -- IN object_name  is an undocumented 9i feature
   END LOOP;

   FORALL j IN depts.FIRST .. depts.LAST

      UPDATE     emp
      SET        empno             = empno
      WHERE      empno IN depts (j);

-- IN object_name  is an undocumented 9i feature
END;
/


-----------------------------------------------------------
-- Test code used for finding bugs due
-- to the extentions of the syntax
-----------------------------------------------------------
-- gave/gives syntax problems with PLF   (also S/R conflicts)

SELECT     dummy day
FROM       dual;


SELECT     dummy at
FROM       dual;


SELECT     dummy year
FROM       dual;


-- are OK

SELECT     dummy timestamp
FROM       dual;


SELECT     dummy interval
FROM       dual;


-- SELECT dummy date from dual; /* does not work on Oracle 9.0.1 or 9.2 */
/*Asja -  missed overlaps, OVERLAPS works beginning from 9.0.1 version */

SELECT     * 
FROM       dual
WHERE      (TO_DATE ('20-12-2006'), TO_DATE ('27-12-2006')) OVERLAPS
              (TO_DATE ('22-12-2006'), TO_DATE ('30-12-2006'));


SELECT     COUNT ( * )
FROM       (SELECT     datetime d1, datetime d2
            FROM       tblpassage)
WHERE      (TO_DATE ('20-12-2006'), TO_DATE ('21-12-2006')) OVERLAPS (d1, d2);


SELECT     * 
FROM       dual
WHERE      (SYSDATE - 3, SYSDATE - 1) OVERLAPS
              (SYSDATE, NUMTODSINTERVAL (-2, 'day'));


/*FMT!*****************************************************
 *  8i and older
 *********************************************************/
-- DANGLING, ROWID =

SELECT     t.mgr.name
FROM       dept t
WHERE      t.mgr IS NOT DANGLING;


SELECT     ename
FROM       emp
WHERE      ROWID = 'AAAAZ8AABAAABvlAAA';


-- INTERVAL expressions

SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '7' DAY PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '123-2' YEAR ( 3 ) TO MONTH PRECEDING)
FROM       t;


SELECT     AVG
              (x) OVER (ORDER BY z RANGE INTERVAL '123' YEAR ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG

           (x
           ) OVER (ORDER BY z RANGE INTERVAL '300' MONTH ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '4' YEAR PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '50' MONTH PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '123' YEAR PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                  ORDER BY z
                  RANGE INTERVAL '4 5:12:10.222' DAY ( 3 ) TO SECOND ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '4 5:12' DAY TO MINUTE PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '4 5:12' DAY TO MINUTE PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '400 5' DAY ( 3 ) TO HOUR PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '400' DAY ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                  ORDER BY z
                  RANGE INTERVAL '11:12:10.2222222' HOUR TO SECOND ( 7 ) PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '11:20' HOUR TO MINUTE PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '10' HOUR PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '10:22' MINUTE TO SECOND PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '10' MINUTE PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '4' DAY PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '25' HOUR PRECEDING)
FROM       t;


SELECT     AVG (x) OVER (ORDER BY z RANGE INTERVAL '40' MINUTE PRECEDING)
FROM       t;


SELECT     AVG
              (x) OVER (ORDER BY z RANGE INTERVAL '120' HOUR ( 3 ) PRECEDING)
FROM       t;


SELECT     AVG(x) OVER (
                     ORDER BY z
                     RANGE INTERVAL '30.12345' SECOND ( 2 , 4 ) PRECEDING)
FROM       t;


SELECT     INTERVAL '4 5' DAY TO HOUR C0
FROM       dual;


-- CASE expression  [only searched case]

SELECT     AVG (CASE WHEN e.sal > 2000 THEN e.sal ELSE 2000 END)
FROM       emp e;


SELECT     INTERVAL '4' DAY TO DAY
FROM       dual;


SELECT     INTERVAL '0' YEAR TO YEAR
FROM       dual;


-- ANY/SOME/ALL

SELECT     * 
FROM       tab
WHERE      a = ANY (b, a);


SELECT     * 
FROM       tab
WHERE      a = SOME (SELECT     x
                     FROM       y
                     ORDER BY x);


-- test for the parens and expr in the AST

BEGIN
   d1               := a;
   d2               := (a);
   d3               := ( (a));
   d4               := ( ( (a)));
END;
/


---------------------------------------
-- Caused Bugs
---------------------------------------

CREATE SEQUENCE "VBZ$DB_OBJ_NAMES_SEQ"
   INCREMENT BY 1
   START WITH 1
   MAXVALUE 1.0E27
   -- 1.0E27 not accepted at places of integers
   MINVALUE 1
   NOCYCLE
   CACHE 20
   NOORDER;


-- TREAT (6-182)

SELECT     TREAT (VALUE (p) AS empl_t).empid
FROM       persons_view p;


SELECT     (TREAT (VALUE (p) AS empl_t)).empid
FROM       persons_view p;


SELECT     ( ( (TREAT (VALUE (p) AS empl_t)))).empid
FROM       persons_view p;


SELECT     name, TREAT (VALUE (p) AS employee_t).salary salary
FROM       persons p;


-- theoretically (haven't found any description about using "TREAT =>" )

SELECT     1, gg (TREAT => sql)
FROM       dual;


/*Andre*/
-- from Type2

SELECT     i MOD 20, j REM 30
FROM       tab;


-- Serge, skipped expressions categories

SELECT     * 
FROM       tbl1
WHERE      col1 IS ANY
       AND a = ANY a
       AND col1 = ANY (SELECT     col1
                       FROM       tbl1)
       AND a1 IS NOT NAN
       AND b IS INFINITE;


SELECT     * 
FROM       tbl1
WHERE      col1 = ANY (SELECT     col1
                       FROM       tbl1)
        OR col1 >= ANY (SELECT     col1
                        FROM       tbl1)
        OR col1 <= ANY (SELECT     col1
                        FROM       tbl1)
        OR col1 > ANY (SELECT     col1
                       FROM       tbl1)
        OR col1 < ANY (SELECT     col1
                       FROM       tbl1)
        OR col1 <> ANY (SELECT     col1
                        FROM       tbl1)
        OR col1 <> SOME (SELECT     col1
                         FROM       tbl1)
        OR col1 = SOME (SELECT     col1
                        FROM       tbl1)
        OR col1 < SOME (SELECT     1
                        FROM       dual)
        OR col1 > SOME (SELECT     1
                        FROM       dual)
        OR col1 <= SOME (SELECT     1
                         FROM       dual)
        OR col1 >= SOME (SELECT     1
                         FROM       dual)
        OR col1 = ALL (SELECT     col1
                       FROM       tbl1)
        OR col1 >= ALL (SELECT     col1
                        FROM       tbl1)
        OR col1 > ALL (SELECT     col1
                       FROM       tbl1)
        OR col1 <> ALL (SELECT     col1
                        FROM       tbl1)
        OR col1 < ALL (SELECT     col1
                       FROM       tbl1)
        OR col1 <= ALL (SELECT     col1
                        FROM       tbl1)
        OR col1 NOT LIKE 'A%'
        OR col1 NOT BETWEEN 1 AND 3
        OR col1 < 2;


SELECT     * 
FROM       LTABLE
WHERE      (col1 LIKE '1%'
         OR col1 LIKEC '1%'
         OR col1 LIKE2 '1%'
         OR col1 LIKE4 '1%')
       AND (col1 NOT LIKE '1%'
         OR col1 NOT LIKEC '1%'
         OR col1 NOT LIKE2 '1%'
         OR col1 NOT LIKE4 '1%');


-- some relational statements

SELECT     * 
FROM       aa
WHERE      a <> 3;


SELECT     * 
FROM       aa
WHERE      a != 3;


SELECT     * 
FROM       aa
WHERE      a <= 3;


SELECT     * 
FROM       aa
WHERE      a >= 3;


SELECT     * 
FROM       bb
WHERE      a ^= b;


SELECT     * 
FROM       bb
WHERE      a ^= b;


DECLARE
   a              BOOLEAN;
BEGIN
   a                := 'a' ~= 'b';

-- but not "~  ="
END;
/


-- merge/delete inside IF statement

DECLARE
   a              BOOLEAN := TRUE;
BEGIN

   IF (a = TRUE)
   THEN
      BEGIN

         MERGE INTO tbl3
            USING       tbl2
            ON (c1 > k1)
            WHEN MATCHED
            THEN
               UPDATE SET c2                = 'ccc'
             LOG ERRORS ;

      END;
   ELSE
      BEGIN

         DELETE FROM tbl3;

      END;
   END IF;

END;
/


-- Igor, MOD and REM as function names

DECLARE
   str_var        varchar2 (200);
   i              number := 20;

   FUNCTION REM(in_var         IN   number, round_val      IN   number)
      RETURN number
   IS
   BEGIN
      RETURN MOD (in_var, round_val);
   END;

BEGIN
   str_var          := CASE mod (i, 2) WHEN 0 THEN 'file' ELSE 'view' END;
   str_var          := CASE rem (i, 2) WHEN 0 THEN 'file' ELSE 'view' END;
END;


