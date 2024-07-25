/*  The examples below are editable and saved on a per-tab basis */


DECLARE
     a1  number := f (aaaaaa, bbbbbbbb, cccccccccccc);
     a2 number
               := f
                  (
                       aaaaaaaaaaaaaaaaaaaaaaa,
                       bbbbbbbbbbbbbbbbbbbbbbbbb,
                       ccccccccccccccccccccccccccccccccc
                  ) ;
     a3  number := f (g (h (x)));
     a4 number
               := fffffffffffffffffffff(ggggggggggggggggggggggg(hhhhhhhhhhhhhhhhhhhhhhh(xxxxxxxxxxxxxxxxxxxxxxxxx))) ;
     a5 number
               := fffffffffffffffffffff(ggggggggggggggggggggggg(hhhhhhhhhhhhhhhhhhhhhhh
                                                                (
                                                                     xxxxxxxxxxxx,
                                                                     xxxxxxxxxxxxx
                                                                ))) ;

     TYPE frcflg_rt
     IS
          RECORD
          (
               last_name char (1),
               first_name char (1),
               middle_initial char (1),
               job_id char (1),
               changed_by char (1),
               changed_on char (1)
          );
BEGIN
     fffffffffffffffffffff(ggggggggggggggggggggggg(hhhhhhhhhhhhhhhhhhhhhhh
                                                   (
                                                        xxxxxxxxxxxx,
                                                        xxxxxxxxxxxxx
                                                   )));
     a :=   NVL (x, 100);
     a :=   NVL
            (
                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyy.zzzzzzzzzzzzzzzz,
                 100
            );
     a :=   other (x, 100);
     a :=   other
            (
                 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyy.zzzzzzzzzzzzzzzz,
                 100
            );
     a :=   DECODE (x, 1, a, 2, b, 5, d, def);
     a :=   DECODE
            (
                 xxxxxxxxxxxxxxxxxxx,
                 1, aaaaaaaaaaaaaaaaaaaaa,
                 2, bbbbbbbbbbbbbbbbbbbbb,
                 5, dddddddddddddddddddddddd,
                 def
            );
END;

SELECT   x
  FROM   tab
 WHERE   NOT EXISTS (SELECT   u
                       FROM   v
                      WHERE   NOT (a, b, c) IN (SELECT   k
                                                  FROM   l
                                                 WHERE   z = 1));

SELECT   f (1), g (2), h (3, 4, 5) FROM tab;

INSERT INTO building_blocks (a)
  VALUES
           (
                 NEW shape ('my_shape', 4)
           );

INSERT INTO tab
  VALUES
           (
                 1
           );

INSERT INTO building_blocks
           (
                 a, b, c
           )
  VALUES
           (
                 1, 2, 3
           );

INSERT INTO building_blocks
           (
                 a,
                 b,
                 c,
                 d,
                 e
           )
  VALUES
           (
                 1,
                 2,
                 3,
                 4,
                 5
           );

INSERT INTO building_blocks
           (
                 aaaaaaaaaaaaaaaa,
                 bbbbbbbbbbbbbb,
                 cccccccccccccccc,
                 ddddddddddddddddd,
                 eeeeeeeeeeeee
           )
  VALUES
           (
                 f (1), g (2), h (3, 4, 5)
           );

INSERT INTO building_blocks
     SELECT   aaaaaa,
              bbbb,
              cccccc,
              ddddd
       FROM   mytab, histab, hertab
      WHERE   histab.col1 = hertab.col2;

INSERT INTO building_blocks
     SELECT   aaaaaaaaaaaaaaaa,
              bbbbbbbbbbbbbbbbbbb,
              cccccccccccccccccc,
              dddddddddddddddd,
              eeeeeeeeeeeeeee,
              fffffffffffffffffffffffffff
       FROM   mytab, histab, hertab
      WHERE   histab.col1 = hertab.col2;

CREATE FUNCTION asja.dd
(
     cfin IN integer
)
     RETURN numeric
IS
BEGIN
     NULL;
END;

CREATE FUNCTION asja.dd
(
     cfin IN integer, cfout OUT integer,
     cfinout IN OUT integer
)
     RETURN numeric
IS
BEGIN
     NULL;
END;

CREATE FUNCTION asja.dd
(
     cfin IN integer, cfout OUT integer,
     cfout OUT NOCOPY integer, cfinout IN OUT NOCOPY integer,
     cfinout IN OUT integer
)
     RETURN numeric
IS
BEGIN
     NULL;
END;

CREATE TABLE t (a number);

CREATE TABLE t
(
     a number,
     b number,
     c number
);

CREATE TABLE t
(
     aaaaaaaaaaaaaaaaaaaaaaa number,
     bbbbbbbbbbbbbbbbbbbb number,
     ccccccccccccccccccc number
);