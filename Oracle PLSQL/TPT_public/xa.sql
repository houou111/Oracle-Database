select * from table( dbms_xplan.display_cursor(null, null, 'ADVANCED +ALLSTATS LAST +MEMSTATS LAST') );
