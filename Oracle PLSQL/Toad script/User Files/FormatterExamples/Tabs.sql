/*  The examples below are editable and saved on a per-tab basis */

DROP TABLE my_table1;

CREATE TABLE my_table1 (my_num1 number,
                        my_num2 number);

INSERT INTO my_table1 (my_num1, my_num2)
  VALUES   (12, 100);

INSERT INTO my_table1 (my_num1, my_num2)
  VALUES   (15, 100);

INSERT INTO my_table1 (my_num1, my_num2)
  VALUES   (18, 100);

SELECT   * FROM my_table2;

VARIABLE x refcursor

BEGIN
     a_proc_call (aaa,
                  bbb,
                  ccc,
                  ddd,
                  eee,
                  fff);

     my_procedure (1 + 9 * aaa,
                   var2,
                   3 * variable_c + func (5),
                   eee);

     complex_proc_call (2 * variable_one,
                        func1 (8 + var2,
                               argument_x,
                               COS (3 / res),
                               var3),
                        5 + func2 (7 + var4),
                        'my string',
                        func3 (inner_func1 (32),
                               inner_func2 (var5, 'test'),
                               inner_func3 (9 - var6 / (var7 * 2)),
                               'str'),
                        78);

     proc_call_with_query
     (
          aaa + (SELECT   MAX (col1) + COUNT (col2) FROM tab1),
          bbb * func (123, 456, 789)
     );

     procedure_with_named_params (named_parameter_one =>       1 + 5 * var,
                                  another_named_parameter =>   SIN (p1) / 8,
                                  last_named_p =>              7);
END;