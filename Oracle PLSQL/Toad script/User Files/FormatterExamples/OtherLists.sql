/*  The examples below are editable and saved on a per-tab basis */



DELETE FROM   mytab
      WHERE   id = 1
  RETURNING   fact_header_id,
              oorsprong,
              tot_prijs,
              btw_perc
       INTO   :aaaaaaaa,
              :bbbbbbb,
              :cccccccc,
              :dddddddd,
              :mmmmmmm;

  SELECT   cust_gender,
           a,
           b,
           c,
           STATS_ONE_WAY_ANOVA (cust_income_level, amount_sold)
    FROM   sh.customers c, sh.sales s
   WHERE   c.cust_id = s.cust_id
GROUP BY   cust_gender,
           x,
           y,
           z
ORDER BY   a,
           b,
           d,
           e;

INSERT INTO my_table1 (my_num1,
                       my_num2,
                       x,
                       y,
                       z,
                       x)
  VALUES   (12,
            100,
            3,
            4,
            5,
            6);

  SELECT   a,
           b,
           d,
           e
    FROM   x,
           y,
           z,
           u,
           v,
           w
GROUP BY   aaaaaaaaaaaaaaaaa,
           eeeeeeeeeeeee,
           fffffffffffff,
           gggggggggggggg
ORDER BY   aaaaaaaaaa,
           cccccccccccccccc,
           bbbbbbbbbbbbb,
           e,
           f;

INSERT INTO mytab
   VALUES   (a,
             b,
             c,
             d,
             e,
             f)
RETURNING   x,
            y,
            z,
            u,
            v,
            w
     INTO   a,
            b,
            c,
            d,
            e,
            f;

BEGIN
     my_procedure (aaaaaaaaaaa,
                   bbbbbbbbbb,
                   ccccccccc4ccccccccccccccccccc,
                   dddddddddddddd,
                   eeeeeeeeeeeee,
                   ffffffffffff,
                   ggggggggggg);
END;

  SELECT   channel_desc, calendar_month_desc, co.country_id
    FROM   sales,
           customers,
           times,
           channels,
           countries co
GROUP BY   GROUPING SETS
           (
                (channel_desc, calendar_month_desc, co.country_id),
                (channel_desc, co.country_id),
                (channel_desc, co.country_id2),
                (channel_desc, co.country_id3),
                (calendar_month_desc, co.country_id)
           );