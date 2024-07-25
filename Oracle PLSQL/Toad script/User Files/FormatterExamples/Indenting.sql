/*  The examples below are editable and saved on a per-tab basis */


BEGIN
     a :=   1;

     d :=   1;

     b :=   2;

     WHILE TRUE
     LOOP
          a :=   1;

          b :=   2;

          IF a > b
          THEN
               c :=   d;
          END IF;
     END LOOP;

     x :=   1;

     c :=   d;
END;

CREATE PROCEDURE myproc
AS
BEGIN
     NULL;
END;