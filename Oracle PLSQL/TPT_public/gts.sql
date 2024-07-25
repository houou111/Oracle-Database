exec dbms_stats.gather_table_stats(user, upper('&1'), null, 100, cascade=>true);


