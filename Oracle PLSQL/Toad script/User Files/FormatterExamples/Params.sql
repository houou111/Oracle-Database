/*  The examples below are editable and saved on a per-tab basis */



BEGIN
     a :=   func (fact_header_id,
                  oorsprong,
                  art_act_div,
                  omsch =>     3,
                  aantal,
                  soort,
                  eenheid =>   66666666,
                  afwart_id);
END;

BEGIN
     a_proc_call (aaa,
                  bbb,
                  ccc,
                  eee,
                  fff);
     my_procedure (1 + 9 * aaa,
                   var2,
                   3 * variable_c + func (5),
                   eee);
     complex_proc_call (2 * variable_one,
                        func1 (8 + var2, var3),
                        5 + func2 (7 + var4),
                        'my string',
                        func3 (inner_func1 (32), 'str'),
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

BEGIN
     a :=   f (g (h (a)));
END;