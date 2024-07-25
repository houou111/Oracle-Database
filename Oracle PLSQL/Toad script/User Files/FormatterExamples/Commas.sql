/*  The examples below are editable and saved on a per-tab basis */

DROP
   TABLE
   my_table1;

CREATE TABLE my_table1
(
     my_num1 number,
     my_num2 number
);

INSERT INTO building_blocks
           (
                 aaaaaaaaaaaaaaaa,
                 bbbbbbbbbbbbbb,
                 cccccccccccccccc,
                 ddddddddddddddddd,
                 eeeeeeeeeeeee
           )
     SELECT   aaaaaaaaaaaaaaaa,
              bbbbbbbbbbbbbbbbbbb,
              cccccccccccccccccc,
              dddddddddddddddd,
              eeeeeeeeeeeeeee,
              fffffffffffffffff
       FROM   mytab, histab, hertab
      WHERE   histab.col1 = hertab.col2;

INSERT INTO tab
  VALUES
           (
                 1
           );