/*  The examples below are editable and saved on a per-tab basis */

CREATE OR REPLACE VIEW exu8tne
(
     tsno,
     fileno,
     blockno,
     LENGTH
)
AS
     SELECT   e.tsno,
              e.fileno,
              e.blockno,
              CEIL (e.LENGTH
                    * ( (SELECT   t1$.blocksize
                           FROM   sys.ts$ t1$
                          WHERE   t1$.ts# = e.tsno)
                       / -- was a problem
                          -- in this expression
                         (SELECT   t0$.blocksize -- select
                            FROM   sys.ts$ t0$
                           WHERE   t0$.ts# = 0)))
       FROM   sys.exu9tne e
/


CREATE OR REPLACE FUNCTION new --T920
     RETURN number -- in here new is used as a variable
IS
     new  number := 2;
BEGIN
     new :=   3 * new; -- was bug in 4.8.x
     RETURN new; -- was also bug in 4.8.x
END;
/

-- hi

BEGIN --00
     a :=   a --aa
             + b --bb
                + c --cc
                   ;
     NULL; --aaaa
     NULL; --aaaa2
     NULL; --aaaa3
      ----bb
      --cccccs
     NULL; --aaaa4
     NULL; --aaaa5
 --dd
END; --99

-- same without comments:

BEGIN
     a :=   a + b + c;
     NULL;
     NULL;
     NULL;


     NULL;
     NULL;
END;