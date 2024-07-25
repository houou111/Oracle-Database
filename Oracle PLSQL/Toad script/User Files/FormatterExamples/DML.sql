/*  The examples below are editable and saved on a per-tab basis */



UPDATE   titles
   SET   ttl_descriptionfffffffff =   a,
         z =                          b,
         u =                          d,
         v =                          (SELECT   descrshort
                                         FROM   hrsdon.ps_na_name_prefix@batch.ccci.org
                                        WHERE   ttl_code = name_prefix),
         updated_sdate =              sysffffffffffffffffffffffffffffffffffdate,
         updated_by =                 'MIGDBA';

SELECT   jobs.*, employees.*
  FROM                       hr.jobs
                        JOIN
                             hr.employees
                        ON (jobs.job_id = employees.job_id)
                   JOIN
                        hr.employees
                   ON (UPPER (jobs.max_salary) = UPPER (employees.salary))
              JOIN
                   hr.employees
              ON (jobs.job_id = employees.job_id)
         JOIN
              hr.employees
         ON (UPPER (jobs.max_salary) = UPPER (employees.salary));

UPDATE   titles
   SET   ttl_description =   (SELECT   descrshort
                                FROM   hrsdon.ps_na_name_prefix@batch.ccci.org
                               WHERE   ttl_code = name_prefix),
         updated_sdate =     SYSDATE,
         updated_by =        'MIGDBA';

SELECT   a,
         b,
         c,
         d
  FROM   u,
         v,
         w,
         x
 WHERE   NOT EXISTS (SELECT   x
                       FROM   y
                      WHERE   EXISTS (SELECT   u FROM v));

INSERT   ALL
  INTO   sales (prod_id,
                cust_id,
                time_id,
                amount)
VALUES   (product_id,
          customer_id,
          weekly_start_date,
          sales_sun)
  INTO   sales (prod_id,
                cust_id,
                time_id,
                amount)
VALUES   (product_id,
          customer_id,
          weekly_start_date + 1,
          sales_mon)
     SELECT   product_id,
              customer_id,
              weekly_start_date,
              sales_sun,
              sales_mon,
              sales_tue,
              sales_wed,
              sales_thu,
              sales_fri,
              sales_sat
       FROM   sales_input_table;

INSERT INTO tab (a,
                 b,
                 c,
                 d)
  VALUES   (x,
            y,
            z,
            u);

INSERT INTO tab (aa,
                 bbbb,
                 bb,
                 bbbbb)
  VALUES   (1,
            2,
            3,
            4);

INSERT INTO tab (a,
                 b,
                 c,
                 d)
  VALUES   (x,
            y,
            z,
            u);

INSERT INTO tab (a,
                 b,
                 c,
                 d)
     SELECT   a,
              b,
              c,
              d
       FROM   u,
              v,
              w,
              x
      WHERE   NOT EXISTS (SELECT   x
                            FROM   y
                           WHERE   EXISTS (SELECT   u FROM v));

UPDATE   tab
   SET   a = b, c = d, e = f, g = h
 WHERE   NOT EXISTS (SELECT   x
                       FROM   y
                      WHERE   EXISTS (SELECT   u FROM v));

DELETE FROM   tab
      WHERE   NOT EXISTS (SELECT   x
                            FROM   y
                           WHERE   EXISTS (SELECT   u FROM v));

SELECT   w1.name, w2.name
  FROM   mytable w1, mytable3 w2
 WHERE   w1.name LIKE 'XXX-%' AND
         w2.name LIKE 'YYY-%' AND
         SUBSTR (w1.name, 4) = SUBSTR (w2.name, 4)