/*  The examples below are editable and saved on a per-tab basis */



SELECT   *
  FROM   tab
 WHERE   variable_ofne > variable_two AND
         variable_three < function_abc (parameter_one, parameter_two) AND
         variable_four = variable_five;

  SELECT   moviecategory.categoryname,
           movietitle.rating,
           movietitle.movieid,
           movietitle.title
    FROM   movies_prod.movietitle, movies_prod.moviecategory
   WHERE   mtle.md <= 20 AND
           ( (movy.catd = move.cd)) AND
           ( (movy.cid = mov.ryid))
ORDER BY   moviecategory.categoryname, movietitle.rating ASC;

SELECT   x
  FROM   y
 WHERE   a > 1 AND b > 2 AND c > 3;

SELECT   x
  FROM   y
 WHERE   a > 1 OR b > 2 OR c > 3;

SELECT   x
  FROM   y
 WHERE   a > 1 AND b > 2 AND c > 3 OR
         a > 1 AND b > 2 AND c > 3 AND b > 2 AND c > 3 OR
         a > 1 AND b > 2 AND c > 3;

BEGIN
     LOOP
          EXIT WHEN a OR b AND (b21 AND b22 AND (b231 OR b233)) OR b AND (c);
     END LOOP;
END;

SELECT   moviecategory.categoryname,
         movietitle.movieid,
         movietitle.title,
         movietitle.year,
         moviecopy.copyformat,
         moviecopy.moviecopyid,
         rentalitem.rentalid,
         movierental.totalcharge
  FROM   movies_prod.moviecopy,
         movies_prod.movietitle,
         movies_prod.rentalitem,
         movies_prod.moviecategory,
         movies_prod.movierental
 WHERE   ( (movietitle.movieid = moviecopy.movieid) AND
          (moviecopy.copycondition = 'NEW') AND
          (moviecopy.moviecopyid = rentalitem.moviecopyid) AND
          (moviecategory.categoryid = movietitle.categoryid) AND
          (movierental.rentalid = rentalitem.rentalid));