/*  The examples below are editable and saved on a per-tab basis */


DECLARE
     a  number;
     b  number := 1;
BEGIN
     NULL;
END;

CREATE TABLE tab (a number,
                  b number);

CREATE VIEW vw (a,
                b,
                c,
                d)
AS
     SELECT   a,
              b,
              c,
              d
       FROM   tab;

CREATE PACKAGE BODY pkg
AS
     PROCEDURE p1
     IS
          h_koers_vrmnt          number (12, 6);
          h_koers_boekheeeeeeee  number (12, 6);
          h_koers_vm             number (9, 6);
          h_systeem              number (1);
          h_munt_bkh             varchar2 (3) := 'USD';
          h_euromunt_vm          number (1);
          h_dummy varchar2 (1000)
                    := 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' ;
          h_foutnr               number (3) := 100;
          h_aankoop              number (1);
          h_verkoop              number (1) := 1;
     BEGIN
          NULL;
     END;

     PROCEDURE p2
     IS
          h_koers_vrmnt  number (12, 6);
          h_koers_boekh  number (12, 6);
          h_koers_vm     number (9, 6);
          h_systeem      number (1);
          h_munt_bkh     varchar2 (3);
          h_euromunt_vm  number (1);
          h_dummy        varchar2 (1);
          h_foutnr       number (3);
          h_aankoop      number (1);
          h_verkoop      number (1);
     BEGIN
          NULL;
     END;
END;