SELECT x
  FROM y
 WHERE a NOT IN (SELECT x
                   FROM y
                  WHERE a NOT IN (1, 2, 3))
   AND bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
   AND bbbbb NOT IN (SELECT x
                       FROM y
                      WHERE a NOT IN (SELECT x
                                        FROM y))
   AND bbbbb NOT IN (SELECT x
                       FROM y
                      WHERE a NOT IN (SELECT x
                                        FROM y
                                       WHERE a NOT IN (1, 2, 3)))
   AND bbbbb NOT IN (SELECT x
                       FROM y
                      WHERE a NOT IN (SELECT x
                                        FROM y
                                       WHERE a NOT IN (1, 2, 3)))
   AND b NOT IN (SELECT x
                   FROM y);

SELECT x
  FROM y
 WHERE a NOT IN (SELECT x
                   FROM y
                  WHERE a NOT IN (1, 2, 3))
   AND (SELECT x
          FROM y) IS NULL;

SELECT col1
  FROM tab
 WHERE col1 = 22
 GROUP BY 1
HAVING a > b
ORDER BY 1;

INSERT   INTO tab
   VALUES (1, 2, 3);

INSERT   INTO tab
   SELECT u
     FROM v;

UPDATE tab
   SET a = b,
       c = d;

DELETE FROM tab
 WHERE a = 1000;
